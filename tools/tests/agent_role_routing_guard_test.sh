#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOL="$ROOT_DIR/tools/agent_role_routing_guard.py"
CONTRACT="$ROOT_DIR/config/agent_role_routing.json"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

contract_model() {
  python3 - "$CONTRACT" "$1" "$2" "$3" <<'PY'
import json
import sys
from pathlib import Path

contract = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
print(contract["clients"][sys.argv[2]]["preferred_models"][sys.argv[3]][int(sys.argv[4])])
PY
}

assert_template_exception_reasons_are_canonical() {
  python3 - "$CONTRACT" "$ROOT_DIR/templates/todo_template.md" <<'PY'
import json
import re
import sys
from pathlib import Path

contract = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
canonical = {
    reason
    for surface in contract["surfaces"].values()
    for reason in surface["allowed_exception_reasons"]
}
template = Path(sys.argv[2]).read_text(encoding="utf-8")
match = re.search(r"\*\*Exception reason:\*\*\s*`<([^>]+)>`", template)
assert match, "template Exception reason field not found"
declared = {item.strip() for item in match.group(1).split("|") if item.strip() != "n/a"}
assert declared <= canonical, sorted(declared - canonical)
PY
}

assert_template_exception_reasons_are_canonical

CODEX_CHAT_MODEL="$(contract_model codex chat_orchestrator 0)"
CODEX_ROUTINE_MODEL="$(contract_model codex routine_executor 0)"
CODEX_REVIEW_MODEL="$(contract_model codex strongest_review 0)"
CLAUDE_CHAT_MODEL="$(contract_model claude-code chat_orchestrator 0)"
CLAUDE_ROUTINE_MODEL="$(contract_model claude-code routine_executor 0)"
CLAUDE_REVIEW_MODEL="$(contract_model claude-code strongest_review 0)"
CLINE_CHAT_MODEL="$(contract_model cline-ide chat_orchestrator 1)"
CLINE_ROUTINE_MODEL="$(contract_model cline-ide routine_executor 1)"

assert_outcome() {
  local expected="$1"
  shift
  local output="$TMP_DIR/out.txt"

  set +e
  python3 "$TOOL" "$@" >"$output" 2>&1
  local status=$?
  set -e

  if [[ "$expected" == "go" ]]; then
    [[ $status -eq 0 ]] || {
      cat "$output"
      printf 'expected go, got exit %s\n' "$status" >&2
      exit 1
    }
  else
    [[ $status -eq 2 ]] || {
      cat "$output"
      printf 'expected non-go exit 2, got %s\n' "$status" >&2
      exit 1
    }
  fi

  grep -q "Overall outcome: $expected" "$output" || {
    cat "$output"
    printf 'missing expected outcome %s\n' "$expected" >&2
    exit 1
  }
}

assert_json_violation() {
  local expected_code="$1"
  shift
  local output="$TMP_DIR/result.json"
  set +e
  python3 "$TOOL" "$@" --json-output "$output" >/dev/null 2>&1
  local status=$?
  set -e
  [[ $status -eq 2 ]] || {
    cat "$output"
    printf 'expected JSON fixture to exit 2, got %s\n' "$status" >&2
    exit 1
  }
  python3 - "$output" "$expected_code" <<'PY'
import json
import sys

payload = json.loads(open(sys.argv[1], encoding="utf-8").read())
assert payload["outcome"] != "go"
assert any(item["code"] == sys.argv[2] for item in payload["violations"])
PY
}

assert_outcome delegate-required \
  --client codex \
  --surface implementation \
  --role primary-chat \
  --model "$CODEX_ROUTINE_MODEL" \
  --effort medium \
  --proof-mode declared

assert_outcome go \
  --client codex \
  --surface implementation \
  --role routine-executor \
  --model "$CODEX_ROUTINE_MODEL" \
  --effort medium \
  --proof-mode declared \
  --execution-topology primary-checkout-single-writer \
  --worktree-authorization not-authorized

assert_json_violation MODEL-MISMATCH \
  --client codex \
  --surface implementation \
  --role routine-executor \
  --model gpt \
  --effort medium \
  --proof-mode declared

assert_json_violation EFFORT-MISMATCH \
  --client codex \
  --surface implementation \
  --role routine-executor \
  --model "$CODEX_ROUTINE_MODEL" \
  --effort m \
  --proof-mode declared

assert_json_violation EFFORT-MISMATCH \
  --client codex \
  --surface implementation \
  --role routine-executor \
  --model "$CODEX_ROUTINE_MODEL" \
  --effort medium-plus \
  --proof-mode declared

assert_outcome blocked \
  --client codex \
  --surface implementation \
  --role routine-executor \
  --model "$CODEX_ROUTINE_MODEL" \
  --effort medium \
  --proof-mode declared \
  --execution-topology worktree-isolated \
  --worktree-authorization not-authorized

assert_outcome blocked \
  --client codex \
  --surface implementation \
  --role routine-executor \
  --model "$CODEX_ROUTINE_MODEL" \
  --effort medium \
  --proof-mode declared \
  --execution-topology worktree-isolated \
  --worktree-authorization explicit \
  --worktree-authorization-reference "APROVADO: use subagents in parallel"

