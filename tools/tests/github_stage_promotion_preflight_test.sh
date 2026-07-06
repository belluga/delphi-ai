#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT_DIR/tools/github_stage_promotion_preflight.sh"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

REMOTE="$TMP_DIR/origin.git"
REPO="$TMP_DIR/repo"
OUTPUT="$TMP_DIR/preflight.out"
FOUNDATION="$TMP_DIR/foundation_documentation"
PACKAGE_DIR="$FOUNDATION/todos/active/v2.0.0+1"
PACKAGE_TODO="$PACKAGE_DIR/TODO-v2.0.0+1-release-package.md"
CHILD_TODO="$PACKAGE_DIR/TODO-v2.0.0+1-sample.md"

git init --bare -q "$REMOTE"
git init -q "$REPO"
git -C "$REPO" config user.email test@example.test
git -C "$REPO" config user.name "Test User"
git -C "$REPO" remote add origin "$REMOTE"

printf 'base\n' > "$REPO/app.txt"
git -C "$REPO" add app.txt
git -C "$REPO" commit -q -m "base"
git -C "$REPO" branch dev
git -C "$REPO" push -q origin dev

git -C "$REPO" checkout -q -b feature/promotable dev
printf 'feature\n' >> "$REPO/app.txt"
git -C "$REPO" add app.txt
git -C "$REPO" commit -q -m "feature change"
FEATURE_SHA="$(git -C "$REPO" rev-parse HEAD)"

mkdir -p "$PACKAGE_DIR"
cat >"$CHILD_TODO" <<'EOF'
# TODO (v2.0.0+1): Sample Child

## Delivery Status Canon
- **Current delivery stage:** `Local-Implemented`
EOF
cat >"$PACKAGE_TODO" <<EOF
# TODO (v2.0.0+1): Current Version Release Package

## Delivery Status Canon
- **Current delivery stage:** \`Local-Implemented\`

## Current Branch Authority
- Root canonical branch: \`feature/promotable\`
- \`foundation_documentation\` authority branch: \`main\`
- Canonical post-replay source baselines currently under promotion consideration:
  - root \`feature/promotable@$FEATURE_SHA\`
  - \`foundation_documentation\` \`main@bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb\`

## Current Diff Child Owners (Approved + In Scope)
- \`todos/active/v2.0.0+1/TODO-v2.0.0+1-sample.md\`
- \`todos/active/v2.0.0+1/TODO-v2.0.0+1-release-package.md\`
EOF

bash "$SCRIPT" --repo "$REPO" --source feature/promotable --base origin/dev >"$OUTPUT"
grep -q "Overall outcome: go" "$OUTPUT"

bash "$SCRIPT" --repo "$REPO" --source feature/promotable --base origin/dev --governing-todo "$PACKAGE_TODO" --repo-key root >"$OUTPUT"
grep -q "Overall outcome: go" "$OUTPUT"
grep -q "governing_todo: $PACKAGE_TODO" "$OUTPUT"

cat >"$PACKAGE_DIR/TODO-v2.0.0+1-late-hotfix.md" <<'EOF'
# TODO (v2.0.0+1): Late Hotfix

## Delivery Status Canon
- **Current delivery stage:** `Pending`
EOF

if bash "$SCRIPT" --repo "$REPO" --source feature/promotable --base origin/dev --governing-todo "$PACKAGE_TODO" --repo-key root >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected live release-package drift to block preflight\n' >&2
  exit 1
fi
grep -q "Release Package Rollup Guard" "$OUTPUT"
grep -q "not frozen in the release package" "$OUTPUT"

rm "$PACKAGE_DIR/TODO-v2.0.0+1-late-hotfix.md"

git -C "$REPO" checkout -q feature/promotable
printf 'post-proof drift\n' >> "$REPO/app.txt"
git -C "$REPO" add app.txt
git -C "$REPO" commit -q -m "post-proof drift"

if bash "$SCRIPT" --repo "$REPO" --source feature/promotable --base origin/dev --governing-todo "$PACKAGE_TODO" --repo-key root >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected governing TODO authority drift to block preflight\n' >&2
  exit 1
fi
grep -q "authoritative baseline SHA" "$OUTPUT"

git -C "$REPO" checkout -q -b reconcile/direct-promote dev
printf 'reconcile\n' >> "$REPO/app.txt"
git -C "$REPO" add app.txt
git -C "$REPO" commit -q -m "reconcile change"

if bash "$SCRIPT" --repo "$REPO" --source reconcile/direct-promote --base origin/dev >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected reconcile/* source preflight to be blocked\n' >&2
  exit 1
fi
grep -q "Promotion may not start from reconcile/\\*" "$OUTPUT"
grep -q "Replay the accepted reconcile state onto the canonical version/source branch first" "$OUTPUT"

git -C "$REPO" checkout -q dev
git -C "$REPO" checkout -q -b sequence/direct-promote dev
printf 'sequence\n' >> "$REPO/app.txt"
git -C "$REPO" add app.txt
git -C "$REPO" commit -q -m "sequence change"

if bash "$SCRIPT" --repo "$REPO" --source sequence/direct-promote --base origin/dev >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected sequence/* source preflight to be blocked\n' >&2
  exit 1
fi
grep -q "Promotion may not start from sequence/\\*" "$OUTPUT"
grep -q "Validate the accepted sequence state with the user" "$OUTPUT"

git -C "$REPO" checkout -q dev
git -C "$REPO" checkout -q -b stage
git -C "$REPO" push -q origin stage

git -C "$REPO" checkout -q dev
printf 'feature-two\n' >> "$REPO/app.txt"
git -C "$REPO" add app.txt
git -C "$REPO" commit -q -m "feature two"
git -C "$REPO" push -q origin dev

git -C "$REPO" checkout -q stage
git -C "$REPO" merge -q --no-ff origin/dev -m "merge dev into stage"
git -C "$REPO" push -q origin stage

git -C "$REPO" checkout -q -b reconcile/dev-contains-stage-demo origin/dev
git -C "$REPO" merge -q --no-ff origin/stage -m "merge stage into dev topology replay"

bash "$SCRIPT" --repo "$REPO" --source reconcile/dev-contains-stage-demo --base origin/dev >"$OUTPUT"
grep -q "Overall outcome: go" "$OUTPUT"
grep -q "topology_only_reconciliation_accepted: yes" "$OUTPUT"

printf 'github_stage_promotion_preflight_test: OK\n'
