# TODO: Delphi TODO Closeout Disposition Guard

## Artifact Identity
- **Artifact type:** `tactical_execution_contract`

## Context
The model-upgrade follow-up validation approved `C-07`: stale active TODOs are not just a detection problem; the TODO process itself has been leaving delivered work behind in `active/`. This slice adds an explicit closeout disposition step and a deterministic guard so delivered TODOs must be moved, promoted, blocked, or kept active for a real remaining reason.

## Framing Source & Story Slice
- **Feature brief:** `direct-to-todo`
- **Primary story ID:** `C-07`
- **Why this is the right current slice:** This is one Delphi self-maintenance improvement to close the process gap after delivery evidence, commit/push, or lane movement.
- **Direct-to-TODO rationale:** The user approved the C-07 refinement after agreeing that the issue was caused by the TODO process itself leaving stale active TODOs behind.

## Contract Boundary
- This TODO adds process enforcement and a guard; it does not auto-move TODO files.
- The guard may classify stale active TODOs and block closeout handoff, but the agent must still make the path/status change intentionally.
- Cleanup of already delivered C-04 and C-06 TODOs is in scope as the first application of the new closeout rule.

## Delivery Status Canon
- **Current delivery stage:** `Completed`
- **Qualifiers:** `none`
- **Next exact step:** `n/a - local-only Delphi self-maintenance slice completed and moved to completed/ before commit/push.`

## Scope
- [x] Add a deterministic closeout guard that validates delivered active TODO disposition.
- [x] Add regression coverage for missing disposition, valid pending move, stale keep-active, completed-but-still-active, blocked, and all-active advisory scan cases.
- [x] Update closeout workflow, TODO-driven umbrella, template, tool manifest, and deterministic tooling register to require closeout disposition.
- [x] Move already delivered local-only C-04 and C-06 TODOs from `active/` to `completed/` as C-07 cleanup.
- [x] Preserve non-mutating behavior: the tool reports and blocks but never moves files automatically.

## Out of Scope
- [ ] Auto-move TODO files.
- [ ] Make `self_check.sh` fail on all stale active TODOs by default.
- [ ] Change downstream Belluga Now project code or project-specific TODOs.
- [ ] Change GitHub promotion semantics beyond closeout disposition evidence.

## Definition of Done
- [x] A new guard exists for closeout disposition and active stale detection.
- [x] Delivered active TODOs require one of `keep-active`, `move-promotion-lane`, `move-completed`, or `blocked`.
- [x] `keep-active` requires an actionable remaining next step, not a stale chat/report step.
- [x] Move dispositions become blockers once commit/push is complete or git is synced and the TODO remains in `active/`.
- [x] Canonical workflow/template/skill surfaces tell agents to run the guard and record the disposition.

## Validation Steps
- [x] Run `python3 -m py_compile tools/todo_closeout_guard.py`.
- [x] Run `bash tools/tests/todo_closeout_guard_test.sh`.
- [x] Run `python3 tools/todo_closeout_guard.py foundation_documentation/todos/completed/delphi-todo-closeout-disposition-guard.md`.
- [x] Run `python3 tools/todo_closeout_guard.py --repo . --all-active --advisory --json-output /tmp/delphi-todo-closeout-guard.json`.
- [x] Run `bash self_check.sh`.
- [x] Run `python3 tools/todo_authority_guard.py foundation_documentation/todos/completed/delphi-todo-closeout-disposition-guard.md --require-delivery-gates`.
- [x] Run `python3 tools/todo_completion_guard.py foundation_documentation/todos/completed/delphi-todo-closeout-disposition-guard.md`.

