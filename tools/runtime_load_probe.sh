#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: runtime_load_probe.sh --url <url>
       [--mode <load|stress|spike|soak>]
       [--method <verb>] [--header "<name>: <value>"] [--body-file <path>]
       [--stage <concurrency>:<duration-sec>] [--stage <concurrency>:<duration-sec> ...]
       [--concurrency <n>] [--duration-sec <n>]
       [--request-timeout-sec <n>] [--expect-status <code>]
       [--max-p95-sec <seconds>] [--max-p99-sec <seconds>]
       [--max-error-rate <ratio>] [--min-throughput <req-per-sec>]
       [--output-dir <dir>]

Run deterministic HTTP load/stress stages with curl workers, summarize latency/error metrics,
and fail objectively when thresholds are breached.
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

now_ms() {
  if date +%s%3N >/dev/null 2>&1; then
    date +%s%3N
  else
    python3 - <<'PY'
import time
print(int(time.time() * 1000))
PY
  fi
}

percentile_from_file() {
  local file="$1"
  local pct="$2"
  local count index

  count="$(wc -l < "$file" | tr -d ' ')"
  if [ "$count" -eq 0 ]; then
    printf 'n/a'
    return 0
  fi

  index=$(( (count * pct + 99) / 100 ))
  if [ "$index" -lt 1 ]; then
    index=1
  fi

  sort -n "$file" | sed -n "${index}p"
}

float_gt() {
  awk -v left="$1" -v right="$2" 'BEGIN { exit !(left > right) }'
}

float_lt() {
  awk -v left="$1" -v right="$2" 'BEGIN { exit !(left < right) }'
}

is_non_negative_decimal() {
  [[ "$1" =~ ^([0-9]+([.][0-9]+)?|[.][0-9]+)$ ]]
}

format_ratio() {
  awk -v numerator="$1" -v denominator="$2" 'BEGIN {
    if (denominator == 0) {
      print "0.0000"
    } else {
      printf "%.4f", numerator / denominator
    }
  }'
}

format_throughput() {
  awk -v total="$1" -v duration="$2" 'BEGIN {
    if (duration == 0) {
      print "0.00"
    } else {
      printf "%.2f", total / duration
    }
  }'
}

URL=""
METHOD="GET"
MODE="load"
BODY_FILE=""
OUTPUT_DIR=""
REQUEST_TIMEOUT_SEC=30
EXPECT_STATUS=""
MAX_P95_SEC=""
MAX_P99_SEC=""
MAX_ERROR_RATE=""
MIN_THROUGHPUT=""
FALLBACK_CONCURRENCY=""
FALLBACK_DURATION=""
declare -a HEADERS=()
declare -a STAGES=()

