---
description: Sequence multiple approved tactical TODOs through explicit affected-area checkpoint gates, then run the parity-complete broad local gate once at integrated package closeout.
---

# Workflow: TODO Sequencing

## Purpose
Coordinate one execution lane across multiple approved TODOs when the main risk is rework, not parallelism. This workflow creates a sequencing plan that decides the safest order and checkpoint granularity, defaults the checkpoint unit to one TODO, allows a shared micro-batch unit only when that exception is explicitly admitted in the plan, and requires an exact affected-area checkpoint bundle after every unit before the next begins. A unit bundle contains only the focused tests, builds, deterministic guards, and runtime proof that the unit changes or consumes. Flutter-changing units additionally capture a stable full-workspace live VS Code Problems snapshot and matching rule review at every checkpoint; that static gate is mandatory but is not `stage-full`, `CI-Equivalent`, promotable, package-complete, or a substitute for the broad local gate. The agent must not start a concurrent CLI analyzer to recreate the editor-owned evidence. The parity-complete broad local gate runs once when the full sequencing/orchestration package is ready for integrated closeout: directly on the principal canonical state, or after replay when the sequencing lane is isolated. The workflow records functional checkpoints on a dedicated sequencing branch when that topology is used and pauses for explicit user validation before replaying the accepted net effect onto the canonical branch. When the package-closeout gate is `stage-full`, isolated worktrees must stop before `browser-stage-full`, so the skipped boundary starts at `local-public-web-build` and all later readonly/mutation browser proof remains deferred until replay onto the principal authoritative branch.

Load `ci-equivalent-governance` whenever this workflow needs to interpret `CI-Equivalent`, decide whether a named broad local gate such as `stage-full` is truly parity-complete, or judge whether a narrower local bundle is merely diagnostic.

The sequencing branch is execution topology only. It is not a second TODO authority, not a promotion lane, and not a replacement for the normal TODO delivery/closeout guards. Prefer the branch family `sequence/*` so the lane is visibly distinct from orchestration-only `reconcile/*`.

Checkpoint commits/pushes still obey the canonical governed-commit rule. The sequencing plan must record the exact authority source that authorizes checkpoint commits/pushes on the sequencing branch before any checkpoint commit is created. Valid sources include explicit user instruction, explicit workflow/plan lane authority, or another governing approval artifact that makes the sequencing checkpoint write-path autonomous.

## Triggers
- The user explicitly asks for TODO sequencing, package sequencing, or execution ordering that minimizes rework.
- Multiple approved TODOs touch overlapping surfaces, shared contracts, generated artifacts, or broad validation surfaces where parallel work would create churn.
- Each sequencing unit must land as a locally functional checkpoint before the next sequencing unit starts.

## Inputs
- Governing TODO set with approval evidence (`APROVADO`) or an explicitly approved package plan that covers the same TODO set.
- Stable base branch or base commit for the sequencing wave.
- Project-owned checkpoint-gate topology: an exact affected-area checkpoint bundle for every sequencing unit plus one parity-complete broad local gate (`stage-full` or an exact equivalent) for integrated package closeout.
- Sequencing execution plan under `foundation_documentation/artifacts/execution-plans/`.
- Checkpoint manifest path under `foundation_documentation/artifacts/checkpoints/`.
- Governing package TODO folder inventory (typically `foundation_documentation/todos/active/<version>/`) so checkpoint-time follow-up discovery can be compared against the current sequencing plan.
- Canonical return branch that receives the accepted net effect after final user validation.

## Procedure
1. **Confirm authority and bound the package**
   - Use this workflow only when multiple approved TODOs will run sequentially on one lane.
   - If any TODO is not yet refined/approved enough for execution, stop sequencing and send that TODO back through the normal TODO-driven approval path first.
   - Create or update a sequencing execution plan from `delphi-ai/templates/sequencing_execution_plan_template.md`.
   - Save that plan in the downstream project at `foundation_documentation/artifacts/execution-plans/<short-slug>.md`.
   - Treat the plan as the package-stage ledger for this sequential package. Record order, granularity, blockers, current active sequencing unit, latest green checkpoint, and next exact step there instead of inventing a parallel status artifact.
