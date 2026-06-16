# TODO: Delphi TODO-Driven Phase Subskills

## Artifact Identity
- **Artifact type:** `tactical_execution_contract`

## Context
The TODO-driven execution skill is still too dense for reliable progressive disclosure. The approved direction is to align it with current agent-workflow best practices: keep a concise orchestrator, split clear process phases into subskills/workflows, and keep deterministic gates visible in the parent flow.

## Framing Source & Story Slice
- **Feature brief:** `direct-to-todo`
- **Primary story ID:** `n/a`
- **Why this is the right current slice:** The work is one instruction-refactor slice: make TODO-driven execution easier to load and harder to skip.
- **Direct-to-TODO rationale:** The user approved implementation after reviewing the evidence for decomposition, progressive disclosure, and orchestrator-style workflows.

## Contract Boundary
- This TODO defines **WHAT** must be delivered and what counts as done.
- The work is bounded to Delphi self-maintenance under `delphi-ai/`.

## Delivery Status Canon (Required)
- **Current delivery stage:** `Production-Ready`
- **Qualifiers:** `none`
- **Next exact step:** Closed; no further action remains in this TODO.

## Scope
- [x] Keep `wf-docker-todo-driven-execution-method` as the concise umbrella/orchestrator.
- [x] Add phase workflows/subskills for lane framing, contract refinement, approval gates, execution boundary, delivery gates, and closeout/promotion.
- [x] Preserve critical gates in the umbrella: `APROVADO`, `Decision Baseline`, `Completion Evidence Matrix`, `Pipeline/Copilot P1/P2 Preflight`, `Rule-Spirit Anti-Pattern Hunt`, and `todo_completion_guard.py`.
- [x] Sync Cline/Claude/.clinerules mirrors and update the deterministic tooling register.
- [x] Validate with `self_check`, syntax checks, `git diff --check`, and TODO completion guard.

## Out of Scope
- [ ] Change downstream project code.
- [ ] Change the semantics of TODO approval or delivery gates.
- [ ] Add new deterministic tools.

## Definition of Done
- [x] TODO-driven umbrella skill and workflow are shorter and dispatch by phase/state.
- [x] Each phase has a matching workflow and skill with clear inputs, outputs, and non-negotiables.
- [x] Mirrors are synchronized for Cline, Claude, and `.clinerules`.
- [x] Register entries classify the new phase skills and refresh the umbrella entry.

## Validation Steps
- [x] Run `bash self_check.sh`.
- [x] Run `python3 -m py_compile tools/todo_completion_guard.py`.
- [x] Run `bash -n` for changed shell scripts if any.
- [x] Run `git diff --check`.
- [x] Run `python3 tools/todo_completion_guard.py <this-todo>` and require `Overall outcome: go`.

## External Dependency Readiness
| Dependency | Why It Matters | Status | Last Verified | Verification Method | Adjustment / Workaround |
| --- | --- | --- | --- | --- | --- |
| none | Delphi self-maintenance only. | `healthy` | `2026-05-25` | `n/a` | `n/a` |

## Profile Scope & Handoffs
- **Primary execution profile:** `strategic-cto`
- **Active technical scope:** `delphi-self-maintenance`
- **Expected supporting profiles:** `none`
- **Scope-check command:** `n/a - Delphi self-maintenance`

## Complexity
- **Level (`small|medium|big`):** `medium`
- **Checkpoint policy:** `single-pass with final validation`
- **Why this level:** Multiple skill/workflow/mirror surfaces change, but semantics remain unchanged.

## Canonical Module Anchors
- **Primary module doc:** `workflows/docker/todo-driven-execution-method.md`
- **Secondary module docs:**
  - `skills/wf-docker-todo-driven-execution-method/SKILL.md`
  - `rules/core/todo-driven-execution-model-decision.md`
  - `skills/deterministic-tooling-register.md`

