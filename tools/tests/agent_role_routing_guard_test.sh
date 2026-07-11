#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOL="$ROOT_DIR/tools/agent_role_routing_guard.py"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

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
  --model gpt-5.6-luna \
  --effort medium \
  --proof-mode declared

assert_outcome go \
  --client codex \
  --surface implementation \
  --role routine-executor \
  --model gpt-5.6-luna \
  --effort medium \
  --proof-mode declared

assert_outcome go \
  --client codex \
  --surface implementation \
  --role primary-chat \
  --model gpt-5.6-luna \
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
  --model gpt-5.6-luna \
  --effort ExtraRight-or-closest-equivalent \
  --proof-mode declared

assert_outcome go \
  --client codex \
  --surface formal-review \
  --role formal-reviewer \
  --model gpt-5.6-sol \
  --effort ExtraRight-or-closest-equivalent \
  --proof-mode declared

assert_outcome go \
  --client codex \
  --surface formal-review \
  --role formal-reviewer \
  --review-kind architecture_adherence \
  --model gpt-5.4 \
  --effort ExtraRight-or-closest-equivalent \
  --proof-mode declared

assert_outcome go \
  --client claude-code \
  --surface formal-review \
  --role formal-reviewer \
  --model opus \
  --effort xhigh \
  --proof-mode artifact

assert_outcome go \
  --client cline-ide \
  --surface implementation \
  --role routine-executor \
  --model sonnet-or-best-available-routine-coding-model \
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
  --model gpt-5.6-luna \
  --effort medium \
  --proof-mode artifact

printf 'agent_role_routing_guard_test: OK\n'
