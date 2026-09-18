#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOL="$ROOT_DIR/tools/runtime_ingress_surface_audit.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

NON_LARAVEL="$TMP_DIR/non-laravel"
mkdir -p "$NON_LARAVEL/nginx"
git -C "$NON_LARAVEL" init -q
cat > "$NON_LARAVEL/nginx/app.conf" <<'EOF'
location /storage {
    alias /srv/static;
}
EOF

# A storage-like route is not a Laravel invariant unless Laravel is present.
bash "$TOOL" --repo "$NON_LARAVEL" > "$TMP_DIR/non-laravel.out"
grep -q 'Overall outcome: ready' "$TMP_DIR/non-laravel.out"
if grep -q 'Laravel storage' "$TMP_DIR/non-laravel.out"; then
  printf 'unexpected Laravel storage finding for non-Laravel repository\n' >&2
  exit 1
fi

# The legacy invariant remains enforced for a detected Laravel surface.
mkdir -p "$NON_LARAVEL/laravel-app/routes"
if bash "$TOOL" --repo "$NON_LARAVEL" > "$TMP_DIR/laravel.out"; then
  printf 'expected Laravel storage invariant to block\n' >&2
  exit 1
fi
grep -q 'references Laravel storage without the try_files alias invariant' \
  "$TMP_DIR/laravel.out"
grep -q 'Overall outcome: blocked' "$TMP_DIR/laravel.out"

# No local surface remains blocked unless platform ownership is explicit.
PLATFORM_ONLY="$TMP_DIR/platform-only"
mkdir -p "$PLATFORM_ONLY"
git -C "$PLATFORM_ONLY" init -q
if bash "$TOOL" --repo "$PLATFORM_ONLY" > "$TMP_DIR/no-surface.out"; then
  printf 'expected missing runtime surfaces to block without explicit ownership\n' >&2
  exit 1
fi
grep -q 'Overall outcome: blocked' "$TMP_DIR/no-surface.out"

# Platform-owned runtimes may legitimately have no local Docker/ingress files,
# but callers must assert that fact from the project contract.
bash "$TOOL" --repo "$PLATFORM_ONLY" --platform-owned > "$TMP_DIR/platform.out"
grep -q 'no local Dockerfile, compose, or ingress surfaces were found' \
  "$TMP_DIR/platform.out"
grep -q 'Overall outcome: ready' "$TMP_DIR/platform.out"

printf 'runtime_ingress_surface_audit_test: OK\n'
