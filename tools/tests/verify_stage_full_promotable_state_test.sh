#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -L)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../../.." && pwd -P)"
SCRIPT="$ROOT_DIR/delphi-ai/tools/verify_stage_full_promotable_state.sh"
TODO_PATH="$ROOT_DIR/foundation_documentation/todos/active/v0.4.0/TODO-v0.4.0-release-package.md"
OUTPUT_PATH="$(mktemp)"
trap 'rm -f "$OUTPUT_PATH"' EXIT

mkdir -p "$(dirname "$TODO_PATH")"
touch "$TODO_PATH"

SCRIPT_UNDER_TEST=1 source "$SCRIPT"

governing_todo="$(detect_governing_todo "v0.4.0-rc")"
expected_todo="$TODO_PATH"
[[ "$governing_todo" == "$expected_todo" ]]

related_todo="$(detect_related_governing_todo_for_non_authoritative_branch "v0.4.0-root-harness-replay")"
[[ "$related_todo" == "$expected_todo" ]]

if detect_related_governing_todo_for_non_authoritative_branch "dev" >/dev/null 2>&1; then
  echo "Expected dev to remain outside non-authoritative package-governed detection." >&2
  exit 1
fi

emit_non_authoritative_branch_teach "v0.4.0-root-harness-replay" "$expected_todo" >"$OUTPUT_PATH"
grep -Fq 'TEACH runtime response' "$OUTPUT_PATH"
grep -Fq 'enforcement: stop_before_stage_full' "$OUTPUT_PATH"
grep -Fq 'Overall outcome: no-go' "$OUTPUT_PATH"
grep -Fq 'root_branch: v0.4.0-root-harness-replay' "$OUTPUT_PATH"

printf 'verify_stage_full_promotable_state_test: OK\n'
