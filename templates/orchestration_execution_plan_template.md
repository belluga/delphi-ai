# Template: Orchestration Execution Plan

Use this file as a starting point for:

`foundation_documentation/artifacts/execution-plans/<short-slug>.md`

This artifact belongs to the downstream project's `foundation_documentation/artifacts/` tree, not to PACED/Delphi internal docs.

## Artifact Identity
- **Artifact type:** `orchestration_execution_plan`
- **Status:** `<Draft|Pending Approval|Approved|Superseded|Canceled>`
- **Created:** `<YYYY-MM-DD>`
- **Governing workflow / skill:** `delphi-ai/workflows/docker/subagent-worktree-reconciliation-method.md`
- **Approval token required before execution:** `APROVADO`

## Authority Boundary
- Governing TODOs define **WHAT** must be delivered and what counts as done.
- This plan defines **HOW** the orchestrator intends to sequence, parallelize, reconcile, and validate the work.
- If this plan conflicts with a governing TODO, stop and update the TODO or this plan before execution.
- This plan does not create a new backlog authority, tactical TODO, or approval conversation.
- Requirement wording in governing TODOs is literal. Replacing a named artifact, UI control, navigation path, runtime target, or validation lane requires an approved row in the Spec Deviation Ledger before execution or delivery can proceed.
- Workstreams must be derived from acceptance criteria and validation requirements, not broad implementation themes. Every criterion must have a non-orchestrator implementation owner and planned evidence before dispatch.

## Governing TODO Set
| ID | TODO | Role in Plan | Start Eligibility |
| --- | --- | --- | --- |
| `<PLAN-A>` | `foundation_documentation/todos/active/<lane>/<todo>.md` | `<blocker|independent|dependent|integration>` | `<can start|blocked by PLAN-X|planning only>` |

## Acceptance Traceability Matrix
Every governing TODO `Definition of Done`, `Validation Steps`, and accepted decision marker must appear here as an exact or clearly quoted criterion before approval. During execution, workers update implementation/test evidence fields for their owned rows; the orchestrator only reconciles and validates final runtime evidence.

Implementation evidence can include code, static-analysis snapshot, unit, widget, package, repository, feature/API, and targeted tests. Flutter local static evidence is the stable full-workspace VS Code Problems bridge snapshot plus static-rule review, not a CLI analyzer run. Runtime/Web evidence is the final acceptance lane for visible behavior. For Flutter visible behavior, write `shared-android-web`, `android-only`, `web-only`, or `divergent-android-web` in the Runtime / Web Evidence plan. Shared behavior can close with either ADB integration or Playwright navigation; divergent Android/Web behavior requires both.

| Requirement ID | Source TODO / Criterion | Implementation Owner | Required Artifact / UI Marker | Implementation Evidence | Test Evidence | Runtime / Web Evidence | Status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `<PLAN-A-DOD-01>` | `<exact DoD / validation / decision text from governing TODO>` | `<worker/subagent name>` | `<FAB|tab|route|endpoint|schema|n/a>` | `<planned evidence before execution; passed artifact after execution>` | `<planned test before execution; passed command/artifact after execution>` | `<planned runtime/web/device evidence or n/a>` | `<planned|passed|blocked|waived>` |

## Spec Deviation Ledger
Use this only when the implementation intentionally diverges from a governing TODO term. Unapproved deviations are blockers; the correct default is to implement the TODO exactly.

| Source TODO / Criterion | Original Requirement | Proposed Deviation | Approval Evidence | Status |
| --- | --- | --- | --- | --- |
| `none` | `No spec deviations approved.` | `n/a` | `n/a` | `n/a` |

## Dependency Graph
- `<PLAN-A>` blocks `<PLAN-B>` because `<reason>`.
- `<PLAN-C>` is independent from `<PLAN-A>` because `<reason>`.

## Orchestration Topology
- **Base branch / commit:** `<origin/dev|commit sha>`
- **Orchestrator reconciliation branch:** `<orchestrator/<slug>|n/a until approved>`
- **Principal checkout policy:** `<principal checkout stays on reconciliation branch when runtime/browser/device validation depends on it>`
- **Runtime-facing source checkouts:** `<root + mounted source repos/submodules that must be on reconcile/* before authoritative local validation>`
- **Authoritative return branch after reconcile:** `<canonical version branch that receives the accepted net effect before promotion or non-orchestration closeout resumes>`
- **Reconcile failure routing rule:** `<CI-Equivalent/runtime failures on reconcile return to the owning worker/subagent or TODO owner; orchestrator patches stay reconciliation-only>`
- **Promotion source after reconcile:** `<authoritative return branch only; reconcile branch itself is never the promotable lane>`
- **Worker branches / worktrees:** `<worker branch names or creation policy>`
- **Derived artifact repos:** `<web-app or equivalent derived bundle repos that are not branch-authority sources>`

