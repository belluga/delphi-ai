# TODO — Support standalone Foundation repositories in the closeout guard

## Artifact Identity

- **Artifact type:** `tactical_execution_contract`
- **Lifecycle state:** `Active — planning`
- **Created:** `2026-09-25`
- **Owner:** `Delphi / Strategic CTO-Tech-Lead`, under human authority

## Context

`tools/todo_closeout_guard.py` currently assumes every TODO authority lives under `<repo>/foundation_documentation/todos/**`. A canonical Foundation may instead be a standalone repository whose root directly contains `todos/**`. In that topology, the guard resolves an explicit active TODO as `path_state=other`, while `--all-active --repo <standalone-foundation>` discovers zero files. Both invocations still return `Overall outcome: go`, creating a governance false positive.

The existing fixture suite is false-green for this behavior because it creates only the nested topology. This is a reusable Delphi defect, not a project-specific exception: the guard must resolve both canonical layouts deterministically and fail closed when the requested authority root or TODO path is not recognized.

## Framing Source & Story Slice

- **Feature brief:** `direct-to-todo`
- **Primary story ID:** `CLOSEOUT-STANDALONE-01`
- **Why this is the right current slice:** one bounded maintenance/regression fix restores the advertised closeout contract for a second canonical Foundation topology.
- **Direct-to-TODO rationale:** the symptom, root cause, affected tool, and required compatibility cases are already concrete; feature decomposition is unnecessary.

## Objective

Make `todo_closeout_guard.py` correctly classify and discover TODOs in both nested `foundation_documentation/todos/**` and standalone `todos/**` authorities, while rejecting unrecognized paths/roots instead of emitting a false `go`.

## Contract Boundary

- This TODO changes only the deterministic closeout guard, its regression fixtures, and this governing TODO.
- The guard remains read-only except for the already-supported optional JSON evidence output.
- CLI arguments and nested-layout behavior remain backward compatible.
- No downstream project identity, path, TODO content, or business term may be embedded in Delphi code/tests/docs.

## Implementation Intent

- **Current delivery:** generic authority-root resolution and fail-closed regression coverage for the closeout guard.
- **Planned next step:** unblock downstream Foundation closeout validation after this slice is completed and published.
- **Anticipatory implementation authorized now:** `none`.
- **Rationale:** only the proven false-positive paths belong in this fix.

## Delivery Status Canon

- **Current delivery stage:** `Pending`
- **Qualifiers:** `none`
- **Next exact step:** run fresh architecture and plan critique against `origin/feat/add-stack-capabilities@36b7123`, then execute coherence, drift, and authority preflight.

## Active Work State

- **Work state:** `review`
- **Why this state now:** planning and approval gates remain open; implementation has not started.
- **Exit condition:** explicit `APROVADO`, normal authority guard `go`, implementation, and all delivery gates.

## Scope

- [ ] Add a generic authority-root resolver that recognizes `<repo>/foundation_documentation/todos` and `<repo>/todos` without project-specific names.
- [ ] Classify explicit TODO paths relative to the resolved authority root instead of matching hard-coded absolute path parts after `resolve()`.
- [ ] Discover active TODOs in either supported topology and deduplicate equivalent resolved roots/paths.
- [ ] Fail closed when an explicit TODO is outside every supported authority root.
- [ ] Fail closed when `--all-active` cannot find any supported TODO authority root; distinguish this from a valid empty active directory.
- [ ] Add RED/GREEN regression fixtures for nested, standalone, symlink-resolved, unrecognized-path, missing-root, and real active-count behavior.
- [ ] Preserve existing disposition parsing, git-state handling, JSON output, advisory exit behavior, and non-mutating semantics.

## Out of Scope

- [ ] Change downstream project or Foundation files.
- [ ] Add project-specific aliases, repository names, absolute paths, or special cases.
- [ ] Auto-move TODOs or alter closeout disposition semantics.
- [ ] Change TODO approval, completion, promotion, or Git authority policy.
- [ ] Introduce worktrees, auxiliary checkouts, or parallel code writers.

## Delivery Status Semantics

- `Pending`: plan/refinement/review, without implementation authority.
- `Local-Implemented`: code and tests pass locally with all required delivery evidence.
- `Lane-Promoted`: commit is published to the current version feature branch.
- `Production-Ready`: package-level promotion remains owned by the v0.4.0 release package.

## Execution Lane Tracking

