---
name: test-orchestration-suite
description: "Orchestrate Laravel/Flutter/Web test execution with explicit suite decisions, gate sequencing, and adherence validation before delivery."
---

# Test Orchestration Suite

## Purpose
Provide a single, consistent workflow to execute and validate tests across Laravel, Flutter, and Web with explicit gates, fix-loop controls, and baseline adherence evidence.

## Scope Controls
- This skill coordinates execution; it does not bypass TODO governance for code/doc changes.
- Classify orchestration scope:
  - `small`: one stack or targeted rerun.
  - `medium`: multi-stack with one checkpoint before continue.
  - `big`: end-to-end run with checkpointed stage approvals.

## Orchestration Flow (Baseline)
1. Laravel tests (local Mongo).
2. Flutter unit + widget tests.
3. Flutter integration tests (real backend when compatibility matters).
4. Build web bundle.
5. Web navigation tests in `web-app`.
6. Compatibility gate: bundle metadata matches pinned Flutter commit.
7. Final report with decision-adherence status.

## Decision Gate: Compatibility vs Speed
- If scope includes compatibility/integration/e2e, real-backend integration is mandatory.
- If scope is unit-only regression, unit/widget suites may be sufficient.
- Freeze this decision before execution as `D-RUN-*`.

## Stage Procedure
1. **Plan and freeze**
   - Record `D-RUN-*` decisions for required suites, sequence, fail-fast behavior, and acceptance criteria.
2. **Execute stages in order**
   - Stop on first failed gate.
3. **Fix loop control**
   - If a fix is needed, apply TODO discipline (ephemeral or tactical lane as eligible), get approvals, then rerun failed stage.
4. **Failure Modes and uncertainty**
   - Capture edge cases (flaky env, backend mismatch, metadata mismatch), assumptions, unknowns, and confidence.
5. **Decision Adherence Validation**
   - Validate each `D-RUN-*` decision as `Adherent` or `Exception` with evidence.
   - Unresolved `Exception` blocks run closure.

## Laravel Stage
- Run against local MongoDB with replica set.
- Never use Atlas in CI-oriented flows.
- On failure, stop and escalate with actionable error context.

## Flutter Stage
- Run unit + widget first.
- For unstable environments, use resilient detached runner when appropriate.
- Run integration with domain/scheme overrides for local backend.
- No mock fallback when real backend is required.

## Web Stage
- Tests live only in `web-app`.
- Validate home load, primary route, and one critical CTA flow.
- Enforce metadata pin check before declaring success.

## Required Outputs
- Concise stage report:
  - suites run
  - passed/failed gates
  - reruns/fix loops executed
  - follow-up actions
- Decision-adherence table for `D-RUN-*` decisions.

## Done Criteria
- Requested suites completed with expected gate behavior.
- Compatibility gates satisfied when in scope.
- Decision-adherence table fully resolved.
- Any residual risk documented explicitly.
