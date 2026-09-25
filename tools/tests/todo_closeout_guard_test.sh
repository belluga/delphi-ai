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
  shift
  set +e
  python3 "$GUARD" "$todo_file" --repo "$REPO" "$@" > "$OUTPUT_FILE" 2>&1
  local status=$?
  set -e
  test "$status" -eq 2
  grep -q "Overall outcome: no-go" "$OUTPUT_FILE"
  ! grep -q 'Traceback' "$OUTPUT_FILE"
}

assert_go() {
  local todo_file="$1"
  shift
  python3 "$GUARD" "$todo_file" --repo "$REPO" "$@" > "$OUTPUT_FILE" 2>&1
  grep -q "Overall outcome: go" "$OUTPUT_FILE"
}

assert_structured_no_go() {
  local expected_code="$1"
  shift
  set +e
  "$@" > "$OUTPUT_FILE" 2>&1
  local status=$?
  set -e
  test "$status" -eq 2
  grep -q 'Overall outcome: no-go' "$OUTPUT_FILE"
  grep -q "$expected_code" "$OUTPUT_FILE"
  ! grep -q 'Traceback' "$OUTPUT_FILE"
}

assert_boundary_json() {
  local expected_code="$1"
  local expected_count="$2"
  shift 2
  assert_structured_no_go "$expected_code" "$@" --json-output "$JSON_OUTPUT"
  python3 - "$JSON_OUTPUT" "$expected_code" "$expected_count" <<'PY'
import json, sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
assert data["todo_count"] == len(data["todo_results"]) == int(sys.argv[3])
assert len(data["violations"]) == 1
assert [value["code"] for value in data["violations"]] == [sys.argv[2]]
item = data["violations"][0]
assert set(("code", "message", "resolution", "section", "todo_path")) <= set(item)
PY
}

assert_explicit_boundary_json() {
  local expected_code="$1"
  local lexical_path="$2"
  shift 2
  assert_boundary_json "$expected_code" 0 "$@"
  python3 - "$JSON_OUTPUT" "$expected_code" "$lexical_path" <<'PY'
import json, sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
assert data["todo_count"] == 0
assert data["todo_results"] == []
assert len(data["violations"]) == 1
assert [value["code"] for value in data["violations"]] == [sys.argv[2]]
item = data["violations"][0]
assert item["todo_path"] == sys.argv[3]
PY
}

cat > "$ACTIVE/missing-disposition.md" <<'TODO'
# TODO: Missing Disposition

## Delivery Status Canon
- **Current delivery stage:** `Local-Implemented`
- **Qualifiers:** `none`
- **Next exact step:** Move this TODO to completed after validation.

## Active Work State
- **Work state:** `review`
- **Why this state now:** Local implementation is complete and only closeout remains.
- **Exit condition:** The TODO is moved to completed.
TODO

assert_no_go "$ACTIVE/missing-disposition.md"
grep -q "CLOSEOUT-DISPOSITION-MISSING" "$OUTPUT_FILE"

cat > "$ACTIVE/missing-active-work-state.md" <<'TODO'
# TODO: Missing Active Work State

## Delivery Status Canon
- **Current delivery stage:** `Local-Implemented`
- **Qualifiers:** `none`
- **Next exact step:** Move this TODO to completed after validation.

## TODO Closeout Disposition
- **Disposition:** `move-completed`
- **Disposition reason:** Local-only maintenance is complete after validation and commit/push.
- **Post-commit/push status:** `pending`
- **Next path/status action:** Move this TODO to `foundation_documentation/todos/completed/` after push.
TODO

assert_no_go "$ACTIVE/missing-active-work-state.md"
grep -q "ACTIVE-WORK-STATE-MISSING" "$OUTPUT_FILE"

cat > "$ACTIVE/move-completed-pending.md" <<'TODO'
# TODO: Move Completed Pending

## Delivery Status Canon
- **Current delivery stage:** `Local-Implemented`
- **Qualifiers:** `none`
- **Next exact step:** Commit and push this implementation package.

## Active Work State
- **Work state:** `review`
- **Why this state now:** Local implementation is complete and awaits the file move.
- **Exit condition:** Commit/push completes and the TODO moves to completed.

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

## Active Work State
- **Work state:** `review`
- **Why this state now:** Local implementation is complete and only file movement remains.
- **Exit condition:** The TODO is moved to completed.

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

## Active Work State
- **Work state:** `review`
- **Why this state now:** The TODO is waiting on a real review step.
- **Exit condition:** The remaining validation completes.

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

## Active Work State
- **Work state:** `review`
- **Why this state now:** Local implementation is complete and only promotion follow-through remains.
- **Exit condition:** The promotion lane threshold is met.

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

## Active Work State
- **Work state:** `blocked`
- **Why this state now:** External dependency is unavailable.
- **Exit condition:** The dependency becomes available and the TODO can resume.

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
assert data["todo_count"] == 7
assert data["overall_outcome"] == "no-go"
assert any(item["code"] == "CLOSEOUT-DISPOSITION-MISSING" for item in data["violations"])
PY

