---
name: wf-docker-independent-final-review-method
description: "Workflow: MUST use whenever a tactical TODO needs an independent no-context external review of the implemented result before closure because complexity or impact is materially high."
---

# Method: Independent No-Context Final Review

## Purpose
Run the canonical delivery-side final review once `wf-docker-audit-escalation-method` has derived the final-review floor.

## Triggers
- `wf-docker-audit-escalation-method` marks `final_review` as `required|recommended`.
- The user explicitly asks for an external final review.

## Inputs
- Tactical TODO under `foundation_documentation/todos/active/`.
- Implemented change package and delivery evidence.
- A bounded final-review package (`bounded-file-set` or `bounded-summary`).

## Procedure
1. Use the latest successful audit-escalation guard output as the minimum decision authority for this gate.
2. Build a bounded package; do not pass the whole session transcript.
   - If using a `bounded-summary`, include at minimum: frozen baseline, approved scope boundary, bounded touched-surface/diff summary, adherence status, validation evidence index, test-quality-audit evidence/status, residual risks, existing waivers, and unresolved verification debt.
   - When using subagents programmatically, derive a dispatch packet with `python3 delphi-ai/tools/subagent_review_dispatch.py --review-kind final_review ...`.
3. Use a fresh auxiliary reviewer with no inherited thread context.
4. Ask for findings first, ordered by severity, focusing on regressions, adherence, missing/weak evidence, missing full applicable test-quality-audit outputs, weak or bypass-prone test logic, performance or elegance regressions, structural regressions, and residual risk rather than redesign.
5. Retry once with a tighter package if the first attempt fails or times out.
6. If a required final review still cannot be obtained, only the current human approval authority may waive it; `blocked` alone does not satisfy closure.
7. Resolve each material finding as `Integrated|Challenged|Deferred with rationale`.
   - If reviewers returned structured JSON, merge it with `python3 delphi-ai/tools/subagent_review_merge.py ...` before recording the authoritative resolution.
8. Treat `audit-protocol-triple-review` as additive only; it does not silently replace a required final review unless a future canonical rule explicitly authorizes that replacement.

## Outputs
- Final-review gate decision with rationale.
- Fresh no-context final-review findings.
- Explicit finding-resolution record in the TODO.