while [ $# -gt 0 ]; do
  case "$1" in
    --url)
      [ $# -ge 2 ] || die "missing value for --url"
      URL="$2"
      shift 2
      ;;
    --mode)
      [ $# -ge 2 ] || die "missing value for --mode"
      case "$2" in
        load|stress|spike|soak) ;;
        *) die "invalid --mode value: $2" ;;
      esac
      MODE="$2"
      shift 2
      ;;
    --method)
      [ $# -ge 2 ] || die "missing value for --method"
      METHOD="$2"
      shift 2
      ;;
    --header)
      [ $# -ge 2 ] || die "missing value for --header"
      HEADERS+=("$2")
      shift 2
      ;;
    --body-file)
      [ $# -ge 2 ] || die "missing value for --body-file"
      BODY_FILE="$2"
      shift 2
      ;;
    --stage)
      [ $# -ge 2 ] || die "missing value for --stage"
      STAGES+=("$2")
      shift 2
      ;;
    --concurrency)
      [ $# -ge 2 ] || die "missing value for --concurrency"
      FALLBACK_CONCURRENCY="$2"
      shift 2
      ;;
    --duration-sec)
      [ $# -ge 2 ] || die "missing value for --duration-sec"
      FALLBACK_DURATION="$2"
      shift 2
      ;;
    --request-timeout-sec)
      [ $# -ge 2 ] || die "missing value for --request-timeout-sec"
      REQUEST_TIMEOUT_SEC="$2"
      shift 2
      ;;
    --expect-status)
      [ $# -ge 2 ] || die "missing value for --expect-status"
      EXPECT_STATUS="$2"
      shift 2
      ;;
    --max-p95-sec)
      [ $# -ge 2 ] || die "missing value for --max-p95-sec"
      MAX_P95_SEC="$2"
      shift 2
      ;;
    --max-p99-sec)
      [ $# -ge 2 ] || die "missing value for --max-p99-sec"
      MAX_P99_SEC="$2"
      shift 2
      ;;
    --max-error-rate)
      [ $# -ge 2 ] || die "missing value for --max-error-rate"
      MAX_ERROR_RATE="$2"
      shift 2
      ;;
    --min-throughput)
      [ $# -ge 2 ] || die "missing value for --min-throughput"
      MIN_THROUGHPUT="$2"
      shift 2
      ;;
    --output-dir)
      [ $# -ge 2 ] || die "missing value for --output-dir"
      OUTPUT_DIR="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

[ -n "$URL" ] || die "--url is required"
command -v curl >/dev/null 2>&1 || die "curl is required"

[[ "$REQUEST_TIMEOUT_SEC" =~ ^[1-9][0-9]*$ ]] || die "--request-timeout-sec must be a positive integer"
if [ -n "$BODY_FILE" ] && [ ! -f "$BODY_FILE" ]; then
  die "body file not found: $BODY_FILE"
fi

if [ "${#STAGES[@]}" -eq 0 ]; then
  if [ -z "$FALLBACK_CONCURRENCY" ]; then
    FALLBACK_CONCURRENCY=5
  fi
  if [ -z "$FALLBACK_DURATION" ]; then
    FALLBACK_DURATION=10
  fi
  STAGES+=("${FALLBACK_CONCURRENCY}:${FALLBACK_DURATION}")
fi

for stage in "${STAGES[@]}"; do
  [[ "$stage" =~ ^[1-9][0-9]*:[1-9][0-9]*$ ]] || die "invalid --stage value: $stage"
done

if [ -n "$EXPECT_STATUS" ]; then
  [[ "$EXPECT_STATUS" =~ ^[0-9]{3}$ ]] || die "--expect-status must be a 3-digit HTTP status code"
fi

for threshold in "$MAX_P95_SEC" "$MAX_P99_SEC" "$MAX_ERROR_RATE" "$MIN_THROUGHPUT"; do
  if [ -n "$threshold" ]; then
    is_non_negative_decimal "$threshold" || die "threshold values must be zero or greater"
  fi
done

if [ -z "$OUTPUT_DIR" ]; then
  OUTPUT_DIR="$(mktemp -d)"
else
  mkdir -p "$OUTPUT_DIR"
fi

SUMMARY_TSV="$OUTPUT_DIR/summary.tsv"
REPORT_MD="$OUTPUT_DIR/report.md"
printf 'stage_index\tmode\tconcurrency\tduration_sec\ttotal_requests\terror_count\terror_rate\tthroughput_rps\tp50_sec\tp95_sec\tp99_sec\tstatus\tnotes\trun_dir\n' >"$SUMMARY_TSV"

is_success_status() {
  local code="$1"

  if [ "$code" = "transport_error" ]; then
    return 1
  fi

  if [ -n "$EXPECT_STATUS" ]; then
    [ "$code" = "$EXPECT_STATUS" ]
    return "$?"
  fi

  case "$code" in
    2??|3??) return 0 ;;
    *) return 1 ;;
  esac
}

