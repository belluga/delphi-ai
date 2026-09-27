# TODO: Delphi Cross-Stack TODO Agent-Orchestration Contract

## Artifact Identity

- **Artifact type:** tactical_execution_contract
- **Origin:** Consolidated from the temporary self-improvement ledger on 2026-09-27.
- **Authority rule:** config/agent_role_routing.json remains the sole role/model routing authority.

## Context

Delphi has role/model routing and a pre-execution guard, but not one bounded repeatable method for executing a current cross-stack TODO with the correct executor, static-analysis provider, test matrix, and independent review.

The method must reduce discretion, not create a generic coordinator. It preserves Architecture Simplification First, the principal checkout, one normal material writer, exact-TODO scope, and existing AGENTS/profile/authorization rules.

The execution baseline is the exact active TODO plus current Docker/Laravel/Flutter workspace state. Historic SHAs and unrelated Foundation Documentation do not select the initial executor.

## Framing Source & Story Slice

- **Feature brief:** direct-to-todo
- **Primary story ID:** n/a
- **Why this is the right current slice:** The user requested a durable Delphi contract for agent-selected cross-stack TODO execution, including deterministic admission, provider selection, test/review ordering, and evidence.
- **Direct-to-TODO rationale:** This is Delphi self-maintenance. It changes process/tooling, not a downstream product feature.

## Contract Boundary

- The TODO defines the reusable Delphi method. It does not authorize a downstream application TODO by itself.
- The method consumes the routing JSON and never copies role-to-model mappings into workflow, skill, guard code, or prose.
- The contract uses three distinct terms:
  - **surface:** implementation, implementation-validation, monitoring, formal-review, delivery-review, or another JSON-defined surface;
  - **execution role:** primary-chat, routine-executor, formal-reviewer, process-monitor, or deterministic-only;
  - **model family:** chat_orchestrator, routine_executor, monitoring, strongest_review, or another JSON-defined family.
- The V1 package is Delphi-only. A project-local provider declaration and bridge plugin setup are separately authorized downstream work.

## Implementation Intent

- **Current delivery:** Create the V1 workflow, explicitly invoked Codex skill, routing/provider/review guard extensions, tests, and coherent documentation/mirrors.
- **Planned next steps:** Complete P0, then P1, then refresh independent review and request APROVADO.
- **Anticipatory implementation authorized now:** none
- **Rationale:** V1 consumes existing authority, centralizes only deterministic checks, and defers any local orchestrator-writing exception until a genuine writer-lease capability exists.

## Delivery Status Canon (Required)

- **Current delivery stage:** Pending
- **Qualifiers:** Blocked
- **Next exact step:** await P0 closure, then P1 closure; run a fresh independent review of this tracked TODO before APROVADO.

## Active Work State (Required While TODO Remains In active)

- **Work state:** blocked
- **Why this state now:** P0/P1 own prerequisite routing/schema work, and the post-green test/review order requires a fresh review before this contract is frozen.
- **Exit condition:** P0 closes with its bootstrap exception retired; P1 closes with schema/taxonomy migration stabilized; the refreshed review converges; the user gives explicit APROVADO.

## Blocker Notes

- **Blocker:** Active prerequisite TODOs own routing guard and platform/scenario/settings work.
- **Why blocked now:** Concurrent changes to their shared config/guard/workflow surfaces violate single-owner discipline.
- **What unblocks it:** Close P0, then P1, then refresh this TODO's review and obtain APROVADO.
- **Owner / source:** delphi-pre-execution-agent-routing-guard followed by delphi-platform-scenario-settings-routing-contract.
- **Last confirmed truth:** The plan is implementation-ready in shape but must not begin until this ordering is true.

## Execution Lane Tracking (Required)

- **Local implementation branches:** delphi-ai:v0.6.2-rc
- **Promotion lane path:** resolve at implementation time through the applicable lane.
- **Lane-promoted threshold for this TODO:** pending
- **Production-ready threshold for this TODO:** pending

