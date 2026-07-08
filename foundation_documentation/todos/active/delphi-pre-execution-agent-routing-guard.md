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
- **Next exact step:** `review the completed routing package, decide closeout/commit sequencing, and retire the bootstrap exception at TODO closeout`

## Active Work State (Required While TODO Remains In `active/`)
- **Work state:** `review`
- **Why this state now:** The bounded routing package is implemented and locally validated; the TODO remains active while the package is reviewed and prepared for closeout/commit handling.
- **Exit condition:** Review/closeout either confirms the package for completion or opens a bounded follow-up/blocker.

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
- [x] Run `python3 -m py_compile tools/agent_role_routing_guard.py` and any supporting Python helpers created for this slice.
- [x] Run `bash tools/tests/agent_role_routing_guard_test.sh`.
- [x] Run existing regression suites for any touched deterministic guards or routing helpers.
- [x] Run `bash self_check.sh`.
- [x] Run `git diff --check`.
- [x] Run representative routing preflight commands for at least Codex, Claude Code, and Cline IDE mappings and record the expected outcome.

### Flow Evidence Planning Matrix
| Criterion / Flow | Why Flow-Impacting | Platform Parity | Required Runtime Lane | Mutation Lane Required? | Backend Real-Data Required? | Planned Evidence | Non-Applicability Rationale |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Delphi routing contract and pre-execution guard | `structure-only` | `n/a` | `n/a` | `no` | `no` | guard CLI fixtures, self-check, touched workflow/template review | No downstream product runtime or user-facing app flow changes are in scope. |

### Local CI-Equivalent Suite Matrix
| Repository / CI Surface | Why In Scope | Behavior / Scenario Covered | Fixture / Seed / Runtime Preconditions | Local CI-Equivalent Command | Required Before | Status | Evidence Artifact / Command | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `delphi-ai / routing guard compile` | New deterministic Python tooling. | Python guard and helper syntax is valid. | none | `python3 -m py_compile tools/agent_role_routing_guard.py tools/sync_claude_agent_routing.py tools/todo_authority_guard.py` | `Local-Implemented` | `passed` | `python3 -m py_compile tools/agent_role_routing_guard.py tools/sync_claude_agent_routing.py tools/todo_authority_guard.py` | Includes the new Claude sync tool plus the touched authority guard. |
| `delphi-ai / routing guard regression` | New fail-closed routing behavior needs positive and negative fixtures. | Guard returns the correct routing outcome for implementation, review, monitoring, unsupported-capability, and waiver scenarios. | deterministic fixture inputs only | `bash tools/tests/agent_role_routing_guard_test.sh` | `Local-Implemented` | `passed` | `bash tools/tests/agent_role_routing_guard_test.sh` | Covers go, delegate-required, review-required, waiver-required, and blocked paths. |
| `delphi-ai / touched guard regressions` | Existing deterministic guards may ingest the new routing ledger or preflight evidence. | Existing approval/execution/orchestration guard behavior stays coherent after routing integration. | relevant fixture TODO/plan files | `bash tools/tests/todo_authority_guard_test.sh` | `Local-Implemented` | `passed` | `bash tools/tests/todo_authority_guard_test.sh` | Includes the new `Agent Routing Preflight` enforcement path. |
| `delphi-ai / mirror and instruction coherence` | Workflows, skills, manifests, mirrors, and possibly generated client artifacts will change. | Canonical and mirror surfaces remain synchronized and internally coherent. | none | `bash self_check.sh` | `Local-Implemented` | `passed` | `bash self_check.sh` | Synced `.cline`, `.claude`, `.clinerules`, public Codex mirrors, and Claude routing agents. |

### Runtime / Rollout Notes
- No downstream runtime rollout is in scope.
- Client-facing artifact generation must remain declarative and must not depend on private runtime credentials or project-specific env.

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
- [x] `D-07` This TODO carries a one-time bootstrap exception: until the first routing guard exists and validates, the current session may implement the enforcement package directly in the primary chat under explicit approval; that exception expires when this TODO closes.

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
- **Temporary exceptions allowed:** bounded orchestrator-local reconciliation, merge-conflict resolution, minimal integration glue explicitly authorized by workflow and recorded in routing evidence, plus this TODO's one-time bootstrap exception while the first routing guard is still the thing being built
- **Cutover / removal condition:** once the new guard, routing ledger/evidence, and workflow/template integrations are in place and validated, the old discretionary fallback behavior becomes prohibited

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

