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

- [ ] Extend the canonical routing schema/guard after P0/P1 so surface, role, model family, capability, precedence, and a `fallback_policy=prohibited` resolve from one authority.
- [ ] Add active-runtime-model evidence distinct from declared routing selection, with one closed active-model-state enum and explicit continuation outcomes; define quality and token-cost tiers only in canonical schema.
- [ ] Make model mismatch, unknown identity, or absent runtime proof return blocked with scoped user continuation and rerun.
- [ ] Add implementation_diff_review as a distinct post-green review kind under formal-review.
- [ ] Add generic static-analysis provider schema/resolver; absence, invalidity, or failure blocks and provider switching requires explicit user selection plus rerun.
- [ ] Add the canonical cross-stack workflow and explicitly invoked Codex skill as contract consumers.
- [ ] Implement executor-owned clean Problems, complete non-fail-fast focused-test matrix, bounded repair, and post-green independent diff review.
- [ ] Record minimal per-TODO phase/handoff evidence without inferring usage/cost or creating telemetry.
- [ ] Make surface traits, role catalog, review-kind-to-surface binding, and model-family resolution canonical data; production guard invocation cannot replace the contract path, while fixture injection remains test-only.
- [ ] Bind `implementation_diff_review` canonically to `surface=formal-review` and `role=formal-reviewer`; reject any other surface/role combination.
- [ ] Update affected workflows, templates, manifests, tooling register, mirrors, and tests.

## Out of Scope

- [ ] A second routing authority or hardcoded surface/role/model/review matrix.
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

- [ ] Routing JSON remains the only surface/role/model/review authority; all consumers resolve their selection and binding from it.
- [ ] Intake validates and presents implementation, monitoring, review, and provider selections before real execution.
- [ ] Guard distinguishes declared selection from active-runtime evidence and validates scoped continuation through rerun.
- [ ] Provider selection has no automatic fallback. Missing/invalid/unavailable selection blocks until an explicitly chosen provider validates.
- [ ] V1 creates no local-orchestrator writing exception; routine executor is the sole normal material writer, and any pre-existing canonical exception stays governed by its own current contract rather than this TODO.
- [ ] A human continuation can affect only active-model admission; it never unblocks an absent, invalid, unhealthy, or wrong-workspace static-analysis provider.
- [ ] Executor owns complete declared focused-test matrices after clean Problems; every command is attempted and individually evidenced.
- [ ] Fresh independent implementation_diff_review occurs only after clean Problems and a full green matrix; request changes restarts the complete cycle.
- [ ] Test repair restores intended contract only; it cannot weaken, skip, delete, or narrow expectations.
- [ ] Implementation diff, critique/governance, and final delivery review remain separate.
- [ ] Per-TODO phase/handoff observation is minimal, non-authoritative, and represents unavailable usage as unavailable.
- [ ] Exact tests, self-check/mirrors, TODO/diff gates, fresh final review, and delivery evidence are complete before any delivery claim.

## Validation Steps