## Scope

- [ ] Extend the canonical routing schema/guard after P0/P1 so surface, role, model family, capability, precedence, and fallback resolve from one authority.
- [ ] Add active-runtime-model evidence distinct from declared routing selection; define quality and token-cost tiers only in canonical schema.
- [ ] Make model mismatch, unknown identity, or absent runtime proof return blocked with scoped user continuation and rerun.
- [ ] Add implementation_diff_review as a distinct post-green review kind under formal-review.
- [ ] Add generic static-analysis provider schema/resolver; absence, invalidity, or failure blocks and provider switching requires explicit user selection plus rerun.
- [ ] Add the canonical cross-stack workflow and explicitly invoked Codex skill as contract consumers.
- [ ] Implement executor-owned clean Problems, complete non-fail-fast focused-test matrix, bounded repair, and post-green independent diff review.
- [ ] Record minimal per-TODO phase/handoff evidence without inferring usage/cost or creating telemetry.
- [ ] Update affected workflows, templates, manifests, tooling register, mirrors, and tests.

## Out of Scope

- [ ] A second routing authority or hardcoded agent/model matrix.
- [ ] Automatic dispatch, automatic subagent spawning, automatic waiver approval, or fabricated runtime proof.
- [ ] Local orchestrator code writing in V1, including unused-import removal.
- [ ] Generic queue, retry engine, coordinator, patch executor, multi-writer topology, or accounting platform.
- [ ] Downstream project provider declaration/plugin installation/product implementation.
- [ ] Implicit CLI fallback, historical-SHA assignment, automatic delivery, or automatic promotion.

## Diff Expectation Contract (Required Before Delivery)

- **Contract status:** required before APROVADO
- **Policy:** strict; unclassified or forbidden paths block delivery
- **User validation:** required on deviation
- **Comparison mode:** working_tree

### Repository Baselines

| Repository | Path | Baseline ref | Comparison mode |
| --- | --- | --- | --- |
| delphi-ai | delphi-ai | capture immediately before APROVADO | working_tree |
| current downstream project | separately authorized P4 | capture in P4 | working_tree |

### Expected Changed Paths

| Repository | Path glob | Change types | Reason |
| --- | --- | --- | --- |
| delphi-ai | config/agent_role_routing.json, schema, routing guard, review dispatch/schema, tests | A or M | Canonical contract and deterministic enforcement. |
| delphi-ai | workflows/docker, skills, templates, tools/manifest.md, tooling register | A or M | Method, skill, consumer documentation, and mirrors. |
| delphi-ai | tools/vscode_diagnostics_bridge | A or M | Only if required for provider health/schema support. |

### Not Expected Changed Paths

| Repository | Path glob | Change types | Reason |
| --- | --- | --- | --- |
| downstream project | all paths | any | P4 is separately authorized; V1 does not mutate application/product surfaces. |
| delphi-ai | unrelated promotion, runtime, CI, or stack policy | any | Prevent scope expansion. |

## Bounded But Elastic Guardrails

- **May stay inside this TODO:** Required schema, guard, workflow, skill, template, test, manifest, and mirror changes that make role, model evidence, provider, matrix, and review gates coherent.
- **Must update or split the TODO:** Writer lease/atomic patch permits, project configuration instances, automatic dispatch, another client platform, telemetry service, or product implementation.

## Definition of Done

