---
name: wf-docker-independent-test-quality-audit-method
description: "Workflow: MUST use whenever the delivery needs a dedicated no-context end-of-implementation audit of test quality, especially when test logic changed or test confidence is material."
---

# Method: Independent Test Quality Audit

## Purpose
Run a fresh external audit focused on whether the tests that justify delivery confidence are actually trustworthy.

## Triggers
- Test files, assertions, fixtures, runners, or related test logic changed.
- The TODO is a bugfix/regression, behavior-defining change, shared contract/API/schema change, compatibility claim, or critical user journey.
- The user explicitly asks for a heavy external audit of tests.

## Inputs
- Tactical TODO under `foundation_documentation/todos/active/`.
- Bounded implementation diff.
- Bounded test diff (or explicit `no test diff`).
- Validation evidence already collected.
- Frozen expectations / Definition of Done.

## Procedure
1. Decide whether the gate is `required|recommended|not_needed`.
2. Run `wf-docker-independent-test-quality-audit-method` using `test-quality-audit` as the primary audit lens.
3. Build a bounded package; do not pass the whole session transcript.
4. Require gate-satisfying evidence to cover the full applicable `test-quality-audit` workload, not just a short answer set.
5. Use a fresh no-context external reviewer/subagent when available.
6. If no subagent/external reviewer is available, any bounded self-review is supporting evidence only and does not satisfy a `required` gate by itself.
7. Ask for findings first, ordered by severity, explicitly covering product/test delta alignment, workaround risk, assertion efficacy, assertion efficiency, coverage sufficiency, and fail-first/TDD alignment when relevant.
8. Retry once with a tighter package if the first attempt fails or times out.
9. If a required audit still cannot be obtained, only the current human approval authority may waive it; `blocked` alone does not satisfy delivery.
10. Resolve each material finding as `Integrated|Challenged|Deferred with rationale`.

## Outputs
- Test-audit gate decision with rationale.
- Fresh no-context audit findings.
- Explicit finding-resolution record in the TODO.