- [ ] Routing fixtures: declared versus observed model; active-model states `exact|stronger|weaker|lateral|unknown|unavailable`; scoped continuation/expiry; prohibited automatic transition; and no hardcoded surface/role/family/review or contract-path drift.
- [ ] Provider fixtures: absent/invalid declaration, exact CLI command, missing CLI command, healthy bridge, bridge health/workspace/revision failure, explicit provider switch, prohibited fallback, and human-model continuation cannot unlock a provider.
- [ ] Review fixtures: request_changes, approve_green_diff, green matrix binding, missing/non-green rejection, invalid payload, wrong-surface/wrong-role rejection, and final-review/critique separation.
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
| provider resolver | explicit selection, provider-only validation, and fail-closed behavior | provider fixtures | bash tools/tests/static_analysis_provider_guard_test.sh | Local-Implemented | planned |
| review dispatch/schema | post-green decision and formal-review/formal-reviewer binding validation | green/non-green and wrong-surface/role fixtures | bash tools/tests/review_dispatch_guard_test.sh | Local-Implemented | planned |
| focused matrix | all-command execution/evidence | controlled command fixtures | bash tools/tests/focused_test_matrix_guard_test.sh | Local-Implemented | planned |
| Delphi coherence | mirrors and canonical wording | none | bash self_check.sh | Local-Implemented | planned |
| approval-readiness | each named P2/P3 script exists and its fixture/oracle matches this frozen contract | P0/P1 closed schema/tool names | bash tools/tests/agent_role_routing_guard_test.sh; bash tools/tests/static_analysis_provider_guard_test.sh; bash tools/tests/review_dispatch_guard_test.sh; bash tools/tests/focused_test_matrix_guard_test.sh | APROVADO | blocked |

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
- **Latest TEACH evidence / artifact:** 2026-09-27 `audit_escalation_guard.py` -> `Overall outcome: go`; reconciled-critique fingerprint `00fa3104f472`.

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
| `release_or_promotion_critical` | `yes` | The future canonical routing/provider/review behavior materially governs delivery confidence even though this artifact itself makes no delivery claim. |
| `high_severity_plan_review_issue` | `yes` | The pre-prerequisite critique found unresolved P0/P1 ownership/taxonomy and V1-contract blockers. |
| `explicit_three_lane_request` | `yes` | The derived floor requires `audit-protocol-triple-review` as an additive delivery-side protocol; it never replaces critique or final review. |

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
- [x] D-14: V1 adds no writer bypass. Existing P0-owned exceptions are neither expanded nor reinterpreted here; each remains subject to the current canonical surface, authorization, and single-writer rules.
- [x] D-15: Runtime evidence records `declared_model`, `observed_active_model`, `active_model_state`, attestor/source, TODO/session/surface/action binding, and expiry. `active_model_state` is exactly `exact|stronger|weaker|lateral|unknown|unavailable`; declared routing is never upgraded into observed proof.
- [x] D-16: Every non-`exact` active-model state starts blocked. A user-confirmed scoped continuation plus successful rerun may produce `go` with `continuation_status=user_confirmed`, remains explicitly unverified when applicable, and never changes routing/provider authority. Provider health/selection has no continuation path.
- [x] D-17: Production resolution uses the canonical contract path only. An alternate contract path is allowed solely as explicit fixture/test injection and is rejected from the operational workflow.
- [x] D-18: A review kind carries canonical allowed-surface and allowed-role bindings; `implementation_diff_review` is valid only for `surface=formal-review` and `role=formal-reviewer`.
- [x] D-19: `audit-protocol-triple-review` is a required delivery-side additive protocol. Canonical-path retirement requires a distinct required cutover-integrity gate; neither replaces critique, implementation-diff review, test-quality audit, or final review.

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
- **Baseline commit:** `4f4ace9`
- **Baseline push reference:** `origin/v0.6.2-rc`
- **Gate status:** no_material_findings
- **Findings summary:** `4f4ace9` is the committed, pushed reconciled package for pre-prerequisite critique only. It is invalid for the formal gate once P0/P1 close or their canonical contract changes.
- **Evidence / reference:** `origin/v0.6.2-rc` push of `4f4ace9` on 2026-09-27.
- **Mandatory refresh condition:** after P0 closeout and P1 closeout are each committed/pushed, capture and push a new baseline before formal plan review, architecture decision review, or critique.
- **Waiver authority / reference (required if waived):** n/a

## Gate: Review Scope Drift

- **Gate decision:** required
- **Why this decision:** Review changes must not silently alter scope, validation semantics, ownership, or the no-fallback contract.
- **Trigger stage:** after the planning-side review/guard cycle converges and before APROVADO
- **Baseline source:** Review Baseline Freeze -> Baseline commit
- **Material sections compared:** Context|Contract Boundary|Scope|Out of Scope|Definition of Done|Validation Steps|Execution Lane Tracking|Canonical Module Anchors|Decisions|Decision Baseline|Architecture Change Governance|Assumptions Preview|Execution Plan|Flow Evidence Planning Matrix|Local CI-Equivalent Suite Matrix
- **Guard command:** `python3 tools/review_scope_drift_guard.py --todo foundation_documentation/todos/active/delphi-cross-stack-todo-agent-orchestration-contract.md`
- **No-go handling rule:** return to the review loop, revalidate material evolution with the user, refresh the pushed baseline when needed, and rerun affected gates.
- **Gate status:** blocked
- **Findings summary:** 2026-09-27 guard found material drift in Scope, Out of Scope, Definition of Done, Validation Steps, Decisions, Assumptions, Execution Plan, and PCV. The user authorized this bounded correction loop; formal revalidation remains blocked until P0/P1 close and a new baseline is pushed.
- **Evidence / reference:** `python3 tools/review_scope_drift_guard.py --todo foundation_documentation/todos/active/delphi-cross-stack-todo-agent-orchestration-contract.md` -> `REVIEW-SCOPE-DRIFT-MATERIAL-CHANGE` against the superseded `bf67507`; final pre-prerequisite review uses `4f4ace9`.
- **Waiver authority / reference (required if waived):** n/a

