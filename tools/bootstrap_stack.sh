#!/usr/bin/env bash
set -euo pipefail

# Deterministic Root Detection
SCRIPT_ROOT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"

usage() {
  echo "Usage: bash delphi-ai/tools/bootstrap_stack.sh <stack-key>"
  echo "Example: bash delphi-ai/tools/bootstrap_stack.sh svelte-app"
  exit 1
}

if [ $# -lt 1 ]; then
  usage
fi

STACK_KEY="$1"
echo "PACED: Bootstrapping new stack authority for [$STACK_KEY]..."

# 1. Instruction Layer (Rules)
mkdir -p "$SCRIPT_ROOT/rules/stacks/$STACK_KEY"
cat <<EOF > "$SCRIPT_ROOT/rules/stacks/$STACK_KEY/00_manifest.md"
# Stack Rules: $STACK_KEY
- **Authority:** PACED Deterministic
- **Focus:** [Explain the core focus of this stack]

## Mandatory Patterns
1. [Pattern 1]
2. [Pattern 2]
EOF

# 2. Deterministic Layer (Guards/Linters)
mkdir -p "$SCRIPT_ROOT/deterministic/stacks/$STACK_KEY"
cat <<EOF > "$SCRIPT_ROOT/deterministic/stacks/$STACK_KEY/lint_config.json"
{
  "stack": "$STACK_KEY",
  "version": "1.0.0",
  "rules": []
}
EOF

# 3. CI Engine Template
CI_ENGINE_PATH="$SCRIPT_ROOT/.github/workflows/shared/${STACK_KEY}-engine.yml"
if [ ! -f "$CI_ENGINE_PATH" ]; then
  cp "$SCRIPT_ROOT/.github/workflows/shared/next-app-engine.yml" "$CI_ENGINE_PATH"
  # Replace name in the new engine
  sed -i "s/PACED: Independent Web-App CI Engine/PACED: $STACK_KEY CI Engine/g" "$CI_ENGINE_PATH"
  echo "CI Engine created: .github/workflows/shared/${STACK_KEY}-engine.yml"
fi

echo "Stack [$STACK_KEY] initialized. Now customize the rules and guards in:"
echo "  - rules/stacks/$STACK_KEY/"
echo "  - deterministic/stacks/$STACK_KEY/"
