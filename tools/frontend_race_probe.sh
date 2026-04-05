#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: frontend_race_probe.sh --scenario <id> --runner <command>
       [--burst-level <n>] [--burst-level <n> ...]
       [--repetitions <n>] [--timeout-sec <n>]
       [--settle-sec <seconds>] [--workdir <path>]
       [--env KEY=VALUE] [--env KEY=VALUE ...]
       [--output-dir <dir>] [--fail-fast]

Run a real frontend race scenario command repeatedly with deterministic burst levels.

The underlying runner should consume the exported DELPHI_RACE_* environment variables:
- DELPHI_RACE_SCENARIO
- DELPHI_RACE_BURST_LEVEL
- DELPHI_RACE_REPEAT_INDEX
- DELPHI_RACE_ATTEMPT_DIR
- DELPHI_RACE_OUTPUT_DIR
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

is_non_negative_decimal() {
  [[ "$1" =~ ^([0-9]+([.][0-9]+)?|[.][0-9]+)$ ]]
}

SCENARIO=""
RUNNER=""
OUTPUT_DIR=""
WORKDIR=""
REPETITIONS=1
TIMEOUT_SEC=120
SETTLE_SEC="0"
FAIL_FAST=false
declare -a BURST_LEVELS=()
declare -a EXTRA_ENVS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --scenario)
      [ $# -ge 2 ] || die "missing value for --scenario"
      SCENARIO="$2"
      shift 2
      ;;
    --runner)
      [ $# -ge 2 ] || die "missing value for --runner"
      RUNNER="$2"
      shift 2
      ;;
    --burst-level)
      [ $# -ge 2 ] || die "missing value for --burst-level"
      BURST_LEVELS+=("$2")
      shift 2
      ;;
    --repetitions)
      [ $# -ge 2 ] || die "missing value for --repetitions"
      REPETITIONS="$2"
      shift 2
      ;;
    --timeout-sec)
      [ $# -ge 2 ] || die "missing value for --timeout-sec"
      TIMEOUT_SEC="$2"
      shift 2
      ;;
    --settle-sec)
      [ $# -ge 2 ] || die "missing value for --settle-sec"
      SETTLE_SEC="$2"
      shift 2
      ;;
    --workdir)
      [ $# -ge 2 ] || die "missing value for --workdir"
      WORKDIR="$2"
      shift 2
      ;;
    --env)
      [ $# -ge 2 ] || die "missing value for --env"
      EXTRA_ENVS+=("$2")
      shift 2
      ;;
    --output-dir)
      [ $# -ge 2 ] || die "missing value for --output-dir"
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --fail-fast)
      FAIL_FAST=true
      shift
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

[ -n "$SCENARIO" ] || die "--scenario is required"
[ -n "$RUNNER" ] || die "--runner is required"
[[ "$REPETITIONS" =~ ^[1-9][0-9]*$ ]] || die "--repetitions must be a positive integer"
[[ "$TIMEOUT_SEC" =~ ^[1-9][0-9]*$ ]] || die "--timeout-sec must be a positive integer"
is_non_negative_decimal "$SETTLE_SEC" || die "--settle-sec must be zero or greater"

if [ "${#BURST_LEVELS[@]}" -eq 0 ]; then
  BURST_LEVELS=(5 10 20)
fi

for level in "${BURST_LEVELS[@]}"; do
  [[ "$level" =~ ^[1-9][0-9]*$ ]] || die "invalid --burst-level value: $level"
done

for assignment in "${EXTRA_ENVS[@]}"; do
  [[ "$assignment" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]] || die "invalid --env assignment: $assignment"
done

if [ -n "$WORKDIR" ] && [ ! -d "$WORKDIR" ]; then
  die "workdir not found: $WORKDIR"
fi

if [ -z "$OUTPUT_DIR" ]; then
  OUTPUT_DIR="$(mktemp -d)"
else
  mkdir -p "$OUTPUT_DIR"
fi

SUMMARY_TSV="$OUTPUT_DIR/summary.tsv"
REPORT_MD="$OUTPUT_DIR/report.md"
printf 'burst_level\trepetition\tstatus\texit_code\tduration_ms\tattempt_dir\n' >"$SUMMARY_TSV"

TIMEOUT_BIN=""
if command -v timeout >/dev/null 2>&1; then
  TIMEOUT_BIN="$(command -v timeout)"
fi

