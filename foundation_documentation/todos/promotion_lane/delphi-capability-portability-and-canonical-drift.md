# TODO: Delphi Capability Portability and Canonical Drift

## Artifact Identity
- **Artifact type:** `tactical_execution_contract`

## Context
Delphi's instruction layer needs to stay portable while the Belluga ecosystem keeps accumulating stack support. The method must distinguish capabilities available globally from stacks active in a downstream project, depend on foundation documentation for environment/topology facts, and reduce duplication that causes drift between canonical rules, workflows, skills, and agent mirrors.

## Framing Source & Story Slice
- **Feature brief:** `direct-to-todo`
- **Primary story ID:** `n/a`
- **Why this is the right current slice:** The requested changes are one bounded Delphi self-maintenance slice: normalize capability/topology rules and reduce instruction drift.
- **Direct-to-TODO rationale:** The user provided the exact improvement fronts and explicitly approved applying them.

## Contract Boundary
- This TODO defines **WHAT** must be delivered and what counts as done.
- `Assumptions Preview` and `Execution Plan` define **HOW** Delphi currently intends to deliver this contract.
- This TODO is bounded but elastic for local instruction/mirror adjustments required by the same portability and drift-reduction objective.

## Delivery Status Canon (Required)
- **Current delivery stage:** `Lane-Promoted`
- **Qualifiers:** `none`
- **Next exact step:** Await explicit user request for `main` promotion; the model-upgrade branch package is closed for this TODO.

## Scope
- [x] Reduce weight and duplication in older instruction surfaces where the same operational truth is copied instead of referenced.
- [x] Establish an explicit stack capability registry for Flutter, Laravel, Docker, and future Go.
- [x] Separate "capability available in Delphi" from "stack active in a downstream project."
- [x] Require environment, tenants, domains, runtime owners, and validation targets to come from portable contracts in `foundation_documentation` or approved project-owned config/env.
- [x] Consolidate canonical sources to reduce drift between skills, workflows, mirrors, and rules.

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
| Delphi capability portability and drift reduction | `model-upgrade/delphi-instruction-modernization@d56fb4d` | `model-upgrade branch pushed` | `n/a` | `pending explicit main promotion` | `lane-promoted` |

## Out of Scope
- [ ] Make post-session feedback and heavy audits more opt-in or risk-triggered; the user explicitly chose to keep that point as-is for now.
- [ ] Change downstream project code or downstream project-specific documentation.
- [ ] Remove existing Flutter, Laravel, or Docker scripts just because a given downstream project might not use them.
- [ ] Implement Go stack workflows beyond reserving an explicit future-capability slot.

## Bounded But Elastic Guardrails
- **May stay inside this TODO:** Canonical instruction edits, stack capability registry/config edits, mirror syncs, and narrow validation/test updates for the same Delphi self-maintenance objective.
- **Must update or split the TODO:** Any change that alters post-session audit policy, adds a new stack implementation, changes downstream project runtime topology, or requires project-specific docs/code.

## Definition of Done
- [x] Canonical instructions explain available Delphi capability versus project-active stack selection.
- [x] Stack capability registry exists and names Flutter, Laravel, Docker, and future Go without activating stacks by presence alone.
- [x] Environment/tenant/domain guidance points to foundation documentation or project-owned config/env as the authoritative contract.
- [x] Drift-prone skills/rules/workflows touched by this change reference canonical sources instead of duplicating large bodies where practical.
- [x] Mirrors for Cline/Claude-compatible surfaces are synchronized.

## Validation Steps
- [x] Run `bash self_check.sh`.
- [x] Run `git diff --check`.
- [x] Run targeted text scan proving no downstream-project-specific topology was introduced into Delphi canons.
- [x] Review changed files for canonical-source consistency and record any remaining follow-up candidates.

