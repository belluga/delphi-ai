#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: test_coverage_matrix_scaffold.sh --intent <compatibility|unit-regression|critical-user-journey> --strategy <test-first|test-after|not-applicable> --platform-matrix <value> --behavior <text> [--behavior <text> ...] [--layer <name> ...] [--prerequisite <name> ...] [--stage <name> ...] [--decision <ID:description> ...] [--output <path>]

Generate a markdown scaffold for the Test Creation Standard skill.
The default rows are stack-neutral. Repeat --layer, --prerequisite, and --stage
to replace them with exact project-declared evidence surfaces.
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
declare -a LAYERS=()
declare -a PREREQUISITES=()
declare -a STAGES=()

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
    --layer)
      [ $# -ge 2 ] || die "missing value for --layer"
      LAYERS+=("$2")
      shift 2
      ;;
    --prerequisite)
      [ $# -ge 2 ] || die "missing value for --prerequisite"
      PREREQUISITES+=("$2")
      shift 2
      ;;
    --stage)
      [ $# -ge 2 ] || die "missing value for --stage"
      STAGES+=("$2")
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

if [ "${#LAYERS[@]}" -eq 0 ]; then
  LAYERS=(
    "Static / contract"
    "Unit / provider / component"
    "Integration / module / adapter"
    "Application / contract / end-to-end"
    "Browser / device (if active)"
    "Compatibility fixture / migration (if applicable)"
  )
fi

if [ "${#PREREQUISITES[@]}" -eq 0 ]; then
  PREREQUISITES=(
    "Owning manifest and exact project commands"
    "Required local services and boundary reachability"
    "Required variables/secrets by name (never values)"
    "Writable artifact paths and runtime owner"
    "Browser/device availability and runtime freshness (if active)"
  )
fi

if [ "${#STAGES[@]}" -eq 0 ]; then
  STAGES=(
    "Static / contract checks"
    "Unit / provider / component tests"
    "Integration / module / adapter tests"
    "Application / contract / end-to-end tests"
    "Build / publish (if active)"
    "Browser / device validation (if active)"
    "Broad project CI-equivalent closeout"
  )
fi

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

  local behavior layer
  for behavior in "${BEHAVIORS[@]}"; do
    cat <<EOF

### $behavior
| Layer | Planned Coverage | Test Surface | Evidence / Notes |
| --- | --- | --- | --- |
EOF
    for layer in "${LAYERS[@]}"; do
      printf '| %s | TODO | TODO | TODO |\n' "$layer"
    done
  done

  cat <<'EOF'

## CI / Harness Prerequisites
EOF

  local prerequisite
  for prerequisite in "${PREREQUISITES[@]}"; do
    printf -- '- %s: TODO\n' "$prerequisite"
  done

  cat <<'EOF'

## Stage Status Map
| Stage | Status (`passed|blocked|failed|flaky|not-applicable`) | Evidence |
| --- | --- | --- |
EOF

  local stage
  for stage in "${STAGES[@]}"; do
    printf '| %s | TODO | TODO |\n' "$stage"
  done

  cat <<'EOF'

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
