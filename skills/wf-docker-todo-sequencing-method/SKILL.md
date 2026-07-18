---
name: wf-docker-todo-sequencing-method
description: "Workflow: MUST use whenever the scope matches this purpose: sequence multiple approved TODOs through explicit affected-area checkpoint gates, then run the parity-complete broad local gate once at integrated package closeout."
---

# Workflow: TODO Sequencing

Use this workflow when the package risk is execution order and rework, not parallel delegation.

## Canonical Workflow
- `workflows/docker/todo-sequencing-method.md`

## Purpose
- Create a sequencing execution plan that chooses the best TODO order to avoid rework.
- Default the checkpoint unit to one approved TODO at a time on a dedicated checkpoint branch, preferably `sequence/*`.
- Allow a shared checkpoint unit across multiple TODOs only when the sequencing plan explicitly admits a micro-batch, records why that size is safe, and leaves the granularity visible for user validation.
- Require the current sequencing unit's own delivery gates plus its recorded affected-area checkpoint bundle before the next sequencing unit starts.
- Require every plan row to name the exact tests, analyzers, guards, builds, and runtime proof that the current TODO changes or consumes; that checkpoint is blocking but is not `CI-Equivalent` or promotion evidence.
- Require every Flutter-changing checkpoint to complete the stable full-workspace live Problems snapshot and matching rule review before the next unit starts; the test/build portion remains affected-area only and must not start a concurrent CLI analyzer.
- Reserve the parity-complete broad local gate (for example `stage-full`) for one package-closeout run after all admitted units have passed their targeted checkpoints; run it on the principal canonical state after replay when the sequencing lane is isolated.
- When the sequencing lane is isolated from the authoritative runtime/browser surface, require the plan to record the non-authoritative claims boundary and the later package-closeout broad gate that remains mandatory after replay.
- When that later package-closeout broad gate is `stage-full`, require isolated worktrees to stop before `browser-stage-full`, so the skipped boundary starts at `local-public-web-build` and all later readonly/mutation browser proof stays deferred until replay onto the principal authoritative branch.
- Require a checkpoint-time scan for newly appeared follow-up TODOs in the governed package folder, and refresh sequencing when that inventory changes.
- Record functional checkpoint commits/pushes only from green states and only when the sequencing plan records an explicit commit/push authority source.
- Pause for explicit user validation before replaying the accepted net effect onto the canonical branch.

## Deterministic Support Boundary
- Load `ci-equivalent-governance` before deciding whether a named broad local gate is truly parity-complete.
- Reuse the normal TODO deterministic guards for each TODO (`todo_authority_guard.py`, `todo_completion_guard.py`, `todo_closeout_guard.py`).
- Force the sequencing plan to carry an explicit granularity decision surface so the operator can tell whether a proposed sequencing unit is too small, too large, or safe to checkpoint as one unit.
- Force the sequencing plan to carry an explicit gate-topology decision surface: an exact affected-area checkpoint bundle for every unit, its forbidden overclaims, and one package-closeout authoritative broad gate.
- If that broad gate is `stage-full`, force the sequencing plan to name the exact pre-browser cutoff (`stop before browser-stage-full`, meaning before `local-public-web-build`) instead of vaguely saying "first part of stage-full".
- Do not invent a fake promotion flow from `sequence/*`; replay to the canonical branch first.

## Non-Negotiables
- Do not use this workflow for unapproved TODOs.
- Do not start the next sequencing unit while the current sequencing unit still lacks its green recorded checkpoint gate.
- Do not replace the required full Flutter-workspace Problems snapshot with an edited-file or directory subset at a checkpoint. It is a static rule gate, not the deferred broad test/runtime gate.
- Do not use `stage-full`, a promotable wrapper, or another parity-complete broad local gate as the default per-unit checkpoint. Run that gate once only when the full sequencing/orchestration package is ready for integrated closeout, unless the user explicitly asks for broad-regression diagnosis or recovery.
- Do not batch multiple TODOs behind one shared checkpoint gate unless the sequencing plan explicitly admits that micro-batch and records the shared validation surface, rationale, and user-review status.
- Do not ignore newly appeared follow-up TODOs discovered at checkpoint time; classify them before the next sequencing unit starts.
- Do not reopen a delivered/checkpointed TODO just to absorb a newly discovered follow-up. If the natural parent owner is already delivered/checkpointed, add the follow-up as fresh sequencing work instead.
- Do not split a newly discovered follow-up into a standalone sequencing unit before checking whether it is already contemplated by an open owner or should be merged into an in-flight, not-yet-delivered owner.
- Do not mark any TODO inside a micro-batch as checkpointed before the shared affected-area checkpoint bundle passes for the whole admitted unit.
- Do not let downstream delivery-gate execution silently substitute the package-closeout broad gate into an individual unit; the current unit must obey the plan's recorded affected-area checkpoint topology.
- Do not label a per-unit affected-area checkpoint as `CI-Equivalent`, `promotable`, package-complete, or the full broad local gate.
- Do not claim `local-public-web-build`, browser readonly, browser mutation, or authoritative runtime freshness proof from an isolated sequencing worktree when those surfaces are reserved for the authoritative branch.
- Do not run `browser-stage-full`, `local-public-web-build`, or any downstream readonly/mutation browser step from an isolated sequencing worktree when the checkpoint gate is only the pre-browser prefix of `stage-full`.
- Treat any request to cross that cutoff from the isolated sequencing worktree as out of contract and refuse it until replay onto the principal authoritative branch.
- Do not create checkpoint commits/pushes without an explicit recorded commit/push authority source allowed by the governed-commit rule.
- Do not mark `sequence/*` as the promotion source branch.
- Do not replay onto the canonical branch before explicit user validation of the sequencing branch result.
