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

Implementation evidence can include code, analyzer, unit, widget, package, repository, feature/API, and targeted tests. Runtime/Web evidence is the final acceptance lane for visible behavior. For Flutter visible behavior, write `shared-android-web`, `android-only`, `web-only`, or `divergent-android-web` in the Runtime / Web Evidence plan. Shared behavior can close with either ADB integration or Playwright navigation; divergent Android/Web behavior requires both.

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
- **Worker branches / worktrees:** `<worker branch names or creation policy>`

## Checkpoint / Branch Accumulation Control
- **Checkpoint manifest path:** `foundation_documentation/artifacts/checkpoints/<short-slug>-<YYYY-MM-DD>.md`
- **Checkpoint policy:** checkpoints are pushed recovery states plus manifests, not indefinite accumulation branches.
- **Allowed checkpoint statuses:** `wip_checkpoint`, `validated_local_checkpoint`, `promotion_ready_checkpoint`, `superseded_checkpoint`.
- **Same-branch continuation rule:** continue on the orchestrator branch only while the work remains inside this approved plan and the checkpoint manifest records the next exact step. After promotion, supersession, or scope drift, start from the promoted target branch or a fresh/rebased orchestrator branch.
- **Build artifact policy:** generated deploy bundles such as `web-app` are excluded unless the plan explicitly owns deploy-artifact promotion.

## Workstreams
Derive workstreams from the Acceptance Traceability Matrix. A workstream may group related criteria, but it must not hide a specific required UI artifact, endpoint, schema change, test lane, or runtime journey.

| Workstream | Ownership Boundary | Inputs / Dependencies | Output Checkpoint | Worker-Local Validation |
| --- | --- | --- | --- | --- |
| `<WS-01>` | `<files/modules/packages>` | `<dependencies>` | `<commit/evidence expected>` | `<tests/checks>` |

## Execution Ownership Ledger
| Workstream | Implementation Owner | Orchestrator Code Scope | Worker Checkpoint Evidence | Reconciliation Evidence |
| --- | --- | --- | --- | --- |
| `<WS-01>` | `<worker/subagent name>` | `<none|merge-conflict-only|reconciliation-only>` | `<checkpoint commit/evidence expected>` | `<merge/cherry-pick/test evidence expected>` |

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

## Consolidated Delivery Evidence
Fill this section only after execution, before claiming local implementation or delivery completion.

| Area | Required Evidence | Status | Evidence Artifact / Command | Owner |
| --- | --- | --- | --- | --- |

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
