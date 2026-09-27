# TODO: Delphi Pre-Execution Agent Routing Guard

## Artifact Identity
- **Artifact type:** `tactical_execution_contract`

## Context
The current Delphi effort/model routing policy is clear enough as intent but not strict enough as an execution rule. In practice, the primary chat can still rationalize doing implementation or execution locally and only explain the deviation afterward. That breaks the intended model split: primary orchestrator for scope/integration, routine executor for writing and operational execution, and stronger reviewer for approval/review gates.

## Framing Source & Story Slice
- **Feature brief:** `direct-to-todo`
- **Primary story ID:** `n/a`
- **Why this is the right current slice:** This is one bounded Delphi self-maintenance slice: convert model/agent routing from prose guidance into a pre-execution deterministic contract and guard.
- **Direct-to-TODO rationale:** The user already established the intended operating policy and explicitly asked for a real implementation TODO before approval. A separate feature brief would duplicate the same contract discussion.

## Contract Boundary
- This TODO defines **WHAT** must be delivered so Delphi resolves required agent/model routing before execution, not after.
- The slice is architecture-corrective: it retires discretionary routing behavior and replaces it with fail-closed preflight logic plus explicit exception/waiver paths.
- The slice is bounded to Delphi self-maintenance surfaces in `delphi-ai/`. It must not mutate downstream project code or invent fake client capabilities that the active client cannot actually support.

## Delivery Status Canon (Required)
- **Current delivery stage:** `Pending`
- **Qualifiers:** `none`
- **Next exact step:** `repeat the architecture-opinion review with the completed bounded evidence package, then complete the remaining audit-derived independent review gates before deciding disposition`

## Active Work State (Required While TODO Remains In `active/`)
- **Work state:** `review`
- **Why this state now:** The bounded routing package was implemented in the historic P0 commits, but its closeout evidence predates the current deterministic delivery-gate contract. This TODO is being retrofitted only to revalidate and independently review that already-bounded package.
- **Exit condition:** The current-closeout validation and audit-derived review gates either confirm the historic package for completion or open a bounded follow-up/blocker.

## Scope
- [ ] Add a canonical agent-role routing contract that maps execution surfaces, role responsibilities, client capabilities, model defaults, and permitted exceptions.
- [ ] Add a deterministic pre-execution routing guard that classifies the next intended action and returns `go|delegate-required|review-required|waiver-required|blocked` before implementation/review/operational execution begins.
- [ ] Wire routing preflight into the relevant Delphi execution methods so implementation, review, and operational execution cannot start from stale or undeclared routing assumptions.
- [ ] Add TODO/plan evidence surfaces for routing decisions, actual selected role/model, and waiver evidence where client/runtime proof is unavailable.
- [ ] Generate or synchronize client-facing routing artifacts where the client supports them materially, with Claude as first-class generated support and Cline limited to declarative/hook-level enforcement that matches its actual product constraints.
- [ ] Add regression coverage and manifest/register updates so the routing contract remains mechanically testable and visible in Delphi tooling.

## Out of Scope
- [ ] Full runtime introspection of the exact active model for clients that do not expose trustworthy model telemetry.
- [ ] Automatic subagent spawning or auto-execution from the guard itself.
- [ ] Downstream Belluga project code or project-specific runtime contracts.
- [ ] Pretending that Cline IDE supports implementation subagents in the same way as Codex or Claude when it does not.

## Diff Expectation Contract
- **Contract status:** `required`
- **Policy:** `strict; the closeout-evidence diff is bounded to this TODO, while the historic implementation is proven by the immutable implementation evidence below`
- **User validation:** `required on deviation`
- **Comparison mode:** `working_tree`
- **Legacy-package rationale:** This TODO was implemented before the current diff-contract requirement existed. Its historic implementation began at `181c0bb` and was subsequently hardened by committed routing-policy changes through `cb3ac9a`. The live guard baseline is deliberately the last published head before this closeout-evidence retrofit, so it cannot silently absorb unrelated current work; the completion matrix names the immutable historic implementation commits separately.

### Repository Baselines
| Repository | Path | Baseline ref | Comparison mode |
| --- | --- | --- | --- |
| `delphi-ai` | `.` | `v0.6.2-rc@da4954f` | `working_tree` |

### Expected Changed Paths
| Repository | Path glob | Change types (`A|M|D|R|any`) | Reason |
| --- | --- | --- | --- |
| `delphi-ai` | `foundation_documentation/todos/active/delphi-pre-execution-agent-routing-guard.md` | `M` | Closeout-only contract, evidence, and disposition for the already-implemented P0 package. |
| `delphi-ai` | `tools/tests/agent_role_routing_guard_test.sh` | `M` | Necessary same-scope regression repair: the test must derive the one canonical routine-executor model from JSON rather than index an absent fallback model. |
| `delphi-ai` | `config/agent_role_routing.json` | `M` | Necessary same-scope D-07 remediation: remove the expired bootstrap exception from both executable implementation surfaces so the canonical authority rejects new use. |
| `delphi-ai` | `tools/agent_role_routing_guard.py` | `M` | Necessary same-scope fail-closed repair: reject underspecified model and effort declarations found by the required final review. |

### Not Expected Changed Paths
| Repository | Path glob | Change types (`A|M|D|R|any`) | Reason |
| --- | --- | --- | --- |
| `delphi-ai` | `workflows/**` | `any` | The D-07 remediation is fully expressed by canonical exception removal plus generic-guard regression coverage; a workflow rewrite would be unapproved scope expansion. |

### Diff Deviation Analysis
| Diff item | Classification (`scope deviation|necessary need|noise`) | Evidence / agent defense | Decision (`revert|clean noise|retain with renewed approval`) | User validation / renewed approval |
| --- | --- | --- | --- | --- |
| `delphi-ai:config/agent_role_routing.json M` | `necessary need` | `ARCH-P0-BOOTSTRAP-RETIREMENT-001` proves the P0 bootstrap exception remained executable; D-07 already requires it to expire at closeout. | `retain under existing P0 approval` | `No renewed approval needed: the historic user APROVADO on 2026-07-06 explicitly approved D-07 and its expiry; this change is its literal, bounded enforcement.` |
| `delphi-ai:tools/agent_role_routing_guard.py M` | `necessary need` | `P0-FINAL-ROUTING-MATCH-001` proves bidirectional prefix matching lets abbreviated model/effort declarations bypass the approved fail-closed guard. | `retain under existing P0 approval` | `No renewed approval needed: exact declared routing is a literal P0 deterministic-preflight and fail-closed requirement; no role, model family, client capability, or execution surface was added.` |

## Bounded But Elastic Guardrails
- **May stay inside this TODO:** local contract refinements, client-capability clarifications, guard/test additions, workflow/template wiring, and Claude/Cline/Codex compatibility surfaces that preserve the same routing objective.
- **Must update or split the TODO:** any expansion into downstream project behavior, broad promotion-flow redesign unrelated to routing, or generalized client orchestration beyond pre-execution routing enforcement.

