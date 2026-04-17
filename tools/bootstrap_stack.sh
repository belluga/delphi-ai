#!/usr/bin/env bash
set -euo pipefail

# Deterministic Root Detection
SCRIPT_ROOT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"

usage() {
  echo "Usage: bash delphi-ai/tools/bootstrap_stack.sh <stack-key> [linter] [test-cmd] [gates] [runtime-ver]"
  echo "Example: bash delphi-ai/tools/bootstrap_stack.sh go-app golangci-lint 'go test ./...' 'logic,security,concurrency' '1.21'"
  exit 1
}

if [ $# -lt 1 ]; then
  usage
fi

STACK_KEY="$1"
LINTER_CMD="${2:-}"
TEST_CMD="${3:-}"
GATES_LIST="${4:-}"
RUNTIME_VER="${5:-}"

# Interactivity: If parameters are missing, ask for them (only if in a terminal)
if [ -z "$LINTER_CMD" ] || [ -z "$TEST_CMD" ] || [ -z "$GATES_LIST" ] || [ -z "$RUNTIME_VER" ]; then
  if [ ! -t 0 ]; then
    echo "ERROR: Missing parameters and not in an interactive terminal."
    usage
  fi
  echo "============================================================"
  echo "🚀 PACED: STACK ARCHITECT ASSISTANT (Interactive Mode)"
  echo "Registering new authority for: [$STACK_KEY]"
  echo "============================================================"
  [ -z "$LINTER_CMD" ] && read -p "🔹 Linter oficial para $STACK_KEY: " LINTER_CMD
  [ -z "$TEST_CMD" ] && read -p "🔹 Comando de Teste: " TEST_CMD
  [ -z "$GATES_LIST" ] && read -p "🔹 Gates obrigatórios (vírgula): " GATES_LIST
  [ -z "$RUNTIME_VER" ] && read -p "🔹 Versão da Runtime: " RUNTIME_VER
fi

echo "PACED: Bootstrapping stack [$STACK_KEY] with $LINTER_CMD..."

# 1. Instruction Layer (Rules)
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

# 2. Deterministic Layer (Guards/Linters)
mkdir -p "$SCRIPT_ROOT/deterministic/stacks/$STACK_KEY"
cat <<EOF > "$SCRIPT_ROOT/deterministic/stacks/$STACK_KEY/guardrails.sh"
#!/usr/bin/env bash
set -euo pipefail
echo "PACED Deterministic Guard: Running $LINTER_CMD..."
$LINTER_CMD
EOF
chmod +x "$SCRIPT_ROOT/deterministic/stacks/$STACK_KEY/guardrails.sh"

# 3. CI Engine Generation
CI_ENGINE_PATH="$SCRIPT_ROOT/.github/workflows/shared/${STACK_KEY}-engine.yml"
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

# 4. Register in Linker (Python injection)
python3 <<EOF
import sys
from pathlib import Path

guard_path = Path("$SCRIPT_ROOT/deterministic/core/todo_completion_guard.py")
content = guard_path.read_text()
new_gate_entry = '    "$STACK_KEY": ["${GATES_LIST.replace(",", '", "')}"],'
if 'NAMESPACE_MANDATORY_GATES = {' in content and '"$STACK_KEY"' not in content:
    content = content.replace('NAMESPACE_MANDATORY_GATES = {', f'NAMESPACE_MANDATORY_GATES = {{\n{new_gate_entry}')
    guard_path.write_text(content)
EOF

echo "✅ SUCCESS: Stack [$STACK_KEY] is now part of the PACED Ecosystem."
