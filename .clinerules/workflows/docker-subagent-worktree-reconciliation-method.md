---
name: "docker-subagent-worktree-reconciliation-method"
description: "Coordinate parallel implementation subagents through isolated worktrees, an orchestrator-owned reconciliation branch, and consolidated validation before delivery."
---

<!-- Generated from `workflows/docker/subagent-worktree-reconciliation-method.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# Workflow: Subagent Worktree Reconciliation

## Purpose
Coordinate parallel implementation subagents without surrendering integration ownership. This method keeps each delegated slice in its own worktree, requires checkpoint commits from workers, and makes the orchestrator responsible for merging those checkpoints into one reconciliation branch where delivery evidence is collected.

Worker-local success is necessary but insufficient. Workers/subagents may close their implementation slice with code review, analyzer, unit, widget, package, and targeted tests. Delivery only counts when the orchestrator validates the consolidated branch with the final runtime lane(s) required for the merged behavior, including any browser/device flows served from the principal local checkout.
For Flutter visible behavior, ADB integration and Playwright navigation are interchangeable only when Android and Web behavior is the same. If the behavior differs materially across Android and Web, both lanes are required before the orchestrator may accept delivery.
The closure bar is promotion-grade confidence for the full touched TODO/behavior set, even when the user only asked for local delivery or promotion to a lower lane.
The reconciliation branch/worktree is execution topology only. It does not create a second tactical TODO, a second approval conversation, or a separate backlog authority from the governing TODO.
Implementation ownership belongs to workers/subagents. The orchestrator must not implement a TODO slice locally. The orchestrator may edit production/test/runtime code only when the edit is strictly necessary to reconcile worker checkpoints, resolve merge conflicts, or make integration glue that cannot be assigned back without blocking reconciliation; every such edit must be logged as orchestrator reconciliation scope, never as feature implementation.

## Triggers
- The user explicitly asks for subagents, delegation, or parallel implementation work.
- The active tactical TODO can be partitioned into multiple bounded slices with mostly disjoint ownership.
- Consolidated validation on a merged branch is materially safer than trusting isolated worker branches.

## Inputs
- Governing tactical TODO or equivalent bounded execution authority.
- Orchestration execution plan under `foundation_documentation/artifacts/execution-plans/` when the wave coordinates multiple TODOs, multiple workstreams, or any user-visible approval plan.
- Stable base branch or base commit for the execution wave.
- Named worker slices with explicit file/module ownership.
- Required validation plan for worker-local and consolidated lanes.
- Execution ownership ledger that assigns every implementation workstream to a worker/subagent and limits orchestrator code edits to reconciliation/merge-conflict scope.
- Acceptance Traceability Matrix that maps every governing TODO DoD item, validation step, and literal UI/API/runtime marker to a non-orchestrator owner and planned implementation/test/runtime evidence.
- Spec Deviation Ledger for any intentional substitution of a governing TODO artifact, UI control, navigation path, endpoint, schema term, or validation lane.
- Checkpoint manifest path under `foundation_documentation/artifacts/checkpoints/` whenever the reconciliation branch is being committed/pushed as a recovery point.

## Preferred Deterministic Helpers
1. Create the worktree topology with non-interactive git commands such as:
   ```bash
   git worktree add ../wt-orchestrator -b orchestrator/example origin/dev
   git worktree add ../wt-worker-a -b worker/example-a origin/dev
   git worktree add ../wt-worker-b -b worker/example-b origin/dev
   ```
2. Merge or cherry-pick accepted worker checkpoints into the orchestrator lane with non-interactive git commands.
3. Run the project's native test/build commands from the worker and reconciliation worktrees, including repo-provided wrappers when they are the canonical entrypoint.
4. When web/browser validation depends on a published bundle, use the repository-approved publish/build command from the reconciliation branch before Playwright reruns.

## Procedure
1. **Confirm authorization and bound the slice**
   - Use this workflow only when the user has explicitly approved subagent/delegated implementation.
   - Before implementation dispatch, create or update an orchestration execution plan from `delphi-ai/templates/orchestration_execution_plan_template.md` when the wave coordinates multiple TODOs, multiple workstreams, or a user-requested approval plan.
   - Save that plan in the downstream project at `foundation_documentation/artifacts/execution-plans/<short-slug>.md`.
   - Treat the plan as derived execution topology: governing TODOs retain `WHAT` and done-criteria authority, while the plan records `HOW` the orchestrator will sequence, parallelize, reconcile, and validate.
   - Treat execution waves as orchestrator-owned internal control checkpoints, not user feedback gates. After approval, advance between waves autonomously unless a mandatory user decision, scope change, TODO conflict, real blocker, or validation waiver is encountered.
   - Before presenting the plan as ready for approval or delivery, run `python3 delphi-ai/tools/orchestration_plan_completion_guard.py --plan foundation_documentation/artifacts/execution-plans/<short-slug>.md` and require `Overall outcome: go`.
   - If the plan file is used as execution-ready evidence after approval, rerun the guard with `--require-approved`.
   - Do not dispatch workers or create worktrees until the plan has an explicit approval state or the governing TODO approval already covers the exact same orchestration topology.
   - Partition the work into bounded slices with clear ownership and minimal overlap.
   - Assign every implementation workstream to a worker/subagent in the execution ownership ledger. Do not list the orchestrator as implementation owner for a TODO slice.
   - Derive worker slices from TODO acceptance criteria and validation steps, not broad themes. If a TODO names a concrete artifact such as `FAB`, tab, route, endpoint, schema projection, browser journey, or device lane, that exact marker must appear in the Acceptance Traceability Matrix.
   - Treat substitutions as blockers unless they have an approved Spec Deviation Ledger row. Example: delivering a generic button where the TODO requires a `FAB` is not acceptable without explicit approval.
   - Define the consolidated validation plan before dispatching workers.
2. **Establish the branch/worktree topology**
   - Freeze one base branch or base commit for the execution wave.
   - Create one orchestrator-owned reconciliation branch/worktree from that base.
   - Create one worker branch/worktree per delegated slice from that same base unless a later dependency requires an intentional rebase.
   - Prefer clear branch names that make roles obvious, such as `orchestrator/<slug>` and `worker/<slug>-<lane>`.
   - Treat the reconciliation branch/worktree as an integration surface only, not as new TODO authority.
   - When runtime validation depends on the main local checkout, browser-facing domain, tunnel, emulator, or attached device, keep that principal checkout on the orchestrator-owned reconciliation branch. Worker branches stay in auxiliary worktrees only.
3. **Dispatch workers with explicit contracts**
   - Give each worker explicit ownership of files/modules, required tests, and checkpoint expectations.
   - Give each worker explicit ownership of the Acceptance Traceability Matrix rows it must satisfy, including any exact UI/API/runtime markers from the TODO.
   - Tell each worker it is not alone in the codebase and must not revert edits from other lanes.
   - Require workers to produce checkpoint commits whenever a coherent slice builds or passes its targeted tests.
4. **Keep integration authority with the orchestrator**
   - The orchestrator owns the reconciliation branch and stays on the critical path.
   - Waiting for worker output is acceptable when coupled with active validation and follow-up.
   - The orchestrator does not implement feature/domain/UI/backend TODO slices. If a slice needs production/test/runtime edits, dispatch or re-dispatch it to the responsible worker.
   - Orchestrator code edits are limited to merge conflict resolution, checkpoint reconciliation, and minimal integration glue that cannot be safely delegated without blocking the merge. Record each such edit in the execution ownership ledger or delivery evidence.
   - Do not leave final integration as an implicit future task for the human operator.
5. **Reconcile checkpoints continuously**
   - Pull accepted worker commits into the reconciliation branch by merge or cherry-pick.
   - Resolve conflicts in the orchestrator lane rather than allowing hidden shared mutable state across worktrees.
   - If one worker depends on another worker's checkpoint, propagate that dependency intentionally rather than assuming both lanes share the same evolving tree.
6. **Validate on the consolidated branch**
   - Workers run targeted/unit/module-local validation for their owned slice.
   - The orchestrator runs the union of required validation against the reconciliation branch state.
   - Validate every traceability row, not only every workstream. A workstream is incomplete if any owned DoD item, validation step, or named marker still lacks code, test, and required runtime evidence.
   - Include broader integration/regression suites when combined behavior changes.
   - Include project-native build/release commands for the consolidated artifact, for example a repo wrapper such as `build_web.sh` when that is the canonical build entrypoint.
   - Derive the required browser/device journeys and the materially distinct touched behavior families from the active TODOs, validation matrix, or equivalent project-owned evidence; do not choose them ad hoc.
   - Include relevant navigation or smoke validation on the consolidated runtime or built artifact, especially every user journey and behavior family touched by the merged slices.
   - Treat code, unit, widget, and worker-targeted tests as implementation evidence, not final UI acceptance evidence. Final UI acceptance belongs to the orchestrator on the consolidated branch.
   - For Flutter UI behavior, record whether Android and Web are behaviorally identical or divergent. If identical, either ADB integration or Playwright navigation can satisfy the final runtime lane; if divergent, run both.
   - For UI-facing criteria, include real browser/device/navigation validation when the TODO or validation matrix requires web, admin screen, public surface, map, list, detail, route, click, scroll, persisted selection, loading/error state, or other interactive behavior.
   - Do not declare delivery confidence from one representative flow when other touched families remain unvalidated. Shared plumbing proof is supporting evidence only; untouched behavior families remain open until directly validated or explicitly blocked.
   - Run browser/device validation against the runtime that actually resolves to the reconciliation branch state. If the designated domain/tunnel/device target is serving stale code or another branch, stop and classify the stage as `blocked` until the wiring is corrected.
7. **Drive iteration until green or explicitly blocked**
   - When consolidated validation fails, assign precise follow-up back to the responsible worker. Patch locally only when the patch is strictly reconciliation or merge-conflict scope; otherwise re-dispatch the slice.
   - Repeat the reconcile-and-validate loop until the consolidated branch is green.
   - If a required validation lane cannot be run, record an explicit blocker with cause, owner, and next action instead of claiming completion.
8. **Close on reconciliation evidence**
   - Report delivery evidence from the reconciliation branch state, not from isolated worker branches.
   - Report delivery evidence by traceability row. Each row must have passed implementation evidence, passed test evidence, and passed runtime/web/device evidence when applicable.
   - Worker-local success never substitutes for consolidated success.
   - Before claiming local implementation or delivery completion, run `python3 delphi-ai/tools/orchestration_delivery_guard.py --plan foundation_documentation/artifacts/execution-plans/<short-slug>.md --require-approved` and require `Overall outcome: go`.
   - The delivery guard must show that every consolidated validation matrix row has passed evidence, runtime/browser/device evidence targets the reconciliation branch build, and no implementation workstream was owned by the orchestrator.
   - Keep worker branches available until the reconciliation branch has passed the required gates and the result is integrated.
   - If local implementation is closed and only promotion/lane follow-through remains, keep the same governing TODO, move it to `foundation_documentation/todos/promotion_lane/`, and continue with the appropriate promotion-lane skill instead of opening a fresh tactical TODO for finalization.
   - Use `github-stage-promotion-orchestrator` for `dev-only|through-stage` requests and `github-main-promotion-orchestrator` only when the user explicitly requests `main`.
   - Open a new tactical TODO only when the promotion workflow/process itself is what is being designed, repaired, or otherwise changed.
9. **Create recoverable checkpoints without branch accumulation**
   - Treat a checkpoint as a recoverable, pushed git state plus a manifest, not as permission to keep accumulating unrelated work on the same branch.
   - Before committing an orchestrator checkpoint, classify it as `wip_checkpoint`, `validated_local_checkpoint`, `promotion_ready_checkpoint`, or `superseded_checkpoint`.
   - Store the checkpoint manifest under `foundation_documentation/artifacts/checkpoints/<short-slug>-<YYYY-MM-DD>.md`, not under `artifacts/tmp/`, when it should survive the session. The manifest must record repository names, branch names, commit SHAs after commit, governing TODOs, validation/guard evidence, excluded dirty surfaces, and the next exact promotion/discard step.
   - Use `wip_checkpoint` only as a recovery point. It must not move TODOs to `Local-Implemented`, `promotion_lane/`, or completed states.
   - Use `validated_local_checkpoint` only after the consolidated branch has passed the required delivery guard and final runtime/device/browser lanes for the current local claim.
   - After a checkpoint is promoted into its target branch (`dev`, `stage`, or `main`), stop using the old orchestrator branch for new feature work. Start the next wave from the promoted target branch or an explicitly rebased fresh orchestrator branch.
   - If a checkpoint is not going to be promoted, either mark it superseded in the manifest or keep it only as a recovery branch. Do not continue piling new TODO scopes onto it.
   - If additional work is still part of the same approved wave, continuing on the same orchestrator branch is allowed only when the execution plan still owns that next work and the checkpoint manifest records the next exact step. Otherwise create a new plan/branch or update the governing TODO before continuing.

## Outputs
- Orchestration execution plan under `foundation_documentation/artifacts/execution-plans/` for multi-TODO, multi-workstream, or user-requested approval waves.
- One orchestrator reconciliation branch/worktree.
- The principal local checkout attached to the orchestrator reconciliation branch whenever runtime validation depends on it.
- One worker branch/worktree per delegated slice.
- Checkpoint commits from workers.
- Recoverable orchestrator checkpoint commits and persistent checkpoint manifests when the reconciliation branch is pushed for continuity.
- Consolidated validation evidence collected from the reconciliation branch.
- Delivery guard TEACH evidence for the approved plan before local implementation or delivery completion is claimed.
- Explicit blocker records whenever a required validation lane could not run.
- The same governing TODO retained as authority through promotion follow-through unless the promotion process itself became the active work item.

## Validation
- No multi-TODO or multi-workstream dispatch begins before the orchestration execution plan exists and has been approved or is explicitly covered by the governing TODO approval.
- No orchestration execution plan is presented as complete until `orchestration_plan_completion_guard.py` returns `Overall outcome: go`.
- The orchestration execution plan names the governing TODOs, dependency graph, acceptance traceability matrix, spec deviation ledger, workstream ownership, execution waves, branch/worktree topology, and consolidated validation matrix.
- Every governing TODO DoD item and validation step is represented in the Acceptance Traceability Matrix before approval.
- Literal required markers from governing TODOs, such as named UI controls, tabs, routes, endpoints, schemas, web/browser/device lanes, loading states, and navigation behaviors, are either represented exactly in traceability or covered by an approved Spec Deviation Ledger row.
- Execution waves are not used as routine human checkpoints; unexpected pauses must be justified by a mandatory decision/blocker/waiver condition.
- The execution wave has a dedicated orchestrator reconciliation branch.
- When browser/device validation is in scope, the runtime target used for that validation resolves to the reconciliation branch state.
- Every accepted worker change was integrated through that reconciliation branch.
- Every implementation workstream is owned by a worker/subagent; the orchestrator owns reconciliation, conflict resolution, validation orchestration, and evidence collection only.
- Every acceptance traceability row is owned by a worker/subagent; the orchestrator is never listed as implementation owner.
- Any orchestrator code edit is documented as reconciliation/merge-conflict/integration-glue scope and never as TODO-slice implementation.
- Workers provided targeted validation for their owned slices.
- The orchestrator ran the required consolidated tests/builds/navigation checks against the merged state.
- The orchestrator verified the traceability matrix row-by-row against the merged state, including required web/browser/device/navigation evidence for UI-facing criteria.
- `orchestration_delivery_guard.py --require-approved` returns `Overall outcome: go` before any local implementation or delivery completion claim.
- The orchestrator either validated every materially distinct touched behavior family at promotion-grade confidence or recorded an explicit blocker/waiver for the remaining gap.
- Any missing required validation is represented as an explicit blocker rather than a silent waiver.
- No new tactical TODO was created solely to represent reconciliation closure or operational promotion follow-through.
- Pushed orchestrator checkpoints include a persistent manifest with repo/branch/commit SHAs, governing TODOs, evidence, exclusions, and next promotion/discard step.
- Orchestrator branches are not used as indefinite accumulation buckets after promotion, supersession, or scope drift.