## Decisions
- [x] `D-01` Use a phase-state decomposition rather than unrelated topic subskills.
- [x] `D-02` Keep delivery-blocking gates visible in the umbrella.
- [x] `D-03` Keep phase details in canonical workflow files and concise skills.

## Decision Baseline (Frozen)
- [x] The parent TODO-driven method remains the entrypoint and state machine.
- [x] Phase subskills are supporting surfaces, not independent alternate workflows.
- [x] Existing deterministic guards remain authoritative for delivery claims.

## Approval
- **Approved by:** user instruction on 2026-05-25: "Pode seguir então os ajustes. alinhado às melhores práticas."

## Flow Evidence Planning Matrix
| Criterion / Flow | Why Flow-Impacting | Platform Parity | Required Runtime Lane | Mutation Lane Required? | Backend Real-Data Required? | Planned Evidence | Non-Applicability Rationale |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Delphi instruction refactor | `structure-only` | `n/a` | `n/a` | `no` | `no` | self-check, syntax checks, completion guard | No product runtime or user-facing app flow changes. |

## Local CI-Equivalent Suite Matrix
| Repository / CI Surface | Why In Scope | Local CI-Equivalent Command | Required Before | Status | Evidence Artifact / Command | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| `delphi-ai / instruction self-check` | Skills/workflows/mirrors changed. | `bash self_check.sh` | `Local-Implemented` | passed | `bash self_check.sh` | Passed with 195 files checked, 0 individual failures, and 0 coherence failures. |
| `delphi-ai / syntax checks` | Python mirror generator and guard reference were touched by validation scope. | `python3 -m py_compile tools/sync_clinerules_mirrors.py tools/todo_completion_guard.py`; shell check applicability reviewed with `git diff --name-only` | `Local-Implemented` | passed | `python3 -m py_compile tools/sync_clinerules_mirrors.py tools/todo_completion_guard.py` | Python compile passed; no changed shell scripts were present. |

## Pipeline/Copilot P1/P2 Preflight
| Reviewer Surface / Package | Review Focus | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| bounded self-review of TODO-driven phase refactor | mirror drift, missing workflow counterparts, missing self-check anchors, guard compatibility, and instruction drift | passed | `bash self_check.sh`; `python3 -m py_compile tools/sync_clinerules_mirrors.py tools/todo_completion_guard.py`; `git diff --check` | none | Initial self-check failure exposed missing umbrella anchors; added `small|medium|big`, `Plan Review Gate`, and `Decision Adherence`, then self-check passed. |

## Rule-Spirit Anti-Pattern Hunt
| Rule / Principle Surface | Bypass or Anti-Pattern Search Lens | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| TODO-driven execution rule and workflow | Subskills hiding approval/delivery gates, duplicating canonical truth, or weakening deterministic close authority | passed | `workflows/docker/todo-driven-execution-method.md`; `skills/wf-docker-todo-driven-execution-method/SKILL.md`; `rules/core/todo-driven-execution-model-decision.md`; `bash self_check.sh` | none | Umbrella keeps `APROVADO`, `Decision Baseline`, completion evidence, CI-equivalent, P1/P2 preflight, Rule-Spirit hunt, and completion guard visible. |

