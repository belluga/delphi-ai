---
description: Define the canonical no-context independent test-quality audit gate for end-of-implementation review, including trigger rules, package hygiene, retry discipline, and resolution handling.
---

# Method: Independent Test Quality Audit

## Purpose
Provide a dedicated end-of-implementation audit focused on the integrity and quality of the tests that justify delivery confidence.

This method exists to detect pass-the-test workarounds, weak assertions, retrofit-only coverage, brittle test rewrites, and other changes that can make validation look green without proving the product behavior that actually matters.
It is stricter than generic final review: it is specifically about whether the tests changed for the right reasons and whether the affected test surface is effective and efficient.
Gate-satisfying evidence must cover the full applicable `test-quality-audit` workload for the scoped stack and risk profile, not just a short answer to a few review questions.

## When It Applies
- `Required` when any test file, assertion, fixture, runner, helper, or audit-relevant test logic changed.
- `Required` when test confidence is materially part of delivery confidence, including:
  - bugfix or regression work;
  - behavior-defining changes;
  - shared contract/API/schema changes;
  - compatibility claims;
  - critical user journeys.
- `Recommended` for other TODOs that touch production behavior with non-trivial validation risk.
- `Not needed` only for low-risk non-behavioral work with no meaningful test impact.

## Inputs
- Tactical TODO under `foundation_documentation/todos/active/`.
- Frozen decisions / approved expectations.
- Bounded implementation diff.
- Bounded test diff, or an explicit record that no test diff exists.
- Validation evidence already collected.
- Expected behaviors / Definition of Done still in force.
- Residual risks or uncertainty that still matter to test confidence.

## Audit Lens
- Use `test-quality-audit` as the primary audit lens.
- The audit must explicitly answer:
  - whether changed test logic reflects a real product or contract change;
  - whether any changed test logic appears to exist mainly to make the suite pass;
  - whether the assertions are effective enough to catch the intended regression or behavior break;
  - whether the assertions and coverage are efficient rather than bloated, redundant, or brittle;
  - whether the changed and nearby tests actually cover the required behaviors and failure modes.
- When applicable, also challenge:
  - fail-first or test-first alignment;
  - bypass patterns (`skip`, overly broad stubs, test-only routes, silent mock fallbacks, DI/test harness shortcuts);
  - assertions that only prove transport status or absence of exceptions while missing business outcomes;
  - fixture/runner changes that quietly weaken the guarantees of the suite.

## Minimum Gate-Satisfying Outputs
- The audit evidence must include every applicable output expected by `test-quality-audit`, including:
  - audit framing for target stacks, compatibility intent, and critical user journeys in scope;
  - fail-first / test-first alignment assessment when bugfix, regression, or behavior-defining work is involved;
  - bypass scan results for skips, test-only shortcuts, overly broad stubs, silent fallbacks, and similar masking patterns;
  - real-backend, fallback, DI parity, CI parity, and platform-matrix checks whenever the scoped change or claim makes them relevant;
  - issue cards for every material finding;
  - failure modes / uncertainty notes that still matter to delivery confidence;
  - decision-adherence evidence when active TODO decisions are in scope.
- The five explicit audit questions in this method are mandatory, but they are not sufficient by themselves when the underlying `test-quality-audit` scope requires more.

## Package Hygiene
- The audit package must be bounded. Do not hand the full session transcript or diffuse conversational history to the reviewer.
- Prefer one of these package shapes:
  - `bounded-file-set`: only the implementation/test surfaces and evidence needed for the audit;
  - `bounded-summary`: a concise structured summary of the test-relevant package.
- If using a `bounded-summary`, it must include at minimum:
  - frozen baseline / approved expectations;
  - approved scope boundary;
  - bounded implementation summary;
  - bounded test summary with explicit changed files or explicit `no test diff`;
  - validation evidence index;
  - expected behaviors / Definition of Done;
  - residual risks / unknowns still relevant to validation confidence;
  - any existing blockers or waivers already affecting the test lane.
- Preserve concrete test deltas and expectations instead of paraphrasing them into soft language.

## Required-Gate Waiver Control
- If a `required` independent test-quality audit cannot be completed after one retry, a `blocked` record alone does not permit `Completed` or `Production-Ready`.
- Only the current human approval authority for the TODO may waive a required test-quality audit gate.
- The waiver record must include:
  - `waiver_reason`
  - `approver_id`
  - `approval_reference`
  - `mitigation_summary`
  - `follow_up_owner`
  - `follow_up_task_id`

## Procedure
1. Record the audit decision in the TODO as `required|recommended|not_needed` with rationale.
2. Build the bounded test-audit package.
   - If orchestration tooling is desired, derive a dispatch packet with `python3 delphi-ai/tools/subagent_review_dispatch.py --review-kind test_quality_audit ...`.
3. Run one fresh auxiliary audit with no inherited thread context.
   - If a subagent is available in the environment, use that subagent with `fork_context=false`.
   - If no subagent is available, document the constraint and optionally run a bounded no-context self-review from the package only as supporting evidence; this does not satisfy a `required` independent audit gate by itself.
   - In other environments, use the closest equivalent that guarantees no prior thread contamination.
4. Prompt the reviewer to return findings first, ordered by severity, and to stay focused on test quality rather than reopen the full architecture.
   - Require explicit positions on:
     - product/test delta alignment;
     - pass-the-test workaround risk;
     - assertion efficacy;
     - assertion efficiency;
     - coverage sufficiency for required behaviors and failure modes;
     - fail-first/test-first alignment when relevant.
5. Treat the audit as challenge evidence only:
   - advisory, never authoritative by itself;
   - it may block closure if it exposes weak or misleading validation, but it does not replace the TODO contract or user approval model.
6. If the first no-context audit attempt fails or times out, retry once with a tighter package.
7. If a `required` audit still cannot be obtained after one retry:
   - record the tooling limitation explicitly;
   - do not silently treat bounded self-review as equivalent to a true fresh no-context external audit;
   - require either a blocker state or an explicit waiver before `Completed` or `Production-Ready`;
   - treat `blocked` as non-satisfying until the gate is actually run or explicitly waived by the approval authority.
8. Resolve every material finding explicitly in the TODO as one of:
   - `Integrated`
   - `Challenged`
   - `Deferred with rationale`
   - If structured reviewer JSON was used, merge it with `python3 delphi-ai/tools/subagent_review_merge.py ...` before recording the authoritative resolution.
   - Prefer the machine-checkable resolution table from `templates/todo_template.md`, then derive `*-resolution.json` with `python3 delphi-ai/tools/gate_finding_resolution_extract.py --review-kind test_quality_audit ...` when metrics are in scope.
9. If the audit invalidates the claimed Definition of Done or shows that test changes do not map to real product change, treat delivery confidence as broken until the tests or scope are corrected.

## Outputs
- A recorded audit decision (`required|recommended|not_needed`) with rationale.
- A bounded audit package reference.
- Findings summarized in the TODO with explicit resolution status.
- A blocker or waiver record if a required independent audit could not be executed.

## Non-Authority Rule
- Fresh auxiliary audits are intentionally independent, but they do not own the decision.
- Delivery authority remains the tactical TODO, the decision-adherence gates, and the normal approval model.
