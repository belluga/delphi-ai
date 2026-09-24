#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

REPO="$TMP_DIR/foundation"
CHECKOUT_OUTPUT="$TMP_DIR/checkout.out"
WORKTREE_OUTPUT="$TMP_DIR/worktree.out"
CANONICAL_COMMIT_OUTPUT="$TMP_DIR/canonical-commit.out"
COPIED_COMMIT_OUTPUT="$TMP_DIR/copied-commit.out"
WORKTREE_PATH="$TMP_DIR/foundation-wt"
COPIED_REPO="$TMP_DIR/foundation-copy"

git -C "$TMP_DIR" init -q "$REPO"
git -C "$REPO" config user.email test@example.test
git -C "$REPO" config user.name "Test User"
printf 'doc\n' >"$REPO/README.md"
git -C "$REPO" add README.md
git -C "$REPO" commit -q -m "initial"
git -C "$REPO" branch -m main
git -C "$REPO" branch feature/test

bash "$ROOT_DIR/tools/install_foundation_main_only_guard.sh" --repo "$REPO" --branch main >/dev/null

HOOKS_PATH="$(git -C "$REPO" config --get core.hooksPath)"
test -x "$HOOKS_PATH/reference-transaction"
test -x "$HOOKS_PATH/post-checkout"
test -x "$HOOKS_PATH/pre-commit"
test -x "$HOOKS_PATH/pre-push"
test -x "$HOOKS_PATH/../managed/foundation-main-only/lib.sh"

if git -C "$REPO" checkout feature/test >"$CHECKOUT_OUTPUT" 2>&1; then
  cat "$CHECKOUT_OUTPUT"
  printf 'expected foundation main-only checkout to be blocked\n' >&2
  exit 1
fi
grep -q "TEACH runtime response" "$CHECKOUT_OUTPUT"
grep -q "outside the only approved writable branch 'main'" "$CHECKOUT_OUTPUT"
grep -q "Do not create or switch to feature branches" "$CHECKOUT_OUTPUT"
test "$(git -C "$REPO" branch --show-current)" = "main"

if git -C "$REPO" worktree add --detach "$WORKTREE_PATH" HEAD >"$WORKTREE_OUTPUT" 2>&1; then
  cat "$WORKTREE_OUTPUT"
  printf 'expected linked worktree creation to be blocked\n' >&2
  exit 1
fi
grep -q "TEACH runtime response" "$WORKTREE_OUTPUT"
grep -q "linked Git worktree gitdir" "$WORKTREE_OUTPUT"
grep -q "Git exposes no pre-worktree-add hook" "$WORKTREE_OUTPUT"
mkdir -p "$REPO/.git/worktrees/simulated-linked"

printf 'canon\n' >>"$REPO/README.md"
git -C "$REPO" add README.md
if git -C "$REPO" commit -m "canonical commit while split authority exists" >"$CANONICAL_COMMIT_OUTPUT" 2>&1; then
  cat "$CANONICAL_COMMIT_OUTPUT"
  printf 'expected canonical foundation commit to be blocked while linked worktree exists\n' >&2
  exit 1
fi
grep -q "TEACH runtime response" "$CANONICAL_COMMIT_OUTPUT"
grep -q "detected linked worktree admin entries" "$CANONICAL_COMMIT_OUTPUT"
grep -q "Git exposes no pre-worktree-add hook" "$CANONICAL_COMMIT_OUTPUT"

rm -rf "$WORKTREE_PATH"
rm -rf "$REPO/.git/worktrees/simulated-linked"
git -C "$REPO" worktree prune >/dev/null

cp -a "$REPO" "$COPIED_REPO"
git -C "$COPIED_REPO" config user.email test@example.test
git -C "$COPIED_REPO" config user.name "Test User"
printf 'copy\n' >"$COPIED_REPO/COPY.md"
git -C "$COPIED_REPO" add COPY.md
if git -C "$COPIED_REPO" commit -m "copied folder commit" >"$COPIED_COMMIT_OUTPUT" 2>&1; then
  cat "$COPIED_COMMIT_OUTPUT"
  printf 'expected copied writable mirror commit to be blocked\n' >&2
  exit 1
fi
grep -q "TEACH runtime response" "$COPIED_COMMIT_OUTPUT"
grep -q "not from the only approved canonical checkout" "$COPIED_COMMIT_OUTPUT"
grep -q "Delete the alternate folder or writable mirror" "$COPIED_COMMIT_OUTPUT"

printf 'install_foundation_main_only_guard_test: OK\n'
