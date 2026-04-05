---
description: Define the canonical no-context external final-review gate for implemented tactical TODOs, including trigger rules, bounded review packages, retry discipline, and resolution handling.
---

# Method: Independent No-Context Final Review

## Purpose
Provide a repeatable external review lane for implemented tactical TODOs whose complexity or impact is high enough that a fresh reviewer with no inherited thread context materially improves confidence before closure.

This method critiques the delivered implementation and its evidence. It is not a late-stage redesign gate unless the reviewer finds a material defect or approval-breaking divergence.

## When It Applies
- Always `required` for tactical TODOs classified as `big`.
- `Required` for `medium` tactical TODOs when any of the following are true:
  - blast radius is `cross-module`;
  - the TODO changes public contract/API/schema/route/auth/payment behavior;
  - the TODO changes runtime/infra-sensitive paths such as queue/worker/realtime/ingress/runtime configuration;
  - the TODO intentionally supersedes canonical module decisions;
  - the Plan Review Gate contains any `high` severity issue card.
- `Recommended` for other `medium` tactical TODOs.
- `Not needed` only for low-risk `small` TODOs unless the user explicitly asks for an external final review anyway.

## Review Focus
- decision adherence vs frozen baseline
- regressions and behavioral drift
- missing/weak validation evidence
- missing, weak, or bypass-prone test-audit evidence
- security/performance residual risks already present in the delivery packet
- elegance regressions (loss of simplicity, coherence, or minimal incidental complexity)
- structural regressions caused by brittle workarounds or structural shortcuts, such as ad hoc patches, layered patches over unresolved defects, contract bypasses, opportunistic duplication, hidden coupling, or other avoidable structural debt
- verification debt and waiver quality

The reviewer should not reopen the whole architecture by default. Only a material defect, approval-breaking divergence, or clearly insufficient evidence may force a broader reset.

## Inputs
- Tactical TODO under `foundation_documentation/todos/active/`.
- Implemented change package (diff or bounded touched-surface set).
- Decision Adherence Validation and Module Decision Consistency Validation.
- Validation/test output, test-quality-audit evidence from `wf-docker-independent-test-quality-audit-method`, security/performance evidence, and verification-debt evidence already collected for delivery.
- A bounded final-review package:
  - either a curated file/evidence set,
  - or a concise structured delivery summary.

## Package Hygiene
- The review package must be bounded. Do not hand the full session transcript or diffuse conversational history to the reviewer.
- Prefer one of these package shapes:
  - `bounded-file-set`: only the touched files/diffs and final evidence needed to critique delivery;
  - `bounded-summary`: a concise structured summary containing frozen decisions, final adherence status, validation evidence, residual risks, waivers, and unresolved debt.
- If using a `bounded-summary`, it must include at minimum:
  - frozen baseline / approved decision set;
  - approved scope boundary;
  - bounded touched-surface or diff summary;
  - decision-adherence and module-consistency status;
  - validation evidence index;
  - test-quality-audit evidence and status;
  - residual risks;
  - existing waivers and unresolved verification debt.
- Preserve concrete evidence and explicit residual risks rather than smoothing them into generic prose.

## Required-Gate Waiver Control
- If a `required` no-context final review cannot be completed after one retry, a `blocked` record alone does not permit `Completed` or `Production-Ready`.
- Only the current human approval authority for the TODO may waive a required final-review gate.
- The waiver record must include:
  - `waiver_reason`
  - `approver_id`
  - `approval_reference`
  - `mitigation_summary`
  - `follow_up_owner`
  - `follow_up_task_id`

## Procedure
1. Record the final-review decision in the TODO as `required|recommended|not_needed` with rationale.
2. Build the bounded final-review package.
3. Run one fresh auxiliary final review with no inherited thread context.
   - If a subagent is available in the environment, use that subagent with `fork_context=false`.
   - If no subagent is available, document the constraint and run a bounded no-context self-review from the package only.
   - In other environments, use the closest equivalent that guarantees no prior thread contamination.
4. Prompt the reviewer to return findings first, ordered by severity, focusing on:
   - bugs/regressions;
   - adherence breaks;
   - missing or weak validation;
   - missing, weak, bypass-prone, or incomplete test logic and test-audit evidence;
   - waiver/debt misuse;
   - residual operational/security/performance risks;
   - elegance regressions;
   - structural regressions caused by brittle workarounds or structural shortcuts that should block closure.
5. Treat the review as challenge evidence only:
   - advisory, never authoritative by itself;
   - it may block closure if it exposes unresolved material defects, but it does not replace the TODO contract or user approval model.
6. If the first no-context final-review attempt fails or times out, retry once with a tighter package.
7. If a `required` final review still cannot be obtained after one retry:
   - record the tooling limitation explicitly;
   - do not silently treat bounded self-review as equivalent to a true fresh no-context final review;
   - require either a blocker state or an explicit waiver before `Completed` or `Production-Ready`;
   - treat `blocked` as non-satisfying until the gate is actually run or explicitly waived by the approval authority.
8. Resolve every material finding explicitly in the TODO as one of:
   - `Integrated`
   - `Challenged`
   - `Deferred with rationale`
9. If the final review reveals:
   - an implementation defect within approved scope, fix it and refresh the affected evidence;
   - an adherence break, block closure until the decision package is corrected or renewed approval is obtained;
   - a true approval-material scope/design change, refresh the TODO and request renewed `APROVADO` before continuing.

## Outputs
- A recorded final-review decision (`required|recommended|not_needed`) with rationale.
- A bounded final-review package reference.
- Findings summarized in the TODO with explicit resolution status.
- A blocker or waiver record if a required no-context final review could not be executed.

## Non-Authority Rule
- Fresh auxiliary final reviews are intentionally independent, but they do not own the delivery decision.
- Closure authority remains the tactical TODO, explicit approvals, and the normal adherence/risk gates.