- [ ] Routing JSON remains the only role/model authority; all consumers resolve surface, role, and family from it.
- [ ] Intake validates and presents implementation, monitoring, review, and provider selections before real execution.
- [ ] Guard distinguishes declared selection from active-runtime evidence and validates scoped continuation through rerun.
- [ ] Provider selection has no automatic fallback. Missing/invalid/unavailable selection blocks until an explicitly chosen provider validates.
- [ ] V1 has no local orchestrator writing exception; routine executor is the sole normal material writer.
- [ ] Executor owns complete declared focused-test matrices after clean Problems; every command is attempted and individually evidenced.
- [ ] Fresh independent implementation_diff_review occurs only after clean Problems and a full green matrix; request changes restarts the complete cycle.
- [ ] Test repair restores intended contract only; it cannot weaken, skip, delete, or narrow expectations.
- [ ] Implementation diff, critique/governance, and final delivery review remain separate.
- [ ] Per-TODO phase/handoff observation is minimal, non-authoritative, and represents unavailable usage as unavailable.
- [ ] Exact tests, self-check/mirrors, TODO/diff gates, fresh final review, and delivery evidence are complete before any delivery claim.

## Validation Steps

- [ ] Routing fixtures: exact, stronger, weaker, lateral, unknown, runtime unavailable, continuation, expiry, and no hardcoded family drift.
- [ ] Provider fixtures: absent/invalid declaration, exact CLI command, missing CLI command, healthy bridge, bridge health/workspace/revision failure, explicit provider switch, prohibited fallback.
- [ ] Review fixtures: request_changes, approve_green_diff, green matrix binding, missing/non-green rejection, invalid payload, and final-review/critique separation.
- [ ] Focused-matrix fixtures: continue after failure; row completeness; cleanup; missing/skipped/unclassifiable equals non-green; repair resets Problems plus full matrix.
- [ ] Observability fixtures: platform usage preserved when available and unavailable when absent; data cannot alter routing/gates.
- [ ] Run affected routing/review/provider tests, Python compilation for new tools, bash self_check.sh, and git diff --check.
- [ ] Run python3 tools/todo_deterministic_validator.py against this TODO.
- [ ] Run fresh independent implementation/delivery review after implementation.

### Flow Evidence Planning Matrix

| Criterion / Flow | Why Flow-Impacting | Required Runtime Lane | Planned Evidence | Non-Applicability Rationale |
| --- | --- | --- | --- | --- |
| Delphi role/provider/test orchestration | structure-only | n/a | deterministic fixtures, workflow/skill review, self-check | V1 changes Delphi tooling, not downstream user flow. |
| Project provider instance | environment/tooling contract | selected-provider validation | P4 resolver/health or exact CLI evidence | P4 is outside this TODO. |

### Local CI-Equivalent Suite Matrix

| Repository / CI Surface | Behavior | Preconditions | Command | Required Before | Status |
| --- | --- | --- | --- | --- | --- |
| routing guard | role/evidence/continuation resolution | deterministic JSON fixtures | bash tools/tests/agent_role_routing_guard_test.sh | Local-Implemented | planned |
| provider resolver | explicit selection and fail-closed behavior | provider fixtures | new provider regression | Local-Implemented | planned |
| review dispatch/schema | post-green decision validation | green/non-green fixtures | affected dispatch regression | Local-Implemented | planned |
| focused matrix | all-command execution/evidence | controlled command fixtures | new matrix regression | Local-Implemented | planned |
| Delphi coherence | mirrors and canonical wording | none | bash self_check.sh | Local-Implemented | planned |

## Profile Scope & Handoffs

- **Primary execution profile:** strategic-cto
- **Active technical scope:** delphi-self-maintenance
- **Expected supporting profiles:** operational-coder and assurance-tester-quality
- **Scope-check command:** n/a - Delphi self-maintenance

### Handoff Log

| From | To | Why | Status |
| --- | --- | --- | --- |
| strategic-cto | assurance-tester-quality | Fresh no-context review after P0/P1, before APROVADO. | planned |
| strategic-cto | operational-coder | Implement only after prerequisites, review convergence, and APROVADO. | blocked |

## Complexity

- **Level:** big
- **Checkpoint policy:** section-by-section
- **Why:** This crosses routing/schema, guards, provider selection, test/review sequencing, workflow/skill/templates, and mirrors.

## Audit Trigger Matrix

