#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VALIDATOR="$ROOT_DIR/deterministic/core/todo_deterministic_validator.py"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

OUTPUT_FILE="$TMP_DIR/todo-deterministic-validator.out"

assert_no_go() {
  local todo_file="$1"
  if python3 "$VALIDATOR" --todo "$todo_file" > "$OUTPUT_FILE" 2>&1; then
    cat "$OUTPUT_FILE"
    printf 'expected no-go for %s\n' "$todo_file" >&2
    exit 1
  fi
  grep -q "Result: FAIL" "$OUTPUT_FILE"
}

assert_go() {
  local todo_file="$1"
  python3 "$VALIDATOR" --todo "$todo_file" > "$OUTPUT_FILE" 2>&1
  grep -q "Result: PASS" "$OUTPUT_FILE"
}

ACTIVE_ROOT="$TMP_DIR/project/foundation_documentation/todos/active/core"
mkdir -p "$ACTIVE_ROOT"

cat > "$ACTIVE_ROOT/missing-active-work-state.md" <<'TODO'
# TODO: Missing Active Work State

## Artifact Identity
- **Artifact type:** `tactical_execution_contract`

## Contract Boundary
- bounded

## Delivery Status Canon
- **Current delivery stage:** `Pending`
- **Qualifiers:** `none`
- **Next exact step:** Implement the first bounded step.
TODO

assert_no_go "$ACTIVE_ROOT/missing-active-work-state.md"
grep -q "TODO-ACTIVE-WORK-STATE-MISSING" "$OUTPUT_FILE"
grep -q "TODO-ACTIVE-WORK-STATE-INVALID" "$OUTPUT_FILE"

cat > "$ACTIVE_ROOT/blocked-work-state-mismatch.md" <<'TODO'
# TODO: Blocked Work State Mismatch

## Artifact Identity
- **Artifact type:** `tactical_execution_contract`

## Contract Boundary
- bounded

## Delivery Status Canon
- **Current delivery stage:** `Pending`
- **Qualifiers:** `Blocked`
- **Next exact step:** Await the missing dependency.

## Active Work State
- **Work state:** `review`
- **Why this state now:** Waiting on an external unblocker.
- **Exit condition:** The dependency becomes available.

## Blocker Notes
- **Blocker:** missing dependency
- **Why blocked now:** the dependency is down
- **What unblocks it:** restore the dependency
- **Owner / source:** external provider
- **Last confirmed truth:** local implementation is unchanged
TODO

assert_no_go "$ACTIVE_ROOT/blocked-work-state-mismatch.md"
grep -q "TODO-ACTIVE-WORK-BLOCKED-STATE-MISSING" "$OUTPUT_FILE"

cat > "$ACTIVE_ROOT/cutover-gate-supported.md" <<'TODO'
# TODO: Cutover Gate Supported

## Artifact Identity
- **Artifact type:** `tactical_execution_contract`

## Contract Boundary
- bounded

## Delivery Status Canon
- **Current delivery stage:** `Pending`
- **Qualifiers:** `none`
- **Next exact step:** Run the bounded cutover review and then continue implementation.

## Active Work State
- **Work state:** `implementation`
- **Why this state now:** The TODO is still gathering implementation and review evidence.
- **Exit condition:** Implementation is complete and the package moves into review.

## Independent Cutover Integrity Audit Gate
- **Cutover audit decision:** `required`
- **Cutover audit status:** `findings_integrated`
- **Evidence / reference:** `foundation_documentation/artifacts/cutover-audit.md`
- **Waiver authority / reference (required if waived):** `n/a`
- | Finding ID | Resolution (`Integrated|Challenged|Deferred`) | Usefulness (`useful|noise|mixed|unknown`) | Formalizable (`yes|partial|no|unknown`) | Candidate Rule Level (`paced|project|none|unknown`) | Candidate Rule ID | Rationale / Evidence |
- | --- | --- | --- | --- | --- | --- | --- |
- | `CUT-1` | `Deferred` | `mixed` | `partial` | `project` | `n/a` | Approved temporary compatibility bridge with explicit removal criteria. |
TODO

assert_go "$ACTIVE_ROOT/cutover-gate-supported.md"

printf 'todo_deterministic_validator_test: OK\n'
