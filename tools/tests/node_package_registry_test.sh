#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

PROJECT="$TMP_DIR/project"
mkdir -p "$PROJECT/foundation_documentation" "$PROJECT/packages/shared" \
  "$PROJECT/node_modules/ignored/packages/hidden"
ln -s "$ROOT_DIR" "$PROJECT/delphi-ai"

cat > "$PROJECT/package.json" <<'EOF'
{
  "name": "fixture-app",
  "dependencies": {
    "@acme/shared": "workspace:*"
  }
}
EOF

cat > "$PROJECT/packages/shared/package.json" <<'EOF'
{
  "name": "@acme/shared",
  "version": "1.0.0"
}
EOF

cat > "$PROJECT/packages/shared/README.md" <<'EOF'
# Shared

Reusable validation and boundary helpers.
EOF

cat > "$PROJECT/node_modules/ignored/packages/hidden/package.json" <<'EOF'
{"name":"@bad/hidden"}
EOF

bash "$ROOT_DIR/tools/verify_package_registry.sh" --project-root "$PROJECT" \
  > "$TMP_DIR/verify.out"

LOCAL="$PROJECT/foundation_documentation/local_packages.yaml"
grep -q '^node:$' "$LOCAL"
grep -q "name: '@acme/shared'" "$LOCAL"
grep -q "path: 'packages/shared'" "$LOCAL"
grep -q 'in_use: true' "$LOCAL"
if grep -q '@bad/hidden' "$LOCAL"; then
  printf 'ignored dependency tree leaked into local package registry\n' >&2
  exit 1
fi

bash "$ROOT_DIR/tools/query_packages.sh" --project-root "$PROJECT" \
  --stack node --search shared > "$TMP_DIR/query.out"
grep -q 'STACK:       node' "$TMP_DIR/query.out"
grep -q 'NAME:        @acme/shared' "$TMP_DIR/query.out"
grep -q 'STATUS:      in_use' "$TMP_DIR/query.out"

bash "$ROOT_DIR/tools/query_packages.sh" --project-root "$PROJECT" \
  --detail '@acme/shared' > "$TMP_DIR/detail.out"
grep -q '=== README CONTENT ===' "$TMP_DIR/detail.out"
grep -q 'Reusable validation and boundary helpers.' "$TMP_DIR/detail.out"

# Generic registry parsing must preserve the existing stack sections.
bash "$ROOT_DIR/tools/query_packages.sh" --project-root "$PROJECT" \
  --stack flutter --search stream_value > "$TMP_DIR/flutter.out"
grep -q 'STACK:       flutter' "$TMP_DIR/flutter.out"
grep -q 'NAME:        stream_value' "$TMP_DIR/flutter.out"

bash "$ROOT_DIR/tools/query_packages.sh" --project-root "$PROJECT" \
  --stack laravel --all > "$TMP_DIR/laravel.out"
grep -q '=== 0 package(s) found ===' "$TMP_DIR/laravel.out"

if bash "$ROOT_DIR/tools/query_packages.sh" --project-root "$PROJECT" \
  --stack '../node' --all > "$TMP_DIR/invalid.out" 2>&1; then
  printf 'unsafe stack filter unexpectedly succeeded\n' >&2
  exit 1
fi
grep -q 'Invalid --stack' "$TMP_DIR/invalid.out"

printf 'node_package_registry_test: OK\n'