## Definition of Done
- [ ] Delphi has one canonical routing contract for roles, surfaces, clients, capabilities, and exception policy.
- [ ] A deterministic pre-execution guard exists and is invoked by the execution boundary before code writing, file edits, implementation validation, monitoring, or formal review can proceed.
- [ ] Routine implementation and operational execution route to the routine executor role by default; formal review/approval/delivery review route to the stronger review role; the primary chat remains orchestration-first.
- [ ] Missing routing proof or unsupported client capability yields an explicit exception/waiver path instead of silent fallback in the primary agent.
- [ ] Claude-compatible agent artifacts are generated or synchronized from the canonical routing contract.
- [ ] Cline-compatible surfaces express the routing contract without claiming unsupported executor-subagent automation.
- [ ] Tool manifest, deterministic tooling register, mirrors, and affected workflow surfaces are updated and validated.

## Validation Steps
- [x] Rerun `python3 -m py_compile tools/agent_role_routing_guard.py tools/sync_claude_agent_routing.py tools/todo_authority_guard.py`.
- [x] Rerun `bash tools/tests/agent_role_routing_guard_test.sh`.
- [x] Rerun `bash tools/tests/todo_authority_guard_test.sh`.
- [x] Rerun `bash self_check.sh`.
- [x] Run `git diff --check`.
- [x] Run representative routing preflight commands for Codex, Claude Code, and Cline IDE mappings and record the expected outcome.

### Flow Evidence Planning Matrix
| Criterion / Flow | Why Flow-Impacting | Platform Parity | Required Runtime Lane | Mutation Lane Required? | Backend Real-Data Required? | Planned Evidence | Non-Applicability Rationale |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Delphi routing contract and pre-execution guard | `structure-only` | `n/a` | `n/a` | `no` | `no` | guard CLI fixtures, self-check, touched workflow/template review | No downstream product runtime or user-facing app flow changes are in scope. |

### Local CI-Equivalent Suite Matrix
| Repository / CI Surface | Why In Scope | Behavior / Scenario Covered | Fixture / Seed / Runtime Preconditions | Local CI-Equivalent Command | Required Before | Status | Evidence Artifact / Command | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `delphi-ai / routing guard compile` | Deterministic Python routing tooling. | Python guard and helper syntax is valid. | none | `python3 -m py_compile tools/agent_role_routing_guard.py tools/sync_claude_agent_routing.py tools/todo_authority_guard.py` | `Local-Implemented` | `passed` | `2026-09-27 routine-executor; exit 0; 61 ms` | Includes the post-review exact-match guard hardening. |
| `delphi-ai / routing guard regression` | Fail-closed routing behavior needs positive and negative fixtures. | Correct outcomes for implementation, review, monitoring, unsupported-capability, and waiver scenarios. | deterministic fixture inputs only | `bash tools/tests/agent_role_routing_guard_test.sh` | `Local-Implemented` | `passed` | `2026-09-27 routine-executor; exit 0; 2052 ms` | Derives the one current routine model from JSON; proves bootstrap retirement and rejects abbreviated model/effort declarations. |
| `delphi-ai / touched guard regressions` | The authority guard ingests routing evidence. | Existing approval/execution/orchestration guard behavior remains coherent after routing integration. | relevant fixture TODO/plan files | `bash tools/tests/todo_authority_guard_test.sh` | `Local-Implemented` | `passed` | `2026-09-27 routine-executor; exit 0; 1386 ms` | Includes the `Agent Routing Preflight` enforcement path. |
| `delphi-ai / mirror and instruction coherence` | Workflows, skills, manifests, and generated client artifacts must remain coherent. | Canonical and mirror surfaces remain synchronized and internally coherent. | none | `bash self_check.sh` | `Local-Implemented` | `passed` | `2026-09-27 routine-executor; exit 0; 4925 ms; 243 checks` | 243 checked, zero individual or coherence failures after the hardening. |
### Runtime / Rollout Notes
- No downstream runtime rollout is in scope.
- Client-facing artifact generation must remain declarative and must not depend on private runtime credentials or project-specific env.

## Completion Evidence Matrix
| Criterion ID | Source Section | Criterion | Evidence Type | Evidence Artifact / Command | Runtime Target | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `DOD-01` | `Definition of Done` | Delphi has one canonical routing contract for roles, surfaces, clients, capabilities, and exception policy. | `code|doc|review` | `config/agent_role_routing.json`; historic implementation `181c0bb`; fresh Sol architecture-opinion clean on 2026-09-27 | `n/a` | `passed` | The closeout review confirmed that JSON remains the sole policy authority. |
| `DOD-02` | `Definition of Done` | A deterministic pre-execution guard exists and is invoked by the execution boundary before code writing, file edits, implementation validation, monitoring, or formal review can proceed. | `code|test` | `tools/agent_role_routing_guard.py`; `workflows/docker/todo-execution-boundary-method.md`; guard regression exit 0 on 2026-09-27 | `n/a` | `passed` | The bounded code/workflow pair has current regression evidence, including blocked expired-bootstrap invocations. |
| `DOD-03` | `Definition of Done` | Routine implementation and operational execution route to the routine executor role by default; formal review/approval/delivery review route to the stronger review role; the primary chat remains orchestration-first. | `code|test` | `config/agent_role_routing.json`; Codex/Cline executor and Claude review representative preflights exit 0 on 2026-09-27 | `n/a` | `passed` | Current selections are resolved from JSON, not copied into policy prose. |
| `DOD-04` | `Definition of Done` | Missing routing proof or unsupported client capability yields an explicit exception/waiver path instead of silent fallback in the primary agent. | `code|test` | `tools/agent_role_routing_guard.py`; `bash tools/tests/agent_role_routing_guard_test.sh` exit 0 plus direct expired-bootstrap preflights exit 2 on 2026-09-27 | `n/a` | `passed` | Negative fixtures preserve fail-closed exception/waiver behavior; an expired exception cannot be revived by a waiver reference. |
| `DOD-05` | `Definition of Done` | Claude-compatible agent artifacts are generated or synchronized from the canonical routing contract. | `code|test` | `tools/sync_claude_agent_routing.py`; `.claude/agents/delphi-*.md`; `bash self_check.sh` exit 0 on 2026-09-27 | `n/a` | `passed` | Coherence check verifies generated support rather than a duplicate policy matrix. |
| `DOD-06` | `Definition of Done` | Cline-compatible surfaces express the routing contract without claiming unsupported executor-subagent automation. | `code|review` | `.cline/**`; `.clinerules/**`; fresh Sol architecture-opinion clean on 2026-09-27 | `n/a` | `passed` | Independent review found no fake client-capability claim or duplicate policy authority. |
| `DOD-07` | `Definition of Done` | Tool manifest, deterministic tooling register, mirrors, and affected workflow surfaces are updated and validated. | `test|doc` | `tools/manifest.md`; `skills/deterministic-tooling-register.md`; `bash self_check.sh` exit 0 on 2026-09-27 | `n/a` | `passed` | Current self-check: 243 checks, zero failures. |
| `VAL-01` | `Validation Steps` | Rerun `python3 -m py_compile tools/agent_role_routing_guard.py tools/sync_claude_agent_routing.py tools/todo_authority_guard.py`. | `test` | `2026-09-27 routine-executor; exit 0; 61 ms` | `local` | `passed` | Post-review exact-match hardening. |
| `VAL-02` | `Validation Steps` | Rerun `bash tools/tests/agent_role_routing_guard_test.sh`. | `test` | `2026-09-27 routine-executor; exit 0; 2052 ms` | `local` | `passed` | Includes abbreviated model/effort negative fixtures. |
| `VAL-03` | `Validation Steps` | Rerun `bash tools/tests/todo_authority_guard_test.sh`. | `test` | `2026-09-27 routine-executor; exit 0; 1386 ms` | `local` | `passed` | Existing routing-evidence integration remains coherent. |
| `VAL-04` | `Validation Steps` | Rerun `bash self_check.sh`. | `test` | `2026-09-27 routine-executor; exit 0; 4925 ms; 243 checks` | `local` | `passed` | Zero individual or coherence failures. |
| `VAL-05` | `Validation Steps` | Run `git diff --check`. | `test` | `2026-09-27 routine-executor; exit 0; 17 ms` | `local` | `passed` | No whitespace error after exact-match hardening. |
| `VAL-06` | `Validation Steps` | Run representative routing preflight commands for Codex, Claude Code, and Cline IDE mappings and record the expected outcome. | `test` | `2026-09-27 routine-executor; Codex implementation-validation go (47 ms), Claude formal-review go (47 ms), Cline implementation go (50 ms)` | `local` | `passed` | All three current client examples derive their expected selections from the canonical JSON. |

