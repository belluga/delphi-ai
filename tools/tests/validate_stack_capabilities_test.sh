#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOL="$ROOT_DIR/tools/validate_stack_capabilities.py"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

GOOD="$TMP_DIR/good.yaml"
BAD="$TMP_DIR/bad.yaml"
BAD_OUTPUT="$TMP_DIR/bad.out"

cat > "$GOOD" <<'EOF'
schema_version: 1
ecosystem: belluga
activation_contract:
  authority_order:
    - foundation_documentation
capabilities:
  docker:
    lifecycle: available
    purpose: Runtime orchestration.
    activation_markers:
      - compose files
    execution_policy: Use project-declared topology.
  flutter:
    lifecycle: available
    purpose: Client app.
    activation_markers:
      - pubspec.yaml
    execution_policy: Use only when project declares Flutter active.
  laravel:
    lifecycle: available
    purpose: Backend/API.
    activation_markers:
      - composer.json
    execution_policy: Use project-owned safe runners.
  go:
    lifecycle: future
    purpose: Future backend/service capability.
    activation_markers:
      - go.mod
    execution_policy: Reserved until project declares Go active.
EOF

cat > "$BAD" <<'EOF'
schema_version: 1
ecosystem: belluga
activation_contract:
  authority_order:
    - foundation_documentation
capabilities:
  docker:
    lifecycle: live
    purpose: Runtime orchestration.
    active: true
    activation_markers:
      - compose files
    execution_policy: Use project-declared topology.
EOF

python3 "$TOOL" "$GOOD"
if python3 "$TOOL" "$BAD" >"$BAD_OUTPUT" 2>&1; then
  cat "$BAD_OUTPUT"
  printf 'expected bad registry to fail\n' >&2
  exit 1
fi

grep -q "missing capability block" "$BAD_OUTPUT"
grep -q "forbidden project activation flag" "$BAD_OUTPUT"
grep -q "invalid lifecycle" "$BAD_OUTPUT"

printf 'validate_stack_capabilities_test: OK\n'
