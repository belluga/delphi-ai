---
name: wf-docker-subagent-worktree-reconciliation-method
description: "Workflow: MUST use whenever the scope matches this purpose: Coordinate parallel implementation subagents through isolated worktrees, an orchestrator-owned reconciliation branch, and consolidated validation before delivery."
---

# Method: Subagent Worktree Reconciliation

## Purpose
Provide a portable orchestration layer for parallel implementation subagents that keeps worker edits isolated while the orchestrator owns integration, the principal reconciliation checkout, and final validation.
The orchestrator's evidence bar is the same confidence threshold required before a hypothetical `main` promotion of the reconciled result, even when the actual request stops at local delivery or a lower promotion lane.
The reconciliation branch/worktree is execution topology only. It does not create a new tactical TODO, a second approval conversation, or a separate backlog authority from the governing TODO set.
Implementation belongs to workers/subagents. The orchestrator may edit production/test/runtime code only for merge-conflict resolution, checkpoint reconciliation, or minimal integration glue that cannot be delegated without blocking reconciliation. The orchestrator must not own TODO-slice implementation.
Worker/subagent closure may rely on code, analyzer, unit, widget, package, and targeted tests for the owned slice. Orchestrator acceptance requires final runtime validation on the consolidated branch: ADB integration and/or Playwright navigation according to the platform parity of the visible behavior. If Android and Web behavior differs materially, both lanes are required; if it is the same behavior, either lane can satisfy final runtime acceptance.

## Preferred Deterministic Helpers
1. Start multi-TODO, multi-workstream, or user-requested approval waves from `delphi-ai/templates/orchestration_execution_plan_template.md`, saved under `foundation_documentation/artifacts/execution-plans/` in the downstream project.
2. Before presenting an orchestration plan as ready, run `python3 delphi-ai/tools/orchestration_plan_completion_guard.py --plan foundation_documentation/artifacts/execution-plans/<short-slug>.md` and require `Overall outcome: go`.
3. Before claiming local implementation or delivery completion, run `python3 delphi-ai/tools/orchestration_delivery_guard.py --plan foundation_documentation/artifacts/execution-plans/<short-slug>.md --require-approved` and require `Overall outcome: go`.
4. Use `git worktree` plus non-interactive git commands to create one worker worktree per delegated slice and one reconciliation worktree for the orchestrator.
5. Use the project's native test/build commands from the active validation plan inside both worker and reconciliation worktrees.
6. When browser validation depends on a published Flutter web bundle, use the repository-approved publish/build entrypoint for the reconciliation branch before rerunning Playwright.
7. When pushing an orchestrator checkpoint, create a persistent manifest from `delphi-ai/templates/orchestration_checkpoint_manifest_template.md` under `foundation_documentation/artifacts/checkpoints/`.

## Procedure
1. Bound the execution slice and confirm the user explicitly wants subagents or parallel implementation.
2. For multi-TODO, multi-workstream, or user-requested approval waves, write the orchestration execution plan before dispatching workers. The plan must name governing TODOs, dependencies, acceptance traceability matrix, spec deviation ledger, workstreams, execution ownership ledger, branch/worktree topology, execution waves, and consolidated validation.
3. Build worker slices from acceptance criteria, DoD rows, validation steps, and literal TODO markers. Do not slice only by broad implementation theme when that can hide a concrete required artifact such as `FAB`, tab, route, endpoint, schema projection, browser journey, or device lane.
4. Run `orchestration_plan_completion_guard.py` and require `Overall outcome: go` before asking for approval or claiming the plan is ready.
5. Ask for explicit approval of the plan when it is not already covered by the governing TODO approval. Do not dispatch workers before that approval.
6. Treat execution waves as orchestrator-owned internal checkpoints, not user feedback gates. After approval, advance autonomously between waves unless a mandatory user decision, scope change, TODO conflict, real blocker, or validation waiver is encountered.
7. Create isolated worker worktrees plus one orchestrator reconciliation branch/worktree from the same base.
8. Keep the principal local checkout on the orchestrator-owned `reconcile/*` branch whenever real runtime validation depends on a browser-facing domain, tunnel, simulator, or device attached to the main working copy. Worker edits stay isolated in auxiliary worktrees.
9. Assign every implementation workstream and every Acceptance Traceability Matrix row to a worker/subagent. The orchestrator owns reconciliation, conflict resolution, validation orchestration, and evidence collection only.
10. Treat exact TODO terms as binding. If implementation substitutes a named artifact, UI control, route, endpoint, schema term, or validation lane, stop unless the Spec Deviation Ledger records explicit approval.
11. Require checkpoint commits and targeted validation from each worker before claiming integration progress.
12. Merge accepted worker checkpoints into the reconciliation branch continuously and run consolidated tests, builds, and relevant navigation checks there.
13. If consolidated validation fails, send the fix back to the responsible worker unless the edit is strictly merge-conflict or reconciliation scope.
14. Derive required browser/device journeys and the materially distinct touched behavior families from the active TODOs, validation matrix, acceptance traceability matrix, or equivalent project-owned artifact. Do not choose the final user journeys ad hoc from memory, and do not close the wave on one representative happy path if sibling touched behaviors remain unverified.
15. Run browser/device validation against the runtime that resolves to the reconciliation branch state. If the public domain/tunnel/device target is not serving the current reconciliation build, treat the stage as `blocked` until that wiring is corrected.
16. For UI-facing criteria, require real browser/device/navigation evidence when the TODO mentions web, admin screen, public surface, map, list, detail, route, click, scroll, persisted selection, loading/error state, or interaction behavior.
17. For Flutter UI-facing criteria, record platform parity before acceptance. If Android and Web behavior is the same, either ADB integration or Playwright navigation can satisfy final runtime acceptance; if behavior differs materially, both lanes are required.
18. Run `orchestration_delivery_guard.py --require-approved` before any local implementation or delivery completion claim.
19. Keep driving follow-up until the consolidated branch is green at promotion-grade confidence for the touched TODO set, or record an explicit blocker instead of claiming delivery.
20. When the merged result is locally implemented and only promotion/lane follow-through remains, keep the same governing TODO, move it to `foundation_documentation/todos/promotion_lane/`, and hand off operational lane work to the appropriate promotion skill. Use `github-stage-promotion-orchestrator` for `dev-only|through-stage` promotion and `github-main-promotion-orchestrator` only when the user explicitly requests `main`. Do not create a new tactical TODO solely for reconciliation closure or promotion follow-through unless the promotion process itself is the subject of the requested work.
21. Treat orchestrator checkpoints as pushed recovery states, not indefinite accumulation branches. Each checkpoint must be classified as `wip_checkpoint`, `validated_local_checkpoint`, `promotion_ready_checkpoint`, or `superseded_checkpoint`.
22. After a checkpoint is promoted into `dev`, `stage`, or `main`, stop using that orchestrator branch for new feature work. Start the next wave from the promoted target branch or an explicitly fresh/rebased orchestrator branch.
23. Continue on the same orchestrator branch only while the next work remains inside the approved plan and the checkpoint manifest records the next exact step; otherwise create a new plan/branch or update the governing TODO.
