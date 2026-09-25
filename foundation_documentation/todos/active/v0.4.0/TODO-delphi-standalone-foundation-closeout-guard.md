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

- This TODO changes only the deterministic closeout guard, its regression fixtures, the bounded derived audit package, and this governing TODO.
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
- **Next exact step:** publish the finding-integrated review baseline, run fresh architecture and plan critique, then execute coherence, drift, and authority preflight.

## Active Work State

- **Work state:** `review`
- **Why this state now:** planning and approval gates remain open; implementation has not started.
- **Exit condition:** explicit `APROVADO`, normal authority guard `go`, implementation, and all delivery gates.

## Scope

- [ ] Add a generic authority-root resolver that recognizes `<repo>/foundation_documentation/todos` and `<repo>/todos` without project-specific names.
- [ ] Classify explicit TODO paths relative to the resolved authority root instead of matching hard-coded absolute path parts after `resolve()`.
- [ ] Discover active TODOs in either supported topology, deduplicate equivalent resolved roots/paths, and reject simultaneous distinct authorities as ambiguous.
- [ ] Fail closed when an explicit TODO is outside every supported authority root.
- [ ] Fail closed when `--all-active` cannot find exactly one supported TODO authority root; distinguish no root, a candidate `todos/` without `active/`, an ambiguous pair of distinct roots, and a valid empty `active/` directory.
- [ ] Validate explicit inputs before reading: an existing regular Markdown file is required; missing paths, directories, and non-Markdown files fail closed without traceback.
- [ ] Preserve relative explicit-path semantics anchored to the process current working directory and define `--repo` as the repository/container whose two immediate authority candidates and Git context are inspected.
- [ ] Add RED/GREEN regression fixtures for nested, standalone, relative-path, root-symlink, equivalent-root/path deduplication, escaping leaf symlink, unrecognized-path, invalid explicit input, missing/ambiguous root, exact exit codes, JSON shape, and real active-count behavior.
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
| standalone closeout guard support | `feat/add-stack-capabilities@00392ee` | `origin/feat/add-stack-capabilities@00392ee` | n/a | release-package-owned | finding-integrated R2 review baseline published |

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
- **Must update or split the TODO:** CLI redesign, new policy semantics, automatic mutations, changes outside the five expected paths, or support for an additional unrelated repository layout.

## Definition of Done

- [ ] `DOD-01` An explicit active TODO under standalone `<repo>/todos/active/**` reports `path_state=active` and is actually validated.
- [ ] `DOD-02` `--all-active --repo <standalone>` discovers the real active TODO count and validates each file.
- [ ] `DOD-03` Existing nested `<repo>/foundation_documentation/todos/**` behavior remains green.
- [ ] `DOD-04` A symlink used as `--repo` resolves to the standalone repository, and two candidate roots or file aliases resolving to the same authority/TODO produce exactly one scan and one `todo_result`.
- [ ] `DOD-05` An explicit TODO outside all supported authority roots—including an external path with a misleading `foundation_documentation/todos/active/**` suffix—and a leaf symlink escaping an accepted root return exit `2`, `no-go`, and the exact outside-authority violation code.
- [ ] `DOD-06` Root-state semantics are exact: zero supported roots and an existing candidate `todos/` without `active/` return exit `2`; one existing empty `active/` is valid with count zero and exit `0`; two distinct supported authorities return exit `2` as ambiguous.
- [ ] `DOD-07` Explicit missing paths, directories, and non-Markdown files return exit `2` with typed governance violations and no traceback; argparse misuse remains exit `2` and unexpected runtime/tool failures remain exit `1`.
- [ ] `DOD-08` Relative explicit TODO arguments remain anchored to the process current working directory and work from both nested and standalone repository roots.
- [ ] `DOD-09` Disposition parsing, advisory mode, JSON evidence, git metadata rooted at the resolved `--repo` Git worktree, and non-mutating behavior each retain direct compatibility assertions; discovery-level violations remain serializable/printable without inventing a TODO result.
- [ ] `DOD-10` The shell harness is normalized to LF and executes directly in the declared Linux/WSL lane.
- [ ] `DOD-11` No downstream project name/path/business concept is persisted in Delphi surfaces.

## Validation Steps