# Authority-resolution regressions: standalone support and typed fail-closed boundaries.
STANDALONE="$TMP_DIR/standalone"
STANDALONE_ACTIVE="$STANDALONE/todos/active"
mkdir -p "$STANDALONE_ACTIVE"
cp "$ACTIVE/keep-active-promotion.md" "$STANDALONE_ACTIVE/green.md"
python3 "$GUARD" "$STANDALONE_ACTIVE/green.md" --repo "$STANDALONE" > "$OUTPUT_FILE" 2>&1
grep -q "path_state: active" "$OUTPUT_FILE"
python3 "$GUARD" --repo "$STANDALONE" --all-active --json-output "$JSON_OUTPUT" > "$OUTPUT_FILE" 2>&1
python3 - "$JSON_OUTPUT" <<'PY'
import json, sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
assert data["todo_count"] == len(data["todo_results"]) == 1
assert data["overall_outcome"] == "go"
PY

# Standalone explicit/all-active paths must validate every discovered TODO, not only classify it.
cp "$ACTIVE/missing-disposition.md" "$STANDALONE_ACTIVE/invalid.md"
assert_structured_no_go 'CLOSEOUT-DISPOSITION-MISSING' python3 "$GUARD" "$STANDALONE_ACTIVE/invalid.md" --repo "$STANDALONE"
grep -q 'path_state: active' "$OUTPUT_FILE"
set +e
python3 "$GUARD" --repo "$STANDALONE" --all-active --json-output "$JSON_OUTPUT" > "$OUTPUT_FILE" 2>&1
status=$?
set -e
test "$status" -eq 2
python3 - "$JSON_OUTPUT" "$STANDALONE_ACTIVE/green.md" "$STANDALONE_ACTIVE/invalid.md" <<'PY'
import json, sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
assert data["overall_outcome"] == "no-go"
assert data["todo_count"] == len(data["todo_results"]) == 2
contexts = {item["context"]["todo_path"]: item for item in data["todo_results"]}
assert set(contexts) == {sys.argv[2], sys.argv[3]}
assert contexts[sys.argv[2]]["violations"] == []
assert [item["code"] for item in contexts[sys.argv[3]]["violations"]] == ["CLOSEOUT-DISPOSITION-MISSING"]
assert [item["code"] for item in data["violations"]] == ["CLOSEOUT-DISPOSITION-MISSING"]
PY
rm "$STANDALONE_ACTIVE/invalid.md"

OUTSIDE="$TMP_DIR/outside/todos/active/outside.md"
mkdir -p "$(dirname "$OUTSIDE")"
cp "$STANDALONE_ACTIVE/green.md" "$OUTSIDE"
assert_explicit_boundary_json "CLOSEOUT-TODO-OUTSIDE-AUTHORITY" "$OUTSIDE" python3 "$GUARD" "$OUTSIDE" --repo "$STANDALONE"

LEAF_ESCAPE="$STANDALONE_ACTIVE/leaf-escape.md"
ln -s "$OUTSIDE" "$LEAF_ESCAPE"
assert_explicit_boundary_json "CLOSEOUT-TODO-OUTSIDE-AUTHORITY" "$LEAF_ESCAPE" python3 "$GUARD" "$LEAF_ESCAPE" --repo "$STANDALONE"
rm "$LEAF_ESCAPE"

INCOMPLETE="$TMP_DIR/incomplete"
mkdir -p "$INCOMPLETE/todos"
assert_structured_no_go "CLOSEOUT-AUTHORITY-INCOMPLETE" python3 "$GUARD" --repo "$INCOMPLETE" --all-active

AMBIGUOUS="$TMP_DIR/ambiguous"
mkdir -p "$AMBIGUOUS/todos/active" "$AMBIGUOUS/foundation_documentation/todos/active"
assert_structured_no_go "CLOSEOUT-AUTHORITY-AMBIGUOUS" python3 "$GUARD" --repo "$AMBIGUOUS" --all-active

mkdir -p "$STANDALONE/todos/archive/active"
cp "$STANDALONE_ACTIVE/green.md" "$STANDALONE/todos/archive/active/lure.md"
assert_structured_no_go "CLOSEOUT-TODO-LIFECYCLE-UNRECOGNIZED" python3 "$GUARD" "$STANDALONE/todos/archive/active/lure.md" --repo "$STANDALONE"
UNKNOWN_LIFECYCLE_ESCAPE="$STANDALONE/todos/archive/escape.md"
ln -s "$OUTSIDE" "$UNKNOWN_LIFECYCLE_ESCAPE"
assert_explicit_boundary_json "CLOSEOUT-TODO-OUTSIDE-AUTHORITY" "$UNKNOWN_LIFECYCLE_ESCAPE" python3 "$GUARD" "$UNKNOWN_LIFECYCLE_ESCAPE" --repo "$STANDALONE"
rm "$UNKNOWN_LIFECYCLE_ESCAPE"

# Exact explicit-input catalog and valid empty authority behavior.
EMPTY="$TMP_DIR/empty"
mkdir -p "$EMPTY/todos/active"
python3 "$GUARD" --repo "$EMPTY" --all-active --json-output "$JSON_OUTPUT" > "$OUTPUT_FILE" 2>&1
python3 - "$JSON_OUTPUT" <<'PY'
import json, sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
assert data["todo_count"] == 0
assert data["todo_results"] == []
assert data["overall_outcome"] == "go"
PY
for kind in missing directory text; do
  case "$kind" in
    missing) target="$STANDALONE/todos/active/missing.md"; code=CLOSEOUT-TODO-MISSING ;;
    directory) target="$STANDALONE/todos/active"; code=CLOSEOUT-TODO-NOT-FILE ;;
    text) target="$STANDALONE/todos/active/not-markdown.txt"; : > "$target"; code=CLOSEOUT-TODO-NOT-MARKDOWN ;;
  esac
  assert_structured_no_go "$code" python3 "$GUARD" "$target" --repo "$STANDALONE"
