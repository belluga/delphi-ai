---
name: wf-docker-independent-final-review-method
description: "Workflow: MUST use whenever a tactical TODO needs an independent no-context external review of the implemented result before closure because complexity or impact is materially high."
---

# Method: Independent No-Context Final Review

## Purpose
Run a fresh external review of the implemented result for higher-complexity or higher-impact tactical TODOs without contaminating the reviewer with the main thread context.

## Triggers
- A tactical TODO is `big`.
- A `medium` tactical TODO has high-impact signals such as cross-module blast radius, public contract/runtime-sensitive changes, intentional module supersede, or a `high` severity plan-review issue.
- The user explicitly asks for an external final review.

## Inputs
- Tactical TODO under `foundation_documentation/todos/active/`.
- Implemented change package and delivery evidence.
- A bounded final-review package (`bounded-file-set` or `bounded-summary`).

## Procedure
1. Decide whether the final-review gate is `required|recommended|not_needed`.
2. Build a bounded package; do not pass the whole session transcript.
   - If using a `bounded-summary`, include at minimum: frozen baseline, approved scope boundary, bounded touched-surface/diff summary, adherence status, validation evidence index, residual risks, existing waivers, and unresolved verification debt.
3. Use a fresh auxiliary reviewer with no inherited thread context.
4. Ask for findings first, ordered by severity, focusing on regressions, adherence, and missing evidence rather than redesign.
5. Retry once with a tighter package if the first attempt fails or times out.
6. If a required final review still cannot be obtained, only the current human approval authority may waive it; `blocked` alone does not satisfy closure.
7. Resolve each material finding as `Integrated|Challenged|Deferred with rationale`.

## Outputs
- Final-review gate decision with rationale.
- Fresh no-context final-review findings.
- Explicit finding-resolution record in the TODO.
