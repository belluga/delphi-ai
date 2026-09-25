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

- This TODO changes only the deterministic closeout guard, its regression fixtures, its canonical `tools/manifest.md` inventory entry, the bounded derived audit package, and this governing TODO.
- The guard remains read-only except for the already-supported optional JSON evidence output.
- CLI arguments and valid nested-layout behavior remain backward compatible; previously unchecked invalid/ambiguous inputs intentionally become typed no-go results.
- No downstream project identity, path, TODO content, or business term may be embedded in Delphi code/tests/docs.

## Implementation Intent

- **Current delivery:** generic authority-root resolution and fail-closed regression coverage for the closeout guard.
- **Planned next step:** unblock downstream Foundation closeout validation after this slice is completed and published.
- **Anticipatory implementation authorized now:** `none`.
- **Rationale:** only the proven false-positive paths belong in this fix.

## Delivery Status Canon

- **Current delivery stage:** `Pending`
- **Qualifiers:** `none`
- **Next exact step:** conclude and adjudicate the two fresh R6 reviews, then run assumption coherence, scope drift, and authority preflight; request `APROVADO` only if every pre-approval gate is green.

## Active Work State

- **Work state:** `implementation`
- **Why this state now:** the active TODO is still gaining/changing planning and pre-implementation evidence; product implementation has not started.
- **Exit condition:** implementation and local validation become materially complete, then the state transitions to `review` for delivery gates.

## Scope

- [ ] Add a generic authority-root resolver that recognizes `<repo>/foundation_documentation/todos` and `<repo>/todos` without project-specific names.
- [ ] Classify explicit TODO paths relative to the resolved authority root instead of matching hard-coded absolute path parts after `resolve()`.
- [ ] Recognize lifecycle only from the first relative component below the authority root (`active`, `promotion_lane`, or `completed`); reject every other explicit in-authority state, including deeper `active` lure segments.
- [ ] Discover active TODOs in either supported topology, deduplicate equivalent resolved roots/paths, and reject simultaneous distinct authorities as ambiguous.
- [ ] Fail closed when an explicit TODO is outside every supported authority root.
- [ ] Fail closed when `--all-active` cannot find exactly one supported TODO authority root; distinguish no root, a candidate `todos/` without `active/`, an ambiguous pair of distinct roots, and a valid empty `active/` directory.
- [ ] Validate explicit inputs before reading: an existing regular Markdown file is required; missing paths, directories, and non-Markdown files fail closed without traceback.
- [ ] Canonicalize and containment-check `active/` plus every discovered TODO; reject an `active/` directory symlink or discovered leaf symlink that escapes the resolved authority, and deduplicate equivalent discovered aliases.
- [ ] Preserve relative explicit-path semantics anchored to the process current working directory and define `--repo` as the repository/container whose two immediate authority candidates and Git context are inspected.
- [ ] Add RED/GREEN regression fixtures for nested, standalone, relative-path, root-symlink, equivalent-root/path deduplication, escaping leaf symlink, unrecognized-path, invalid explicit input, missing/ambiguous root, exact exit codes, JSON shape, and real active-count behavior.
- [ ] Preserve existing disposition parsing, git-state handling, JSON output, advisory exit behavior, and non-mutating semantics.
- [ ] Update the guard docstring/help text inside the same source file so both supported layouts and boundary outcomes are accurately advertised.
- [ ] Update `tools/manifest.md` in the same change so the canonical inventory describes dual-layout authority resolution and fail-closed boundary validation.

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
| standalone closeout guard support | `feat/add-stack-capabilities@87e2237` | `origin/feat/add-stack-capabilities@87e2237` | n/a | release-package-owned | R6 material baseline published; reviews running |

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
| `delphi-ai` | `tools/manifest.md` | `M` | mandatory canonical inventory synchronization for the materially changed guard |
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
- **Must update or split the TODO:** CLI redesign, new policy semantics, automatic mutations, changes outside the six expected paths, or support for an additional unrelated repository layout.

## Definition of Done