done

# Root and leaf aliases: equivalent roots/files deduplicate; escapes fail closed.
EQUIVALENT="$TMP_DIR/equivalent"
mkdir -p "$EQUIVALENT/todos/active" "$EQUIVALENT/foundation_documentation"
cp "$STANDALONE_ACTIVE/green.md" "$EQUIVALENT/todos/active/one.md"
ln -s ../todos "$EQUIVALENT/foundation_documentation/todos"
ln -s one.md "$EQUIVALENT/todos/active/alias.md"
python3 "$GUARD" --repo "$EQUIVALENT" --all-active --json-output "$JSON_OUTPUT" > "$OUTPUT_FILE" 2>&1
python3 - "$JSON_OUTPUT" <<'PY'
import json, sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
assert data["todo_count"] == len(data["todo_results"]) == 1
PY
ln -s "$OUTSIDE" "$EQUIVALENT/todos/active/escape.md"
assert_structured_no_go "CLOSEOUT-TODO-OUTSIDE-AUTHORITY" python3 "$GUARD" --repo "$EQUIVALENT" --all-active

# Root-level violations must retain nullable JSON paths and n/a text rendering.
MISSING_ROOT="$TMP_DIR/missing-root"
assert_boundary_json "CLOSEOUT-AUTHORITY-MISSING" 0 python3 "$GUARD" --repo "$MISSING_ROOT" --all-active
grep -q 'todo_path: n/a' "$OUTPUT_FILE"
python3 - "$JSON_OUTPUT" <<'PY'
import json, sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
assert data["todo_count"] == len(data["todo_results"]) == 0
for item in data["violations"]:
    assert set(("code", "message", "resolution", "section", "todo_path")) <= set(item)
    assert item["todo_path"] is None
PY

# Advisory preserves findings but returns 0; argparse remains native exit 2.
python3 "$GUARD" "$OUTSIDE" --repo "$STANDALONE" --advisory > "$OUTPUT_FILE" 2>&1
grep -q 'Overall outcome: no-go' "$OUTPUT_FILE"
python3 "$GUARD" --help > "$OUTPUT_FILE"
grep -q 'standalone' "$OUTPUT_FILE"
grep -q 'nested' "$OUTPUT_FILE"
python3 - "$GUARD" <<'PY'
import ast, pathlib, sys
module = ast.parse(pathlib.Path(sys.argv[1]).read_text(encoding='utf-8'))
docstring = ast.get_docstring(module) or ''
assert 'foundation_documentation/todos' in docstring
assert 'standalone' in docstring
assert 'fail' in docstring.lower()
PY

# Direct-root and archive/active lure Markdown are never lifecycles.
for root_and_repo in "$STANDALONE/todos:$STANDALONE" "$REPO/foundation_documentation/todos:$REPO"; do
  root="${root_and_repo%%:*}"
  fixture_repo="${root_and_repo#*:}"
  cp "$STANDALONE_ACTIVE/green.md" "$root/direct.md"
  assert_structured_no_go 'CLOSEOUT-TODO-LIFECYCLE-UNRECOGNIZED' python3 "$GUARD" "$root/direct.md" --repo "$fixture_repo"
  mkdir -p "$root/archive/active"
  cp "$STANDALONE_ACTIVE/green.md" "$root/archive/active/lure.md"
  assert_structured_no_go 'CLOSEOUT-TODO-LIFECYCLE-UNRECOGNIZED' python3 "$GUARD" "$root/archive/active/lure.md" --repo "$fixture_repo"
done

# CWD-relative explicit paths preserve their process-relative meaning.
(
  cd "$STANDALONE"
  python3 "$GUARD" todos/active/green.md --repo . > "$OUTPUT_FILE" 2>&1
  grep -q 'path_state: active' "$OUTPUT_FILE"
)
(
  cd "$REPO"
  python3 "$GUARD" foundation_documentation/todos/active/keep-active-promotion.md --repo . > "$OUTPUT_FILE" 2>&1
  grep -q 'path_state: active' "$OUTPUT_FILE"
)