run_worker() {
  local duration_sec="$1"
  local worker_id="$2"
  local run_dir="$3"
  local worker_file="$run_dir/worker-${worker_id}.tsv"
  local stderr_file="$run_dir/worker-${worker_id}.stderr.log"
  local deadline_ms
  local output
  local curl_args=()

  deadline_ms=$(( $(now_ms) + (duration_sec * 1000) ))
  curl_args=(-sS -o /dev/null -w '%{http_code}\t%{time_total}\n' --max-time "$REQUEST_TIMEOUT_SEC" -X "$METHOD")

  for header in "${HEADERS[@]}"; do
    curl_args+=(-H "$header")
  done

  if [ -n "$BODY_FILE" ]; then
    curl_args+=(--data-binary "@$BODY_FILE")
  fi

  : >"$worker_file"
  : >"$stderr_file"

  while [ "$(now_ms)" -lt "$deadline_ms" ]; do
    if output="$(curl "${curl_args[@]}" "$URL" 2>>"$stderr_file")"; then
      printf '%s\n' "$output" >>"$worker_file"
    else
      printf 'transport_error\t%s\n' "$REQUEST_TIMEOUT_SEC" >>"$worker_file"
    fi
  done
}

write_report() {
  {
    printf '# Runtime Load Probe\n\n'
    printf -- '- URL: `%s`\n' "$URL"
    printf -- '- Mode: `%s`\n' "$MODE"
    printf -- '- Method: `%s`\n' "$METHOD"
    printf -- '- Stages: `%s`\n' "${STAGES[*]}"
    printf -- '- Request timeout (seconds): `%s`\n' "$REQUEST_TIMEOUT_SEC"
    if [ -n "$EXPECT_STATUS" ]; then
      printf -- '- Expected status: `%s`\n' "$EXPECT_STATUS"
    fi
    if [ -n "$MAX_P95_SEC" ] || [ -n "$MAX_P99_SEC" ] || [ -n "$MAX_ERROR_RATE" ] || [ -n "$MIN_THROUGHPUT" ]; then
      printf '\n## Thresholds\n'
      [ -n "$MAX_P95_SEC" ] && printf -- '- max p95: `%s`\n' "$MAX_P95_SEC"
      [ -n "$MAX_P99_SEC" ] && printf -- '- max p99: `%s`\n' "$MAX_P99_SEC"
      [ -n "$MAX_ERROR_RATE" ] && printf -- '- max error rate: `%s`\n' "$MAX_ERROR_RATE"
      [ -n "$MIN_THROUGHPUT" ] && printf -- '- min throughput: `%s`\n' "$MIN_THROUGHPUT"
    fi

    printf '\n## Stage Summary\n'
    printf '| Stage | Mode | Concurrency | Duration (s) | Total | Errors | Error Rate | Throughput (req/s) | p50 | p95 | p99 | Status | Notes |\n'
    printf '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |\n'
    awk -F '\t' 'NR > 1 {
      printf("| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |\n",
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
    }' "$SUMMARY_TSV"
  } >"$REPORT_MD"
}

printf 'Runtime Load Probe\n'
printf 'URL: %s\n' "$URL"
printf 'Mode: %s\n' "$MODE"
printf 'Stages: %s\n' "${STAGES[*]}"
printf 'Output dir: %s\n' "$OUTPUT_DIR"
printf '\n'