- **Canonical method:** `wf-docker-audit-escalation-method`
- **Guard command:** `python3 tools/audit_escalation_guard.py --todo foundation_documentation/todos/active/delphi-cross-stack-todo-agent-orchestration-contract.md`
- **Latest TEACH evidence / artifact:** pending initial guard run

| Trigger | Value | Notes |
| --- | --- | --- |
| `complexity` | `big` | Routing, guards, provider resolution, workflow/skill, tests, and mirrors change together. |
| `blast_radius` | `cross-module` | The V1 package stays in Delphi but crosses its canonical modules. |
| `behavioral_change_or_bugfix` | `yes` | It defines execution admission, validation, and review behavior. |
| `changes_public_contract` | `yes` | It extends the canonical routing/provider/review contract consumed by Delphi tooling. |
| `touches_auth_or_tenant` | `no` | No identity, authorization, or tenant behavior belongs to V1. |
| `touches_runtime_or_infra` | `no` | V1 does not change product runtime, deployment, or infrastructure; a project provider instance is deferred to P4. |
| `touches_tests` | `yes` | Routing, provider, review, and matrix regressions require fixtures. |
| `critical_user_journey` | `no` | This is Delphi self-maintenance, not a downstream user journey. |
| `release_or_promotion_critical` | `no` | No release or promotion is claimed by this planning artifact. |
| `high_severity_plan_review_issue` | `no` | No current high-severity issue card is unresolved in this TODO. |
| `explicit_three_lane_request` | `no` | The user requested an independent review loop, not the additive three-lane delivery protocol. |

## Canonical Module Anchors

- **Primary module doc:** config/agent_role_routing.json
- **Secondary module docs:**
  - tools/agent_role_routing_guard.py
  - workflows/docker/todo-execution-boundary-method.md
  - workflows/docker/todo-driven-execution-method.md
  - workflows/docker/independent-final-review-method.md
  - workflows/docker/subagent-worktree-reconciliation-method.md
  - templates/todo_template.md
  - tools/manifest.md
  - skills/deterministic-tooling-register.md
- **Consolidation targets:** routing JSON/schema, routing guard, review dispatch/schema, provider resolver, workflow/skill, templates/manifests/mirrors.

## Decisions (Resolved Before Freeze)

- [x] D-01: Routing JSON is authority; consumers do not duplicate its matrix.
- [x] D-02: V1 skill invocation is explicit; automatic dispatch is a separate future proposal.
- [x] D-03: Baseline is current exact TODO plus current workspace, never historical SHAs.
- [x] D-04: Routine executor is sole normal material writer; V1 has no microadjustment exception.
- [x] D-05: Declared routing and active runtime evidence are distinct; mismatches block until scoped record plus rerun.
- [x] D-06: Provider absence/failure blocks; an explicitly selected other provider must validate independently.
- [x] D-07: Bridge mode uses a stable full-workspace live Problems snapshot and never silently falls back.
- [x] D-08: Executor reaches clean Problems plus complete green matrix before independent implementation-diff review.
- [x] D-09: Request changes restarts Problems, matrix, and review; final delivery review is separate.
- [x] D-10: Every focused-test command runs and is evidenced even after failures; repairs cannot weaken tests.
- [x] D-11: Extra adversarial review is risk-triggered only.
- [x] D-12: Usage/handoff evidence is per-TODO and non-authoritative; absent usage is unavailable.
- [x] D-13: Mechanical token-economy path is deferred to writer lease plus atomic-consumption work.

## Module Decision Baseline Snapshot

| Module Decision Ref | Current Decision | Planned Handling |
| --- | --- | --- |
| config/agent_role_routing.json | canonical client/surface/model-family routing | preserve; extend only after P0/P1 |
| delphi-pre-execution-agent-routing-guard | active routing guard review | prerequisite P0 |
| delphi-platform-scenario-settings-routing-contract | active generic schema/migration work | prerequisite P1 |
| Flutter Problems instructions | editor-managed bridge-first wording | intentional supersession through explicit provider resolver; no implicit fallback |