# Lifecycle directories may neither escape nor alias inside an authority.
for lifecycle in active promotion_lane completed; do
  for mode in inside outside; do
    CASE="$TMP_DIR/lifecycle-$lifecycle-$mode"
    mkdir -p "$CASE/todos/active" "$CASE/todos/promotion_lane" "$CASE/todos/completed"
    rm -rf "$CASE/todos/$lifecycle"
    if [[ "$mode" == inside ]]; then
      case "$lifecycle" in
        active) target_lifecycle=completed ;;
        promotion_lane) target_lifecycle=active ;;
        completed) target_lifecycle=active ;;
      esac
      cp "$STANDALONE_ACTIVE/green.md" "$CASE/todos/$target_lifecycle/probe.md"
      ln -s "$CASE/todos/$target_lifecycle" "$CASE/todos/$lifecycle"
    else
      cp "$STANDALONE_ACTIVE/green.md" "$TMP_DIR/outside/probe.md"
      ln -s "$TMP_DIR/outside" "$CASE/todos/$lifecycle"
    fi
    if [[ "$lifecycle" == active ]]; then target="$CASE/todos/active/probe.md"; else target="$CASE/todos/$lifecycle/probe.md"; fi
    if [[ "$mode" == inside ]]; then
      assert_boundary_json 'CLOSEOUT-LIFECYCLE-DIRECTORY-SYMLINK' 0 python3 "$GUARD" "$target" --repo "$CASE"
      expected_code='CLOSEOUT-LIFECYCLE-DIRECTORY-SYMLINK'
    else
      assert_boundary_json 'CLOSEOUT-LIFECYCLE-DIRECTORY-ESCAPE' 0 python3 "$GUARD" "$target" --repo "$CASE"
      expected_code='CLOSEOUT-LIFECYCLE-DIRECTORY-ESCAPE'
    fi
    python3 - "$JSON_OUTPUT" "$expected_code" "$CASE/todos/$lifecycle" <<'PY'
import json, sys
data=json.load(open(sys.argv[1], encoding='utf-8'))
item=next(v for v in data['violations'] if v['code'] == sys.argv[2])
assert item['todo_path'] == sys.argv[3]
PY
  done
done
ACTIVE_ALIAS="$TMP_DIR/active-alias"
mkdir -p "$ACTIVE_ALIAS/todos/completed"
ln -s "$ACTIVE_ALIAS/todos/completed" "$ACTIVE_ALIAS/todos/active"
assert_boundary_json 'CLOSEOUT-LIFECYCLE-DIRECTORY-SYMLINK' 0 python3 "$GUARD" --repo "$ACTIVE_ALIAS" --all-active
python3 - "$JSON_OUTPUT" "$ACTIVE_ALIAS/todos/active" <<'PY'
import json, sys
data=json.load(open(sys.argv[1], encoding='utf-8'))
assert next(v for v in data['violations'] if v['code'] == 'CLOSEOUT-LIFECYCLE-DIRECTORY-SYMLINK')['todo_path'] == sys.argv[2]
PY

ACTIVE_EXTERNAL="$TMP_DIR/active-external"
mkdir -p "$ACTIVE_EXTERNAL/todos" "$TMP_DIR/external-active"
ln -s "$TMP_DIR/external-active" "$ACTIVE_EXTERNAL/todos/active"
assert_boundary_json 'CLOSEOUT-LIFECYCLE-DIRECTORY-ESCAPE' 0 python3 "$GUARD" --repo "$ACTIVE_EXTERNAL" --all-active
python3 - "$JSON_OUTPUT" "$ACTIVE_EXTERNAL/todos/active" <<'PY'
import json, sys
data=json.load(open(sys.argv[1], encoding='utf-8'))
assert next(v for v in data['violations'] if v['code'] == 'CLOSEOUT-LIFECYCLE-DIRECTORY-ESCAPE')['todo_path'] == sys.argv[2]
PY

# Each directed lifecycle file alias must be rejected; same-lifecycle aliases deduplicate.
CROSS="$TMP_DIR/cross"
mkdir -p "$CROSS/todos/active" "$CROSS/todos/promotion_lane" "$CROSS/todos/completed"
for lifecycle in active promotion_lane completed; do cp "$STANDALONE_ACTIVE/green.md" "$CROSS/todos/$lifecycle/$lifecycle.md"; ln -s "$lifecycle.md" "$CROSS/todos/$lifecycle/$lifecycle-alias.md"; done
python3 "$GUARD" --repo "$CROSS" --all-active --json-output "$JSON_OUTPUT" > "$OUTPUT_FILE" 2>&1
python3 - "$JSON_OUTPUT" <<'PY'
import json, sys
data=json.load(open(sys.argv[1], encoding='utf-8'))
assert data['todo_count'] == len(data['todo_results']) == 1
PY
for source in active promotion_lane completed; do
  for target in active promotion_lane completed; do
    [[ "$source" == "$target" ]] && continue
    ln -s "../$target/$target.md" "$CROSS/todos/$source/to-$target.md"
    alias_path="$CROSS/todos/$source/to-$target.md"
    assert_explicit_boundary_json 'CLOSEOUT-TODO-LIFECYCLE-ESCAPE' "$alias_path" python3 "$GUARD" "$alias_path" --repo "$CROSS"
    rm "$CROSS/todos/$source/to-$target.md"
  done
done
for lifecycle in promotion_lane completed; do
  python3 "$GUARD" "$CROSS/todos/$lifecycle/$lifecycle-alias.md" --repo "$CROSS" > "$OUTPUT_FILE" 2>&1
  grep -q "path_state: $lifecycle" "$OUTPUT_FILE"
done

# A directory named .md is rejected rather than loaded or silently ignored.
mkdir -p "$CROSS/todos/active/directory.md"
assert_boundary_json 'CLOSEOUT-TODO-NOT-FILE' 1 python3 "$GUARD" --repo "$CROSS" --all-active
python3 - "$JSON_OUTPUT" "$CROSS/todos/active/directory.md" <<'PY'
import json, sys
data = json.load(open(sys.argv[1], encoding='utf-8'))
assert data['violations'][0]['todo_path'] == sys.argv[2]
PY
rmdir "$CROSS/todos/active/directory.md"

