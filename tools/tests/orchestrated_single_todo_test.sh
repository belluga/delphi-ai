#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

ROUTE_JSON="$TMP_DIR/route.json"
python3 "$ROOT_DIR/tools/orchestrated_single_todo_routing.py" \
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

RAW_ROOT="$ROOT_DIR/artifacts/tmp/todo-execution/single-todo-test/session-1"
python3 "$ROOT_DIR/tools/orchestrated_single_todo_teach.py" \
  --todo "$ROOT_DIR/foundation_documentation/todos/active/delphi-cross-stack-todo-agent-orchestration-contract.md" \
  --baseline v0.6.2-rc@634b546 \
  --approval-gate approved \
  --authority-gate canonical \
  --primary-goal-state active \
  --primary-goal-report 'active:primary-goal-1' \
  --changed-path tools/orchestrated_single_todo_routing.py \
  --expected-path foundation_documentation/todos/active/delphi-cross-stack-todo-agent-orchestration-contract.md \
  --expected-path 'skills/orchestrated-single-todo-implementation/**' \
  --expected-path tools/orchestrated_single_todo_routing.py \
  --expected-path tools/orchestrated_single_todo_teach.py \
  --expected-path tools/tests/orchestrated_single_todo_test.sh \
  --writer-role routine-executor \
  --raw-artifact-root "$RAW_ROOT" \
  --token-total unavailable \
  --execution-kind llm-subagent \
  --model-family routine_executor \
  --goal-created \
  --goal-completed \
  --goal-tokens-used 128 \
  --goal-token-budget unbudgeted \
  --goal-time-used-seconds 2.5 >/dev/null

python3 "$ROOT_DIR/tools/orchestrated_single_todo_teach.py" \
  --todo "$ROOT_DIR/foundation_documentation/todos/active/delphi-cross-stack-todo-agent-orchestration-contract.md" \
  --baseline v0.6.2-rc@634b546 \
  --approval-gate approved \
  --authority-gate canonical \
  --primary-goal-state active \
  --primary-goal-report 'active:primary-goal-1' \
  --changed-path tools/orchestrated_single_todo_routing.py \
  --expected-path tools/orchestrated_single_todo_routing.py \
  --writer-role routine-executor \
  --raw-artifact-root "$RAW_ROOT" \
  --token-total unavailable \
  --execution-kind deterministic-only \
  --model-family n/a \
  --goal-tokens-used n/a \
  --goal-token-budget n/a \
  --goal-time-used-seconds n/a >/dev/null

# Direct Foundation repositories and downstream symlink targets resolve to
# `<foundation-root>/todos/active/**`, without a literal
# `foundation_documentation` path segment. They remain canonical when the
# Foundation root marker is present.
DIRECT_FOUNDATION="$TMP_DIR/uninotas-foundation"
mkdir -p "$DIRECT_FOUNDATION/todos/active/features"
touch "$DIRECT_FOUNDATION/project_constitution.md"
cat > "$DIRECT_FOUNDATION/todos/active/features/TODO-direct-foundation.md" <<'EOF'
## Diff Expectation Contract

- `tools/orchestrated_single_todo_teach.py`
EOF
python3 "$ROOT_DIR/tools/orchestrated_single_todo_teach.py" \
  --todo "$DIRECT_FOUNDATION/todos/active/features/TODO-direct-foundation.md" \
  --baseline v0.6.2-rc@634b546 \
  --approval-gate approved \
  --authority-gate canonical \
  --primary-goal-state active \
  --primary-goal-report 'active:primary-goal-1' \
  --changed-path tools/orchestrated_single_todo_teach.py \
  --expected-path tools/orchestrated_single_todo_teach.py \
  --writer-role routine-executor \
  --raw-artifact-root "$RAW_ROOT" \
  --token-total unavailable \
  --execution-kind deterministic-only \
  --model-family n/a \
  --goal-tokens-used n/a \
  --goal-token-budget n/a \
  --goal-time-used-seconds n/a >/dev/null