overall_exit=0
stage_index=0
for stage in "${STAGES[@]}"; do
  stage_index=$((stage_index + 1))
  concurrency="${stage%%:*}"
  duration_sec="${stage##*:}"
  run_dir="$OUTPUT_DIR/stage-${stage_index}-c${concurrency}-d${duration_sec}"
  all_file="$run_dir/all.tsv"
  times_file="$run_dir/times.txt"
  notes=()

  mkdir -p "$run_dir"
  printf 'Running stage=%s concurrency=%s duration=%ss\n' "$stage_index" "$concurrency" "$duration_sec"

  pids=()
  for worker_id in $(seq 1 "$concurrency"); do
    run_worker "$duration_sec" "$worker_id" "$run_dir" &
    pids+=("$!")
  done

  worker_failed=false
  for pid in "${pids[@]}"; do
    if ! wait "$pid"; then
      worker_failed=true
    fi
  done

  if [ "$worker_failed" = true ]; then
    notes+=("worker-shell-failure")
  fi

  cat "$run_dir"/worker-*.tsv >"$all_file"
  awk -F '\t' '$2 ~ /^[0-9.]+$/ { print $2 }' "$all_file" >"$times_file"

  total_requests="$(wc -l < "$all_file" | tr -d ' ')"
  error_count=0
  if [ "$total_requests" -gt 0 ]; then
    while IFS=$'\t' read -r status_code _; do
      if ! is_success_status "$status_code"; then
        error_count=$((error_count + 1))
      fi
    done <"$all_file"
  fi

  error_rate="$(format_ratio "$error_count" "$total_requests")"
  throughput_rps="$(format_throughput "$total_requests" "$duration_sec")"
  p50_sec="$(percentile_from_file "$times_file" 50)"
  p95_sec="$(percentile_from_file "$times_file" 95)"
  p99_sec="$(percentile_from_file "$times_file" 99)"
  status="passed"

  if [ "$total_requests" -eq 0 ]; then
    status="failed"
    notes+=("no-requests-captured")
  fi

  if [ "$worker_failed" = true ]; then
    status="failed"
  fi

  if [ "$error_count" -gt 0 ] && [ -z "$MAX_ERROR_RATE" ]; then
    status="failed"
    notes+=("unexpected-status-or-transport-errors")
  fi

  if [ -n "$MAX_ERROR_RATE" ] && float_gt "$error_rate" "$MAX_ERROR_RATE"; then
    status="failed"
    notes+=("error-rate-threshold-breached")
  fi

  if [ -n "$MAX_P95_SEC" ] && [ "$p95_sec" != "n/a" ] && float_gt "$p95_sec" "$MAX_P95_SEC"; then
    status="failed"
    notes+=("p95-threshold-breached")
  fi

  if [ -n "$MAX_P99_SEC" ] && [ "$p99_sec" != "n/a" ] && float_gt "$p99_sec" "$MAX_P99_SEC"; then
    status="failed"
    notes+=("p99-threshold-breached")
  fi

  if [ -n "$MIN_THROUGHPUT" ] && float_lt "$throughput_rps" "$MIN_THROUGHPUT"; then
    status="failed"
    notes+=("throughput-threshold-breached")
  fi

  if [ "$status" != "passed" ]; then
    overall_exit=2
  fi

  notes_text="none"
  if [ "${#notes[@]}" -gt 0 ]; then
    notes_text="$(IFS=,; printf '%s' "${notes[*]}")"
  fi

  printf '  - total requests: %s\n' "$total_requests"
  printf '  - errors: %s\n' "$error_count"
  printf '  - error rate: %s\n' "$error_rate"
  printf '  - throughput (req/s): %s\n' "$throughput_rps"
  printf '  - p50: %s\n' "$p50_sec"
  printf '  - p95: %s\n' "$p95_sec"
  printf '  - p99: %s\n' "$p99_sec"
  printf '  - status: %s\n' "$status"
  printf '\n'

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$stage_index" "$MODE" "$concurrency" "$duration_sec" "$total_requests" "$error_count" "$error_rate" \
    "$throughput_rps" "$p50_sec" "$p95_sec" "$p99_sec" "$status" "$notes_text" "$run_dir" >>"$SUMMARY_TSV"
done

write_report

printf 'Report: %s\n' "$REPORT_MD"
printf 'Summary TSV: %s\n' "$SUMMARY_TSV"
printf 'Final outcome: %s\n' "$([ "$overall_exit" -eq 0 ] && printf clean || printf review-needed)"
exit "$overall_exit"