## Completion Evidence Matrix
| Criterion ID | Source Section | Criterion | Evidence Type | Evidence Artifact / Command | Runtime Target | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `SCOPE-01` | `Scope` | Add a deterministic closeout guard that validates delivered active TODO disposition. | code | `tools/todo_closeout_guard.py` | local | passed | New guard implemented. |
| `SCOPE-02` | `Scope` | Add regression coverage for missing disposition, valid pending move, stale keep-active, completed-but-still-active, blocked, and all-active advisory scan cases. | test | `bash tools/tests/todo_closeout_guard_test.sh` | local | passed | Fixture suite covers all listed cases. |
| `SCOPE-03` | `Scope` | Update closeout workflow, TODO-driven umbrella, template, tool manifest, and deterministic tooling register to require closeout disposition. | docs | `workflows/docker/todo-closeout-promotion-method.md`; `workflows/docker/todo-driven-execution-method.md`; `templates/todo_template.md`; `tools/manifest.md`; `skills/deterministic-tooling-register.md` | local | passed | Canonical and mirror surfaces updated. |
| `SCOPE-04` | `Scope` | Move already delivered local-only C-04 and C-06 TODOs from `active/` to `completed/` as C-07 cleanup. | file move | `git mv foundation_documentation/todos/active/delphi-todo-authority-and-promotion-guard.md foundation_documentation/todos/completed/`; `git mv foundation_documentation/todos/active/delphi-rule-spirit-scanner-severity-allowlist.md foundation_documentation/todos/completed/` | local | passed | Completed TODOs now have completed delivery status. |
| `SCOPE-05` | `Scope` | Preserve non-mutating behavior: the tool reports and blocks but never moves files automatically. | code review | `tools/todo_closeout_guard.py` | local | passed | Tool only reads TODOs, prints/writes JSON reports, and exits with guard status. |
| `DOD-01` | `Definition of Done` | A new guard exists for closeout disposition and active stale detection. | code + test | `tools/todo_closeout_guard.py`; `bash tools/tests/todo_closeout_guard_test.sh` | local | passed | Guard classifies active delivered TODOs. |
| `DOD-02` | `Definition of Done` | Delivered active TODOs require one of `keep-active`, `move-promotion-lane`, `move-completed`, or `blocked`. | test | `bash tools/tests/todo_closeout_guard_test.sh` | local | passed | Missing/invalid disposition is blocked. |
| `DOD-03` | `Definition of Done` | `keep-active` requires an actionable remaining next step, not a stale chat/report step. | test | `bash tools/tests/todo_closeout_guard_test.sh` | local | passed | Stale keep-active fixture blocks. |
| `DOD-04` | `Definition of Done` | Move dispositions become blockers once commit/push is complete or git is synced and the TODO remains in `active/`. | test | `bash tools/tests/todo_closeout_guard_test.sh` | local | passed | Complete-post-push fixture blocks while still in `active/`. |
| `DOD-05` | `Definition of Done` | Canonical workflow/template/skill surfaces tell agents to run the guard and record the disposition. | docs + self-check | `bash self_check.sh` | local | passed | Individual files checked: 203; individual failures: 0; coherence failures: 0. |
| `VAL-01` | `Validation Steps` | Run `python3 -m py_compile tools/todo_closeout_guard.py`. | test | `python3 -m py_compile tools/todo_closeout_guard.py` | local | passed | Command exited 0. |
| `VAL-02` | `Validation Steps` | Run `bash tools/tests/todo_closeout_guard_test.sh`. | test | `bash tools/tests/todo_closeout_guard_test.sh` | local | passed | Output: `todo_closeout_guard_test: OK`. |
| `VAL-03` | `Validation Steps` | Run `python3 tools/todo_closeout_guard.py foundation_documentation/todos/completed/delphi-todo-closeout-disposition-guard.md`. | guard | `python3 tools/todo_closeout_guard.py foundation_documentation/todos/completed/delphi-todo-closeout-disposition-guard.md` | local | passed | Guard result: `Overall outcome: go`. |
| `VAL-04` | `Validation Steps` | Run `python3 tools/todo_closeout_guard.py --repo . --all-active --advisory --json-output /tmp/delphi-todo-closeout-guard.json`. | guard | `python3 tools/todo_closeout_guard.py --repo . --all-active --advisory --json-output /tmp/delphi-todo-closeout-guard.json` | local | passed | All-active advisory result: `Overall outcome: go`; active TODO count: 2. |
| `VAL-05` | `Validation Steps` | Run `bash self_check.sh`. | test | `bash self_check.sh` | local | passed | Individual files checked: 203; individual failures: 0; coherence failures: 0. |
| `VAL-06` | `Validation Steps` | Run `python3 tools/todo_authority_guard.py foundation_documentation/todos/completed/delphi-todo-closeout-disposition-guard.md --require-delivery-gates`. | guard | `python3 tools/todo_authority_guard.py foundation_documentation/todos/completed/delphi-todo-closeout-disposition-guard.md --require-delivery-gates` | local | passed | Guard result: `Overall outcome: go`. |
| `VAL-07` | `Validation Steps` | Run `python3 tools/todo_completion_guard.py foundation_documentation/todos/completed/delphi-todo-closeout-disposition-guard.md`. | guard | `python3 tools/todo_completion_guard.py foundation_documentation/todos/completed/delphi-todo-closeout-disposition-guard.md` | local | passed | Guard result: `Overall outcome: go`. |