- [ ] `VAL-01` Run `python3 -m py_compile tools/todo_closeout_guard.py`.
- [ ] `VAL-02` Run `bash tools/tests/todo_closeout_guard_test.sh` directly from the Linux/WSL checkout and require direct assertions for every DOD topology and exact exit contract.
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
| `DOD-04` | Definition of Done | repo symlink + equivalent authority/TODO deduplication | test | `symlinked-repo`; `equivalent-root-aliases`; `equivalent-file-aliases` | local CLI | planned | assert count `1` and exactly one `todo_result` |
| `DOD-05` | Definition of Done | outside authority + escaping leaf symlink | negative test | `misleading-outside-authority`; `leaf-symlink-escape` | local CLI | planned | exact outside-authority code and exit `2` |
| `DOD-06` | Definition of Done | zero/malformed/empty/ambiguous root states | negative+positive tests | `missing-authority-root`; `missing-active-directory`; `empty-active-authority`; `distinct-authorities` | local CLI | planned | exact diagnostics, counts, and exit codes |
| `DOD-07` | Definition of Done | explicit input and CLI exit contract | negative test | `missing-explicit`; `directory-explicit`; `non-markdown-explicit`; argparse misuse | local CLI | planned | governance `2`, misuse `2`, unexpected tool failure `1`, no traceback for governed inputs |
| `DOD-08` | Definition of Done | relative path compatibility | regression | nested and standalone invocation from each repository root | local CLI | planned | path remains CWD-relative |
| `DOD-09` | Definition of Done | compatibility/non-mutation | regression+review | separate assertions for disposition, advisory, JSON, Git, discovery violation rendering, and bounded diff | local CLI | planned | advisory `0`; normal no-go `2`; optional JSON is the only write |
| `DOD-10` | Definition of Done | Linux/WSL harness execution | test | `file` + direct shell execution | local CLI | planned | LF terminators and suite reaches final OK marker |
| `DOD-11` | Definition of Done | Delphi agnosticism | review | bounded diff | n/a | planned | generic fixture names only |
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

## Decision Pending (Resolve Before Freeze)

- [x] `none — topology semantics and fail-closed behavior are frozen below`.

## Decisions (Resolved Before Freeze)

- [x] `D-01` Supported authority roots are `<repo>/foundation_documentation/todos` and `<repo>/todos`; names below `todos/` retain the existing active/promotion/completed semantics.
- [x] `D-02` Path classification is relative to resolved authority roots, not hard-coded absolute path segments.
- [x] `D-03` A candidate authority is supported only when its `active/` child exists as a directory; equivalent roots/paths produced by symlinks are deduplicated after canonical resolution, while two distinct supported roots are rejected as ambiguous.
- [x] `D-04` Explicit paths outside supported roots—including escaping leaf symlinks—and all-active scans without exactly one supported root fail closed.
- [x] `D-05` A supported root with an existing but empty `active/` directory is valid; an existing `todos/` candidate without `active/` is unsupported and returns a typed no-go.
- [x] `D-06` A relative explicit TODO path remains relative to the process current working directory. `--repo` identifies the repository/container whose immediate root candidates and resolved Git worktree provide discovery and Git metadata.
- [x] `D-07` Explicit governed inputs must be existing regular `.md` files. Missing, directory, and non-Markdown inputs are governance no-go results (exit `2`), while argparse misuse stays exit `2`, unexpected runtime/tool failures stay exit `1`, and advisory mode returns `0` after reporting any governed findings.
- [x] `D-08` Discovery-level violations are first-class result violations with an optional `todo_path`; text/JSON renderers must not require a synthetic per-TODO result.
- [x] `D-09` The shell fixture is normalized to LF as part of this fix so its direct Linux/WSL command is authoritative.
- [x] `D-10` No instruction/workflow/template change is needed because the existing CLI contract is already generic; the implementation was narrower than its contract.

## Module Decision Baseline Snapshot