- **Local implementation branches:** `delphi-ai:feat/add-stack-capabilities`
- **Promotion lane path:** `feat/add-stack-capabilities -> origin/feat/add-stack-capabilities`
- **Lane-promoted threshold for this TODO:** `origin/feat/add-stack-capabilities`
- **Production-ready threshold for this TODO:** `n/a — v0.4.0 release package owns later promotion`

## Promotion Evidence

| Scope Item | Local Branch/Commit | PR to lane threshold | PR to `stage` | PR to `main` | Current Status |
| --- | --- | --- | --- | --- | --- |
| standalone closeout guard support | `feat/add-stack-capabilities@36b7123` | `origin/feat/add-stack-capabilities@36b7123` | n/a | release-package-owned | review baseline published |

## Diff Expectation Contract

- **Contract status:** `required`
- **Policy:** `strict; unclassified or forbidden paths block delivery`
- **User validation:** `required on deviation`
- **Comparison mode:** `working_tree`

### Repository Baselines

| Repository | Path | Baseline ref | Comparison mode |
| --- | --- | --- | --- |
| `delphi-ai` | `.` | `feat/add-stack-capabilities@9ba43e8bba3618d029320bf6d7b40415881a0287` | `working_tree` |

### Expected Changed Paths

| Repository | Path glob | Change types (`A|M|D|R|any`) | Reason |
| --- | --- | --- | --- |
| `delphi-ai` | `tools/todo_closeout_guard.py` | `M` | generic topology resolution and fail-closed behavior |
| `delphi-ai` | `tools/tests/todo_closeout_guard_test.sh` | `M` | RED/GREEN nested and standalone fixtures |
| `delphi-ai` | `artifacts/analysis/standalone-foundation-closeout-guard-delivery-package.md` | `A, M` | bounded derived audit package |
| `delphi-ai` | `foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md` | `any` | tactical authority, evidence, and closeout origin |
| `delphi-ai` | `foundation_documentation/todos/completed/TODO-delphi-standalone-foundation-closeout-guard.md` | `A, R` | exact closeout destination after all gates |

### Not Expected Changed Paths

| Repository | Path glob | Change types (`A|M|D|R|any`) | Reason |
| --- | --- | --- | --- |
| `delphi-ai` | `main_instructions.md` | `any` | no instruction change is required |
| `delphi-ai` | `rules/**` | `any` | policy semantics remain unchanged |
| `delphi-ai` | `workflows/**` | `any` | closeout workflow already states the correct contract |
| `delphi-ai` | `skills/**` | `any` | skill mirrors do not change |
| `delphi-ai` | `templates/**` | `any` | tactical template does not change |

### Diff Deviation Analysis

| Diff item | Classification | Evidence / agent defense | Decision | User validation / renewed approval |
| --- | --- | --- | --- | --- |
| `n/a` | `n/a` | guard not yet executed against implementation | `n/a` | `n/a` |

## Bounded But Elastic Guardrails

- **May stay inside this TODO:** local helper extraction inside the guard and fixture refactors required for the same topology contract.
- **Must update or split the TODO:** CLI redesign, new policy semantics, automatic mutations, changes outside the four expected paths, or support for an additional unrelated repository layout.

## Definition of Done

- [ ] `DOD-01` An explicit active TODO under standalone `<repo>/todos/active/**` reports `path_state=active` and is actually validated.
- [ ] `DOD-02` `--all-active --repo <standalone>` discovers the real active TODO count and validates each file.
- [ ] `DOD-03` Existing nested `<repo>/foundation_documentation/todos/**` behavior remains green.
- [ ] `DOD-04` A project-root symlink to a standalone Foundation resolves to one authority without duplicate scans.
- [ ] `DOD-05` An explicit TODO outside all supported authority roots returns `no-go` with a precise violation.
- [ ] `DOD-06` `--all-active` with no supported authority root returns `no-go`; a valid authority with an empty active directory remains distinguishable and intentionally accepted.
- [ ] `DOD-07` Disposition parsing, advisory mode, JSON evidence, git metadata, and non-mutating behavior remain compatible.
- [ ] `DOD-08` No downstream project name/path/business concept is persisted in Delphi surfaces.

## Validation Steps

