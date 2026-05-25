# TODO: Delphi Model Upgrade Follow-up Validation

## Artifact Identity
- **Artifact type:** `tactical_execution_contract`

## Context
The model-upgrade branch is locally delivered and pushed. A follow-up assessment identified additional improvement candidates that should not be implemented silently because they vary in urgency, determinism value, and blast radius. This TODO exists to validate those candidates point by point before opening implementation work.

## Framing Source & Story Slice
- **Feature brief:** `direct-to-todo`
- **Primary story ID:** `n/a`
- **Why this is the right current slice:** The user requested a point-by-point validation TODO for the remaining model-upgrade improvement space.
- **Direct-to-TODO rationale:** This is a bounded Delphi self-maintenance validation ledger. It does not authorize implementation until the user selects which points proceed and approves the resulting execution boundary.

## Contract Boundary
- This TODO defines **WHAT must be validated**, not yet what must be implemented.
- Implementation scope remains pending until each candidate is classified as `approve|reject|split|defer`.
- Any approved implementation package must refresh this TODO or split into a narrower tactical TODO before file changes outside `foundation_documentation/todos/**`.

## Delivery Status Canon (Required)
- **Current delivery stage:** `Completed`
- **Qualifiers:** `none`
- **Next exact step:** `n/a - validation ledger closed after C-01 through C-07 were decided, implemented, and closed.`

## Scope
- [x] Validate whether the environment-topology template drift should be fixed immediately: the scaffold uses `Activation Evidence State`, while the template still says `Active? yes/no/unknown`.
- [x] Validate whether to add a deterministic stage-promotion scenario classifier for `docker-normal`, `docker-bot-next-version`, `docker-mixed`, `flutter-only`, `laravel-only`, and `flutter-laravel`.
- [x] Validate whether `environment_topology_contract_scaffold.py` should derive stack detection markers from `config/stack_capabilities.yaml` instead of hard-coding stack checks.
- [x] Validate whether `todo_completion_guard.py` or a companion guard should check objective evidence for `APROVADO`, rule ingestion, and delivery-gate execution.
- [x] Validate whether `validate_phase_surfaces.py` should read phase groups from declarative config instead of hard-coded Python tuples.
- [x] Validate whether `rule_spirit_anti_pattern_scan.sh` should gain severity classification, allowlist support, and machine-readable output such as JSON or SARIF.
- [x] Validate whether Delphi should add deterministic stale-closeout detection for TODOs whose `Next exact step` is already satisfied after commit/push or lane movement.

## Out of Scope
- [ ] Promote `model-upgrade/delphi-instruction-modernization` to `main`.
- [ ] Change downstream Belluga Now project code or project-specific documentation.
- [ ] Implement Go stack workflows beyond the existing future-capability slot.
- [ ] Change post-session feedback or heavy-audit opt-in/risk-trigger policy.

## Definition of Done
- [x] Each candidate has a recorded decision: `approve`, `reject`, `split`, or `defer`.
- [x] Approved candidates have a bounded implementation path and validation expectation.
- [x] Rejected or deferred candidates include the reason and revisit trigger.
- [x] Split candidates name the follow-up TODO or story slice to create.

## Validation Steps
- [x] Review each candidate with the user.
- [x] Update the `Candidate Validation Matrix`.
- [x] If any implementation is approved, refresh or split the TODO before implementation begins.
- [x] Before any delivery claim for this TODO, run `python3 tools/todo_completion_guard.py <this-todo>` and require `Overall outcome: go`.