## Assumptions Preview

| Assumption | Evidence | If False | Handling |
| --- | --- | --- | --- |
| Existing routing guard can extend instead of be replaced. | It already resolves client/surface/role/model/effort. | Do not create a second selector. | block |
| P0/P1 can close before P2. | Active ownership is explicit. | Keep TODO blocked and re-sequence. | block |
| Project authority can provide provider declaration path at intake. | User chose explicit selection rather than default. | Guard blocks and requests scoped selection. | keep |
| Platform may lack active-model telemetry. | Current guard accepts declared selection, not telemetry. | A human may explicitly accept a scoped unverified continuation; it is never represented as observed proof. | keep |

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
2. Intake resolves surface, role, model family, provider, capabilities, precedence, and `fallback_policy`; its only V1 value is `prohibited`. User confirms the map.
3. Model and provider admission are independent. A non-`exact` active-model state is blocked until a scoped user continuation passes guard rerun; an absent, invalid, unhealthy, wrong-workspace, or wrong-revision provider remains blocked until an explicitly selected provider validates independently. No human model continuation unlocks a provider.
4. Routine executor is the sole normal writer. Orchestrator waits with collaboration.wait_agent timeout_ms 240000; timeout is a wait window, not failure.
5. At checkpoint, collect selected-provider static evidence. Bridge mode requires stable full-workspace live Problems.
6. Errors, warnings, or new attributable diagnostics return to executor.
7. With clean Problems, executor runs every declared focused-test command as one non-fail-fast matrix. Each row records command, exit, duration, evidence/output, and product/environment classification. Cleanup is protected.
8. Any non-green, missing, skipped, or unclassifiable row is non-green. Executor may make one bounded contract-preserving repair batch, then returns to step 5.
9. Only clean Problems plus green complete matrix dispatches fresh no-context implementation_diff_review through canonical `surface=formal-review` and `role=formal-reviewer`.
10. Reviewer checks frozen diff scope, architecture, contract integrity, and attached test evidence; emits request_changes or approve_green_diff.
11. Request changes returns to step 5. Approval proceeds only to remaining delivery gates and never replaces final delivery review.
12. Extra audit is only for explicit security, data integrity, concurrency, public-contract, or user-request risk.

### Runtime-Model Evidence State Machine

| Evidence state | Initial outcome | User-facing explanation | Valid continuation result after scoped record + guard rerun |
| --- | --- | --- | --- |
| `exact` | `go` | Observed active model is the canonical model or a declared canonical equivalence. | n/a |
| `stronger` | `blocked` | Recommended model is available through a stronger actual model; request explicit token-cost acceptance. | `go` with `continuation_status=user_confirmed` |
| `weaker` | `blocked` | Actual model is weaker than the recommendation; request explicit quality acceptance. | `go` with `continuation_status=user_confirmed` |
| `lateral` | `blocked` | Actual model is neither canonically equivalent nor ordered relative to the recommendation. | `go` with user-specific continuation reason; otherwise remain blocked. |
| `unknown` or `unavailable` | `blocked` | The active runtime model could not be determined; identify the recommended model and request the user's continuation decision. | `go` with an explicitly unverified user-confirmed continuation, or remain blocked. |

The record binds TODO, session, surface, action, canonical recommendation, observed/declaration values, decision, reason, attestor/source, and expiry. The guard rejects expired, mismatched, incomplete, or cross-scope records. No state selects another model or provider automatically.

### Deterministic Tool Boundaries