# Repo symlink, runtime output failure, exact argparse/governance exits, and Git context.
ln -s "$STANDALONE" "$TMP_DIR/repo-link"
python3 "$GUARD" --repo "$TMP_DIR/repo-link" --all-active > "$OUTPUT_FILE" 2>&1
mkdir -p "$TMP_DIR/json-directory"
set +e
python3 "$GUARD" --repo "$STANDALONE" --all-active --json-output "$TMP_DIR/json-directory" > "$OUTPUT_FILE" 2>&1
status=$?
set -e
test "$status" -eq 1
grep -q 'TODO Closeout Guard runtime error: unable to write JSON output:' "$OUTPUT_FILE"
! grep -q 'Traceback' "$OUTPUT_FILE"
set +e
python3 "$GUARD" --repo "$STANDALONE" > "$OUTPUT_FILE" 2>&1
status=$?
set -e
test "$status" -eq 2
GIT_REPO="$TMP_DIR/git-repo"
mkdir -p "$GIT_REPO/todos/active"
cp "$STANDALONE_ACTIVE/green.md" "$GIT_REPO/todos/active/green.md"
git -C "$GIT_REPO" init -q
git -C "$GIT_REPO" add .
git -C "$GIT_REPO" -c user.name=fixture -c user.email=fixture@example.invalid commit -qm fixture
python3 "$GUARD" --repo "$GIT_REPO" --all-active --json-output "$JSON_OUTPUT" > "$OUTPUT_FILE" 2>&1
python3 - "$JSON_OUTPUT" "$GIT_REPO" <<'PY'
import json, pathlib, sys
data=json.load(open(sys.argv[1], encoding='utf-8'))
assert data['git']['available'] is True
assert pathlib.Path(data['git']['root']).resolve() == pathlib.Path(sys.argv[2]).resolve()
assert isinstance(data['git']['clean'], bool)
PY

# Symlinked repo resolves to its canonical Git worktree.
ln -s "$GIT_REPO" "$TMP_DIR/git-repo-link"
python3 "$GUARD" --repo "$TMP_DIR/git-repo-link" --all-active --json-output "$JSON_OUTPUT" > "$OUTPUT_FILE" 2>&1
python3 - "$JSON_OUTPUT" "$GIT_REPO" <<'PY'
import json, pathlib, sys
data=json.load(open(sys.argv[1], encoding='utf-8'))
assert data['todo_count'] == len(data['todo_results']) == 1
assert pathlib.Path(data['git']['root']).resolve() == pathlib.Path(sys.argv[2]).resolve()
PY

# Mixed discovery keeps the one valid TODO but reports an escaped alias.
MIXED="$TMP_DIR/mixed"
mkdir -p "$MIXED/todos/active"
cp "$STANDALONE_ACTIVE/green.md" "$MIXED/todos/active/valid.md"
ln -s "$OUTSIDE" "$MIXED/todos/active/escaped.md"
set +e
python3 "$GUARD" --repo "$MIXED" --all-active --json-output "$JSON_OUTPUT" > "$OUTPUT_FILE" 2>&1
status=$?
set -e
test "$status" -eq 2
python3 - "$JSON_OUTPUT" <<'PY'
import json, sys
data=json.load(open(sys.argv[1], encoding='utf-8'))
assert data['todo_count'] == len(data['todo_results']) == 1
assert data['overall_outcome'] == 'no-go'
item=next(v for v in data['violations'] if v['code'] == 'CLOSEOUT-TODO-OUTSIDE-AUTHORITY')
assert set(('code','message','resolution','section','todo_path')) <= set(item)
assert item['todo_path']
PY

# Exact no-go, argparse, advisory, and unexpected JSON-write exits.
set +e
python3 "$GUARD" "$OUTSIDE" --repo "$STANDALONE" > "$OUTPUT_FILE" 2>&1; status=$?
set -e
test "$status" -eq 2
set +e
python3 "$GUARD" --repo "$STANDALONE" > "$OUTPUT_FILE" 2>&1; status=$?
set -e
test "$status" -eq 2
python3 "$GUARD" "$OUTSIDE" --repo "$STANDALONE" --advisory > "$OUTPUT_FILE" 2>&1
grep -q 'Overall outcome: no-go' "$OUTPUT_FILE"
set +e
python3 "$GUARD" --repo "$STANDALONE" --all-active --json-output "$TMP_DIR/json-directory" > "$OUTPUT_FILE" 2>&1; status=$?
set -e
test "$status" -eq 1

# Before/after tree, mode, content, and link-target digest proves nonmutation.
snapshot_tree() {
  find "$1" -mindepth 1 -printf '%P %m %y\n' | sort | while IFS= read -r entry; do
    path="${entry%% *}"
    printf '%s\n' "$entry"
    [[ -f "$1/$path" ]] && sha256sum "$1/$path"
    [[ -L "$1/$path" ]] && readlink "$1/$path"
    true
  done | sha256sum
}
before="$(snapshot_tree "$GIT_REPO")"
python3 "$GUARD" --repo "$GIT_REPO" --all-active > "$OUTPUT_FILE" 2>&1
after="$(snapshot_tree "$GIT_REPO")"
test "$before" = "$after"