2. **Build the order and checkpoint granularity deliberately**
   - Evaluate dependency direction, shared files/modules, migration/contract risk, generated artifact coupling, runtime invalidation, and rollback cost.
   - Prefer an order that establishes shared contracts and shared plumbing first when later TODOs depend on them.
   - Prefer an order that groups hot validation surfaces together when doing so reduces repeated runtime/bootstrap churn without weakening proof quality.
   - Default the checkpoint unit to one approved TODO plus one exact affected-area checkpoint bundle.
   - Admit a multi-TODO micro-batch only when every member TODO is already bounded and approved, the members share one repository family or one validation surface, no member still depends on an unresolved external decision or audit-perimeter freeze, the combined diff is still small enough for unambiguous failure triage, and every TODO-specific local evidence bundle will still run before the shared affected-area checkpoint bundle.
   - Record each admitted sequencing unit explicitly in the plan, including why that unit size is safe, what the shared validation surface is, and whether user granularity review is still pending.
   - If the chosen order or granularity changes later, refresh the plan before continuing.
3. **Establish sequencing topology**
   - Freeze one base branch or base commit for the sequencing wave.
   - Create one sequencing branch from that base, preferably `sequence/<slug>`.
   - Record the canonical return branch that will receive the accepted net effect after final user validation.
   - Record the exact affected-area checkpoint bundle that must pass after each sequencing unit. It must contain the direct touched/consumed test, guard, build, or runtime surfaces; it must not default to `stage-full`, a promotable wrapper, or another parity-complete broad gate. For every Flutter-changing unit, record the separate mandatory stable full-workspace live Problems snapshot and matching architecture/rule review; never replace it with an edited-file or directory subset, and never start a concurrent CLI analyzer.
   - Record one later package-closeout broad local gate and the state where it runs. If the sequencing branch is isolated, that state is the principal canonical branch after replay; if the sequencing branch is principal, it runs there after the final unit only.
   - State what each unit gate must not claim: `CI-Equivalent`, promotable parity, package completeness, browser/runtime freshness, readonly completion, mutation completion, or web-build proof.
   - If the later package-closeout broad gate is `stage-full`, the recorded isolated lane must explicitly stop before `browser-stage-full`; that means it never enters `local-public-web-build`, readonly smoke, or mutation smoke from the isolated worktree.
   - Record the explicit checkpoint commit/push authority source before any checkpoint commit is created.
   - Before any direct sequencing checkpoint commit/push, run `python3 delphi-ai/tools/git_write_authority_guard.py --repo <repo-path> --action <git-commit|git-push>` and require `Overall outcome: go`.
   - Record that `sequence/*` is a checkpoint lane only and may never be treated as the promotion source branch.
4. **Execute one sequencing unit at a time**
   - Run the current sequencing unit through the normal TODO-driven execution flow on the sequencing branch.
   - When the current sequencing unit reaches delivery gates, the sequencing plan still owns the branch-state gate for that unit: use the recorded affected-area checkpoint bundle, not an ad hoc broader substitute chosen from habit.
   - For a single-TODO unit, that means one governing TODO. For an admitted micro-batch, finish each member TODO's own local evidence and close-claim prerequisites before running the shared affected-area checkpoint bundle.
   - Do not start the next sequencing unit while the current sequencing unit still lacks its required delivery evidence or deterministic close-claim guards.
   - Run the recorded affected-area checkpoint bundle on the current sequencing branch state after the current sequencing unit's TODO-specific delivery gates are green. For Flutter-changing units, complete the mandatory stable full-workspace live Problems snapshot and matching architecture/rule review before treating the checkpoint as green; this does not escalate the test/runtime bundle into `stage-full`.
   - If that recorded checkpoint gate fails, fix the current unit or record a blocker before proceeding. Do not defer the breakage to a later TODO.
   - If a micro-batch grows beyond its recorded safe boundary mid-execution, stop, split the batch back into smaller units, and refresh the plan before continuing.
5. **Checkpoint only from green states**
   - After the current sequencing unit and the recorded checkpoint gate are both green, update every affected TODO status/evidence/next exact step.
   - If final package broad-gate validation and canonical replay still remain, record each completed TODO as checkpointed with the package-closeout dependency explicit. Do not claim `CI-Equivalent`, package-complete, or promotion-ready from the targeted checkpoint.
   - Create and push the checkpoint commit only after the sequencing plan's commit/push authority is satisfied.
   - Create or update the checkpoint manifest from `delphi-ai/templates/sequencing_checkpoint_manifest_template.md`.
   - Each checkpoint must represent a functional branch state that already passed the recorded affected-area checkpoint bundle. The manifest must state that the package-closeout broad gate remains pending. No TODO inside an admitted micro-batch may be checkpointed before the shared checkpoint bundle passes.