| Module Decision Ref | Current Module Decision | Planned Handling (`Preserve|Supersede (Intentional)|Out of Scope`) | Evidence |
| --- | --- | --- | --- |
| `todo-closeout-promotion-method#active-todo-scan` | Closeout validation applies to active TODOs under the governing Foundation authority, independent of whether that authority is nested or standalone. | `Preserve` | `workflows/docker/todo-closeout-promotion-method.md` |
| `todo_closeout_guard.py#path-state` | Classification currently matches hard-coded nested path segments and can return false `go` for standalone authorities. | `Supersede (Intentional)` | observed explicit standalone reproduction |
| `todo_closeout_guard.py#all-active` | Discovery currently scans only `foundation_documentation/todos/active` and treats an absent root as an empty successful scan. | `Supersede (Intentional)` | observed standalone `todo_count=0`, outcome `go` |
| `todo_closeout_guard.py#exit-contract` | Documented exits are `0` go, `2` governed no-go, and `1` runtime/tool misuse; argparse independently uses `2`. | `Preserve + Clarify` | module docstring + `argparse` behavior |

## Decision Baseline (Frozen Before Implementation)

- [x] `D-01` Preserve nested layout behavior.
- [x] `D-02` Add standalone layout behavior without project-specific aliases.
- [x] `D-03` Eliminate false `go` for unrecognized explicit paths and missing roots.
- [x] `D-04` Keep the guard non-mutating.
- [x] `D-05` Treat root ambiguity, invalid governed input, and authority escape as typed governance violations rather than successful empty work or traceback.
- [x] `D-06` Preserve CWD-relative explicit paths, direct Linux/WSL fixture execution, and the documented/advisory exit behavior.

## Architecture Change Governance

- **Applicability:** `required`
- **Why this applies:** shared guard authority resolution changes and false-green evidence can affect every TODO closeout.
- **Deviation / debt being retired:** advertised generic `--repo` behavior is implemented as a hard-coded nested topology.
- **Target steady-state after closeout:** one generic resolver supplies classification and discovery for both supported layouts; no parallel topology logic.
- **Temporary exceptions allowed:** `none`
- **Compatibility window:** immediate; nested behavior stays supported permanently.
- **Cutover / removal condition:** all topology fixtures pass and no hard-coded project alias exists.

### Patterns To Enforce

| Pattern / Decision | Source / ID | Scope | Why It Must Hold After Cutover |
| --- | --- | --- | --- |
| one authority resolver | `D-01` through `D-05` | explicit classification and all-active discovery | Both CLI modes must share identical topology, ambiguity, and escape semantics. |
| classification relative to a recognized resolved root | `D-02`, `D-04` | every explicit TODO | Misleading absolute path segments and escaping symlinks must never grant authority. |
| fail-closed discovery | `D-03`, `D-05` | `--all-active` | Missing, malformed, or ambiguous authority cannot become an empty `go`. |
| canonical deduplication | `D-03`, `DOD-04` | roots and TODO paths | Equivalent aliases must produce one authority and one result. |
| typed boundary failures | `D-07`, `D-08` | governed filesystem inputs | Expected invalid inputs remain machine-readable no-go results without traceback. |

### Prohibited Anti-Patterns

| Anti-Pattern / Wrong Path | Detection Signal | Why It Is Forbidden After Cutover | Exception Policy |
| --- | --- | --- | --- |
| absolute segment matching for authority | classification searches for `foundation_documentation/todos` anywhere in a resolved path | An external misleading suffix can be mistaken for governed authority. | `none` |
| absent authority treated as empty success | zero candidate roots yields count zero and `go` | It recreates the release-gate false positive. | `none` |
| project-specific or fixture-only aliases | downstream name/path appears in source or only fixtures are special-cased | The shared guard must remain Delphi-generic. | `none` |
| divergent explicit/discovery resolvers | separate root rules in `load_todo` and `discover_active_todos` | The modes can silently disagree again. | `none` |
| first-root-wins ambiguity | two distinct candidate roots are scanned or one is silently preferred | Authority selection becomes order-dependent. | `none` |

### Architecture Protection Harness

| Harness Type | Surface | Command / Rule / Artifact | Regression It Must Catch | Adoption Timing | Evidence Plan / Follow-up |
| --- | --- | --- | --- | --- | --- |
| test | authority-root resolution | `todo_closeout_guard_test.sh` | standalone classified as other | implement-in-this-todo | RED/GREEN fixture |
| test | all-active discovery | `todo_closeout_guard_test.sh` | zero-count false go | implement-in-this-todo | exact count assertions |
| test | fail closed | `todo_closeout_guard_test.sh` | missing root/outside path returns go | implement-in-this-todo | negative assertions |
| test | direct Linux/WSL execution | `bash tools/tests/todo_closeout_guard_test.sh` | CRLF prevents the harness from reaching fixtures | implement-in-this-todo | LF normalization + final OK assertion |

