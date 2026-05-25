---
description: Close, promote, or block a TODO after delivery evidence is complete while preserving the same governing TODO through lane follow-through.
---

# Method: TODO Closeout and Promotion

## Purpose
Move a delivered TODO to the right next state, promote stable truth to canonical docs, and keep promotion follow-through tied to the same governing TODO.

## Inputs
- TODO with delivery evidence and `todo_completion_guard.py` result.
- Stable implementation decisions and module-doc impacts.
- Promotion lane target and user authorization.

## Procedure
1. If pausing blocked, set `Blocked` explicitly with blocker notes and next exact step.
2. Promote stable outcomes into canonical project/module docs before close.
3. Decide the closeout lane:
   - keep in `active/` while implementation evidence, decisions, canonicalization, or promotion preparation remain open;
   - move to `promotion_lane/` when local implementation is complete and only authorized lane follow-through remains;
   - move to `completed/` only when the final required lane threshold for the TODO is complete;
   - for local-only Delphi self-maintenance where remote promotion is intentionally out of scope, move to `completed/` only after local validation, commit/push, and canonical docs are complete.
4. Use `github-stage-promotion-orchestrator` for `dev-only|through-stage` promotion.
5. Use `github-main-promotion-orchestrator` only when the user explicitly requests `main`.
6. Do not create a new tactical TODO solely for operational promotion follow-through unless the promotion process itself is the active requested work.
7. Rerun `todo_authority_guard.py <todo-path> --require-delivery-gates` and `todo_completion_guard.py` before any close-claim path/status change.

## Outputs
- Updated TODO stage/path.
- Canonical docs updated with stable truth.
- Promotion or blocker status with exact next step.

## Non-Negotiables
- Same governing TODO remains authoritative through promotion follow-through.
- No `Production-Ready` claim before the final required lane threshold is complete.
- No close-claim path/status change while either deterministic guard returns anything other than `Overall outcome: go`.
- No durable truth left only in tactical notes after close.