## Profile Scope & Handoffs
- **Primary execution profile:** `operational-coder`
- **Active technical scope:** `delphi-self-maintenance`
- **Expected supporting profiles:** `strategic-cto|assurance-tester-quality`
- **Scope-check command:** `n/a - Delphi self-maintenance slice`

### Handoff Log
| From Profile | To Profile | Why the Handoff Exists | Touched Surfaces | Status / Evidence |
| --- | --- | --- | --- | --- |
| `strategic-cto` | `operational-coder` | Contract framing and approval are complete; the session is now executing the approved routing package. | `main_instructions.md`, `workflows/docker/**`, `tools/**`, `templates/**`, `.claude/**`, `.cline/**`, `.clinerules/**` | `completed - user replied APROVADO on 2026-07-06` |
| `operational-coder` | `strategic-cto` | Canonical wording decisions remain visible while instruction/workflow language is updated. | `main_instructions.md`, `workflows/docker/**`, `.claude/**`, `.clinerules/**` | `active - bounded support only` |

## Complexity
- **Level (`small|medium|big`):** `big`
- **Checkpoint policy:** `section-by-section`
- **Why this level:** The slice changes core execution policy, adds a new deterministic guard, touches multiple canonical workflows/templates/tools, and introduces client-specific compatibility surfaces with cross-client behavior implications.

## Canonical Module Anchors
- **Primary module doc:** `workflows/docker/effort-selection-method.md`
- **Secondary module docs:**
  - `main_instructions.md`
  - `workflows/docker/todo-execution-boundary-method.md`
  - `workflows/docker/subagent-worktree-reconciliation-method.md`
  - `workflows/docker/todo-approval-gates-method.md`
  - `templates/todo_template.md`
  - `skills/deterministic-tooling-register.md`
  - `tools/manifest.md`
- **Planned decision promotion targets (module sections):**
  - pre-execution routing policy
  - fail-closed exception handling
  - client capability mapping
- **Module decision consolidation targets (required):**
  - `main_instructions.md`
  - `workflows/docker/effort-selection-method.md`
  - `workflows/docker/todo-execution-boundary-method.md`
  - `workflows/docker/subagent-worktree-reconciliation-method.md`
  - `templates/todo_template.md`
  - `skills/deterministic-tooling-register.md`
  - `tools/manifest.md`

## Decision Pending (Resolve Before Freeze)
- [x] `D-01` Approve a new canonical routing contract plus deterministic pre-execution guard instead of leaving routing as prose guidance plus advisory helper output.
- [x] `D-02` Approve fail-closed declaration/waiver behavior when the client cannot prove the exact active model or selected subagent role at runtime.
- [x] `D-03` Approve first-slice client coverage as: Claude generated artifacts now, Codex declarative routing now, and Cline declarative/hook-level enforcement only, without fake executor-subagent automation.

## Decisions (Resolved Before Freeze)
- [x] `D-04` Prefer a dedicated `agent_role_routing_guard.py` and canonical routing config over overloading `effort_selection_advisor.py` into a blocker with mixed responsibilities.
- [x] `D-05` Treat routine code writing, file-edit execution, and implementation-side validation as the same routing family unless an explicit workflow exception allows orchestrator-local reconciliation glue.
- [x] `D-06` Keep review-only/no-context routing stateless by default and keep monitoring deterministic first or ephemeral bounded summarization only.
- [x] `D-07` This TODO carried a one-time bootstrap exception only while the first routing guard was being built. It is not available to closeout validation or any future TODO and will be recorded as retired in the completion disposition.

## Module Decision Baseline Snapshot
| Module Decision Ref | Current Module Decision | Planned Handling | Evidence |
| --- | --- | --- | --- |
| `main_instructions.md#effort-model-goal-budget-discipline` | Routing policy is expressed as default/prefer language and leaves room for discretionary local execution. | `Supersede (Intentional)` | `main_instructions.md` |
| `workflows/docker/effort-selection-method.md#model-routing-defaults` | The matrix recommends executor/reviewer models and states, but does not fail closed before execution. | `Supersede (Intentional)` | `workflows/docker/effort-selection-method.md` |
| `workflows/docker/todo-execution-boundary-method.md#procedure` | Execution boundary requires authority/rule ingestion but not explicit routing preflight. | `Supersede (Intentional)` | `workflows/docker/todo-execution-boundary-method.md` |

## Decision Baseline (Frozen Before Implementation)
- [x] `D-01` The next intended action must resolve routing before execution begins.
- [x] `D-02` Primary chat/orchestrator does not perform ordinary implementation or implementation-side execution when delegated routing is available.
- [x] `D-03` Unsupported runtime proof becomes explicit waiver/exception handling, not silent fallback.
- [x] `D-04` The current TODO may use a bounded bootstrap exception only while building the first routing guard itself; future implementation slices must rely on the landed guard/evidence path.

## Architecture Change Governance
- **Applicability (`required|not_needed`):** `required`
- **Why this applies:** This TODO corrects a recurring process deviation: the primary agent can still absorb implementation/execution despite an approved delegated routing policy.
- **Deviation / debt being retired:** prose-only routing that allows post-hoc rationalization instead of pre-execution enforcement
- **Target steady-state after closeout:** deterministic preflight resolves required role/model/state before implementation, execution, monitoring, or review begins
- **Temporary exceptions allowed:** only bounded orchestration-local reconciliation, merge-conflict resolution, or minimal integration glue explicitly authorized by workflow and recorded in routing evidence. The P0 bootstrap exception is retired at closeout and cannot authorize new work.
- **Cutover / removal condition:** the new guard, routing ledger/evidence, and workflow/template integrations are in place and revalidated; the old discretionary fallback behavior and P0 bootstrap exception are prohibited

