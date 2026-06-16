#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT_DIR/tools/github_stage_promotion_preflight.sh"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

REMOTE="$TMP_DIR/origin.git"
REPO="$TMP_DIR/repo"
OUTPUT="$TMP_DIR/preflight.out"

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

bash "$SCRIPT" --repo "$REPO" --source feature/promotable --base origin/dev >"$OUTPUT"
grep -q "Overall outcome: go" "$OUTPUT"

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
