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

(cd "$TMP_DIR" && bash ./audit_instruction_baselines.sh) >"$TMP_DIR/pass.txt"
grep -q '| Laravel TODO authority adjunct | PASS |' "$TMP_DIR/pass.txt"

for _ in $(seq 1 90); do echo '## Gate A — Shared Authority'; done >>"$TMP_DIR/rules/stacks/laravel/shared/todo-driven-execution-model-decision.md"
if (cd "$TMP_DIR" && bash ./audit_instruction_baselines.sh) >"$TMP_DIR/fail.txt"; then
  echo "Expected Laravel shared-authority regrowth to fail." >&2
  exit 1
fi
grep -q 'Laravel adjunct regrows shared authority' "$TMP_DIR/fail.txt"
echo 'audit_instruction_baselines_test: PASS'