## External Dependency Readiness
| Dependency | Why It Matters | Status (`unknown|healthy|degraded|failing|rate-limited|stale`) | Last Verified | Verification Method | Adjustment / Workaround |
| --- | --- | --- | --- | --- | --- |
| none | Instruction-only Delphi self-maintenance does not depend on external services. | `healthy` | `2026-05-25` | `n/a` | `n/a` |

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
- **Level (`small|medium|big`):** `medium`
- **Checkpoint policy:** `consolidated`
- **Why this level:** The work touches multiple instruction surfaces and mirrors but remains one method-level objective.

## Canonical Module Anchors
- **Primary module doc:** `main_instructions.md`
- **Secondary module docs (if any):**
  - `ecosystem_template_configuration.md`
  - `config/stack_capabilities.yaml`
  - `workflows/docker/delphi-project-setup-method.md`
  - `workflows/docker/environment-readiness-method.md`
  - `skills/deterministic-tooling-register.md`
- **Planned decision promotion targets (module sections):**
  - `main_instructions.md` source-of-truth and workflow discipline sections.
  - `ecosystem_template_configuration.md` stack capability model.
- **Module decision consolidation targets (required):**
  - `main_instructions.md` and `config/stack_capabilities.yaml`.

## Decision Pending
- [x] `D-01` Decide whether stack support presence should imply project activation.
- [x] `D-02` Decide where project-specific environment, tenant, and domain topology belongs.
- [x] `D-03` Decide whether to change heavy audit/post-session opt-in behavior in this slice.

## Decisions
- [x] `D-01` Capability presence does not imply activation; active stacks must be declared by downstream foundation docs, repo structure, or project-owned config/env. Ref: user instruction, `main_instructions.md` existing additive stack capability model.
- [x] `D-02` Environment, tenants, domains, runtime owners, and validation targets belong in portable foundation documentation/project-owned config/env, not hard-coded Delphi rules. Ref: user instruction, `main_instructions.md` execution owner discovery.
- [x] `D-03` Heavy audit/post-session opt-in behavior remains unchanged in this slice. Ref: user explicit "vamos manter como está."

## Module Decision Baseline Snapshot
| Module Decision Ref | Current Module Decision | Planned Handling (`Preserve|Supersede (Intentional)|Out of Scope`) | Evidence |
| --- | --- | --- | --- |
| `main_instructions.md#additive-stack-capability-model` | Stack capability availability is separate from active project topology. | `Preserve` | Existing instruction text and user confirmation. |
| `main_instructions.md#execution-owner-validation-surface-discovery` | Runtime topology must be resolved from TODO/foundation docs/readiness/project config before validation. | `Preserve` | Existing instruction text and user confirmation. |
| `main_instructions.md#post-session-review-boundary` | Post-session review behavior is still mandatory under current self-improvement policy. | `Out of Scope` | User explicitly kept this point unchanged. |

## Decision Baseline
- [x] `D-01` The registry will describe Delphi-supported capabilities, not project activation.
- [x] `D-02` Project-active stack and runtime topology must be resolved from foundation docs/project-owned config/env before commands execute.
- [x] `D-03` Heavy audit/post-session policy will not be changed in this TODO.

## Questions To Close
- [x] No open question blocks implementation; the user approved applying the listed points and excluded one point from scope.

## Assumptions Preview
| Assumption ID | Assumption | Evidence | If False | Confidence (`High|Medium|Low`) | Handling (`Keep as Assumption|Promote to Decision|Block`) |
| --- | --- | --- | --- | --- | --- |
| `A-01` | Delphi self-maintenance should not run downstream readiness checks. | `main_instructions.md` Delphi self-maintenance policy. | Validation would need downstream `verify_context.sh`. | `High` | `Keep as Assumption` |
| `A-02` | The new registry can be YAML config plus canonical prose; no deterministic parser is required in this slice. | Existing config uses YAML for ecosystem packages. | Add parser/tooling in a later TODO. | `Medium` | `Keep as Assumption` |