## Completion Evidence Matrix
| Criterion ID | Source Section | Criterion | Evidence Type | Evidence Artifact / Command | Runtime Target | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `SCOPE-01` | `Scope` | Validate whether the environment-topology template drift should be fixed immediately: the scaffold uses `Activation Evidence State`, while the template still says `Active? yes/no/unknown`. | matrix | `Candidate Validation Matrix` row `C-01`; `templates/environment_topology_contract_template.md` | local | passed | Approved and implemented. |
| `SCOPE-02` | `Scope` | Validate whether to add a deterministic stage-promotion scenario classifier for `docker-normal`, `docker-bot-next-version`, `docker-mixed`, `flutter-only`, `laravel-only`, and `flutter-laravel`. | matrix | `Candidate Validation Matrix` row `C-02`; `tools/github_stage_promotion_scenario_classifier.py` | local | passed | Approved and implemented. |
| `SCOPE-03` | `Scope` | Validate whether `environment_topology_contract_scaffold.py` should derive stack detection markers from `config/stack_capabilities.yaml` instead of hard-coding stack checks. | matrix | `Candidate Validation Matrix` row `C-03`; `config/stack_capabilities.yaml`; `tools/environment_topology_contract_scaffold.py` | local | passed | Approved and implemented. |
| `SCOPE-04` | `Scope` | Validate whether `todo_completion_guard.py` or a companion guard should check objective evidence for `APROVADO`, rule ingestion, and delivery-gate execution. | matrix | `Candidate Validation Matrix` row `C-04`; `foundation_documentation/todos/completed/delphi-todo-authority-and-promotion-guard.md` | local | passed | Split, implemented, and closed. |
| `SCOPE-05` | `Scope` | Validate whether `validate_phase_surfaces.py` should read phase groups from declarative config instead of hard-coded Python tuples. | matrix | `Candidate Validation Matrix` row `C-05`; `config/phase_surfaces.yaml`; `tools/validate_phase_surfaces.py` | local | passed | Approved and implemented. |
| `SCOPE-06` | `Scope` | Validate whether `rule_spirit_anti_pattern_scan.sh` should gain severity classification, allowlist support, and machine-readable output such as JSON or SARIF. | matrix | `Candidate Validation Matrix` row `C-06`; `foundation_documentation/todos/completed/delphi-rule-spirit-scanner-severity-allowlist.md` | local | passed | Split, implemented, and closed. |
| `SCOPE-07` | `Scope` | Validate whether Delphi should add deterministic stale-closeout detection for TODOs whose `Next exact step` is already satisfied after commit/push or lane movement. | matrix | `Candidate Validation Matrix` row `C-07`; `foundation_documentation/todos/completed/delphi-todo-closeout-disposition-guard.md` | local | passed | Approved, implemented, and closed. |
| `DOD-01` | `Definition of Done` | Each candidate has a recorded decision: `approve`, `reject`, `split`, or `defer`. | matrix | `Candidate Validation Matrix` | local | passed | C-01 through C-07 have decisions. |
| `DOD-02` | `Definition of Done` | Approved candidates have a bounded implementation path and validation expectation. | matrix | `Candidate Validation Matrix`; completed split TODOs | local | passed | Approved/split candidates cite artifacts; structure-only governance ledger with no browser/device/runtime user flow. |
| `DOD-03` | `Definition of Done` | Rejected or deferred candidates include the reason and revisit trigger. | review | `Candidate Validation Matrix` | local | passed | No candidate ended as reject/defer; all were approved or split with rationale. |
| `DOD-04` | `Definition of Done` | Split candidates name the follow-up TODO or story slice to create. | matrix | `Candidate Validation Matrix` rows `C-04`, `C-06`; completed split TODOs | local | passed | Split candidates cite completed TODO paths. |
| `VAL-01` | `Validation Steps` | Review each candidate with the user. | approval log | `Approval` section | local | passed | User approved C-01 through C-07 in sequence. |
| `VAL-02` | `Validation Steps` | Update the `Candidate Validation Matrix`. | doc | `Candidate Validation Matrix` | local | passed | Matrix is current; structure-only governance ledger with no browser/device/runtime user flow. |
| `VAL-03` | `Validation Steps` | If any implementation is approved, refresh or split the TODO before implementation begins. | doc | completed split TODOs and matrix rows | local | passed | C-04 and C-06 split; other approved candidates were bounded in this ledger or dedicated TODOs. |
| `VAL-04` | `Validation Steps` | Before any delivery claim for this TODO, run `python3 tools/todo_completion_guard.py <this-todo>` and require `Overall outcome: go`. | guard | `python3 tools/todo_completion_guard.py foundation_documentation/todos/completed/delphi-model-upgrade-follow-up-validation.md` | local | passed | Command executed during closeout validation. |

## Local CI-Equivalent Suite Matrix
| Repository / CI Surface | Why In Scope | Local CI-Equivalent Command | Required Before | Status | Evidence Artifact / Command | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| delphi-ai / closeout guard all-active | Ledger closure should leave no stale delivered active TODO. | `python3 tools/todo_closeout_guard.py --repo . --all-active --advisory --json-output /tmp/delphi-close-ledger-closeout.json` | Completed | passed | `python3 tools/todo_closeout_guard.py --repo . --all-active --advisory --json-output /tmp/delphi-close-ledger-closeout.json` | Command executed during closeout validation. |
| delphi-ai / TODO completion guard | Completed ledger needs criterion-specific close evidence. | `python3 tools/todo_completion_guard.py foundation_documentation/todos/completed/delphi-model-upgrade-follow-up-validation.md` | Completed | passed | `python3 tools/todo_completion_guard.py foundation_documentation/todos/completed/delphi-model-upgrade-follow-up-validation.md` | Command executed during closeout validation. |