## Architecture Review Gates

- **Architecture decision review:** `required`
- **Decision review lifecycle:** `after diagnosis is closed and before APROVADO`
- **Decision review kind:** `architecture_opinion`
- **Decision review package:** `bounded-file-set`
- **Decision review status:** `findings_integrated`
- **Decision review evidence / resolution:** `R1 architecture opinion returned NO-GO with ARQ-01..04; every finding is resolved in the R1 ledger and frozen semantics; a fresh R2 reviewer must confirm no material findings before APROVADO.`
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
- **Baseline commit:** `00392eef2460232337da01333af6d76fdc25b051`
- **Baseline push reference:** `origin/feat/add-stack-capabilities`
- **Gate status:** `findings_integrated`
- **Findings summary:** R1 material findings integrated: exact authority-state model, symlink dedup/escape semantics, explicit-input/exit contract, LF harness, canonical architecture schema, and 1:1 evidence mapping; refreshed baseline published for R2.
- **Evidence / reference:** `origin/feat/add-stack-capabilities@00392eef2460232337da01333af6d76fdc25b051`; R1 architecture and plan critique finding ledgers integrated.
- **Waiver authority / reference:** `n/a`

## Gate: Review Scope Drift

- **Gate decision:** `required`
- **Why this decision:** behavior and test scope must remain identical to the reviewed baseline.
- **Trigger stage:** `after planning reviews converge and before APROVADO`
- **Baseline source:** `Gate: Review Baseline Freeze -> Baseline commit`
- **Material sections compared:** `template canonical set`
- **Guard command:** `python3 tools/review_scope_drift_guard.py --todo foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md`
- **Gate status:** `not_run`
- **Findings summary:** `pending refreshed baseline and R2 convergence`
- **Evidence / reference:** `R1 changes are material by design; drift will run only after the refreshed baseline is published and reviewed.`
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
4. **Required RED tests:** desired standalone explicit/all-active behavior, CWD-relative paths, root/file alias deduplication, escaping leaf/outside-root rejection, invalid explicit inputs, zero/malformed/ambiguous roots, valid empty-active, exact exit codes, JSON rendering, and direct LF harness execution. Each RED asserts the desired contract and must fail against current guard behavior; reproducing the current false-green is diagnosis, not RED.
5. **Analyzer prevention:** `no-rule-needed`; this is runtime path-resolution behavior, best prevented by deterministic fixtures rather than a static analyzer rule.

| Stage | Coverage Before Fix | Required Evidence |
| --- | --- | --- |
| nested authority resolution | covered | preserve existing suite |
| standalone explicit classification | missing | RED fixture then GREEN |
| standalone all-active discovery | missing | RED exact-count fixture then GREEN |
| symlink canonicalization | missing | dedup fixture |
| unknown root/path rejection | false-green | negative fixtures requiring no-go |
| explicit input validation | traceback/unchecked | typed missing/directory/non-Markdown fixtures |
| Linux/WSL harness entry | CRLF-broken | LF normalization and direct execution |
| disposition parsing | covered | preserve existing suite |
| JSON/advisory output | covered | preserve existing suite + standalone scan |

## Execution Plan

### Touched Surfaces

- `tools/todo_closeout_guard.py`
- `tools/tests/todo_closeout_guard_test.sh`
- `artifacts/analysis/standalone-foundation-closeout-guard-delivery-package.md`
- this tactical TODO

### Ordered Steps

1. Normalize the existing shell harness to LF, then add tests that assert the desired standalone, relative-path, invalid-input, outside/escape, deduplication, and root-state contracts; capture their failure against the current guard as RED.
2. Extract one generic supported-root resolver used by explicit classification and all-active discovery. Accept only candidates with an `active/` directory, deduplicate resolved aliases, and reject distinct simultaneous authorities.
3. Add typed result-level violations for invalid explicit inputs, unrecognized/escaping paths, missing/malformed roots, and ambiguous roots; keep them printable and JSON-serializable without a synthetic TODO result.
4. Preserve nested behavior, CWD-relative explicit paths, empty-active success, exact exit/advisory behavior, disposition parsing, resolved-repo Git metadata, JSON, and non-mutation with individual assertions.
5. Produce the bounded derived audit package; run targeted suite, compile, self-check, diff/authority/completion gates, independent reviews/audits, and closeout.

