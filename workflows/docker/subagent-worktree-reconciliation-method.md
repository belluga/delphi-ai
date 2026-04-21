---
description: Coordinate parallel implementation subagents through isolated worktrees, an orchestrator-owned reconciliation branch, and consolidated validation before delivery.
---

# Workflow: Subagent Worktree Reconciliation

## Purpose
Coordinate parallel implementation subagents without surrendering integration ownership. This method keeps each delegated slice in its own worktree, requires checkpoint commits from workers, and makes the orchestrator responsible for merging those checkpoints into one reconciliation branch where delivery evidence is collected.

Worker-local success is necessary but insufficient. Delivery only counts when the consolidated branch passes the required validation for the merged behavior, including any browser/device flows served from the principal local checkout.
The closure bar is promotion-grade confidence for the full touched TODO/behavior set, even when the user only asked for local delivery or promotion to a lower lane.
The reconciliation branch/worktree is execution topology only. It does not create a second tactical TODO, a second approval conversation, or a separate backlog authority from the governing TODO.

## Triggers
- The user explicitly asks for subagents, delegation, or parallel implementation work.
- The active tactical TODO can be partitioned into multiple bounded slices with mostly disjoint ownership.
- Consolidated validation on a merged branch is materially safer than trusting isolated worker branches.

## Inputs
- Governing tactical TODO or equivalent bounded execution authority.
- Stable base branch or base commit for the execution wave.
- Named worker slices with explicit file/module ownership.
- Required validation plan for worker-local and consolidated lanes.

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
   - Partition the work into bounded slices with clear ownership and minimal overlap.
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
   - Tell each worker it is not alone in the codebase and must not revert edits from other lanes.
   - Require workers to produce checkpoint commits whenever a coherent slice builds or passes its targeted tests.
4. **Keep integration authority with the orchestrator**
   - The orchestrator owns the reconciliation branch and stays on the critical path.
   - Waiting for worker output is acceptable when coupled with active validation and follow-up.
   - Do not leave final integration as an implicit future task for the human operator.
5. **Reconcile checkpoints continuously**
   - Pull accepted worker commits into the reconciliation branch by merge or cherry-pick.
   - Resolve conflicts in the orchestrator lane rather than allowing hidden shared mutable state across worktrees.
   - If one worker depends on another worker's checkpoint, propagate that dependency intentionally rather than assuming both lanes share the same evolving tree.
6. **Validate on the consolidated branch**
   - Workers run targeted/unit/module-local validation for their owned slice.
   - The orchestrator runs the union of required validation against the reconciliation branch state.
   - Include broader integration/regression suites when combined behavior changes.
   - Include project-native build/release commands for the consolidated artifact, for example a repo wrapper such as `build_web.sh` when that is the canonical build entrypoint.
   - Derive the required browser/device journeys and the materially distinct touched behavior families from the active TODOs, validation matrix, or equivalent project-owned evidence; do not choose them ad hoc.
   - Include relevant navigation or smoke validation on the consolidated runtime or built artifact, especially every user journey and behavior family touched by the merged slices.
   - Do not declare delivery confidence from one representative flow when other touched families remain unvalidated. Shared plumbing proof is supporting evidence only; untouched behavior families remain open until directly validated or explicitly blocked.
   - Run browser/device validation against the runtime that actually resolves to the reconciliation branch state. If the designated domain/tunnel/device target is serving stale code or another branch, stop and classify the stage as `blocked` until the wiring is corrected.
7. **Drive iteration until green or explicitly blocked**
   - When consolidated validation fails, assign precise follow-up back to the responsible worker or patch locally if that is faster and safer.
   - Repeat the reconcile-and-validate loop until the consolidated branch is green.
   - If a required validation lane cannot be run, record an explicit blocker with cause, owner, and next action instead of claiming completion.
8. **Close on reconciliation evidence**
   - Report delivery evidence from the reconciliation branch state, not from isolated worker branches.
   - Worker-local success never substitutes for consolidated success.
   - Keep worker branches available until the reconciliation branch has passed the required gates and the result is integrated.
   - If local implementation is closed and only promotion/lane follow-through remains, keep the same governing TODO, move it to `foundation_documentation/todos/promotion_lane/`, and continue with the appropriate promotion-lane skill instead of opening a fresh tactical TODO for finalization.
   - Use `github-stage-promotion-orchestrator` for `dev-only|through-stage` requests and `github-main-promotion-orchestrator` only when the user explicitly requests `main`.
   - Open a new tactical TODO only when the promotion workflow/process itself is what is being designed, repaired, or otherwise changed.

## Outputs
- One orchestrator reconciliation branch/worktree.
- The principal local checkout attached to the orchestrator reconciliation branch whenever runtime validation depends on it.
- One worker branch/worktree per delegated slice.
- Checkpoint commits from workers.
- Consolidated validation evidence collected from the reconciliation branch.
- Explicit blocker records whenever a required validation lane could not run.
- The same governing TODO retained as authority through promotion follow-through unless the promotion process itself became the active work item.

## Validation
- The execution wave has a dedicated orchestrator reconciliation branch.
- When browser/device validation is in scope, the runtime target used for that validation resolves to the reconciliation branch state.
- Every accepted worker change was integrated through that reconciliation branch.
- Workers provided targeted validation for their owned slices.
- The orchestrator ran the required consolidated tests/builds/navigation checks against the merged state.
- The orchestrator either validated every materially distinct touched behavior family at promotion-grade confidence or recorded an explicit blocker/waiver for the remaining gap.
- Any missing required validation is represented as an explicit blocker rather than a silent waiver.
- No new tactical TODO was created solely to represent reconciliation closure or operational promotion follow-through.
