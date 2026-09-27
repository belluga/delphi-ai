# TODO: Delphi Cross-Stack TODO Agent-Orchestration Contract

## Artifact Identity

- **Artifact type:** tactical_execution_contract
- **Origin:** Consolidated from the temporary self-improvement ledger on 2026-09-27.
- **Authority rule:** config/agent_role_routing.json remains the sole role/model routing authority.

## Context

Delphi has role/model routing and a pre-execution guard. This bounded P2 package adds an explicitly invoked Codex skill and two deterministic helpers for a small, user-directed micro-adjustment while preserving the existing execution boundaries.

The package reduces discretion without creating a generic coordinator. It preserves Architecture Simplification First, the principal checkout, one normal material writer, exact-TODO scope, and existing AGENTS/profile/authorization rules.

## Framing Source & Story Slice

- **Feature brief:** direct-to-todo
- **Primary story ID:** n/a
- **Why this is the right current slice:** The user requested a directly invoked Codex executor skill with deterministic role/model resolution and TEACH assessment of bounded micro-adjustment criteria.
- **Direct-to-TODO rationale:** This is Delphi self-maintenance. It changes process/tooling, not a downstream product feature.

## Contract Boundary

- The TODO defines the reusable Delphi method. It does not authorize a downstream application TODO by itself.
- The method consumes the routing JSON and never copies a role-to-model routing matrix into workflow, skill, guard code, or prose. A dated per-action resolver result is execution evidence only, never an alternate authority, and must be refreshed before dispatch.
- Raw execution payloads (Problems snapshots, test stdout/stderr, review payloads, and provider usage reports) stay only under the profile-directed ignored temporary artifact root: `foundation_documentation/artifacts/tmp/todo-execution/<todo-id>/<session-id>/` for downstream TODOs, or `delphi-ai/artifacts/tmp/todo-execution/<todo-id>/<session-id>/` for Delphi self-maintenance. They are never staged or tracked.
- The tracked TODO is the durable execution summary: it records only decision-relevant command/result metadata, findings, classifications, and provider-reported token totals accumulated by canonical tier. It never embeds raw logs, full payloads, inferred token counts, inferred cost, or a second telemetry authority.
- The contract uses three distinct terms:
  - **surface:** implementation, implementation-validation, monitoring, formal-review, delivery-review, or another JSON-defined surface;
  - **execution role:** primary-chat, routine-executor, formal-reviewer, process-monitor, or deterministic-only;
  - **model family:** chat_orchestrator, routine_executor, monitoring, strongest_review, or another JSON-defined family.
- The V1 package is Delphi-only. A project-local provider declaration and bridge plugin setup are separately authorized downstream work.

## Implementation Intent

- **Current delivery:** Create one explicitly invoked Codex skill plus deterministic helpers that consume the existing routing JSON.
- **Planned next steps:** Validate the skill/helpers and retain broader provider/review orchestration for a separately authorized future TODO.
- **Anticipatory implementation authorized now:** none
- **Rationale:** This package consumes existing authority and does not migrate the routing schema, add runtime introspection, or create a writer bypass.

## Delivery Status Canon (Required)

- **Current delivery stage:** Pending
- **Qualifiers:** none
- **Next exact step:** implement and validate the explicitly invoked skill and two deterministic helpers.

## Active Work State (Required While TODO Remains In active)

- **Work state:** implementation
- **Why this state now:** The bounded P2 package is authorized directly against the existing JSON authority; no P0/P1 or schema cutover prerequisite is required.
- **Exit condition:** The skill, helpers, focused tests, and deterministic evidence are complete without changing the existing routing contract.

## Execution Boundary Clarification

- **Prerequisites:** none beyond the existing `config/agent_role_routing.json` and this exact TODO.
- **Explicit invocation:** the Codex skill is never selected automatically; invoke it by name for this bounded micro-adjustment.
- **Authority:** existing JSON remains the sole role/model source; helpers may resolve and report, never mutate or replace it.

## Execution Lane Tracking (Required)

- **Local implementation branches:** delphi-ai:v0.6.2-rc
- **Promotion lane path:** resolve at implementation time through the applicable lane.
- **Lane-promoted threshold for this TODO:** pending
- **Production-ready threshold for this TODO:** pending

## Scope