- [ ] `DOD-01` An explicit active TODO under standalone `<repo>/todos/active/**` reports `path_state=active` and is actually validated.
- [ ] `DOD-02` `--all-active --repo <standalone>` discovers the real active TODO count and validates each file.
- [ ] `DOD-03` Existing nested `<repo>/foundation_documentation/todos/**` behavior remains green.
- [ ] `DOD-04` A symlink used as `--repo` resolves to the standalone repository, and two candidate roots or file aliases resolving to the same authority/TODO produce exactly one scan and one `todo_result`.
- [ ] `DOD-05` Explicit outside paths, misleading suffixes, and escaping leaf symlinks emit `CLOSEOUT-TODO-OUTSIDE-AUTHORITY`, exit `2`, and no TODO result.
- [ ] `DOD-06` Root-state semantics emit the exact schema codes: missing root, incomplete root, ambiguous distinct roots in both explicit/all-active modes, and valid empty active behavior.
- [ ] `DOD-07` Explicit missing paths, directories, and non-Markdown files emit their exact catalog codes at exit `2` without traceback; argparse misuse remains exit `2`.
- [ ] `DOD-08` Relative explicit TODO arguments remain anchored to the process current working directory and work from both nested and standalone repository roots.
- [ ] `DOD-09` Explicit in-authority lifecycle classification uses only the first relative component; unknown/direct-root/deeper-lure cases emit `CLOSEOUT-TODO-LIFECYCLE-UNRECOGNIZED` in nested and standalone fixtures.
- [ ] `DOD-10` All-active discovery containment is enforced separately: a leaf symlink escape is excluded with `CLOSEOUT-TODO-OUTSIDE-AUTHORITY`; an `active/` directory escape emits `CLOSEOUT-AUTHORITY-ACTIVE-ESCAPE`; equivalent discovered aliases deduplicate.
- [ ] `DOD-11` Existing disposition parsing scenarios retain direct assertions.
- [ ] `DOD-12` Advisory mode preserves the no-go envelope and returns exit `0`; normal governance no-go returns `2`; deterministic JSON-output write failure returns runtime/tool exit `1`.
- [ ] `DOD-13` JSON output satisfies every Boundary Violation and Result Schema invariant, including `todo_count == len(todo_results)`, stable nullable `todo_path`, and mixed discovery results.
- [ ] `DOD-14` Git metadata is taken from the resolved `--repo` Git worktree and asserted in a temporary committed repository.
- [ ] `DOD-15` A before/after filesystem snapshot proves the guard is non-mutating except for an explicitly requested JSON output file.
- [ ] `DOD-16` Root-level discovery violations render in text and JSON without a synthetic `todo_result`; text prints `todo_path: n/a` and JSON stores `null`.
- [ ] `DOD-17` The shell harness is normalized to LF and executes directly in the declared Linux/WSL lane.
- [ ] `DOD-18` The guard docstring/help advertises both authority layouts without a nested-only claim.
- [ ] `DOD-19` No downstream project name/path/business concept is persisted in Delphi surfaces.
- [ ] `DOD-20` Explicit mode under an `active/` directory that resolves outside authority emits `CLOSEOUT-AUTHORITY-ACTIVE-ESCAPE` (not the leaf outside code), with the candidate active path, count `0`, results `[]`, and exit `2`.
- [ ] `DOD-21` `tools/manifest.md` describes the guard's dual-layout resolution and fail-closed authority/input behavior in the same change.

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
| `DOD-05` | Definition of Done | explicit outside authority | negative test | `misleading-outside-authority`; explicit `leaf-symlink-escape` | local CLI | planned | exact `CLOSEOUT-TODO-OUTSIDE-AUTHORITY`, count `0`, exit `2` |
| `DOD-06` | Definition of Done | root-state catalog | negative+positive tests | `missing-authority-root`; `missing-active-directory`; `empty-active-authority`; explicit/all-active `distinct-authorities` | local CLI | planned | exact catalog codes, nullable paths, counts, and exits |
| `DOD-07` | Definition of Done | explicit input catalog + argparse | negative test | `missing-explicit`; `directory-explicit`; `non-markdown-explicit`; argparse misuse | local CLI | planned | exact three codes, governance `2`, argparse `2`, no governed traceback |
| `DOD-08` | Definition of Done | relative path compatibility | regression | nested and standalone invocation from each repository root | local CLI | planned | path remains CWD-relative |
| `DOD-09` | Definition of Done | exact lifecycle component | negative test | nested/standalone `archive`; direct-root Markdown; `archive/active` lure | local CLI | planned | exact unrecognized-lifecycle code and exit `2` |
| `DOD-10` | Definition of Done | all-active item/directory containment + dedup | negative+positive tests | discovered leaf escape; `active/` escape; discovered equivalent file aliases | local CLI | planned | escaped items excluded; exact codes; unique result count |
| `DOD-11` | Definition of Done | disposition compatibility | regression | existing missing/move/keep-active/blocked scenarios | local CLI | planned | each established disposition code/outcome asserted |
| `DOD-12` | Definition of Done | advisory and exact process exits | regression+negative test | advisory no-go; normal no-go; `--json-output <existing-directory>` | local CLI | planned | `0`, `2`, and deterministic runtime `1` respectively |
| `DOD-13` | Definition of Done | JSON envelope | contract test | root errors, explicit errors, mixed valid+escape discovery, normal TODO violations | local CLI | planned | schema invariants and exact nullable paths |
| `DOD-14` | Definition of Done | resolved Git context | integration test | symlinked `--repo` pointing at temporary initialized/committed Git worktree | local CLI | planned | `git.root` equals resolved `rev-parse --show-toplevel`; clean/sync fields retain types |
| `DOD-15` | Definition of Done | non-mutation | snapshot test | before/after path+content+mode digest, excluding requested JSON output | local CLI | planned | snapshots identical |
| `DOD-16` | Definition of Done | discovery violation rendering | contract test | root-level missing/ambiguous violation | local CLI | planned | no TODO result; text `n/a`; JSON `null` |
| `DOD-17` | Definition of Done | Linux/WSL harness execution | test | `file` + direct shell execution | local CLI | planned | LF terminators and suite reaches final OK marker |
| `DOD-18` | Definition of Done | accurate CLI documentation | test+review | `--help` and source docstring assertion | local CLI | planned | both layouts represented; no nested-only all-active help |
| `DOD-19` | Definition of Done | Delphi agnosticism | review | bounded diff | n/a | planned | generic fixture names only |
| `DOD-20` | Definition of Done | explicit active-directory escape precedence | negative contract test | explicit TODO below escaped `active/` | local CLI | planned | exact active-escape code/path/count/results/exit; no leaf-code substitution |
| `DOD-21` | Definition of Done | canonical tool inventory synchronization | review+assertion | `tools/manifest.md` row for `todo_closeout_guard.py` | local docs | planned | dual-layout + fail-closed semantics present |
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
- **Scope-check command:** `python3 tools/profile_scope_check.py --profile strategic-cto tools/todo_closeout_guard.py tools/tests/todo_closeout_guard_test.sh tools/manifest.md artifacts/analysis/standalone-foundation-closeout-guard-delivery-package.md foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md`
- **Scope-check outcome:** `review required`; the TODO is allowed and the tool/test/derived-artifact paths are explicitly routed through the handoffs below.

### Handoff Log

| From Profile | To Profile | Why the Handoff Exists | Touched Surfaces | Status / Evidence |
| --- | --- | --- | --- | --- |
| strategic-cto | operational-coder | minimal deterministic Python implementation | `tools/todo_closeout_guard.py` | planned; scope-check unknown is expected and routed |
| operational-coder | assurance-tester-quality | false-green regression and negative cases | `tools/tests/todo_closeout_guard_test.sh` | planned; scope-check unknown is expected and routed |
| assurance-tester-quality | strategic-cto | final agnosticism/contract review, canonical tool-inventory synchronization, and derived packet | bounded diff + `tools/manifest.md` + `artifacts/analysis/**` | planned; scope-check unknown is expected and routed |

## Complexity

- **Level (`small|medium|big`):** `medium`
- **Checkpoint policy:** `single bounded implementation checkpoint`
- **Why this level:** the code change is localized, but the guard is shared release-governance infrastructure and the defect is a false-positive gate.

## Canonical Module Anchors

- **Primary module doc:** `tools/todo_closeout_guard.py`
- **Secondary module docs:** `tools/tests/todo_closeout_guard_test.sh`, `tools/manifest.md`, `workflows/docker/todo-closeout-promotion-method.md`
- **Planned decision promotion targets:** `none — current workflow already declares the intended generic behavior`.
- **Module decision consolidation targets:** `none`.

## Decision Pending (Resolve Before Freeze)

- [x] `none — topology semantics and fail-closed behavior are frozen below`.

## Decisions (Resolved Before Freeze)

- [x] All resolved implementation decisions are recorded exactly once in `Decision Baseline (Frozen Before Implementation)` below; no parallel decision-ID namespace or additional unresolved decision exists.

