#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GUARD="$ROOT_DIR/tools/todo_completion_guard.py"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

OUTPUT_FILE="$TMP_DIR/todo-completion-guard.out"

assert_no_go() {
  local todo_file="$1"
  if python3 "$GUARD" "$todo_file" > "$OUTPUT_FILE" 2>&1; then
    cat "$OUTPUT_FILE"
    printf 'expected no-go for %s\n' "$todo_file" >&2
    exit 1
  fi
  grep -q "Overall outcome: no-go" "$OUTPUT_FILE"
}

assert_go() {
  local todo_file="$1"
  python3 "$GUARD" "$todo_file" > "$OUTPUT_FILE" 2>&1
  grep -q "Overall outcome: go" "$OUTPUT_FILE"
}

cat > "$TMP_DIR/local-implemented-no-evidence.md" <<'TODO'
# TODO: Local Implemented No Evidence

## Delivery Status Canon
- **Current delivery stage:** `Local-Implemented-Audited`

## Scope
- [ ] Implement the release contract.

## Definition of Done
- [ ] All release guard evidence is complete.

## Validation Steps
- [ ] Unit test: guard regression script fails before the fix.
TODO

assert_no_go "$TMP_DIR/local-implemented-no-evidence.md"
grep -q "delivery_claim: True" "$OUTPUT_FILE"
grep -q "COMPLETION-EVIDENCE-MATRIX-MISSING" "$OUTPUT_FILE"
grep -q "CRITERION-CHECKLIST-UNCHECKED" "$OUTPUT_FILE"

cat > "$TMP_DIR/local-validated-no-evidence.md" <<'TODO'
# TODO: Local Validated No Evidence

## Delivery Status Canon
- **Current delivery stage:** `Local-Validated-Round03`

## Acceptance Criteria
- [ ] The validation claim has concrete evidence.

## Definition of Done
- [ ] The TODO cannot be closed on assertion alone.
TODO

assert_no_go "$TMP_DIR/local-validated-no-evidence.md"
grep -q "delivery_claim: True" "$OUTPUT_FILE"
grep -q "Acceptance Criteria item is still unchecked" "$OUTPUT_FILE"

cat > "$TMP_DIR/local-complete-no-evidence.md" <<'TODO'
# TODO: Local Complete No Evidence

## Delivery Status Canon
- **Current delivery stage:** `Local-Complete-Guard-Passed`

## Scope
- [ ] Close the release TODO.
TODO

assert_no_go "$TMP_DIR/local-complete-no-evidence.md"
grep -q "delivery_claim: True" "$OUTPUT_FILE"
grep -q "CRITERION-CHECKLIST-UNCHECKED" "$OUTPUT_FILE"

cat > "$TMP_DIR/incomplete-stage-is-not-delivery.md" <<'TODO'
# TODO: Incomplete Stage Is Not Delivery

## Delivery Status Canon
- **Current delivery stage:** `Incomplete`

## Scope
- [ ] Draft the release contract.
TODO

assert_go "$TMP_DIR/incomplete-stage-is-not-delivery.md"
grep -q "delivery_claim: False" "$OUTPUT_FILE"

cat > "$TMP_DIR/acceptance-missing-evidence.md" <<'TODO'
# TODO: Acceptance Missing Evidence

## Delivery Status Canon
- **Current delivery stage:** `Local-Implemented`

## Scope
- [x] Implement deterministic repository guard.

## Acceptance Criteria
- [x] The guard blocks incomplete delivery claims.

## Definition of Done
- [x] All guard regressions pass.

## Validation Steps
- [x] Unit test: completion guard regression script passes.

## Completion Evidence Matrix
| Criterion ID | Source Section | Criterion | Evidence Type | Evidence Artifact / Command | Runtime Target | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| SCOPE-01 | Scope | Implement deterministic repository guard. | automated | `bash tools/tests/todo_completion_guard_test.sh` | local shell | passed | completed |
| DOD-01 | Definition of Done | All guard regressions pass. | automated | `bash tools/tests/todo_completion_guard_test.sh` | local shell | passed | completed |
| VAL-01 | Validation Steps | Unit test: completion guard regression script passes. | automated | `bash tools/tests/todo_completion_guard_test.sh` | local shell | passed | completed |
TODO

assert_no_go "$TMP_DIR/acceptance-missing-evidence.md"
grep -q "Acceptance Criteria item lacks criterion-specific evidence" "$OUTPUT_FILE"

cat > "$TMP_DIR/complete-evidence.md" <<'TODO'
# TODO: Complete Evidence

## Delivery Status Canon
- **Current delivery stage:** `Local-Implemented`

## Scope
- [x] Implement deterministic repository guard.

## Out of Scope
- [ ] Ship unrelated future work.

## Acceptance Criteria
- [x] The guard blocks incomplete delivery claims.

## Definition of Done
- [x] All guard regressions pass.

## Validation Steps
- [x] Unit test: completion guard regression script passes.

## Completion Evidence Matrix (Local, Non-ADB)
| Criterion ID | Source Section | Criterion | Evidence Type | Evidence Artifact / Command | Runtime Target | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| SCOPE-01 | Scope | Implement deterministic repository guard. | automated | `bash tools/tests/todo_completion_guard_test.sh` | local shell | passed | completed |
| AC-01 | Acceptance Criteria | The guard blocks incomplete delivery claims. | automated | `bash tools/tests/todo_completion_guard_test.sh` | local shell | passed | completed |
| DOD-01 | Definition of Done | All guard regressions pass. | automated | `bash tools/tests/todo_completion_guard_test.sh` | local shell | passed | completed |
| VAL-01 | Validation Steps | Unit test: completion guard regression script passes. | automated | `bash tools/tests/todo_completion_guard_test.sh` | local shell | passed | completed |
TODO

assert_go "$TMP_DIR/complete-evidence.md"
grep -q "scope_count: 1" "$OUTPUT_FILE"
grep -q "acceptance_criteria_count: 1" "$OUTPUT_FILE"

printf 'todo_completion_guard_test: OK\n'