### Patterns To Enforce
| Pattern / Decision | Source / ID | Scope | Why It Must Hold After Cutover |
| --- | --- | --- | --- |
| pre-execution routing resolution | `this TODO / D-01` | all delegated implementation/review/monitoring surfaces | Routing must be decided before the action, not explained afterward. |
| orchestration-only primary chat | `workflows/docker/subagent-worktree-reconciliation-method.md` | primary chat and orchestration flows | The orchestrator must retain integration ownership without becoming default implementation owner. |
| explicit waiver path | `this TODO / D-02` | clients without runtime-proof capability | Missing proof must stay visible and reviewable instead of disappearing into chat memory. |

### Prohibited Anti-Patterns
| Anti-Pattern / Wrong Path | Detection Signal | Why It Is Forbidden After Cutover | Exception Policy |
| --- | --- | --- | --- |
| primary chat writes code before routing resolution | execution began without routing preflight evidence | It reintroduces discretionary routing and token/cost drift. | none |
| exploratory subagent use presented as implementation delegation | routing ledger shows exploration only while primary chat still implemented | It creates false compliance with the routing policy. | none |
| fake client support claims | client artifact or workflow claims unsupported subagent/model behavior | It makes the deterministic policy misleading and non-enforceable. | none |

### Architecture Protection Harness
| Harness Type | Surface | Command / Rule / Artifact | Regression It Must Catch | Adoption Timing | Evidence Plan / Follow-up |
| --- | --- | --- | --- | --- | --- |
| `guard` | `tools/agent_role_routing_guard.py` | `python3 tools/agent_role_routing_guard.py ...` | missing or wrong routing before execution | `implement-in-this-todo` | new tool + fixtures |
| `workflow` | `workflows/docker/todo-execution-boundary-method.md` | routing preflight step before implementation | implementation starts without preflight | `implement-in-this-todo` | workflow diff + self-check |
| `template` | `templates/todo_template.md` | routing ledger / evidence section | no durable routing proof in TODO/plan artifacts | `implement-in-this-todo` | template diff + self-check |
| `test` | `tools/tests/agent_role_routing_guard_test.sh` | regression suite | false `go`, false waiver, or unsupported-client drift | `implement-in-this-todo` | new regression suite |
| `hook/reminder` | `.clinerules/hooks/session_start` or equivalent declarative client surface | client-start reminder where supported | forgetting to resolve routing at session start | `implement-in-this-todo` | limited to reminder/enforcement surfaces the client truly supports |

## Architecture Review Gates
- **Architecture decision review:** `required`
- **Decision-review derivation:** `python3 tools/audit_escalation_guard.py --todo foundation_documentation/todos/active/delphi-pre-execution-agent-routing-guard.md`
- **Decision review lifecycle:** `historic diagnosis closed; recovery review before disposition, without reopening approved scope`
- **Decision review kind:** `architecture_opinion`
- **Decision review package:** `bounded-summary: P0 contract, historic implementation range, current canonical routing JSON, guard/workflow/test evidence`
- **Decision review status:** `findings_integrated`
- **Decision review evidence / resolution:** `Fresh no-context Sol architecture-opinion on 2026-09-27 first found ARCH-P0-BOOTSTRAP-RETIREMENT-001; the same-P0 JSON/test remediation was re-reviewed clean. Final assessment: no P0 architecture release-blocker; performance acceptable, elegance/structural soundness/operational fit strong positive. Raw derived packets remain transient outside Git.`
- **Architecture adherence review:** `required`
- **Adherence-review derivation:** `same audit guard result as the decision review`
- **Adherence review lifecycle:** `after current-closeout validation and before Completed`
- **Adherence review kind:** `architecture_adherence`
- **Adherence review package:** `bounded-summary: frozen P0 contract, current canonical routing JSON, guard/workflow/test evidence, and validation evidence`
- **Adherence review status:** `no_material_findings`
- **Adherence review evidence / resolution:** `Fresh no-context Sol architecture-adherence review on 2026-09-27 returned approved_no_material_findings: bounded P0 closeout adheres to canonical authority, fail-closed retirement, capability honesty, and single-writer boundaries. Raw derived packets remain transient outside Git.`
- **No-go handling:** `an unresolved approval-breaking divergence returns to the bounded P0 remediation loop; it does not expand into the later P1/P2 contracts.`
## Gate: Review Baseline Freeze
- **Gate decision:** `required`
- **Why this decision:** The historic implementation predates the current review baseline protocol. A narrowly scoped, committed and pushed closeout-evidence baseline is required before the recovery review loop so it cannot absorb P1/P2 work.
- **Trigger stage:** `before the first recovery review or closeout guard run`
- **Baseline branch:** `v0.6.2-rc`
- **Baseline commit:** `9334af66c7d837292d9307924f6f23c1d6e62a68`
- **Baseline push reference:** `origin/v0.6.2-rc`
- **Gate status:** `no_material_findings`
- **Findings summary:** `the 2026-07-06 approval remains the historic implementation authority; 9334af6 freezes the bounded D-07 remediation, exact-declaration hardening, and compatibility-boundary fixtures and is pushed to origin.`
- **Evidence / reference:** `historic approval: user APROVADO on 2026-07-06; current-session responsibility/closeout direction confirmed by user; closeout baseline commit/push 9334af6 on 2026-09-27`
- **Waiver authority / reference (required if waived):** `n/a`

## Gate: Review Scope Drift
- **Gate decision:** `required`
- **Why this decision:** The historic approval is not reopened, but the closeout retrofit must prove that it did not change scope, exceptions, or client coverage before disposition.
- **Trigger stage:** `after recovery review convergence and before the closeout disposition`
- **Baseline source:** `Review Baseline Freeze -> Baseline commit`
- **Guard command:** `python3 delphi-ai/tools/review_scope_drift_guard.py --todo foundation_documentation/todos/active/delphi-pre-execution-agent-routing-guard.md`
- **Gate status:** `no_material_findings`
- **Findings summary:** `9334af6 is the refreshed pushed review baseline; the only successor edit records this baseline and does not alter a material scope-governing section.`
- **Evidence / reference:** `2026-09-27: python3 tools/review_scope_drift_guard.py --todo foundation_documentation/todos/active/delphi-pre-execution-agent-routing-guard.md`
- **Waiver authority / reference (required if waived):** `n/a`

## Questions To Close
- [x] Claude artifact generation stays in the first slice and is implemented through `tools/sync_claude_agent_routing.py` plus generated `.claude/agents/*.md`.
- [x] Routing evidence uses a compact `Agent Routing Preflight` section inside TODOs plus `Worker Routing Contracts` inside orchestration plans.

## Assumptions Preview
| Assumption ID | Assumption | Evidence | If False | Confidence | Handling |
| --- | --- | --- | --- | --- | --- |
| `A-01` | A deterministic preflight can enforce correct routing by declared client/capability plus durable evidence even when runtime model introspection is unavailable. | prior Delphi guards already validate declared process evidence rather than hidden chat state | the slice would need runtime-specific proof adapters or a narrower first scope | `Medium` | `Promote to Decision` |
| `A-02` | Claude-compatible agent artifacts can be generated from a canonical contract without introducing project-specific truth. | `tools/sync_claude_agent_routing.py` emits the projection from `config/agent_role_routing.json`; `.claude/agents/delphi-routine-executor.md` carries the generated-source header | Claude support should be reduced to documented mapping only in this slice | `Medium` | `Keep as Assumption` |
| `A-03` | Cline IDE should stay declarative/hook-driven for this slice because its subagent model does not match the desired implementation executor shape. | prior design analysis and client capability discussion in this session | first-slice scope may overclaim unsupported automation | `High` | `Promote to Decision` |

