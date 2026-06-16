# TODO: Delphi TODO Authority And Promotion Guard

## Artifact Identity
- **Artifact type:** `tactical_execution_contract`

## Context
The model-upgrade follow-up validation approved `C-04`: add objective guard support for approval, rule ingestion, and delivery-gate evidence. The user also clarified that promotion must not become an infinite loop of new TODOs for every finding, while P1/P2 risk still must not pass promotion guards.

## Framing Source & Story Slice
- **Feature brief:** `direct-to-todo`
- **Primary story ID:** `C-04`
- **Why this is the right current slice:** This slice is one Delphi self-maintenance improvement: make TODO authority/process evidence machine-checkable without adding a heavier approval ritual.
- **Direct-to-TODO rationale:** The user already approved this bounded split from the active model-upgrade validation TODO.

## Contract Boundary
- This TODO implements a lightweight authority/process guard. It validates evidence that should already exist in tactical TODOs; it must not introduce a new approval ceremony.
- Promotion-specific findings may stay inside the governing promotion TODO when they preserve the same approved objective, scenario, and risk conversation.
- A new TODO or renewed approval is required only when a finding changes approved scope, introduces a new independently testable behavior, creates a new approval/risk conversation, or asks for a waiver/exception to a blocking P1/P2.

## Delivery Status Canon
- **Current delivery stage:** `Completed`
- **Qualifiers:** `none`
- **Next exact step:** `n/a - local-only Delphi self-maintenance slice completed and moved to completed/ by C-07 closeout cleanup.`

## Scope
- [x] Add a companion deterministic TODO authority guard for approval, rule-ingestion, delivery-gate, and promotion-finding routing evidence.
- [x] Add the minimal approval and promotion-routing evidence surfaces to the tactical TODO template.
- [x] Wire the guard into TODO execution/delivery workflows and deterministic tooling documentation.
- [x] Update stage-promotion guidance so same-scope P1/P2 remediation blocks completion but does not force a new TODO/restart.
- [x] Add regression coverage for missing approval, missing rule ingestion, missing delivery gates, and promotion routing edge cases.

## Out of Scope
- [ ] Scrape chat history to infer approval.
- [ ] Require a separate TODO for every CI/Copilot/promotion finding.
- [ ] Change downstream Belluga Now project code or project-specific promotion contracts.
- [ ] Replace `todo_completion_guard.py`; this is a companion process/authority guard.

## Definition of Done
- [x] Tactical TODOs have a small canonical `Approval` evidence section.
- [x] A deterministic guard blocks missing approval evidence, missing rule ingestion, missing delivery gates under delivery claims, unresolved P1/P2 routing, and missing renewed-approval references where required.
- [x] Promotion docs distinguish same-scope remediation from scope-changing findings that require split/renewed approval.
- [x] Guard tests cover both blocking and non-blocking promotion remediation cases.

## Validation Steps
- [x] Run `python3 -m py_compile tools/todo_authority_guard.py`.
- [x] Run `bash tools/tests/todo_authority_guard_test.sh`.
- [x] Run `bash self_check.sh`.
- [x] Run `python3 tools/todo_authority_guard.py foundation_documentation/todos/active/delphi-todo-authority-and-promotion-guard.md --require-delivery-gates`.
- [x] Run `python3 tools/todo_completion_guard.py foundation_documentation/todos/active/delphi-todo-authority-and-promotion-guard.md`.

