# TODO: Delphi Sync, Topology, and Determinism Follow-ups

## Artifact Identity
- **Artifact type:** `tactical_execution_contract`

## Context
The model-upgrade branch now has stronger delivery gates and stack portability rules. The remaining improvement space is known and approved: `.claude` sync should be first-class, environment/topology contracts should be scaffolded from available project evidence with user validation, registry/schema checks should be deterministic, anti-pattern hunting should gain stack-specific scanners, large skills should continue moving toward canonical pointers, legacy tool surfaces should be deprecated or bridged, and escape metrics should be easier to capture.

## Framing Source & Story Slice
- **Feature brief:** `direct-to-todo`
- **Primary story ID:** `n/a`
- **Why this is the right current slice:** The requested improvements all reduce Delphi drift and make the new gates more enforceable without changing downstream project behavior.
- **Direct-to-TODO rationale:** The user approved all listed improvement fronts and explicitly requested a TODO so no point is forgotten.

## Contract Boundary
- This TODO defines **WHAT** must be delivered and what counts as done.
- `Assumptions Preview` and `Execution Plan` define **HOW** Delphi currently intends to deliver this contract.
- The work is bounded to Delphi self-maintenance under `delphi-ai/` plus its local self-maintenance TODO.

## Delivery Status Canon (Required)
- **Current delivery stage:** `Local-Implemented`
- **Qualifiers:** `none`
- **Next exact step:** Commit and push the implemented follow-up package on `model-upgrade/delphi-instruction-modernization`.

## Scope
- [x] Make `.claude` skill mirror synchronization and auditing first-class in Delphi self-check.
- [x] Add a portable environment/topology contract flow that can infer available data from a downstream environment, write a draft contract, and mark uncertain values for user validation instead of guessing.
- [x] Add deterministic validation for `config/stack_capabilities.yaml`.
- [x] Add stack-aware anti-pattern scanners that support the Rule-Spirit Anti-Pattern Hunt for Flutter, Laravel, Docker, and future Go.
- [x] Reduce additional large legacy skill bodies where practical by delegating to canonical sources.
- [x] Deprecate or bridge legacy duplicate TODO completion tooling so only one canonical guard is authoritative.
- [x] Add an initial metrics support surface for P1/P2 and anti-pattern escape tracking.

## Delivery Status Semantics
- `Pending`: no meaningful delivery milestone has been reached yet.
- `Local-Implemented`: work is implemented locally and validated locally.
- `Lane-Promoted`: work has been merged through the declared lane threshold.
- `Production-Ready`: final required lane threshold is complete and confidence gates are satisfied.
- `Provisional`: delivery is intentionally partial/incomplete but useful for unblocking dependent work.
- `Blocked`: work cannot currently proceed; `Blocker Notes` become mandatory.

## Provisional Notes
- **Missing for production-ready:** `n/a`
- **Revisit criteria:** `n/a`
- **Dependencies unblocked:** `n/a`

## Blocker Notes
- **Blocker:** `n/a`
- **Why blocked now:** `n/a`
- **What unblocks it:** `n/a`
- **Owner / source:** `n/a`
- **Last confirmed truth:** `n/a`

## Execution Lane Tracking
- **Local implementation branches:** `delphi-ai:model-upgrade/delphi-instruction-modernization`
- **Promotion lane path:** `model-upgrade -> main`
- **Lane-promoted threshold for this TODO:** `model-upgrade branch commit`
- **Production-ready threshold for this TODO:** `main promotion when requested`

## Promotion Evidence
| Scope Item | Local Branch/Commit | PR to lane threshold | PR to `stage` | PR to `main` | Current Status |
| --- | --- | --- | --- | --- | --- |
| Delphi sync/topology/determinism follow-ups | `model-upgrade/delphi-instruction-modernization@local-implemented` | `pending commit/push` | `n/a` | `pending explicit main promotion` | `local implemented` |

## Out of Scope
- [ ] Change downstream project code or downstream project-specific documentation.
- [ ] Make post-session feedback and heavy audits opt-in or risk-triggered; the user explicitly kept that behavior unchanged.
- [ ] Implement a full Go stack package beyond reserved/future capability and scanner placeholder support.
- [ ] Store real secrets from `.env` files in generated topology contracts.

## Bounded But Elastic Guardrails
- **May stay inside this TODO:** Delphi tools/templates/workflows/skills/rules/mirrors required to complete the approved drift-reduction fronts.
- **Must update or split the TODO:** Any downstream project mutation, audit-policy change, or full new stack implementation.

