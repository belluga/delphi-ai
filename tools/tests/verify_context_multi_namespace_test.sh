#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOL="$ROOT_DIR/tools/verify_context.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

PROJECT="$TMP_DIR/project"
mkdir -p "$PROJECT/foundation_documentation"
git -C "$PROJECT" init -q
touch "$PROJECT/foundation_documentation/local_packages.yaml"

cat > "$PROJECT/foundation_documentation/project_constitution.md" <<'EOF'
# Project Constitution

- **Namespace:** laravel
- **Namespaces:** docker, flutter, nestjs, react, vite, postgresql, prisma, railway
EOF

(
  cd "$PROJECT"
  bash "$TOOL" --repair
)

test -d "$PROJECT/.agents/rules/stack"
test ! -L "$PROJECT/.agents/rules/stack"
test -L "$PROJECT/.agents/rules/stack/docker"
test -L "$PROJECT/.agents/rules/stack/flutter"
test -L "$PROJECT/.agents/rules/stack/nestjs"
test -L "$PROJECT/.agents/rules/stack/react"
test -L "$PROJECT/.agents/rules/stack/vite"
test -L "$PROJECT/.agents/rules/stack/postgresql"
test -L "$PROJECT/.agents/rules/stack/prisma"
test -L "$PROJECT/.agents/rules/stack/railway"
test "$(readlink "$PROJECT/.agents/rules/stack/nestjs")" = "$ROOT_DIR/rules/stacks/nestjs"
test "$(readlink "$PROJECT/.agents/rules/stack/react")" = "$ROOT_DIR/rules/stacks/react"
test "$(readlink "$PROJECT/.agents/rules/stack/vite")" = "$ROOT_DIR/rules/stacks/vite"
test "$(readlink "$PROJECT/.agents/rules/stack/postgresql")" = "$ROOT_DIR/rules/stacks/postgresql"
test "$(readlink "$PROJECT/.agents/rules/stack/prisma")" = "$ROOT_DIR/rules/stacks/prisma"
test "$(readlink "$PROJECT/.agents/rules/stack/railway")" = "$ROOT_DIR/rules/stacks/railway"
test -f "$PROJECT/.agents/rules/stack/.delphi-managed-stack-links"
test -d "$PROJECT/.agents/deterministic/stack"
test -f "$PROJECT/.agents/deterministic/stack/.delphi-managed-stack-links"

# A marker-owned group must repair links left by a previous Delphi install root.
rm -f "$PROJECT/.agents/rules/stack/docker"
ln -s "/previous/delphi-ai/rules/stacks/docker" "$PROJECT/.agents/rules/stack/docker"
(
  cd "$PROJECT"
  bash "$TOOL" --repair
)
test "$(readlink "$PROJECT/.agents/rules/stack/docker")" = "$ROOT_DIR/rules/stacks/docker"

cat > "$PROJECT/foundation_documentation/project_constitution.md" <<'EOF'
# Project Constitution

- **Namespace:** laravel
EOF

(
  cd "$PROJECT"
  bash "$TOOL" --repair
)

test -L "$PROJECT/.agents/rules/stack"
test "$(readlink "$PROJECT/.agents/rules/stack")" = "$ROOT_DIR/rules/stacks/laravel"
test ! -e "$PROJECT/.agents/deterministic/stack"

# Clearing a legacy single-stack link must also work after Delphi relocates.
rm -f "$PROJECT/.agents/rules/stack"
ln -s "/previous/delphi-ai/rules/stacks/laravel" "$PROJECT/.agents/rules/stack"

cat > "$PROJECT/foundation_documentation/project_constitution.md" <<'EOF'
# Project Constitution
EOF

(
  cd "$PROJECT"
  bash "$TOOL" --repair
)

test ! -e "$PROJECT/.agents/rules/stack"
test ! -e "$PROJECT/.agents/deterministic/stack"

# An untouched constitution template is inert until the project declares
# capabilities; examples must never be parsed as activation data.
cp "$ROOT_DIR/templates/project_constitution_template.md" \
  "$PROJECT/foundation_documentation/project_constitution.md"
(
  cd "$PROJECT"
  bash "$TOOL" --repair
)
test ! -e "$PROJECT/.agents/rules/stack"
test ! -e "$PROJECT/.agents/deterministic/stack"

cat > "$PROJECT/foundation_documentation/project_constitution.md" <<'EOF'
# Project Constitution

- **Namespaces:** docker, ../outside
EOF

if (
  cd "$PROJECT"
  bash "$TOOL" --repair
) > "$TMP_DIR/invalid.out" 2>&1; then
  cat "$TMP_DIR/invalid.out"
  printf 'expected invalid namespace declaration to fail\n' >&2
  exit 1
fi

grep -q 'Invalid namespace' "$TMP_DIR/invalid.out"

printf 'verify_context_multi_namespace_test: OK\n'
