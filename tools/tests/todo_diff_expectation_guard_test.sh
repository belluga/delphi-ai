#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GUARD="$ROOT_DIR/tools/todo_diff_expectation_guard.py"
TMP_DIR="$(mktemp -d)"
cleanup() {
  local status=$?
  rm -rf "$TMP_DIR"
  exit "$status"
}
trap cleanup EXIT

REPO="$TMP_DIR/repo"
mkdir -p "$REPO/src"
git -C "$REPO" init -q
git -C "$REPO" config user.email delphi-test@example.invalid
git -C "$REPO" config user.name Delphi-Test
printf 'initial\n' > "$REPO/src/main.txt"
git -C "$REPO" add src/main.txt
git -C "$REPO" commit -qm baseline

TODO="$TMP_DIR/todo.md"
write_todo() {
  local baseline="$1"
  cat > "$TODO" <<TODO
# TODO: Diff Contract Fixture

## Diff Expectation Contract
- **Contract status:** \`required\`
- **Policy:** \`strict; unclassified or forbidden paths block delivery\`
- **User validation:** \`required on deviation\`
- **Comparison mode:** \`working_tree\`

### Repository Baselines
| Repository | Path | Baseline ref | Comparison mode |
| --- | --- | --- | --- |
| root | . | $baseline | working_tree |

### Expected Changed Paths
| Repository | Path glob | Change types (A|M|D|R|any) | Reason |
| --- | --- | --- | --- |
| root | src/** | M | source implementation |

### Not Expected Changed Paths
| Repository | Path glob | Change types (A|M|D|R|any) | Reason |
| --- | --- | --- | --- |
| root | logs/** | any | generated/log output is not implementation scope |
TODO
}

BASELINE="$(git -C "$REPO" rev-parse HEAD)"
write_todo "$BASELINE"
printf 'updated\n' > "$REPO/src/main.txt"
python3 "$GUARD" "$TODO" --repo-root "$REPO" > "$TMP_DIR/pass.out"
grep -q 'Overall outcome: go' "$TMP_DIR/pass.out"
grep -q 'actual_change_count: 1' "$TMP_DIR/pass.out"

git -C "$REPO" add src/main.txt
git -C "$REPO" commit -qm expected-change
BASELINE="$(git -C "$REPO" rev-parse HEAD)"
write_todo "$BASELINE"
mkdir -p "$REPO/config"
printf 'unexpected\n' > "$REPO/config/unexpected.txt"
if python3 "$GUARD" "$TODO" --repo-root "$REPO" > "$TMP_DIR/unclassified.out" 2>&1; then
  cat "$TMP_DIR/unclassified.out"
  exit 1
fi
grep -q 'Overall outcome: no-go' "$TMP_DIR/unclassified.out"
grep -q 'DIFF-UNCLASSIFIED-PATH' "$TMP_DIR/unclassified.out"
grep -q 'This no-go is not an automatic rollback' "$TMP_DIR/unclassified.out"
grep -q 'necessary/justifiable need' "$TMP_DIR/unclassified.out"

git -C "$REPO" add config/unexpected.txt
git -C "$REPO" commit -qm unexpected-change
BASELINE="$(git -C "$REPO" rev-parse HEAD)"
write_todo "$BASELINE"
mkdir -p "$REPO/logs"
printf 'noise\n' > "$REPO/logs/output.log"
if python3 "$GUARD" "$TODO" --repo-root "$REPO" > "$TMP_DIR/forbidden.out" 2>&1; then
  cat "$TMP_DIR/forbidden.out"
  exit 1
fi
grep -q 'DIFF-FORBIDDEN-PATH' "$TMP_DIR/forbidden.out"
grep -q 'revert an unnecessary deviation' "$TMP_DIR/forbidden.out"

git -C "$REPO" add logs/output.log
git -C "$REPO" commit -qm forbidden-change
BASELINE="$(git -C "$REPO" rev-parse HEAD)"
write_todo "$BASELINE"
rm "$REPO/src/main.txt"
if python3 "$GUARD" "$TODO" --repo-root "$REPO" > "$TMP_DIR/type.out" 2>&1; then
  cat "$TMP_DIR/type.out"
  exit 1
fi
grep -q 'DIFF-CHANGE-TYPE-UNEXPECTED' "$TMP_DIR/type.out"

cat > "$TMP_DIR/missing-contract.md" <<'TODO'
# TODO: Missing Diff Contract

## Delivery Status Canon
- **Current delivery stage:** `Local-Implemented`
TODO
if python3 "$GUARD" "$TMP_DIR/missing-contract.md" --repo-root "$REPO" > "$TMP_DIR/missing.out" 2>&1; then
  cat "$TMP_DIR/missing.out"
  exit 1
fi
grep -q 'DIFF-CONTRACT-MISSING' "$TMP_DIR/missing.out"

printf 'todo_diff_expectation_guard_test: OK\n'