## Definition of Done
- [x] `.claude` sync/check runs as part of Delphi self-maintenance validation.
- [x] Environment/topology contract template and scaffold flow exist, infer available evidence, redact secrets, and mark user-validation needs.
- [x] Stack capability registry validation is wired into self-check.
- [x] Rule-spirit anti-pattern scanning has a canonical support tool and workflow references.
- [x] At least two large legacy skill surfaces are reduced or explicitly classified as follow-up if too risky.
- [x] Legacy duplicate TODO completion guard path is bridged or deprecated toward `tools/todo_completion_guard.py`.
- [x] Metrics/escape tracking guidance or helper exists for P1/P2 and anti-pattern escapes.

## Validation Steps
- [x] Run `bash self_check.sh`.
- [x] Run `bash tools/tests/todo_completion_guard_test.sh`.
- [x] Run `python3 -m py_compile` for changed Python tools.
- [x] Run `bash -n` for changed shell tools.
- [x] Run `git diff --check`.
- [x] Run the new registry/topology/anti-pattern helpers against safe local fixtures or this repo where applicable.
- [x] Run `python3 tools/todo_completion_guard.py <this-todo>` and require `Overall outcome: go` before claiming `Local-Implemented`.

## External Dependency Readiness
| Dependency | Why It Matters | Status (`unknown|healthy|degraded|failing|rate-limited|stale`) | Last Verified | Verification Method | Adjustment / Workaround |
| --- | --- | --- | --- | --- | --- |
| none | Delphi self-maintenance does not require external services. | `healthy` | `2026-05-25` | `n/a` | `n/a` |

## Profile Scope & Handoffs
- **Primary execution profile:** `strategic-cto`
- **Active technical scope:** `delphi-self-maintenance`
- **Expected supporting profiles:** `none`
- **Scope-check command:** `n/a - Delphi self-maintenance profile selection recorded in session`

### Handoff Log
| From Profile | To Profile | Why the Handoff Exists | Touched Surfaces | Status / Evidence |
| --- | --- | --- | --- | --- |
| `n/a` | `n/a` | No profile handoff expected. | `n/a` | `n/a` |

## Complexity
- **Level (`small|medium|big`):** `big`
- **Checkpoint policy:** `consolidated`
- **Why this level:** The work spans multiple tools, workflows, templates, sync surfaces, and deterministic validations.

## Canonical Module Anchors
- **Primary module doc:** `main_instructions.md`
- **Secondary module docs (if any):**
  - `ecosystem_template_configuration.md`
  - `config/stack_capabilities.yaml`
  - `workflows/docker/environment-readiness-method.md`
  - `workflows/docker/todo-driven-execution-method.md`
  - `workflows/docker/update-skill-method.md`
  - `skills/deterministic-tooling-register.md`
- **Planned decision promotion targets (module sections):**
  - Delphi source-of-truth, stack capability, readiness, TODO delivery, and skill-sync sections.
- **Module decision consolidation targets (required):**
  - `main_instructions.md`, workflow files, templates, and tools manifest.

## Decision Pending
- [x] `D-01` Decide whether `.claude` sync should become first-class in `self_check.sh`.
- [x] `D-02` Decide whether topology contract scaffolding may infer values from environment files.
- [x] `D-03` Decide whether anti-pattern hunting should remain manual-only.

## Decisions
- [x] `D-01` `.claude` sync/check becomes first-class for curated `.claude/skills` mirrors.
- [x] `D-02` Topology contract scaffolding may infer values from available repo evidence, but secrets must be redacted and ambiguous values must be marked for user validation.
- [x] `D-03` Anti-pattern hunting gains deterministic scanner support while final severity/judgment remains in the TODO gate.

## Decision Baseline
- [x] New deterministic helpers must be project-agnostic and write only redacted/generated artifacts.
- [x] Available stack capabilities remain separate from active project topology.
- [x] The canonical TODO completion guard remains `tools/todo_completion_guard.py`.
- [x] Heavy audit opt-in policy remains unchanged.

## Questions To Close
- [x] No open question blocks implementation; the user approved these fronts and emphasized the topology inference/validation flow.