| Tool / surface | Responsibility | Must not do |
| --- | --- | --- |
| routing guard | resolve canonical surface/role/family/review binding; compare declared versus observed identity/evidence/tier; validate continuation | invent runtime proof, accept an operational alternate contract path, or maintain a second authority |
| provider guard | validate explicit declaration/selection, command or bridge health/workspace/stability | analyze source or fall back |
| review schema/dispatch | validate post-green decision/matrix binding plus canonical allowed surface/role; resolve review family | approve untested/wrong-surface diff or replace final review |
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
- [ ] P1 is observed as `implementation` while P0 is still `review`: this TODO cannot mutate P1; its owner must re-sequence/approve P1 before P2 may start.
- [ ] Runtime model evidence or the explicitly selected provider is absent, invalid, unstable, or mismatched: return `blocked`; require the scoped user record and a successful rerun, never fallback.
- [ ] Problems is non-clean, a matrix row is non-green/missing/skipped/unclassifiable, or review requests changes: return the work to the routine executor and restart the cycle from Problems.
- [ ] A review proposes a generic coordinator, queue, retry, new abstraction, writer bypass, or scope expansion: challenge it against the frozen TODO and require renewed approval if it is not indispensable.

### Residual Unknowns / Risks

- [ ] P0/P1 timing and their final schema/taxonomy are external prerequisites; this TODO must be re-reviewed against their closed state before approval.
- [ ] The downstream project provider-declaration location and bridge installation authority are intentionally not invented in V1; P4 remains separately authorized.
- [ ] Platform evidence may not attest the active runtime model; it remains blocked until a bounded user continuation is accepted by the guard rerun, and then remains labelled unverified rather than proved.

## Independent No-Context Critique Gate

- **Critique decision:** required
- **Why this decision:** The guard derives the expanded critique floor from big, cross-module, behavior-defining, canonical-contract, and test-touching scope.
- **Impact signals in scope:** cross-module blast radius|public contract/schema/api
- **Package mode:** bounded-file-set
- **Package minimum contents:** frozen baseline|approved scope boundary|assumptions preview|execution plan summary|issue cards|residual risks|existing blockers
- **Critique isolation mode:** fresh internal no-context reviewer
- **Internal reviewer mandate:** required; the reviewer is not the implementing agent, waits are status-based, and an external provider does not satisfy this gate.
- **Canonical multi-lane audit protocol:** `audit-protocol-triple-review` is required at delivery and additive; it never substitutes for this critique.
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
- **Derived performance/concurrency decision:** recommended (from the 2026-09-27 post-critique audit guard); this pre-APROVADO package resolves the four planned no-surface classifications before approval, and any contrary discovery is material scope drift requiring renewed approval.

| Lane ID | Lane | Trigger Result | Trigger Severity | Trigger Reason Code | Trigger Rationale | Gate Deadline | Minimum Evidence Rule | State | Residual Risk | Uncertainty Reason Code | Recorded At (UTC) | Executor ID |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `EPS` | `endpoint-performance-scrutiny` | `not_needed` | `low` | `EPS-DATA-PATH-CHANGED` | Planned V1 changes no read, query, endpoint, or data-access path. | `before_local_implemented` | `n/a` | `not_applicable` | none | none | `2026-09-27T11:47:03Z` | `not_applicable` |
| `FRC` | `frontend-race-condition-validation` | `not_needed` | `low` | `FRC-LIFECYCLE-ASYNC-EFFECT` | Planned V1 changes no retriggerable or lifecycle-sensitive UI async surface. | `before_local_implemented` | `n/a` | `not_applicable` | none | none | `2026-09-27T11:47:03Z` | `not_applicable` |
| `BCI` | `backend-concurrency-idempotency-validation` | `not_needed` | `low` | `BCI-NON-IDEMPOTENT-WRITE` | Planned V1 changes no backend write, invariant, job, webhook, or overlapping mutation surface. | `before_local_implemented` | `n/a` | `not_applicable` | none | none | `2026-09-27T11:47:03Z` | `not_applicable` |
| `RLS` | `runtime-load-stress-validation` | `not_needed` | `low` | `RLS-QUEUE-WORKER-REALTIME-CHANGED` | Planned V1 changes no runtime-pressure, queue, worker, realtime, batch, cache, index, or SLO surface. | `before_production_ready` | `n/a` | `not_applicable` | none | none | `2026-09-27T11:47:03Z` | `not_applicable` |