## Module Decision Baseline Snapshot

| Module Decision Ref | Current Module Decision | Planned Handling (`Preserve|Supersede (Intentional)|Out of Scope`) | Evidence |
| --- | --- | --- | --- |
| `todo-closeout-promotion-method#active-todo-scan` | Closeout validation applies to active TODOs under the governing Foundation authority, independent of whether that authority is nested or standalone. | `Preserve` | `workflows/docker/todo-closeout-promotion-method.md` |
| `todo_closeout_guard.py#path-state` | Classification currently matches hard-coded nested path segments and can return false `go` for standalone authorities. | `Supersede (Intentional)` | observed explicit standalone reproduction |
| `todo_closeout_guard.py#all-active` | Discovery currently scans only `foundation_documentation/todos/active` and treats an absent root as an empty successful scan. | `Supersede (Intentional)` | observed standalone `todo_count=0`, outcome `go` |
| `todo_closeout_guard.py#exit-contract` | Documented exits are `0` go, `2` governed no-go, and `1` runtime/tool misuse; argparse independently uses `2`. | `Preserve` | module docstring + `argparse` behavior; clarification is recorded in notes/schema without inventing a handling enum |

## Decision Baseline (Frozen Before Implementation)

- [x] `D-01` Supported authority roots are `<repo>/foundation_documentation/todos` and `<repo>/todos`; names below `todos/` retain the existing active/promotion/completed semantics.
- [x] `D-02` Path classification is relative to resolved authority roots, not hard-coded absolute path segments.
- [x] `D-03` A candidate authority is supported only when its `active/` child exists as a directory; equivalent roots/paths produced by symlinks are deduplicated after canonical resolution, while two distinct supported roots are rejected as ambiguous.
- [x] `D-04` Explicit paths outside supported roots—including escaping leaf symlinks—and all-active scans without exactly one supported root fail closed.
- [x] `D-05` A supported root with an existing but empty `active/` directory is valid; an existing `todos/` candidate without `active/` is unsupported and returns a typed no-go.
- [x] `D-06` A relative explicit TODO path remains relative to the process current working directory. `--repo` identifies the repository/container whose immediate root candidates and resolved Git worktree provide discovery and Git metadata.
- [x] `D-07` Explicit governed inputs must be existing regular `.md` files. Missing, directory, and non-Markdown inputs are governance no-go results (exit `2`), while argparse misuse stays exit `2`, unexpected runtime/tool failures stay exit `1`, and advisory mode returns `0` after reporting any governed findings.
- [x] `D-08` Discovery-level violations are first-class result violations with an always-present but nullable `todo_path`; text/JSON renderers must not require a synthetic per-TODO result.
- [x] `D-09` The shell fixture is normalized to LF as a harness precondition in this fix so its direct Linux/WSL command is authoritative; normalization is not represented as a guard-behavior RED.
- [x] `D-10` No instruction/workflow/template change is needed because the existing CLI contract is already generic; mandatory `tools/manifest.md` inventory synchronization is still required for the material tool change.
- [x] `D-11` Lifecycle classification uses exactly `relative.parts[0]`; recognized values are `active`, `promotion_lane`, and `completed`. Any other first component is `CLOSEOUT-TODO-LIFECYCLE-UNRECOGNIZED`, even when a later component is named `active`.
- [x] `D-12` `active/` and every discovered Markdown path are resolved and checked against the resolved authority before loading. Directory or leaf escape is never a TODO result.

### Boundary Violation and Result Schema

| Condition | Exact violation code | `todo_path` | `todo_count` / `todo_results` |
| --- | --- | --- | --- |
| neither candidate authority exists | `CLOSEOUT-AUTHORITY-MISSING` | `null` | `0` / `[]` |
| candidate `todos/` exists but no candidate has an `active/` directory | `CLOSEOUT-AUTHORITY-INCOMPLETE` | `null` | `0` / `[]` |
| two candidate roots resolve to distinct supported authorities | `CLOSEOUT-AUTHORITY-AMBIGUOUS` | `null` | `0` / `[]` in explicit and all-active modes |
| a candidate `active/` directory resolves outside its resolved authority (explicit or all-active mode) | `CLOSEOUT-AUTHORITY-ACTIVE-ESCAPE` | string path of the candidate `active/` alias | `0` / `[]`; resolver rejects the authority before explicit leaf classification or discovery |
| explicit or discovered TODO resolves outside the selected authority | `CLOSEOUT-TODO-OUTSIDE-AUTHORITY` | string path as supplied/discovered | path is excluded from count/results |
| explicit path does not exist | `CLOSEOUT-TODO-MISSING` | supplied path string | `0` / `[]` |
| explicit path exists but is not a regular file | `CLOSEOUT-TODO-NOT-FILE` | supplied path string | `0` / `[]` |
| explicit regular file is not `.md` (case-insensitive suffix policy is not added; exact suffix is `.md`) | `CLOSEOUT-TODO-NOT-MARKDOWN` | supplied path string | `0` / `[]` |
| explicit Markdown is within authority but first relative component is not a recognized lifecycle | `CLOSEOUT-TODO-LIFECYCLE-UNRECOGNIZED` | supplied path string | `0` / `[]` |

- **Envelope invariant:** `todo_count == len(todo_results)` and counts only unique resolved, authorized Markdown TODOs actually loaded.
- **Violation invariant:** every entry in top-level `violations` has `code`, `message`, `resolution`, `section`, and `todo_path`; `todo_path` is JSON `null` only when no concrete path exists (root missing/incomplete/ambiguous).
- **Mixed discovery invariant:** valid authorized files still produce `todo_results`; escaped/invalid discovered aliases do not, and any boundary violation forces `overall_outcome=no-go`.
- **Text invariant:** root-level `todo_path: null` renders as `todo_path: n/a`; JSON retains the explicit `null`.
- **Exit invariant:** normal go is `0`; every structured governance no-go above is `2`; `--advisory` reports the same envelope but returns `0`; argparse misuse remains `2`; a deterministic JSON-output write failure (`--json-output` points to an existing directory) proves unexpected tool/runtime exit `1`.

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
| test | lifecycle boundary | `todo_closeout_guard_test.sh` | unknown/direct/deeper-lure in-authority path returns go | implement-in-this-todo | exact first-component fixtures |
| test | discovery containment | `todo_closeout_guard_test.sh` | escaped `active/` or discovered leaf is loaded/counted | implement-in-this-todo | separate directory/leaf escape fixtures |
| contract | machine-readable envelope | `Boundary Violation and Result Schema` + JSON fixtures | codes/nullable path/count/results drift or renderer crash | implement-in-this-todo | literal schema assertions |
| test | direct Linux/WSL execution | `bash tools/tests/todo_closeout_guard_test.sh` | CRLF prevents the harness from reaching fixtures | implement-in-this-todo | LF normalization + final OK assertion |

