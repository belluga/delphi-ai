---
name: wf-docker-todo-closeout-promotion-method
description: "Workflow phase: close, block, or promote a TODO after delivery evidence while preserving the same governing TODO through lane follow-through."
---

# Method: TODO Closeout and Promotion

Use after delivery evidence is complete or when the TODO must pause blocked. Canonical details live in `workflows/docker/todo-closeout-promotion-method.md`.

## Responsibilities
- Set `Blocked` with blocker notes and next exact step when pausing.
- Promote stable decisions into canonical docs.
- Record `TODO Closeout Disposition` as `keep-active`, `move-promotion-lane`, `move-completed`, or `blocked`.
- Move the same TODO to `promotion_lane/` or `completed/` only when the lane threshold supports it.
- Rerun `todo_authority_guard.py <todo-path> --require-delivery-gates` and `todo_completion_guard.py` before close-claim path/status changes.
- Run `todo_closeout_guard.py <todo-path>` before close-claim path/status changes and `todo_closeout_guard.py --all-active --repo <repo-root>` after commit/push or lane movement to catch stale active TODOs.
- Route promotion through the appropriate GitHub promotion skill.

## Outputs
- Closed, blocked, or promotion-lane TODO with canonical docs updated as needed.

## Non-Negotiables
- Do not create a new tactical TODO solely for promotion follow-through.
- Do not claim `Production-Ready` before the final required lane threshold is complete.
- Do not close or move a TODO while either deterministic guard returns anything other than `Overall outcome: go`.
- Do not leave a delivered TODO in `active/` without a valid disposition and actionable next step.