## Execution Plan
### Touched Surfaces
- `main_instructions.md`
- `ecosystem_template_configuration.md`
- `config/stack_capabilities.yaml`
- `workflows/docker/delphi-project-setup-method.md`
- `workflows/docker/environment-readiness-method.md`
- `skills/wf-docker-delphi-project-setup-method/SKILL.md`
- `skills/wf-docker-environment-readiness-method/SKILL.md`
- `.clinerules/**`, `.cline/skills/**`, `.claude/skills/**` mirrors as needed
- `foundation_documentation/todos/active/delphi-capability-portability-and-canonical-drift.md`

### Ordered Steps
1. Add a stack capability registry that distinguishes capability availability from project activation.
2. Update canonical instructions and ecosystem configuration to point to the registry and foundation-documentation runtime contracts.
3. Update setup/readiness workflows and skills so scripts remain available but only project-declared active stacks execute.
4. Sync Cline/Claude mirrors and reduce duplication where sync surfaces support canonical pointers.
5. Run validation and record evidence in this TODO.

### Test Strategy
- **Strategy:** `test-after`
- **Why:** This is instruction/config maintenance; correctness is validated by self-check, diff hygiene, and agnosticism scans.
- **Fail-first target(s) (when required):** `n/a`

### Flow Evidence Planning Matrix
| Criterion / Flow | Why Flow-Impacting | Platform Parity (`android-only|web-only|shared-android-web|divergent-android-web|n/a`) | Required Runtime Lane | Mutation Lane Required? | Backend Real-Data Required? | Planned Evidence | Non-Applicability Rationale |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Delphi instruction/config portability | `structure-only` | `n/a` | `n/a` | `no` | `no` | `bash self_check.sh`, `git diff --check`, text scan | No product runtime/user flow is modified. |

### Planned CI-Equivalent Suite Matrix
| Repository / CI Surface | Why In Scope | Local CI-Equivalent Command | Required Before | Planned Status | Evidence Artifact / Command | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| `delphi-ai / instruction self-check` | Rules/workflows/skills/mirrors are touched. | `bash self_check.sh` | `Local-Implemented` | `planned` | `pending` | Canonical coherence check. |
| `delphi-ai / diff hygiene` | Markdown/config edits can introduce whitespace issues. | `git diff --check` | `Local-Implemented` | `planned` | `pending` | Local static hygiene check. |

### Runtime / Rollout Notes
- No runtime rollout. Downstream projects retain current topology; new guidance only clarifies that active stack/runtime facts come from project contracts.

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
  - **Severity:** medium
  - **Evidence:** Existing hard-coded ecosystem stack language and duplicated skill bodies.
  - **Why it matters now:** Portability and future Go migration require separating ecosystem capability from project activation.
  - **Option A (Recommended):** Add a capability registry and update canons to reference it.
    - **Effort:** medium
    - **Risk:** low
    - **Blast radius:** cross-module
    - **Maintenance burden:** improves
    - **Performance impact:** neutral
    - **Elegance impact:** improves
    - **Structural soundness impact:** improves
  - **Option B (Alternative):** Only update prose in `main_instructions.md`.
    - **Effort:** low
    - **Risk:** medium
    - **Blast radius:** local
    - **Maintenance burden:** neutral
    - **Performance impact:** neutral
    - **Elegance impact:** neutral
    - **Structural soundness impact:** neutral
  - **Option C (Do Nothing):** Leave current implicit model.
    - **Effort:** low
    - **Risk:** high
    - **Blast radius:** cross-module
    - **Maintenance burden:** worsens
    - **Performance impact:** neutral
    - **Elegance impact:** worsens
    - **Structural soundness impact:** worsens
  - **Recommendation:** Option A.

### Failure Modes & Edge Cases
- [x] Registry accidentally looks like project activation; mitigate with explicit `availability` versus `activation_contract`.
- [x] Foundation docs guidance becomes downstream-project-specific; mitigate with agnosticism scan.
- [x] Mirrors drift after canonical edits; mitigate with `self_check.sh`.