## Execution Plan
### Touched Surfaces
- `main_instructions.md`
- `workflows/docker/effort-selection-method.md`
- `workflows/docker/todo-execution-boundary-method.md`
- `workflows/docker/subagent-worktree-reconciliation-method.md`
- `workflows/docker/todo-approval-gates-method.md`
- `templates/todo_template.md`
- `tools/manifest.md`
- `skills/deterministic-tooling-register.md`
- `tools/agent_role_routing_guard.py`
- `tools/tests/agent_role_routing_guard_test.sh`
- `config/**` for canonical routing contract if created
- `.claude/**`, `.cline/**`, `.clinerules/**` compatibility surfaces as required

### Ordered Steps
1. Create the canonical routing contract for roles, surfaces, clients, capabilities, state policy, and exception policy.
2. Implement a dedicated deterministic routing guard that reads the contract and evaluates the next intended action before execution.
3. Wire the guard into the canonical execution boundary and orchestration/routing workflows so preflight is mandatory before implementation or formal review begins.
4. Add durable routing evidence surfaces to TODO/template/plan artifacts and update any touched deterministic guards that must validate the new evidence.
5. Generate or update Claude/Cline/Codex-facing compatibility surfaces from the same canonical contract without overstating unsupported client capabilities.
6. Add regression tests, refresh manifests/registers/mirrors, and run self-maintenance validation.

### Test Strategy
- **Strategy:** `test-after`
- **Why:** This is deterministic tooling and workflow/template wiring; the most efficient path is to implement the guard and then lock behavior down with CLI fixtures and touched-guard regression tests.
- **Fail-first target(s) (when required):** `agent_role_routing_guard_test` should include explicit no-go / waiver-required fixture cases before final closeout if the implementation path risks permissive defaults.

### Pre-APROVADO RED Evidence Capture
- **Decision (`required|recommended|not_needed|waived`):** `not_needed`
- **Why now:** This is not a bugfix/regression slice whose uncertainty would be reduced by symptom-first test capture.
- **Target symptom:** `n/a`
- **Allowed surfaces:** `n/a`
- **Forbidden surfaces reaffirmed:** `production code|runtime/config/deploy|canonical project docs outside TODO authoring`
- **Planned command / target:** `n/a`
- **Status (`not_run|running|red_reproduced|red_not_reproduced|blocked|waived`):** `waived`
- **Findings summary:** `n/a`

## Plan Review Gate
### Review Sections
- [x] Architecture
- [x] Code Quality
- [x] Tests
- [x] Performance
- [x] Security
- [x] Elegance
- [x] Structural Soundness

### Issue Cards
- **Issue ID:** `ARCH-01`
  - **Severity:** `high`
  - **Evidence:** `workflows/docker/effort-selection-method.md`; `main_instructions.md`
  - **Why it matters now:** If routing remains advisory, the same policy drift will recur even after we add more prose.
  - **Option A (Recommended):** create a dedicated canonical routing contract plus deterministic pre-execution guard, and fail closed on missing routing proof
    - **Effort:** `medium`
    - **Risk:** `medium`
    - **Blast radius:** `cross-module`
    - **Maintenance burden:** `medium`
    - **Performance impact:** `neutral`
    - **Elegance impact:** `improves`
    - **Structural soundness impact:** `improves`
  - **Option B (Alternative):** strengthen prose only inside `main_instructions.md` and `effort-selection-method.md`
    - **Effort:** `low`
    - **Risk:** `high`
    - **Blast radius:** `cross-module`
    - **Maintenance burden:** `high`
    - **Performance impact:** `neutral`
    - **Elegance impact:** `regresses`
    - **Structural soundness impact:** `regresses`
  - **Option C (Do Nothing):** keep current advisory behavior
    - **Effort:** `low`
    - **Risk:** `high`
    - **Blast radius:** `cross-stack`
    - **Maintenance burden:** `high`
    - **Performance impact:** `neutral`
    - **Elegance impact:** `regresses`
    - **Structural soundness impact:** `regresses`
  - **Recommendation:** `Option A` because the failure mode is operational non-adherence, not lack of prose.
- **Issue ID:** `SCOPE-01`
  - **Severity:** `medium`
  - **Evidence:** prior client analysis in this session
  - **Why it matters now:** Over-scoping first-slice client automation will either fake unsupported behavior or delay the core guard.
  - **Option A (Recommended):** implement canonical contract + guard + Claude generation now, and keep Cline enforcement declarative/hook-level only
    - **Effort:** `medium`
    - **Risk:** `low`
    - **Blast radius:** `cross-module`
    - **Maintenance burden:** `medium`
    - **Performance impact:** `neutral`
    - **Elegance impact:** `improves`
    - **Structural soundness impact:** `improves`
  - **Option B (Alternative):** try to automate equal executor behavior across Codex, Claude, and Cline in the same slice
    - **Effort:** `high`
    - **Risk:** `high`
    - **Blast radius:** `cross-stack`
    - **Maintenance burden:** `high`
    - **Performance impact:** `neutral`
    - **Elegance impact:** `regresses`
    - **Structural soundness impact:** `regresses`
  - **Option C (Do Nothing):** keep all clients at prose-only mapping
    - **Effort:** `low`
    - **Risk:** `medium`
    - **Blast radius:** `cross-stack`
    - **Maintenance burden:** `high`
    - **Performance impact:** `neutral`
    - **Elegance impact:** `neutral`
    - **Structural soundness impact:** `regresses`
  - **Recommendation:** `Option A` because it keeps the first slice bounded while delivering real enforcement where the client support is strongest.

### Failure Modes & Edge Cases
- [ ] A client cannot expose trustworthy runtime proof of selected model/role; the guard must return `waiver-required` instead of pretending certainty.
- [ ] Primary chat tries to read the routing contract but still performs `apply_patch` or implementation validation without durable routing evidence.
- [ ] A workflow-authorized orchestration exception is broad enough to become hidden implementation ownership unless the TODO/plan records it explicitly.

### Residual Unknowns / Risks
- [ ] Exact artifact shape for routing evidence in TODOs vs orchestration plans still needs one explicit decision.
- [ ] Claude artifact generation may need a narrow follow-up if the canonical config cannot map cleanly onto current `.claude` agent surfaces.

## Additional Architectural Opinions
- **Needed:** `no`
- **Why ambiguity remains:** `n/a`
- **Opinion count:** `0`
- **Package mode:** `n/a`
- **Subagent mandate (when available):** `no`
- **Required lenses:** `n/a`

## Audit Trigger Matrix
- **Canonical method:** `wf-docker-audit-escalation-method`
- **Guard command:** `python3 delphi-ai/tools/audit_escalation_guard.py --todo foundation_documentation/todos/active/delphi-pre-execution-agent-routing-guard.md`
- **Latest TEACH evidence / artifact:** `not_run`