## Assumptions Preview
| Assumption ID | Assumption | Evidence | If False | Confidence (`High|Medium|Low`) | Handling (`Keep as Assumption|Promote to Decision|Block`) |
| --- | --- | --- | --- | --- | --- |
| `A-01` | `.claude/skills` can follow the same curated mirror model as `.cline/skills`, scoped to existing `.claude` skill directories. | Existing `.claude/skills` contains curated subset, not every canonical skill. | Sync script should use explicit existing directories only. | `High` | `Keep as Assumption` |
| `A-02` | A topology scaffold can safely inspect `.env` and `.env.example` if it redacts secret-like keys and clearly marks user-validation needs. | User requested inference from available environment data with validation. | Tool must restrict to docs/config only. | `High` | `Promote to Decision` |
| `A-03` | Legacy deterministic guard path can be bridged without deleting files. | Existing `deterministic/core/todo_completion_guard.py` path exists. | Use wrapper/deprecation first. | `Medium` | `Keep as Assumption` |

## Execution Plan
### Touched Surfaces
- `tools/*`
- `templates/*`
- `workflows/docker/*`
- `rules/core/*`
- `skills/*`
- `.cline/skills/*`, `.clinerules/*`, `.claude/skills/*`
- `deterministic/core/todo_completion_guard.py`
- `foundation_documentation/todos/active/delphi-sync-topology-and-determinism-followups.md`

### Ordered Steps
1. Add `.claude` sync script and audit wiring.
2. Add environment/topology contract template, scaffold tool, workflow/skill/rule references, and readiness integration.
3. Add stack capability registry validator and wire it into self-check.
4. Add rule-spirit anti-pattern scanner support and workflow references.
5. Bridge legacy TODO completion guard path to canonical `tools/todo_completion_guard.py`.
6. Reduce selected large skills or record bounded follow-up where risk is too high.
7. Add metrics/escape guidance or helper.
8. Sync mirrors, validate, and fill delivery evidence.

### Test Strategy
- **Strategy:** `test-after`
- **Why:** This is tool/instruction maintenance; correctness is verified through deterministic self-checks and helper smoke runs.
- **Fail-first target(s) (when required):** `n/a`

### Flow Evidence Planning Matrix
| Criterion / Flow | Why Flow-Impacting | Platform Parity (`android-only|web-only|shared-android-web|divergent-android-web|n/a`) | Required Runtime Lane | Mutation Lane Required? | Backend Real-Data Required? | Planned Evidence | Non-Applicability Rationale |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Delphi tool/instruction maintenance | `structure-only` | `n/a` | `n/a` | `no` | `no` | self-check, helper smoke tests, completion guard | No product runtime or user-facing app flow changes. |

### Local CI-Equivalent Suite Matrix
| Repository / CI Surface | Why In Scope | Local CI-Equivalent Command | Required Before | Status | Evidence Artifact / Command | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| `delphi-ai / instruction self-check` | Rules/workflows/skills/mirrors were touched. | `bash self_check.sh` | `Local-Implemented` | passed | `bash self_check.sh` | Passed with 183 files checked and 0 coherence failures. |
| `delphi-ai / guard tests` | Completion guard and legacy bridge are in scope. | `bash tools/tests/todo_completion_guard_test.sh` | `Local-Implemented` | passed | `bash tools/tests/todo_completion_guard_test.sh` | Guard regression script passed. |
| `delphi-ai / helper smoke tests` | New topology, registry, scanner, and gate-escape helpers are in scope. | `bash tools/tests/environment_topology_contract_scaffold_test.sh`; `bash tools/tests/validate_stack_capabilities_test.sh`; `bash tools/tests/rule_spirit_anti_pattern_scan_test.sh`; `bash tools/tests/rule_event_record_gate_escape_test.sh` | `Local-Implemented` | passed | listed commands | All helper fixture tests passed. |
| `delphi-ai / syntax checks` | Python and shell helpers changed. | `python3 -m py_compile ...`; `bash -n ...` | `Local-Implemented` | passed | `python3 -m py_compile tools/environment_topology_contract_scaffold.py tools/validate_stack_capabilities.py tools/rule_event_record.py tools/todo_completion_guard.py deterministic/core/todo_completion_guard.py`; `bash -n ...` | Static syntax checks passed. |

### Runtime / Rollout Notes
- No runtime rollout. Generated topology contracts are project-local artifacts under `foundation_documentation/artifacts/` in downstream repos.