## Pipeline/Copilot P1/P2 Preflight
| Reviewer Surface / Package | Review Focus | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| model-upgrade follow-up validation ledger closeout | Closure risks: undecided candidate left open, stale next step, or missing completed split TODO reference | passed | `python3 tools/todo_authority_guard.py foundation_documentation/todos/completed/delphi-model-upgrade-follow-up-validation.md --require-delivery-gates`; `python3 tools/todo_closeout_guard.py --repo . --all-active --advisory --json-output /tmp/delphi-close-ledger-closeout.json` | none | No undecided candidate remains; active closeout guard is clean. |

## Rule-Spirit Anti-Pattern Hunt
| Rule / Principle Surface | Bypass or Anti-Pattern Search Lens | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| TODO-driven closeout and validation ledger | Closing the ledger while hiding undecided implementation work, stale active TODOs, or missing split references | passed | `python3 tools/todo_closeout_guard.py --repo . --all-active --advisory --json-output /tmp/delphi-close-ledger-closeout.json`; `python3 tools/todo_completion_guard.py foundation_documentation/todos/completed/delphi-model-upgrade-follow-up-validation.md` | none | C-01 through C-07 are decided; split TODOs are completed; active guard is clean. |

## TODO Closeout Disposition
- **Disposition:** `move-completed`
- **Disposition reason:** All validation candidates C-01 through C-07 were decided, implemented, and closed or referenced from this ledger.
- **Post-commit/push status:** `complete`
- **Next path/status action:** `n/a - TODO moved to foundation_documentation/todos/completed/delphi-model-upgrade-follow-up-validation.md.`

## External Dependency Readiness
| Dependency | Why It Matters | Status | Last Verified | Verification Method | Adjustment / Workaround |
| --- | --- | --- | --- | --- | --- |
| none | This validation TODO is local Delphi self-maintenance planning. | `healthy` | `2026-05-25` | `n/a` | `n/a` |

## Profile Scope & Handoffs
- **Primary execution profile:** `strategic-cto`
- **Active technical scope:** `delphi-self-maintenance`
- **Expected supporting profiles:** `none until an implementation candidate is approved`
- **Scope-check command:** `n/a - validation-only TODO updates`

## Complexity
- **Level (`small|medium|big`):** `medium`
- **Checkpoint policy:** `point-by-point validation before implementation`
- **Why this level:** The candidate list spans templates, promotion tooling, topology detection, TODO gates, phase validation, and anti-pattern scanning.

## Canonical Module Anchors
- **Primary module doc:** `main_instructions.md`
- **Secondary module docs:**
  - `templates/environment_topology_contract_template.md`
  - `tools/environment_topology_contract_scaffold.py`
  - `tools/todo_completion_guard.py`
  - `tools/validate_phase_surfaces.py`
  - `tools/rule_spirit_anti_pattern_scan.sh`
  - `skills/github-stage-promotion-orchestrator/SKILL.md`
  - `config/stack_capabilities.yaml`
- **Planned decision promotion targets (module sections):**
  - To be selected after candidate validation.
- **Module decision consolidation targets (required):**
  - To be selected after candidate validation.

