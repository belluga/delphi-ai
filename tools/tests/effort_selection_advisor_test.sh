#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOL="$ROOT_DIR/tools/effort_selection_advisor.py"
CONTRACT="$ROOT_DIR/config/agent_role_routing.json"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

EXECUTOR_JSON="$TMP_DIR/executor.json"
REVIEW_JSON="$TMP_DIR/review.json"
AMBIGUITY_JSON="$TMP_DIR/ambiguity.json"
MONITORING_JSON="$TMP_DIR/monitoring.json"
ORDINARY_JSON="$TMP_DIR/ordinary.json"
TODO_APPROVAL_JSON="$TMP_DIR/todo-approval.json"
DELIVERY_REVIEW_JSON="$TMP_DIR/delivery-review.json"
CLAUDE_APPROVAL_JSON="$TMP_DIR/claude-approval.json"
CLINE_DELIVERY_JSON="$TMP_DIR/cline-delivery.json"

python3 "$TOOL" \
  --surface executor-subagent \
  --goals-supported \
  --json-output "$EXECUTOR_JSON" >/dev/null

python3 "$TOOL" \
  --surface review-subagent \
  --json-output "$REVIEW_JSON" >/dev/null

python3 "$TOOL" \
  --surface exploratory-review \
  --material-strategic-ambiguity \
  --json-output "$AMBIGUITY_JSON" >/dev/null

python3 "$TOOL" \
  --surface monitoring \
  --json-output "$MONITORING_JSON" >/dev/null

python3 "$TOOL" \
  --surface ordinary-session \
  --json-output "$ORDINARY_JSON" >/dev/null

python3 "$TOOL" \
  --surface todo-approval \
  --json-output "$TODO_APPROVAL_JSON" >/dev/null

python3 "$TOOL" \
  --surface delivery-review \
  --json-output "$DELIVERY_REVIEW_JSON" >/dev/null

python3 "$TOOL" \
  --client claude-code \
  --surface todo-approval \
  --json-output "$CLAUDE_APPROVAL_JSON" >/dev/null

python3 "$TOOL" \
  --client cline-ide \
  --surface delivery-review \
  --json-output "$CLINE_DELIVERY_JSON" >/dev/null

python3 - "$CONTRACT" "$EXECUTOR_JSON" "$REVIEW_JSON" "$AMBIGUITY_JSON" "$MONITORING_JSON" "$ORDINARY_JSON" "$TODO_APPROVAL_JSON" "$DELIVERY_REVIEW_JSON" "$CLAUDE_APPROVAL_JSON" "$CLINE_DELIVERY_JSON" <<'PY'
import json
import sys
from pathlib import Path

contract = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
executor = json.loads(Path(sys.argv[2]).read_text(encoding="utf-8"))
review = json.loads(Path(sys.argv[3]).read_text(encoding="utf-8"))
ambiguity = json.loads(Path(sys.argv[4]).read_text(encoding="utf-8"))
monitoring = json.loads(Path(sys.argv[5]).read_text(encoding="utf-8"))
ordinary = json.loads(Path(sys.argv[6]).read_text(encoding="utf-8"))
todo_approval = json.loads(Path(sys.argv[7]).read_text(encoding="utf-8"))
delivery_review = json.loads(Path(sys.argv[8]).read_text(encoding="utf-8"))
claude_approval = json.loads(Path(sys.argv[9]).read_text(encoding="utf-8"))
cline_delivery = json.loads(Path(sys.argv[10]).read_text(encoding="utf-8"))

codex_models = contract["clients"]["codex"]["preferred_models"]
claude_models = contract["clients"]["claude-code"]["preferred_models"]
cline_models = contract["clients"]["cline-ide"]["preferred_models"]

assert executor["recommended_model"] == codex_models["routine_executor"][0]
assert executor["recommended_effort"] == "medium"
assert executor["goal_policy"] == "required"
assert executor["execution_state_policy"] == "sticky-per-chat-or-todo-compact-state"
assert review["recommended_model"] == codex_models["strongest_review"][0]
assert review["recommended_effort"] == "ExtraRight-or-closest-equivalent"
assert review["goal_policy"] == "stateless-default"
assert ambiguity["recommended_effort"] == "ExtraRight-or-closest-equivalent"
assert ambiguity["recommended_model"] == codex_models["strongest_review"][0]
assert ambiguity["material_strategic_ambiguity"] is True
assert monitoring["recommended_model"] == (
    f"deterministic-first-or-{codex_models['monitoring'][0]}-if-llm-needed"
)
assert monitoring["recommended_effort"] == "low-or-medium"
assert monitoring["execution_state_policy"] == "ephemeral-bounded-status-pass"
assert ordinary["recommended_model"] == codex_models["chat_orchestrator"][0]
assert ordinary["recommended_model_family"] == "chat_orchestrator"
assert todo_approval["recommended_model"] == codex_models["chat_orchestrator"][0]
assert todo_approval["recommended_model_family"] == "chat_orchestrator"
assert delivery_review["recommended_model"] == codex_models["chat_orchestrator"][0]
assert delivery_review["recommended_model_family"] == "chat_orchestrator"
assert claude_approval["client"] == "claude-code"
assert claude_approval["recommended_model"] == claude_models["chat_orchestrator"][0]
assert claude_approval["recommended_model_family"] == "chat_orchestrator"
assert "chat/orchestrator model" in claude_approval["model_notes"][0]
assert cline_delivery["client"] == "cline-ide"
assert cline_delivery["recommended_model"] == cline_models["chat_orchestrator"][0]
assert cline_delivery["recommended_model_family"] == "chat_orchestrator"
assert "chat/orchestrator model" in cline_delivery["model_notes"][0]
print("effort_selection_advisor_test: OK")
PY