- [ ] `VAL-01` Run `python3 -m py_compile tools/todo_closeout_guard.py`.
- [ ] `VAL-02` Run `bash tools/tests/todo_closeout_guard_test.sh` and require direct assertions for every DOD topology.
- [ ] `VAL-03` Run `bash self_check.sh`.
- [ ] `VAL-04` Run `python3 tools/todo_diff_expectation_guard.py foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md --repo-root .`.
- [ ] `VAL-05` Run `python3 tools/todo_authority_guard.py foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md --require-delivery-gates`.
- [ ] `VAL-06` Run `python3 tools/todo_completion_guard.py foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md`.
- [ ] `VAL-07` Inspect `git diff --check 9ba43e8bba3618d029320bf6d7b40415881a0287 --` and `git diff --name-status --find-renames 9ba43e8bba3618d029320bf6d7b40415881a0287 --`.

## Completion Evidence Matrix

| Criterion ID | Source Section | Criterion | Evidence Type | Evidence Artifact / Command | Runtime Target | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `DOD-01` | Definition of Done | standalone explicit path | test | `standalone-explicit-missing-disposition` fixture | local CLI | planned | must produce active classification and real violation |
| `DOD-02` | Definition of Done | standalone all-active discovery | test | `standalone-all-active-count` fixture | local CLI | planned | assert exact nonzero count |
| `DOD-03` | Definition of Done | nested compatibility | regression | existing nested fixture matrix | local CLI | planned | no regression |
| `DOD-04` | Definition of Done | symlink authority deduplication | test | `symlinked-standalone-authority` fixture | local CLI | planned | each resolved TODO scanned once |
| `DOD-05` | Definition of Done | explicit unrecognized path | negative test | `outside-authority-root` fixture | local CLI | planned | fail closed |
| `DOD-06` | Definition of Done | missing root vs empty active | negative+positive tests | `missing-authority-root`; `empty-active-authority` | local CLI | planned | distinct diagnostics/outcomes |
| `DOD-07` | Definition of Done | compatibility/non-mutation | regression+review | full fixture suite + diff review | local CLI | planned | optional JSON only write |
| `DOD-08` | Definition of Done | Delphi agnosticism | review | bounded diff | n/a | planned | generic fixture names only |
| `VAL-01` | Validation Steps | Python syntax | test | py_compile command | local | planned | exit 0 |
| `VAL-02` | Validation Steps | fixture suite | test | shell test command | local | planned | exact assertions |
| `VAL-03` | Validation Steps | Delphi coherence | test | self_check command | local | planned | no failures |
| `VAL-04` | Validation Steps | diff contract | guard | diff expectation command | local | planned | outcome go |
| `VAL-05` | Validation Steps | delivery authority | guard | authority command | local | planned | outcome go |
| `VAL-06` | Validation Steps | completion evidence | guard | completion command | local | planned | outcome go |
| `VAL-07` | Validation Steps | clean/bounded diff | review | exact git commands | local | planned | no whitespace/unclassified path |

## External Dependency Readiness

| Dependency | Why It Matters | Status | Last Verified | Verification Method | Adjustment / Workaround |
| --- | --- | --- | --- | --- | --- |
| Python 3 standard library | guard runtime | healthy | 2026-09-25 | current guard executes | none |
| Git CLI | optional sync metadata | healthy | 2026-09-25 | current guard reports git context | fixtures must not require network |

## Profile Scope & Handoffs

- **Primary execution profile:** `strategic-cto`
- **Active technical scope:** `delphi-tooling`
- **Expected supporting profiles:** `operational-coder; assurance-tester-quality`
- **Scope-check command:** `python3 tools/profile_scope_check.py --profile strategic-cto tools/todo_closeout_guard.py tools/tests/todo_closeout_guard_test.sh artifacts/analysis/standalone-foundation-closeout-guard-delivery-package.md foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md`
- **Scope-check outcome:** `review required`; the TODO is allowed and the tool/test/derived-artifact paths are explicitly routed through the handoffs below.

### Handoff Log

| From Profile | To Profile | Why the Handoff Exists | Touched Surfaces | Status / Evidence |
| --- | --- | --- | --- | --- |
| strategic-cto | operational-coder | minimal deterministic Python implementation | `tools/todo_closeout_guard.py` | planned; scope-check unknown is expected and routed |
| operational-coder | assurance-tester-quality | false-green regression and negative cases | `tools/tests/todo_closeout_guard_test.sh` | planned; scope-check unknown is expected and routed |
| assurance-tester-quality | strategic-cto | final agnosticism/contract review and derived packet | bounded diff + `artifacts/analysis/**` | planned; scope-check unknown is expected and routed |

## Complexity

