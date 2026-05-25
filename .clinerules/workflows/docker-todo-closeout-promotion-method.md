---
name: "docker-todo-closeout-promotion-method"
description: "Close, promote, or block a TODO after delivery evidence is complete while preserving the same governing TODO through lane follow-through."
---

<!-- Generated from `workflows/docker/todo-closeout-promotion-method.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# Workflow: TODO Closeout and Promotion

## Purpose
Move a delivered TODO to the right next state, promote stable truth to canonical docs, and keep promotion follow-through tied to the same governing TODO.

## Inputs
- TODO with delivery evidence and `todo_completion_guard.py` result.
- Stable implementation decisions and module-doc impacts.
- Promotion lane target and user authorization.

## Procedure
1. If pausing blocked, set `Blocked` explicitly with blocker notes and next exact step.
2. Promote stable outcomes into canonical project/module docs before close.
3. Record `TODO Closeout Disposition` in the governing TODO:
   - `keep-active` only when a real blocker, promotion action, validation step, canonicalization task, or approval wait remains;
   - `move-promotion-lane` when local implementation is complete and only authorized lane follow-through remains;
   - `move-completed` when the final required lane threshold is complete;
   - `blocked` when execution is paused on an explicit blocker.
4. Decide the closeout lane:
   - keep in `active/` while implementation evidence, decisions, canonicalization, or promotion preparation remain open;
   - move to `promotion_lane/` when local implementation is complete and only authorized lane follow-through remains;
   - move to `completed/` only when the final required lane threshold for the TODO is complete;
   - for local-only Delphi self-maintenance where remote promotion is intentionally out of scope, move to `completed/` only after local validation, commit/push, and canonical docs are complete.
5. Use `github-stage-promotion-orchestrator` for `dev-only|through-stage` promotion.
6. Use `github-main-promotion-orchestrator` only when the user explicitly requests `main`.
7. Do not create a new tactical TODO solely for operational promotion follow-through unless the promotion process itself is the active requested work.
8. Rerun `todo_authority_guard.py <todo-path> --require-delivery-gates`, `todo_completion_guard.py`, and `todo_closeout_guard.py <todo-path>` before any close-claim path/status change.
9. After commit/push or lane movement, update `Post-commit/push status` and run `todo_closeout_guard.py --all-active --repo <repo-root>`; if it flags a `move-*` TODO still in `active/`, move it or change the disposition with a real remaining active reason.

## Outputs
- Updated TODO stage/path.
- Canonical docs updated with stable truth.
- Promotion or blocker status with exact next step.

## Non-Negotiables
- Same governing TODO remains authoritative through promotion follow-through.
- No `Production-Ready` claim before the final required lane threshold is complete.
- No close-claim path/status change while either deterministic guard returns anything other than `Overall outcome: go`.
- No delivered TODO may remain in `active/` without a valid closeout disposition and actionable next step.
- No durable truth left only in tactical notes after close.
