# TODO: Completion Guard Mutation Evidence Scoping

## Artifact Identity
- **Artifact type:** `tactical_execution_contract`

## Context
`todo_completion_guard.py` checks mutation evidence against the complete Completion Evidence Matrix row, including the criterion text. A correct rejected-mutation criterion necessarily says `no mutation`, which the helper treats as evidence that no mutation test ran. This makes valid real-backend PATCH/DELETE rejection evidence impossible to admit.

## Contract Boundary
- Evaluate navigation and mutation evidence only from evidence-bearing cells, never from the criterion wording.
- Preserve rejection of rows whose evidence itself says `no mutation`, `read-only`, or equivalent.
- This changes Delphi guard semantics only; it does not waive any product runtime or mutation evidence requirement.

## Scope
- [x] Add a RED fixture whose criterion says `no mutation` while its evidence records a real-backend PATCH mutation test.
- [x] Scope mutation-evidence detection to evidence cells and retain its negative phrases.
- [x] Run the focused guard regression suite.

## Definition of Done
- [x] A real-backend rejected-mutation evidence row can satisfy the completion guard when its criterion says `no mutation`.
- [x] An evidence cell that itself says `no mutation` remains rejected.

## Validation Steps
- [x] Run `bash tools/tests/todo_completion_guard_test.sh`.

## Test Strategy
- **Strategy:** `test-first`
- **RED target:** a completed local TODO with an admin PATCH rejection criterion and real-backend mutation evidence is currently rejected only because the criterion text is included in the evidence scan.

## Complexity
- **Level (`small|medium|big`):** `small`
- **Checkpoint policy:** `one focused guard test`

## Approval
- **Approval status:** `approved_for_blocker_remediation`
- **Approval source:** active product implementation GOAL requires discovered blocking work to be recorded and resolved through TODO-driven execution.
- **Scope limit:** deterministic guard/test correction only.

## Implementation Evidence
- **RED:** the added `rejected-mutation-real-backend-evidence.md` fixture caused `bash -x tools/tests/todo_completion_guard_test.sh` to stop at its `assert_go`, because the guard inspected `no mutation` in the criterion rather than the evidence cells.
- **GREEN:** `row_has_mutation_coverage(row[3:])` now receives only Evidence Type through Notes. `bash tools/tests/todo_completion_guard_test.sh` passes, and the U03 completion guard returns `Overall outcome: go` with its real-backend PATCH/DELETE evidence.