- **Level (`small|medium|big`):** `medium`
- **Checkpoint policy:** `single bounded implementation checkpoint`
- **Why this level:** the code change is localized, but the guard is shared release-governance infrastructure and the defect is a false-positive gate.

## Canonical Module Anchors

- **Primary module doc:** `tools/todo_closeout_guard.py`
- **Secondary module docs:** `tools/tests/todo_closeout_guard_test.sh`, `workflows/docker/todo-closeout-promotion-method.md`
- **Planned decision promotion targets:** `none — current workflow already declares the intended generic behavior`.
- **Module decision consolidation targets:** `none`.

## Decision Pending

- [x] `none — topology semantics and fail-closed behavior are frozen below`.

## Decisions

- [x] `D-01` Supported authority roots are `<repo>/foundation_documentation/todos` and `<repo>/todos`; names below `todos/` retain the existing active/promotion/completed semantics.
- [x] `D-02` Path classification is relative to resolved authority roots, not hard-coded absolute path segments.
- [x] `D-03` Equivalent roots/paths produced by symlinks are deduplicated after canonical resolution.
- [x] `D-04` Explicit paths outside supported roots and all-active scans without a supported root fail closed.
- [x] `D-05` A supported root with an empty `active/` directory is valid and distinguishable from a missing authority root.
- [x] `D-06` No instruction/workflow/template change is needed because the existing CLI contract is already generic; the implementation was narrower than its contract.

## Decision Baseline

- [x] `D-01` Preserve nested layout behavior.
- [x] `D-02` Add standalone layout behavior without project-specific aliases.
- [x] `D-03` Eliminate false `go` for unrecognized explicit paths and missing roots.
- [x] `D-04` Keep the guard non-mutating.

## Architecture Change Governance

- **Applicability:** `required`
- **Why this applies:** shared guard authority resolution changes and false-green evidence can affect every TODO closeout.
- **Deviation / debt being retired:** advertised generic `--repo` behavior is implemented as a hard-coded nested topology.
- **Target steady-state after closeout:** one generic resolver supplies classification and discovery for both supported layouts; no parallel topology logic.
- **Compatibility window:** immediate; nested behavior stays supported permanently.
- **Cutover / removal condition:** all topology fixtures pass and no hard-coded project alias exists.

### Architecture Protection Harness

| Harness Type | Surface | Command / Rule / Artifact | Regression It Must Catch | Adoption Timing | Evidence Plan / Follow-up |
| --- | --- | --- | --- | --- | --- |
| test | authority-root resolution | `todo_closeout_guard_test.sh` | standalone classified as other | implement-in-this-todo | RED/GREEN fixture |
| test | all-active discovery | `todo_closeout_guard_test.sh` | zero-count false go | implement-in-this-todo | exact count assertions |
| test | fail closed | `todo_closeout_guard_test.sh` | missing root/outside path returns go | implement-in-this-todo | negative assertions |

## Architecture Review Gates

- **Architecture decision review:** `required`
- **Decision review lifecycle:** `after diagnosis is closed and before APROVADO`
- **Decision review kind:** `architecture_opinion`
- **Decision review package:** `bounded-file-set`
- **Decision review status:** `not_run`
- **Decision review evidence / resolution:** `pending frozen baseline`
- **Architecture adherence review:** `required`
- **Adherence review lifecycle:** `after implementation and before Completed`
- **Adherence review kind:** `architecture_adherence`
- **Adherence review package:** `bounded-file-set`
- **Adherence review status:** `not_run`
- **Adherence review evidence / resolution:** `pending implementation`
- **No-go handling:** return to the affected loop; do not request approval or close with unresolved divergence.

## Gate: Review Baseline Freeze

- **Gate decision:** `required`
- **Why this decision:** shared guard behavior needs an immutable review packet.
- **Trigger stage:** `before planning-side reviews`
- **Baseline branch:** `feat/add-stack-capabilities`
- **Baseline commit:** `36b71230a4cb88f8dc8c9454b6dfd7eb5bdbc8bd`
- **Baseline push reference:** `origin/feat/add-stack-capabilities`
- **Gate status:** `running`
- **Findings summary:** refined standalone/nested/fail-closed contract frozen; fresh reviews pending.
- **Evidence / reference:** `origin/feat/add-stack-capabilities@36b7123`; validator/diff/audit/routing guards passed before freeze.
- **Waiver authority / reference:** `n/a`

## Gate: Review Scope Drift

