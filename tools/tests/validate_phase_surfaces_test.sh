#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOL="$ROOT_DIR/tools/validate_phase_surfaces.py"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

GOOD="$TMP_DIR/good.yaml"
BAD_MISSING_PHASE="$TMP_DIR/bad-missing-phase.yaml"
BAD_MALFORMED="$TMP_DIR/bad-malformed.yaml"
BAD_OUTPUT="$TMP_DIR/bad.out"

cat > "$GOOD" <<'EOF'
schema_version: 1

phase_groups:
  - name: todo-driven-fixture
    umbrella_skill: wf-docker-todo-driven-execution-method
    require_register: true
    phases:
      - wf-docker-todo-lane-framing-method
      - wf-docker-todo-contract-refinement-method
    workflows:
      - workflows/docker/todo-lane-framing-method.md
    clinerules:
      - .clinerules/workflows/docker-todo-lane-framing-method.md
EOF

python3 "$TOOL" --root "$ROOT_DIR" --config "$GOOD"

cat > "$BAD_MISSING_PHASE" <<'EOF'
schema_version: 1

phase_groups:
  - name: missing-phase-fixture
    umbrella_skill: wf-docker-todo-driven-execution-method
    require_register: true
    phases:
      - wf-docker-todo-lane-framing-method
      - missing-phase-skill
    workflows: []
    clinerules: []
EOF

if python3 "$TOOL" --root "$ROOT_DIR" --config "$BAD_MISSING_PHASE" >"$BAD_OUTPUT" 2>&1; then
  cat "$BAD_OUTPUT"
  printf 'expected missing phase config to fail\n' >&2
  exit 1
fi
grep -q "missing phase skill" "$BAD_OUTPUT"

cat > "$BAD_MALFORMED" <<'EOF'
schema_version: 1

phase_groups:
  - name: malformed
    require_register: true
    phases: []
EOF

if python3 "$TOOL" --root "$ROOT_DIR" --config "$BAD_MALFORMED" >"$BAD_OUTPUT" 2>&1; then
  cat "$BAD_OUTPUT"
  printf 'expected malformed config to fail\n' >&2
  exit 1
fi
grep -q "missing umbrella_skill" "$BAD_OUTPUT"
grep -q "phases must include at least one phase skill" "$BAD_OUTPUT"

printf 'validate_phase_surfaces_test: OK\n'
