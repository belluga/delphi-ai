#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT_DIR/tools/github_promotion_source_authority_guard.py"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

REMOTE="$TMP_DIR/origin.git"
REPO="$TMP_DIR/repo"
FOUNDATION="$TMP_DIR/foundation_documentation"
PACKAGE_DIR="$FOUNDATION/todos/active/v1.0.0+1"
PACKAGE_TODO="$PACKAGE_DIR/TODO-v1.0.0+1-release-package.md"
CHILD_TODO="$PACKAGE_DIR/TODO-v1.0.0+1-feature.md"
OUTPUT="$TMP_DIR/authority.out"

git init --bare -q "$REMOTE"
git init -q "$REPO"
git -C "$REPO" config user.email test@example.test
git -C "$REPO" config user.name "Test User"
git -C "$REPO" remote add origin "$REMOTE"

printf 'base\n' > "$REPO/app.txt"
git -C "$REPO" add app.txt
git -C "$REPO" commit -q -m "base"
git -C "$REPO" branch dev
git -C "$REPO" checkout -q -b v1.0.0+1-rc
printf 'release\n' >> "$REPO/app.txt"
git -C "$REPO" add app.txt
git -C "$REPO" commit -q -m "release state"
RELEASE_SHA="$(git -C "$REPO" rev-parse HEAD)"

mkdir -p "$PACKAGE_DIR"

cat >"$CHILD_TODO" <<'EOF'
# TODO (v1.0.0+1): Sample Feature

## Delivery Status Canon
- **Current delivery stage:** `Local-Implemented`
EOF

cat >"$PACKAGE_TODO" <<EOF
# TODO (v1.0.0+1): Current Version Release Package

## Delivery Status Canon
- **Current delivery stage:** \`Local-Implemented\`

## Current Branch Authority
- Root canonical branch: \`v1.0.0+1-rc\`
- \`foundation_documentation\` authority branch: \`main\`
- Canonical post-replay source baselines currently under promotion consideration:
  - root \`v1.0.0+1-rc@$RELEASE_SHA\`
  - \`foundation_documentation\` \`main@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\`

## Current Diff Child Owners (Approved + In Scope)
- \`todos/active/v1.0.0+1/TODO-v1.0.0+1-feature.md\`
- \`todos/active/v1.0.0+1/TODO-v1.0.0+1-release-package.md\`
EOF

python3 "$SCRIPT" --repo "$REPO" --source-ref v1.0.0+1-rc --governing-todo "$PACKAGE_TODO" --repo-key root >"$OUTPUT"
grep -q "Overall outcome: go" "$OUTPUT"
grep -q "expected_source_branch: v1.0.0+1-rc" "$OUTPUT"

git -C "$REPO" branch v1.0.0+1-hotfix "$RELEASE_SHA"
if python3 "$SCRIPT" --repo "$REPO" --source-ref v1.0.0+1-hotfix --governing-todo "$PACKAGE_TODO" --repo-key root >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected wrong authoritative branch to be blocked\n' >&2
  exit 1
fi
grep -q "authoritative promotion branch" "$OUTPUT"

cat >"$CHILD_TODO" <<'EOF'
# TODO (v1.0.0+1): Sample Feature

## Delivery Status Canon
- **Current delivery stage:** `Pending`
EOF

if python3 "$SCRIPT" --repo "$REPO" --source-ref v1.0.0+1-rc --governing-todo "$PACKAGE_TODO" --repo-key root >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected child owner below Local-Implemented to be blocked\n' >&2
  exit 1
fi
grep -q "below the minimum promotable threshold" "$OUTPUT"

cat >"$CHILD_TODO" <<'EOF'
# TODO (v1.0.0+1): Sample Feature

## Delivery Status Canon
- **Current delivery stage:** `Local-Implemented`
EOF

git -C "$REPO" checkout -q v1.0.0+1-rc
printf 'post-validation drift\n' >> "$REPO/app.txt"
git -C "$REPO" add app.txt
git -C "$REPO" commit -q -m "drift after validation"

if python3 "$SCRIPT" --repo "$REPO" --source-ref v1.0.0+1-rc --governing-todo "$PACKAGE_TODO" --repo-key root >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected authoritative sha drift to be blocked\n' >&2
  exit 1
fi
grep -q "does not match the authoritative baseline SHA" "$OUTPUT"

printf 'github_promotion_source_authority_guard_test: OK\n'