- **Gate decision:** `required`
- **Why this decision:** behavior and test scope must remain identical to the reviewed baseline.
- **Trigger stage:** `after planning reviews converge and before APROVADO`
- **Baseline source:** `Gate: Review Baseline Freeze -> Baseline commit`
- **Material sections compared:** `template canonical set`
- **Guard command:** `python3 tools/review_scope_drift_guard.py --todo foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md`
- **Gate status:** `not_run`
- **Findings summary:** `pending`
- **Evidence / reference:** `pending`
- **Waiver authority / reference:** `n/a`

## Questions To Close

- [x] Supported layouts are nested and standalone only.
- [x] Missing authority roots fail closed.
- [x] Empty active directories remain valid.

## Assumptions Preview

| Assumption ID | Assumption | Evidence | If False | Confidence | Handling |
| --- | --- | --- | --- | --- | --- |
| `none` | No live assumption: the failure and root cause are directly observed in code and CLI output. | guard source + downstream reproduction | n/a | High | Keep as Assumption |

## Bug-Fix Evidence Gate

1. **Existing coverage:** partial/false-green. The suite covers only nested `foundation_documentation/todos`.
2. **Real payload/database inspection:** not applicable; the real boundary is local filesystem topology plus markdown and Git CLI metadata.
3. **Existing failing test:** none. The existing suite passes because it never constructs a standalone authority.
4. **Required RED tests:** standalone explicit path, standalone all-active exact count, symlink dedupe, outside-root no-go, missing-root no-go, and valid empty-active behavior.
5. **Analyzer prevention:** `no-rule-needed`; this is runtime path-resolution behavior, best prevented by deterministic fixtures rather than a static analyzer rule.

| Stage | Coverage Before Fix | Required Evidence |
| --- | --- | --- |
| nested authority resolution | covered | preserve existing suite |
| standalone explicit classification | missing | RED fixture then GREEN |
| standalone all-active discovery | missing | RED exact-count fixture then GREEN |
| symlink canonicalization | missing | dedup fixture |
| unknown root/path rejection | false-green | negative fixtures requiring no-go |
| disposition parsing | covered | preserve existing suite |
| JSON/advisory output | covered | preserve existing suite + standalone scan |

## Execution Plan

### Touched Surfaces

- `tools/todo_closeout_guard.py`
- `tools/tests/todo_closeout_guard_test.sh`
- this tactical TODO only

### Ordered Steps

1. Add failing standalone/outside/missing-root fixtures and assert current false-green output (RED).
2. Extract one generic supported-root resolver used by explicit classification and all-active discovery.
3. Add precise violations for unrecognized explicit paths and missing authority roots.
4. Preserve nested, empty-active, advisory, JSON, git, and non-mutating behavior.
5. Run targeted suite, compile, self-check, diff/authority/completion gates, independent reviews, and closeout.

### Test Strategy

- **Strategy:** `test-first`.
- **Evidence layers:** unit-like CLI fixtures plus integration/contract execution of the real Python entry point against real temporary directories and symlinks.
- **No external substitution:** no database, network, container, or project-specific fixture is needed.
- **Fail-first targets:** standalone explicit/all-active and unrecognized root/path cases.

### Pre-APROVADO RED Evidence Capture

- **Decision:** `not_needed`.
- **Why now:** the production-like CLI symptom is already reproduced read-only; source test changes wait for approval.
- **Observed symptom:** explicit standalone TODO yields `path_state=other`; standalone all-active yields `todo_count=0`; both report `go`.
- **Status:** `observed_read_only`.

### Flow Evidence Planning Matrix

| Criterion / Flow | Why Flow-Impacting | Platform Parity | Required Runtime Lane | Mutation Lane Required? | Backend Real-Data Required? | Planned Evidence | Non-Applicability Rationale |
| --- | --- | --- | --- | --- | --- | --- | --- |
| closeout CLI classification/discovery | shared governance gate | Linux/WSL filesystem + symlink | real Python CLI | yes | no | temp-directory nested/standalone/symlink fixtures | no user UI/backend |

### Local CI-Equivalent Suite Matrix

| Repository / CI Surface | Why In Scope | Behavior / Scenario Covered | Fixture / Seed / Runtime Preconditions | Local CI-Equivalent Command | Required Before | Status | Evidence Artifact / Command | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| closeout guard syntax | Python changes | import/parse | Python 3 | `python3 -m py_compile tools/todo_closeout_guard.py` | Local-Implemented | planned | command output | narrow first |
| closeout guard fixture suite | behavior changes | nested + standalone + negative topology | self-seeded mktemp dirs/symlinks | `bash tools/tests/todo_closeout_guard_test.sh` | Local-Implemented | planned | command output | exact count/path assertions |
| Delphi self-check | shared tooling coherence | repository checks | principal checkout | `bash self_check.sh` | Local-Implemented | planned | command output | authoritative broad gate |