# Symlink-spelled explicit paths remain compatible with symlinked --repo.
python3 "$GUARD" "$TMP_DIR/git-repo-link/todos/active/green.md" --repo "$TMP_DIR/git-repo-link" > "$OUTPUT_FILE" 2>&1
grep -q 'Overall outcome: go' "$OUTPUT_FILE"
grep -q 'path_state: active' "$OUTPUT_FILE"

# Traversal spelling must not escape a lexical authority alias.
TRAVERSAL="$STANDALONE/todos/active/../../../outside/todos/active/outside.md"
assert_explicit_boundary_json 'CLOSEOUT-TODO-OUTSIDE-AUTHORITY' "$TRAVERSAL" python3 "$GUARD" "$TRAVERSAL" --repo "$STANDALONE"

# Root-state catalog is identical for explicit and all-active modes.
for mode in explicit all; do
  for state in missing incomplete ambiguous; do
    case "$state" in
      missing) state_repo="$TMP_DIR/catalog-missing"; code=CLOSEOUT-AUTHORITY-MISSING; mkdir -p "$state_repo" ;;
      incomplete) state_repo="$TMP_DIR/catalog-incomplete"; code=CLOSEOUT-AUTHORITY-INCOMPLETE; mkdir -p "$state_repo/todos" ;;
      ambiguous) state_repo="$TMP_DIR/catalog-ambiguous"; code=CLOSEOUT-AUTHORITY-AMBIGUOUS; mkdir -p "$state_repo/todos/active" "$state_repo/foundation_documentation/todos/active" ;;
    esac
    if [[ "$mode" == all ]]; then
      assert_boundary_json "$code" 0 python3 "$GUARD" --repo "$state_repo" --all-active
    else
      assert_boundary_json "$code" 0 python3 "$GUARD" "$state_repo/claimed.md" --repo "$state_repo"
    fi
  done
done

# Authority roots and discovered aliases cannot escape the selected repository.
AUTHORITY_ESCAPE="$TMP_DIR/authority-escape"
mkdir -p "$AUTHORITY_ESCAPE" "$TMP_DIR/external-authority/active"
ln -s "$TMP_DIR/external-authority" "$AUTHORITY_ESCAPE/todos"
for mode in explicit all; do
  if [[ "$mode" == explicit ]]; then
    assert_boundary_json 'CLOSEOUT-AUTHORITY-OUTSIDE-REPOSITORY' 0 python3 "$GUARD" "$AUTHORITY_ESCAPE/todos/active/missing.md" --repo "$AUTHORITY_ESCAPE"
  else
    assert_boundary_json 'CLOSEOUT-AUTHORITY-OUTSIDE-REPOSITORY' 0 python3 "$GUARD" --repo "$AUTHORITY_ESCAPE" --all-active
  fi
  python3 - "$JSON_OUTPUT" "$AUTHORITY_ESCAPE/todos" <<'PY'
import json, sys
data=json.load(open(sys.argv[1], encoding='utf-8'))
item=next(v for v in data['violations'] if v['code'] == 'CLOSEOUT-AUTHORITY-OUTSIDE-REPOSITORY')
assert item['todo_path'] == sys.argv[2]
PY
done

# Broken/escaping active aliases are boundary violations, not silently skipped.
BROKEN="$TMP_DIR/broken-alias"
mkdir -p "$BROKEN/todos/active"
ln -s "$TMP_DIR/nonexistent-outside.md" "$BROKEN/todos/active/broken.md"
assert_boundary_json 'CLOSEOUT-TODO-OUTSIDE-AUTHORITY' 0 python3 "$GUARD" --repo "$BROKEN" --all-active
python3 - "$JSON_OUTPUT" "$BROKEN/todos/active/broken.md" <<'PY'
import json, sys
data=json.load(open(sys.argv[1], encoding='utf-8'))
assert next(v for v in data['violations'] if v['code'] == 'CLOSEOUT-TODO-OUTSIDE-AUTHORITY')['todo_path'] == sys.argv[2]
PY

# In-authority broken leaves and directory targets remain structured no-go.
BROKEN_INTERNAL="$TMP_DIR/broken-internal"
mkdir -p "$BROKEN_INTERNAL/todos/active"
ln -s missing.md "$BROKEN_INTERNAL/todos/active/broken.md"
assert_boundary_json 'CLOSEOUT-TODO-MISSING' 0 python3 "$GUARD" --repo "$BROKEN_INTERNAL" --all-active
python3 - "$JSON_OUTPUT" "$BROKEN_INTERNAL/todos/active/broken.md" <<'PY'
import json, sys
data=json.load(open(sys.argv[1], encoding='utf-8'))
assert next(v for v in data['violations'] if v['code'] == 'CLOSEOUT-TODO-MISSING')['todo_path'] == sys.argv[2]
PY
DIRECTORY_TARGET="$TMP_DIR/directory-target"
mkdir -p "$DIRECTORY_TARGET/todos/active" "$DIRECTORY_TARGET/todos/active/real-directory"
ln -s real-directory "$DIRECTORY_TARGET/todos/active/directory-link.md"
assert_boundary_json 'CLOSEOUT-TODO-NOT-FILE' 0 python3 "$GUARD" --repo "$DIRECTORY_TARGET" --all-active
python3 - "$JSON_OUTPUT" "$DIRECTORY_TARGET/todos/active/directory-link.md" <<'PY'
import json, sys
data=json.load(open(sys.argv[1], encoding='utf-8'))
assert next(v for v in data['violations'] if v['code'] == 'CLOSEOUT-TODO-NOT-FILE')['todo_path'] == sys.argv[2]
PY

