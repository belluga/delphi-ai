#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

SUBMODULE_REPO="$TMP_DIR/submodule"
PARENT_REPO="$TMP_DIR/parent"
OUTPUT="$TMP_DIR/out.txt"

git -C "$TMP_DIR" init -q "$SUBMODULE_REPO"
git -C "$SUBMODULE_REPO" config user.email test@example.test
git -C "$SUBMODULE_REPO" config user.name "Test User"
printf 'v1\n' >"$SUBMODULE_REPO/file.txt"
git -C "$SUBMODULE_REPO" add file.txt
git -C "$SUBMODULE_REPO" commit -q -m "submodule initial"
SUBMODULE_SHA_ONE="$(git -C "$SUBMODULE_REPO" rev-parse HEAD)"

git -C "$TMP_DIR" init -q "$PARENT_REPO"
git -C "$PARENT_REPO" config user.email test@example.test
git -C "$PARENT_REPO" config user.name "Test User"
git -C "$PARENT_REPO" -c protocol.file.allow=always submodule add -q "$SUBMODULE_REPO" child
git -C "$PARENT_REPO" commit -q -m "parent initial"

printf 'v2\n' >"$SUBMODULE_REPO/file.txt"
git -C "$SUBMODULE_REPO" commit -q -am "submodule advance"
SUBMODULE_SHA_TWO="$(git -C "$SUBMODULE_REPO" rev-parse HEAD)"

bash "$ROOT_DIR/tools/install_pipeline_only_gitlink_commit_guard.sh" --repo "$PARENT_REPO" >/dev/null
HOOKS_PATH="$(git -C "$PARENT_REPO" config --get core.hooksPath)"
test -x "$HOOKS_PATH/pre-commit"

printf 'normal\n' >"$PARENT_REPO/README.md"
git -C "$PARENT_REPO" add README.md
git -C "$PARENT_REPO" commit -q -m "normal file commit"

git -C "$PARENT_REPO/child" fetch -q origin
git -C "$PARENT_REPO/child" checkout -q "$SUBMODULE_SHA_TWO"
printf 'second normal file\n' >"$PARENT_REPO/NOTES.md"
git -C "$PARENT_REPO" add NOTES.md
git -C "$PARENT_REPO" commit -q -m "normal file while gitlink drifts"
test "$(git -C "$PARENT_REPO" rev-parse --verify HEAD:NOTES.md)" = "$(git -C "$PARENT_REPO" hash-object "$PARENT_REPO/NOTES.md")"

git -C "$PARENT_REPO" reset -q HEAD NOTES.md

git -C "$PARENT_REPO" add child
if git -C "$PARENT_REPO" commit -m "manual staged gitlink move" >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected staged gitlink commit to be blocked\n' >&2
  exit 1
fi
grep -q "Staged gitlink paths:" "$OUTPUT"
grep -q "child" "$OUTPUT"

git -C "$PARENT_REPO" reset -q HEAD child
if git -C "$PARENT_REPO" commit -am "manual gitlink move with -a" >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected git commit -a with gitlink drift to be blocked\n' >&2
  exit 1
fi
grep -q "Staged gitlink paths:" "$OUTPUT"
grep -q "child" "$OUTPUT"

git -C "$PARENT_REPO/child" checkout -q "$SUBMODULE_SHA_ONE"
git -C "$PARENT_REPO" add child
git -C "$PARENT_REPO" reset -q HEAD child
git -C "$PARENT_REPO" reset -q HEAD NOTES.md
git -C "$PARENT_REPO" checkout -- NOTES.md
git -C "$PARENT_REPO" checkout -- child

printf 'install_pipeline_only_gitlink_commit_guard_test: OK\n'