## Decision Baseline (Frozen Before Implementation)

- [x] D-01: P0 then P1 close before P2 begins.
- [x] D-02: Blocked model/provider states require valid record and guard rerun before go.
- [x] D-03: No independent diff review of untested diff.
- [x] D-04: No local orchestrator edit in V1.
- [x] D-05: No inferred cost from model, response length, or prose.

## Architecture Change Governance

- **Applicability:** required
- **Deviation / debt:** Discretionary role/provider selection, ambiguous test/review order, implicit provider fallback, and review of untested diffs.
- **Target steady-state:** One routing authority; explicit selections/exceptions; executor-owned green matrix; post-green independent review; normal single writer.
- **Temporary exceptions:** none in V1
- **Cutover condition:** JSON, guards, workflow, skill, templates, and mirrors agree; obsolete conflicting provider wording is retired.

### Prohibited Anti-Patterns

| Anti-pattern | Detection signal | Policy |
| --- | --- | --- |
| hardcoded role/model matrix | values outside canonical contract | block |
| automatic provider fallback | provider changed without user record/rerun | block |
| pre-green diff review | no clean Problems/full green evidence | block |
| test weakening for green | reduced contract/coverage | block |
| local orchestrator implementation | V1 diff lacks executor ownership | block |
| generic coordinator or telemetry | scope expands beyond per-TODO evidence | renewed approval |

## Architecture Review Gates

- **Architecture decision review:** required (from `audit_escalation_guard.py`)
- **Decision review lifecycle:** after P0/P1 are closed and before APROVADO
- **Decision review kind:** `architecture_opinion`
- **Decision review package:** bounded-file-set
- **Decision review status:** not_run
- **Decision review evidence / resolution:** pending P0/P1 closure and fresh freeze-backed review
- **Architecture adherence review:** required (from `audit_escalation_guard.py`)
- **Adherence review lifecycle:** after implementation and before Completed
- **Adherence review kind:** `architecture_adherence`
- **Adherence review package:** bounded-file-set
- **Adherence review status:** not_run
- **Adherence review evidence / resolution:** delivery-stage gate; no implementation exists
- **No-go handling:** absent, blocked, or unresolved required review returns to the applicable plan or delivery loop; it never authorizes APROVADO or Completed.

## Gate: Review Baseline Freeze

- **Gate decision:** required
- **Why this decision:** A fresh independent planning review must assess one committed, pushed contract rather than transient conversation state.
- **Trigger stage:** before the first freeze-backed planning-side review or guard run
- **Baseline branch:** `v0.6.2-rc`
- **Baseline commit:** `bf67507`
- **Baseline push reference:** `origin/v0.6.2-rc`
- **Gate status:** no_material_findings
- **Findings summary:** `bf67507` is the committed, pushed planning package. This freeze does not satisfy the still-required fresh review after P0/P1.
- **Evidence / reference:** `origin/v0.6.2-rc` push of `bf67507` on 2026-09-27.
- **Waiver authority / reference (required if waived):** n/a

## Gate: Review Scope Drift

- **Gate decision:** required
- **Why this decision:** Review changes must not silently alter scope, validation semantics, ownership, or the no-fallback contract.
- **Trigger stage:** after the planning-side review/guard cycle converges and before APROVADO
- **Baseline source:** Review Baseline Freeze -> Baseline commit
- **Material sections compared:** Context|Contract Boundary|Scope|Out of Scope|Definition of Done|Validation Steps|Execution Lane Tracking|Canonical Module Anchors|Decisions|Decision Baseline|Architecture Change Governance|Assumptions Preview|Execution Plan|Flow Evidence Planning Matrix|Local CI-Equivalent Suite Matrix
- **Guard command:** `python3 tools/review_scope_drift_guard.py --todo foundation_documentation/todos/active/delphi-cross-stack-todo-agent-orchestration-contract.md`
- **No-go handling rule:** return to the review loop, revalidate material evolution with the user, refresh the pushed baseline when needed, and rerun affected gates.
- **Gate status:** not_run
- **Findings summary:** no freeze-backed review has converged
- **Evidence / reference:** pending the review baseline and fresh critique
- **Waiver authority / reference (required if waived):** n/a