### Test Strategy

- **Strategy:** `test-first`.
- **Evidence layers:** unit-like CLI fixtures plus integration/contract execution of the real Python entry point against real temporary directories and symlinks.
- **No external substitution:** no database, network, container, or project-specific fixture is needed.
- **Fail-first targets:** every behavior named in `DOD-01` through `DOD-10`; a RED must assert desired behavior and fail against the current source, never assert the known false-green as success.

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
| closeout guard fixture suite | behavior changes | nested + standalone + invalid input + negative/ambiguous topology + exits/JSON | self-seeded mktemp dirs/symlinks; LF harness | `bash tools/tests/todo_closeout_guard_test.sh` | Local-Implemented | planned | command output | direct Linux/WSL execution; exact count/path/code/exit assertions |
| Delphi self-check | shared tooling coherence | repository checks | principal checkout | `bash self_check.sh` | Local-Implemented | planned | command output | authoritative broad gate |

## Plan Review Gate

### Review Sections

- [x] Architecture — one resolver, one authority, explicit ambiguity and escape semantics.
- [x] Code Quality — pure boundary helpers and typed result violations instead of scattered branches/tracebacks.
- [x] Tests — desired-behavior RED cases at the real CLI boundary with exact fields/counts/codes/exits.
- [x] Performance — two bounded candidates, canonical-set deduplication, unchanged recursive scan complexity.
- [x] Security — recognized-root containment after resolution; leaf symlink escape fails closed.
- [x] Elegance — layout differences are data-driven candidates, not duplicated mode-specific code.
- [x] Structural Soundness — authority discovery, classification, rendering, and exit mapping each have one responsibility and a shared result model.

### Issue Cards

- **Issue `PR-01` — authority state and ambiguity were underspecified (`high`).**
  - **Evidence / why now:** R1 architecture and critique found no frozen distinction among zero roots, `todos/` without `active/`, an empty `active/`, equivalent aliases, and two distinct roots; implementation choices here decide whether the false `go` survives in another form.
  - **Option A (chosen):** candidate is supported only with an `active/` directory; zero/incomplete and two distinct authorities are typed no-go; one empty active is go; equivalent resolved candidates deduplicate. Effort `medium`; risk `low`; blast `shared-tool`; maintenance `low`; performance `neutral`; elegance `improves`; structure `improves`.
  - **Option B:** accept any `todos/` and prefer nested when both exist. Effort `low`; risk `high`; blast `shared-tool`; maintenance `medium`; performance `neutral`; elegance `neutral`; structure `regresses`.
  - **Option C:** keep first-existing-root behavior. Effort `low`; risk `high`; blast `cross-project`; maintenance `high`; performance `neutral`; elegance `regresses`; structure `regresses`.
  - **Resolution:** Option A is frozen in `D-03` through `D-05`, `DOD-04/DOD-06`, and exact fixtures.
- **Issue `PR-02` — symlink and containment claims did not prove deduplication or escape rejection (`high`).**
  - **Evidence / why now:** the original single symlink fixture could pass without exercising two equivalent root aliases or file aliases, while a leaf symlink could resolve outside authority.
  - **Option A (chosen):** separate `--repo` symlink, equivalent-root, equivalent-file, misleading outside suffix, and leaf-escape fixtures; assert exactly one result or exact outside-authority code. Effort `medium`; risk `low`; blast `shared-tool`; maintenance `low`; performance `neutral`; elegance `improves`; structure `improves`.
  - **Option B:** test only a symlinked repo. Effort `low`; risk `high`; blast `shared-tool`; maintenance `medium`; performance `neutral`; elegance `neutral`; structure `neutral`.
  - **Option C:** reject every symlink. Effort `low`; risk `medium`; blast `cross-project`; maintenance `low`; performance `neutral`; elegance `regresses`; structure `regresses`.
  - **Resolution:** Option A is frozen in `DOD-04/DOD-05` and the completion matrix.
