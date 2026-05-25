---
description: Classify the TODO execution lane and decide whether feature framing is required before a tactical TODO becomes authority.
---

# Method: TODO Lane and Framing

## Purpose
Decide the correct tracking lane before implementation work begins. This phase prevents tactical TODOs from swallowing unrelated work and prevents no-code ledgers from inheriting implementation gates.

## Inputs
- User request.
- Existing active/ephemeral TODOs.
- Project/module docs and current repository state when needed.
- `templates/feature_brief_template.md` when pre-TODO framing is required.

## Procedure
1. Classify the lane:
   - `Profile-Scoped Capped TODO` for Genesis/Strategic no-code ledgers.
   - `Operational Micro-Fix` for tiny local operational changes with no product/test/doc impact.
   - `Maintenance/Regression Fix` for restoring previously documented behavior through an ephemeral TODO.
   - `Tactical TODO` for implementation, refactor, project-doc, or delivery work that changes durable artifacts.
2. Decide whether the work is already one bounded execution slice.
   - Use `Direct-to-TODO` only when there is one primary value/story objective, low ambiguity, and one approval conversation.
   - For `medium|big` work that is not one bounded slice, or materially ambiguous work of any size, create/update a feature brief first.
3. If a tactical TODO is required, ensure it lives under `foundation_documentation/todos/active/` and records:
   - framing source/story slice;
   - delivery stage, qualifiers, and next exact step;
   - scope and out of scope;
   - DoD and validation steps;
   - blocker state when applicable.
4. If the lane is `Operational Micro-Fix`, validate immediately with objective checks and do not invent a TODO.
   - Typo-only edits qualify only when they are non-authoritative operational notes and do not change meaning, rules, contracts, workflows, validation expectations, or project-specific `foundation_documentation`.
5. If the lane is `Maintenance/Regression Fix`, use `foundation_documentation/todos/ephemeral/` and request `APROVADO` before edits.

## Outputs
- Lane classification and rationale.
- Feature brief if required.
- Tactical or ephemeral TODO ready for contract refinement, or a recorded micro-fix validation path.

## Non-Negotiables
- Do not implement before lane classification.
- Do not use a tactical TODO as a bucket for multiple independently testable story slices.
- Do not apply tactical implementation gates to profile-scoped no-code ledgers unless they actually authorize implementation.