## Assumptions Preview

| Assumption | Evidence | If False | Handling |
| --- | --- | --- | --- |
| Existing routing guard can extend instead of be replaced. | It already resolves client/surface/role/model/effort. | Do not create a second selector. | block |
| P0/P1 can close before P2. | Active ownership is explicit. | Keep TODO blocked and re-sequence. | block |
| Project authority can provide provider declaration path at intake. | User chose explicit selection rather than default. | Guard blocks and requests scoped selection. | keep |
| Platform may lack active-model telemetry. | Current guard accepts declared selection, not telemetry. | Explicit continuation remains unverified. | keep |

## Execution Plan

### Ownership-Safe Sequence

| Phase | Owner / prerequisite | Bounded outcome | Exit gate |
| --- | --- | --- | --- |
| P0 | existing routing-guard TODO | close it and retire bootstrap exception | its closeout completes |
| P1 | existing platform/scenario/settings TODO after P0 | stabilize approved schema/migration/taxonomy only | its closeout completes |
| P2 | this TODO after P0/P1 | extend routing guard; add post-green review kind; provider schema/resolver; canonical wording | routing/provider/review fixtures pass |
| P3 | this TODO after P2 | add explicit workflow/skill, matrix rules, minimal evidence, templates/manifests/mirrors | consumers use JSON roles only |
| P4 | separately authorized downstream task | create provider declaration and bridge/plugin setup if selected | project provider preflight returns go |
| P5 | separate future TODO | consider writer lease/atomic mechanical permit | separately approved/validated |
| P6 | consolidated V1 | exact fixture matrix, TODO/diff validation, fresh final review | all gates pass |

### V1 Runtime Cycle

1. Explicit skill invocation loads the exact TODO and current workspace.
2. Intake resolves surface, role, model family, provider, capabilities, precedence, and fallback; user confirms the map.
3. Missing/mismatched model or provider state is blocked. A scoped record is accepted only through successful guard rerun.
4. Routine executor is the sole normal writer. Orchestrator waits with collaboration.wait_agent timeout_ms 240000; timeout is a wait window, not failure.
5. At checkpoint, collect selected-provider static evidence. Bridge mode requires stable full-workspace live Problems.
6. Errors, warnings, or new attributable diagnostics return to executor.
7. With clean Problems, executor runs every declared focused-test command as one non-fail-fast matrix. Each row records command, exit, duration, evidence/output, and product/environment classification. Cleanup is protected.
8. Any non-green, missing, skipped, or unclassifiable row is non-green. Executor may make one bounded contract-preserving repair batch, then returns to step 5.
9. Only clean Problems plus green complete matrix dispatches fresh no-context implementation_diff_review through contract-selected formal review.
10. Reviewer checks frozen diff scope, architecture, contract integrity, and attached test evidence; emits request_changes or approve_green_diff.
11. Request changes returns to step 5. Approval proceeds only to remaining delivery gates and never replaces final delivery review.
12. Extra audit is only for explicit security, data integrity, concurrency, public-contract, or user-request risk.

### Deterministic Tool Boundaries

| Tool / surface | Responsibility | Must not do |
| --- | --- | --- |
| routing guard | resolve authority; compare canonical identity/evidence/tier; validate continuation | invent runtime proof or second authority |
| provider guard | validate explicit declaration/selection, command or bridge health/workspace/stability | analyze source or fall back |
| review schema/dispatch | validate post-green decision/matrix binding; resolve review family | approve untested diff or replace final review |
| workflow/skill | invoke tools in order and present user decisions | duplicate selection policy |
| mechanical guard | deferred from V1 | create writer authority |

