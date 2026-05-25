#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

CONTRACT="$TMP_DIR/promotion-contract.json"
OUTPUT="$TMP_DIR/out.txt"
REPO="$TMP_DIR/repo"

bash "$ROOT_DIR/tools/github_promotion_contract_init.sh" \
  --output "$CONTRACT" \
  --scope through-stage \
  --gitlink-policy pipeline-only \
  >/dev/null

bash "$ROOT_DIR/tools/github_promotion_action_guard.sh" \
  --contract "$CONTRACT" \
  --action pr-create \
  --repo-kind docker \
  --repo-slug test/docker \
  --head bot/next-version \
  --base dev \
  >"$OUTPUT"
grep -q "Overall outcome: go" "$OUTPUT"

if bash "$ROOT_DIR/tools/github_promotion_action_guard.sh" \
  --contract "$CONTRACT" \
  --action pr-create \
  --repo-kind docker \
  --repo-slug test/docker \
  --head bot/next-version \
  --base stage \
  >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected bot/next-version -> stage to be blocked\n' >&2
  exit 1
fi
grep -q "bot/next-version -> dev" "$OUTPUT"

if bash "$ROOT_DIR/tools/github_promotion_action_guard.sh" \
  --contract "$CONTRACT" \
  --action pr-create \
  --repo-kind other \
  --repo-slug test/web-app \
  --head feature \
  --base dev \
  >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected web-app PR mutation to be blocked\n' >&2
  exit 1
fi
grep -q "derived artifact" "$OUTPUT"

mkdir -p "$REPO"
git -C "$REPO" init -q
git -C "$REPO" config user.email test@example.test
git -C "$REPO" config user.name "Test User"
touch "$REPO/README.md"
git -C "$REPO" add README.md
git -C "$REPO" commit -q -m initial
git -C "$REPO" branch dev
git -C "$REPO" branch stage
git -C "$REPO" checkout -q -b bot/next-version dev
git -C "$REPO" update-index --add --cacheinfo 160000 1111111111111111111111111111111111111111 flutter-app
git -C "$REPO" commit -q -m "Update flutter gitlink"

bash "$ROOT_DIR/tools/github_promotion_diff_guard.sh" \
  --contract "$CONTRACT" \
  --repo "$REPO" \
  --mode range \
  --base-ref dev \
  --source-ref bot/next-version \
  >"$OUTPUT"
grep -q "Overall outcome: go" "$OUTPUT"

if bash "$ROOT_DIR/tools/github_promotion_diff_guard.sh" \
  --contract "$CONTRACT" \
  --repo "$REPO" \
  --mode range \
  --base-ref stage \
  --source-ref bot/next-version \
  >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected bot/next-version gitlink range against stage to be blocked\n' >&2
  exit 1
fi
grep -q "bot/next-version -> dev" "$OUTPUT"

printf 'github_promotion_guard_policy_test: OK\n'