### Residual Unknowns / Risks
- [x] No deterministic parser enforces the stack registry yet; leave as a future candidate unless repeated drift justifies tooling.

## Approval
- **Approved by:** user instruction on 2026-05-25: "Esses pontos você pode aplicar."
- **Scope exclusions confirmed:** keep post-session feedback/heavy audit opt-in behavior unchanged.

## Completion Evidence Matrix
| Criterion ID | Source Section | Criterion | Evidence Type | Evidence Artifact / Command | Runtime Target | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `SCOPE-01` | `Scope` | Reduce weight and duplication in older instruction surfaces where the same operational truth is copied instead of referenced. | code | `skills/wf-docker-delphi-project-setup-method/SKILL.md`, `skills/wf-docker-environment-readiness-method/SKILL.md`, `skills/rule-docker-shared-todo-driven-execution-model-decision/SKILL.md` | local | passed | Drift-prone skill bodies now delegate to canonical workflows/rules/config where practical. |
| `SCOPE-02` | `Scope` | Establish an explicit stack capability registry for Flutter, Laravel, Docker, and future Go. | config | `config/stack_capabilities.yaml` | local | passed | Registry names Docker, Flutter, Laravel, and future Go. |
| `SCOPE-03` | `Scope` | Separate "capability available in Delphi" from "stack active in a downstream project." | doc | `main_instructions.md`, `ecosystem_template_configuration.md`, `workflows/docker/delphi-project-setup-method.md` | local | passed | Canonical text distinguishes available capability from project activation. |
| `SCOPE-04` | `Scope` | Require environment, tenants, domains, runtime owners, and validation targets to come from portable contracts in `foundation_documentation` or approved project-owned config/env. | doc/tool | `main_instructions.md`, `workflows/docker/environment-readiness-method.md`, `tools/environment_readiness_report.sh` | local | passed | Runtime topology guidance now points to project-owned contract sources. |
| `SCOPE-05` | `Scope` | Consolidate canonical sources to reduce drift between skills, workflows, mirrors, and rules. | doc/code | `rules/core/workflow-definition-model-decision.md`, `workflows/docker/update-skill-method.md`, `bash self_check.sh` | local | passed | Canonical-source/mirror discipline added and generated mirrors synced. |
| `DOD-01` | `Definition of Done` | Canonical instructions explain available Delphi capability versus project-active stack selection. | doc | `main_instructions.md`, `ecosystem_template_configuration.md` | local | passed | Available-vs-active model is explicit; navigation/browser coverage not applicable because this is a structure-only instruction change with no user-visible runtime flow. |
| `DOD-02` | `Definition of Done` | Stack capability registry exists and names Flutter, Laravel, Docker, and future Go without activating stacks by presence alone. | config | `config/stack_capabilities.yaml` | local | passed | Registry includes activation contract and non-activation signals; navigation/browser coverage not applicable because this is a structure-only config change. |
| `DOD-03` | `Definition of Done` | Environment/tenant/domain guidance points to foundation documentation or project-owned config/env as the authoritative contract. | doc/tool | `workflows/docker/environment-readiness-method.md`, `tools/environment_readiness_report.sh` | local | passed | Guidance avoids guessed tenant/domain/runtime targets; navigation/browser coverage not applicable because no downstream runtime was changed. |
| `DOD-04` | `Definition of Done` | Drift-prone skills/rules/workflows touched by this change reference canonical sources instead of duplicating large bodies where practical. | code | `skills/wf-docker-delphi-project-setup-method/SKILL.md`, `skills/wf-docker-environment-readiness-method/SKILL.md`, `skills/wf-docker-update-skill-method/SKILL.md` | local | passed | Skills are concise entrypoints or explicitly direct mirrors to canonical sources. |
| `DOD-05` | `Definition of Done` | Mirrors for Cline/Claude-compatible surfaces are synchronized. | test/manual | `bash self_check.sh`; manual `cp` sync for touched `.claude/skills/**`; `.claude/rules/00-main-instructions.md`; `.claude/rules/07-shared-model-decisions.md` | local | passed | Cline/Codex mirrors passed self-check; touched Claude skills match canonical copies where applicable. |
| `VAL-01` | `Validation Steps` | Run `bash self_check.sh`. | test | `bash self_check.sh` | local | passed | Individual failures: 0; coherence failures: 0. |
| `VAL-02` | `Validation Steps` | Run `git diff --check`. | test | `git diff --check` | local | passed | No whitespace errors. |
| `VAL-03` | `Validation Steps` | Run targeted text scan proving no downstream-project-specific topology was introduced into Delphi canons. | test | `rg -n -e "Belluga Now" -e "belluga_now" -e "belluga-now" -e "Landlord host hint" main_instructions.md ecosystem_template_configuration.md config rules workflows skills tools .clinerules .cline .claude` | local | passed | No matches after cleanup. |
| `VAL-04` | `Validation Steps` | Review changed files for canonical-source consistency and record any remaining follow-up candidates. | review | `git diff --name-only`; manual review of canonical/mirror surfaces | local | passed | Follow-up candidates remain limited to optional deeper static registry/parser tooling and further large-skill splitting. |

