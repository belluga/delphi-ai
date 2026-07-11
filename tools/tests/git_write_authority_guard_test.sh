#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT_DIR/tools/git_write_authority_guard.py"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

make_repo() {
  local repo="$1"
  git init -q "$repo"
  git -C "$repo" config user.email test@example.test
  git -C "$repo" config user.name "Test User"
  printf 'base\n' > "$repo/file.txt"
  git -C "$repo" add file.txt
  git -C "$repo" commit -q -m "base"
}

FOUNDATION="$TMP_DIR/foundation_documentation"
CODE="$TMP_DIR/code-repo"
DELPHI="$TMP_DIR/delphi-ai"
OUT="$TMP_DIR/out.txt"

make_repo "$FOUNDATION"
make_repo "$CODE"
make_repo "$DELPHI"
git -C "$FOUNDATION" branch -m main

python3 "$SCRIPT" --repo "$FOUNDATION" --action git-commit >"$OUT"
grep -q "Overall outcome: go" "$OUT"
grep -q "foundation_main_allowed" "$OUT"

git -C "$FOUNDATION" checkout -q -b docs-drift
if python3 "$SCRIPT" --repo "$FOUNDATION" --action git-push >"$OUT" 2>&1; then
  cat "$OUT"
  printf 'expected foundation non-main branch to be blocked\n' >&2
  exit 1
fi
grep -q "foundation_documentation.*must stay on \`main\`" "$OUT"

git -C "$CODE" branch dev
git -C "$CODE" checkout -q dev
if python3 "$SCRIPT" --repo "$CODE" --action git-commit >"$OUT" 2>&1; then
  cat "$OUT"
  printf 'expected dev direct write to be blocked\n' >&2
  exit 1
fi
grep -q "protected promotion branch \`dev\`" "$OUT"

git -C "$CODE" checkout -q -b sequence/v0.3.2
python3 "$SCRIPT" --repo "$CODE" --action git-push >"$OUT"
grep -q "Overall outcome: go" "$OUT"
grep -q "project_work_branch_allowed" "$OUT"

git -C "$CODE" checkout -q -b v0.3.2-rc
python3 "$SCRIPT" --repo "$CODE" --action git-commit >"$OUT"
grep -q "Overall outcome: go" "$OUT"
grep -q "project_work_branch_allowed" "$OUT"

python3 "$SCRIPT" --repo "$DELPHI" --action git-commit >"$OUT"
grep -q "Overall outcome: go" "$OUT"
grep -q "delphi_self_allowed" "$OUT"

git -C "$CODE" checkout -q "$(git -C "$CODE" rev-parse HEAD)"
if python3 "$SCRIPT" --repo "$CODE" --action git-push >"$OUT" 2>&1; then
  cat "$OUT"
  printf 'expected detached HEAD to be blocked\n' >&2
  exit 1
fi
grep -q "detached HEAD" "$OUT"

printf 'git_write_authority_guard_test: OK\n'