- **Issue `PR-03` — explicit input and exit behavior could traceback or serialize inconsistently (`high`).**
  - **Evidence / why now:** current code reads before authorization; missing paths traceback, non-active outside files can return `go`, and `print_result` assumes every violation has `todo_path`.
  - **Option A (chosen):** validate governed explicit inputs up front, emit typed result-level violations with optional path context, preserve `0` go / `2` governed no-go / `1` unexpected tool failure, and keep argparse misuse at its native `2`. Effort `medium`; risk `low`; blast `shared-tool`; maintenance `low`; performance `neutral`; elegance `improves`; structure `improves`.
  - **Option B:** catch all exceptions and return one generic error. Effort `low`; risk `medium`; blast `shared-tool`; maintenance `medium`; performance `neutral`; elegance `neutral`; structure `regresses`.
  - **Option C:** retain traceback/runtime exit `1` for filesystem mistakes. Effort `none`; risk `high`; blast `cross-project`; maintenance `high`; performance `neutral`; elegance `regresses`; structure `regresses`.
  - **Resolution:** Option A is frozen in `D-07/D-08`, `DOD-05/DOD-07/DOD-09`, and exact JSON/text assertions.
- **Issue `PR-04` — relative path and `--repo` ownership semantics were implicit (`medium`).**
  - **Evidence / why now:** canonical workflows often invoke a relative TODO from repository root, while `--repo` also drives discovery and Git context; changing anchoring would be an accidental CLI break.
  - **Option A (chosen):** preserve relative TODO resolution from process CWD; resolve `--repo` separately as the authority container and Git-context worktree. Effort `low`; risk `low`; blast `shared-tool`; maintenance `low`; performance `neutral`; elegance `improves`; structure `improves`.
  - **Option B:** anchor explicit TODO to `--repo`. Effort `low`; risk `medium`; blast `cross-project`; maintenance `low`; performance `neutral`; elegance `neutral`; structure `neutral`.
  - **Option C:** require absolute paths. Effort `low`; risk `high`; blast `cross-project`; maintenance `medium`; performance `neutral`; elegance `regresses`; structure `regresses`.
  - **Resolution:** Option A is frozen in `D-06`, `DOD-08`, and nested/standalone CWD fixtures.
- **Issue `PR-05` — the current Linux/WSL fixture command is materially broken by CRLF (`high`).**
  - **Evidence / why now:** direct `bash tools/tests/todo_closeout_guard_test.sh` fails at `set -euo pipefail\r`; a stream-normalized copy passes, proving both a runner defect and false-green logical coverage.
  - **Option A (chosen):** normalize the tracked harness to LF before RED additions and require direct execution to reach its final marker. Effort `low`; risk `low`; blast `test-only`; maintenance `low`; performance `neutral`; elegance `improves`; structure `improves`.
  - **Option B:** pipe through `tr -d '\r'` in validation. Effort `low`; risk `medium`; blast `test-only`; maintenance `high`; performance `neutral`; elegance `regresses`; structure `regresses`.
  - **Option C:** ignore the Linux/WSL lane. Effort `none`; risk `high`; blast `release-gate`; maintenance `high`; performance `neutral`; elegance `regresses`; structure `invalid`.
  - **Resolution:** Option A is frozen in `D-09`, `DOD-10`, and `VAL-02`.
- **Issue `PR-06` — test-first and compatibility evidence were grouped too loosely (`medium`).**
  - **Evidence / why now:** the former plan said to assert the current false-green as RED and grouped disposition, advisory, JSON, Git, and non-mutation into one undifferentiated criterion.
  - **Option A (chosen):** RED asserts desired behavior and fails current code; every compatibility dimension gets a direct assertion and completion-matrix mapping. Effort `medium`; risk `low`; blast `test`; maintenance `medium`; performance `neutral`; elegance `improves`; structure `improves`.
  - **Option B:** retain grouped smoke coverage. Effort `low`; risk `medium`; blast `shared-tool`; maintenance `low`; performance `neutral`; elegance `neutral`; structure `neutral`.
  - **Option C:** rely on status/exit only. Effort `low`; risk `high`; blast `cross-project`; maintenance `high`; performance `neutral`; elegance `regresses`; structure `regresses`.
  - **Resolution:** Option A is frozen in the Bug-Fix Evidence Gate, ordered steps, `DOD-09`, and completion matrix.