## Completion Evidence Matrix
| Criterion ID | Source Section | Criterion | Evidence Type | Evidence Artifact / Command | Runtime Target | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| SCOPE-01 | Scope | Make `.claude` skill mirror synchronization and auditing first-class in Delphi self-check. | implementation + validation | `tools/sync_claude_skill_mirrors.sh`; `tools/self_check.sh`; `tools/audit_instruction_baselines.sh`; `bash self_check.sh` | local shell | passed | Self-check now syncs and audits `.claude` skill mirrors. |
| SCOPE-02 | Scope | Add a portable environment/topology contract flow that can infer available data from a downstream environment, write a draft contract, and mark uncertain values for user validation instead of guessing. | implementation + fixture test | `tools/environment_topology_contract_scaffold.py`; `templates/environment_topology_contract_template.md`; `bash tools/tests/environment_topology_contract_scaffold_test.sh` | local shell | passed | Fixture confirmed public domain inference, secret redaction, stack hints, and validation checklist. |
| SCOPE-03 | Scope | Add deterministic validation for `config/stack_capabilities.yaml`. | implementation + fixture test | `tools/validate_stack_capabilities.py`; `bash tools/tests/validate_stack_capabilities_test.sh`; `python3 tools/validate_stack_capabilities.py` | local shell | passed | Validator is wired into `self_check.sh` and passes against the canonical registry. |
| SCOPE-04 | Scope | Add stack-aware anti-pattern scanners that support the Rule-Spirit Anti-Pattern Hunt for Flutter, Laravel, Docker, and future Go. | implementation + fixture test | `tools/rule_spirit_anti_pattern_scan.sh`; `bash tools/tests/rule_spirit_anti_pattern_scan_test.sh`; `bash tools/rule_spirit_anti_pattern_scan.sh --repo . --stack all --path tools --path skills --path workflows` | local shell | passed | Scanner supports shared, Flutter, Laravel, Docker, and Go lenses and does not print env secrets in the fixture. |
| SCOPE-05 | Scope | Reduce additional large legacy skill bodies where practical by delegating to canonical sources. | implementation + audit | `wc -w skills/flutter-architecture-adherence/SKILL.md skills/test-orchestration-suite/SKILL.md`; `bash self_check.sh` | local shell | passed | `flutter-architecture-adherence` reduced to 617 words and `test-orchestration-suite` to 549 words. |
| SCOPE-06 | Scope | Deprecate or bridge legacy duplicate TODO completion tooling so only one canonical guard is authoritative. | implementation + validation | `deterministic/core/todo_completion_guard.py`; `python3 deterministic/core/todo_completion_guard.py --all-completed`; `bash tools/tests/todo_completion_guard_test.sh` | local shell | passed | Legacy path delegates to canonical `tools/todo_completion_guard.py` and preserves `--todo` compatibility. |
| SCOPE-07 | Scope | Add an initial metrics support surface for P1/P2 and anti-pattern escape tracking. | implementation + fixture test | `tools/rule_event_record.py gate-escape`; `bash tools/tests/rule_event_record_gate_escape_test.sh`; `workflows/docker/progressive-determinism-metrics-method.md` | local shell | passed | Gate escape helper records Pipeline/Copilot P1/P2 and Rule-Spirit escapes into the existing PACED JSONL ledger. |
| DOD-01 | Definition of Done | `.claude` sync/check runs as part of Delphi self-maintenance validation. | self-check evidence | `bash self_check.sh` | local shell | passed | Self-check output: `.claude` mirrors synchronized and `Canonical vs .claude skill mirror` passed; integration_test/browser evidence n/a because this is structure-only instruction tooling. |
| DOD-02 | Definition of Done | Environment/topology contract template and scaffold flow exist, infer available evidence, redact secrets, and mark user-validation needs. | fixture test | `bash tools/tests/environment_topology_contract_scaffold_test.sh` | local shell | passed | Test asserted `example.test`, redacted secret values, and `User Validation Checklist`. |
| DOD-03 | Definition of Done | Stack capability registry validation is wired into self-check. | self-check evidence | `bash self_check.sh`; `python3 tools/validate_stack_capabilities.py` | local shell | passed | Self-check begins with `validate_stack_capabilities: OK`; integration_test/browser evidence n/a because this is structure-only registry tooling. |
| DOD-04 | Definition of Done | Rule-spirit anti-pattern scanning has a canonical support tool and workflow references. | implementation + scan evidence | `tools/rule_spirit_anti_pattern_scan.sh`; `workflows/docker/todo-driven-execution-method.md`; `rules/core/todo-driven-execution-model-decision.md` | local shell | passed | TODO workflow and rule now cite the scanner as support evidence. |
| DOD-05 | Definition of Done | At least two large legacy skill surfaces are reduced or explicitly classified as follow-up if too risky. | word-count evidence | `wc -w skills/flutter-architecture-adherence/SKILL.md skills/test-orchestration-suite/SKILL.md` | local shell | passed | Both reduced below the audit large-skill warning threshold. |
| DOD-06 | Definition of Done | Legacy duplicate TODO completion guard path is bridged or deprecated toward `tools/todo_completion_guard.py`. | bridge validation | `python3 deterministic/core/todo_completion_guard.py --all-completed` | local shell | passed | Bridge returned `Overall outcome: go` via canonical guard. |
| DOD-07 | Definition of Done | Metrics/escape tracking guidance or helper exists for P1/P2 and anti-pattern escapes. | helper test | `bash tools/tests/rule_event_record_gate_escape_test.sh` | local shell | passed | Test recorded a `paced.gate.pipeline-p1-p2-preflight` escape event. |
| VAL-01 | Validation Steps | Run `bash self_check.sh`. | command | `bash self_check.sh` | local shell | passed | Passed with 183 files checked, 0 individual failures, and 0 coherence failures. |
| VAL-02 | Validation Steps | Run `bash tools/tests/todo_completion_guard_test.sh`. | command | `bash tools/tests/todo_completion_guard_test.sh` | local shell | passed | Guard regression test passed. |
| VAL-03 | Validation Steps | Run `python3 -m py_compile` for changed Python tools. | command | `python3 -m py_compile tools/environment_topology_contract_scaffold.py tools/validate_stack_capabilities.py tools/rule_event_record.py tools/todo_completion_guard.py deterministic/core/todo_completion_guard.py` | local shell | passed | Python syntax compilation passed. |
| VAL-04 | Validation Steps | Run `bash -n` for changed shell tools. | command | `bash -n tools/sync_claude_skill_mirrors.sh tools/rule_spirit_anti_pattern_scan.sh tools/tests/environment_topology_contract_scaffold_test.sh tools/tests/validate_stack_capabilities_test.sh tools/tests/rule_spirit_anti_pattern_scan_test.sh tools/tests/rule_event_record_gate_escape_test.sh tools/self_check.sh tools/audit_instruction_baselines.sh` | local shell | passed | Shell syntax checks passed. |
| VAL-05 | Validation Steps | Run `git diff --check`. | command | `git diff --check` | local shell | passed | Whitespace check passed after final TODO evidence update. |
| VAL-06 | Validation Steps | Run the new registry/topology/anti-pattern helpers against safe local fixtures or this repo where applicable. | command | `bash tools/tests/environment_topology_contract_scaffold_test.sh`; `bash tools/tests/validate_stack_capabilities_test.sh`; `bash tools/tests/rule_spirit_anti_pattern_scan_test.sh`; `python3 tools/validate_stack_capabilities.py`; `python3 tools/environment_topology_contract_scaffold.py --repo . --stdout`; `bash tools/rule_spirit_anti_pattern_scan.sh --repo . --stack all --path tools --path skills --path workflows` | local shell | passed | Fixture and repo smoke runs completed; scanner findings were review-only self/tool/test references. |
| VAL-07 | Validation Steps | Run `python3 tools/todo_completion_guard.py <this-todo>` and require `Overall outcome: go` before claiming `Local-Implemented`. | command | `python3 tools/todo_completion_guard.py foundation_documentation/todos/active/delphi-sync-topology-and-determinism-followups.md` | local shell | passed | Final guard returned `Overall outcome: go`. |