## Plan Review

### Architecture

- One resolver must own supported-root discovery and relative path classification.
- Resolved paths are deduplicated; symlinks do not create parallel authorities.
- Unknown roots/paths fail closed.

### Code Quality

- Prefer small pure helpers returning resolved TODO roots/state.
- Do not duplicate nested/standalone branches across CLI modes.

### Tests

- Existing suite is false-green for standalone layout.
- New tests call the real CLI and assert semantic JSON/text fields, not exit code alone.

### Performance

- At most two candidate TODO roots per repository; recursive scan behavior is unchanged.

### Security

- Resolve paths without following arbitrary inputs outside an explicitly recognized authority root.
- Preserve read-only behavior and caller-selected JSON output only.

### Failure Modes & Edge Cases

- [ ] Both candidate roots resolve to the same symlink target.
- [ ] A supported root exists but `active/` is empty.
- [ ] No supported root exists.
- [ ] Explicit TODO is outside supported roots.
- [ ] Explicit TODO path does not exist or is not a file.
- [ ] Nested behavior regresses while standalone becomes green.

### Residual Unknowns / Risks

- [ ] Windows junction behavior is not separately claimed; canonical `Path.resolve()` semantics and WSL symlink fixture are the current boundary.

## Audit Trigger Matrix

- **Canonical method:** `wf-docker-audit-escalation-method`
- **Guard command:** `python3 tools/audit_escalation_guard.py --todo foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md`
- **Latest TEACH evidence / artifact:** `audit_escalation_guard.py: Overall outcome go; fingerprint 2cb9969d112b; critique, test-quality, final review, verification debt, architecture decision/adherence and additive triple review required; performance/concurrency recommended; formal security review not needed`.

| Trigger | Value | Notes |
| --- | --- | --- |
| `complexity` | `medium` | localized shared guard |
| `blast_radius` | `cross-stack` | shared guard serves downstream Foundations across stacks |
| `behavioral_change_or_bugfix` | `yes` | false-positive fix |
| `changes_public_contract` | `no` | implementation catches up to existing CLI contract |
| `touches_auth_or_tenant` | `no` | local files only |
| `touches_runtime_or_infra` | `no` | CLI tooling only |
| `touches_tests` | `yes` | fixture suite changes |
| `critical_user_journey` | `no` | governance workflow |
| `release_or_promotion_critical` | `yes` | closeout gate |
| `high_severity_plan_review_issue` | `yes` | false go |
| `explicit_three_lane_request` | `no` | not requested |

## Independent No-Context Critique Gate

- **Critique decision:** `required`
- **Why this decision:** medium, cross-project, test-changing, release-critical false-positive guard.
- **Impact signals in scope:** `cross-project blast radius|false-green governance gate|test changes`.
- **Package mode:** `bounded-file-set`.
- **Package minimum contents:** `frozen TODO|guard source|fixture suite|read-only reproduction`.
- **Critique isolation mode:** `fresh internal no-context reviewer`.
- **Internal reviewer mandate:** `required after baseline freeze`.
- **Critique lenses:** `correctness|performance|elegance|structural-soundness|risk`.
- **Critique status:** `not_run`
- **Findings summary:** `pending`.
- **Evidence / reference:** `pending`.
- **Waiver authority / reference:** `n/a`.

## Gate: Assumption Code Coherence

- **Gate decision:** `required`
- **Why this decision:** guard/source/test facts must still match the frozen plan before approval.
- **Trigger stage:** `after critique convergence and before APROVADO`.
- **Guard scope:** `none — direct facts/decisions, no live assumptions`.
- **Guard command:** `python3 tools/assumption_code_coherence_guard.py --todo foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md`.
- **Gate status:** `not_run`
- **Findings summary:** `pending`.
- **Evidence / reference:** `pending`.
- **Waiver authority / reference:** `n/a`.

## Approval

- **Approved by:** `pending explicit APROVADO`.
- **Approval scope:** `pending`.
- **Execution not authorized by approval:** downstream project edits, policy redesign, automatic moves, worktrees, or additional layouts.
- **Renewed approval required when:** CLI contract, supported layouts, changed files, mutation behavior, or risk materially changes.