## Gate: Review Baseline Freeze
- **Gate decision:** `required`
- **Why this decision:** This is a big Delphi self-maintenance slice touching core execution policy; the review package must freeze before plan-side review and critique.
- **Trigger stage:** `before the first planning-side review or guard run`
- **Baseline branch:** `pending`
- **Baseline commit:** `pending`
- **Baseline push reference:** `pending`
- **Gate status:** `waived`
- **Findings summary:** `the user approved the execution contract directly after the bounded plan review; no separate no-context critique packet was run before implementation`
- **Evidence / reference:** `session approval thread on 2026-07-06`
- **Waiver authority / reference (required if waived):** `user - APROVADO on 2026-07-06`

## Gate: Review Scope Drift
- **Gate decision:** `required`
- **Why this decision:** Routing policy is approval-material; drift in scope, exceptions, or client coverage must reconverge before APROVADO.
- **Trigger stage:** `after planning-side review convergence and before APROVADO`
- **Baseline source:** `Review Baseline Freeze -> Baseline commit`
- **Guard command:** `python3 delphi-ai/tools/review_scope_drift_guard.py --todo foundation_documentation/todos/active/delphi-pre-execution-agent-routing-guard.md`
- **Gate status:** `waived`
- **Findings summary:** `the touched insertion points were inspected directly during TODO preparation; no separate assumption-code coherence guard exists yet for this slice`
- **Evidence / reference:** `direct code/doc inspection during TODO preparation on 2026-07-06`
- **Waiver authority / reference (required if waived):** `bootstrap exception within this TODO`

## Questions To Close
- [x] Claude artifact generation stays in the first slice and is implemented through `tools/sync_claude_agent_routing.py` plus generated `.claude/agents/*.md`.
- [x] Routing evidence uses a compact `Agent Routing Preflight` section inside TODOs plus `Worker Routing Contracts` inside orchestration plans.

## Assumptions Preview
| Assumption ID | Assumption | Evidence | If False | Confidence | Handling |
| --- | --- | --- | --- | --- | --- |
| `A-01` | A deterministic preflight can enforce correct routing by declared client/capability plus durable evidence even when runtime model introspection is unavailable. | prior Delphi guards already validate declared process evidence rather than hidden chat state | the slice would need runtime-specific proof adapters or a narrower first scope | `Medium` | `Promote to Decision` |
| `A-02` | Claude-compatible agent artifacts can be generated from a canonical contract without introducing project-specific truth. | `.claude/skills/**` mirrors and existing compatibility surfaces are already generated from canonical Delphi sources | Claude support should be reduced to documented mapping only in this slice | `Medium` | `Keep as Assumption` |
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
- **Critique status:** `not_run`
- **Findings summary:** `not started`
- **Evidence / reference:** `n/a`
- **Waiver authority / reference (required if waived):** `n/a`

## Gate: Assumption Code Coherence
- **Gate decision:** `required`
- **Why this decision:** The plan depends on real client/tooling constraints and on the current code already exposing the intended insertion points.
- **Trigger stage:** `after critique convergence and before APROVADO`
- **Guard scope:** `A-01,A-02,A-03`
- **Guard command:** `python3 delphi-ai/tools/assumption_code_coherence_guard.py --todo foundation_documentation/todos/active/delphi-pre-execution-agent-routing-guard.md`
- **Gate status:** `not_run`
- **Findings summary:** `not started`
- **Evidence / reference:** `n/a`
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
- **Current governed action:** `implementation`
- **Selected role:** `primary-chat`
- **Selected model:** `gpt-5.4-mini`
- **Selected effort:** `medium`
- **Proof mode:** `waiver`
- **Exception reason:** `bootstrap-guard-implementation`
- **Guard outcome:** `go`
- **Waiver / exception reference:** `D-07 bootstrap exception`
