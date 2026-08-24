#!/usr/bin/env bash
set -euo pipefail

resolve_repo_root() {
  local start="${CLAUDE_PROJECT_DIR:-$(pwd)}"
  git -C "$start" rev-parse --show-toplevel 2>/dev/null || printf '%s\n' "$start"
}

resolve_delphi_root() {
  local repo_root="$1"
  if [[ -f "$repo_root/main_instructions.md" && -d "$repo_root/tools" ]]; then
    printf '%s\n' "$repo_root"
    return 0
  fi
  if [[ -f "$repo_root/delphi-ai/main_instructions.md" && -d "$repo_root/delphi-ai/tools" ]]; then
    printf '%s\n' "$repo_root/delphi-ai"
    return 0
  fi
  printf 'Unable to resolve delphi-ai root from %s\n' "$repo_root" >&2
  return 1
}

run_delphi_hook_guard() {
  local event="$1"
  local repo_root
  local delphi_root

  repo_root="$(resolve_repo_root)"
  delphi_root="$(resolve_delphi_root "$repo_root")"
  python3 "$delphi_root/tools/session_hook_guard.py" --client claude-code --event "$event" --repo-root "$repo_root"
}
