# Template: Sequencing Execution Plan

Use this file as a starting point for:

`foundation_documentation/artifacts/execution-plans/<short-slug>.md`

This artifact belongs to the downstream project's `foundation_documentation/artifacts/` tree, not to PACED/Delphi internal docs.

## Artifact Identity
- **Artifact type:** `sequencing_execution_plan`
- **Status:** `<Draft|Pending Approval|Approved|Checkpointing|Awaiting User Validation|Replayed|Superseded|Canceled>`
- **Created:** `<YYYY-MM-DD>`
- **Governing workflow / skill:** `delphi-ai/workflows/docker/todo-sequencing-method.md`
- **Approval token required before execution:** `APROVADO`

## Authority Boundary
- Governing TODOs define **WHAT** must be delivered and what counts as done.
- This plan defines **HOW** the package will be ordered, grouped, checkpointed, validated, and replayed.
- If this plan conflicts with a governing TODO, stop and refresh the TODO or this plan before execution.
- This plan is the package-stage ledger for the sequencing wave. Do not create a parallel manual version-status file for the same package.
- The sequencing branch is a checkpoint lane only. It is never the promotion source branch.
- If the sequencing lane is non-authoritative, this plan must record the exact checkpoint prefix gate, what that prefix must not claim, and the later authoritative broad local gate that still remains mandatory after replay.
- Checkpoint commits/pushes require explicit user or governing approval evidence. The plan must record that authority before any checkpoint commit is created.

## Governing TODO Set
| Order | TODO | Role in Sequence | Start Eligibility |
| --- | --- | --- | --- |
| `<SEQ-01>` | `foundation_documentation/todos/active/<lane>/<todo>.md` | `<foundational|dependent|independent|final-integration>` | `<can start|blocked by SEQ-00|planning only>` |

## Sequencing Order Board
Record why this order reduces rework. This is the core package-level decision surface.

| Order | TODO | Why This Position Avoids Rework | Shared Surface / Dependency Risk | Must Be True Before Start | Status (`planned|active|checkpointed|blocked|done`) |
| --- | --- | --- | --- | --- | --- |
| `1` | `<SEQ-01>` | `<reason>` | `<contracts/files/runtime surfaces>` | `<preconditions>` | `<planned>` |

## Sequencing Granularity Control
Default checkpoint unit is one approved TODO plus one recorded checkpoint gate. On authoritative branches that gate is normally the broad local stage gate; on isolated non-authoritative sequencing lanes it may instead be an explicit checkpoint prefix gate with a later authoritative broad local gate recorded below. Any multi-TODO checkpoint must be explicitly admitted here before execution.

- **Default checkpoint unit:** `one TODO per checkpoint gate`
- **Granularity override policy:** `only explicitly admitted micro-batches may share one checkpoint gate`
- **User granularity review status:** `<pending|approved|changes_requested>`

| Sequencing Unit | Member TODOs | Unit Type (`single-todo|micro-batch`) | Why This Size Is Safe | Shared Validation Surface | TODO-Local Gates Still Required? | Checkpoint Gate Boundary | User Review Status (`pending|approved|changes_requested`) |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `U-01` | `<SEQ-01>` | `single-todo` | `<why one TODO is the right unit here>` | `<repo family / validation surface>` | `yes` | `<gate runs after this unit>` | `<pending>` |

## Sequencing Topology
- **Base branch / commit:** `<origin/dev|v0.2.0+8-rc|commit sha>`
- **Sequencing branch:** `<sequence/<slug>>`
- **Canonical return branch after sequencing:** `<feature/<slug>|version branch|other authoritative branch>`
- **Promotion source after replay:** `<same canonical return branch only>`
- **Branch policy:** `sequence/* is checkpoint-only topology and may never be used as the promotion source`
- **Explicit user validation required before replay:** `yes`
- **Checkpoint commit / push authority:** `<user message, approved plan, or other explicit authority>`
- **Checkpoint gate while sequencing branch is non-authoritative (optional):** `<exact prefix command or n/a; if derived from stage-full, record the exact pre-browser cutoff and stop before browser-stage-full>`
- **Authoritative broad local stage gate after replay / on canonical branch:** `<stage-full or exact equivalent command>`
- **Replay validation policy:** `<bounded sanity pass on trivial replay | full broad gate rerun on non-trivial replay>`