## Rules Acknowledgement / Ingestion

| Source | Why It Applies Now | Must Preserve | Must Avoid | Execution Impact |
| --- | --- | --- | --- | --- |
| `rules/core/todo-driven-execution-model-decision.md` | tactical bugfix | APROVADO and evidence gates | premature code edits | blocks implementation |
| `workflows/docker/todo-closeout-promotion-method.md` | affected guard contract | real active discovery and disposition validation | false go | acceptance source |
| `skills/bug-fix-evidence-loop/SKILL.md` | reproducible false-green bug | RED first and mandatory questions | retrofit-only tests | test-first execution |
| `skills/test-creation-standard/SKILL.md` | fixture logic changes | real CLI boundary and exact assertions | status-only confidence | contract tests |
| `workflows/docker/deterministic-todo-validation-method.md` | tactical TODO | canonical structure | derived bundle edits | validation |

## Agent Routing Preflight

- **Client surface:** `codex`
- **Current governed action:** `implementation`
- **Selected role:** `routine-executor`
- **Selected model:** `gpt-5.6-terra`
- **Selected effort:** `medium`
- **Proof mode:** `declared`
- **Exception reason:** `n/a`
- **Subagent / delegation authorization:** `reviewers only; implementation remains principal-checkout single-writer`
- **Execution topology:** `primary-checkout-single-writer`
- **Worktree / auxiliary-checkout authorization:** `not-authorized`
- **Worktree authorization evidence:** `n/a`
- **Writer scheduling policy:** `single-writer-serialized`
- **Guard outcome:** `go`
- **Waiver / exception reference:** `n/a`

## Decision Adherence Validation

| Decision ID | Status | Evidence | Notes |
| --- | --- | --- | --- |
| `D-01` | pending | pending implementation | two supported layouts |
| `D-02` | pending | pending implementation | relative classification |
| `D-03` | pending | pending implementation | deduplication |
| `D-04` | pending | pending implementation | fail closed |
| `D-05` | pending | pending implementation | empty active distinction |
| `D-06` | pending | pending implementation | no docs change |

## Module Decision Consistency Validation

| Module Decision Ref | Planned Handling | Delivery Status | Evidence | Notes |
| --- | --- | --- | --- | --- |
| `closeout#non-mutating` | Preserve | pending | pending | no auto-move |
| `closeout#all-active` | Preserve + Fix | pending | pending | discover real authority |
| `closeout#same-governing-todo` | Preserve | pending | pending | no new promotion TODO |

## Pipeline/Copilot P1/P2 Preflight

| Reviewer Surface / Package | Review Focus | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| standalone closeout guard diff | path escape, false go, nested regression, duplicate scans | planned | pending | pending | pre-delivery |

## Rule-Spirit Anti-Pattern Hunt

| Rule / Principle Surface | Bypass or Anti-Pattern Search Lens | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| deterministic closeout | exit-0 without recognized authority, fixture-only shortcut, project alias | planned | pending | pending | pre-delivery |

## Security Risk Assessment

- **Risk level:** `low`.
- **Why this risk level:** local read-only path resolution; malformed/untrusted paths must fail closed.
- **Attack surface in scope:** CLI paths, symlinks, recursive markdown discovery, optional JSON output.
- **Attack simulation decision:** `not_needed` (audit floor `SEC-NOT-TRIGGERED`; bounded negative path/symlink regression tests remain required).
- **Review evidence:** negative outside-root and symlink fixtures planned; no auth, tenant, secret, network, or runtime mutation surface.
- **Residual security risk:** `pending review`.

## Performance & Concurrency Risk Assessment

- **Policy schema version:** `pcv-1`
- **Global sensitivity level:** `low`
- **Why this level:** two bounded root candidates and local markdown scan; no concurrency surface.
- **Current delivery stage at review time:** `Pending`
- **Audit-floor position:** independent performance/concurrency validation is recommended for release sensitivity; all four runtime lanes remain objectively `not_needed` because no endpoint, UI, write, or pressure surface changes.

