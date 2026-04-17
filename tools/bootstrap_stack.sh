#!/usr/bin/env bash
set -euo pipefail

# Deterministic Root Detection
SCRIPT_ROOT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"

# Interactivity: Ensure we are in a terminal or have inputs
if [ ! -t 0 ]; then
  echo "ERROR: This script must be run interactively."
  exit 1
fi

usage() {
  echo "Usage: bash delphi-ai/tools/bootstrap_stack.sh <stack-key>"
  echo "Example: bash delphi-ai/tools/bootstrap_stack.sh go-app"
  exit 1
}

if [ $# -lt 1 ]; then
  usage
fi

STACK_KEY="$1"
echo "============================================================"
echo "🚀 PACED: STACK ARCHITECT ASSISTANT"
echo "Registering new authority for: [$STACK_KEY]"
echo "============================================================"

# 1. Gather Intelligence (Interactive)
read -p "🔹 Qual o Linter oficial para $STACK_KEY? (ex: golangci-lint): " LINTER_CMD
read -p "🔹 Qual o comando de Teste determinístico? (ex: go test ./...): " TEST_CMD
read -p "🔹 Liste os Gates obrigatórios (separados por vírgula): (ex: logic,security,concurrency): " GATES_LIST
read -p "🔹 Qual a versão base da Runtime? (ex: 1.21): " RUNTIME_VER

# 2. Instruction Layer (Rules)
echo "📂 Creating Instruction Layer (Rules)..."
mkdir -p "$SCRIPT_ROOT/rules/stacks/$STACK_KEY"
cat <<EOF > "$SCRIPT_ROOT/rules/stacks/$STACK_KEY/00_manifest.md"
# Stack Rules: $STACK_KEY
- **Authority:** PACED Deterministic
- **Namespace:** $STACK_KEY
- **Mandatory Gates:** [$GATES_LIST]

## Deterministic Standards
1. **Linting:** O código DEVE passar no \`$LINTER_CMD\` sem avisos.
2. **Testing:** Cobertura mínima de testes deve ser validada via \`$TEST_CMD\`.
3. **Architecture:** Seguir os padrões definidos em \`rules/stacks/$STACK_KEY/\`.
EOF

# 3. Deterministic Layer (Guards/Linters)
echo "📂 Creating Deterministic Layer (Guards)..."
mkdir -p "$SCRIPT_ROOT/deterministic/stacks/$STACK_KEY"
cat <<EOF > "$SCRIPT_ROOT/deterministic/stacks/$STACK_KEY/guardrails.sh"
#!/usr/bin/env bash
set -euo pipefail
echo "PACED Deterministic Guard: Running $LINTER_CMD..."
$LINTER_CMD
EOF
chmod +x "$SCRIPT_ROOT/deterministic/stacks/$STACK_KEY/guardrails.sh"

# 4. CI Engine Generation (GitHub Actions)
echo "⚙️ Generating GitHub Actions CI Engine..."
CI_ENGINE_PATH="$SCRIPT_ROOT/.github/workflows/shared/${STACK_KEY}-engine.yml"

# Use a generic template based on the provided inputs
cat <<EOF > "$CI_ENGINE_PATH"
name: "PACED: $STACK_KEY CI Engine"

on:
  workflow_call:
    inputs:
      runtime_version:
        type: string
        default: "$RUNTIME_VER"
      namespace:
        type: string
        default: "$STACK_KEY"

jobs:
  validate-and-test:
    runs-on: ubuntu-latest
    steps:
      - name: "Checkout Project"
        uses: actions/checkout@v4
        with:
          path: "project"

      - name: "Checkout PACED (delphi-ai)"
        uses: actions/checkout@v4
        with:
          repository: "belluga/delphi-ai"
          path: "project/delphi-ai"
          ref: \${{ github.event_name == 'pull_request' && github.head_ref || github.ref_name }}

      - name: "Setup Runtime"
        run: |
          echo "Setting up $STACK_KEY version \${{ inputs.runtime_version }}..."
          # Aqui o usuário deve customizar o setup específico (ex: actions/setup-go)

      - name: "Setup PACED Environment (Repair)"
        working-directory: "project"
        run: bash delphi-ai/tools/verify_context.sh --repair

      - name: "Deterministic Guard: TODO Completion"
        working-directory: "project"
        run: python3 delphi-ai/deterministic/core/todo_completion_guard.py --all-completed

      - name: "Stack Analysis: Lint ($LINTER_CMD)"
        working-directory: "project"
        run: $LINTER_CMD

      - name: "Stack Analysis: Tests ($TEST_CMD)"
        working-directory: "project"
        run: $TEST_CMD
EOF

# 5. Register in Linker (Optional but helpful)
echo "🔗 Registering $STACK_KEY in the PACED Linker..."
# Adiciona o gate obrigatório ao todo_completion_guard.py via Python injection
python3 <<EOF
import sys
from pathlib import Path

guard_path = Path("$SCRIPT_ROOT/deterministic/core/todo_completion_guard.py")
content = guard_path.read_text()
new_gate_entry = '    "$STACK_KEY": ["${GATES_LIST.replace(",", '", "')}"],'
if 'NAMESPACE_MANDATORY_GATES = {' in content:
    content = content.replace('NAMESPACE_MANDATORY_GATES = {', f'NAMESPACE_MANDATORY_GATES = {{\n{new_gate_entry}')
    guard_path.write_text(content)
EOF

echo "============================================================"
echo "✅ SUCCESS: Stack [$STACK_KEY] is now part of the PACED Ecosystem."
echo "============================================================"
echo "Next steps:"
echo "1. Customize the 'Setup Runtime' step in .github/workflows/shared/${STACK_KEY}-engine.yml"
echo "2. Add specific architectural rules in rules/stacks/$STACK_KEY/"
echo "3. Run 'verify_context.sh --repair' in your $STACK_KEY projects."