## Checkpoint / Branch Accumulation Control
- **Checkpoint manifest path:** `foundation_documentation/artifacts/checkpoints/<short-slug>-<YYYY-MM-DD>.md`
- **Checkpoint policy:** every checkpoint is a pushed functional state that already passed the recorded checkpoint gate for the current sequencing unit. If that gate is non-authoritative, the checkpoint state must remain provisional until the later authoritative broad local gate passes after replay.
- **Allowed checkpoint statuses:** `todo_validated_checkpoint`, `package_ready_checkpoint`, `superseded_checkpoint`
- **Same-branch continuation rule:** continue on the sequencing branch only while the next work remains inside this approved plan and the checkpoint manifest records the next exact step. After replay, supersession, or scope drift, start from the canonical branch or a fresh sequencing branch.

## Per-TODO Checkpoint Matrix
| Sequencing Unit | Governing TODO | Must Pass Before Checkpoint | Checkpoint Gate Evidence | TODO State After Checkpoint | Next Exact Step |
| --- | --- | --- | --- | --- | --- |
| `U-01` | `<SEQ-01>` | `<todo guards + local evidence>` | `<command/output/report>` | `<Local-Implemented + Provisional|other>` | `<start next sequencing unit|await validation>` |

## Package-Stage Ledger
- **Current active sequencing unit:** `<U-01|none>`
- **Current package state:** `<planning|executing|checkpointed|blocked|awaiting-user-validation|replayed>`
- **Latest green checkpoint commit:** `<sha|none yet>`
- **Latest green checkpoint manifest:** `<path|none yet>`
- **Open blockers:** `<TODO ids / short reasons>`
- **Next exact step:** `<single exact next action>`

## Checkpoint Gate Contract
Record the gate that must pass after every completed sequencing unit before the next sequencing unit may start. If the sequencing branch is non-authoritative, this may be an explicit checkpoint prefix gate rather than the parity-complete broad local gate.

- **Gate name:** `<stage-full|other exact project-owned name>`
- **Gate status:** `<authoritative broad gate|non-authoritative prefix gate>`
- **Exact command:** `<command>`
- **Why this boundary is correct:** `<brief rationale or reference to project contract>`
- **If derived from `stage-full`:** `<name the exact pre-browser cutoff, e.g. stop before browser-stage-full so local-public web build + readonly + mutation remain deferred>`
- **What it must not claim:** `<n/a if authoritative | CI-equivalent/promotable/runtime freshness/web-build/readonly/mutation if prefix-only>`
- **Runtime target / build path:** `<what is actually exercised>`
- **Gate owner:** `<operator / workflow owner>`
- **Micro-batch rule:** `<if a micro-batch is admitted, every member TODO still runs its own local evidence first and none of them checkpoint before the shared broad gate passes>`

## Authoritative Broad Local Stage Gate Contract
- **Gate name:** `<stage-full|other exact project-owned name>`
- **Exact command:** `<command>`
- **When it is allowed / required:** `<always on authoritative branch | only after replay from non-authoritative sequencing lane>`
- **Why this is parity-complete:** `<brief rationale or reference to project contract>`
- **Runtime target / build path:** `<what is actually exercised>`
- **Mutation / readonly scope:** `<if relevant>`
- **Gate owner:** `<operator / workflow owner>`

## Canonical Replay And User Validation
- **User validation requested?:** `<yes|no>`
- **User validation status:** `<pending|passed|changes_requested|n/a>`
- **Accepted sequencing branch head:** `<sha|pending>`
- **Replay status:** `<pending|passed|blocked|n/a>`
- **Replay proof summary:** `<how the accepted sequence state reached the canonical branch>`
- **Post-replay validation outcome:** `<pending|passed|blocked|n/a>`

## Repository Checkpoint Tracking
Use this when the sequencing wave spans more than one runtime-facing repository.

| Repository | Branch | Latest Checkpoint SHA | Included In Current Checkpoint | Notes |
| --- | --- | --- | --- | --- |
| `<docker-root>` | `<sequence/<slug>>` | `<sha>` | `<yes|no>` | `<notes>` |
| `<flutter-app>` | `<sequence/<slug>>` | `<sha>` | `<yes|no>` | `<notes>` |
| `<laravel-app>` | `<sequence/<slug>>` | `<sha>` | `<yes|no>` | `<notes>` |

## Risk / Conflict Controls
- `<order risk, contract risk, runtime risk, or rollback risk>`
- `<how stage-full churn will be controlled>`
- `<how the operator will stop order drift before continuing>`

## Approval Request
- **Requested approval:** Reply `APROVADO` to authorize this sequencing plan, its checkpoint policy, and its recorded checkpoint granularity.
- **Execution authorized by approval:** `<exact first TODO and branch setup that will start>`
- **Execution not authorized by approval:** `<explicit exclusions>`
- **Autonomy rule:** once approved, sequencing advances between TODOs autonomously unless a blocker, order change, validation waiver, or explicit user decision is required.