The global `recommended` audit floor was resolved by this documented four-lane classification. These terminal no-surface rows are not runtime evidence. No lane may be reclassified after APROVADO: any discovery that P2/P3 touches a corresponding surface is material scope drift, requires renewed user approval, and must be classified before that changed scope executes.

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
- **Canonical multi-lane audit protocol:** `audit-protocol-triple-review` is required and additive at delivery; it cannot replace this final review.
- **Final review status:** not_run
- **Findings summary:** no implementation exists
- **Evidence / reference:** delivery-stage gate after validation, test-quality audit, verification-debt audit, and architecture-adherence review

## Independent Cutover Integrity Audit Gate

- **Cutover audit decision:** required
- **Why this decision:** V1 retires conflicting provider/fallback wording and makes one JSON-backed canonical selection path authoritative.
- **Cutover signals in scope:** canonical cutover|legacy-path retirement|fallback bridge
- **Package mode:** bounded-file-set
- **Canonical multi-lane audit protocol:** `audit-protocol-triple-review` (additive delivery-side evidence)
- **Audit focus:** true canonical path|approved temporary exception scope|removal criteria|hidden fallback mirrors|pseudo-canonical fields
- **Cutover audit status:** not_run
- **Findings summary:** no implementation exists
- **Evidence / reference:** delivery-stage gate after P2/P3; inspect consumers, obsolete bridge/CLI wording, and migration/compatibility artifacts for a second authority or implicit fallback.
- **Waiver authority / reference (required if waived):** n/a

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

The post-green review order is material and requires a fresh review after the post-P0/P1 baseline refresh/freeze and before APROVADO.

## Pre-Prerequisite Critique Record (Non-Gate-Satisfying)

- **Date / mode:** 2026-09-27; fresh internal no-context, read-only bounded-file-set review selected through the current routing JSON formal-review family.
- **Baseline assessed:** substantive package `bf67507`; `49b23e3` only records its freeze metadata.
- **Gate limitation:** This is pre-prerequisite challenge evidence only. It does not satisfy the required plan review, architecture decision review, or critique after P0/P1 close and a new baseline is pushed.
- **Summary:** P0/P1 ownership/taxonomy remains externally blocked. The review integrated deterministic state, authority, review-binding, audit, PCV, baseline-refresh, and wording corrections into this TODO.
- **Performance:** acceptable and product-runtime neutral; local guard/resolver overhead is bounded.
- **Elegance:** one authority, thin consumers, fail-closed provider selection, and no V1 writer exception remain the simplest coherent path.
- **Structural soundness:** blocked until P0/P1 resolve ownership/taxonomy and the refreshed formal gates reconverge; no generic coordinator or hidden fallback is introduced.

### Plan Review Issue Cards

#### PR-01 — P0/P1 ownership and taxonomy are not yet serially coherent

- **Evidence:** P0 remains in `review` with the bootstrap exception (`delphi-pre-execution-agent-routing-guard.md`); P1 is currently `implementation` and mixes scenario, role, and model-family vocabulary (`delphi-platform-scenario-settings-routing-contract.md`).
- **Option A:** Edit P1 from this TODO. Effort: low; risk/blast radius: high/cross-module; elegance/structural soundness: regresses by violating separate-owner discipline.
- **Option B (recommended):** Keep this TODO blocked; require P0 closeout, then P1 owner re-sequences, freezes taxonomy as surface -> role -> model family, and closes P1 before P2. Effort: medium; risk: low; performance: neutral; elegance/structural soundness: improves.
- **Option C:** Start P2 around the unresolved owners. Effort: low initially; risk/maintenance burden: high; performance: neutral; elegance/structural soundness: regresses through overlapping authority.
- **Resolution:** Integrated Option B. No user decision is reopened; ownership is external and must be true before APROVADO.

#### PR-02 — Active runtime-model evidence needs a deterministic continuation state

- **Evidence:** Current guard accepts declared values but lacks observed-model fields; the user required a blocked result that presents the recommended model and lets the user decide whether to continue.
- **Option A:** Treat declared routing as active proof. Effort: low; risk: high; elegance/structural soundness: regresses by fabricating evidence.
- **Option B (recommended):** Keep non-exact/unknown evidence blocked; accept only a user-bound, expiring continuation record through a guard rerun, explicitly retaining the verified/unverified distinction. Effort: medium; risk: bounded; performance: neutral; elegance/structural soundness: improves.
- **Option C:** Keep unknown evidence permanently blocked. Effort: low; risk: low; operational fit: regresses against the user-approved continuation decision.
- **Resolution:** Integrated Option B as D-15/D-16 and the runtime-model state machine.