## Checkpoint / Branch Accumulation Control
- **Checkpoint manifest path:** `foundation_documentation/artifacts/checkpoints/<short-slug>-<YYYY-MM-DD>.md`
- **Checkpoint policy:** checkpoints are pushed recovery states plus manifests, not indefinite accumulation branches.
- **Allowed checkpoint statuses:** `wip_checkpoint`, `validated_local_checkpoint`, `promotion_ready_checkpoint`, `superseded_checkpoint`.
- **Same-branch continuation rule:** continue on the orchestrator branch only while the work remains inside this approved plan and the checkpoint manifest records the next exact step. After promotion, supersession, or scope drift, start from the promoted target branch or a fresh/rebased orchestrator branch.
- **Build artifact policy:** generated deploy bundles such as `web-app` are excluded unless the plan explicitly owns deploy-artifact promotion.

## Pre-Promotion Review Loop Ledger
Use this section when the package enters an internal no-context pre-promotion review loop. This is the package-stage ledger for the loop. Do not create a separate manual version-status file for the same purpose. Accepted/challenged/resolved findings remain authoritative in the governing TODOs and their carry-forward packets.

- **Loop in scope?:** `<yes|no>`
- **Authoritative source branch:** `<source branch intended for promotion; if the package was first integrated on reconcile, this is the post-replay canonical branch, not the reconcile branch itself>`
- **Active remediation branch:** `<review/<slug>-internal-YYYYMMDD>|n/a>`
- **Current round:** `<round identifier>`
- **Last clean internal round:** `<round identifier|none yet>`
- **Open package blockers:** `<TODO ids / short reasons>`
- **Historical finding authority:** `<governing TODO carry-forward packet / TODO-local dispositions>`
- **Review-branch CI-equivalent gate:** `<full in-scope matrix must pass here before replay/consolidation>`
- **Authoritative-source post-replay policy:** `<sanity-only on pure ff/conflict-free replay | full matrix rerun when replay was non-trivial>`
- **Next exact step:** `<the single exact next action for a no-context resume>`

### Review Coverage Board
Use this table to make package coverage explicit and resume-safe. Every governing TODO in the package must appear here once the pre-promotion review loop starts.

| TODO ID | Review Status (`not-reviewed|in-review|reopened-fixed|clean-no-reopen|blocked`) | Latest Evidence Round / Commit | Notes / Blocker |
| --- | --- | --- | --- |
| `<PLAN-A>` | `<not-reviewed>` | `<round-id|commit|n/a>` | `<short note>` |

### Anti-Loop Exit Criteria
- Stop the internal loop only when every governing TODO is either `clean-no-reopen` or has an explicit approved `blocked/waived` disposition.
- Do not reopen a previously adjudicated finding unless the current diff materially changed the same locus/behavior or the prior rationale is objectively insufficient.
- Do not replay the remediation branch onto the authoritative source branch before the review-branch CI-equivalent gate is green.

## Workstreams
Derive workstreams from the Acceptance Traceability Matrix. A workstream may group related criteria, but it must not hide a specific required UI artifact, endpoint, schema change, test lane, or runtime journey.

| Workstream | Ownership Boundary | Inputs / Dependencies | Output Checkpoint | Worker-Local Validation |
| --- | --- | --- | --- | --- |
| `<WS-01>` | `<files/modules/packages>` | `<dependencies>` | `<commit/evidence expected>` | `<tests/checks>` |

## Execution Ownership Ledger
| Workstream | Implementation Owner | Orchestrator Code Scope | Worker Checkpoint Evidence | Reconciliation Evidence |
| --- | --- | --- | --- | --- |
| `<WS-01>` | `<worker/subagent name>` | `<none|merge-conflict-only|reconciliation-only>` | `<checkpoint commit/evidence expected>` | `<merge/cherry-pick/test evidence expected>` |

## Worker Routing Contracts
Record one row per governed execution, monitoring, or review lane when the active client exposes model selection, named agents/subagents, or explicit routing policy that must stay visible. The row should match the same contract used by `python3 delphi-ai/tools/agent_role_routing_guard.py ...`.