- [ ] Add a concise, explicitly invoked Codex skill for the bounded micro-adjustment flow.
- [ ] Add a deterministic helper that resolves the selected role/model/effort from the existing JSON for a declared surface and client.
- [ ] Add a deterministic TEACH helper that assesses only the bounded micro-adjustment criteria and returns a blocking or admissible result.
- [ ] Add focused tests proving JSON authority, no provider fallback, executor-only normal writing, and bounded criteria enforcement.
- [ ] Record only compact TODO summaries and provider-reported token totals; keep raw artifacts in the ignored temporary root.

## Out of Scope

- [ ] A second routing authority or hardcoded surface/role/model/review matrix.
- [ ] Automatic dispatch, automatic subagent spawning, automatic waiver approval, or fabricated runtime proof.
- [ ] Routing-schema migration, platform/scenario cutover, or changes to the existing global guard/advisor/workflows.
- [ ] Runtime model introspection, provider switching, provider health bridges, or automatic provider fallback.
- [ ] Local orchestrator code writing in V1, including unused-import removal.
- [ ] Generic queue, retry engine, coordinator, patch executor, multi-writer topology, or accounting platform.
- [ ] Downstream project provider declaration/plugin installation/product implementation.
- [ ] Implicit CLI fallback, historical-SHA assignment, automatic delivery, or automatic promotion.
- [ ] A global `pcv-1` schema/policy change; PCV product/runtime lanes are not applicable to this Delphi self-maintenance TODO.

## Diff Expectation Contract

- **Contract status:** required
- **Policy:** strict; only the bounded P2 skill/helper package may change
- **User validation:** required on deviation
- **Comparison mode:** working_tree

### Repository Baselines

| Repository | Path | Baseline ref | Comparison mode |
| --- | --- | --- | --- |
| delphi-ai | . | v0.6.2-rc@634b546 | working_tree |

### Expected Changed Paths

