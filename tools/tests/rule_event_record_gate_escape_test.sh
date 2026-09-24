#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOL="$ROOT_DIR/tools/rule_event_record.py"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

EVENTS="$TMP_DIR/rule-events.jsonl"
TODO_FILE="$TMP_DIR/foundation_documentation/todos/active/sample.md"
mkdir -p "$(dirname "$TODO_FILE")"
printf '# TODO: Sample\n' > "$TODO_FILE"

python3 "$TOOL" \
  --events-jsonl "$EVENTS" \
  gate-escape \
  --gate pipeline-p1-p2 \
  --todo-path "$TODO_FILE" \
  --summary "CI found a P1 that local preflight missed" \
  --source-kind ci \
  --source-ref "github/actions/run/1"

test -s "$EVENTS"
grep -q '"event_kind": "rule_escape_recorded"' "$EVENTS"
grep -q '"rule_id": "paced.gate.pipeline-p1-p2-preflight"' "$EVENTS"
grep -q '"source_kind": "ci"' "$EVENTS"

printf 'rule_event_record_gate_escape_test: OK\n'
