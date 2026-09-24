#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOL="$ROOT_DIR/tools/session_hook_guard.py"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

REPO="$TMP_DIR/repo"
mkdir -p "$REPO"
cp -R "$ROOT_DIR"/. "$REPO/"

STATE_PATH="$REPO/artifacts/tmp/session-runtime-state.json"

run_hook() {
  local event="$1"
  local payload="$2"
  local output="$3"
  printf '%s' "$payload" | python3 "$TOOL" --client claude-code --event "$event" --repo-root "$REPO" >"$output"
}

assert_json_contains() {
  local file="$1"
  local pattern="$2"
  grep -q "$pattern" "$file"
}

SESSION_START_PAYLOAD='{"session_id":"sess-1","cwd":"'"$REPO"'","hook_event_name":"SessionStart"}'
SESSION_OUT="$TMP_DIR/session-start.json"
run_hook "SessionStart" "$SESSION_START_PAYLOAD" "$SESSION_OUT"
assert_json_contains "$SESSION_OUT" '"hookEventName": "SessionStart"'
assert_json_contains "$SESSION_OUT" 'Delphi hook governance active'
test -f "$STATE_PATH"

PRE_EDIT_DENY="$TMP_DIR/pre-edit-deny.json"
run_hook \
  "PreToolUse" \
  '{"session_id":"sess-1","cwd":"'"$REPO"'","hook_event_name":"PreToolUse","tool_name":"Write","tool_input":{"file_path":"'"$REPO"'/.claude/settings.json","content":"{}"}}' \
  "$PRE_EDIT_DENY"
assert_json_contains "$PRE_EDIT_DENY" '"permissionDecision": "deny"'
assert_json_contains "$PRE_EDIT_DENY" 'main_instructions.md'

for logical in \
  "main_instructions.md" \
  "workflows/docker/profile-selection-method.md" \
  "workflows/docker/session-lifecycle-method.md" \
  "workflows/docker/self-improvement-session-method.md" \
  "config/hook_governance.json"; do
  READ_OUT="$TMP_DIR/read-$(basename "$logical").json"
  run_hook \
    "PostToolUse" \
    '{"session_id":"sess-1","cwd":"'"$REPO"'","hook_event_name":"PostToolUse","tool_name":"Read","tool_input":{"file_path":"'"$REPO"'/'"$logical"'"},"tool_response":"ok"}' \
    "$READ_OUT"
done

PRE_EDIT_ALLOW="$TMP_DIR/pre-edit-allow.json"
run_hook \
  "PreToolUse" \
  '{"session_id":"sess-1","cwd":"'"$REPO"'","hook_event_name":"PreToolUse","tool_name":"Write","tool_input":{"file_path":"'"$REPO"'/.claude/settings.json","content":"{}"}}' \
  "$PRE_EDIT_ALLOW"
test ! -s "$PRE_EDIT_ALLOW"

POST_EDIT_OUT="$TMP_DIR/post-edit.json"
run_hook \
  "PostToolUse" \
  '{"session_id":"sess-1","cwd":"'"$REPO"'","hook_event_name":"PostToolUse","tool_name":"Write","tool_input":{"file_path":"'"$REPO"'/.claude/settings.json","content":"{}"},"tool_response":{"filePath":"'"$REPO"'/.claude/settings.json","success":true}}' \
  "$POST_EDIT_OUT"

PRE_COMMIT_DENY="$TMP_DIR/pre-commit-deny.json"
run_hook \
  "PreToolUse" \
  '{"session_id":"sess-1","cwd":"'"$REPO"'","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m test"}}' \
  "$PRE_COMMIT_DENY"
assert_json_contains "$PRE_COMMIT_DENY" '"permissionDecision": "deny"'
assert_json_contains "$PRE_COMMIT_DENY" 'self_check'
assert_json_contains "$PRE_COMMIT_DENY" 'tool_tests'

run_hook \
  "PostToolUse" \
  '{"session_id":"sess-1","cwd":"'"$REPO"'","hook_event_name":"PostToolUse","tool_name":"Bash","tool_input":{"command":"bash tools/self_check.sh"},"tool_response":{"stdout":"","stderr":"","interrupted":false,"isImage":false}}' \
  "$TMP_DIR/post-self-check.json"
run_hook \
  "PostToolUse" \
  '{"session_id":"sess-1","cwd":"'"$REPO"'","hook_event_name":"PostToolUse","tool_name":"Bash","tool_input":{"command":"git diff --check"},"tool_response":{"stdout":"","stderr":"","interrupted":false,"isImage":false}}' \
  "$TMP_DIR/post-diff-check.json"
run_hook \
  "PostToolUse" \
  '{"session_id":"sess-1","cwd":"'"$REPO"'","hook_event_name":"PostToolUse","tool_name":"Bash","tool_input":{"command":"bash tools/tests/session_hook_guard_test.sh"},"tool_response":{"stdout":"","stderr":"","interrupted":false,"isImage":false}}' \
  "$TMP_DIR/post-tool-tests.json"

PRE_COMMIT_ALLOW="$TMP_DIR/pre-commit-allow.json"
run_hook \
  "PreToolUse" \
  '{"session_id":"sess-1","cwd":"'"$REPO"'","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git commit -m test"}}' \
  "$PRE_COMMIT_ALLOW"
test ! -s "$PRE_COMMIT_ALLOW"

CONFIG_BLOCK_OUT="$TMP_DIR/config-block.json"
BROKEN_SETTINGS="$REPO/.claude/settings.json"
cp "$BROKEN_SETTINGS" "$TMP_DIR/settings.backup.json"
python3 - "$BROKEN_SETTINGS" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
payload = json.loads(path.read_text(encoding="utf-8"))
payload["hooks"].pop("PreToolUse", None)
path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
PY
run_hook \
  "ConfigChange" \
  '{"session_id":"sess-1","cwd":"'"$REPO"'","hook_event_name":"ConfigChange","source":"project_settings","file_path":"'"$REPO"'/.claude/settings.json"}' \
  "$CONFIG_BLOCK_OUT"
assert_json_contains "$CONFIG_BLOCK_OUT" '"decision": "block"'
assert_json_contains "$CONFIG_BLOCK_OUT" 'PreToolUse'
mv "$TMP_DIR/settings.backup.json" "$BROKEN_SETTINGS"

printf 'session_hook_guard_test: OK\n'