## Architecture Review Gates

- **Architecture decision review:** `required`
- **Decision review lifecycle:** `after diagnosis is closed and before APROVADO`
- **Decision review kind:** `architecture_opinion`
- **Decision review package:** `bounded-file-set`
- **Decision review status:** `running`
- **Decision review evidence / resolution:** `R1 through R5 architecture opinions returned NO-GO; their findings are integrated in PR-01..PR-19, including exact module-table identity and operational status handling; fresh R6 confirmation is pending and this status intentionally remains non-satisfying until it completes.`
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
- **Baseline commit:** `87e2237946c91a2db7eb1ebdb0b1cbfcdb433429`
- **Baseline push reference:** `origin/feat/add-stack-capabilities`
- **Gate status:** `findings_integrated`
- **Findings summary:** R1-R5 material findings integrated: technical contract, status safety, single decision baseline, three-class test evidence, correct work state, and exact 4/4 module snapshot/adherence identity; refreshed R6 baseline published with review statuses intentionally running.
- **Evidence / reference:** `origin/feat/add-stack-capabilities@87e2237946c91a2db7eb1ebdb0b1cbfcdb433429`; R1-R5 architecture and critique ledgers integrated.
- **Waiver authority / reference:** `n/a`

## Gate: Review Scope Drift

- **Gate decision:** `required`
- **Why this decision:** behavior and test scope must remain identical to the reviewed baseline.
- **Trigger stage:** `after planning reviews converge and before APROVADO`
- **Baseline source:** `Gate: Review Baseline Freeze -> Baseline commit`
- **Material sections compared:** `template canonical set`
- **Guard command:** `python3 tools/review_scope_drift_guard.py --todo foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md`
- **Gate status:** `not_run`
- **Findings summary:** `R6 material baseline 87e2237946c91a2db7eb1ebdb0b1cbfcdb433429 is published; scope-drift rerun awaits R6 review convergence.`
- **Evidence / reference:** `review_scope_drift_guard will run after both R6 reviewers finish; no redundant baseline publication remains.`
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
3. **Existing failing test:** the tracked harness fails before fixtures under Linux/WSL because it is CRLF; when normalized only in a read-only stream, the existing logical suite passes because it never constructs a standalone authority.
4. **Required harness precondition evidence:** normalize the tracked script from CRLF to LF and prove direct Linux/WSL execution reaches logical fixtures; this migration is neither guard-behavior RED nor compatibility GREEN.
5. **Required behavior-changing RED tests:** standalone explicit/all-active (including standalone CWD-relative), equivalent file-alias deduplication, explicit/discovered leaf escape, explicit/all-active active-directory escape, unknown/direct/deeper-lure lifecycle, missing/directory/non-Markdown explicit input, missing/incomplete/distinct-ambiguous roots, new boundary/result schema and rendering, dual-layout help, and manifest description. Each asserts desired behavior and must fail against current source.
6. **Required baseline characterization/preservation GREEN tests:** nested explicit/all-active and nested CWD-relative behavior, symlinked `--repo`, equivalent root aliases that are already observationally count-one, existing disposition parsing, ordinary advisory/normal exits, deterministic JSON-output failure exit `1`, existing normal JSON envelope fields, resolved Git metadata, non-mutation, and valid empty-active outcome. These must pass before and after the fix; they must never be distorted merely to manufacture RED.
7. **Analyzer prevention:** `no-rule-needed`; this is runtime path-resolution behavior, best prevented by deterministic fixtures rather than a static analyzer rule.

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
- `tools/manifest.md`
- `artifacts/analysis/standalone-foundation-closeout-guard-delivery-package.md`
- this tactical TODO

### Ordered Steps

1. Record CRLF→LF as a harness precondition migration, capture the named baseline characterization cases as pre-fix GREEN (including repo/root aliases), then add desired behavior-changing tests and capture their failure against current source as RED (including equivalent file aliases, unknown lifecycle, and explicit/all-active leaf/directory escape).
2. Extract one generic supported-root resolver used by explicit classification and all-active discovery. Accept only contained candidates with an `active/` directory, deduplicate resolved aliases, and reject distinct simultaneous authorities.
3. Classify explicit lifecycle by the first component relative to authority and containment-check/deduplicate each all-active discovery result before loading.
4. Add the exact cataloged result-level violations and envelope invariants for invalid inputs, unrecognized lifecycle, escaping paths/directories, missing/incomplete roots, and ambiguity; render text/JSON without synthetic TODO results.
5. Preserve nested behavior, CWD-relative explicit paths, empty-active success, exact process/advisory behavior, disposition parsing, resolved-repo Git metadata, JSON, and non-mutation with individual assertions; update help/docstring and `tools/manifest.md` to the new dual-layout contract.
6. Produce the bounded derived audit package; run targeted suite, compile, self-check, diff/authority/completion gates, independent reviews/audits, and closeout.

### Test Strategy

- **Strategy:** `test-first`.
- **Evidence layers:** unit-like CLI fixtures plus integration/contract execution of the real Python entry point against real temporary directories and symlinks.
- **No external substitution:** no database, network, container, or project-specific fixture is needed.
- **Fail-first targets:** only the behavior-changing cases enumerated in Bug-Fix Evidence Gate item 5. Harness normalization is precondition evidence; preservation/characterization cases remain GREEN before and after the fix. A RED must assert desired changed behavior and fail against current source, never assert the known false-green as success.

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
  - **Option A (chosen):** validate governed explicit inputs up front, emit typed result-level violations with an always-present nullable path field, preserve `0` go / `2` governed no-go / `1` unexpected tool failure, and keep argparse misuse at its native `2`. Effort `medium`; risk `low`; blast `shared-tool`; maintenance `low`; performance `neutral`; elegance `improves`; structure `improves`.
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
  - **Resolution:** Option A is frozen in `D-09`, `DOD-17`, and `VAL-02`.