## External Dependency Readiness
| Dependency | Why It Matters | Status | Last Verified | Verification Method | Adjustment / Workaround |
| --- | --- | --- | --- | --- | --- |
| none | This is local Delphi tooling, workflow, and documentation work. | `healthy` | `2026-05-25` | `n/a` | `n/a` |

## Profile Scope & Handoffs
- **Primary execution profile:** `strategic-cto`
- **Active technical scope:** `delphi-self-maintenance`
- **Expected supporting profiles:** `operational-coder`
- **Scope-check command:** `n/a - Delphi self-maintenance repository has no project profile checker in scope for this slice`

## Complexity
- **Level (`small|medium|big`):** `medium`
- **Checkpoint policy:** `single approved C-07 slice; implementation may proceed inside this TODO`
- **Why this level:** The change adds a new guard, workflow/template requirements, mirror synchronization, and cleanup of stale active TODOs.

## Canonical Module Anchors
- **Primary module doc:** `workflows/docker/todo-closeout-promotion-method.md`
- **Secondary module docs:**
  - `rules/core/todo-driven-execution-model-decision.md`
  - `workflows/docker/todo-driven-execution-method.md`
  - `skills/wf-docker-todo-closeout-promotion-method/SKILL.md`
  - `templates/todo_template.md`
  - `skills/deterministic-tooling-register.md`
- **Planned decision promotion targets (module sections):**
  - TODO closeout disposition enforcement
- **Module decision consolidation targets (required):**
  - `rules/core/todo-driven-execution-model-decision.md`
  - `workflows/docker/todo-closeout-promotion-method.md`
  - `workflows/docker/todo-driven-execution-method.md`
  - `skills/wf-docker-todo-closeout-promotion-method/SKILL.md`
  - `templates/todo_template.md`
  - `skills/deterministic-tooling-register.md`

## Decisions
- [x] `D-01` C-07 is process enforcement plus guard, not only a post-facto stale auditor.
- [x] `D-02` The guard is non-mutating: it reports and blocks, while the agent performs intentional file/status moves.
- [x] `D-03` Delivered active TODOs must declare one closeout disposition before the agent pauses or hands off.

## Decision Baseline
- [x] `D-01` Closeout disposition is part of the TODO-driven process.
- [x] `D-02` Guard does not auto-move files.
- [x] `D-03` Stale delivered TODOs in `active/` are process defects unless they have a real remaining active reason.

## Approval
- **Approved by:** user approved C-07 implementation on 2026-05-25 with "Perfeito, siga assim."
- **Approval scope:** implement the refined C-07 package: process-level closeout disposition, deterministic closeout guard, fixtures, canonical workflow/template updates, and cleanup of already delivered C-04/C-06 active TODOs.
- **Execution not authorized by approval:** automatic file moves by the guard, downstream project changes, or default self-check failure on every stale active TODO.
- **Renewed approval required when:** closeout guard starts mutating files, becomes a default global CI blocker, or changes GitHub promotion topology.

## Rules Acknowledgement / Ingestion
| Source | Why It Applies Now | Must Preserve | Must Avoid | Execution Impact |
| --- | --- | --- | --- | --- |
| `rules/core/todo-driven-execution-model-decision.md` | C-07 changes the TODO-driven closeout state machine. | Approval, delivery gates, and same-governing-TODO promotion follow-through. | Leaving stable outcomes only in chat or active stale TODOs. | Add closeout disposition as a visible gate. |
| `workflows/docker/todo-closeout-promotion-method.md` | This is the primary process gap being fixed. | Deliberate `active/`, `promotion_lane/`, `completed/`, or `blocked` routing. | Auto-moving files or forcing new TODOs for promotion follow-through. | Require disposition and closeout guard. |
| `workflows/docker/update-skill-method.md` | C-07 changes workflows, skills, mirrors, template, and tooling register. | Canonical and mirror surfaces must stay synchronized. | Tool behavior that exists only in the script. | Run self-check after docs. |
| `workflows/docker/deterministic-todo-validation-method.md` | The new guard adds deterministic closeout validation. | Guard output is evidence; final movement remains intentional. | Treating a guard pass as a substitute for actual path/status movement. | Add fixture tests and JSON output. |

