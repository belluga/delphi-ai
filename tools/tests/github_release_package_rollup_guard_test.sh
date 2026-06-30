#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT_DIR/tools/github_release_package_rollup_guard.py"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

WORKSPACE="$TMP_DIR/workspace"
ROOT_REPO="$WORKSPACE"
FLUTTER_REPO="$WORKSPACE/flutter-app"
FOUNDATION="$WORKSPACE/foundation_documentation"
ROOT_REMOTE="$TMP_DIR/root-origin.git"
FLUTTER_REMOTE="$TMP_DIR/flutter-origin.git"
PACKAGE_DIR="$FOUNDATION/todos/promotion_lane/v9.9.9"
PACKAGE_TODO="$PACKAGE_DIR/TODO-v9.9.9-release-package.md"
CHILD_ONE="$PACKAGE_DIR/TODO-v9.9.9-public-fix.md"
CHILD_TWO="$PACKAGE_DIR/TODO-v9.9.9-ios-followthrough.md"
ACTIVE_DIR="$FOUNDATION/todos/active/v9.9.9"
OUTPUT="$TMP_DIR/release-package-rollup.out"

mkdir -p "$PACKAGE_DIR" "$ACTIVE_DIR"

git init --bare -q "$ROOT_REMOTE"
git init -q "$ROOT_REPO"
git -C "$ROOT_REPO" config user.email test@example.test
git -C "$ROOT_REPO" config user.name "Test User"
git -C "$ROOT_REPO" remote add origin "$ROOT_REMOTE"
printf 'root-base\n' > "$ROOT_REPO/README.md"
git -C "$ROOT_REPO" add README.md
git -C "$ROOT_REPO" commit -q -m "root base"
git -C "$ROOT_REPO" branch dev
git -C "$ROOT_REPO" push -q origin dev
git -C "$ROOT_REPO" checkout -q -b v9.9.9-rc
git -C "$ROOT_REPO" update-index --add --cacheinfo 160000 1111111111111111111111111111111111111111 flutter-app
git -C "$ROOT_REPO" commit -q -m "pin flutter gitlink"
ROOT_SHA="$(git -C "$ROOT_REPO" rev-parse HEAD)"

git init --bare -q "$FLUTTER_REMOTE"
git init -q "$FLUTTER_REPO"
git -C "$FLUTTER_REPO" config user.email test@example.test
git -C "$FLUTTER_REPO" config user.name "Test User"
git -C "$FLUTTER_REPO" remote add origin "$FLUTTER_REMOTE"
cat > "$FLUTTER_REPO/pubspec.yaml" <<'EOF_PUB'
name: sample_flutter
environment:
  sdk: ">=3.0.0 <4.0.0"
EOF_PUB
git -C "$FLUTTER_REPO" add pubspec.yaml
git -C "$FLUTTER_REPO" commit -q -m "flutter base"
git -C "$FLUTTER_REPO" branch dev
git -C "$FLUTTER_REPO" push -q origin dev
git -C "$FLUTTER_REPO" checkout -q -b v9.9.9-rc dev
FLUTTER_SHA="$(git -C "$FLUTTER_REPO" rev-parse HEAD)"

cat > "$CHILD_ONE" <<'EOF'
# TODO (v9.9.9): Public Fix

## Delivery Status Canon
- **Current delivery stage:** `Lane-Promoted`
EOF

cat > "$CHILD_TWO" <<'EOF'
# TODO (v9.9.9): iOS Followthrough

## Delivery Status Canon
- **Current delivery stage:** `Lane-Promoted`
EOF

cat > "$PACKAGE_TODO" <<EOF
# TODO (v9.9.9): Release Package

## Delivery Status Canon
- **Current delivery stage:** \`Lane-Promoted\`

## Current Branch Authority
- Root canonical branch: \`v9.9.9-rc\`
- \`flutter-app\` canonical branch: \`v9.9.9-rc\`
- \`foundation_documentation\` authority branch: \`main\`
- Canonical post-replay source baselines currently under promotion consideration:
  - root \`v9.9.9-rc@$ROOT_SHA\`
  - \`flutter-app\` \`v9.9.9-rc@$FLUTTER_SHA\`
  - \`foundation_documentation\` \`main@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\`

## Current Diff Child Owners (Approved + In Scope)
- \`todos/promotion_lane/v9.9.9/TODO-v9.9.9-public-fix.md\`
- \`todos/promotion_lane/v9.9.9/TODO-v9.9.9-ios-followthrough.md\`
EOF

python3 "$SCRIPT" --governing-todo "$PACKAGE_TODO" > "$OUTPUT"
grep -q "Overall outcome: go" "$OUTPUT"
grep -q "recommended_opening_track: docker-bot-next-version" "$OUTPUT"
grep -q "root | branch=v9.9.9-rc .* state=gitlink-only" "$OUTPUT"
grep -q "flutter-app | branch=v9.9.9-rc .* state=already-absorbed-by-dev" "$OUTPUT"

cat > "$ACTIVE_DIR/TODO-v9.9.9-late-hotfix.md" <<'EOF'
# TODO (v9.9.9): Late Hotfix

## Delivery Status Canon
- **Current delivery stage:** `Pending`
EOF

if python3 "$SCRIPT" --governing-todo "$PACKAGE_TODO" > "$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected live membership drift to block release-package rollup\n' >&2
  exit 1
fi
grep -q "Overall outcome: no-go" "$OUTPUT"
grep -q "not frozen in the release package" "$OUTPUT"
grep -q "renew package approval" "$OUTPUT"

cat > "$PACKAGE_TODO" <<EOF
# TODO (v9.9.9): Release Package

## Delivery Status Canon
- **Current delivery stage:** \`Lane-Promoted\`

## Current Branch Authority
- Root canonical branch: \`v9.9.9-rc\`
- \`flutter-app\` canonical branch: \`v9.9.9-rc\`
- \`foundation_documentation\` authority branch: \`main\`
- Canonical post-replay source baselines currently under promotion consideration:
  - root \`v9.9.9-rc@$ROOT_SHA\`
  - \`foundation_documentation\` \`main@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\`

## Current Diff Child Owners (Approved + In Scope)
- \`todos/promotion_lane/v9.9.9/TODO-v9.9.9-public-fix.md\`
- \`todos/promotion_lane/v9.9.9/TODO-v9.9.9-ios-followthrough.md\`
- \`todos/active/v9.9.9/TODO-v9.9.9-late-hotfix.md\`
EOF

if python3 "$SCRIPT" --governing-todo "$PACKAGE_TODO" > "$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected missing flutter baseline and pending child to block release-package rollup\n' >&2
  exit 1
fi
grep -q "does not include an entry for repo \`flutter-app\`" "$OUTPUT"
grep -q "below the minimum promotable threshold" "$OUTPUT"

printf 'github_release_package_rollup_guard_test: OK\n'
