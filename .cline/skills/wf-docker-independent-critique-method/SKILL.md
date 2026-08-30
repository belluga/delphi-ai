---
name: wf-docker-independent-critique-method
description: "Workflow: MUST use whenever a tactical TODO needs an independent no-context auxiliary critique before approval because complexity or impact is materially high."
---

# Method: Independent No-Context Critique

## Purpose
Run the canonical planning-side critique lane once `wf-docker-audit-escalation-method` has derived the critique floor.

## Triggers
- `wf-docker-audit-escalation-method` marks `critique` as `required|recommended`.
- The user explicitly asks for an independent or no-context critique.

## Inputs
- Tactical TODO under `foundation_documentation/todos/active/`.
- Pushed review baseline recorded in `Gate: Review Baseline Freeze`.
- Frozen decisions, assumptions, execution plan, and plan-review output.
- A bounded critique package (`bounded-file-set` or `bounded-summary`).

## Procedure
1. Use the latest successful audit-escalation guard output as the minimum decision authority for this gate.
2. Confirm the review baseline freeze is already committed and pushed before the first fresh critique run.
3. Build a bounded package; do not pass the whole session transcript.
   - If using a `bounded-summary`, include at minimum: frozen decisions, approved scope boundary, assumptions preview, execution plan summary, material issue cards, residual risks, and existing waivers/blockers.
   - When using subagents programmatically, derive this planning critique packet with `python3 delphi-ai/tools/subagent_review_dispatch.py --review-kind critique --lifecycle planning ...`; delivery-side critique callers use `--lifecycle delivery`.
4. Use a fresh internal reviewer with no inherited thread context; it must not be the implementing agent. Do not invoke or treat an external provider as gate-satisfying evidence. Recycle only terminal inactive reviewer lanes; a live reviewer is never recyclable.
5. Ask for findings first, ordered by severity, with no implementation.
6. Treat reviewer lifecycle as status-based, not elapsed-time-based. While status is `pending_init` or `running`, wait without a rigid deadline; a polling timeout is not failure and requires continued waiting.
7. Do not interrupt, close, recycle, replace, duplicate, or repackage/shrink a live review.
8. Retry once only after objective terminal failure or explicit human cancellation, using the same complete gate-satisfying package by default. Change the package only to repair a concrete proven package defect while preserving the full rubric.
9. If a required critique still cannot be obtained, only the current human approval authority may waive it; `blocked` alone does not satisfy the gate.
10. Resolve each material finding as `Integrated|Challenged|Deferred with rationale`.
   - If reviewers returned structured JSON, merge it with `python3 delphi-ai/tools/subagent_review_merge.py ...` before recording the authoritative resolution.
11. After critique findings converge, run `python3 delphi-ai/tools/assumption_code_coherence_guard.py --todo <todo-path>` and record the result under `Gate: Assumption Code Coherence`.
12. Before approval resumes, run `python3 delphi-ai/tools/review_scope_drift_guard.py --todo <todo-path>` and return to the review loop if the guard reports material scope-governing drift against the pushed baseline.
13. Treat `audit-protocol-triple-review` as additive only; it remains the compatibility id for the dedicated delivery-side multi-lane audit and does not silently replace this planning critique gate.

## Outputs
- Critique gate decision with rationale.
- Fresh no-context critique findings.
- Explicit finding-resolution record in the TODO.
- Assumption-vs-code coherence result for the still-live assumptions.
- Review-scope-drift outcome against the pushed baseline before approval resumes, with renewed user scope validation whenever the guard returns `no-go`.