run_attempt() {
  local burst_level="$1"
  local repetition="$2"
  local attempt_dir="$OUTPUT_DIR/burst-${burst_level}/repeat-${repetition}"
  local stdout_file="$attempt_dir/stdout.log"
  local stderr_file="$attempt_dir/stderr.log"
  local env_file="$attempt_dir/env.list"
  local start_ms end_ms duration_ms exit_code status

  mkdir -p "$attempt_dir"

  {
    printf 'DELPHI_RACE_SCENARIO=%s\n' "$SCENARIO"
    printf 'DELPHI_RACE_BURST_LEVEL=%s\n' "$burst_level"
    printf 'DELPHI_RACE_REPEAT_INDEX=%s\n' "$repetition"
    printf 'DELPHI_RACE_ATTEMPT_DIR=%s\n' "$attempt_dir"
    printf 'DELPHI_RACE_OUTPUT_DIR=%s\n' "$OUTPUT_DIR"
    for assignment in "${EXTRA_ENVS[@]}"; do
      printf '%s\n' "$assignment"
    done
  } >"$env_file"

  start_ms="$(now_ms)"
  set +e
  (
    if [ -n "$WORKDIR" ]; then
      cd "$WORKDIR"
    fi

    export DELPHI_RACE_SCENARIO="$SCENARIO"
    export DELPHI_RACE_BURST_LEVEL="$burst_level"
    export DELPHI_RACE_REPEAT_INDEX="$repetition"
    export DELPHI_RACE_ATTEMPT_DIR="$attempt_dir"
    export DELPHI_RACE_OUTPUT_DIR="$OUTPUT_DIR"
    for assignment in "${EXTRA_ENVS[@]}"; do
      export "$assignment"
    done

    if [ -n "$TIMEOUT_BIN" ]; then
      "$TIMEOUT_BIN" --foreground "${TIMEOUT_SEC}s" bash -lc "$RUNNER"
    else
      bash -lc "$RUNNER"
    fi
  ) >"$stdout_file" 2>"$stderr_file"
  exit_code="$?"
  set -e
  end_ms="$(now_ms)"
  duration_ms="$((end_ms - start_ms))"

  if [ "$exit_code" -eq 0 ]; then
    status="passed"
  elif [ "$exit_code" -eq 124 ] || [ "$exit_code" -eq 137 ]; then
    status="timed_out"
  else
    status="failed"
  fi

  printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$burst_level" "$repetition" "$status" "$exit_code" "$duration_ms" "$attempt_dir" >>"$SUMMARY_TSV"

  if [ "$status" = "passed" ]; then
    return 0
  fi

  return 1
}

write_report() {
  {
    printf '# Frontend Race Probe\n\n'
    printf -- '- Scenario: `%s`\n' "$SCENARIO"
    printf -- '- Runner: `%s`\n' "$RUNNER"
    if [ -n "$WORKDIR" ]; then
      printf -- '- Working directory: `%s`\n' "$WORKDIR"
    fi
    printf -- '- Burst levels: `%s`\n' "${BURST_LEVELS[*]}"
    printf -- '- Repetitions per burst: `%s`\n' "$REPETITIONS"
    printf -- '- Timeout (seconds): `%s`\n' "$TIMEOUT_SEC"
    printf -- '- Output directory: `%s`\n' "$OUTPUT_DIR"
    printf '\n## Burst Summary\n'
    printf '| Burst Level | Passed | Failed | Timed Out |\n'
    printf '| --- | --- | --- | --- |\n'

    local level passed failed timed_out
    for level in "${BURST_LEVELS[@]}"; do
      passed="$(awk -F '\t' -v burst="$level" 'NR > 1 && $1 == burst && $3 == "passed" { count++ } END { print count + 0 }' "$SUMMARY_TSV")"
      failed="$(awk -F '\t' -v burst="$level" 'NR > 1 && $1 == burst && $3 == "failed" { count++ } END { print count + 0 }' "$SUMMARY_TSV")"
      timed_out="$(awk -F '\t' -v burst="$level" 'NR > 1 && $1 == burst && $3 == "timed_out" { count++ } END { print count + 0 }' "$SUMMARY_TSV")"
      printf '| %s | %s | %s | %s |\n' "$level" "$passed" "$failed" "$timed_out"
    done

    printf '\n## Attempt Details\n'
    printf '| Burst Level | Repetition | Status | Exit Code | Duration (ms) | Attempt Dir |\n'
    printf '| --- | --- | --- | --- | --- | --- |\n'
    awk -F '\t' 'NR > 1 { printf("| %s | %s | %s | %s | %s | `%s` |\n", $1, $2, $3, $4, $5, $6) }' "$SUMMARY_TSV"
  } >"$REPORT_MD"
}

printf 'Frontend Race Probe\n'
printf 'Scenario: %s\n' "$SCENARIO"
printf 'Burst levels: %s\n' "${BURST_LEVELS[*]}"
printf 'Repetitions per burst: %s\n' "$REPETITIONS"
printf 'Output dir: %s\n' "$OUTPUT_DIR"
printf '\n'

overall_exit=0
stop_now=false
for burst_level in "${BURST_LEVELS[@]}"; do
  for repetition in $(seq 1 "$REPETITIONS"); do
    printf 'Running burst=%s repetition=%s\n' "$burst_level" "$repetition"
    if ! run_attempt "$burst_level" "$repetition"; then
      overall_exit=2
      if [ "$FAIL_FAST" = true ]; then
        stop_now=true
        break
      fi
    fi

    if [ "$SETTLE_SEC" != "0" ]; then
      sleep "$SETTLE_SEC"
    fi
  done

  if [ "$stop_now" = true ]; then
    break
  fi
done

write_report

printf '\nReport: %s\n' "$REPORT_MD"
printf 'Summary TSV: %s\n' "$SUMMARY_TSV"
printf 'Final outcome: %s\n' "$([ "$overall_exit" -eq 0 ] && printf clean || printf review-needed)"
exit "$overall_exit"