## Local CI-Equivalent Suite Matrix
| Repository / CI Surface | Why In Scope | Local CI-Equivalent Command | Required Before | Status | Evidence Artifact / Command | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| `delphi-ai / instruction self-check` | Rules/workflows/skills/mirrors were touched. | `bash self_check.sh` | `Local-Implemented` | passed | `bash self_check.sh` | Individual failures: 0; coherence failures: 0. |
| `delphi-ai / completion guard regression` | `tools/todo_completion_guard.py` and its tests were already part of this branch diff. | `bash tools/tests/todo_completion_guard_test.sh` | `Local-Implemented` | passed | `bash tools/tests/todo_completion_guard_test.sh` | Guard regression script returned OK. |
| `delphi-ai / Python syntax` | Completion guard Python changed in this branch. | `python3 -m py_compile tools/todo_completion_guard.py` | `Local-Implemented` | passed | `python3 -m py_compile tools/todo_completion_guard.py` | No syntax errors. |
| `delphi-ai / shell syntax` | Shell tooling changed in this branch. | `bash -n tools/bootstrap_stack.sh tools/environment_readiness_report.sh scripts/docker/verify_environment.sh tools/tests/todo_completion_guard_test.sh` | `Local-Implemented` | passed | `bash -n tools/bootstrap_stack.sh tools/environment_readiness_report.sh scripts/docker/verify_environment.sh tools/tests/todo_completion_guard_test.sh` | No shell syntax errors. |
| `delphi-ai / diff hygiene` | Markdown/config/tool edits can introduce whitespace issues. | `git diff --check` | `Local-Implemented` | passed | `git diff --check` | No whitespace errors. |

## Pipeline/Copilot P1/P2 Preflight
| Reviewer Surface / Package | Review Focus | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| bounded branch diff + local validation evidence | CI/Copilot P1/P2 defects in instruction, mirror, config, and tooling changes | passed | `bash self_check.sh`; `bash tools/tests/todo_completion_guard_test.sh`; `git diff --check`; manual diff review | none | Review complete; clean. |

## Rule-Spirit Anti-Pattern Hunt
| Rule / Principle Surface | Bypass or Anti-Pattern Search Lens | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| Agnosticism, capability activation, foundation-doc runtime contracts, canonical-source discipline | Looked for project topology hard-coding, capability-presence-as-activation, mirror-only behavior changes, and duplicated skill bodies that should delegate to canons. | passed | `rg -n -e "Belluga Now" -e "belluga_now" -e "belluga-now" -e "Landlord host hint" main_instructions.md ecosystem_template_configuration.md config rules workflows skills tools .clinerules .cline .claude`; `git diff --name-only`; `bash self_check.sh` | no P1 or P2 anti-pattern findings | Project-specific `.claude` leftovers were removed; registry and canonical-source pointers reduce drift. |
