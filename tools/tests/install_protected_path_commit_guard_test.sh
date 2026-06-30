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
git -C "$SUBMODULE_REPO" branch -m main
SUBMODULE_SHA_ONE="$(git -C "$SUBMODULE_REPO" rev-parse HEAD)"

git -C "$TMP_DIR" init -q "$PARENT_REPO"
git -C "$PARENT_REPO" config user.email test@example.test
git -C "$PARENT_REPO" config user.name "Test User"
git -C "$PARENT_REPO" -c protocol.file.allow=always submodule add -q "$SUBMODULE_REPO" child
git -C "$PARENT_REPO" commit -q -m "parent initial"
git -C "$PARENT_REPO" branch -m main
git -C "$PARENT_REPO" branch feature/test

printf 'v2\n' >"$SUBMODULE_REPO/file.txt"
git -C "$SUBMODULE_REPO" commit -q -am "submodule advance"
SUBMODULE_SHA_TWO="$(git -C "$SUBMODULE_REPO" rev-parse HEAD)"

bash "$ROOT_DIR/tools/install_pipeline_only_gitlink_commit_guard.sh" --repo "$PARENT_REPO" >/dev/null
bash "$ROOT_DIR/tools/install_protected_path_commit_guard.sh" \
  --repo "$PARENT_REPO" \
  --path .gitmodules \
  --guard-id gitmodules-pipeline-owned \
  --guard-title "PACED .gitmodules Commit Guard" \
  --authority ".gitmodules is a pipeline-read topology contract in this repository. Local commits must not mutate it." \
  --expected-behavior "Revert or unstage .gitmodules and route approved topology changes through the owning workflow." \
  --resolution "Commit blocked because .gitmodules changed outside the owning workflow." \
  >/dev/null
bash "$ROOT_DIR/tools/install_foundation_main_only_guard.sh" --repo "$PARENT_REPO" --branch main >/dev/null

HOOKS_PATH="$(git -C "$PARENT_REPO" config --get core.hooksPath)"
test -x "$HOOKS_PATH/pre-commit"
test -x "$HOOKS_PATH/reference-transaction"
test -x "$HOOKS_PATH/post-checkout"

printf '\n# guard test\n' >>"$PARENT_REPO/.gitmodules"
git -C "$PARENT_REPO" add .gitmodules
if git -C "$PARENT_REPO" commit -m "mutate .gitmodules" >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected protected path commit to be blocked\n' >&2
  exit 1
fi
grep -q ".gitmodules Commit Guard" "$OUTPUT"
grep -q ".gitmodules is a pipeline-read topology contract" "$OUTPUT"
grep -q "Staged protected paths:" "$OUTPUT"
grep -q ".gitmodules" "$OUTPUT"

git -C "$PARENT_REPO" reset -q HEAD .gitmodules
git -C "$PARENT_REPO" checkout -- .gitmodules

git -C "$PARENT_REPO/child" fetch -q origin
git -C "$PARENT_REPO/child" checkout -q "$SUBMODULE_SHA_TWO"
printf 'normal\n' >"$PARENT_REPO/README.md"
git -C "$PARENT_REPO" add README.md
if git -C "$PARENT_REPO" commit -m "normal file while gitlink drifts" >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected gitlink drift commit to be blocked\n' >&2
  exit 1
fi
grep -q "Pipeline-Only Gitlink Commit Guard" "$OUTPUT"
grep -q "Worktree gitlink paths:" "$OUTPUT"
grep -q "child" "$OUTPUT"

git -C "$PARENT_REPO" reset -q HEAD README.md
git -C "$PARENT_REPO/child" checkout -q "$SUBMODULE_SHA_ONE"
git -C "$PARENT_REPO" checkout -- child

if git -C "$PARENT_REPO" checkout feature/test >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected foundation main-only checkout to be blocked\n' >&2
  exit 1
fi
grep -q "Foundation Documentation Main-Only Guard" "$OUTPUT"
test "$(git -C "$PARENT_REPO" branch --show-current)" = "main"

printf 'install_protected_path_commit_guard_test: OK\n'
