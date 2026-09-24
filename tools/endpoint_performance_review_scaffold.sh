#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: endpoint_performance_review_scaffold.sh --endpoint <text> --pattern <exact-lookup|bounded-list|search|aggregation|mutation> [--lookup-key <text>] [--index <text>] [--output <path>]

Generate a markdown scaffold for endpoint/query performance scrutiny.
This is a deterministic structure helper only.
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

ENDPOINT_NAME=""
PATTERN=""
OUTPUT_PATH=""
declare -a LOOKUP_KEYS=()
declare -a INDEXES=()

while [ $# -gt 0 ]; do
  case "$1" in
    --endpoint)
      [ $# -ge 2 ] || die "missing value for --endpoint"
      ENDPOINT_NAME="$2"
      shift 2
      ;;
    --pattern)
      [ $# -ge 2 ] || die "missing value for --pattern"
      PATTERN="$2"
      shift 2
      ;;
    --lookup-key)
      [ $# -ge 2 ] || die "missing value for --lookup-key"
      LOOKUP_KEYS+=("$2")
      shift 2
      ;;
    --index)
      [ $# -ge 2 ] || die "missing value for --index"
      INDEXES+=("$2")
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

case "$PATTERN" in
  exact-lookup|bounded-list|search|aggregation|mutation) ;;
  *) die "--pattern must be one of exact-lookup|bounded-list|search|aggregation|mutation" ;;
esac

[ -n "$ENDPOINT_NAME" ] || die "--endpoint is required"

render() {
  local now_utc
  now_utc="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"

  cat <<EOF
# Endpoint Performance Review

- Endpoint: $ENDPOINT_NAME
- Access Pattern: $PATTERN
- Created At: $now_utc

## Canonical Lookup Path
- Backend query path:
- Client/repository path:
- Direct exact-lookup contract exists:

## Lookup Keys
EOF

  if [ "${#LOOKUP_KEYS[@]}" -eq 0 ]; then
    printf -- '- TODO\n'
  else
    local key
    for key in "${LOOKUP_KEYS[@]}"; do
      printf -- '- %s\n' "$key"
    done
  fi

  cat <<'EOF'

## Expected Index / Constraint Support
EOF

  if [ "${#INDEXES[@]}" -eq 0 ]; then
    printf -- '- TODO\n'
  else
    local index_name
    for index_name in "${INDEXES[@]}"; do
      printf -- '- %s\n' "$index_name"
    done
  fi

  cat <<'EOF'

## Forbidden Fallback Patterns
- page-walk exact lookup through paginated list endpoint
- broad fetch plus in-memory filter for exact key
- client-side slug/id match after multi-page list traversal

## Evidence
- Heuristic audit output:
- Explain / query-log / benchmark evidence:
- Residual risk:
EOF
}

if [ -n "$OUTPUT_PATH" ]; then
  mkdir -p "$(dirname "$OUTPUT_PATH")"
  render >"$OUTPUT_PATH"
  printf 'Wrote endpoint performance review scaffold to %s\n' "$OUTPUT_PATH"
else
  render
fi
