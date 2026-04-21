---
name: wf-docker-subagent-worktree-reconciliation-method
description: "Workflow: MUST use whenever the scope matches this purpose: Coordinate parallel implementation subagents through isolated worktrees, an orchestrator-owned reconciliation branch, and consolidated validation before delivery."
---

# Method: Subagent Worktree Reconciliation

## Purpose
Provide a portable orchestration layer for parallel implementation subagents that keeps worker edits isolated while the orchestrator owns integration, the principal reconciliation checkout, and final validation.
The orchestrator's evidence bar is the same confidence threshold required before a hypothetical `main` promotion of the reconciled result, even when the actual request stops at local delivery or a lower promotion lane.
The reconciliation branch/worktree is execution topology only. It does not create a new tactical TODO, a second approval conversation, or a separate backlog authority from the governing TODO set.

## Preferred Deterministic Helpers
1. Use `git worktree` plus non-interactive git commands to create one worker worktree per delegated slice and one reconciliation worktree for the orchestrator.
2. Use the project's native test/build commands from the active validation plan inside both worker and reconciliation worktrees.
3. When browser validation depends on a published Flutter web bundle, use the repository-approved publish/build entrypoint for the reconciliation branch before rerunning Playwright.

## Procedure
1. Bound the execution slice and confirm the user explicitly wants subagents or parallel implementation.
2. Create isolated worker worktrees plus one orchestrator reconciliation branch/worktree from the same base.
3. Keep the principal local checkout on the orchestrator-owned `reconcile/*` branch whenever real runtime validation depends on a browser-facing domain, tunnel, simulator, or device attached to the main working copy. Worker edits stay isolated in auxiliary worktrees.
4. Require checkpoint commits and targeted validation from each worker before claiming integration progress.
5. Merge accepted worker checkpoints into the reconciliation branch continuously and run consolidated tests, builds, and relevant navigation checks there.
6. Derive required browser/device journeys and the materially distinct touched behavior families from the active TODOs, validation matrix, or equivalent project-owned artifact. Do not choose the final user journeys ad hoc from memory, and do not close the wave on one representative happy path if sibling touched behaviors remain unverified.
7. Run browser/device validation against the runtime that resolves to the reconciliation branch state. If the public domain/tunnel/device target is not serving the current reconciliation build, treat the stage as `blocked` until that wiring is corrected.
8. Keep driving follow-up until the consolidated branch is green at promotion-grade confidence for the touched TODO set, or record an explicit blocker instead of claiming delivery.
9. When the merged result is locally implemented and only promotion/lane follow-through remains, keep the same governing TODO, move it to `foundation_documentation/todos/promotion_lane/`, and hand off operational lane work to the appropriate promotion skill. Use `github-stage-promotion-orchestrator` for `dev-only|through-stage` promotion and `github-main-promotion-orchestrator` only when the user explicitly requests `main`. Do not create a new tactical TODO solely for reconciliation closure or promotion follow-through unless the promotion process itself is the subject of the requested work.
