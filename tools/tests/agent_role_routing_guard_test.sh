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

CODEX_CHAT_MODEL="$(contract_model codex chat_orchestrator 0)"
CODEX_ROUTINE_MODEL="$(contract_model codex routine_executor 0)"
CODEX_ROUTINE_FALLBACK="$(contract_model codex routine_executor 1)"
CODEX_REVIEW_MODEL="$(contract_model codex strongest_review 0)"
CLAUDE_CHAT_MODEL="$(contract_model claude-code chat_orchestrator 0)"
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
  --proof-mode declared

assert_outcome go \
  --client codex \
  --surface implementation \
  --role routine-executor \
  --model "$CODEX_ROUTINE_FALLBACK" \
  --effort medium \
  --proof-mode declared

assert_outcome go \
  --client codex \
  --surface implementation \
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
  --model "$CODEX_ROUTINE_FALLBACK" \
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
