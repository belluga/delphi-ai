---
name: "docker-todo-sequencing-method"
description: "Sequence multiple approved tactical TODOs through one checkpoint branch, defaulting to one checkpoint gate per TODO and deferring the parity-complete broad local gate to the authoritative branch whenever the sequencing lane is isolated."
---

<!-- Generated from `workflows/docker/todo-sequencing-method.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# Workflow: TODO Sequencing

## Purpose
Coordinate one execution lane across multiple approved TODOs when the main risk is rework, not parallelism. This workflow creates a sequencing plan that decides the safest order and checkpoint granularity, defaults the checkpoint unit to one TODO, allows a shared micro-batch unit only when that exception is explicitly admitted in the plan, runs each sequencing unit to its own local-delivery bar, records whether the lane uses an authoritative broad local gate or only a non-authoritative checkpoint prefix gate, requires the recorded checkpoint gate after every completed sequencing unit before the next begins, defers the parity-complete broad local gate to the canonical replay branch whenever the sequencing lane is isolated from the authoritative runtime/browser surface, records functional checkpoints on a dedicated sequencing branch, and pauses for explicit user validation before replaying the accepted net effect onto the canonical branch. When that later broad gate is `stage-full`, the isolated checkpoint prefix must stop before `browser-stage-full`, so the skipped boundary starts at `local-public-web-build` and all later readonly/mutation browser proof remains deferred until replay onto the principal authoritative branch. Any TODO that closes only on that non-authoritative prefix remains explicitly provisional until replay onto the principal authoritative branch and the deferred broad gate both succeed.

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
- Project-owned checkpoint-gate topology for each sequencing unit: either the authoritative broad local stage gate (`stage-full` or an exact equivalent broad local gate) or an explicit non-authoritative prefix gate plus the later authoritative broad local gate that remains mandatory after replay.
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
   - Default the checkpoint unit to one approved TODO plus one broad local stage gate.
   - Admit a multi-TODO micro-batch only when every member TODO is already bounded and approved, the members share one repository family or one validation surface, no member still depends on an unresolved external decision or audit-perimeter freeze, the combined diff is still small enough for unambiguous failure triage, and every TODO-specific local evidence bundle will still run before the shared broad gate.
   - Record each admitted sequencing unit explicitly in the plan, including why that unit size is safe, what the shared validation surface is, and whether user granularity review is still pending.
   - If the chosen order or granularity changes later, refresh the plan before continuing.
3. **Establish sequencing topology**
   - Freeze one base branch or base commit for the sequencing wave.
   - Create one sequencing branch from that base, preferably `sequence/<slug>`.
   - Record the canonical return branch that will receive the accepted net effect after final user validation.
   - Record the exact checkpoint gate command that must pass after each sequencing unit checkpoint.
   - If the sequencing branch is the current authoritative local surface, that checkpoint gate should be the project's broad local stage gate (`stage-full` or an exact equivalent broad local gate).
   - If the sequencing branch is an isolated worktree or other non-authoritative surface, record instead the exact narrower checkpoint prefix gate, state what it must not claim (for example `CI-Equivalent`, promotable parity, browser/runtime freshness, readonly completion, mutation completion, or web-build proof), and also record the later authoritative broad local gate that still remains mandatory after replay.
  - If that later broad local gate is `stage-full`, the recorded isolated prefix must explicitly stop before `browser-stage-full`; that means the isolated lane never enters `local-public-web-build`, readonly smoke, or mutation smoke from the isolated worktree, and the plan must not describe the prefix vaguely as "the first part of stage-full" without naming that cutoff.
   - Record the explicit checkpoint commit/push authority source before any checkpoint commit is created.
   - Before any direct sequencing checkpoint commit/push, run `python3 delphi-ai/tools/git_write_authority_guard.py --repo <repo-path> --action <git-commit|git-push>` and require `Overall outcome: go`.
   - Record that `sequence/*` is a checkpoint lane only and may never be treated as the promotion source branch.
4. **Execute one sequencing unit at a time**
   - Run the current sequencing unit through the normal TODO-driven execution flow on the sequencing branch.
   - When the current sequencing unit reaches delivery gates, the sequencing plan still owns the branch-state gate for that unit: use the recorded checkpoint gate, not an ad hoc broader substitute chosen from habit.
   - For a single-TODO unit, that means one governing TODO. For an admitted micro-batch, finish each member TODO's own local evidence and close-claim prerequisites before running the shared broad local stage gate.
   - Do not start the next sequencing unit while the current sequencing unit still lacks its required delivery evidence or deterministic close-claim guards.
   - Run the recorded checkpoint gate on the current sequencing branch state after the current sequencing unit's TODO-specific delivery gates are green.
   - If that recorded checkpoint gate fails, fix the current unit or record a blocker before proceeding. Do not defer the breakage to a later TODO.
   - If a micro-batch grows beyond its recorded safe boundary mid-execution, stop, split the batch back into smaller units, and refresh the plan before continuing.
5. **Checkpoint only from green states**
   - After the current sequencing unit and the recorded checkpoint gate are both green, update every affected TODO status/evidence/next exact step.
   - If final package user validation and canonical replay still remain, record each completed TODO as locally delivered but still package-pending. Prefer `Current delivery stage: Local-Implemented` with `Qualifiers: Provisional` unless the governing TODO's own closeout path requires a different still-open state. This provisional qualifier is mandatory when the passed checkpoint gate is only a non-authoritative prefix and the later authoritative broad local gate still remains.
   - Create and push the checkpoint commit only after the sequencing plan's commit/push authority is satisfied.
   - Create or update the checkpoint manifest from `delphi-ai/templates/sequencing_checkpoint_manifest_template.md`.
   - Each checkpoint must represent a functional branch state that already passed the recorded checkpoint gate on the sequencing branch. If that gate is non-authoritative, the manifest must say so explicitly and keep the TODO/package state provisional. No TODO inside an admitted micro-batch may be checkpointed before the shared checkpoint gate passes.
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
8. **Finish on explicit user validation**
   - When the last sequencing unit and its final recorded checkpoint gate are green, record a package-ready checkpoint on the sequencing branch.
   - If the package has been running under a non-authoritative checkpoint prefix gate, do not imply that the parity-complete broad local gate is done yet; that authoritative gate still belongs to the canonical replay branch.
   - Ask the user to validate the sequencing branch result before replaying anything onto the canonical return branch.
   - Do not treat the sequencing branch itself as promotable or complete beyond the package-local checkpoint claim.
9. **Replay only after validation**
   - After the user validates the sequencing branch, replay the accepted net effect onto the canonical return branch.
   - If the sequencing lane used only a non-authoritative checkpoint prefix gate, the authoritative broad local stage gate is still required on the canonical branch before promotion or closeout resumes.
   - If the replay is a pure fast-forward or conflict-free curated replay, run at least a bounded sanity pass on the canonical branch unless the governing package requires the authoritative broad local gate immediately.
   - If the replay introduces conflicts, manual reconciliation, dropped hunks, or other non-trivial source-branch-only change, rerun the in-scope authoritative broad local gate on the canonical branch before promotion or closeout resumes.

## Outputs
- Sequencing execution plan under `foundation_documentation/artifacts/execution-plans/`.
- One checkpoint-only sequencing branch, preferably `sequence/*`.
- A deliberate TODO order plus an explicit checkpoint-granularity board that keeps micro-batch exceptions reviewable.
- A functional checkpoint commit/push after each completed sequencing unit that already passed its recorded checkpoint gate.
- Checkpoint manifests under `foundation_documentation/artifacts/checkpoints/`.
- Explicit final user validation before replay onto the canonical return branch.

## Validation
- No TODO starts on the package before the sequencing plan records the order, the checkpoint granularity, and the governing TODO authority.
- Every sequencing unit defaults to one TODO unless an admitted micro-batch is explicitly recorded in the plan with shared-surface rationale and user-review status.
- Every sequencing unit passes its required delivery/closeout guards plus its recorded checkpoint gate before the next sequencing unit starts.
- When the sequencing lane is non-authoritative, the plan explicitly records the narrower checkpoint prefix gate, the claims that gate must not make, and the later authoritative broad local gate required after replay.
- Delivery gates on isolated sequencing lanes inherit the plan's recorded checkpoint gate and do not silently substitute the deferred authoritative broad gate before replay.
- Every checkpoint includes a fresh governed-folder scan for newly appeared follow-up TODOs, plus an explicit classification of whether each new item is already contemplated, should merge into an open owner, or must become fresh sequencing work.
- No TODO inside an admitted micro-batch is checkpointed or marked delivered before the shared broad local gate passes.
- No checkpoint manifest or TODO claim treats a non-authoritative sequencing worktree as `CI-Equivalent`, promotable, browser-readonly complete, browser-mutation complete, web-build complete, or authoritative runtime-fresh.
- When the broad gate is `stage-full`, the recorded isolated prefix explicitly stops before `browser-stage-full`; the isolated lane therefore skips `local-public-web-build` and all later readonly/mutation browser proof until replay onto the principal authoritative branch.
- Delivered/checkpointed TODOs are not reopened solely to absorb newly discovered follow-up work; new scope is routed as fresh sequencing work when the natural parent owner is already closed or checkpointed.
- Checkpoint commits/pushes occur only after a green branch state and an explicit recorded commit/push authority source.
- The sequencing branch is never treated as a promotion source branch.
- Final replay onto the canonical branch happens only after explicit user validation of the sequencing branch result.
- The sequencing plan is refreshed whenever the required order, checkpoint granularity, or package boundaries change materially.