| Policy | Lane ID | Lane | Trigger Result | Trigger Severity | Trigger Reason Code | Trigger Rationale | Gate Deadline | Minimum Evidence Rule | State | Residual Risk | Uncertainty Reason Code | Recorded At UTC | Executor ID |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `pcv-1` | `EPS` | endpoint-performance-scrutiny | not_needed | low | EPS-DATA-PATH-CHANGED | no endpoint/query path changes | before_local_implemented | EPS-E1 | not_applicable | none | none | `2026-09-25T00:00:00Z` | `codex-primary` |
| `pcv-1` | `FRC` | frontend-race-condition-validation | not_needed | low | FRC-STALE-RESPONSE | no UI async surface | before_local_implemented | FRC-POLICY | not_applicable | none | none | `2026-09-25T00:00:00Z` | `codex-primary` |
| `pcv-1` | `BCI` | backend-concurrency-idempotency-validation | not_needed | low | BCI-EXACT-ONCE-SEMANTICS | no write/concurrency surface | before_local_implemented | BCI-INV | not_applicable | none | none | `2026-09-25T00:00:00Z` | `codex-primary` |
| `pcv-1` | `RLS` | runtime-load-stress-validation | not_needed | low | RLS-BATCH-OR-BULK-PATH-CHANGED | bounded local scan only; no runtime-pressure surface | before_production_ready | RLS-E1 | not_applicable | none | none | `2026-09-25T00:00:00Z` | `codex-primary` |

## Verification Debt Assessment

- **Audit outcome:** `required before Completed`.
- **Why this outcome:** false-green shared guard behavior must not close on unreviewed tests.
- **Inline code TODO debt:** `none expected`.
- **Evidence / audit artifact:** `pending`.
- **Accepted residual debt:** `none`.

## Independent Test Quality Audit Gate

- **Audit decision:** `required`
- **Why this decision:** test logic changes and current coverage is false-green.
- **Trigger signals in scope:** `changed test logic|bugfix|shared deterministic guard`.
- **Required evidence matrix:** `CLI integration/contract + negative fixtures`.
- **Package mode:** `bounded-file-set`.
- **Audit isolation mode:** `fresh internal no-context reviewer`.
- **Internal reviewer mandate:** `required before Completed`.
- **Audit status:** `not_run`
- **Findings summary:** `pending`.
- **Evidence / reference:** `pending`.

## Independent No-Context Final Review Gate

- **Final review decision:** `required`
- **Why this decision:** release-critical cross-project guard behavior.
- **Impact signals in scope:** `false-positive governance gate|nested compatibility`.
- **Package mode:** `bounded-file-set`.
- **Review isolation mode:** `fresh internal no-context reviewer`.
- **Internal reviewer mandate:** `required before Completed`.
- **Final review status:** `not_run`
- **Findings summary:** `pending`.
- **Evidence / reference:** `pending`.

## Independent Multi-Lane Audit Gate

- **Audit decision:** `required`
- **Why this decision:** audit floor marks the release-critical false-positive guard as high criticality.
- **Canonical protocol:** `audit-protocol-triple-review` (additive; it does not replace planning critique, test-quality audit, or final review).
- **Required lanes:** `performance + test-quality`; cutover-integrity is not triggered.
- **Package mode:** `bounded-file-set`.
- **Run root:** `artifacts/tmp/standalone-foundation-closeout-guard-audit`.
- **Audit status:** `not_run`
- **Findings summary:** `pending implementation and primary validation`.
- **Evidence / reference:** `pending session.json + round summary`.

## TODO Closeout Disposition

- **Disposition:** `keep-active`.
- **Disposition reason:** planning, approval, implementation, and validation remain.
- **Post-commit/push status:** `pending`.
- **Next path/status action:** freeze review baseline, obtain APROVADO, implement, validate, and move to the exact completed path.

## Commands

- `python3 tools/todo_deterministic_validator.py --todo foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md`
- `python3 tools/audit_escalation_guard.py --todo foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md`
- `python3 tools/todo_diff_expectation_guard.py foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md --repo-root .`
- `python3 tools/assumption_code_coherence_guard.py --todo foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md`
- `python3 tools/review_scope_drift_guard.py --todo foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md`
- `python3 tools/todo_authority_guard.py foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md --pre-approval`
- After approval: `python3 tools/todo_authority_guard.py foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md`
- Audit start after implementation: `python3 skills/audit-protocol-triple-review/scripts/triple_audit_session.py start --package artifacts/analysis/standalone-foundation-closeout-guard-delivery-package.md --todo foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md --run-root artifacts/tmp/standalone-foundation-closeout-guard-audit`
- Delivery: `python3 tools/todo_authority_guard.py foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md --require-delivery-gates`
- Delivery: `python3 tools/todo_completion_guard.py foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md`
