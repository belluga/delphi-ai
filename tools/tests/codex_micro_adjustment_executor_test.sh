#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

ROUTE_JSON="$TMP_DIR/route.json"
python3 "$ROOT_DIR/tools/codex_micro_adjustment_routing.py" \
  --client codex --surface implementation --role routine-executor \
  --json-output "$ROUTE_JSON" >/dev/null

python3 - "$ROUTE_JSON" <<'PY'
import json
import sys

payload = json.load(open(sys.argv[1], encoding="utf-8"))
assert payload["authority"] == "config/agent_role_routing.json"
assert payload["model_family"] == "routine_executor"
assert payload["provider_fallback"] == "prohibited"
assert payload["model_aliases"]
assert payload["effort_aliases"] == ["medium"]
PY

RAW_ROOT="$ROOT_DIR/artifacts/tmp/todo-execution/p2-test/session-1"
python3 "$ROOT_DIR/tools/codex_micro_adjustment_teach.py" \
  --todo "$ROOT_DIR/foundation_documentation/todos/active/delphi-cross-stack-todo-agent-orchestration-contract.md" \
  --changed-path tools/codex_micro_adjustment_routing.py \
  --writer-role routine-executor \
  --provider-fallback prohibited \
  --runtime-introspection prohibited \
  --schema-migration prohibited \
  --raw-artifact-root "$RAW_ROOT" \
  --token-total unavailable >/dev/null

if python3 "$ROOT_DIR/tools/codex_micro_adjustment_teach.py" \
  --todo "$ROOT_DIR/foundation_documentation/todos/active/delphi-cross-stack-todo-agent-orchestration-contract.md" \
  --changed-path tools/codex_micro_adjustment_routing.py \
  --writer-role primary-chat \
  --provider-fallback allowed \
  --runtime-introspection prohibited \
  --schema-migration prohibited \
  --raw-artifact-root "$RAW_ROOT" \
  --token-total unavailable >/dev/null 2>&1; then
  echo "expected bounded assessment to block" >&2
  exit 1
fi

printf 'codex_micro_adjustment_executor_test: OK\n'