## Local CI-Equivalent Suite Matrix
| Repository / CI Surface | Why In Scope | Local CI-Equivalent Command | Required Before | Status | Evidence Artifact / Command | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| delphi-ai / closeout guard compile | New Python guard. | `python3 -m py_compile tools/todo_closeout_guard.py` | Local-Implemented | passed | `python3 -m py_compile tools/todo_closeout_guard.py` | Compile passed. |
| delphi-ai / closeout guard fixtures | New deterministic behavior. | `bash tools/tests/todo_closeout_guard_test.sh` | Local-Implemented | passed | `bash tools/tests/todo_closeout_guard_test.sh` | Fixture suite passed. |
| delphi-ai / self-check | Workflow, skill, template, manifest, register, and mirrors changed. | `bash self_check.sh` | Local-Implemented | passed | `bash self_check.sh` | Individual files checked: 203; individual failures: 0; coherence failures: 0. |

## Pipeline/Copilot P1/P2 Preflight
| Reviewer Surface / Package | Review Focus | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| C-07 closeout package | Priority risks in closeout guard parsing, false stale detection, auto-mutation risk, and mirror drift | passed | `python3 -m py_compile tools/todo_closeout_guard.py`; `bash tools/tests/todo_closeout_guard_test.sh`; `bash self_check.sh` | none | Guard is non-mutating and fixture-covered. |

## Rule-Spirit Anti-Pattern Hunt
| Rule / Principle Surface | Bypass or Anti-Pattern Search Lens | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| TODO closeout process | Process bypass that satisfies delivery gates but leaves stale active TODOs behind | passed | `python3 tools/todo_closeout_guard.py --repo . --all-active --advisory --json-output /tmp/delphi-todo-closeout-guard.json`; `bash tools/rule_spirit_anti_pattern_scan.sh --repo . --stack all --path tools --path skills --path workflows --path rules --path templates --path foundation_documentation/todos/active --json-output /tmp/delphi-rule-spirit-c07.json` | closeout guard reports `go`; rule-spirit scan reports 9 review-level heuristic findings and no blocker | C-07 fixes the process escape by requiring disposition and moving C-04/C-06 to completed. |

## TODO Closeout Disposition
- **Disposition:** `move-completed`
- **Disposition reason:** This is local-only Delphi self-maintenance; after validation and commit/push, no promotion lane remains for C-07.
- **Post-commit/push status:** `complete`
- **Next path/status action:** `n/a - TODO moved to foundation_documentation/todos/completed/delphi-todo-closeout-disposition-guard.md.`

## Security Risk Assessment
- **Risk level:** `low`
- **Why this risk level:** The guard reads local markdown TODO files and optional git metadata; it does not mutate files or process secrets.
- **Attack surface in scope:** local CLI invocation and optional JSON report path.
- **Attack simulation decision:** `not_needed`
- **Review evidence:** fixture suite validates parser behavior; code review confirms no file move or write except requested JSON output.
- **Residual security risk:** malformed TODO text may produce a conservative blocker.

## Performance & Concurrency Risk Assessment
- **Policy schema version:** `pcv-1`
- **Global sensitivity level:** `low`
- **Why this level:** The guard scans local markdown files and runs small git metadata commands.
- **Current delivery stage at review time:** `Local-Implemented`
- **Concurrency surfaces in scope:** none.
- **Performance evidence:** fixture and all-active advisory scans run locally.
- **Residual performance risk:** large TODO trees may use single-TODO mode during closeout.

## Promotion Finding Routing Ledger
| Finding ID | Severity | Classification | Routing Decision | Same TODO / Split Rationale | Status | Approval / Follow-up Reference |
| --- | --- | --- | --- | --- | --- | --- |
| `n/a` | `n/a` | `n/a` | `n/a` | This TODO is local-only Delphi self-maintenance, not a GitHub promotion lane. | `accepted` | `n/a` |
