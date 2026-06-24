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
4. If the TODO remains in `active/`, record `Active Work State` explicitly:
   - `implementation` while implementation/test evidence is still being produced;
   - `review` when local implementation is materially complete but package-wide review, Copilot-mimic, CI-equivalent, or promotion-readiness scrutiny is still open;
   - `blocked` when execution is paused on an explicit blocker.
5. Decide the closeout lane:
   - keep in `active/` while implementation evidence, decisions, canonicalization, or promotion preparation remain open;
   - move to `promotion_lane/` when local implementation is complete and only authorized lane follow-through remains;
   - move to `completed/` only when the final required lane threshold for the TODO is complete;
   - for local-only Delphi self-maintenance where remote promotion is intentionally out of scope, move to `completed/` only after local validation, commit/push, and canonical docs are complete.
6. Route post-review findings explicitly:
   - Run `review-finding-classification` before changing the routing ledger or splitting follow-up owners.
   - `release-blocker` stays with the current governing TODO/package and must be fixed or explicitly re-approved before promotion continues;
   - `follow-up-fast-follow` becomes an explicit TODO under `foundation_documentation/todos/active/fast_follow_required/followup/`;
   - `follow-up-hardening` becomes an explicit TODO under `foundation_documentation/todos/active/post_release_hardening/hardening/`;
   - `by-design/no-action` stays only as authoritative rationale/evidence in the governing TODO.
   The originating release/package version belongs in the split TODO title/body and routing ledger, not in the directory name.
7. During a package-wide review / Copilot-mimic loop, move TODOs to `promotion_lane/` progressively as soon as each one individually satisfies all of the following:
   - local implementation/evidence is complete for that TODO;
   - the current package-wide review loop has explicitly swept that TODO and found it `clean/no-reopen`;
   - only authorized lane follow-through remains for that TODO.
   Do not wait for the entire package to finish before moving already-clean TODOs out of `active/`.
8. Use `github-stage-promotion-orchestrator` for `dev-only|through-stage` promotion.
9. Use `github-main-promotion-orchestrator` only when the user explicitly requests `main`.
10. Do not create a new tactical TODO solely for operational promotion follow-through unless the promotion process itself is the active requested work.
11. When the delivered package was first integrated on `reconcile/*`, do not let promotion or non-orchestration closeout resume from the canonical branch until `python3 delphi-ai/tools/orchestration_reconcile_replay_guard.py --plan foundation_documentation/artifacts/execution-plans/<short-slug>.md --repo <authoritative-source-repo>` returns `Overall outcome: go`.
12. For promotion loops that use a derived `review/*` remediation branch, enforce both CI-equivalent gates explicitly:
   - the authoritative source/reconcile branch must already be green before the TODO/package is sent into review;
   - the derived review branch must pass its own in-scope CI-equivalent matrix before it can be declared review-clean;
   - if replaying the accepted review net effect changes the authoritative source codebase, rerun the authoritative CI-equivalent matrix before claiming promotion readiness again;
   - if the authoritative source codebase is unchanged from its last green CI-equivalent state, do not rerun it gratuitously.
13. Rerun `todo_authority_guard.py <todo-path> --require-delivery-gates`, `todo_completion_guard.py`, and `todo_closeout_guard.py <todo-path>` before any close-claim path/status change.
14. After commit/push or lane movement, update `Post-commit/push status` and run `todo_closeout_guard.py --all-active --repo <repo-root>`; if it flags a `move-*` TODO still in `active/`, move it or change the disposition with a real remaining active reason.

## Outputs
- Updated TODO stage/path.
- Canonical docs updated with stable truth.
- Promotion or blocker status with exact next step.

## Non-Negotiables
- Same governing TODO remains authoritative through promotion follow-through.
- `active/` is not a single semantic state: every active TODO must declare whether it is still in `implementation`, in package/promotion `review`, or explicitly `blocked`.
- No `Production-Ready` claim before the final required lane threshold is complete.
- No close-claim path/status change while either deterministic guard returns anything other than `Overall outcome: go`.
- No delivered TODO may remain in `active/` without a valid closeout disposition and actionable next step.
- No durable truth left only in tactical notes after close.