- **Issue `PR-06` — test-first and compatibility evidence were grouped too loosely (`medium`).**
  - **Evidence / why now:** the former plan said to assert the current false-green as RED and grouped disposition, advisory, JSON, Git, and non-mutation into one undifferentiated criterion.
  - **Option A (chosen):** RED asserts desired behavior and fails current code; every compatibility dimension gets a direct assertion and completion-matrix mapping. Effort `medium`; risk `low`; blast `test`; maintenance `medium`; performance `neutral`; elegance `improves`; structure `improves`.
  - **Option B:** retain grouped smoke coverage. Effort `low`; risk `medium`; blast `shared-tool`; maintenance `low`; performance `neutral`; elegance `neutral`; structure `neutral`.
  - **Option C:** rely on status/exit only. Effort `low`; risk `high`; blast `cross-project`; maintenance `high`; performance `neutral`; elegance `regresses`; structure `regresses`.
  - **Resolution:** Option A is frozen in the Bug-Fix Evidence Gate, ordered steps, atomic `DOD-11` through `DOD-16`, and completion matrix.
- **Issue `PR-07` — planning package and schema were internally inconsistent (`medium`).**
  - **Evidence / why now:** Contract Boundary/Touched Surfaces omitted the derived package allowed by the diff contract; architecture schema lacked temporary exceptions/patterns/anti-patterns; headings were invisible to scope-drift comparison.
  - **Option A (chosen):** include the derived artifact in every boundary, adopt canonical headings/schema, and record R1 finding resolutions before publishing a new baseline. Effort `low`; risk `low`; blast `governance`; maintenance `low`; performance `neutral`; elegance `improves`; structure `improves`.
  - **Option B:** remove the artifact and keep ad hoc sections. Effort `low`; risk `medium`; blast `audit`; maintenance `medium`; performance `neutral`; elegance `neutral`; structure `regresses`.
  - **Option C:** request approval with inconsistent schema. Effort `none`; risk `high`; blast `release-gate`; maintenance `high`; performance `neutral`; elegance `regresses`; structure `invalid`.
  - **Resolution:** Option A is integrated across Contract Boundary, diff contract, Touched Surfaces, canonical decision sections, and Architecture Change Governance.
- **Issue `PR-08` — unknown in-authority lifecycle could still false-go (`high`).**
  - **Evidence / why now:** R2 reviewers reproduced `todos/archive/sample.md` returning `go`; component-search classification could also accept `archive/active/sample.md` as active.
  - **Option A (chosen):** classify only `relative.parts[0]`, recognize exactly three lifecycle names, and emit a typed no-go for every other in-authority explicit path. Effort `low`; risk `low`; blast `shared-tool`; maintenance `low`; performance `neutral`; elegance `improves`; structure `improves`.
  - **Option B:** accept every non-active in-authority path as out-of-scope go. Effort `none`; risk `high`; blast `release-gate`; maintenance `high`; performance `neutral`; elegance `regresses`; structure `regresses`.
  - **Option C:** search recognized lifecycle names anywhere below authority. Effort `low`; risk `high`; blast `shared-tool`; maintenance `medium`; performance `neutral`; elegance `regresses`; structure `regresses`.
  - **Resolution:** Option A is frozen in `D-11`, the violation catalog, `DOD-09`, and nested/standalone unknown/direct/lure fixtures.
- **Issue `PR-09` — all-active discovery could follow authority/item symlink escapes (`high`).**
  - **Evidence / why now:** R2 reproduced a discovered `active/escape.md` symlink being counted while resolved outside authority; directory escape was not independently claimed.
  - **Option A (chosen):** containment-check resolved `active/` before scanning and every resolved item before load; exclude escaped leaves, reject escaped active directory, deduplicate canonical items. Effort `medium`; risk `low`; blast `shared-tool`; maintenance `low`; performance `neutral`; elegance `improves`; structure `improves`.
  - **Option B:** rely on `rglob` and classification after load. Effort `low`; risk `high`; blast `release-gate`; maintenance `high`; performance `neutral`; elegance `neutral`; structure `regresses`.
  - **Option C:** reject all symlinks including safe repo/root aliases. Effort `low`; risk `medium`; blast `cross-project`; maintenance `low`; performance `neutral`; elegance `regresses`; structure `regresses`.
  - **Resolution:** Option A is frozen in `D-12`, `DOD-06/DOD-10`, and separate leaf/directory fixtures.
- **Issue `PR-10` — exact machine-readable behavior was named but not specified (`high`).**
  - **Evidence / why now:** R2 found no literal violation catalog, no nullable-path rule, no count/result rule for root or mixed discovery failures, and no deterministic exit-1 fixture.
  - **Option A (chosen):** freeze literal codes, a stable always-present nullable `todo_path`, envelope/count invariants, text representation, mixed-result behavior, and JSON-output-directory runtime fixture. Effort `medium`; risk `low`; blast `public CLI`; maintenance `medium`; performance `neutral`; elegance `improves`; structure `improves`.
  - **Option B:** let tests adopt implementation-selected strings. Effort `low`; risk `high`; blast `consumer`; maintenance `high`; performance `neutral`; elegance `neutral`; structure `regresses`.
  - **Option C:** remove exact/schema claims. Effort `low`; risk `high`; blast `release-gate`; maintenance `medium`; performance `neutral`; elegance `regresses`; structure `regresses`.
  - **Resolution:** Option A is frozen in Boundary Violation and Result Schema and atomic `DOD-05` through `DOD-16` rows.
- **Issue `PR-11` — compatibility evidence and finding resolution were not machine-checkable 1:1 (`medium`).**
  - **Evidence / why now:** R2 found grouped `DOD-09`, no named runtime failure fixture, and no canonical critique resolution ledger extractable by tooling.
  - **Option A (chosen):** split disposition, advisory/exits, JSON, Git, non-mutation, discovery rendering, LF, and help into separate DOD/matrix rows; add the canonical resolution ledger under the critique gate. Effort `medium`; risk `low`; blast `governance/test`; maintenance `medium`; performance `neutral`; elegance `improves`; structure `improves`.
  - **Option B:** keep one grouped row and prose ledger. Effort `low`; risk `medium`; blast `audit`; maintenance `high`; performance `neutral`; elegance `neutral`; structure `regresses`.
  - **Option C:** waive machine extraction. Effort `none`; risk `high`; blast `approval-gate`; maintenance `high`; performance `neutral`; elegance `regresses`; structure `invalid`.
  - **Resolution:** Option A is integrated in `DOD-11` through `DOD-18`, the completion matrix, and the canonical critique Resolution ledger.