| Trigger | Value | Notes |
| --- | --- | --- |
| `complexity` | `big` | Cross-cutting execution-policy slice. |
| `blast_radius` | `cross-stack` | Routing policy applies across Delphi execution surfaces. |
| `behavioral_change_or_bugfix` | `yes` | This is a behavior-defining process correction. |
| `changes_public_contract` | `no` | No external API/schema contract is in scope. |
| `touches_auth_or_tenant` | `no` | Not an auth/tenant slice. |
| `touches_runtime_or_infra` | `no` | No downstream runtime/infra behavior changes are in scope. |
| `touches_tests` | `yes` | New routing regression coverage is required. |
| `critical_user_journey` | `no` | No product user journey is touched. |
| `release_or_promotion_critical` | `yes` | Routing affects approval/review/delivery discipline across future work. |
| `high_severity_plan_review_issue` | `yes` | `ARCH-01` is high severity. |
| `explicit_three_lane_request` | `no` | Not explicitly requested yet. |

## Independent No-Context Critique Gate
- **Critique decision:** `required`
- **Why this decision:** Big cross-stack process change with a high-severity architecture issue.
- **Impact signals in scope:** `cross-module blast radius|intentional module supersede|high-severity issue card`
- **Package mode:** `bounded-summary`
- **Package minimum contents:** `frozen baseline|approved scope boundary|assumptions preview|execution plan summary|issue cards|residual risks`
- **Critique isolation mode:** `fresh no-context auxiliary reviewer`
- **Subagent mandate (when available):** `yes`
- **Canonical multi-lane audit protocol (when required):** `n/a unless audit floor escalates further`
- **Audit session / round evidence (when protocol used):** `n/a`
- **Critique lenses:** `correctness|performance|elegance|structural-soundness|risk`
- **Critique status:** `no_material_findings`
- **Findings summary:** `Fresh no-context Sol critique found no P0 defect, regression, hidden scope expansion, or contradiction with the frozen decisions; it recommends accepting the recovery closeout without further remediation.`
- **Evidence / reference:** `2026-09-27 structured critique/merge: performance, elegance, and structural soundness strong_positive; operational fit acceptable. Raw packets remain transient outside Git.`
- **Waiver authority / reference (required if waived):** `n/a`

## Gate: Assumption Code Coherence
- **Gate decision:** `required`
- **Why this decision:** The plan depends on real client/tooling constraints and on the current code already exposing the intended insertion points.
- **Trigger stage:** `after critique convergence and before APROVADO`
- **Guard scope:** `A-01,A-02,A-03`
- **Guard command:** `python3 delphi-ai/tools/assumption_code_coherence_guard.py --todo foundation_documentation/todos/active/delphi-pre-execution-agent-routing-guard.md`
- **Gate status:** `no_material_findings`
- **Findings summary:** `A-02 now cites its generator, canonical JSON input, and generated Claude artifact; live assumption has a concrete code anchor.`
- **Evidence / reference:** `2026-09-27: python3 tools/assumption_code_coherence_guard.py --todo foundation_documentation/todos/active/delphi-pre-execution-agent-routing-guard.md`
- **Waiver authority / reference (required if waived):** `n/a`

## Approval
- **Approved by:** `user on 2026-07-06 with explicit "APROVADO"`
- **Approval scope:** `implement the bounded delphi-ai routing package: canonical routing contract, deterministic pre-execution guard, workflow/template/guard integrations, Codex declarative routing, Claude agent artifacts, Cline declarative/hook-level support, and focused regression validation`
- **Execution not authorized by approval:** `downstream Belluga project code, fake Cline executor-subagent automation, automatic guard-triggered execution, or broader orchestration redesign unrelated to pre-execution routing`
- **Renewed approval required when:** `scope, client coverage, exception policy, or validation obligations change materially`

## Rules Acknowledgement / Ingestion
| Source | Why It Applies Now | Must Preserve | Must Avoid | Execution Impact |
| --- | --- | --- | --- | --- |
| `rules/core/todo-driven-execution-model-decision.md` | This slice is implementing a new hard gate inside the TODO-driven execution model itself. | TODO-first authority, explicit approval, and post-approval rule ingestion | implementation from chat memory alone | keep the new routing evidence inside the governing TODO/workflow structure |
| `workflows/docker/todo-driven-execution-method.md` | The new routing gate must fit the canonical TODO phase machine without inventing a parallel execution lane. | approval -> rule-ingestion -> authority guard -> execution ordering | side-channel enforcement outside the TODO state machine | wire the guard into the existing orchestrator/execution flow |
| `workflows/docker/effort-selection-method.md` | Canonical routing policy is being hardened here. | role separation and model-routing intent | advisory-only ambiguity | translate defaults into preflight enforcement |
| `skills/wf-docker-effort-selection-method/SKILL.md` | The concise skill entry must keep matching the canonical workflow after the routing hardening. | mirror-level clarity about orchestrator/executor/reviewer roles | letting the skill drift from the workflow | refresh the skill summary and downstream mirrors if the workflow contract changes |
| `workflows/docker/todo-execution-boundary-method.md` | The guard must run before implementation starts. | no implementation before boundary gates | file edits before routing resolution | add pre-execution routing step |
| `workflows/docker/todo-approval-gates-method.md` | Approval/review surfaces must continue to route to the stronger review lane. | approval remains a review-focused governed surface | mixing review-only work into routine execution routing | record the review-routing requirement in the canonical contract |
| `workflows/docker/subagent-worktree-reconciliation-method.md` | Orchestrator vs worker ownership already exists here and must stay aligned. | orchestrator is not TODO-slice implementation owner | broad orchestrator exceptions | reuse the same ownership boundary in the routing contract |
| `main_instructions.md` | The top-level Delphi identity/instruction layer must describe the new fail-closed routing rule consistently. | model budget discipline and orchestration-first delivery behavior | contradictory higher-level wording that weakens the guard | update the primary instruction surface alongside the workflow |
| `templates/todo_template.md` | Routing evidence must live in durable execution artifacts. | TODO-native evidence | chat-only routing memory | add a routing ledger or equivalent evidence section |

## Agent Routing Preflight
- **Client surface:** `codex`
- **Current governed action:** `formal-review`
- **Selected role:** `formal-reviewer`
- **Selected model:** `gpt-5.6-sol`
- **Selected effort:** `xhigh`
- **Proof mode:** `declared`
- **Exception reason:** `n/a`
- **Subagent / delegation authorization:** `explicit human reference: user assigned the orchestrator responsibility for P0 -> P1 -> P1.5 sequencing in this session`
- **Execution topology:** `primary-checkout-single-writer`
- **Worktree / auxiliary-checkout authorization:** `not-authorized`
- **Worktree authorization evidence:** `n/a`
- **Writer scheduling policy:** `single-writer-serialized`
- **Guard outcome:** `go`
- **Waiver / exception reference:** `n/a; formal-review tuple verified 2026-09-27 with agent_role_routing_guard.py; prior implementation-validation evidence is recorded in the Completion Evidence Matrix`