## Plan Review Gate

- **Gate decision:** required
- **Why:** A material refinement now puts complete executor-owned focused-test matrix and repair before independent diff review.
- **Reviewer selection:** Resolve formal-review/strongest-review through routing JSON; no named model here.
- **Focus:** P0/P1 ownership, taxonomy, provider non-fallback, model continuation, matrix/review order, test-strength preservation, and no V1 writer bypass.
- **Status:** pending fresh review after P0/P1

### Failure Modes & Edge Cases

- [ ] P0/P1 remain active or touch overlapping routing/schema surfaces: keep this TODO blocked; do not create a second owner.
- [ ] Runtime model evidence or the explicitly selected provider is absent, invalid, unstable, or mismatched: return `blocked`; require the scoped user record and a successful rerun, never fallback.
- [ ] Problems is non-clean, a matrix row is non-green/missing/skipped/unclassifiable, or review requests changes: return the work to the routine executor and restart the cycle from Problems.
- [ ] A review proposes a generic coordinator, queue, retry, new abstraction, writer bypass, or scope expansion: challenge it against the frozen TODO and require renewed approval if it is not indispensable.

### Residual Unknowns / Risks

- [ ] P0/P1 timing and their final schema/taxonomy are external prerequisites; this TODO must be re-reviewed against their closed state before approval.
- [ ] The downstream project provider-declaration location and bridge installation authority are intentionally not invented in V1; P4 remains separately authorized.
- [ ] Platform evidence may not attest the active runtime model; unverified evidence remains blocked until the future canonical continuation path is validated.

## Independent No-Context Critique Gate

- **Critique decision:** required
- **Why this decision:** The guard derives the expanded critique floor from big, cross-module, behavior-defining, canonical-contract, and test-touching scope.
- **Impact signals in scope:** cross-module blast radius|public contract/schema/api
- **Package mode:** bounded-file-set
- **Package minimum contents:** frozen baseline|approved scope boundary|assumptions preview|execution plan summary|issue cards|residual risks|existing blockers
- **Critique isolation mode:** fresh internal no-context reviewer
- **Internal reviewer mandate:** required; the reviewer is not the implementing agent, waits are status-based, and an external provider does not satisfy this gate.
- **Canonical multi-lane audit protocol:** n/a; the delivery-side triple protocol is recommended and additive, not a critique substitute.
- **Critique lenses:** correctness|performance|elegance|structural-soundness|risk
- **Trigger:** After P0/P1 closure, plan review convergence, and baseline freeze; before APROVADO.
- **Focus:** Simplification First, scope expansion, second authority, implicit fallback, generic coordinator/telemetry drift, and premature mechanical exception.
- **Critique status:** not_run
- **Findings summary:** no freeze-backed critique has run
- **Evidence / reference:** pending P0/P1 and the refreshed review baseline
- **Waiver authority / reference (required if waived):** n/a

## Gate: Assumption Code Coherence

- **Gate decision:** required
- **Trigger:** before APROVADO and before delivery
- **Required evidence:** Guards/dispatch/bridge support every claimed capability; unsupported capability remains blocked.
- **Gate status:** not_run

## Security Risk Assessment

- **Risk level:** low
- **Why this risk level:** V1 changes governance tooling rather than an auth, tenant, secret, payment, or public runtime surface; a mistaken allow decision is contained by fail-closed routing/provider gates and independent review.
- **Attack surface in scope:** local routing/provider/review configuration and CLI/bridge invocation policy; no credentials or downstream endpoint behavior.
- **Attack simulation decision:** not_needed (from `audit_escalation_guard.py`)
- **Review evidence:** `SEC-NOT-TRIGGERED`; reassess if V1 later introduces untrusted input, credentials, or a public service boundary.
- **Residual security risk:** incorrect local policy implementation; mitigated by fixtures, bounded scope, and required final review.

