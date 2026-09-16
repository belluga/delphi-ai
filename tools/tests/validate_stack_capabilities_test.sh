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
  project_contract_surfaces:
    - foundation_documentation/
  non_activation_signals:
    - registry presence
capabilities:
  docker:
    lifecycle: available
    purpose: Runtime orchestration.
    activation_markers:
      - compose files
    detection_markers:
      root_files:
        - docker-compose.yml
    execution_policy: Use project-declared topology.
  flutter:
    lifecycle: available
    purpose: Client app.
    activation_markers:
      - pubspec.yaml
    detection_markers:
      nested_files:
        - pubspec.yaml
    execution_policy: Use only when project declares Flutter active.
  laravel:
    lifecycle: available
    purpose: Backend/API.
    activation_markers:
      - composer.json
    detection_markers:
      nested_files:
        - artisan
        - composer.json
      composer_requires:
        - laravel/framework
    execution_policy: Use project-owned safe runners.
  go:
    lifecycle: future
    purpose: Future backend/service capability.
    activation_markers:
      - go.mod
    detection_markers:
      nested_files:
        - go.mod
    execution_policy: Reserved until project declares Go active.
EOF

cat > "$BAD" <<'EOF'
schema_version: 1
ecosystem: belluga
activation_contract:
  authority_order:
    - foundation_documentation
  project_contract_surfaces:
    - foundation_documentation/
  non_activation_signals:
    - registry presence
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
python3 "$ROOT_DIR/tools/tests/stack_capability_registry_test.py"
if python3 "$TOOL" "$BAD" >"$BAD_OUTPUT" 2>&1; then
  cat "$BAD_OUTPUT"
  printf 'expected bad registry to fail\n' >&2
  exit 1
fi

test -s "$BAD_OUTPUT"

printf 'validate_stack_capabilities_test: OK\n'
