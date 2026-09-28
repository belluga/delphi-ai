#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: runtime_load_validation_scaffold.sh --system <text> [--mode <load|stress|spike|soak>] [--entrypoint <text>] [--slo <text>] [--output <path>]

Generate a markdown scaffold for runtime load/stress validation evidence.
This is a deterministic structure helper only.
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

SYSTEM_NAME=""
OUTPUT_PATH=""
declare -a MODES=()
declare -a ENTRYPOINTS=()
declare -a SLOS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --system)
      [ $# -ge 2 ] || die "missing value for --system"
      SYSTEM_NAME="$2"
      shift 2
      ;;
    --mode)
      [ $# -ge 2 ] || die "missing value for --mode"
      case "$2" in
        load|stress|spike|soak) ;;
        *) die "invalid --mode value: $2" ;;
      esac
      MODES+=("$2")
      shift 2
      ;;
    --entrypoint)
      [ $# -ge 2 ] || die "missing value for --entrypoint"
      ENTRYPOINTS+=("$2")
      shift 2
      ;;
    --slo)
      [ $# -ge 2 ] || die "missing value for --slo"
      SLOS+=("$2")
      shift 2
      ;;
    --output)
      [ $# -ge 2 ] || die "missing value for --output"
      OUTPUT_PATH="$2"
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

[ -n "$SYSTEM_NAME" ] || die "--system is required"
if [ "${#MODES[@]}" -eq 0 ]; then
  MODES=(load)
fi

render() {
  local now_utc
  now_utc="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"

  cat <<EOF
# Runtime Load / Stress Validation

- System: $SYSTEM_NAME
- Created At: $now_utc

## Modes
EOF

  local mode
  for mode in "${MODES[@]}"; do
    printf -- '- %s\n' "$mode"
  done

  cat <<'EOF'

## Entrypoints
EOF

  if [ "${#ENTRYPOINTS[@]}" -eq 0 ]; then
    printf -- '- TODO\n'
  else
    local entrypoint
    for entrypoint in "${ENTRYPOINTS[@]}"; do
      printf -- '- %s\n' "$entrypoint"
    done
  fi

  cat <<'EOF'

## Acceptance Targets / SLOs
EOF

  if [ "${#SLOS[@]}" -eq 0 ]; then
    printf -- '- TODO\n'
  else
    local slo
    for slo in "${SLOS[@]}"; do
      printf -- '- %s\n' "$slo"
    done
  fi

  cat <<'EOF'

## Workload Model
- Environment:
- Request mix:
- Concurrency:
- Duration:
- Warm-up / ramp:

## Metrics Summary
| Mode | p50 | p95 | p99 | Throughput | Error Rate | Saturation / Notes |
| --- | --- | --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO | TODO | TODO |

## Residual Risk
- TODO
EOF
}

if [ -n "$OUTPUT_PATH" ]; then
  mkdir -p "$(dirname "$OUTPUT_PATH")"
  render >"$OUTPUT_PATH"
  printf 'Wrote runtime load validation scaffold to %s\n' "$OUTPUT_PATH"
else
  render
fi
