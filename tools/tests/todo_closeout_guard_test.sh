#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GUARD="$ROOT_DIR/tools/todo_closeout_guard.py"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

REPO="$TMP_DIR/project"
ACTIVE="$REPO/foundation_documentation/todos/active"
OUTPUT_FILE="$TMP_DIR/todo-closeout-guard.out"
JSON_OUTPUT="$TMP_DIR/todo-closeout-guard.json"
mkdir -p "$ACTIVE"

assert_no_go() {
  local todo_file="$1"
  shift || true
  if python3 "$GUARD" "$todo_file" --repo "$REPO" "$@" > "$OUTPUT_FILE" 2>&1; then
    cat "$OUTPUT_FILE"
    printf 'expected no-go for %s\n' "$todo_file" >&2
    exit 1
  fi
  grep -q "Overall outcome: no-go" "$OUTPUT_FILE"
}

assert_go() {
  local todo_file="$1"
  shift || true
  python3 "$GUARD" "$todo_file" --repo "$REPO" "$@" > "$OUTPUT_FILE" 2>&1
  grep -q "Overall outcome: go" "$OUTPUT_FILE"
}

cat > "$ACTIVE/missing-disposition.md" <<'TODO'
# TODO: Missing Disposition

## Delivery Status Canon
- **Current delivery stage:** `Local-Implemented`
- **Qualifiers:** `none`
- **Next exact step:** Move this TODO to completed after validation.
TODO

assert_no_go "$ACTIVE/missing-disposition.md"
grep -q "CLOSEOUT-DISPOSITION-MISSING" "$OUTPUT_FILE"

cat > "$ACTIVE/move-completed-pending.md" <<'TODO'
# TODO: Move Completed Pending

## Delivery Status Canon
- **Current delivery stage:** `Local-Implemented`
- **Qualifiers:** `none`
- **Next exact step:** Commit and push this implementation package.

## TODO Closeout Disposition
- **Disposition:** `move-completed`
- **Disposition reason:** Local-only maintenance is complete after validation and commit/push.
- **Post-commit/push status:** `pending`
- **Next path/status action:** Move this TODO to `foundation_documentation/todos/completed/` after push.
TODO

assert_go "$ACTIVE/move-completed-pending.md"

cat > "$ACTIVE/move-completed-complete.md" <<'TODO'
# TODO: Move Completed Complete

## Delivery Status Canon
- **Current delivery stage:** `Local-Implemented`
- **Qualifiers:** `none`
- **Next exact step:** Move this TODO to completed.

## TODO Closeout Disposition
- **Disposition:** `move-completed`
- **Disposition reason:** Local-only maintenance is complete.
- **Post-commit/push status:** `complete`
- **Next path/status action:** Move this TODO to `foundation_documentation/todos/completed/`.
TODO

assert_no_go "$ACTIVE/move-completed-complete.md"
grep -q "CLOSEOUT-MOVE-PENDING-AFTER-PUSH" "$OUTPUT_FILE"

cat > "$ACTIVE/keep-active-stale.md" <<'TODO'
# TODO: Keep Active Stale

## Delivery Status Canon
- **Current delivery stage:** `Local-Implemented`
- **Qualifiers:** `none`
- **Next exact step:** Present the next pending validation point to the user.

## TODO Closeout Disposition
- **Disposition:** `keep-active`
- **Disposition reason:** Waiting for a chat update.
- **Post-commit/push status:** `pending`
- **Next path/status action:** Keep active.
TODO

assert_no_go "$ACTIVE/keep-active-stale.md"
grep -q "CLOSEOUT-NEXT-STEP-STALE" "$OUTPUT_FILE"
grep -q "CLOSEOUT-KEEP-ACTIVE-NON-ACTIONABLE" "$OUTPUT_FILE"

cat > "$ACTIVE/keep-active-promotion.md" <<'TODO'
# TODO: Keep Active Promotion

## Delivery Status Canon
- **Current delivery stage:** `Local-Implemented`
- **Qualifiers:** `none`
- **Next exact step:** Continue stage promotion through the github-stage-promotion-orchestrator.

## TODO Closeout Disposition
- **Disposition:** `keep-active`
- **Disposition reason:** Authorized promotion follow-through remains open.
- **Post-commit/push status:** `complete`
- **Next path/status action:** Keep active until the promotion lane threshold is met.
TODO

assert_go "$ACTIVE/keep-active-promotion.md"

cat > "$ACTIVE/blocked.md" <<'TODO'
# TODO: Blocked

## Delivery Status Canon
- **Current delivery stage:** `Local-Implemented`
- **Qualifiers:** `Blocked`
- **Next exact step:** Await user approval for the external dependency.

## TODO Closeout Disposition
- **Disposition:** `blocked`
- **Disposition reason:** External dependency is unavailable.
- **Post-commit/push status:** `n/a`
- **Next path/status action:** Keep active with blocker notes.
TODO

assert_go "$ACTIVE/blocked.md"

python3 "$GUARD" --repo "$REPO" --all-active --advisory --json-output "$JSON_OUTPUT" > "$OUTPUT_FILE" 2>&1
grep -q "Overall outcome: no-go" "$OUTPUT_FILE"
python3 - "$JSON_OUTPUT" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    data = json.load(handle)

assert data["rule_id"] == "paced.todo.closeout-disposition"
assert data["todo_count"] == 6
assert data["overall_outcome"] == "no-go"
assert any(item["code"] == "CLOSEOUT-DISPOSITION-MISSING" for item in data["violations"])
PY

printf 'todo_closeout_guard_test: OK\n'