- **Issue `PR-12` — canonical tool manifest was omitted from the material-change boundary (`high`).**
  - **Evidence / why now:** R3 architecture review matched this material guard change to `main_instructions.md` Tool Inventory Discipline, which mandates a same-change `tools/manifest.md` update.
  - **Option A (chosen):** add `tools/manifest.md` to scope, boundary, diff, touched surfaces, handoff, DOD, and validation evidence. Effort `low`; risk `low`; blast `tooling-doc`; maintenance `low`; performance `neutral`; elegance `improves`; structure `improves`.
  - **Option B:** claim the existing one-line description remains sufficient. Effort `none`; risk `high`; blast `governance`; maintenance `medium`; performance `neutral`; elegance `neutral`; structure `invalid`.
  - **Option C:** change the manifest in implementation without declaring it. Effort `low`; risk `high`; blast `diff-gate`; maintenance `high`; performance `neutral`; elegance `regresses`; structure `invalid`.
  - **Resolution:** Option A is frozen in Contract Boundary, Scope, Expected Changed Paths, Touched Surfaces, `DOD-21`, and handoff routing.
- **Issue `PR-13` — active-directory escape precedence lacked explicit-mode proof (`high`).**
  - **Evidence / why now:** R3 found only all-active coverage; explicit mode could emit the leaf escape code instead of the authority active-directory code even with a shared resolver claim.
  - **Option A (chosen):** separate explicit and all-active active-directory escape fixtures; both require `CLOSEOUT-AUTHORITY-ACTIVE-ESCAPE`, candidate active path, count `0`, results `[]`, and exit `2`. Effort `low`; risk `low`; blast `shared-tool`; maintenance `low`; performance `neutral`; elegance `improves`; structure `improves`.
  - **Option B:** accept either authority or leaf code. Effort `low`; risk `medium`; blast `machine-contract`; maintenance `high`; performance `neutral`; elegance `neutral`; structure `regresses`.
  - **Option C:** cover only all-active. Effort `none`; risk `high`; blast `explicit-mode`; maintenance `medium`; performance `neutral`; elegance `regresses`; structure `regresses`.
  - **Resolution:** Option A is frozen in the schema plus distinct `DOD-10` and `DOD-20` rows.
- **Issue `PR-14` — RED and decision traceability were internally contradictory (`high`).**
  - **Evidence / why now:** R3 showed preservation cases were incorrectly required to fail, baseline IDs duplicated resolved decision IDs, D-11/D-12 lacked adherence rows, and PR-05/PR-06 referenced stale DOD numbers.
  - **Option A (chosen):** split behavior-changing RED from baseline GREEN characterization; keep D-01..D-12 as the only decision-ID baseline with full adherence; repair every stale DOD reference. Effort `low`; risk `low`; blast `test/governance`; maintenance `low`; performance `neutral`; elegance `improves`; structure `improves`.
  - **Option B:** keep all scenarios as RED and interpret failures loosely. Effort `none`; risk `high`; blast `test-evidence`; maintenance `high`; performance `neutral`; elegance `regresses`; structure `invalid`.
  - **Option C:** drop decision adherence rows. Effort `low`; risk `high`; blast `closeout`; maintenance `medium`; performance `neutral`; elegance `regresses`; structure `invalid`.
  - **Resolution:** Option A is integrated in Bug-Fix Evidence Gate, Test Strategy, the single D-01..D-12 Decision Baseline, complete Decision Adherence Validation, and corrected PR-05/PR-06 references.
- **Issue `PR-15` — current-round review status could false-pass before the reviewer completed (`high`).**
  - **Evidence / why now:** R4 critique observed `findings_integrated` is a satisfying authority-guard state even while a newer mandatory round was still pending.
  - **Option A (chosen):** retain historical ledgers but set the canonical architecture-decision and critique statuses to `running` during a dispatched fresh round; use `findings_integrated` or `no_material_findings` only after that exact round converges. Effort `low`; risk `low`; blast `approval-gate`; maintenance `low`; performance `neutral`; elegance `improves`; structure `improves`.
  - **Option B:** add a separate prose pending field. Effort `low`; risk `high`; blast `approval-gate`; maintenance `medium`; performance `neutral`; elegance `neutral`; structure `regresses`.
  - **Option C:** leave a satisfying status during review. Effort `none`; risk `high`; blast `approval-gate`; maintenance `high`; performance `neutral`; elegance `regresses`; structure `invalid`.
  - **Resolution:** Option A governs the R5 dispatch; canonical statuses remain `running` until both R5 reviewers finish and their findings are adjudicated.
- **Issue `PR-16` — test-first evidence still mixed harness migration and observationally-green aliases into RED (`high`).**
  - **Evidence / why now:** CRLF must be normalized before logical fixtures execute, and current nested-only discovery can accidentally return count one for equivalent root aliases without proving deduplication.
  - **Option A (chosen):** use three evidence classes: harness precondition (CRLF→LF), pre/post characterization GREEN (including repo/root aliases and compatibility), and behavior-changing RED (including equivalent file aliases and all actually changing outcomes). Effort `low`; risk `low`; blast `tests`; maintenance `low`; performance `neutral`; elegance `improves`; structure `improves`.
  - **Option B:** keep mixed batches with per-case notes. Effort `low`; risk `medium`; blast `tests`; maintenance `medium`; performance `neutral`; elegance `neutral`; structure `neutral`.
  - **Option C:** require accidental-green cases to fail. Effort `medium`; risk `high`; blast `test-evidence`; maintenance `high`; performance `neutral`; elegance `regresses`; structure `invalid`.
  - **Resolution:** Option A is frozen in Bug-Fix Evidence Gate, ordered steps, Test Strategy, and `D-09`.
- **Issue `PR-17` — active work state claimed review before local implementation (`medium`).**
  - **Evidence / why now:** the canonical template reserves `review` for materially complete local implementation; this TODO remains Pending and implementation has not started.
  - **Option A (chosen):** use `implementation` while planning/implementation/test evidence is still changing; transition to `review` only after local implementation and validation are materially complete. Effort `minimal`; risk `low`; blast `status`; maintenance `low`; performance `neutral`; elegance `improves`; structure `improves`.
  - **Option B:** add a new planning state. Effort `high`; risk `high`; blast `workflow`; maintenance `high`; performance `neutral`; elegance `regresses`; structure `out-of-scope`.
  - **Option C:** keep `review`. Effort `none`; risk `medium`; blast `status`; maintenance `medium`; performance `neutral`; elegance `regresses`; structure `regresses`.
  - **Resolution:** Option A is applied in Active Work State with an exact transition condition.