#### PR-03 — JSON authority must cover all operational selection and review bindings

- **Evidence:** Existing guard surfaces/roles and review compatibility include code-level policy; arbitrary operational contract substitution would create a second authority.
- **Option A:** Retain hardcoded catalogs and optional contract substitution. Effort: low; risk: high; elegance/structural soundness: regresses.
- **Option B (recommended):** Canonicalize surface traits, role catalog, family and review bindings in JSON; permit alternate path only as explicit test injection. Effort: medium; performance: neutral; elegance/structural soundness: improves.
- **Option C:** Add another resolver/configuration layer. Effort/risk/maintenance: high; scope expansion prohibited.
- **Resolution:** Integrated Option B as D-17/D-18 and validation fixtures.

#### PR-04 — Audit assertions need a real TEACH record and complete PCV shape

- **Evidence:** Audit decisions must come from the trigger matrix; PCV-1 requires independent EPS/FRC/BCI/RLS disposition rows.
- **Option A:** Leave prose-only derived claims. Effort: low; risk: medium; structural soundness: regresses.
- **Option B (recommended):** Record the executed TEACH result, re-run after material trigger changes, include four `not_needed`/`not_applicable` lanes, and demand exact P2/P3 commands before APROVADO. Effort: low; performance: neutral; structural soundness: improves.
- **Option C:** Run delivery audits during planning. Effort: high; invalid lifecycle placement.
- **Resolution:** Integrated Option B; the next guard run below supersedes the pre-review fingerprint.

## Reconciled Pre-Prerequisite Critique Record (Non-Gate-Satisfying)

- **Date / mode:** 2026-09-27; second fresh internal no-context, read-only bounded-file-set review selected through the current routing JSON formal-review family.
- **Baseline assessed:** substantive corrected package `c95cb9d`; `5fbe7f8` only refreshes its freeze reference.
- **Result:** the external P0/P1 blockers remain; all seven internal findings were integrated as `RC-01` through `RC-07` below.
- **Gate limitation:** This reconciliation is still not the mandatory formal review/critique after P0/P1 close and a new baseline is pushed.
- **Performance / elegance / structural soundness:** local overhead remains bounded; authority and provider/model paths are less ambiguous; structural readiness remains blocked solely by P0/P1 and the future formal gates.

## Promotion Finding Routing Ledger