## Pipeline/Copilot P1/P2 Preflight
| Reviewer Surface / Package | Review Focus | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| bounded self-review of implemented Delphi diff and validation suite | CI/Copilot severity defects, missing local checks, mirror drift, syntax failures, secret leaks, and guard bypass risks | passed | `bash self_check.sh`; `python3 -m py_compile ...`; `bash -n ...`; `bash tools/tests/*_test.sh`; `git diff --check` | none | Self-check passed. New topology fixture proves secret redaction. Remaining large-skill warnings for `github-stage-promotion-orchestrator` and `wf-docker-todo-driven-execution-method` are non-blocking follow-up space. |

## Rule-Spirit Anti-Pattern Hunt
| Rule / Principle Surface | Bypass or Anti-Pattern Search Lens | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| Delphi core agnosticism and topology separation | Project-specific topology hard-coding, active-stack inference from Delphi capability presence, env secret leakage, and guessed tenant/domain targets | passed | `tools/environment_topology_contract_scaffold.py`; `rules/core/environment-topology-contract-model-decision.md`; `main_instructions.md`; `bash tools/tests/environment_topology_contract_scaffold_test.sh` | none | Topology flow pre-fills available evidence, redacts secrets, and keeps inferred values as `user_validation_required`. |
| TODO delivery gates and anti-pattern hunting | Literal rule compliance that bypasses CI/Copilot preflight or Rule-Spirit review | passed | `tools/todo_completion_guard.py`; `tools/rule_spirit_anti_pattern_scan.sh`; `bash tools/rule_spirit_anti_pattern_scan.sh --repo . --stack all --path tools --path skills --path workflows` | scanner reported review-only self/tool/test references | Scanner is wired as support evidence; final severity judgment remains in the gate. |
| Mirror/source-of-truth discipline | Drift between canonical skills/workflows/rules and `.cline`, `.claude`, `.clinerules`, or public Codex mirrors | passed | `bash self_check.sh` | no mirror drift | `.cline`, `.claude`, `.clinerules`, and tracked public mirrors passed coherence checks. |

