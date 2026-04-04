#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: frontend_race_validation_scaffold.sh --surface <text> [--surface <text> ...] [--output <path>]

Generate a markdown scenario matrix for frontend race-condition validation.
This is a deterministic structure helper only.
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

OUTPUT_PATH=""
declare -a SURFACES=()

while [ $# -gt 0 ]; do
  case "$1" in
    --surface)
      [ $# -ge 2 ] || die "missing value for --surface"
      SURFACES+=("$2")
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

[ "${#SURFACES[@]}" -gt 0 ] || die "at least one --surface is required"

render() {
  local now_utc
  now_utc="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"

  cat <<EOF
# Frontend Race Validation

- Created At: $now_utc

## Surfaces In Scope
EOF

  local surface
  for surface in "${SURFACES[@]}"; do
    printf -- '- %s\n' "$surface"
  done

  cat <<'EOF'

## Scenario Matrix
| Surface | Trigger | Failure Mode | Expected Guard / Policy | Evidence |
| --- | --- | --- | --- | --- |
EOF

  for surface in "${SURFACES[@]}"; do
    printf '| %s | double tap / rapid repeat | duplicate side effect or duplicate navigation | TODO | TODO |\n' "$surface"
    printf '| %s | retry while request in flight | duplicate mutation or state corruption | TODO | TODO |\n' "$surface"
    printf '| %s | older response arrives last | stale response overwrites newer state | TODO | TODO |\n' "$surface"
    printf '| %s | dispose / navigate away mid-flight | post-dispose state write or duplicate UI effect | TODO | TODO |\n' "$surface"
    printf '| %s | rapid filter/search/pagination changes | out-of-order list state or duplicated requests | TODO | TODO |\n' "$surface"
  done

  cat <<'EOF'

## Concurrency Policy Notes
- `drop duplicate`:
- `serialize`:
- `cancel previous`:
- `last-write-wins`:
- `idempotent server-side`:

## Residual Risk
- TODO
EOF
}

if [ -n "$OUTPUT_PATH" ]; then
  mkdir -p "$(dirname "$OUTPUT_PATH")"
  render >"$OUTPUT_PATH"
  printf 'Wrote frontend race validation scaffold to %s\n' "$OUTPUT_PATH"
else
  render
fi