| Finding ID | Finding Source | Severity | Classification | Required Action | Status | Rationale / Follow-up Reference |
| --- | --- | --- | --- | --- | --- | --- |
| `PC-01` | internal no-context pre-prerequisite critique | blocker | release-blocker | external P1 owner re-sequences its state after P0 closeout | blocked | This TODO cannot edit a separate active owner; P2 remains blocked by PR-01. |
| `PC-02` | internal no-context pre-prerequisite critique | blocker | release-blocker | P1 owner separates surface, role, and model-family taxonomy before closeout | blocked | Required by this TODO's contract boundary and PR-01. |
| `PC-03` | internal no-context pre-prerequisite critique | blocker | by-design/no-action | clarify V1 writer boundary only | fixed | D-14 preserves, but does not expand or re-interpret, current P0-owned exceptions; V1 creates no new bypass. |
| `PC-04` | internal no-context pre-prerequisite critique | blocker | release-blocker | add state machine and continuation binding | fixed | D-15/D-16 and Runtime-Model Evidence State Machine; implementation still needs fixtures. |
| `PC-05` | internal no-context pre-prerequisite critique | blocker | release-blocker | close canonical-authority bypasses in P2 fixtures/guard | fixed | D-17, scope, DoD, and validation now require data-driven operational resolution. |
| `PC-06` | internal no-context pre-prerequisite critique | blocker | release-blocker | bind `implementation_diff_review` to canonical formal-review surface/role | fixed | D-18 and wrong-surface/wrong-role fixtures are required. |
| `PC-07` | internal no-context pre-prerequisite critique | blocker | release-blocker | record and rerun audit TEACH after material triggers | fixed | Matrix reflects risk signals; rerun is required after P0/P1 as part of the new formal baseline. |
| `PC-08` | internal no-context pre-prerequisite critique | blocker | release-blocker | complete four PCV-1 lanes | fixed | EPS/FRC/BCI/RLS are closed pre-APROVADO classifications; scope drift, not post-approval reclassification, handles a new runtime surface. |
| `PC-09` | internal no-context pre-prerequisite critique | blocker | release-blocker | make post-P0/P1 baseline refresh mandatory | fixed | Review Baseline Freeze now limits `bf67507` to pre-prerequisite review. |
| `PC-10` | internal no-context pre-prerequisite critique | minor | release-blocker | replace ambiguous fallback wording | fixed | V1 uses `fallback_policy=prohibited`; alternate provider requires user selection and rerun. |
| `PC-11` | internal no-context pre-prerequisite critique | minor | release-blocker | replace planned test placeholders before APROVADO | fixed | Local CI matrix names exact P2/P3 scripts and behavior oracles; P0/P1 block their implementation, not their planning. |
| `RC-01` | second internal no-context pre-prerequisite critique | high | release-blocker | separate model continuation from provider admission | fixed | D-16, V1 step 3, and provider fixtures now prohibit a human model continuation from unlocking a provider. |
| `RC-02` | second internal no-context pre-prerequisite critique | high | release-blocker | close PCV-1 plan before APROVADO | fixed | Four terminal no-surface rows now include rationale, date, and executor applicability; new exposure is material scope drift requiring renewed approval. |
| `RC-03` | second internal no-context pre-prerequisite critique | high | release-blocker | align triple trigger and add cutover audit | fixed | Trigger is `yes`; triple protocol and cutover-integrity gate are required/additive delivery-side gates. |
| `RC-04` | second internal no-context pre-prerequisite critique | high | release-blocker | close implementation-diff-review role binding | fixed | D-18 and runtime cycle require `formal-review` plus `formal-reviewer`; fixtures reject other combinations. |
| `RC-05` | second internal no-context pre-prerequisite critique | medium | release-blocker | use one active-model-state enum | fixed | D-15, D-16, matrix, table, and fixtures use exactly `exact|stronger|weaker|lateral|unknown|unavailable`. |
| `RC-06` | second internal no-context pre-prerequisite critique | medium | release-blocker | name exact P2/P3 test scripts and oracles | fixed | Local CI matrix now names provider, review dispatch, and focused matrix scripts; their declared behavior is the required oracle. |
| `RC-07` | second internal no-context pre-prerequisite critique | low | follow-up-fast-follow | normalize noncanonical ledger statuses | fixed | PC-07/PC-08 now use canonical `fixed`; remaining future rerun is in rationale. |
| `FR-01` | final internal pre-prerequisite plan review | high | release-blocker | resolve immutable PCV-1 no-surface representation | blocked | `pcv-1` has no canonical no-surface trigger/evidence values; choosing between a versioned policy evolution or a separately owned prerequisite is a material scope decision. |
| `FR-02` | final internal pre-prerequisite plan review | medium | release-blocker | replace residual command placeholders | fixed | Commands section now repeats the exact Local CI-Equivalent script paths. |
| `FR-03` | final internal pre-prerequisite plan review | medium | release-blocker | correct review/freeze order wording | fixed | Consolidated record now requires refresh/freeze before the fresh review. |
| `FR-04` | final internal pre-prerequisite plan review | low | follow-up-fast-follow | correct count and closeout wording | fixed | Reconciled record says seven findings; closeout names the real next action. |

## TODO Closeout Disposition

- **Disposition:** blocked
- **Disposition reason:** P0 must close and retire bootstrap; P1 must then stabilize its own state/taxonomy and close. The final review baseline and gates must be refreshed afterward. Before any delivery gate, resolve FR-01 without inventing a noncanonical PCV-1 value.
- **Post-commit/push status:** pending the final plan-review corrections.
- **Next path/status action:** publish these corrections; obtain the user's scope decision for FR-01; then await P0/P1 rather than start P2.

## Commands (Run Locally)

- bash tools/tests/agent_role_routing_guard_test.sh
- bash tools/tests/static_analysis_provider_guard_test.sh
- bash tools/tests/review_dispatch_guard_test.sh
- bash tools/tests/focused_test_matrix_guard_test.sh
- bash self_check.sh
- git diff --check
- python3 tools/todo_deterministic_validator.py --todo foundation_documentation/todos/active/delphi-cross-stack-todo-agent-orchestration-contract.md
