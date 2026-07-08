#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

python3 - "$REPO_ROOT" <<'PY'
import re
import sys
from pathlib import Path

repo_root = Path(sys.argv[1])
manifest = repo_root / "tools" / "manifest.md"
missing = []

for line in manifest.read_text(encoding="utf-8").splitlines():
    match = re.search(r"`(tools/[^`]+)`", line)
    if not match:
        continue
    rel_path = match.group(1)
    if not (repo_root / rel_path).exists():
        missing.append(rel_path)

if missing:
    for rel_path in missing:
        print(f"missing manifest tool path: {rel_path}", file=sys.stderr)
    raise SystemExit(1)
PY

python3 "$REPO_ROOT/tools/validate_stack_capabilities.py"
bash "$REPO_ROOT/tools/sync_cline_skill_mirrors.sh"
bash "$REPO_ROOT/tools/sync_claude_skill_mirrors.sh"
python3 "$REPO_ROOT/tools/sync_claude_agent_routing.py"
bash "$REPO_ROOT/tools/sync_clinerules_mirrors.sh"
python3 "$REPO_ROOT/tools/validate_phase_surfaces.py"
if [ -d "$HOME/.codex/skills/public" ]; then
  bash "$REPO_ROOT/tools/sync_codex_public_skill_mirrors.sh"
fi
bash "$REPO_ROOT/tools/audit_instruction_baselines.sh"