## Candidate Validation Matrix
| Candidate ID | Candidate | Default Recommendation | User Decision (`approve|reject|split|defer|pending`) | Rationale / Revisit Trigger |
| --- | --- | --- | --- | --- |
| `C-01` | Fix environment topology template drift from `Active? yes|no|unknown` to activation evidence state language. | `approve` | `approve` | Approved by user on 2026-05-25 and implemented in `templates/environment_topology_contract_template.md`; small, low-risk consistency fix that prevents manual reintroduction of active-stack inference. |
| `C-02` | Add deterministic stage-promotion scenario classifier. | `approve` | `approve` | Approved by user on 2026-05-25 and implemented as `tools/github_stage_promotion_scenario_classifier.py` with fixture coverage; advisory only and not promotion authorization. |
| `C-03` | Make topology scaffold stack detection registry-driven. | `approve` | `approve` | Approved by user on 2026-05-25 and implemented through `config/stack_capabilities.yaml` `detection_markers`, scaffold registry parsing, validator coverage, and fixture proof with an extra registry-defined stack. |
| `C-04` | Add objective guard support for `APROVADO`, rule ingestion, and delivery-gate evidence. | `split` | `split` | Approved by user on 2026-05-25 as a split slice. Implemented and closed in `foundation_documentation/todos/completed/delphi-todo-authority-and-promotion-guard.md`, with promotion finding routing included so P1/P2 blocks delivery claims without forcing a new TODO for every same-scope remediation. |
| `C-05` | Move phase-surface groups from hard-coded Python to declarative config. | `approve` | `approve` | Approved by user on 2026-05-25 and implemented via `config/phase_surfaces.yaml`, `tools/validate_phase_surfaces.py` config parsing, and `tools/tests/validate_phase_surfaces_test.sh`; reduces validator drift when new phase-split skills are added. |
| `C-06` | Improve Rule-Spirit scanner with severities, allowlist, and JSON/SARIF output. | `split` | `split` | Approved by user on 2026-05-25 as a split slice and implemented/closed in `foundation_documentation/todos/completed/delphi-rule-spirit-scanner-severity-allowlist.md`; JSON output is in scope, while SARIF is deferred until the JSON schema stabilizes. |
| `C-07` | Add stale TODO closeout detection for satisfied `Next exact step` / stale active close-claim states. | `approve` | `approve` | Approved by user on 2026-05-25 and implemented/closed in `foundation_documentation/todos/completed/delphi-todo-closeout-disposition-guard.md`; scope includes process-level closeout disposition, a non-mutating guard, and cleanup of delivered C-04/C-06 TODOs from `active/` to `completed/`. |

## Questions To Close
- [x] Which candidates are approved for immediate implementation?
- [x] Which candidates should be split into independent TODOs?
- [x] Should any candidate be rejected or deferred until after `model-upgrade` reaches `main`?

## Approval
- **Approved by:** user approved `C-01` on 2026-05-25 with "Aprovado ponto #1."; user approved `C-02` on 2026-05-25 with "Aprovado também!"; user approved `C-03` on 2026-05-25 with "Pode implementar os já aprovados, acho que de C1 a C3"; user approved split implementation for `C-04` on 2026-05-25 with "Perfeito. Aprovado."; user approved `C-05` on 2026-05-25 with "OK. Aprovado C-05."; user approved `C-06` split implementation on 2026-05-25 with "Na sequência, pode fazer de acordo com sua recomendação."; user approved `C-07` implementation on 2026-05-25 with "Perfeito, siga assim."
- **Approval scope:** `C-01`, `C-02`, `C-03`, split implementation of `C-04`, `C-05`, split implementation of `C-06`, and `C-07` closeout-disposition implementation.

## Rules Acknowledgement / Ingestion
| Source | Why It Applies Now | Must Preserve | Must Avoid | Execution Impact |
| --- | --- | --- | --- | --- |
| `rules/core/todo-driven-execution-model-decision.md` | This validation ledger is authorizing approved implementation slices. | Explicit approval scope and bounded execution per candidate. | Treating pending candidates as approved. | Record approvals and keep remaining candidates pending. |
| `workflows/docker/update-skill-method.md` | `C-05` changes validator/config surfaces used by self-check and skill coherence. | Canonical, mirror, and tooling-register surfaces must stay coherent. | Hidden hard-coded phase groups in Python. | Move phase groups to config and add fixture tests for the validator. |
| `workflows/docker/deterministic-todo-validation-method.md` | `C-05` adds a declarative config read by deterministic validation tooling. | Config must remain deterministic, human-reviewable, and self-check compatible. | Project-specific or runtime activation facts in phase config. | Store phase group membership only in `config/phase_surfaces.yaml`. |
| `workflows/docker/todo-execution-boundary-method.md` | `C-04` is now active process guard for approved implementation slices. | Approval and rule-ingestion evidence must be TODO-native. | Chat-only authority or fake process evidence. | Run authority guard against this validation TODO after recording C-05 approval/rules. |
| `workflows/docker/todo-delivery-gates-method.md` | `C-06` changes support tooling for the Rule-Spirit Anti-Pattern Hunt. | Scanner output remains evidence input, with human P1/P2 judgment preserved. | Hidden permanent allowlists or scanner-only adjudication. | Split C-06 into a bounded scanner/tooling TODO and keep SARIF out of this slice. |
| `workflows/docker/todo-closeout-promotion-method.md` | `C-07` changes the closeout process itself. | Delivered TODOs must move, promote, block, or keep active only with a real remaining reason. | Post-facto stale audit without process enforcement, or automatic file mutation by tooling. | Add closeout disposition and a non-mutating guard. |