## Completion Evidence Matrix
| Criterion ID | Source Section | Criterion | Evidence Type | Evidence Artifact / Command | Runtime Target | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `SCOPE-01` | `Scope` | Add a companion deterministic TODO authority guard for approval, rule-ingestion, delivery-gate, and promotion-finding routing evidence. | code | `tools/todo_authority_guard.py` | local | passed | New companion guard implemented. |
| `SCOPE-02` | `Scope` | Add the minimal approval and promotion-routing evidence surfaces to the tactical TODO template. | doc | `templates/todo_template.md` | local | passed | Template now includes compact `Approval`, delivery gate, and promotion routing sections. |
| `SCOPE-03` | `Scope` | Wire the guard into TODO execution/delivery workflows and deterministic tooling documentation. | doc | `rules/core/todo-driven-execution-model-decision.md`; `workflows/docker/todo-*.md`; `skills/deterministic-tooling-register.md`; mirrors synchronized by `bash self_check.sh` | local | passed | Guard is documented in approval/execution/delivery/closeout surfaces. |
| `SCOPE-04` | `Scope` | Update stage-promotion guidance so same-scope P1/P2 remediation blocks completion but does not force a new TODO/restart. | doc | `skills/github-stage-promotion-orchestrator/SKILL.md`; `skills/github-stage-promotion-failure-review/SKILL.md`; `skills/github-stage-promotion-closeout-report/SKILL.md` | local | passed | Promotion finding routing added. |
| `SCOPE-05` | `Scope` | Add regression coverage for missing approval, missing rule ingestion, missing delivery gates, and promotion routing edge cases. | test | `bash tools/tests/todo_authority_guard_test.sh` | local | passed | Test covers no-go and go cases, including same-TODO promotion remediation. |
| `DOD-01` | `Definition of Done` | Tactical TODOs have a small canonical `Approval` evidence section. | doc | `templates/todo_template.md` | local | passed | Added compact section without extra approval ceremony. |
| `DOD-02` | `Definition of Done` | A deterministic guard blocks missing approval evidence, missing rule ingestion, missing delivery gates under delivery claims, unresolved P1/P2 routing, and missing renewed-approval references where required. | test | `bash tools/tests/todo_authority_guard_test.sh` | local | passed | Fixture suite exercises each blocker. |
| `DOD-03` | `Definition of Done` | Promotion docs distinguish same-scope remediation from scope-changing findings that require split/renewed approval. | review | `skills/github-stage-promotion-orchestrator/SKILL.md`; `skills/github-stage-promotion-failure-review/SKILL.md`; `bash tools/rule_spirit_anti_pattern_scan.sh --repo . --stack all --path tools --path skills --path workflows --path rules --path templates` | local | passed | Docs state P1/P2 blocks completion but same-scope fixes stay in the lane. |
| `DOD-04` | `Definition of Done` | Guard tests cover both blocking and non-blocking promotion remediation cases. | test | `bash tools/tests/todo_authority_guard_test.sh` | local | passed | Includes fixed same-TODO P1 pass and unresolved/scope-change blockers. |
| `VAL-01` | `Validation Steps` | Run `python3 -m py_compile tools/todo_authority_guard.py`. | test | `python3 -m py_compile tools/todo_authority_guard.py` | local | passed | Command exited 0. |
| `VAL-02` | `Validation Steps` | Run `bash tools/tests/todo_authority_guard_test.sh`. | test | `bash tools/tests/todo_authority_guard_test.sh` | local | passed | Output: `todo_authority_guard_test: OK`. |
| `VAL-03` | `Validation Steps` | Run `bash self_check.sh`. | test | `bash self_check.sh` | local | passed | Individual files checked: 203; individual failures: 0; coherence failures: 0. |
| `VAL-04` | `Validation Steps` | Run `python3 tools/todo_authority_guard.py foundation_documentation/todos/active/delphi-todo-authority-and-promotion-guard.md --require-delivery-gates`. | test | `python3 tools/todo_authority_guard.py foundation_documentation/todos/active/delphi-todo-authority-and-promotion-guard.md --require-delivery-gates` | local | passed | Guard result recorded after evidence update: `Overall outcome: go`. |
| `VAL-05` | `Validation Steps` | Run `python3 tools/todo_completion_guard.py foundation_documentation/todos/active/delphi-todo-authority-and-promotion-guard.md`. | test | `python3 tools/todo_completion_guard.py foundation_documentation/todos/active/delphi-todo-authority-and-promotion-guard.md` | local | passed | Guard result recorded after evidence update: `Overall outcome: go`. |

## External Dependency Readiness
| Dependency | Why It Matters | Status | Last Verified | Verification Method | Adjustment / Workaround |
| --- | --- | --- | --- | --- | --- |
| none | This is local Delphi tooling and documentation work. | `healthy` | `2026-05-25` | `n/a` | `n/a` |

## Profile Scope & Handoffs
- **Primary execution profile:** `strategic-cto`
- **Active technical scope:** `delphi-self-maintenance`
- **Expected supporting profiles:** `operational-coder`
- **Scope-check command:** `n/a - Delphi self-maintenance repository has no project profile checker in scope for this slice`

## Complexity
- **Level (`small|medium|big`):** `medium`
- **Checkpoint policy:** `single approved split; implementation may proceed inside this TODO`
- **Why this level:** The change touches guard tooling, template shape, canonical TODO workflows, and stage-promotion guidance.

## Canonical Module Anchors
- **Primary module doc:** `rules/core/todo-driven-execution-model-decision.md`
- **Secondary module docs:**
  - `workflows/docker/todo-execution-boundary-method.md`
  - `workflows/docker/todo-delivery-gates-method.md`
  - `skills/github-stage-promotion-orchestrator/SKILL.md`
- **Planned decision promotion targets (module sections):**
  - TODO authority/process enforcement
  - Promotion finding routing
- **Module decision consolidation targets (required):**
  - `rules/core/todo-driven-execution-model-decision.md`
  - `workflows/docker/todo-execution-boundary-method.md`
  - `workflows/docker/todo-delivery-gates-method.md`
  - `skills/github-stage-promotion-orchestrator/SKILL.md`
  - `skills/github-stage-promotion-failure-review/SKILL.md`

