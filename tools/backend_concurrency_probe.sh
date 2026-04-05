#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: backend_concurrency_probe.sh --url <url> [--method <verb>] [--concurrency <n>] [--concurrency <n> ...] [--header "<name>: <value>"] [--body-file <path>] [--idempotency-header <name>] [--idempotency-mode <same|unique>] [--expect-status <code>] [--batches <n>] [--output-dir <dir>]

Send real concurrent HTTP requests and summarize response-code/latency evidence.

Defaults:
- method: GET
- concurrency levels: 5, 10, 20
- idempotency mode: same
- batches: 1
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

URL=""
METHOD="GET"
OUTPUT_DIR=""
BODY_FILE=""
EXPECT_STATUS=""
IDEMPOTENCY_HEADER=""
IDEMPOTENCY_MODE="same"
BATCHES=1
declare -a CONCURRENCY_LEVELS=()
declare -a HEADERS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --url)
      [ $# -ge 2 ] || die "missing value for --url"
      URL="$2"
      shift 2
      ;;
    --method)
      [ $# -ge 2 ] || die "missing value for --method"
      METHOD="$2"
      shift 2
      ;;
    --concurrency)
      [ $# -ge 2 ] || die "missing value for --concurrency"
      CONCURRENCY_LEVELS+=("$2")
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
    --idempotency-header)
      [ $# -ge 2 ] || die "missing value for --idempotency-header"
      IDEMPOTENCY_HEADER="$2"
      shift 2
      ;;
    --idempotency-mode)
      [ $# -ge 2 ] || die "missing value for --idempotency-mode"
      case "$2" in
        same|unique) ;;
        *) die "invalid --idempotency-mode value: $2" ;;
      esac
      IDEMPOTENCY_MODE="$2"
      shift 2
      ;;
    --expect-status)
      [ $# -ge 2 ] || die "missing value for --expect-status"
      EXPECT_STATUS="$2"
      shift 2
      ;;
    --batches)
      [ $# -ge 2 ] || die "missing value for --batches"
      BATCHES="$2"
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

if [ "${#CONCURRENCY_LEVELS[@]}" -eq 0 ]; then
  CONCURRENCY_LEVELS=(5 10 20)
fi

if [ -n "$BODY_FILE" ] && [ ! -f "$BODY_FILE" ]; then
  die "body file not found: $BODY_FILE"
fi

if [ -z "$OUTPUT_DIR" ]; then
  OUTPUT_DIR="$(mktemp -d)"
else
  mkdir -p "$OUTPUT_DIR"
fi

exit_code=0

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

run_one_request() {
  local level="$1"
  local batch="$2"
  local request_id="$3"
  local run_dir="$4"
  local meta_file="$run_dir/request-${request_id}.meta"
  local body_out="$run_dir/request-${request_id}.body"
  local curl_args=()
  local idem_value=""

  curl_args=(-sS -o "$body_out" -w '%{http_code}\t%{time_total}\n' -X "$METHOD")

  for header in "${HEADERS[@]}"; do
    curl_args+=(-H "$header")
  done

  if [ -n "$BODY_FILE" ]; then
    curl_args+=(--data-binary "@$BODY_FILE")
  fi

  if [ -n "$IDEMPOTENCY_HEADER" ]; then
    idem_value="probe-${level}-${batch}"
    if [ "$IDEMPOTENCY_MODE" = "unique" ]; then
      idem_value="${idem_value}-${request_id}"
    fi
    curl_args+=(-H "$IDEMPOTENCY_HEADER: $idem_value")
  fi

  curl "${curl_args[@]}" "$URL" >"$meta_file"
}

printf 'Backend Concurrency Probe\n'
printf 'URL: %s\n' "$URL"
printf 'Method: %s\n' "$METHOD"
printf 'Concurrency levels: %s\n' "${CONCURRENCY_LEVELS[*]}"
printf 'Batches: %s\n' "$BATCHES"
printf 'Output dir: %s\n' "$OUTPUT_DIR"
printf '\n'

for level in "${CONCURRENCY_LEVELS[@]}"; do
  for batch in $(seq 1 "$BATCHES"); do
    run_dir="$OUTPUT_DIR/concurrency-${level}/batch-${batch}"
    mkdir -p "$run_dir"

    printf 'Running concurrency=%s batch=%s\n' "$level" "$batch"
    pids=()
    for request_id in $(seq 1 "$level"); do
      run_one_request "$level" "$batch" "$request_id" "$run_dir" &
      pids+=("$!")
    done

    request_failed=false
    for pid in "${pids[@]}"; do
      if ! wait "$pid"; then
        request_failed=true
      fi
    done

    if [ "$request_failed" = true ]; then
      printf '  - transport failure detected in one or more concurrent requests\n'
      exit_code=2
    fi

    awk -F '\t' '{print $1}' "$run_dir"/*.meta | sort | uniq -c | sed 's/^/  - status /'
    awk -F '\t' '{print $2}' "$run_dir"/*.meta >"$run_dir/times.txt"
    printf '  - p50 time_total: %s\n' "$(percentile_from_file "$run_dir/times.txt" 50)"
    printf '  - p95 time_total: %s\n' "$(percentile_from_file "$run_dir/times.txt" 95)"
    printf '  - p99 time_total: %s\n' "$(percentile_from_file "$run_dir/times.txt" 99)"

    if [ -n "$EXPECT_STATUS" ]; then
      mismatches="$(awk -F '\t' -v expected="$EXPECT_STATUS" '$1 != expected {print $0}' "$run_dir"/*.meta | wc -l | tr -d ' ')"
      if [ "$mismatches" -gt 0 ]; then
        printf '  - expected status %s but found %s mismatches\n' "$EXPECT_STATUS" "$mismatches"
        exit_code=2
      fi
    fi

    printf '\n'
  done
done

printf 'Final outcome: %s\n' "$([ "$exit_code" -eq 0 ] && printf clean || printf review-needed)"
exit "$exit_code"
