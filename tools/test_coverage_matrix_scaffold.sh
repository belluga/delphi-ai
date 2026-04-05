#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: test_coverage_matrix_scaffold.sh --intent <compatibility|unit-regression|critical-user-journey> --strategy <test-first|test-after|not-applicable> --platform-matrix <value> --behavior <text> [--behavior <text> ...] [--decision <ID:description> ...] [--output <path>]

Generate a markdown scaffold for the Test Creation Standard skill.
This captures the repeatable planning structure only; test design and approval remain human.
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

INTENT=""
STRATEGY=""
PLATFORM_MATRIX=""
OUTPUT_PATH=""
declare -a BEHAVIORS=()
declare -a DECISIONS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --intent)
      [ $# -ge 2 ] || die "missing value for --intent"
      INTENT="$2"
      shift 2
      ;;
    --strategy)
      [ $# -ge 2 ] || die "missing value for --strategy"
      STRATEGY="$2"
      shift 2
      ;;
    --platform-matrix)
      [ $# -ge 2 ] || die "missing value for --platform-matrix"
      PLATFORM_MATRIX="$2"
      shift 2
      ;;
    --behavior)
      [ $# -ge 2 ] || die "missing value for --behavior"
      BEHAVIORS+=("$2")
      shift 2
      ;;
    --decision)
      [ $# -ge 2 ] || die "missing value for --decision"
      DECISIONS+=("$2")
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

case "$INTENT" in
  compatibility|unit-regression|critical-user-journey) ;;
  *) die "--intent must be one of compatibility|unit-regression|critical-user-journey" ;;
esac

case "$STRATEGY" in
  test-first|test-after|not-applicable) ;;
  *) die "--strategy must be one of test-first|test-after|not-applicable" ;;
esac

[ -n "$PLATFORM_MATRIX" ] || die "--platform-matrix is required"
[ "${#BEHAVIORS[@]}" -gt 0 ] || die "at least one --behavior is required"

render() {
  local now_utc
  now_utc="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"

  cat <<EOF
# Test Coverage Matrix Scaffold

- Intent: $INTENT
- Test Strategy: $STRATEGY
- Platform Matrix: $PLATFORM_MATRIX
- Created At: $now_utc

## Frozen Decisions
| Decision ID | Description | Status (\`Adherent|Exception\`) | Evidence |
| --- | --- | --- | --- |
EOF

  if [ "${#DECISIONS[@]}" -eq 0 ]; then
    cat <<'EOF'
| D-T01 | TODO | TODO | TODO |
EOF
  else
    local decision id description
    for decision in "${DECISIONS[@]}"; do
      id="${decision%%:*}"
      description="${decision#*:}"
      if [ "$id" = "$description" ]; then
        description="TODO"
      fi
      printf '| %s | %s | TODO | TODO |\n' "$id" "$description"
    done
  fi

  cat <<'EOF'

## Fail-First Targets
- Why test-first is applicable or not:
- Exact failing assertion(s) to go red before implementation:

## Critical Path Coverage
EOF

  local behavior
  for behavior in "${BEHAVIORS[@]}"; do
    cat <<EOF

### $behavior
| Layer | Planned Coverage | Test Surface | Evidence / Notes |
| --- | --- | --- | --- |
| Backend contract / feature | TODO | TODO | TODO |
| Repository / controller state | TODO | TODO | TODO |
| Screen integration | TODO | TODO | TODO |
| Navigation / entry shell | TODO | TODO | TODO |
| Legacy fixture / compatibility case | TODO | TODO | TODO |
EOF
  done

  cat <<'EOF'

## CI / Harness Prerequisites
- Backend reachability:
- Local Mongo / replica set:
- Web bundle build gate:
- Mobile device / emulator availability:
- Required secrets / env vars:
- Artifact directory ownership / writability:

## Stage Status Map
| Stage | Status (\`passed|blocked|failed\`) | Evidence |
| --- | --- | --- |
| Laravel contract / feature tests | TODO | TODO |
| Flutter unit + widget tests | TODO | TODO |
| Flutter integration on web | TODO | TODO |
| Flutter integration on mobile | TODO | TODO |
| Web bundle build | TODO | TODO |
| Web navigation smoke | TODO | TODO |
| Metadata pin check | TODO | TODO |

## Deliberate Exclusions
- TODO

## Residual Risk
- TODO
EOF
}

if [ -n "$OUTPUT_PATH" ]; then
  mkdir -p "$(dirname "$OUTPUT_PATH")"
  render >"$OUTPUT_PATH"
  printf 'Wrote test coverage matrix scaffold to %s\n' "$OUTPUT_PATH"
else
  render
fi