## Decision Adherence
| Decision | Status | Evidence |
| --- | --- | --- |
| `.claude` sync/check becomes first-class. | adherent | `tools/sync_claude_skill_mirrors.sh`, `tools/self_check.sh`, `tools/audit_instruction_baselines.sh`. |
| Topology contract scaffolding may infer values but must redact secrets and require validation. | adherent | `tools/environment_topology_contract_scaffold.py`, topology template, rule/workflow/skill surfaces, fixture test. |
| Anti-pattern hunting gains deterministic scanner support while final judgment remains gate-led. | adherent | `tools/rule_spirit_anti_pattern_scan.sh`, TODO workflow/rule references. |
| Available stack capabilities remain separate from active project topology. | adherent | `config/stack_capabilities.yaml`, `tools/validate_stack_capabilities.py`, environment-topology rule. |

## Security Risk Assessment
- **Status:** passed.
- **Evidence:** `bash tools/tests/environment_topology_contract_scaffold_test.sh` confirmed secret-like env values were redacted and raw secret fixture values were absent from output.
- **Residual risk:** The topology scaffold is heuristic; generated contracts require user validation before use as authority.

## Performance / Concurrency Assessment
- **Status:** passed.
- **Evidence:** Changes are local deterministic scripts, docs, skills, mirrors, and tests. No runtime endpoint or concurrent product path changed.
- **Residual risk:** `rule_spirit_anti_pattern_scan.sh` is heuristic and can be noisy; it exits non-blocking by default unless `--fail-on-findings` is explicitly selected.

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
- **Issue ID:** ARCH-01
  - **Severity:** high
  - **Evidence:** `.claude` mirrors previously required manual copying; topology contracts lacked a scaffold flow.
  - **Why it matters now:** These are repeat drift sources that undermine Delphi portability and local gate reliability.
  - **Option A (Recommended):** Add deterministic sync/scaffold/validation helpers and wire them into self-check/workflows.
    - **Effort:** medium
    - **Risk:** medium
    - **Blast radius:** cross-module
    - **Maintenance burden:** improves
    - **Performance impact:** neutral
    - **Elegance impact:** improves
    - **Structural soundness impact:** improves
  - **Option B (Alternative):** Keep as prose-only instructions.
    - **Effort:** low
    - **Risk:** high
    - **Blast radius:** cross-module
    - **Maintenance burden:** worsens
    - **Performance impact:** neutral
    - **Elegance impact:** worsens
    - **Structural soundness impact:** worsens
  - **Option C (Do Nothing):** Leave current manual practices.
    - **Effort:** low
    - **Risk:** high
    - **Blast radius:** cross-module
    - **Maintenance burden:** worsens
    - **Performance impact:** neutral
    - **Elegance impact:** worsens
    - **Structural soundness impact:** worsens
  - **Recommendation:** Option A.

### Failure Modes & Edge Cases
- [x] Topology scaffold leaks secrets; mitigate by redacting secret-like keys and preferring `.env.example` where possible.
- [x] Scanner false positives become noisy; emit review findings, not hard failures, unless used through a specific gate.
- [x] Large-skill reduction removes necessary trigger detail; reduce only selected low-risk surfaces and leave explicit follow-ups for the rest.

### Residual Unknowns / Risks
- [x] Anti-pattern scanner coverage will be heuristic initially; rule-spirit severity remains judgment-led.

## Approval
- **Approved by:** user instruction on 2026-05-25: "Os outros pontos eu aprovo 100%."
- **Topology emphasis:** user required a flow that fills available data from the environment and validates with the user when needed.