- **Issue `PR-18` — module snapshot and adherence tables used divergent identities/enums (`high`).**
  - **Evidence / why now:** R5 critique found the snapshot's four exact references were not reproduced by Module Decision Consistency Validation, and `Preserve + Clarify` was outside the declared handling enum.
  - **Option A (chosen):** use the exact same four references and canonical handling values in both tables; keep clarifications in evidence/notes. Effort `low`; risk `low`; blast `governance`; maintenance `low`; performance `neutral`; elegance `improves`; structure `improves`.
  - **Option B:** add a mapping between two naming systems. Effort `medium`; risk `medium`; blast `governance`; maintenance `high`; performance `neutral`; elegance `regresses`; structure `regresses`.
  - **Option C:** leave approximate semantic correspondence. Effort `none`; risk `high`; blast `closeout`; maintenance `high`; performance `neutral`; elegance `regresses`; structure `invalid`.
  - **Resolution:** Option A is integrated; snapshot and validation now match 4/4 by exact reference and handling value.
- **Issue `PR-19` — evidence-only freeze update left operational actions stale (`medium`).**
  - **Evidence / why now:** both R5 reviewers found next-step, drift, and closeout text still instructed publication of the already-published R5 baseline.
  - **Option A (chosen):** after each material baseline is actually published, use the evidence-only commit to point all three fields to current review convergence followed by coherence, drift, and authority preflight. Effort `minimal`; risk `low`; blast `status`; maintenance `low`; performance `neutral`; elegance `improves`; structure `improves`.
  - **Option B:** keep publication language until review ends. Effort `none`; risk `medium`; blast `operator`; maintenance `medium`; performance `neutral`; elegance `regresses`; structure `regresses`.
  - **Option C:** remove exact next actions. Effort `low`; risk `high`; blast `workflow`; maintenance `low`; performance `neutral`; elegance `regresses`; structure `invalid`.
  - **Resolution:** Option A governs the R6 freeze evidence update; the published state will point to R6 convergence, never to redundant publication.

### Failure Modes & Edge Cases

- [x] Both candidate roots resolve to the same symlink target: deduplicate and scan once.
- [x] Both candidate roots resolve to distinct authorities: typed ambiguous-authority no-go.
- [x] A candidate `todos/` exists without `active/`: typed unsupported/missing-active no-go.
- [x] A supported `active/` exists but is empty: valid `go`, count zero.
- [x] No supported root exists: typed missing-authority no-go.
- [x] Explicit TODO is outside supported roots despite a misleading suffix: exact outside-authority no-go.
- [x] Explicit leaf symlink escapes authority: exact outside-authority no-go.
- [x] Discovered leaf symlink escapes authority: exclude from results and emit exact outside-authority no-go.
- [x] `active/` directory symlink escapes authority: reject authority with exact active-escape no-go.
- [x] Explicit TODO path is missing, a directory, or not Markdown: typed no-go, no traceback.
- [x] Explicit path is under unknown/direct/deeper-lure lifecycle: exact unrecognized-lifecycle no-go.
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
| `PR-R1-01..07` | plan critique R1 | freeze/schema, semantic, CRLF, RED, exit/JSON, and diff inconsistencies resolved by `PR-01` through `PR-07` | integrated; R2 completed |
| `ARQ-R2-01..03` | architecture R2 | lifecycle false-go, atomic evidence, and literal machine schema resolved by `PR-08`, `PR-10`, `PR-11` | integrated; R3 completed |
| `PR-R2-01..05` | plan critique R2 | literal schema, internal lifecycle, discovery escape, canonical ledger, and operational state resolved in schema/DOD/ledger/status | integrated; R3 completed |
| `ARQ-R3-01..03` | architecture R3 | manifest discipline, explicit active escape, and D-11/D-12 adherence resolved by `PR-12` through `PR-14` | integrated; R4 completed |
| `CRIT-R3-01..03` | plan critique R3 | RED/GREEN split, decision namespaces/adherence/stale refs, and operational state resolved by `PR-14` and status refresh | integrated; R4 completed |
| `ARQ-R4-01` | architecture R4 | operational freeze/drift/next-step state refreshed toward R5 convergence | integrated; R5 completed |
| `CRIT-R4-01..04` | plan critique R4 | current-round gate safety, single decision baseline/module row, three-class tests, and work state resolved by `PR-15` through `PR-17` | integrated; R5 completed |
| `ARQ-R5-01` | architecture R5 | operational next-step/drift/closeout update made part of the post-publish evidence procedure | integrated; fresh R6 required |
| `CRIT-R5-01..02` | plan critique R5 | exact 4/4 module identity/handling and operational state resolved by `PR-18/PR-19` | integrated; fresh R6 required |

## Audit Trigger Matrix

- **Canonical method:** `wf-docker-audit-escalation-method`
- **Guard command:** `python3 tools/audit_escalation_guard.py --todo foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md`
- **Latest TEACH evidence / artifact:** `audit_escalation_guard.py: Overall outcome go; fingerprint abcf5a62880d; critique, test-quality, final review, verification debt, architecture decision/adherence and additive triple review required; performance/concurrency recommended; formal security review not needed`.

| Trigger | Value | Notes |
| --- | --- | --- |
| `complexity` | `medium` | localized shared guard |
| `blast_radius` | `cross-stack` | shared guard serves downstream Foundations across stacks |
| `behavioral_change_or_bugfix` | `yes` | false-positive fix |
| `changes_public_contract` | `yes` | valid CLI arguments remain stable, but invalid/ambiguous boundary behavior and machine-readable violations intentionally become fail-closed and are frozen above |
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
- **Internal reviewer mandate:** `required after each material baseline refresh; R1-R5 findings were integrated, so a fresh R6 reviewer is required before APROVADO`.
- **Critique lenses:** `correctness|performance|elegance|structural-soundness|risk`.
- **Critique status:** `running`
- **Findings summary:** `R1 through R5 returned NO-GO; all material issue families are integrated as PR-01..PR-19; fresh R6 is pending and the canonical status intentionally remains non-satisfying`.
- **Resolution ledger:**