| Repository | Path glob | Change types | Reason |
| --- | --- | --- | --- |
| delphi-ai | foundation_documentation/todos/active/delphi-cross-stack-todo-agent-orchestration-contract.md | any | This P2 TODO contract and bounded evidence. |
| delphi-ai | skills/codex-micro-adjustment-executor/** | any | Explicitly invoked P2 skill package. |
| delphi-ai | tools/codex_micro_adjustment_routing.py | any | Deterministic JSON-authority resolver. |
| delphi-ai | tools/codex_micro_adjustment_teach.py | any | Deterministic bounded-adjustment TEACH gate. |
| delphi-ai | tools/tests/codex_micro_adjustment_executor_test.sh | any | Focused P2 helper/skill regression fixtures. |

### Not Expected Changed Paths

| Repository | Path glob | Change types | Reason |
| --- | --- | --- | --- |
| delphi-ai | foundation_documentation/todos/active/delphi-platform-scenario-settings-routing-contract.md | any | P1 is out of scope. |
| delphi-ai | config/agent_role_routing.json | any | Existing JSON authority is unchanged. |
| delphi-ai | tools/agent_role_routing_guard.py | any | P0/global routing guard is unchanged. |
| delphi-ai | tools/effort_selection_advisor.py | any | P1/global advisor is unchanged. |
| delphi-ai | tools/todo_authority_guard.py | any | Global TODO guard is unchanged. |
| delphi-ai | tools/todo_completion_guard.py | any | Global TODO guard is unchanged. |
| delphi-ai | tools/todo_deterministic_validator.py | any | Global TODO validator is unchanged. |
| delphi-ai | tools/review_scope_drift_guard.py | any | Global scope guard is unchanged. |
| delphi-ai | tools/assumption_code_coherence_guard.py | any | Global coherence guard is unchanged. |
| delphi-ai | tools/tests/agent_role_routing_guard_test.sh | any | P0 test is unchanged. |
| delphi-ai | tools/tests/effort_selection_advisor_test.sh | any | P1 test is unchanged. |
| delphi-ai | workflows/** | any | Existing workflows are unchanged. |
| delphi-ai | downstream/** | any | Downstream work is out of scope. |

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
- [ ] Raw Problems/test/review/usage payloads are written only to the ignored temporary artifact root; the TODO retains the bounded result summary required to interpret a gate and nothing more.
- [ ] Each completed governed LLM action updates the exact TODO's cumulative provider-reported token total for its JSON-resolved tier; an unavailable provider report remains `unavailable`, never an estimate or zero.
- [ ] Exact tests, self-check/mirrors, TODO/diff gates, fresh final review, and delivery evidence are complete before any delivery claim.

## Validation Steps

- [ ] Routing fixtures: declared versus observed model; active-model states `exact|stronger|weaker|lateral|unknown|unavailable`; scoped continuation/expiry; prohibited automatic transition; and no hardcoded surface/role/family/review or contract-path drift.
- [ ] Provider fixtures: absent/invalid declaration, exact CLI command, missing CLI command, healthy bridge, bridge health/workspace/revision failure, explicit provider switch, prohibited fallback, and human-model continuation cannot unlock a provider.
- [ ] Review fixtures: request_changes, approve_green_diff, green matrix binding, missing/non-green rejection, invalid payload, wrong-surface/wrong-role rejection, and final-review/critique separation.
- [ ] Focused-matrix fixtures: continue after failure; row completeness; cleanup; missing/skipped/unclassifiable equals non-green; repair resets Problems plus full matrix.
- [ ] Observability fixtures: platform usage preserved when available and unavailable when absent; data cannot alter routing/gates.
- [ ] Evidence-ledger fixtures: raw Problems/test/review/usage payloads remain under the ignored temporary root; TODO summaries omit raw output and token totals aggregate only provider-reported values by JSON-resolved tier.
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
- **Latest TEACH evidence / artifact:** 2026-09-27 `audit_escalation_guard.py` -> `Overall outcome: go`; Delphi self-maintenance fingerprint `e7b8e59cd3e2`.

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
| `release_or_promotion_critical` | `no` | This is Delphi self-maintenance planning, not a downstream product release or promotion package. |
| `high_severity_plan_review_issue` | `no` | The internal critique findings are integrated; P0/P1 are external prerequisites, not a runtime/product audit trigger for this TODO. |
| `explicit_three_lane_request` | `no` | The user requested independent review loops, not the dedicated delivery-side three-lane protocol. |

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
- [x] D-19: `audit-protocol-triple-review` is optional/recommended only when the audit floor requests it. Canonical-path retirement still requires a distinct required cutover-integrity gate; neither replaces critique, implementation-diff review, test-quality audit, or final review.
- [x] D-20: Delphi self-maintenance is not a PCV product/runtime lane. Its `PCV-NOT-TRIGGERED` result does not alter the global `pcv-1` policy and any separately authorized downstream/product TODO evaluates PCV under its own scope.
- [x] D-21: Raw Problems, test, review, and provider-usage payloads are transient ignored artifacts. The tracked TODO stores only gate-relevant summary facts, never raw output or a competing telemetry record.
- [x] D-22: Provider-reported token totals are accumulated in the exact TODO by canonical JSON-resolved tier. Missing usage is `unavailable`; neither tokens nor cost may be estimated or influence routing/gates.

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

- **Applicability (`required|not_needed`):** required
- **Why this applies:** V1 corrects the architecture of execution authority: discretionary role/provider choice and untested-diff review must become a single JSON-backed, fail-closed lifecycle.
- **Deviation / debt being retired:** Discretionary role/provider selection, ambiguous test/review order, implicit provider fallback, review of untested diffs, and durable raw-output artifacts outside the TODO summary.
- **Target steady-state after closeout:** One routing authority; explicit selections/exceptions; executor-owned green matrix; ignored raw execution payloads plus compact TODO evidence; per-tier provider-reported token totals; post-green independent review; normal single writer.
- **Temporary exceptions allowed:** none in V1
- **Cutover / removal condition:** JSON, guards, workflow, skill, templates, and mirrors agree; obsolete conflicting provider wording and tracked raw execution-output paths are retired.

### Patterns To Enforce

| Pattern / Decision | Source / ID | Scope | Why It Must Hold After Cutover |
| --- | --- | --- | --- |
| JSON-backed role, model-family, review, and tier resolution | D-01, D-15, D-17, D-18 | routing and review admission | Consumers must not create a second selection matrix or infer a routing tier. |
| Fail-closed provider and active-model admission | D-05, D-06, D-16 | execution intake | Missing proof or provider health must stop rather than silently downgrade quality or analysis. |
| Raw-temporary, summary-tracked evidence | D-12 and Execution Artifact & Token Ledger | Problems, test, review, and usage evidence | Reproducible gate facts and token totals remain in the TODO without tracking verbose or sensitive transient payloads. |
| Green matrix before independent diff review | D-08, D-09, D-10 | implementation validation | A reviewer must assess a tested diff, and a requested change must restart the full quality cycle. |

### Prohibited Anti-Patterns

| Anti-Pattern / Wrong Path | Detection Signal | Why It Is Forbidden After Cutover | Exception Policy |
| --- | --- | --- | --- |
| hardcoded role/model/tier matrix | values or tier policy outside canonical JSON contract | It recreates a competing selection authority. | none |
| automatic provider fallback | provider changes without explicit user selection and rerun | It hides unavailable/invalid static evidence. | none |
| pre-green diff review | missing clean Problems or full green matrix evidence | It asks independent review to validate an untested diff. | none |
| test weakening for green | changed expectation, fixture, or harness outside frozen contract | It converts a regression into a passing signal. | renewed approval only |
| tracked raw execution output or usage payload | artifact path outside ignored temporary root or raw payload copied into TODO | It creates noisy, durable pseudo-evidence and competing telemetry. | none |
| local orchestrator implementation or generic coordinator | V1 diff grants writer bypass or expands into queue/retry/telemetry framework | It violates single-writer scope and Architecture Simplification First. | renewed approval only |

### Architecture Protection Harness

| Harness Type | Surface | Command / Rule / Artifact | Regression It Must Catch | Adoption Timing (`already-enforced|implement-in-this-todo|follow-up-approved|manual-only-with-rationale`) | Evidence Plan / Follow-up |
| --- | --- | --- | --- | --- | --- |
| structural approval guard | TODO contract | `tools/todo_authority_guard.py --pre-approval` | missing canonical routing, rules ingestion, architecture fields, or implementation readiness | already-enforced | P1.5 requires `preflight-go` before APROVADO. |
| routing-contract fixture suite | role/model/tier admission | `bash tools/tests/agent_role_routing_guard_test.sh` | hardcoded or mismatched routing, invalid continuation, and second authority | implement-in-this-todo | Local CI matrix row and validation fixture requirement. |
| provider/review fixture suites | provider and post-green review gates | `bash tools/tests/static_analysis_provider_guard_test.sh`; `bash tools/tests/review_dispatch_guard_test.sh` | implicit fallback, wrong provider evidence, wrong review surface/role, or review before green matrix | implement-in-this-todo | Local CI matrix rows and required implementation fixtures. |
| execution-evidence lifecycle rule | transient raw artifacts and tracked TODO summary | Execution Artifact & Token Ledger plus focused-matrix/evidence-ledger fixtures | raw output tracked outside temporary root, missing bounded summary, inferred token/cost, or non-aggregated tier totals | implement-in-this-todo | Definition of Done and Validation Steps require fixture coverage and final TODO evidence. |

## Architecture Review Gates

- **Architecture decision review:** required
- **Architecture decision review source:** `audit_escalation_guard.py`
- **Decision review lifecycle:** after P0/P1 are closed and before APROVADO
- **Decision review kind:** `architecture_opinion`
- **Decision review package:** bounded-file-set
- **Decision review status:** not_run
- **Decision review evidence / resolution:** pending P0/P1 closure and fresh freeze-backed review
- **Architecture adherence review:** required
- **Architecture adherence review source:** `audit_escalation_guard.py`
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
- **Baseline commit:** `7e0eee4`
- **Baseline push reference:** `origin/v0.6.2-rc`
- **Gate status:** no_material_findings
- **Findings summary:** `7e0eee4` is the committed, pushed Delphi-scoped package for pre-prerequisite critique only. It is invalid for the formal gate once P0/P1 close or their canonical contract changes.
- **Evidence / reference:** `origin/v0.6.2-rc` push of `7e0eee4` on 2026-09-27.
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
- **Findings summary:** 2026-09-27 guard found material drift against superseded `bf67507`. The user authorized the bounded correction loop; `7e0eee4` is the refreshed pre-prerequisite baseline and formal revalidation remains blocked until P0/P1 close.
- **Evidence / reference:** `python3 tools/review_scope_drift_guard.py --todo foundation_documentation/todos/active/delphi-cross-stack-todo-agent-orchestration-contract.md` -> `REVIEW-SCOPE-DRIFT-MATERIAL-CHANGE` against `bf67507`; the final pre-prerequisite plan check targets `7e0eee4`.
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
| P2 | this TODO and explicit skill invocation | resolve existing JSON role/model settings, assess bounded criteria, and execute only the approved micro-adjustment | focused helper tests and TEACH output pass |
| Future | separately authorized TODO | routing-schema migration, provider/runtime admission, post-green review orchestration, or writer lease | separate approval and validation |

### V1 Runtime Cycle

1. Explicit skill invocation loads the exact TODO and current workspace.
2. The resolver reads `config/agent_role_routing.json` and reports the selected surface, role, model family, model alias, effort, and proof policy; it never edits the JSON or invents a provider fallback.
3. The TEACH helper checks only the bounded micro-adjustment criteria: exact TODO scope, one normal executor writer, no runtime/provider/schema cutover, reversible bounded edits, and compact evidence.
4. The routine executor is the sole normal material writer; the skill does not grant primary-chat or alternate-provider bypasses.
5. Raw command/review/usage payloads remain under the ignored temporary artifact root. The exact TODO records only compact phase/result summaries and provider-reported token totals by canonical tier; unavailable usage stays `unavailable`.
6. Any criterion failure returns a deterministic TEACH block and requires user correction before rerun; no automatic dispatch, retry, fallback, or waiver is created.

### Execution Artifact & Token Ledger

1. For each governed action, the executor or reviewer writes raw Problems snapshots, test stdout/stderr, review payloads, and provider usage payloads below the profile-directed ignored temporary root defined in Contract Boundary. The action directory is scoped to the exact TODO and session and is not a tracked evidence artifact.
2. The exact TODO receives only the compact gate-relevant summary: action ID, selected canonical surface/role/tier, command or review kind, exit/outcome, duration when applicable, failure classification, reviewer decision, and any user continuation. It must not reproduce raw output or depend on an ignored file as its sole durable evidence.
3. If a provider reports token usage, aggregate its reported token total into exactly one row for the action's canonical JSON-resolved tier. Do not calculate a cost, estimate missing values, or use the aggregate to select a model, tier, provider, or gate result. If no report exists, record `unavailable` for that action/tier rather than `0`.
4. At TODO closeout, preserve the compact summary and tier totals in the tracked TODO; temporary payloads may be pruned under the existing transient-artifact policy only after their relevant result/classification is recorded.

### Token-Tier Consolidation (Tracked TODO Summary)

The routing JSON supplies the tier identifiers. During execution, append or update one row per observed tier; do not pre-copy the tier catalog here.

| Canonical JSON-resolved tier | Cumulative provider-reported tokens | Included governed action IDs | Evidence status |
| --- | --- | --- | --- |
| no tier observed yet | unavailable | none | no governed execution has completed for this TODO |

### Runtime-Model Evidence State Machine

| Evidence state | Initial outcome | User-facing explanation | Valid continuation result after scoped record + guard rerun |
| --- | --- | --- | --- |
| `exact` | `go` | Observed active model is the canonical model or a declared canonical equivalence. | n/a |
| `stronger` | `blocked` | Recommended model is available through a stronger actual model; request explicit token-cost acceptance. | `go` with `continuation_status=user_confirmed` |
| `weaker` | `blocked` | Actual model is weaker than the recommendation; request explicit quality acceptance. | `go` with `continuation_status=user_confirmed` |
| `lateral` | `blocked` | Actual model is neither canonically equivalent nor ordered relative to the recommendation. | `go` with user-specific continuation reason; otherwise remain blocked. |
| `unknown` or `unavailable` | `blocked` | The active runtime model could not be determined; identify the recommended model and request the user's continuation decision. | `go` with an explicitly unverified user-confirmed continuation, or remain blocked. |

The record binds TODO, session, surface, action, canonical recommendation, observed/declaration values, decision, reason, attestor/source, and expiry. The guard rejects expired, mismatched, incomplete, or cross-scope records. No state selects another model or provider automatically.

### Pre-APROVADO Gate Ordering

1. After P0/P1 close, refresh and push the review baseline.
2. Run architecture decision review, plan review, critique, assumption-code coherence, and scope-drift gates. Planning-review dispatch records its own JSON-derived review evidence; it is not combined into the implementation tuple.
3. Prepare exactly one planned implementation tuple: `surface=implementation`, `role=routine-executor`, and the model family resolved by the canonical routing JSON. Provider evidence is `n/a` for this structural preflight and becomes mandatory before the provider-dependent static-analysis gate.
4. Run `python3 tools/todo_authority_guard.py foundation_documentation/todos/active/delphi-cross-stack-todo-agent-orchestration-contract.md --pre-approval` and require `Overall outcome: preflight-go`.
5. Request explicit APROVADO. Only after approval do rule ingestion and the action-specific normal routing guard require `go` before implementation or implementation-side formal review.

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
- **Why:** The bounded skill/helpers package needs a focused review of JSON authority, explicit invocation, writer boundaries, and TEACH criteria.
- **Reviewer selection:** Resolve formal-review/strongest-review through routing JSON; no named model here.
- **Focus:** existing JSON authority, no automatic provider fallback, executor-only normal writing, ignored raw artifacts, compact TODO summaries, and no generic coordinator drift.
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
- **Canonical multi-lane audit protocol:** `audit-protocol-triple-review` is recommended only if a future audit rerun derives it; it is additive and never substitutes for this critique.
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
- **Why this level:** V1 changes Delphi governance tooling only; it does not alter a downstream query path, user-flow latency target, concurrent write path, queue, runtime, or deployment system.
- **Current delivery stage at review time:** Pending
- **PCV applicability:** not applicable to this Delphi self-maintenance TODO by the user's scope clarification.
- **Derived performance/concurrency decision:** not_needed (2026-09-27 audit guard; `PCV-NOT-TRIGGERED`).
- **Boundary:** Do not alter `pcv-1`, invent no lane values, and do not use PCV rows as a surrogate for Delphi tooling review. If a later separately authorized downstream/product TODO changes endpoint, async UI, backend-write, or runtime-pressure behavior, that TODO applies the PCV method under its own scope.

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
- **Canonical multi-lane audit protocol:** `audit-protocol-triple-review` is recommended only if a future audit rerun derives it; it is additive and cannot replace this final review.
- **Final review status:** not_run
- **Findings summary:** no implementation exists
- **Evidence / reference:** delivery-stage gate after validation, test-quality audit, verification-debt audit, and architecture-adherence review

## Independent Cutover Integrity Audit Gate

- **Cutover audit decision:** required
- **Why this decision:** V1 retires conflicting provider/fallback wording and makes one JSON-backed canonical selection path authoritative.
- **Cutover signals in scope:** canonical cutover|legacy-path retirement|fallback bridge
- **Package mode:** bounded-file-set
- **Canonical multi-lane audit protocol:** `audit-protocol-triple-review` only if separately derived/recommended; it remains additive delivery-side evidence.
- **Audit focus:** true canonical path|approved temporary exception scope|removal criteria|hidden fallback mirrors|pseudo-canonical fields
- **Cutover audit status:** not_run
- **Findings summary:** no implementation exists
- **Evidence / reference:** delivery-stage gate after P2/P3; inspect consumers, obsolete bridge/CLI wording, and migration/compatibility artifacts for a second authority or implicit fallback.
- **Waiver authority / reference (required if waived):** n/a

## Approval

- **Status:** not requested
- **Required before implementation:** explicit invocation of this skill and the deterministic resolver/TEACH helpers; no P0/P1 or schema-cutover prerequisite.

## Rules Acknowledgement / Ingestion

These are the concrete P1.5 inputs prepared for pre-approval structural validation. Reload them after APROVADO immediately before execution; if they materially conflict with the frozen plan, stop, update this TODO, and obtain renewed approval.

| Source | Why It Applies Now | Must Preserve | Must Avoid | Execution Impact |
| --- | --- | --- | --- | --- |
| `workflows/docker/todo-approval-gates-method.md` | P1.5 freezes, reviews, structurally preflights, then requests APROVADO. | planning-review order and one implementation tuple | treating pre-approval as execution authority | refresh baseline, complete reviews, and require `preflight-go` before approval. |
| `workflows/docker/todo-execution-boundary-method.md` | P2 implementation will be delegated under one normal writer. | principal checkout and single-writer authorization | implicit worktrees, auxiliary checkouts, or parallel writers | record primary-checkout topology and dispatch only the JSON-resolved executor. |
| `workflows/docker/effort-selection-method.md` | model/tier selection and evidence are governed actions. | JSON resolution, evidence mode, compact state, and review-tier separation | hardcoded model/tier policy or unrecorded active-model exception | rerun canonical routing guard before each governed action. |
| `workflows/docker/independent-critique-method.md` | P1.5 requires a fresh no-context critique before APROVADO. | reviewer independence and frozen bounded package | letting implementation or its routing tuple substitute for critique | record separate JSON-derived formal-review evidence. |
| `skills/deterministic-tooling-register.md` | V1 adds deterministic guard/fixture consumers and must not duplicate workflow authority. | named tools' boundaries and TEACH-style diagnostics | a new generic coordinator or opaque policy engine | implement only the listed deterministic checks and their fixtures. |

## Agent Routing Preflight

- **Canonical contract:** config/agent_role_routing.json
- **Client surface:** `codex`
- **Current governed action:** `implementation`
- **Selected role:** `routine-executor`
- **Selected model:** `gpt-5.6-luna` — current resolver snapshot only, derived from the canonical JSON on 2026-09-27; P1.5 must rerun it after P0/P1 and before any dispatch.
- **Selected effort:** `medium`
- **Proof mode:** `declared`
- **Exception reason:** `n/a`
- **Execution topology:** `primary-checkout-single-writer`
- **Worktree authorization:** `not-authorized`
- **Worktree authorization reference:** `n/a`
- **Guard outcome:** `go`
- **Guard-outcome limitation:** This is the current routing declaration only; it grants neither P1.5 `preflight-go` nor implementation authority.
- **Pre-approval implementation tuple:** `surface=implementation`; `role=routine-executor`; model family resolved from the canonical routing JSON; provider `n/a` for structural preflight only.
- **Required pre-approval evidence:** Exact TODO; resolved implementation surface/role/model family; actual-model status; user map confirmation; selection/continuation records as needed; concrete Rules Acknowledgement paths.
- **Planning-review separation:** Architecture/plan/critique dispatch uses separately recorded JSON-derived formal-review evidence and does not alter the single machine-readable implementation tuple.
- **Fail-closed behavior:** `todo_authority_guard.py --pre-approval` must return `preflight-go` before APROVADO. After approval, provider evidence becomes mandatory only for provider-dependent static analysis, and the action-specific routing guard must return `go` before implementation or implementation-side formal review.
- **Status:** blocked by P0/P1; first action after their closure is the pre-APROVADO planning-gate sequence above.

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
- provider-reported token totals are retained only as cumulative canonical-tier summaries in the exact TODO; unavailable usage remains unavailable.

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

#### PR-04 — Audit assertions need a real TEACH record without misapplying PCV

- **Evidence:** Audit decisions must come from the trigger matrix; PCV-1 is a product/runtime lane policy and this TODO is Delphi self-maintenance.
- **Option A:** Leave prose-only derived claims. Effort: low; risk: medium; structural soundness: regresses.
- **Option B (recommended):** Record the executed TEACH result, re-run after material trigger changes, record PCV non-applicability for this scope without changing the global policy, and demand exact P2/P3 commands before APROVADO. Effort: low; performance: neutral; structural soundness: improves.
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
| `PC-08` | internal no-context pre-prerequisite critique | blocker | by-design/no-action | assess PCV applicability | fixed | User clarified that PCV product/runtime lanes do not apply to Delphi self-maintenance; no `pcv-1` change or invented lane value is needed. |
| `PC-09` | internal no-context pre-prerequisite critique | blocker | release-blocker | make post-P0/P1 baseline refresh mandatory | fixed | Review Baseline Freeze now limits `bf67507` to pre-prerequisite review. |
| `PC-10` | internal no-context pre-prerequisite critique | minor | release-blocker | replace ambiguous fallback wording | fixed | V1 uses `fallback_policy=prohibited`; alternate provider requires user selection and rerun. |
| `PC-11` | internal no-context pre-prerequisite critique | minor | release-blocker | replace planned test placeholders before APROVADO | fixed | Local CI matrix names exact P2/P3 scripts and behavior oracles; P0/P1 block their implementation, not their planning. |
| `RC-01` | second internal no-context pre-prerequisite critique | high | release-blocker | separate model continuation from provider admission | fixed | D-16, V1 step 3, and provider fixtures now prohibit a human model continuation from unlocking a provider. |
| `RC-02` | second internal no-context pre-prerequisite critique | high | by-design/no-action | assess PCV-1 scope | fixed | User clarified this is Delphi self-maintenance; PCV product/runtime lanes are non-applicable and the global policy remains unchanged. |
| `RC-03` | second internal no-context pre-prerequisite critique | high | by-design/no-action | align triple trigger and cutover audit | fixed | The triple trigger is `no`; a future audit may recommend it. Cutover-integrity remains required for canonical-path retirement. |
| `RC-04` | second internal no-context pre-prerequisite critique | high | release-blocker | close implementation-diff-review role binding | fixed | D-18 and runtime cycle require `formal-review` plus `formal-reviewer`; fixtures reject other combinations. |
| `RC-05` | second internal no-context pre-prerequisite critique | medium | release-blocker | use one active-model-state enum | fixed | D-15, D-16, matrix, table, and fixtures use exactly `exact|stronger|weaker|lateral|unknown|unavailable`. |
| `RC-06` | second internal no-context pre-prerequisite critique | medium | release-blocker | name exact P2/P3 test scripts and oracles | fixed | Local CI matrix now names provider, review dispatch, and focused matrix scripts; their declared behavior is the required oracle. |
| `RC-07` | second internal no-context pre-prerequisite critique | low | follow-up-fast-follow | normalize noncanonical ledger statuses | fixed | PC-07/PC-08 now use canonical `fixed`; remaining future rerun is in rationale. |
| `FR-01` | final internal pre-prerequisite plan review | high | by-design/no-action | correct PCV applicability | fixed | User clarified that PCV is not applicable to Delphi self-maintenance; retain `pcv-1` unchanged and do not create a synthetic lane record. |
| `FR-02` | final internal pre-prerequisite plan review | medium | release-blocker | replace residual command placeholders | fixed | Commands section now repeats the exact Local CI-Equivalent script paths. |
| `FR-03` | final internal pre-prerequisite plan review | medium | release-blocker | correct review/freeze order wording | fixed | Consolidated record now requires refresh/freeze before the fresh review. |
| `FR-04` | final internal pre-prerequisite plan review | low | follow-up-fast-follow | correct count and closeout wording | fixed | Reconciled record says seven findings; closeout names the real next action. |
| `INT-01` | Delphi-ready internal plan review | medium | release-blocker | remove preflight/approval circularity | fixed | P1.5 and Agent Routing Preflight now follow the canonical pre-APROVADO implementation-tuple sequence; planning-review evidence remains separate. |
| `INT-02` | Delphi-ready internal plan review | low | follow-up-fast-follow | update stale closeout wording | fixed | Closeout now records the final correction as the pending publication, then P0/P1 as the next action. |
| `INT-03` | deterministic pre-approval guard | medium | release-blocker | add canonical structural fields, rules-ingestion rows, and machine-readable routing tuple | fixed | `todo_authority_guard.py --pre-approval` now reports only the deliberate post-P0/P1 architecture-decision-review blocker. |
| `INT-04` | user-directed plan refinement | medium | release-blocker | keep raw execution results untracked and consolidate provider-reported tokens by canonical tier in the TODO | fixed | D-21/D-22 and Execution Artifact & Token Ledger define the ignored artifact root, bounded tracked summaries, and no-inference aggregation. |

## TODO Closeout Disposition

- **Disposition:** blocked
- **Disposition reason:** P0 must close and retire bootstrap; P1 must then stabilize its own state/taxonomy and close. The final review baseline and gates must be refreshed afterward.
- **Post-commit/push status:** reconciled pre-APROVADO and evidence-ledger corrections published in `8bcf229` on `v0.6.2-rc`.
- **Next path/status action:** await P0/P1 rather than start P2; then refresh the baseline and execute P1.5.

## Commands (Run Locally)

- bash tools/tests/agent_role_routing_guard_test.sh
- bash tools/tests/static_analysis_provider_guard_test.sh
- bash tools/tests/review_dispatch_guard_test.sh
- bash tools/tests/focused_test_matrix_guard_test.sh
- bash self_check.sh
- git diff --check
- python3 tools/todo_deterministic_validator.py --todo foundation_documentation/todos/active/delphi-cross-stack-todo-agent-orchestration-contract.md
