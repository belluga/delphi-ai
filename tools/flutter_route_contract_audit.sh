#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: flutter_route_contract_audit.sh [--repo <path>] [--generated-router <path>]

Audit the generated Flutter router for required non-URL arguments using the
canonical Delphi route-contract heuristics.

Options:
  --repo <path>             Repository root. Defaults to current directory.
  --generated-router <path> Generated router file. Defaults to
                            flutter-app/lib/application/router/app_router.gr.dart
  -h, --help                Show this help text.

Exit codes:
  0  No required non-URL contract hits were found.
  2  One or more required non-URL contract hits were found and need classification.
  1  Operational error (missing file, missing rg, invalid repo/path, etc.).
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

command -v rg >/dev/null 2>&1 || die "ripgrep (rg) is required"

REPO_INPUT="."
ROUTER_INPUT="flutter-app/lib/application/router/app_router.gr.dart"

while [ $# -gt 0 ]; do
  case "$1" in
    --repo)
      [ $# -ge 2 ] || die "missing value for --repo"
      REPO_INPUT="$2"
      shift 2
      ;;
    --generated-router)
      [ $# -ge 2 ] || die "missing value for --generated-router"
      ROUTER_INPUT="$2"
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

REPO_ROOT="$(git -C "$REPO_INPUT" rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$REPO_ROOT" ]; then
  REPO_ROOT="$(cd "$REPO_INPUT" 2>/dev/null && pwd || true)"
fi
[ -n "$REPO_ROOT" ] || die "unable to resolve repository root from: $REPO_INPUT"

if [[ "$ROUTER_INPUT" = /* ]]; then
  ROUTER_PATH="$ROUTER_INPUT"
else
  ROUTER_PATH="$REPO_ROOT/$ROUTER_INPUT"
fi
[ -f "$ROUTER_PATH" ] || die "generated router file not found: $ROUTER_PATH"

PATTERN='required _i|required .*State|required String .*Name'
hits="$(rg -n "$PATTERN" "$ROUTER_PATH" || true)"

printf 'Flutter Route Contract Audit\n'
printf 'Repository: %s\n' "$REPO_ROOT"
printf 'Generated router: %s\n' "$ROUTER_PATH"
printf '\n'

printf 'Required non-URL contract hits:\n'
if [ -z "$hits" ]; then
  printf '  - none\n'
  exit 0
fi

while IFS= read -r line; do
  [ -n "$line" ] || continue
  printf '  - %s\n' "$line"
done <<< "$hits"
printf '\n'
printf 'Action: classify each hit as URL-Hydratable or Internal-Only before delivery.\n'
exit 2