## Decision Adherence Validation
| Decision ID | Status (`Adherent`/`Exception`) | Evidence | Notes |
| --- | --- | --- |
| `D-01` | `Adherent` | `config/agent_role_routing.json`; `tools/agent_role_routing_guard.py`; current review pending | Canonical routing resolution remains JSON-driven. |
| `D-02` | `Adherent` | `tools/agent_role_routing_guard.py`; regression rerun pending | Missing proof uses explicit failure/waiver outcomes rather than hidden fallback. |
| `D-03` | `Adherent` | `.claude/**`, `.cline/**`, `.clinerules/**`; `bash self_check.sh` pending | Client-specific support stays within declared capability boundaries. |
| `D-04` | `Adherent` | `tools/agent_role_routing_guard.py` | Dedicated routing guard remains separate from effort advice. |
| `D-05` | `Adherent` | current `implementation-validation` preflight | Routine writing/validation stays in the executor routing family. |
| `D-06` | `Adherent` | current config and review workflow evidence pending | Review and monitoring remain separately routed. |
| `D-07` | `Adherent` | `config/agent_role_routing.json`; `tools/tests/agent_role_routing_guard_test.sh` | The bootstrap exception is absent from both executable implementation surfaces; current negative fixtures prove new use is blocked. |

## Module Decision Consistency Validation
| Module Decision Ref | Planned Handling | Delivery Status (`Preserved|Superseded (Approved)|Regression`) | Evidence | Notes |
| --- | --- | --- | --- |
| `main_instructions.md#effort-model-goal-budget-discipline` | `Supersede (Intentional)` | `Superseded (Approved)` | historic P0 implementation; current review pending | Routing moved from advisory prose to canonical deterministic preflight. |
| `workflows/docker/effort-selection-method.md#model-routing-defaults` | `Supersede (Intentional)` | `Superseded (Approved)` | historic P0 implementation; current review pending | Default role/model routing is now guard-backed. |
| `workflows/docker/todo-execution-boundary-method.md#procedure` | `Supersede (Intentional)` | `Superseded (Approved)` | historic P0 implementation; current review pending | Pre-execution routing is part of the execution boundary. |

## Pipeline/Copilot P1/P2 Preflight
| Reviewer Surface / Package | Review Focus | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| `historic P0 routing package + current closeout evidence` | `CI/Copilot-style P1/P2: canonical-source bypass, wrong role/model default, unsupported client-capability claim, missing regression coverage` | `planned` | `fresh strongest-review package after baseline freeze` | `none yet` | `Do not claim delivery until a fresh independent reviewer records the result.` |

## Rule-Spirit Anti-Pattern Hunt
| Rule / Principle Surface | Bypass or Anti-Pattern Search Lens | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| `Architecture Simplification First` | `duplicated routing matrix, generic orchestration framework, policy moved from JSON into prose` | `planned` | `fresh architecture/adherence review` | `none yet` | `The JSON must remain the authority; client artifacts are derived only.` |
| `single-writer and execution boundary` | `primary-chat implementation/validation bypass, fake delegation, worktree inference` | `planned` | `current preflight plus fresh review` | `none yet` | `Current closeout validation is routed to routine-executor in the primary checkout.` |
| `client capability integrity` | `Claude/Cline claims that exceed actual product support` | `planned` | `self_check plus fresh review` | `none yet` | `Unsupported automation must fail closed or stay declarative.` |

## Promotion Finding Routing Ledger
| Finding ID | Severity | Classification | Routing Decision | Same TODO / Split Rationale | Status | Approval / Follow-up Reference |
| --- | --- | --- | --- | --- | --- | --- |
| `ARCH-P0-BOOTSTRAP-RETIREMENT-001` | `high` | `release-blocker` | `same-todo` | `The expired bootstrap exception is a literal P0 D-07/cutover obligation, not a new behavior or P1/P2 concern.` | `fixed` | `Fresh Sol architecture-opinion re-review on 2026-09-27 found no remaining P0 blocker after JSON exception removal and two negative fixtures; raw packets are transient outside Git.` |
| `P0-FINAL-ROUTING-MATCH-001` | `high` | `release-blocker` | `same-todo` | `Abbreviated model/effort acceptance defeats P0's literal fail-closed preflight objective; the bounded guard/test repair adds no new selection policy.` | `integrated_pending_re-review` | `Fresh Sol final review on 2026-09-27; routine-executor replaced bidirectional prefix matching with exact aliases plus the narrow existing provider/alias/version form and added negative fixtures. Current review/validation rerun remains required.` |
| `P0-EXACT-MATCH-TEST-001` | `medium` | `release-blocker` | `same-todo` | `The narrow provider/alias/numeric-version compatibility form is part of the repaired P0 guard; its malformed boundary must be regression-protected before closeout.` | `integrated_pending_re-audit` | `Fresh Terra test-quality audit on 2026-09-27 found missing malformed-version negatives. Routine-executor added contract-derived `claude-<alias>-x` and `claude-<alias>-5-beta` fixtures requiring `MODEL-MISMATCH`; fresh audit remains required.` |
| `P0-EXACT-MATCH-TEST-002` | `medium` | `release-blocker` | `same-todo` | `The same narrow matcher supports numeric multipart versions used by the current Claude routine configuration; a contract-derived positive fixture is needed to prevent an over-tightening regression.` | `integrated_pending_re-audit` | `Fresh Terra re-audit on 2026-09-27 found the missing `claude-sonnet-4-6` positive. Routine-executor added a JSON-derived Claude routine fixture; fresh audit remains required.` |
| `P0-FINAL-PCV-CLOSEOUT-001` | `high` | `release-blocker` | `blocked-user-decision` | `The immutable pcv-1 schema cannot truthfully encode P0's absent runtime surfaces with its current positive reason-code registry; a versioned policy evolution or an exceptional human closure waiver is outside the approved P0 routing scope.` | `blocked` | `Fresh Sol final review on 2026-09-27. Do not silently reinterpret the rows or treat a lane waiver as schema repair; await user decision on separately approved PCV evolution versus explicit P0 closure waiver.` |

## TODO Closeout Disposition
- **Disposition:** `keep-active`
- **Disposition reason:** `The historic P0 package needs current deterministic validation, review, and evidence before it can be completed; no new implementation scope is authorized by this recovery.`
- **Post-commit/push status:** `pending`
- **Next path/status action:** `freeze and push the closeout-evidence baseline; then run the executor validation and independent review gates.`

## Security Risk Assessment
- **Risk level:** `low`
- **Why this risk level:** `The P0 guard affects developer execution governance but does not add a public endpoint, credential flow, or downstream runtime behavior.`
- **Attack surface in scope:** `local agent/client instruction and deterministic CLI inputs only`
- **Attack simulation decision:** `not_needed`
- **Review evidence:** `audit escalation result 2026-09-27: security_review=not_needed (SEC-NOT-TRIGGERED)`
- **Residual security risk:** `A malformed local routing configuration could block or misroute work; regression fixtures and independent review are the bounded mitigations.`

## Performance & Concurrency Risk Assessment
- **Policy schema version:** `pcv-1`
- **Global sensitivity level:** `low`
- **Why this level:** `This is Delphi self-maintenance without downstream request, state, async UI, database, queue, or runtime-load behavior.`
- **Current delivery stage at review time:** `Pending`

