#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: test_orchestration_status_report.sh --scope <small|medium|big> --require-stage <name> [--require-stage <name> ...] [--stage <name>=<passed|failed|blocked|flaky|skipped|not-applicable>] [--decision <ID>=<adherent|exception>] [--intent <text>] [--platform-matrix <text>] [--output <path>]

Generate a deterministic stage-status report for the Test Orchestration Suite skill.
The script does not choose suites or classify root cause; it only enforces the explicit stage/dependency matrix provided to it.
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

SCOPE=""
INTENT=""
PLATFORM_MATRIX=""
OUTPUT_PATH=""
declare -a REQUIRED_STAGES=()
declare -a DECISION_ORDER=()
declare -A STAGE_STATUS=()
declare -A DECISION_STATUS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --scope)
      [ $# -ge 2 ] || die "missing value for --scope"
      SCOPE="$2"
      shift 2
      ;;
    --intent)
      [ $# -ge 2 ] || die "missing value for --intent"
      INTENT="$2"
      shift 2
      ;;
    --platform-matrix)
      [ $# -ge 2 ] || die "missing value for --platform-matrix"
      PLATFORM_MATRIX="$2"
      shift 2
      ;;
    --require-stage)
      [ $# -ge 2 ] || die "missing value for --require-stage"
      REQUIRED_STAGES+=("$2")
      shift 2
      ;;
    --stage)
      [ $# -ge 2 ] || die "missing value for --stage"
      raw_stage="$2"
      stage_name="${raw_stage%%=*}"
      stage_value="${raw_stage#*=}"
      [ -n "$stage_name" ] || die "invalid --stage format: $raw_stage"
      [ "$stage_name" != "$stage_value" ] || die "invalid --stage format: $raw_stage"
      case "$stage_value" in
        passed|failed|blocked|flaky|skipped|not-applicable) ;;
        *) die "invalid stage status: $stage_value" ;;
      esac
      STAGE_STATUS["$stage_name"]="$stage_value"
      shift 2
      ;;
    --decision)
      [ $# -ge 2 ] || die "missing value for --decision"
      raw_decision="$2"
      decision_id="${raw_decision%%=*}"
      decision_value="${raw_decision#*=}"
      [ -n "$decision_id" ] || die "invalid --decision format: $raw_decision"
      [ "$decision_id" != "$decision_value" ] || die "invalid --decision format: $raw_decision"
      case "$decision_value" in
        adherent|exception) ;;
        *) die "invalid decision status: $decision_value" ;;
      esac
      DECISION_STATUS["$decision_id"]="$decision_value"
      DECISION_ORDER+=("$decision_id")
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

case "$SCOPE" in
  small|medium|big) ;;
  *) die "--scope must be one of small|medium|big" ;;
esac

[ "${#REQUIRED_STAGES[@]}" -gt 0 ] || die "at least one --require-stage is required"

overall_status="promotion-ready"
declare -a OVERALL_NOTES=()

evaluate_stage() {
  local status="$1"

  case "$status" in
    passed)
      return 0
      ;;
    blocked|"")
      overall_status="blocked"
      return 1
      ;;
    failed|flaky|skipped|not-applicable)
      if [ "$overall_status" != "blocked" ]; then
        overall_status="failed"
      fi
      return 1
      ;;
  esac
}

render() {
  local now_utc
  now_utc="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"

  cat <<EOF
# Test Orchestration Status Report

- Scope: $SCOPE
- Intent: ${INTENT:-not-recorded}
- Platform Matrix: ${PLATFORM_MATRIX:-not-recorded}
- Created At: $now_utc

## Required Stage Status
| Stage | Required | Status | Result |
| --- | --- | --- | --- |
EOF

  local stage status result
  for stage in "${REQUIRED_STAGES[@]}"; do
    status="${STAGE_STATUS[$stage]:-missing}"
    result="OK"
    if ! evaluate_stage "${STAGE_STATUS[$stage]:-}"; then
      case "${STAGE_STATUS[$stage]:-}" in
        "")
          result="Missing explicit status"
          OVERALL_NOTES+=("$stage is required but has no recorded status")
          ;;
        blocked)
          result="Blocked gate"
          OVERALL_NOTES+=("$stage is blocked and therefore cannot count as passed")
          ;;
        failed)
          result="Failed gate"
          OVERALL_NOTES+=("$stage failed")
          ;;
        flaky)
          result="Flaky gate"
          OVERALL_NOTES+=("$stage is flaky and cannot count as green")
          ;;
        skipped|not-applicable)
          result="Invalid for required gate"
          OVERALL_NOTES+=("$stage is required and cannot be $status")
          ;;
      esac
    fi
    printf '| %s | yes | %s | %s |\n' "$stage" "$status" "$result"
  done

  cat <<'EOF'

## Recorded Decisions
| Decision ID | Status | Result |
| --- | --- | --- |
EOF

  if [ "${#DECISION_ORDER[@]}" -eq 0 ]; then
    printf '| (none) | not-recorded | no decision-adherence entries were supplied |\n'
  else
    local decision_id decision_result
    for decision_id in "${DECISION_ORDER[@]}"; do
      decision_result="Adherent"
      if [ "${DECISION_STATUS[$decision_id]}" = "exception" ]; then
        decision_result="Blocks closure until approved"
        if [ "$overall_status" = "promotion-ready" ]; then
          overall_status="failed"
        fi
        OVERALL_NOTES+=("$decision_id remains an unresolved decision exception")
      fi
      printf '| %s | %s | %s |\n' "$decision_id" "${DECISION_STATUS[$decision_id]}" "$decision_result"
    done
  fi

  cat <<'EOF'

## Fix Loop / Follow-up Notes
EOF

  if [ "${#OVERALL_NOTES[@]}" -eq 0 ]; then
    printf -- '- none\n'
  else
    local note
    for note in "${OVERALL_NOTES[@]}"; do
      printf -- '- %s\n' "$note"
    done
  fi

  printf '\nOverall outcome: %s\n' "$overall_status"
  if [ "$overall_status" = "promotion-ready" ]; then
    printf 'Closure: all required stages are explicitly passed and no unresolved decision exception remains.\n'
  else
    printf 'Closure: not ready to claim successful orchestration yet.\n'
  fi
}

if [ -n "$OUTPUT_PATH" ]; then
  mkdir -p "$(dirname "$OUTPUT_PATH")"
  render >"$OUTPUT_PATH"
  printf 'Wrote test orchestration status report to %s\n' "$OUTPUT_PATH"
else
  render
fi

if [ "$overall_status" = "promotion-ready" ]; then
  exit 0
fi

exit 2
