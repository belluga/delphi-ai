---
name: wf-docker-genesis-bootstrap-method
description: "Workflow: MUST use whenever the scope matches this purpose: Run Genesis as a structured no-code bootstrap flow driven by capped TODOs, moving from interview through constitution to module decomposition without collapsing into tactical implementation."
---

# Method: Genesis Bootstrap

## Purpose
Run `Genesis / Product-Bootstrap` as a structured no-code flow that turns under-defined project intent into the first canonical package without drifting into tactical implementation too early.

## Triggers
- The active profile is `Genesis / Product-Bootstrap`.
- The project is still in inception or business-foundation refinement.
- The session needs a live no-code ledger to preserve decisions, gaps, and next interview fronts.

## Inputs
- User interviews, discovery notes, references, sketches, and prototypes.
- Any existing `foundation_documentation/**` surfaces already created.
- `templates/capped_todo_template.md` for the live Genesis TODO.
- `templates/project_bootstrap_packet_template.md` for the optional companion snapshot packet.

## Standard Genesis Sequence

### `GEN-01 Initial Interview`
- Capture confirmed truths.
- Capture explicit assumptions as assumptions, not as scope.
- Capture rejected inferences so Delphi does not reintroduce them later.
- Capture the open gap register and next interview front.

### `GEN-02 Gap Closure + Project Constitution`
- Close or explicitly defer the gaps that materially affect cross-module rules, actor boundaries, scope topology, or system invariants.
- Use the active Genesis capped TODO as the live decision ledger.
- Promote approved stable outcomes into `project_constitution.md` and `system_roadmap.md` as they become real.
- Do not wait for all uncertainty to disappear before writing the constitution, but do not freeze constitution rules from unvalidated inference.

### `GEN-03 Module Decomposition`
- Split the now-clearer system into modules / bounded contexts.
- Promote module-local contracts into `foundation_documentation/modules/*.md`.
- Leave partial coverage explicit where interview truth is still incomplete.
- Make the remaining deferred questions visible rather than hiding them inside module prose.

These phases may overlap, but the active Genesis capped TODO must always make the current phase explicit.

## Procedure
1. Confirm `Genesis / Product-Bootstrap` is still the correct active profile.
2. Create or update a capped TODO under `foundation_documentation/todos/active/` using `templates/capped_todo_template.md`.
3. Mark the current Genesis phase in that TODO (`GEN-01`, `GEN-02`, or `GEN-03`).
4. Use the capped TODO as the live ledger for:
   - confirmed truths;
   - open gaps;
   - rejected inferences;
   - next exact interview front.
5. When useful, create or update a companion bootstrap packet under `foundation_documentation/artifacts/**` as the higher-level snapshot.
6. Promote stable outcomes into canonical docs continuously:
   - `project_mandate.md` for project principles when needed;
   - `domain_entities.md` for domain vocabulary;
   - `project_constitution.md` for cross-module rules and invariants;
   - `system_roadmap.md` for staged strategic framing;
   - `modules/*.md` for module-local contracts.
7. Explicitly classify each unresolved item as one of:
   - still blocking Genesis;
   - intentionally deferred but bounded;
   - already answered by existing canon.
8. Do not open a tactical implementation TODO from Genesis until the remaining gaps are sufficiently closed or explicitly deferred.
9. When the first canonical package is stable enough for ongoing stewardship, hand off:
   - to `Strategic / CTO-Tech-Lead` for continued constitutional governance; or
   - to `Operational / Coder` only when implementation can proceed from approved canon plus a true tactical TODO.

## Outputs
- A live Genesis capped TODO under `foundation_documentation/todos/active/`.
- Optional companion bootstrap packet under `foundation_documentation/artifacts/**`.
- Progressive constitution/roadmap/module canonicalization grounded in interview truth.
- Explicit deferred list instead of hidden ambiguity.

## Validation
- The active Genesis ledger is a capped TODO and remains explicitly `no code`.
- The current Genesis phase is explicit in the active TODO.
- Rejected inferences are preserved so they do not silently return later.
- Constitution and module docs are promoted from validated discovery, not from convenience assumptions.
- No tactical implementation authority is implied until Genesis hands off deliberately.