| Lane ID | Lane | Trigger Result | Trigger Severity | Trigger Reason Code | Gate Deadline | Minimum Evidence Rule | State | Residual Risk | Uncertainty Reason Code |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `EPS` | `endpoint-performance-scrutiny` | `not_needed` | `low` | `EPS-DATA-PATH-CHANGED` | `before_local_implemented` | `n/a` | `not_applicable` | `none` | `none` |
| `FRC` | `frontend-race-condition-validation` | `not_needed` | `low` | `FRC-LIFECYCLE-ASYNC-EFFECT` | `before_local_implemented` | `n/a` | `not_applicable` | `none` | `none` |
| `BCI` | `backend-concurrency-idempotency-validation` | `not_needed` | `low` | `BCI-NON-IDEMPOTENT-WRITE` | `before_local_implemented` | `n/a` | `not_applicable` | `none` | `none` |
| `RLS` | `runtime-load-stress-validation` | `not_needed` | `low` | `RLS-SLO-CLAIM` | `before_production_ready` | `n/a` | `not_applicable` | `none` | `none` |
- **Audit escalation overlay:** `recommended for performance/concurrency only because the historic trigger matrix says release_or_promotion_critical=yes; the PCV method must validate or correct these lane classifications before Local-Implemented.`

## Verification Debt Assessment
- **Audit outcome:** `pending`
- **Why this outcome:** `Audit escalation requires a verification-debt audit for this big/release-sensitive historic package.`
- **Inline code TODO debt:** `pending`
- **Evidence / audit artifact:** `pending wf-docker verification-debt audit`
- **Accepted residual debt:** `pending`

## Independent Test Quality Audit Gate
- **Audit decision:** `required`
- **Why this decision:** `audit escalation: tests touched, behavior-defining routing change, and release-sensitive governance surface.`
- **Trigger signals in scope:** `changed test logic|behavior-defining change|architectural change|compatibility|non-trivial validation risk`
- **Required evidence matrix (when architectural):** `unit|n/a widget|n/a integration|n/a web real-backend|n/a mobile real-backend`
- **Package mode:** `bounded-summary`
- **Package minimum contents:** `frozen closeout baseline|historic implementation range|bounded test diff|current validation evidence|DoD|residual risks`
- **Canonical method:** `wf-docker-independent-test-quality-audit-method`
- **Audit isolation mode:** `fresh internal no-context reviewer`
- **Internal reviewer mandate:** `required; resolve strongest-review from the canonical JSON; wait for the live reviewer without recycling on a timeout`
- **Gate-satisfying evidence expectation:** `required fresh internal no-context audit; external provider evidence does not satisfy the gate`
- **Audit focus:** `routing fixture coverage, fail-closed assertions, client-capability boundaries, and test-only bypass detection`
- **Required applicable evidence:** `audit framing|bypass scan|assertion efficacy|issue cards when material findings exist|failure modes|decision adherence evidence`
- **Audit status:** `not_run`
- **Findings summary:** `The first Terra audit found missing malformed provider/alias/version negatives; its re-audit then found missing multipart numeric positive coverage. Both bounded JSON-derived fixture repairs are integrated; one fresh no-context re-audit remains required before closeout.`
- **Resolution ledger:** `P0-EXACT-MATCH-TEST-001 -> same-todo integrated_pending_re-audit; P0-EXACT-MATCH-TEST-002 -> same-todo integrated_pending_re-audit`
- **Evidence / reference:** `2026-09-27 structured test-quality audits/merges; routine-executor validation after the multipart positive fixture: routing test exit 0, 2020 ms; diff check exit 0, 7 ms. Raw packets remain transient outside Git.`
- **Waiver authority / reference (required if waived):** `n/a`

## Independent No-Context Final Review Gate
- **Final review decision:** `required`
- **Why this decision:** `audit escalation: big, cross-stack governance surface with a historic high-severity architecture issue.`
- **Impact signals in scope:** `cross-module blast radius|intentional module supersede|high-severity issue card`
- **Package mode:** `bounded-summary`
- **Package minimum contents:** `frozen closeout baseline|approved historical scope boundary|bounded historic package summary|adherence status|validation evidence|test-audit evidence|residual risks|verification debt`
- **Review isolation mode:** `fresh internal no-context reviewer`
- **Internal reviewer mandate:** `required; resolve strongest-review from the canonical JSON; wait for the live reviewer without recycling on a timeout`
- **Canonical multi-lane audit protocol (when required):** `audit-protocol-triple-review`
- **Audit session / round evidence (when protocol used):** `2026-09-27 triple audit round 01: all performance, test-quality, and cutover-integrity lanes zero findings; runner wording-only recommended-path conflict was adjudicated resolved. Session artifacts are transient outside Git.`
- **Review focus:** `adherence|regressions|validation evidence|test-audit evidence|security/performance residuals|elegance|structural regressions|verification debt`
- **Final review status:** `blocked`
- **Findings summary:** `Fresh no-context Sol final review found P0-FINAL-ROUTING-MATCH-001 and P0-FINAL-PCV-CLOSEOUT-001. The first is integrated in the bounded P0 guard/test loop and awaits fresh validation/re-review; the second requires a user-authorized PCV disposition.`
- **Resolution ledger:** `P0-FINAL-ROUTING-MATCH-001 -> same-todo integrated_pending_re-review; P0-FINAL-PCV-CLOSEOUT-001 -> blocked-user-decision`
- **Evidence / reference:** `2026-09-27 structured final-review merge; raw packets remain transient outside Git. Dedicated triple protocol was already resolved in round 01 and remains additive, not a substitute for this final review.`
- **Waiver authority / reference (required if waived):** `n/a`

## Independent Cutover Integrity Audit Gate
- **Cutover audit decision:** `required`
- **Why this decision:** `P0 retires the bootstrap exception and the prior discretionary-routing path, so canonical cutover and legacy-path retirement must be checked.`
- **Cutover signals in scope:** `canonical cutover|legacy-path retirement|compatibility exception`
- **Package mode:** `bounded-summary`
- **Canonical multi-lane audit protocol (when used):** `audit-protocol-triple-review`
- **Audit session / round evidence (when protocol used):** `pending`
- **Audit focus:** `canonical JSON authority|bootstrap-exception retirement|hidden fallback mirrors|pseudo-canonical client artifacts`
- **Cutover audit status:** `no_material_findings`
- **Findings summary:** `Triple-audit cutover-integrity lane on 2026-09-27 confirmed the bootstrap exception is removed from both executable canonical lists and no fallback bridge/mirror remains.`
- **Resolution ledger:** `none`
- **Evidence / reference:** `Resolved dedicated multi-lane audit round 01; raw session packets remain transient outside Git.`
- **Waiver authority / reference (required if waived):** `n/a`

## Module Consolidation Gate
- [ ] Canonical module docs were updated with stable conceptual outcomes and final decisions from this TODO.
- [ ] Decision promotion ledger (or equivalent trace table) in module docs links back to this TODO.
- [ ] Every relevant prior module decision is either preserved or intentionally superseded with explicit traceability.
- [ ] Superseded/conflicting tactical notes were removed or replaced by canonical module references.
- [ ] TODO/module cross-links were updated (including active/completed path changes).