# A lifecycle directory violation precedes missing leaf validation.
MISSING_LEAF="$TMP_DIR/missing-leaf"
mkdir -p "$MISSING_LEAF/todos/completed"
ln -s "$MISSING_LEAF/todos/completed" "$MISSING_LEAF/todos/active"
assert_explicit_boundary_json 'CLOSEOUT-LIFECYCLE-DIRECTORY-SYMLINK' "$MISSING_LEAF/todos/active" python3 "$GUARD" "$MISSING_LEAF/todos/active/missing.md" --repo "$MISSING_LEAF"

# Active discovery rejects aliases into each other lifecycle.
ACTIVE_CROSS="$TMP_DIR/active-cross"
mkdir -p "$ACTIVE_CROSS/todos/active" "$ACTIVE_CROSS/todos/promotion_lane" "$ACTIVE_CROSS/todos/completed"
for target in promotion_lane completed; do
  cp "$STANDALONE_ACTIVE/green.md" "$ACTIVE_CROSS/todos/$target/target.md"
  alias_path="$ACTIVE_CROSS/todos/active/to-$target.md"
  ln -s "../$target/target.md" "$alias_path"
  assert_boundary_json 'CLOSEOUT-TODO-LIFECYCLE-ESCAPE' 0 python3 "$GUARD" --repo "$ACTIVE_CROSS" --all-active
  python3 - "$JSON_OUTPUT" "$alias_path" <<'PY'
import json, sys
data=json.load(open(sys.argv[1], encoding='utf-8'))
assert next(v for v in data['violations'] if v['code'] == 'CLOSEOUT-TODO-LIFECYCLE-ESCAPE')['todo_path'] == sys.argv[2]
PY
  rm "$alias_path"
done

# Cyclic repository and lifecycle links remain structured no-go without hang.
REPO_CYCLE="$TMP_DIR/repo-cycle"
ln -s repo-cycle "$REPO_CYCLE"
assert_boundary_json 'CLOSEOUT-REPOSITORY-UNRESOLVABLE' 0 timeout 5 python3 "$GUARD" --repo "$REPO_CYCLE" --all-active
python3 - "$JSON_OUTPUT" "$REPO_CYCLE" <<'PY'
import json, sys
data=json.load(open(sys.argv[1], encoding='utf-8'))
assert data['violations'][0]['todo_path'] == sys.argv[2]
PY
CYCLE_LIFECYCLE="$TMP_DIR/cycle-lifecycle"
mkdir -p "$CYCLE_LIFECYCLE/todos/active"
ln -s promotion_lane "$CYCLE_LIFECYCLE/todos/promotion_lane"
assert_explicit_boundary_json 'CLOSEOUT-LIFECYCLE-DIRECTORY-SYMLINK' "$CYCLE_LIFECYCLE/todos/promotion_lane" timeout 5 python3 "$GUARD" "$CYCLE_LIFECYCLE/todos/promotion_lane/missing.md" --repo "$CYCLE_LIFECYCLE"