| Workstream / Surface | Worker / Subagent | Governed Action | Required Role | Selected Model | Selected Effort | Proof Mode | Guard Outcome | Waiver / Exception Reference |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `<WS-01>` | `<worker/subagent name>` | `<implementation|implementation-validation|monitoring|formal-review|todo-approval|delivery-review>` | `<routine-executor|formal-reviewer|process-monitor|deterministic-only>` | `<model>` | `<effort or n/a>` | `<artifact|declared|waiver>` | `<go>` | `<n/a or reference>` |

## Worker Goal Contracts
Record one row per executor workstream when the active client exposes persistent goals. Derive the decision from `delphi-ai/workflows/docker/effort-selection-method.md`. Review-only/no-context subagents stay stateless by default and should not receive these goal contracts unless the client/tool requires resumable reviewer state for a bounded package.

| Workstream | Worker / Subagent | Goal Objective | Must Pass Before `complete` | `blocked` Condition |
| --- | --- | --- | --- | --- |
| `<WS-01>` | `<worker/subagent name>` | `<single bounded objective tied to owned rows/artifacts>` | `<Flutter: stable full-workspace Problems bridge snapshot + static-rule review; otherwise named lint/static gate; targeted tests; applicable build/publish gates>` | `<exact condition that returns ownership/blocker to the orchestrator>` |

## Execution Waves
Waves are orchestrator-owned control checkpoints. They are not user feedback gates and must not stop execution by default. Stop only for a mandatory user decision, scope change, conflict with the governing TODO set, real blocker, or explicit validation waiver.

### Wave 0 - Preflight / Approval
- <No-code/readiness actions before execution>

### Wave 1 - <Name>
- <Parallel or sequential work items>
- **Gate to next wave:** <objective gate>

### Wave 2 - <Name>
- <Parallel or sequential work items>
- **Gate to next wave:** <objective gate>

## Consolidated Validation Matrix
Every row must be traceable to one or more Acceptance Traceability Matrix rows. UI-facing rows must name browser/device/navigation/runtime evidence explicitly when the governing TODO includes UI, navigation, web, map, public surface, admin screen, or interaction behavior. Record whether Android and Web behavior is shared or divergent; require both ADB and Playwright only when behavior differs materially across platforms.

| Area | Required Evidence | Runtime Target | Owner |
| --- | --- | --- | --- |
| `<area>` | `<test/build/navigation evidence>` | `<worker|reconciliation|device|browser>` | `<worker|orchestrator>` |

## CI-Equivalent Local Suite Matrix
Every repo-owned CI suite/job that the touched repositories will execute for this wave must be represented here before approval. CI-Equivalent is current-branch local product proof: run it from the authoritative branch currently under evaluation, using the project-owned local build/publish path and the same product-facing suites/jobs the pipeline uses for that scope. For package/version promotion lanes, that authoritative branch is usually the governing-TODO version branch such as `v0.2.0+8-rc`, and this matrix must pass there before any derived `review/*` remediation branch can substitute additional evidence. If the project exposes a named broad local stage profile such as `stage-full`, that profile must be the parity-complete local mirror of the stage pipeline for the touched scope on that branch; narrower diagnostic bundles must use distinct names and must not be reported as that broad stage gate. In a reconciliation workflow that authoritative branch is often the reconciliation branch, but reconcile topology is not what makes the run CI-Equivalent. The orchestrator may run targeted reruns diagnostically, but local delivery and promotion readiness are blocked until every in-scope row has been executed locally and passed on the authoritative branch state for this wave. Once the reconciliation state is green, replay the accepted net effect onto the `Authoritative return branch after reconcile` before promotion resumes. Published `stage`/`main` probes are separate evidence and do not replace this matrix. For high-coupling surfaces such as auth, shared runtime wiring, navigation/browser behavior, publish bundles, or submodule-mounted apps, treat this matrix as the minimum floor and add the broader local suites that are cheaper to fail here than later in CI or promotion.

| Repository / CI Surface | Why In Scope | Local CI-Equivalent Command | Applies To (`worker-local|reconciliation|pre-promotion`) | Status (`planned|passed|blocked|waived|n/a`) | Evidence Artifact / Command | Owner |
| --- | --- | --- | --- | --- | --- | --- |
| `<flutter-app / Validate and Build Web>` | `<why this CI surface is in scope>` | `<exact local command that mirrors the CI job>` | `<reconciliation>` | `<planned>` | `<planned output path / report / n/a>` | `<worker|orchestrator>` |

## Consolidated Delivery Evidence
Fill this section only after execution, before claiming local implementation or delivery completion.

| Area | Required Evidence | Status | Evidence Artifact / Command | Owner |
| --- | --- | --- | --- | --- |