- **Issue `PR-07` — planning package and schema were internally inconsistent (`medium`).**
  - **Evidence / why now:** Contract Boundary/Touched Surfaces omitted the derived package allowed by the diff contract; architecture schema lacked temporary exceptions/patterns/anti-patterns; headings were invisible to scope-drift comparison.
  - **Option A (chosen):** include the derived artifact in every boundary, adopt canonical headings/schema, and record R1 finding resolutions before publishing a new baseline. Effort `low`; risk `low`; blast `governance`; maintenance `low`; performance `neutral`; elegance `improves`; structure `improves`.
  - **Option B:** remove the artifact and keep ad hoc sections. Effort `low`; risk `medium`; blast `audit`; maintenance `medium`; performance `neutral`; elegance `neutral`; structure `regresses`.
  - **Option C:** request approval with inconsistent schema. Effort `none`; risk `high`; blast `release-gate`; maintenance `high`; performance `neutral`; elegance `regresses`; structure `invalid`.
  - **Resolution:** Option A is integrated across Contract Boundary, diff contract, Touched Surfaces, canonical decision sections, and Architecture Change Governance.

### Failure Modes & Edge Cases

- [x] Both candidate roots resolve to the same symlink target: deduplicate and scan once.
- [x] Both candidate roots resolve to distinct authorities: typed ambiguous-authority no-go.
- [x] A candidate `todos/` exists without `active/`: typed unsupported/missing-active no-go.
- [x] A supported `active/` exists but is empty: valid `go`, count zero.
- [x] No supported root exists: typed missing-authority no-go.
- [x] Explicit TODO is outside supported roots despite a misleading suffix: exact outside-authority no-go.
- [x] Explicit leaf symlink escapes authority: exact outside-authority no-go.
- [x] Explicit TODO path is missing, a directory, or not Markdown: typed no-go, no traceback.
- [x] Relative explicit paths from nested and standalone roots: preserve CWD anchoring.
- [x] Discovery-level violation has no TODO result: render text/JSON safely.
- [x] Nested behavior regresses while standalone becomes green: existing matrix plus direct nested relative fixture catches it.

### Residual Unknowns / Risks

- [x] Windows junction behavior is not separately claimed; canonical `Path.resolve()` semantics and the authoritative Linux/WSL symlink fixtures are the bounded contract.
- [x] Argparse misuse and governance no-go both use exit `2`; differentiation is by argparse output versus structured guard result, preserving current CLI behavior.
- [x] `--repo` may itself be a symlink, but this TODO does not authorize arbitrary recursive search for TODO roots beyond its two immediate candidate layouts.

### R1 Review Finding Resolution Ledger

| Finding | Source | Resolution | Status |
| --- | --- | --- | --- |
| `ARQ-01` | architecture R1 | split repo-symlink, root-alias, and file-alias fixtures with exact one-result assertions | integrated |
| `ARQ-02` | architecture R1 | supported root requires `active/`; missing versus empty states frozen | integrated |
| `ARQ-03` | architecture R1 | CWD-relative behavior and misleading outside-suffix exact code frozen | integrated |
| `ARQ-04` | architecture R1 | derived audit package added consistently to boundary and touched surfaces | integrated |
| `PR-R1-01..07` | plan critique R1 | freeze/schema, semantic, CRLF, RED, exit/JSON, and diff inconsistencies resolved by `PR-01` through `PR-07` | integrated; fresh R2 required |

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
- **Critique status:** `findings_integrated`
- **Findings summary:** `R1 returned NO-GO; seven material issue families are integrated as PR-01..PR-07; fresh R2 is mandatory before APROVADO`.
- **Evidence / reference:** `R1 no-context critique + R1 Review Finding Resolution Ledger`.
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
| `D-06` | pending | pending implementation | relative path and resolved repo/Git semantics |
| `D-07` | pending | pending implementation | explicit-input and exit contract |
| `D-08` | pending | pending implementation | discovery-level result rendering |
| `D-09` | pending | pending implementation | LF harness |
| `D-10` | pending | pending implementation | no docs change |

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
