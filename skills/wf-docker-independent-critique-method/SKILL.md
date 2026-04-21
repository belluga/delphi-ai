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
- Frozen decisions, assumptions, execution plan, and plan-review output.
- A bounded critique package (`bounded-file-set` or `bounded-summary`).

## Procedure
1. Use the latest successful audit-escalation guard output as the minimum decision authority for this gate.
2. Build a bounded package; do not pass the whole session transcript.
   - If using a `bounded-summary`, include at minimum: frozen decisions, approved scope boundary, assumptions preview, execution plan summary, material issue cards, residual risks, and existing waivers/blockers.
   - When using subagents programmatically, derive a dispatch packet with `python3 delphi-ai/tools/subagent_review_dispatch.py --review-kind critique ...`.
3. Use a fresh auxiliary reviewer with no inherited thread context.
4. Ask for findings first, ordered by severity, with no implementation.
5. Retry once with a tighter package if the first attempt fails or times out.
6. If a required critique still cannot be obtained, only the current human approval authority may waive it; `blocked` alone does not satisfy the gate.
7. Resolve each material finding as `Integrated|Challenged|Deferred with rationale`.
   - If reviewers returned structured JSON, merge it with `python3 delphi-ai/tools/subagent_review_merge.py ...` before recording the authoritative resolution.
8. Treat `audit-protocol-triple-review` as additive only; it does not silently replace this planning critique gate.

## Outputs
- Critique gate decision with rationale.
- Fresh no-context critique findings.
- Explicit finding-resolution record in the TODO.