6. **Run the checkpoint-time follow-up discovery scan**
   - Before activating the next sequencing unit, rescan the governed package folder for newly appeared TODOs or follow-up owners that are not already represented in the sequencing plan.
   - For each newly discovered TODO, classify it explicitly:
     - `already contemplated` when an existing open owner or sequencing unit already governs that exact scope;
     - `merge into open owner` when the scope belongs inside a touched owner that is still open and not yet checkpointed/delivered;
     - `new sequencing owner` when the scope is materially separate or when the natural parent owner is already checkpointed/delivered and must not be reopened.
   - Record the classification result in the sequencing plan before the next unit starts.
   - If the new TODO changes package order, granularity, or ownership boundaries, refresh the sequencing plan immediately instead of deferring that reconciliation.
7. **Advance the package ledger**
   - Mark the current sequencing unit as checkpointed in the sequencing plan.
   - Move the next TODO or next admitted micro-batch into the active position only after the previous unit's checkpoint has been recorded.
   - If execution discovers that the order, checkpoint granularity, or package boundary is now wrong or incomplete, stop and refresh the sequencing plan before starting the next unit.
8. **Finish targeted checkpoints before package closeout**
   - When the last sequencing unit and its final affected-area checkpoint bundle are green, record a package-ready-for-integration checkpoint.
   - Do not run the broad local gate earlier merely because an individual unit completed. It is now required exactly once for the integrated package.
   - If the sequencing branch is isolated, ask the user to validate the sequencing branch result before replaying anything onto the canonical return branch.
   - Do not treat the sequencing branch itself as promotable or complete beyond the targeted package checkpoint claim.
9. **Replay and run the single broad package gate**
   - After the user validates the sequencing branch, replay the accepted net effect onto the canonical return branch.
   - Run the recorded parity-complete broad local gate once on the resulting principal canonical package state before `Local-Implemented`, package-complete, or promotion-ready claims.
   - If the sequencing lane is already principal, omit replay and run that one broad gate after the final targeted checkpoint.
   - If replay introduces conflicts, manual reconciliation, dropped hunks, or other non-trivial source-branch-only change, resolve them before the single broad gate; do not create a second per-unit broad run.

## Outputs
- Sequencing execution plan under `foundation_documentation/artifacts/execution-plans/`.
- One checkpoint-only sequencing branch, preferably `sequence/*`.
- A deliberate TODO order plus an explicit checkpoint-granularity board that keeps micro-batch exceptions reviewable.
- A functional checkpoint commit/push after each completed sequencing unit that already passed its recorded checkpoint gate.
- Checkpoint manifests under `foundation_documentation/artifacts/checkpoints/`.
- One parity-complete broad local gate result for the fully integrated package before promotion closeout.
- Explicit final user validation before replay onto the canonical return branch.

## Validation
- No TODO starts on the package before the sequencing plan records the order, the checkpoint granularity, and the governing TODO authority.
- Every sequencing unit defaults to one TODO unless an admitted micro-batch is explicitly recorded in the plan with shared-surface rationale and user-review status.
- Every sequencing unit passes its required delivery guards plus its recorded affected-area checkpoint bundle before the next sequencing unit starts.
- The plan records the exact touched/consumed validation bundle for every unit and one later parity-complete broad local gate for the integrated package.
- Delivery gates do not silently substitute the package-closeout broad gate into a per-unit checkpoint.
- Every checkpoint includes a fresh governed-folder scan for newly appeared follow-up TODOs, plus an explicit classification of whether each new item is already contemplated, should merge into an open owner, or must become fresh sequencing work.
- No TODO inside an admitted micro-batch is checkpointed before the shared affected-area checkpoint bundle passes.
- No checkpoint manifest or TODO claim treats a per-unit gate as `CI-Equivalent`, promotable, package-complete, browser-readonly complete, browser-mutation complete, web-build complete, or authoritative runtime-fresh.
- The broad local gate runs once only after all admitted units' targeted checkpoints are green, on the principal canonical state; when that gate is `stage-full` and the lane was isolated, the isolated lane stops before `browser-stage-full` and all later browser proof waits for replay.
- Delivered/checkpointed TODOs are not reopened solely to absorb newly discovered follow-up work; new scope is routed as fresh sequencing work when the natural parent owner is already closed or checkpointed.
- Checkpoint commits/pushes occur only after a green branch state and an explicit recorded commit/push authority source.
- The sequencing branch is never treated as a promotion source branch.
- Final replay onto the canonical branch happens only after explicit user validation of the sequencing branch result.
- The sequencing plan is refreshed whenever the required order, checkpoint granularity, or package boundaries change materially.