# Broken authority roots, nonregular discovery nodes, and punctuated disposition.
AUTHORITY_BROKEN_EXTERNAL="$TMP_DIR/authority-broken-external"
mkdir -p "$AUTHORITY_BROKEN_EXTERNAL"
ln -s "$TMP_DIR/missing-external-authority" "$AUTHORITY_BROKEN_EXTERNAL/todos"
assert_boundary_json 'CLOSEOUT-AUTHORITY-OUTSIDE-REPOSITORY' 0 timeout 5 python3 "$GUARD" --repo "$AUTHORITY_BROKEN_EXTERNAL" --all-active
AUTHORITY_BROKEN_INTERNAL="$TMP_DIR/authority-broken-internal"
mkdir -p "$AUTHORITY_BROKEN_INTERNAL"
ln -s "$AUTHORITY_BROKEN_INTERNAL/missing-authority" "$AUTHORITY_BROKEN_INTERNAL/todos"
assert_boundary_json 'CLOSEOUT-AUTHORITY-INCOMPLETE' 0 timeout 5 python3 "$GUARD" --repo "$AUTHORITY_BROKEN_INTERNAL" --all-active
NONREGULAR="$TMP_DIR/nonregular"
mkdir -p "$NONREGULAR/todos/active"
mkfifo "$NONREGULAR/todos/active/pipe.md"
assert_explicit_boundary_json 'CLOSEOUT-TODO-NOT-FILE' "$NONREGULAR/todos/active/pipe.md" timeout 5 python3 "$GUARD" --repo "$NONREGULAR" --all-active
rm "$NONREGULAR/todos/active/pipe.md"
python3 - "$NONREGULAR/todos/active/socket.md" <<'PY'
import socket, sys
node = socket.socket(socket.AF_UNIX)
node.bind(sys.argv[1])
node.close()
PY
assert_explicit_boundary_json 'CLOSEOUT-TODO-NOT-FILE' "$NONREGULAR/todos/active/socket.md" timeout 5 python3 "$GUARD" --repo "$NONREGULAR" --all-active
rm "$NONREGULAR/todos/active/socket.md"
UNREADABLE="$TMP_DIR/unreadable"
mkdir -p "$UNREADABLE/todos/active/locked"
cp "$ACTIVE/missing-disposition.md" "$UNREADABLE/todos/active/locked/hidden.md"
chmod 000 "$UNREADABLE/todos/active/locked"
assert_explicit_boundary_json 'CLOSEOUT-DISCOVERY-UNREADABLE' "$UNREADABLE/todos/active/locked" timeout 5 python3 "$GUARD" --repo "$UNREADABLE" --all-active
chmod 700 "$UNREADABLE/todos/active/locked"
UNREADABLE_LEAF="$TMP_DIR/unreadable-leaf"
mkdir -p "$UNREADABLE_LEAF/todos/active"
cp "$ACTIVE/missing-disposition.md" "$UNREADABLE_LEAF/todos/active/unreadable.md"
chmod 000 "$UNREADABLE_LEAF/todos/active/unreadable.md"
assert_explicit_boundary_json 'CLOSEOUT-DISCOVERY-UNREADABLE' "$UNREADABLE_LEAF/todos/active/unreadable.md" timeout 5 python3 "$GUARD" --repo "$UNREADABLE_LEAF" --all-active
cp "$STANDALONE_ACTIVE/green.md" "$UNREADABLE_LEAF/todos/active/readable.md"
assert_boundary_json 'CLOSEOUT-DISCOVERY-UNREADABLE' 1 timeout 5 python3 "$GUARD" --repo "$UNREADABLE_LEAF" --all-active
python3 - "$JSON_OUTPUT" "$UNREADABLE_LEAF/todos/active/unreadable.md" "$UNREADABLE_LEAF/todos/active/readable.md" <<'PY'
import json, sys
data = json.load(open(sys.argv[1], encoding='utf-8'))
assert data['violations'][0]['todo_path'] == sys.argv[2]
assert data['todo_results'][0]['context']['todo_path'] == sys.argv[3]
PY
chmod 600 "$UNREADABLE_LEAF/todos/active/unreadable.md"
PUNCTUATED="$TMP_DIR/punctuated"
mkdir -p "$PUNCTUATED/todos/active"
cp "$STANDALONE_ACTIVE/green.md" "$PUNCTUATED/todos/active/punctuated.md"
sed -i 's/`keep-active`/`keep-active.`/' "$PUNCTUATED/todos/active/punctuated.md"
set +e
python3 "$GUARD" "$PUNCTUATED/todos/active/punctuated.md" --repo "$PUNCTUATED" --json-output "$JSON_OUTPUT" > "$OUTPUT_FILE" 2>&1
status=$?
set -e
test "$status" -eq 2
grep -q 'Overall outcome: no-go' "$OUTPUT_FILE"
grep -q 'CLOSEOUT-DISPOSITION-INVALID' "$OUTPUT_FILE"
! grep -q 'Traceback' "$OUTPUT_FILE"
python3 - "$JSON_OUTPUT" <<'PY'
import json, sys
data=json.load(open(sys.argv[1], encoding='utf-8'))
assert data['overall_outcome'] == 'no-go'
assert data['todo_count'] == len(data['todo_results']) == 1
assert data['todo_results'][0]['context']['disposition'] == 'keep-active.'
assert [item['code'] for item in data['violations']] == ['CLOSEOUT-DISPOSITION-INVALID']
PY

# Cyclic discovery, explicit external breakage, and absent non-active lifecycles are typed.
CYCLE="$TMP_DIR/cycle"
mkdir -p "$CYCLE/todos/active"
ln -s loop.md "$CYCLE/todos/active/loop.md"
assert_explicit_boundary_json 'CLOSEOUT-TODO-MISSING' "$CYCLE/todos/active/loop.md" timeout 5 python3 "$GUARD" --repo "$CYCLE" --all-active
EXTERNAL_BROKEN="$STANDALONE_ACTIVE/external-broken.md"
ln -s "$TMP_DIR/missing-external.md" "$EXTERNAL_BROKEN"
assert_explicit_boundary_json 'CLOSEOUT-TODO-OUTSIDE-AUTHORITY' "$EXTERNAL_BROKEN" timeout 5 python3 "$GUARD" "$EXTERNAL_BROKEN" --repo "$STANDALONE"
rm "$EXTERNAL_BROKEN"
MISSING_LIFECYCLE="$TMP_DIR/missing-lifecycle"
mkdir -p "$MISSING_LIFECYCLE/todos/active"
for lifecycle in promotion_lane completed; do
  missing_path="$MISSING_LIFECYCLE/todos/$lifecycle/missing.md"
  assert_explicit_boundary_json 'CLOSEOUT-TODO-MISSING' "$missing_path" python3 "$GUARD" "$missing_path" --repo "$MISSING_LIFECYCLE"
done

printf 'todo_closeout_guard_test: OK\n'