| Finding ID | Resolution (`Integrated|Challenged|Deferred`) | Usefulness (`useful|noise|mixed|unknown`) | Formalizable (`yes|partial|no|unknown`) | Candidate Rule Level (`paced|project|none|unknown`) | Candidate Rule ID | Rationale / Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| `ARQ-R1-01` | `Integrated` | `useful` | `yes` | `none` | `n/a` | Separate repo-symlink, root-alias, and file-alias fixtures now require exact one-result deduplication. |
| `ARQ-R1-02` | `Integrated` | `useful` | `yes` | `none` | `n/a` | Supported root requires `active/`; missing, incomplete, empty, equivalent, and distinct states are frozen. |
| `ARQ-R1-03` | `Integrated` | `useful` | `yes` | `none` | `n/a` | CWD-relative semantics and misleading outside-suffix rejection are explicit. |
| `ARQ-R1-04` | `Integrated` | `useful` | `partial` | `none` | `n/a` | Derived audit package is consistent across boundary, diff, and touched surfaces. |
| `CRIT-R1-01` | `Integrated` | `useful` | `partial` | `none` | `n/a` | Canonical freeze/schema and review state were repaired before the refreshed baseline. |
| `CRIT-R1-02` | `Integrated` | `useful` | `yes` | `none` | `n/a` | Authority/root/symlink/input/exit semantics and desired-behavior RED fixtures were made explicit. |
| `CRIT-R1-03` | `Integrated` | `useful` | `yes` | `none` | `n/a` | CRLF harness normalization and direct Linux/WSL execution became explicit DOD evidence. |
| `ARQ-R2-01` | `Integrated` | `useful` | `yes` | `none` | `n/a` | Lifecycle is exactly the first relative component; unknown/direct/lure paths fail closed. |
| `ARQ-R2-02` | `Integrated` | `useful` | `yes` | `none` | `n/a` | Compatibility evidence was split into atomic DOD and matrix rows with named fixtures. |
| `ARQ-R2-03` | `Integrated` | `useful` | `yes` | `none` | `n/a` | Literal violation codes and stable result/nullable-path invariants are frozen. |
| `CRIT-R2-01` | `Integrated` | `useful` | `yes` | `none` | `n/a` | Machine-readable schema plus deterministic runtime exit-1 evidence is explicit. |
| `CRIT-R2-02` | `Integrated` | `useful` | `yes` | `none` | `n/a` | Internal unrecognized lifecycle false-go is covered in both layouts. |
| `CRIT-R2-03` | `Integrated` | `useful` | `yes` | `none` | `n/a` | All-active leaf and active-directory escape receive separate containment fixtures and exact codes. |
| `CRIT-R2-04` | `Integrated` | `useful` | `yes` | `none` | `n/a` | This canonical ledger is machine-extractable under the critique gate. |
| `CRIT-R2-05` | `Integrated` | `useful` | `partial` | `none` | `n/a` | Operational next-step/freeze text now points to R3 baseline and convergence. |
| `ARQ-R3-01` | `Integrated` | `useful` | `yes` | `paced` | `main_instructions.md#tool-inventory-discipline` | Material canonical tool changes now include same-change `tools/manifest.md` synchronization. |
| `ARQ-R3-02` | `Integrated` | `useful` | `yes` | `none` | `n/a` | Explicit and all-active active-directory escape fixtures independently prove authority-code precedence. |
| `ARQ-R3-03` | `Integrated` | `useful` | `yes` | `none` | `n/a` | Decision Adherence Validation now covers D-01 through D-12. |
| `CRIT-R3-01` | `Integrated` | `useful` | `yes` | `none` | `n/a` | Behavior-changing RED is separated from pre/post GREEN characterization and preservation. |
| `CRIT-R3-02` | `Integrated` | `useful` | `yes` | `none` | `n/a` | Decision identity, stale DOD references, and missing adherence rows were corrected; R4 further consolidated the single D-01..D-12 baseline. |
| `CRIT-R3-03` | `Integrated` | `useful` | `partial` | `none` | `n/a` | Operational status points to the required R4 refresh/convergence. |
| `ARQ-R4-01` | `Integrated` | `useful` | `partial` | `none` | `n/a` | Operational next-step, drift, and closeout text now point to R5 convergence after the material R4 corrections. |
| `CRIT-R4-01` | `Integrated` | `useful` | `yes` | `none` | `n/a` | Canonical current-round review statuses stay `running` until the dispatched reviewers actually converge. |
| `CRIT-R4-02` | `Integrated` | `useful` | `yes` | `none` | `n/a` | D-01..D-12 is the only decision baseline and the module exit contract has a consistency row. |
| `CRIT-R4-03` | `Integrated` | `useful` | `yes` | `none` | `n/a` | Harness precondition, behavior RED, and characterization GREEN are distinct evidence classes. |
| `CRIT-R4-04` | `Integrated` | `useful` | `yes` | `none` | `n/a` | Active Work State is implementation until local implementation is materially complete. |
| `ARQ-R5-01` | `Integrated` | `useful` | `partial` | `none` | `n/a` | Post-publish evidence updates now point to current review convergence and subsequent guards. |
| `CRIT-R5-01` | `Integrated` | `useful` | `yes` | `none` | `n/a` | Module snapshot and consistency validation use the same four exact references and canonical handling values. |
| `CRIT-R5-02` | `Integrated` | `useful` | `partial` | `none` | `n/a` | Next-step, drift, and closeout status are updated together after publication. |
- **Evidence / reference:** `R1-R5 no-context architecture and critique outputs; PR-01..PR-19; canonical ledger extraction must pass before R6`.
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
| `D-10` | pending | pending implementation | no instruction/workflow/template change; manifest sync only |
| `D-11` | pending | pending implementation | exact first-component lifecycle classification |
| `D-12` | pending | pending implementation | active-directory and discovered-item containment |

## Module Decision Consistency Validation

| Module Decision Ref | Planned Handling | Delivery Status | Evidence | Notes |
| --- | --- | --- | --- | --- |
| `todo-closeout-promotion-method#active-todo-scan` | Preserve | pending | pending | workflow contract remains generic across nested and standalone authority layouts |
| `todo_closeout_guard.py#path-state` | Supersede (Intentional) | pending | pending | replace absolute segment matching with resolved-root-relative lifecycle classification |
| `todo_closeout_guard.py#all-active` | Supersede (Intentional) | pending | pending | replace nested-only empty-success discovery with the frozen fail-closed resolver |
| `todo_closeout_guard.py#exit-contract` | Preserve | pending | pending | preserve process exits while clarifying structured boundary codes and advisory behavior |

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
- **Next path/status action:** converge the running R6 reviews, execute coherence/drift/authority preflight, obtain APROVADO, implement, validate, and move to the exact completed path.

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