## Post-Reconcile Replay Evidence
Fill this section once the reconciliation branch is green and the accepted net effect has been replayed onto the canonical branch that promotion or non-orchestration closeout will resume from.

- **Replay required?:** `<yes when this package was first integrated on reconcile/*>`
- **Replay status:** `<pending|passed|blocked|waived|n/a>`
- **Accepted reconcile branch:** `<reconcile/<slug>>`
- **Accepted reconcile commit:** `<git sha for the accepted integrated state>`
- **Replay mode:** `<fast-forward|merge-commit|same-commit-alias|curated-replay>`
- **Authoritative return branch verified:** `<same canonical branch declared under Orchestration Topology>`
- **Authoritative return branch head after replay:** `<git sha now at the canonical return branch head>`
- **Promotion source branch verified:** `<same canonical branch; reconcile is never the promotion source>`
- **Replay commit(s) on authoritative branch:** `<same-as-reconcile|sha[, sha...]>`
- **Replay proof summary:** `<brief proof of how the accepted reconcile state reached the canonical branch>`
- **Post-replay authoritative CI-equivalent status:** `<passed|not-needed|waived|blocked>`

## Checkpoint Manifest
Fill this after the checkpoint commits/pushes are created.

- **Manifest path:** `foundation_documentation/artifacts/checkpoints/<short-slug>-<YYYY-MM-DD>.md`
- **Checkpoint status:** `<wip_checkpoint|validated_local_checkpoint|promotion_ready_checkpoint|superseded_checkpoint>`
- **Repositories pushed:** `<docker-root|flutter-app|laravel-app|foundation_documentation|web-app|...>`
- **Excluded dirty surfaces:** `<paths/repos intentionally excluded>`
- **Next branch lifecycle step:** `<promote|continue same approved wave|supersede|discard recovery branch>`

## Runtime Freshness Evidence
Required when any validation row involves web, browser, device, runtime, navigation, or build evidence.

Record concrete branch, commit, build artifact, served target, and freshness proof after execution. Leave this section without placeholder rows before execution.

## Runtime Surface Preflight
Fill this when browser/device/runtime validation is in scope.

- **Principal runtime target already in use:** `<public domain|local device|tunnel|container target>`
- **Bind-mount / served-source proof:** `<docker inspect / compose proof that target resolves to the principal checkout>`
- **Navigation env source:** `<already-exported shell vars|.env.local.navigation|other approved source>`
- **Auxiliary runtime required?:** `<no if principal target already serves reconcile state; otherwise blocker + reason>`

## Risk / Conflict Controls
- <Known merge, contract, migration, runtime, or validation risks>
- <How the orchestrator will prevent local filtering, stale runtime, hidden branch drift, or worker overlap>
- <How the orchestrator will prevent itself from becoming the implementation owner instead of reconciliation owner>

## Approval Request
- **Requested approval:** Reply `APROVADO` to authorize this orchestration plan.
- **Execution authorized by approval:** <exact first wave that will start after approval>
- **Execution not authorized by approval:** <explicit exclusions>
- **Autonomy rule:** once approved, the orchestrator advances through waves without requesting feedback between waves unless a mandatory decision/blocker/waiver condition appears.

## Plan Completion Guard
- **Command:** `python3 delphi-ai/tools/orchestration_plan_completion_guard.py --plan foundation_documentation/artifacts/execution-plans/<short-slug>.md`
- **Required before approval/execution:** `Overall outcome: go`

## Delivery Guard
- **Command:** `python3 delphi-ai/tools/orchestration_delivery_guard.py --plan foundation_documentation/artifacts/execution-plans/<short-slug>.md --require-approved`
- **Required before local implementation or delivery completion claim:** `Overall outcome: go`
- **Blocks delivery when:** any traceability row lacks passed implementation/test evidence, a UI/runtime criterion lacks the required fresh web/browser/device/navigation evidence, divergent Android/Web behavior lacks either lane, a named artifact was substituted without an approved spec deviation, or any implementation row names the orchestrator as owner.

## Post-Reconcile Replay Guard
- **Command:** `python3 delphi-ai/tools/orchestration_reconcile_replay_guard.py --plan foundation_documentation/artifacts/execution-plans/<short-slug>.md --repo <authoritative-source-repo>`
- **Required before promotion or non-orchestration closeout resumes from a package first integrated on reconcile:** `Overall outcome: go`
- **Blocks advancement when:** the accepted reconcile state was not replayed onto the canonical return branch, replay evidence is incomplete, the promotion source still points at `reconcile/*`, or a curated replay skipped the required canonical-branch CI-equivalent rerun.