assert_outcome go \
  --client codex \
  --surface implementation \
  --role routine-executor \
  --model "$CODEX_ROUTINE_MODEL" \
  --effort medium \
  --proof-mode declared \
  --execution-topology worktree-isolated \
  --worktree-authorization explicit \
  --worktree-authorization-reference "Human explicitly authorizes git worktrees for isolated writers"

assert_outcome go \
  --client codex \
  --surface implementation \
  --role routine-executor \
  --model "$CODEX_ROUTINE_MODEL" \
  --effort medium \
  --proof-mode declared

assert_outcome blocked \
  --client codex \
  --surface implementation \
  --role primary-chat \
  --model "$CODEX_ROUTINE_MODEL" \
  --effort medium \
  --proof-mode waiver \
  --exception-reason bootstrap-guard-implementation \
  --waiver-reference "D-07 bootstrap exception"

assert_outcome blocked \
  --client codex \
  --surface implementation-validation \
  --role primary-chat \
  --model "$CODEX_ROUTINE_MODEL" \
  --effort medium \
  --proof-mode waiver \
  --exception-reason bootstrap-guard-implementation \
  --waiver-reference "D-07 bootstrap exception"

assert_outcome waiver-required \
  --client codex \
  --surface implementation \
  --role routine-executor \
  --effort medium \
  --proof-mode declared

assert_outcome review-required \
  --client codex \
  --surface formal-review \
  --role formal-reviewer \
  --model "$CODEX_ROUTINE_MODEL" \
  --effort ExtraRight-or-closest-equivalent \
  --proof-mode declared

assert_outcome go \
  --client codex \
  --surface todo-approval \
  --role primary-chat \
  --model "$CODEX_CHAT_MODEL" \
  --effort ExtraRight-or-closest-equivalent \
  --proof-mode declared

assert_outcome go \
  --client codex \
  --surface delivery-review \
  --role primary-chat \
  --model "$CODEX_CHAT_MODEL" \
  --effort ExtraRight-or-closest-equivalent \
  --proof-mode declared

assert_outcome go \
  --client codex \
  --surface delivery-review \
  --role primary-chat \
  --review-kind final_review \
  --model "$CODEX_CHAT_MODEL" \
  --effort ExtraRight-or-closest-equivalent \
  --proof-mode declared

assert_outcome go \
  --client codex \
  --surface delivery-review \
  --role formal-reviewer \
  --review-kind final_review \
  --model "$CODEX_REVIEW_MODEL" \
  --effort ExtraRight-or-closest-equivalent \
  --proof-mode declared

assert_outcome go \
  --client claude-code \
  --surface todo-approval \
  --role primary-chat \
  --model "claude-${CLAUDE_CHAT_MODEL}-5" \
  --effort xhigh \
  --proof-mode declared

assert_outcome go \
  --client claude-code \
  --surface implementation \
  --role routine-executor \
  --model "claude-${CLAUDE_ROUTINE_MODEL}-4-6" \
  --effort medium \
  --proof-mode declared

assert_json_violation MODEL-MISMATCH \
  --client claude-code \
  --surface todo-approval \
  --role primary-chat \
  --model "claude-${CLAUDE_CHAT_MODEL}-x" \
  --effort xhigh \
  --proof-mode declared

assert_json_violation MODEL-MISMATCH \
  --client claude-code \
  --surface todo-approval \
  --role primary-chat \
  --model "claude-${CLAUDE_CHAT_MODEL}-5-beta" \
  --effort xhigh \
  --proof-mode declared

assert_outcome go \
  --client cline-ide \
  --surface delivery-review \
  --role primary-chat \
  --model "$CLINE_CHAT_MODEL" \
  --proof-mode declared

assert_outcome go \
  --client codex \
  --surface formal-review \
  --role formal-reviewer \
  --model "$CODEX_REVIEW_MODEL" \
  --effort ExtraRight-or-closest-equivalent \
  --proof-mode declared

assert_outcome go \
  --client codex \
  --surface formal-review \
  --role formal-reviewer \
  --review-kind architecture_adherence \
  --model "$CODEX_REVIEW_MODEL" \
  --effort ExtraRight-or-closest-equivalent \
  --proof-mode declared

assert_outcome go \
  --client claude-code \
  --surface formal-review \
  --role formal-reviewer \
  --model "$CLAUDE_REVIEW_MODEL" \
  --effort xhigh \
  --proof-mode artifact

assert_outcome go \
  --client cline-ide \
  --surface implementation \
  --role routine-executor \
  --model "$CLINE_ROUTINE_MODEL" \
  --proof-mode declared

assert_outcome go \
  --client codex \
  --surface monitoring \
  --role deterministic-only \
  --proof-mode declared

assert_outcome blocked \
  --client codex \
  --surface implementation \
  --role routine-executor \
  --model "$CODEX_ROUTINE_MODEL" \
  --effort medium \
  --proof-mode artifact

printf 'agent_role_routing_guard_test: OK\n'
