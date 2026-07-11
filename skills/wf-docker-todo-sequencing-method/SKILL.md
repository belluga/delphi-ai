---
name: wf-docker-todo-sequencing-method
description: "Workflow: MUST use whenever the scope matches this purpose: sequence multiple approved TODOs through one checkpoint branch, defaulting to one checkpoint gate per TODO and deferring the parity-complete broad local gate to the authoritative branch whenever the sequencing lane is isolated."
---

# Workflow: TODO Sequencing

Use this workflow when the package risk is execution order and rework, not parallel delegation.

## Canonical Workflow
- `workflows/docker/todo-sequencing-method.md`

## Purpose
- Create a sequencing execution plan that chooses the best TODO order to avoid rework.
- Default the checkpoint unit to one approved TODO at a time on a dedicated checkpoint branch, preferably `sequence/*`.
- Allow a shared checkpoint unit across multiple TODOs only when the sequencing plan explicitly admits a micro-batch, records why that size is safe, and leaves the granularity visible for user validation.
- Require the current sequencing unit's own delivery gates plus its recorded checkpoint gate before the next sequencing unit starts.
- When the sequencing lane is isolated from the authoritative runtime/browser surface, require the plan to record the exact non-authoritative checkpoint prefix gate, the claims that gate must not make, and the later authoritative broad local gate that still remains mandatory after replay.
- When that later authoritative broad local gate is `stage-full`, require the isolated-worktree prefix to stop before `browser-stage-full`, so the skipped boundary starts at `local-public-web-build` and all later readonly/mutation browser proof stays deferred until replay onto the principal authoritative branch.
- Require any TODO delivered under that non-authoritative prefix to remain explicitly provisional until replay onto the principal authoritative branch and the deferred broad local gate both succeed.
- Require a checkpoint-time scan for newly appeared follow-up TODOs in the governed package folder, and refresh sequencing when that inventory changes.
- Record functional checkpoint commits/pushes only from green states and only when the sequencing plan records an explicit commit/push authority source.
- Pause for explicit user validation before replaying the accepted net effect onto the canonical branch.

## Deterministic Support Boundary
- Load `ci-equivalent-governance` before deciding whether a named broad local gate is truly parity-complete.
- Reuse the normal TODO deterministic guards for each TODO (`todo_authority_guard.py`, `todo_completion_guard.py`, `todo_closeout_guard.py`).
- Force the sequencing plan to carry an explicit granularity decision surface so the operator can tell whether a proposed sequencing unit is too small, too large, or safe to checkpoint as one unit.
- Force the sequencing plan to carry an explicit gate-topology decision surface whenever the sequencing lane is non-authoritative: exact checkpoint prefix gate now, forbidden claims now, authoritative broad gate later.
- If that broad gate is `stage-full`, force the sequencing plan to name the exact pre-browser cutoff (`stop before browser-stage-full`, meaning before `local-public-web-build`) instead of vaguely saying "first part of stage-full".
- Do not invent a fake promotion flow from `sequence/*`; replay to the canonical branch first.

## Non-Negotiables
- Do not use this workflow for unapproved TODOs.
- Do not start the next sequencing unit while the current sequencing unit still lacks its green recorded checkpoint gate.
- Do not batch multiple TODOs behind one shared checkpoint gate unless the sequencing plan explicitly admits that micro-batch and records the shared validation surface, rationale, and user-review status.
- Do not ignore newly appeared follow-up TODOs discovered at checkpoint time; classify them before the next sequencing unit starts.
- Do not reopen a delivered/checkpointed TODO just to absorb a newly discovered follow-up. If the natural parent owner is already delivered/checkpointed, add the follow-up as fresh sequencing work instead.
- Do not split a newly discovered follow-up into a standalone sequencing unit before checking whether it is already contemplated by an open owner or should be merged into an in-flight, not-yet-delivered owner.
- Do not mark any TODO inside a micro-batch as checkpointed, `Local-Implemented`, or delivered before the shared checkpoint gate passes for the whole admitted unit; if that gate is only a non-authoritative prefix, every member remains provisional until the later authoritative broad local gate passes after replay.
- Do not let downstream delivery-gate execution silently substitute the deferred authoritative broad local gate back into the isolated sequencing worktree; the current unit must obey the sequencing plan's recorded checkpoint gate topology.
- Do not label a non-authoritative checkpoint prefix gate as `CI-Equivalent`, `promotable`, or the full broad local gate.
- Do not claim `local-public-web-build`, browser readonly, browser mutation, or authoritative runtime freshness proof from an isolated sequencing worktree when those surfaces are reserved for the authoritative branch.
- Do not run `browser-stage-full`, `local-public-web-build`, or any downstream readonly/mutation browser step from an isolated sequencing worktree when the checkpoint gate is only the pre-browser prefix of `stage-full`.
- Treat any request to cross that cutoff from the isolated sequencing worktree as out of contract and refuse it until replay onto the principal authoritative branch.
- Do not create checkpoint commits/pushes without an explicit recorded commit/push authority source allowed by the governed-commit rule.
- Do not mark `sequence/*` as the promotion source branch.
- Do not replay onto the canonical branch before explicit user validation of the sequencing branch result.
