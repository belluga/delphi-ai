#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

bash "$REPO_ROOT/tools/sync_cline_skill_mirrors.sh"
bash "$REPO_ROOT/tools/sync_clinerules_mirrors.sh"
if [ -d "$HOME/.codex/skills/public" ]; then
  bash "$REPO_ROOT/tools/sync_codex_public_skill_mirrors.sh"
fi
bash "$REPO_ROOT/tools/audit_instruction_baselines.sh"
