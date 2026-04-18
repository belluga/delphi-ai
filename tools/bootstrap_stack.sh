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

# ============================================================
# COLLISION GUARD: Verify that the new stack does not conflict
# with any existing PACED artifacts.
# ============================================================
COLLISION_FOUND=0

check_collision() {
  local artifact_path="$1"
  local artifact_desc="$2"
  if [ -e "$artifact_path" ]; then
    echo "COLLISION: $artifact_desc already exists at: $artifact_path"
    COLLISION_FOUND=1
  fi
}

# Check all artifact directories that the bootstrap would create or overwrite
check_collision "$SCRIPT_ROOT/rules/stacks/$STACK_KEY" "Rules directory"
check_collision "$SCRIPT_ROOT/deterministic/stacks/$STACK_KEY" "Deterministic guards directory"
check_collision "$SCRIPT_ROOT/.github/workflows/shared/${STACK_KEY}-engine.yml" "CI engine workflow"
check_collision "$SCRIPT_ROOT/templates/agents/${STACK_KEY}.md" "Agent template"

# Check namespace_gates.json for existing registration
NAMESPACE_GATES_PATH="$SCRIPT_ROOT/deterministic/core/namespace_gates.json"
if [ -f "$NAMESPACE_GATES_PATH" ]; then
  if python3 -c "
import json, sys
data = json.loads(open('$NAMESPACE_GATES_PATH').read())
if '$STACK_KEY' in data and not '$STACK_KEY'.startswith('_'):
    print('COLLISION: Stack \"$STACK_KEY\" is already registered in namespace_gates.json')
    sys.exit(1)
" 2>/dev/null; then
    : # no collision
  else
    COLLISION_FOUND=1
  fi
fi

if [ "$COLLISION_FOUND" -eq 1 ]; then
  echo ""
  echo "ERROR: Cannot bootstrap stack [$STACK_KEY] — collisions detected with existing PACED artifacts."
  echo "If you intend to UPDATE an existing stack, use the appropriate update workflow."
  echo "If this is a new stack with a name conflict, choose a different stack-key."
  exit 2
fi

echo "PACED: No collisions detected. Proceeding with bootstrap for [$STACK_KEY]."

# Interactivity: If parameters are missing, ask for them (only if in a terminal)
if [ -z "$LINTER_CMD" ] || [ -z "$TEST_CMD" ] || [ -z "$GATES_LIST" ] || [ -z "$RUNTIME_VER" ]; then
  if [ ! -t 0 ]; then
    echo "ERROR: Missing parameters and not in an interactive terminal."
    usage
  fi
  echo "============================================================"
  echo "PACED: STACK ARCHITECT ASSISTANT (Interactive Mode)"
  echo "Registering new authority for: [$STACK_KEY]"
  echo "============================================================"
  [ -z "$LINTER_CMD" ] && read -p "Linter oficial para $STACK_KEY: " LINTER_CMD
  [ -z "$TEST_CMD" ] && read -p "Comando de Teste: " TEST_CMD
  [ -z "$GATES_LIST" ] && read -p "Gates obrigatorios (virgula): " GATES_LIST
  [ -z "$RUNTIME_VER" ] && read -p "Versao da Runtime: " RUNTIME_VER
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
1. **Linting:** O codigo DEVE passar no \`$LINTER_CMD\` sem avisos.
2. **Testing:** Cobertura minima de testes deve ser validada via \`$TEST_CMD\`.
3. **Architecture:** Seguir os padroes definidos em \`rules/stacks/$STACK_KEY/\`.
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

# 4. Register in namespace_gates.json (Single Source of Truth)
python3 <<EOF
import json
from pathlib import Path

gates_path = Path("$NAMESPACE_GATES_PATH")
if gates_path.exists():
    data = json.loads(gates_path.read_text(encoding="utf-8"))
else:
    data = {"_comment": "PACED: Mandatory gates per namespace.", "core": ["logic", "critique"]}

gates_list = [g.strip() for g in "$GATES_LIST".split(",") if g.strip()]
data["$STACK_KEY"] = gates_list
gates_path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
print(f"Registered '$STACK_KEY' gates in namespace_gates.json")
EOF

echo ""
echo "SUCCESS: Stack [$STACK_KEY] is now part of the PACED Ecosystem."
echo "Artifacts created:"
echo "  - Rules:         rules/stacks/$STACK_KEY/"
echo "  - Deterministic: deterministic/stacks/$STACK_KEY/"
echo "  - CI Engine:     .github/workflows/shared/${STACK_KEY}-engine.yml"
echo "  - Gates:         namespace_gates.json (entry: $STACK_KEY)"