## Completion Evidence Matrix
| Criterion ID | Source Section | Criterion | Evidence Type | Evidence Artifact / Command | Runtime Target | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| SCOPE-01 | Scope | Keep `wf-docker-todo-driven-execution-method` as the concise umbrella/orchestrator. | file diff | `skills/wf-docker-todo-driven-execution-method/SKILL.md`; `workflows/docker/todo-driven-execution-method.md`; `wc -w ...` | local files | passed | Umbrella skill reduced to 231 words and workflow to 560 words, both routing by phase/state. |
| SCOPE-02 | Scope | Add phase workflows/subskills for lane framing, contract refinement, approval gates, execution boundary, delivery gates, and closeout/promotion. | file diff | `workflows/docker/todo-*-method.md`; `skills/wf-docker-todo-*-method/SKILL.md` | local files | passed | Six phase workflows and six matching skills were added. |
| SCOPE-03 | Scope | Preserve critical gates in the umbrella: `APROVADO`, `Decision Baseline`, `Completion Evidence Matrix`, `Pipeline/Copilot P1/P2 Preflight`, `Rule-Spirit Anti-Pattern Hunt`, and `todo_completion_guard.py`. | grep evidence | `rg -n APROVADO workflows/docker/todo-driven-execution-method.md skills/wf-docker-todo-driven-execution-method/SKILL.md`; `rg -n "Completion Evidence Matrix" workflows/docker/todo-driven-execution-method.md`; `rg -n todo_completion_guard workflows/docker/todo-driven-execution-method.md` | local shell | passed | Critical gates remain visible in the umbrella and phase workflows. |
| SCOPE-04 | Scope | Sync Cline/Claude/.clinerules mirrors and update the deterministic tooling register. | self-check evidence | `bash self_check.sh`; `skills/deterministic-tooling-register.md`; `tools/sync_clinerules_mirrors.py` | local shell | passed | Self-check reported Cline, Claude, public Codex, and `.clinerules` mirror coherence passed. |
| SCOPE-05 | Scope | Validate with `self_check`, syntax checks, `git diff --check`, and TODO completion guard. | command evidence | `bash self_check.sh`; `python3 -m py_compile tools/sync_clinerules_mirrors.py tools/todo_completion_guard.py`; `git diff --check`; `python3 tools/todo_completion_guard.py foundation_documentation/todos/active/delphi-todo-driven-phase-subskills.md` | local shell | passed | Validation suite passed after evidence was recorded. |
| DOD-01 | Definition of Done | TODO-driven umbrella skill and workflow are shorter and dispatch by phase/state. | word-count evidence | `wc -w workflows/docker/todo-driven-execution-method.md skills/wf-docker-todo-driven-execution-method/SKILL.md` | local shell | passed | Main workflow and skill are concise and state-machine oriented. |
| DOD-02 | Definition of Done | Each phase has a matching workflow and skill with clear inputs, outputs, and non-negotiables. | self-check evidence | `bash self_check.sh` | local shell | passed | Canonical wf-skill counterparts and Cline wf-skill counterparts passed. |
| DOD-03 | Definition of Done | Mirrors are synchronized for Cline, Claude, and `.clinerules`. | self-check evidence | `bash self_check.sh` | local shell | passed | Mirror coherence passed for `.cline`, `.claude`, `.clinerules`, and tracked public Codex mirrors. |
| DOD-04 | Definition of Done | Register entries classify the new phase skills and refresh the umbrella entry. | file diff | `skills/deterministic-tooling-register.md` | local files | passed | Added phase-skill entries and refreshed the umbrella classification. |
| VAL-01 | Validation Steps | Run `bash self_check.sh`. | command | `bash self_check.sh` | local shell | passed | Passed with 195 files checked and 0 coherence failures. |
| VAL-02 | Validation Steps | Run `python3 -m py_compile tools/todo_completion_guard.py`. | command | `python3 -m py_compile tools/sync_clinerules_mirrors.py tools/todo_completion_guard.py` | local shell | passed | Python compile passed for the changed Python surface and guard reference. |
| VAL-03 | Validation Steps | Run `bash -n` for changed shell scripts if any. | applicability check | `git diff --name-only` reviewed for changed shell scripts | local shell | passed | No shell scripts changed in this slice, so `bash -n` had no target. |
| VAL-04 | Validation Steps | Run `git diff --check`. | command | `git diff --check` | local shell | passed | Whitespace check passed. |
| VAL-05 | Validation Steps | Run `python3 tools/todo_completion_guard.py <this-todo>` and require `Overall outcome: go`. | command | `python3 tools/todo_completion_guard.py foundation_documentation/todos/active/delphi-todo-driven-phase-subskills.md` | local shell | passed | Final guard returned `Overall outcome: go`. |
