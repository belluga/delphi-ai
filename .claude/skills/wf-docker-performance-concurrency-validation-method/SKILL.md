---
name: wf-docker-performance-concurrency-validation-method
description: "Workflow: MUST use whenever a tactical TODO needs the canonical four-lane performance/concurrency validation policy, closed registries, gate deadlines, or artifact rules."
---

# Method: Performance & Concurrency Validation Lanes

## Purpose
Provide the canonical `pcv-1` policy package for tactical TODO performance/concurrency validation. This method defines the four mandatory lanes, closed registries, gate deadlines, state machine, waiver governance, and machine-checkable artifact rules.

## Triggers
- A tactical TODO reaches `Performance & Concurrency Risk Assessment`.
- A lane needs to be classified as `required|recommended|not_needed`.
- A waiver, missed gate, or artifact contract for `EPS|FRC|BCI|RLS` must be interpreted.
- A review asks whether performance/concurrency evidence is sufficient to satisfy a TODO gate.

## Inputs
- Tactical TODO under `foundation_documentation/todos/active/`.
- Current delivery stage and gate boundary (`Local-Implemented` or `Production-Ready`).
- Any lane artifacts under `foundation_documentation/artifacts/tmp/<run-id>/...`.

## Procedure
1. Confirm the TODO is tactical and approved (`APROVADO`).
2. Load the canonical policy package from `workflows/docker/performance-concurrency-validation-method.md`.
3. Ensure the TODO contains exactly four lane rows: `EPS`, `FRC`, `BCI`, `RLS`.
4. Classify each lane using only the closed registries and glossary terms from `pcv-1`.
5. Enforce the lane state machine and gate deadlines exactly as written.
6. Reject prose-only evidence; require machine-checkable artifact JSON plus hashes.
7. Reject silent downgrades, silent `not_applicable` transitions, and gate-satisfying `blocked|missed_gate|expired` states.
8. If a lane must be waived, apply the distinct executor/reviewer/approver rules from the policy package.

## Outputs
- A tactical TODO with four resolved lane rows and any required conditional objects.
- Lane artifacts that satisfy the `pcv-1` artifact contract.
- Explicit waiver/blocker/missed-gate records when the ideal path cannot be completed.
