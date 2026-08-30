#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

cp -R "$ROOT_DIR/skills" "$TMP_DIR/skills"
cp -R "$ROOT_DIR/rules" "$TMP_DIR/rules"
cp -R "$ROOT_DIR/workflows" "$TMP_DIR/workflows"
cp -R "$ROOT_DIR/.cline" "$TMP_DIR/.cline"
cp -R "$ROOT_DIR/.clinerules" "$TMP_DIR/.clinerules"
cp -R "$ROOT_DIR/.claude" "$TMP_DIR/.claude"
cp "$ROOT_DIR/main_instructions.md" "$TMP_DIR/main_instructions.md"
cp "$ROOT_DIR/tools/audit_instruction_baselines.sh" "$TMP_DIR/audit_instruction_baselines.sh"
mkdir -p "$TMP_DIR/tools"
cp "$ROOT_DIR/tools/manifest.md" "$TMP_DIR/tools/manifest.md"
cp "$ROOT_DIR/tools/list_public_codex_skill_mirrors.sh" "$TMP_DIR/tools/list_public_codex_skill_mirrors.sh"

git -C "$TMP_DIR" init -q

(cd "$TMP_DIR" && HOME="$TMP_DIR/isolated-home" bash ./audit_instruction_baselines.sh) >"$TMP_DIR/pass.txt"
grep -q '| Laravel TODO authority adjunct | PASS |' "$TMP_DIR/pass.txt"

python3 - "$TMP_DIR" <<'PY'
import sys
from pathlib import Path

root = Path(sys.argv[1])
core = "rules/core/todo-driven-execution-model-decision.md"
adjunct = "rules/stacks/laravel/shared/todo-driven-execution-model-decision.md"
assert (root / core).is_file()
assert (root / adjunct).is_file()
for skill in (
    root / "skills/rule-laravel-shared-todo-driven-execution-model-decision/SKILL.md",
    root / ".cline/skills/rule-laravel-shared-todo-driven-execution-model-decision/SKILL.md",
    root / ".claude/skills/rule-laravel-shared-todo-driven-execution-model-decision/SKILL.md",
):
    text = skill.read_text(encoding="utf-8")
    assert f"`{core}` from the repository root" in text, skill
    assert f"`{adjunct}` from the repository root" in text, skill
    assert "](../../rules/" not in text, skill
PY

python3 - "$TMP_DIR" <<'PY'
import re
import sys
from pathlib import Path

root = Path(sys.argv[1])
core = (root / "rules/core/todo-driven-execution-model-decision.md").read_text(encoding="utf-8")
paragraphs = [
    block.strip()
    for block in re.split(r"\n\s*\n", core)
    if len(re.sub(r"\s+", " ", block).strip()) >= 120 and not block.lstrip().startswith("---")
]
assert len(paragraphs) >= 2
first_authority_block = next(block for block in paragraphs if "Choose the simplest faithful design:" in block)
future_authority_block = next(block for block in paragraphs if "Foundation documents may describe future architecture" in block)
adjunct = root / "rules/stacks/laravel/shared/todo-driven-execution-model-decision.md"
skill = root / "skills/rule-laravel-shared-todo-driven-execution-model-decision/SKILL.md"
adjunct.write_text(adjunct.read_text(encoding="utf-8") + "\n\n" + first_authority_block + "\n", encoding="utf-8")
assert "Foundation documents may describe future architecture" in future_authority_block
PY
if (cd "$TMP_DIR" && HOME="$TMP_DIR/isolated-home" bash ./audit_instruction_baselines.sh) >"$TMP_DIR/fail.txt"; then
  echo "Expected copied Laravel core authority to fail." >&2
  exit 1
fi
grep -q 'Laravel adjunct or trigger copies shared core authority' "$TMP_DIR/fail.txt"

cp "$ROOT_DIR/rules/stacks/laravel/shared/todo-driven-execution-model-decision.md" "$TMP_DIR/rules/stacks/laravel/shared/todo-driven-execution-model-decision.md"
python3 - "$TMP_DIR" <<'PY'
import re
import sys
from pathlib import Path

root = Path(sys.argv[1])
core = (root / "rules/core/todo-driven-execution-model-decision.md").read_text(encoding="utf-8")
paragraphs = [
    block.strip()
    for block in re.split(r"\n\s*\n", core)
    if len(re.sub(r"\s+", " ", block).strip()) >= 120 and not block.lstrip().startswith("---")
]
future_authority_block = next(block for block in paragraphs if "Foundation documents may describe future architecture" in block)
assert "Foundation documents may describe future architecture" in future_authority_block
skill = root / "skills/rule-laravel-shared-todo-driven-execution-model-decision/SKILL.md"
skill.write_text(skill.read_text(encoding="utf-8") + "\n\n" + future_authority_block + "\n", encoding="utf-8")
PY
if (cd "$TMP_DIR" && HOME="$TMP_DIR/isolated-home" bash ./audit_instruction_baselines.sh) >"$TMP_DIR/second-fail.txt"; then
  echo "Expected the second copied Laravel core authority block to fail." >&2
  exit 1
fi
grep -q 'Laravel adjunct or trigger copies shared core authority' "$TMP_DIR/second-fail.txt"

# Long Laravel-only loading guidance is allowed: literal core overlap, not size,
# is the boundary.
cp "$ROOT_DIR/skills/rule-laravel-shared-todo-driven-execution-model-decision/SKILL.md" "$TMP_DIR/skills/rule-laravel-shared-todo-driven-execution-model-decision/SKILL.md"
printf '\n## Laravel-Only Detail\n%s\n' "$(printf 'Laravel endpoint ownership and tenant resolver loading detail. %.0s' {1..40})" >>"$TMP_DIR/skills/rule-laravel-shared-todo-driven-execution-model-decision/SKILL.md"
cp "$TMP_DIR/skills/rule-laravel-shared-todo-driven-execution-model-decision/SKILL.md" "$TMP_DIR/.cline/skills/rule-laravel-shared-todo-driven-execution-model-decision/SKILL.md"
cp "$TMP_DIR/skills/rule-laravel-shared-todo-driven-execution-model-decision/SKILL.md" "$TMP_DIR/.claude/skills/rule-laravel-shared-todo-driven-execution-model-decision/SKILL.md"
(cd "$TMP_DIR" && HOME="$TMP_DIR/isolated-home" bash ./audit_instruction_baselines.sh) >"$TMP_DIR/long-laravel-pass.txt"
echo 'audit_instruction_baselines_test: PASS'