## Performance & Concurrency Risk Assessment

- **Policy schema version:** `pcv-1`
- **Global sensitivity level:** none
- **Why this level:** V1 does not alter a query path, user-flow latency target, concurrent write path, queue, runtime, or deployment system.
- **Current delivery stage at review time:** Pending
- **Derived performance/concurrency decision:** not_needed (from `audit_escalation_guard.py`); no PCV-1 lane is applicable unless scope changes.

## Verification Debt Assessment

- **Audit decision:** required
- **Audit outcome:** pending
- **Why this outcome:** Big cross-module tooling work requires a delivery-stage check that validation and evidence debt did not accumulate.
- **Inline code TODO debt:** none known before implementation
- **Evidence / audit artifact:** not_run; execute `verification-debt-audit` before Completed.
- **Accepted residual debt:** none; unverified delivery evidence cannot be accepted as debt.

## Independent Test Quality Audit Gate

- **Audit decision:** required
- **Why this decision:** V1 adds behavior-defining routing/provider/review/matrix fixtures under a canonical tooling contract.
- **Trigger signals in scope:** changed test logic|behavior-defining change|architectural change|shared contract/api/schema|non-trivial validation risk
- **Required evidence matrix:** unit (deterministic guard/resolver fixtures)|n/a downstream runtime lanes
- **Package mode:** bounded-file-set
- **Canonical method:** `wf-docker-independent-test-quality-audit-method`
- **Audit isolation mode:** fresh internal no-context reviewer
- **Audit status:** not_run
- **Findings summary:** no implementation or test diff exists
- **Evidence / reference:** delivery-stage gate after P2/P3 implementation and exact fixtures

## Independent No-Context Final Review Gate

- **Final review decision:** required
- **Why this decision:** The final package changes a cross-module canonical contract and its test/review gates.
- **Impact signals in scope:** cross-module blast radius|public contract/schema/api
- **Package mode:** bounded-file-set
- **Review isolation mode:** fresh internal no-context reviewer
- **Canonical multi-lane audit protocol:** `audit-protocol-triple-review` is recommended and additive at delivery; it cannot replace this final review.
- **Final review status:** not_run
- **Findings summary:** no implementation exists
- **Evidence / reference:** delivery-stage gate after validation, test-quality audit, verification-debt audit, and architecture-adherence review

## Approval

- **Status:** not requested
- **Required before implementation:** P0/P1 closure, refreshed plan review/critique, assumption-code coherence, review-scope-drift evidence, explicit user APROVADO.

## Agent Routing Preflight

- **Canonical contract:** config/agent_role_routing.json
- **Required evidence:** Exact TODO; resolved surface/role/model family/provider; actual-model status; user map confirmation; selection/continuation records as needed.
- **Fail-closed behavior:** No implementation, provider evidence, review, or focused tests without guard result go.
- **Status:** n/a until APROVADO

## Consolidated Review Record

Independent reviews established the V1 outcomes below:

- no automatic provider fallback;
- declared routing selection is not runtime-model proof;
- P0/P1 serialize ownership;
- implementation_diff_review is distinct from final review;
- model identity requires canonical/exact identity or declared equivalence;
- provider selection record binds user decision, prior/new provider, TODO/session/surface, reason, and expiry;
- V1 has no writer bypass;
- executor completes full matrix and bounded repair before independent review;
- request changes restarts Problems, matrix, and review;
- usage/cost is retained only when platform-reported and otherwise unavailable.

The post-green review order is material and requires the pending fresh review before freeze.

## Commands (Run Locally)

- bash tools/tests/agent_role_routing_guard_test.sh
- new provider guard regression command
- affected review dispatch/schema regression command
- new focused-test matrix regression command
- bash self_check.sh
- git diff --check
- python3 tools/todo_deterministic_validator.py --todo foundation_documentation/todos/active/delphi-cross-stack-todo-agent-orchestration-contract.md
