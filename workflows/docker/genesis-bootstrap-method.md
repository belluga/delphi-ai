---
description: Run Genesis as a structured no-code bootstrap flow driven by capped TODOs, moving from interview through constitution to module decomposition without collapsing into tactical implementation.
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
- Classify each newly confirmed answer into its intended canonical home before moving to the next interview turn.

### `GEN-02 Gap Closure + Project Constitution`
- Close or explicitly defer the gaps that materially affect cross-module rules, actor boundaries, scope topology, or system invariants.
- Use the active Genesis capped TODO as the live decision ledger.
- Promote approved stable outcomes into `project_constitution.md` and `system_roadmap.md` as they become real.
- Do not wait for all uncertainty to disappear before writing the constitution, but do not freeze constitution rules from unvalidated inference.

### `GEN-03 Module Decomposition`
- Split the now-clearer system into modules / bounded contexts.
- Do not force the user to originate the module taxonomy from a blank abstraction prompt when Delphi already has enough confirmed truth to propose a first-pass decomposition.
- Prefer a suggestive pass: synthesize candidate capability blocks / module candidates from the confirmed workflows, actors, and business rules already gathered; present that proposal as a proposal; then ask the user to confirm, reject, merge, split, or rename it.
- Treat the evidence as sufficient for a first-pass proposal when Delphi can already point to:
  - one or more confirmed actor or ownership boundaries;
  - one or more confirmed end-to-end workflows or lifecycle phases;
  - one or more confirmed business rules or responsibility splits that naturally separate concerns.
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
5. After each answered interview turn, classify the newly confirmed content before proceeding:
   - `project_mandate.md` for enduring purpose, business principles, target outcomes, and high-level business intent;
   - `domain_entities.md` for domain vocabulary, actor labels, and entity definitions;
   - `project_constitution.md` for cross-module rules, system-wide invariants, ownership boundaries, scope rules, and project-level truths;
   - `system_roadmap.md` for staged sequencing, strategic phases, and major follow-up fronts;
   - `modules/*.md` for module-local workflows, contracts, APIs, and data shapes when the module boundary already exists;
   - Genesis capped TODO / bootstrap packet only for unresolved, partial, deferred, rejected, or still-tracked interview content.
6. Promote content into canonical docs only when it is stable enough to survive the next interview turn without likely reversal.
   - If the correct home is module-local but the module boundary is not ready yet, record the intended future destination in the Genesis ledger instead of parking the item in `project_mandate.md`.
   - Prefer one primary home plus cross-references instead of duplicating the same truth across mandate, constitution, roadmap, modules, and Genesis artifacts.
7. When useful, create or update a companion bootstrap packet under `foundation_documentation/artifacts/**` as the higher-level snapshot.
8. Explicitly classify each unresolved item as one of:
   - still blocking Genesis;
   - intentionally deferred but bounded;
   - already answered by existing canon.
9. When `GEN-03` is active and Delphi has enough confirmed truth to infer a first-pass decomposition, lead with a suggested capability/module map instead of an abstract taxonomy question.
   - Derive the suggestion from already-confirmed business flows, actors, ownership boundaries, and decision points.
   - Phrase it as a working proposal, not as canon.
   - Make the user-facing question concrete: confirm, split, merge, rename, or reject the proposed blocks.
   - If the minimum evidence test above is met, Delphi should still propose a first-pass map even if it expects the user to refine or partially reject it.
   - Only fall back to a generic “what are the business capabilities/modules?” question when Delphi truly lacks enough evidence to make a useful first suggestion without hallucinating structure.
   - Before using that fallback, Delphi must explicitly state:
     - which confirmed facts already exist;
     - why those facts still do not support a safe first-pass decomposition;
     - the single highest-value missing answer needed to unlock a useful proposal.
   - In that fallback case, ask at most one narrow gap-closing question before trying the suggested decomposition again.
10. Do not open a tactical implementation TODO from Genesis until the remaining gaps are sufficiently closed or explicitly deferred.
11. When the first canonical package is stable enough for ongoing stewardship, hand off:
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
- Stable answers are routed continuously into the correct canonical home instead of accumulating in `project_mandate.md` or the Genesis packet as generic holding areas.
- Constitution, roadmap, and module docs are promoted from validated discovery, not from convenience assumptions.
- During `GEN-03`, Delphi behaves suggestively when enough evidence exists: it proposes a first-pass decomposition before asking the user to invent the taxonomy from scratch.
- During `GEN-03`, generic taxonomy questions are a justified fallback only after Delphi explicitly fails the minimum-evidence test and names the single missing answer blocking a safe proposal.
- No tactical implementation authority is implied until Genesis hands off deliberately.