if python3 "$ROOT_DIR/tools/orchestrated_single_todo_teach.py" \
  --todo "$ROOT_DIR/foundation_documentation/todos/active/delphi-cross-stack-todo-agent-orchestration-contract.md" \
  --baseline v0.6.2-rc@634b546 \
  --approval-gate approved \
  --authority-gate canonical \
  --primary-goal-state active \
  --primary-goal-report 'active:primary-goal-1' \
  --changed-path tools/orchestrated_single_todo_routing.py \
  --expected-path tools/orchestrated_single_todo_routing.py \
  --writer-role routine-executor \
  --raw-artifact-root "$RAW_ROOT" \
  --token-total unavailable \
  --execution-kind llm-subagent \
  --model-family routine_executor \
  --goal-tokens-used n/a \
  --goal-token-budget n/a \
  --goal-time-used-seconds n/a >/dev/null 2>&1; then
  echo "expected missing LLM Goal telemetry to block" >&2
  exit 1
fi

if python3 "$ROOT_DIR/tools/orchestrated_single_todo_teach.py" \
  --todo "$ROOT_DIR/foundation_documentation/todos/active/delphi-cross-stack-todo-agent-orchestration-contract.md" \
  --baseline v0.6.2-rc@634b546 \
  --approval-gate pending \
  --authority-gate canonical \
  --primary-goal-state active \
  --primary-goal-report 'active:primary-goal-1' \
  --changed-path tools/orchestrated_single_todo_routing.py \
  --expected-path tools/orchestrated_single_todo_routing.py \
  --writer-role primary-chat \
  --raw-artifact-root "$RAW_ROOT" \
  --token-total unavailable \
  --execution-kind llm-subagent \
  --model-family routine_executor \
  --goal-tokens-used 1 \
  --goal-token-budget 1 \
  --goal-time-used-seconds 0.1 >/dev/null 2>&1; then
  echo "expected bounded assessment to block" >&2
  exit 1
fi

if python3 "$ROOT_DIR/tools/orchestrated_single_todo_teach.py" \
  --todo "$ROOT_DIR/foundation_documentation/todos/active/delphi-cross-stack-todo-agent-orchestration-contract.md" \
  --baseline v0.6.2-rc@634b546 \
  --approval-gate approved \
  --authority-gate canonical \
  --primary-goal-state absent \
  --primary-goal-report 'absent:no-opt-out' \
  --changed-path tools/orchestrated_single_todo_routing.py \
  --expected-path tools/orchestrated_single_todo_routing.py \
  --writer-role routine-executor \
  --raw-artifact-root "$RAW_ROOT" \
  --token-total unavailable \
  --execution-kind deterministic-only \
  --model-family n/a \
  --goal-tokens-used n/a \
  --goal-token-budget n/a \
  --goal-time-used-seconds n/a >/dev/null 2>&1; then
  echo "expected missing primary Goal without opt-out to block" >&2
  exit 1
fi

if python3 "$ROOT_DIR/tools/orchestrated_single_todo_teach.py" \
  --todo "$ROOT_DIR/foundation_documentation/todos/active/delphi-cross-stack-todo-agent-orchestration-contract.md" \
  --baseline v0.6.2-rc@634b546 \
  --approval-gate approved \
  --authority-gate canonical \
  --primary-goal-state absent \
  --primary-goal-report 'metrics-opt-out:malformed' \
  --metrics-opt-out-reference malformed-reference \
  --changed-path tools/orchestrated_single_todo_routing.py \
  --expected-path tools/orchestrated_single_todo_routing.py \
  --writer-role routine-executor \
  --raw-artifact-root "$RAW_ROOT" \
  --token-total unavailable \
  --execution-kind deterministic-only \
  --model-family n/a \
  --goal-tokens-used n/a \
  --goal-token-budget n/a \
  --goal-time-used-seconds n/a >/dev/null 2>&1; then
  echo "expected malformed opt-out to block" >&2
  exit 1
fi

printf 'orchestrated_single_todo_test: OK\n'