## Decisions
- [x] `D-01` Implement a companion `todo_authority_guard.py` rather than expanding `todo_completion_guard.py`, so close-claim evidence and authority/process evidence stay separate.
- [x] `D-02` Validate TODO-native approval records, not chat history. The agent must record the approval evidence in the TODO.
- [x] `D-03` During promotion, same-scope remediation for confirmed P1/P2 findings stays in the governing TODO and lane; new TODO/renewed approval is reserved for scope/risk/exception changes.

## Decision Baseline
- [x] `D-01` Companion guard validates authority/process evidence separately from completion evidence.
- [x] `D-02` Objective approval evidence must live in the TODO.
- [x] `D-03` Promotion routing must block risky completion without making every finding a new TODO.

## Approval
- **Approved by:** user approved `C-04` split implementation on 2026-05-25 with "Perfeito. Aprovado."
- **Approval scope:** implement the lightweight TODO authority/process guard, template support, workflow documentation, and promotion finding routing described in this TODO.
- **Execution not authorized by approval:** downstream project code changes, chat scraping, heavier approval ceremony, or automatic new TODO creation for every promotion finding.
- **Renewed approval required when:** implementation changes the tactical TODO authority model, promotion topology, or the rule for which findings may remain inside the same promotion lane.

## Rules Acknowledgement / Ingestion
| Source | Why It Applies Now | Must Preserve | Must Avoid | Execution Impact |
| --- | --- | --- | --- | --- |
| `rules/core/todo-driven-execution-model-decision.md` | The change implements deterministic support for TODO approval, rule ingestion, and delivery gate sequencing. | Explicit approval before implementation, rule ingestion after approval, delivery gates before claims. | A new ritual that replaces judgment or creates approval churn. | Add objective guard evidence while keeping the process bounded. |
| `workflows/docker/todo-execution-boundary-method.md` | The guard runs after approval/rule ingestion and before implementation claims. | Execution stays inside approved boundary. | Hidden scope expansion or stale rules. | Wire authority guard into the execution boundary. |
| `workflows/docker/todo-delivery-gates-method.md` | Delivery gate execution is part of the guard scope. | P1/P2 preflight and rule-spirit hunt remain blocking. | Treating guard success as a replacement for evidence quality. | Add guard usage alongside completion guard. |
| `skills/github-stage-promotion-orchestrator/SKILL.md` | User explicitly raised promotion flow risk. | P1/P2 blocks completion; same-scope remediation stays in the lane. | Infinite TODO restart loop for every promotion finding. | Add finding routing guidance for promotion. |

## Local CI-Equivalent Suite Matrix
| Repository / CI Surface | Why In Scope | Local CI-Equivalent Command | Required Before | Status | Evidence Artifact / Command | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| delphi-ai / authority guard py_compile | New Python tool. | `python3 -m py_compile tools/todo_authority_guard.py` | Local-Implemented | passed | `python3 -m py_compile tools/todo_authority_guard.py` | Compile syntax validation passed. |
| delphi-ai / authority guard regression | New deterministic guard behavior. | `bash tools/tests/todo_authority_guard_test.sh` | Local-Implemented | passed | `bash tools/tests/todo_authority_guard_test.sh` | Positive and negative fixtures passed. |
| delphi-ai / self-check | Skills, mirrors, rules, and workflows changed. | `bash self_check.sh` | Local-Implemented | passed | `bash self_check.sh` | Individual files checked: 203; individual failures: 0; coherence failures: 0. |

## Pipeline/Copilot P1/P2 Preflight
| Reviewer Surface / Package | Review Focus | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| C-04 implementation package | CI/Copilot priority risks in guard, tests, and promotion docs | passed | `python3 -m py_compile tools/todo_authority_guard.py`; `bash tools/tests/todo_authority_guard_test.sh`; `bash tools/tests/todo_completion_guard_test.sh`; `bash self_check.sh` | none | Local test and coherence package passed; promotion routing tested for blocking-priority findings. |

## Rule-Spirit Anti-Pattern Hunt
| Rule / Principle Surface | Bypass or Anti-Pattern Search Lens | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| TODO-driven execution and stage promotion | Approval bureaucracy, fake process evidence, priority bypass, infinite promotion TODO loop | passed | `bash tools/rule_spirit_anti_pattern_scan.sh --repo . --stack all --path tools --path skills --path workflows --path rules --path templates` | 8 review-only heuristic findings; none blocking. | Findings are existing scanner/test self-references or review-only hints; the C-04 changes add guard evidence and promotion routing instead of weakening rules. |

## Promotion Finding Routing Ledger
| Finding ID | Severity | Classification | Routing Decision | Same TODO / Split Rationale | Status | Approval / Follow-up Reference |
| --- | --- | --- | --- | --- | --- | --- |
| `n/a` | `n/a` | `n/a` | `n/a` | This TODO changes promotion policy but is not executing a promotion lane. | `accepted` | `n/a` |
