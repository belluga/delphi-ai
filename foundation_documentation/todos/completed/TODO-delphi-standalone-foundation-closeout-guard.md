# TODO — Support standalone Foundation repositories in the closeout guard

## Artifact Identity

- **Artifact type:** `tactical_execution_contract`
- **Lifecycle state:** `Completed`
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

- **Current delivery stage:** `Lane-Promoted`
- **Qualifiers:** `none`
- **Next exact step:** `none — delivery and closeout completed on origin/feat/add-stack-capabilities`.

## Active Work State

- **Work state:** `review`
- **Why this state now:** implementation and primary local validation are materially complete; independent delivery reviews and closeout guards remain.
- **Exit condition:** all required audits/reviews and deterministic delivery guards pass, the branch is published, and the TODO moves to its exact completed path.

## Scope

- [x] Add a generic authority-root resolver that recognizes `<repo>/foundation_documentation/todos` and `<repo>/todos` without project-specific names.
- [x] Classify explicit TODO paths relative to the resolved authority root instead of matching hard-coded absolute path parts after `resolve()`.
- [x] Recognize lifecycle only from the first relative component below the authority root (`active`, `promotion_lane`, or `completed`); reject every other explicit in-authority state, including deeper `active` lure segments.
- [x] Discover active TODOs in either supported topology, deduplicate equivalent resolved roots/paths, and reject simultaneous distinct authorities as ambiguous.
- [x] Fail closed when an explicit TODO is outside every supported authority root.
- [x] Fail closed when `--all-active` cannot find exactly one supported TODO authority root; distinguish no root, a candidate `todos/` without `active/`, an ambiguous pair of distinct roots, and a valid empty `active/` directory.
- [x] Validate explicit inputs before reading: an existing regular Markdown file is required; missing paths, directories, and non-Markdown files fail closed without traceback.
- [x] Canonicalize and containment-check every selected lifecycle directory plus every explicit/discovered TODO; reject lifecycle-directory symlinks and leaf symlinks that escape the resolved authority, and deduplicate equivalent discovered aliases.
- [x] Treat each recognized lifecycle directory as its own containment boundary: reject symlink directories for `active`, `promotion_lane`, and `completed` even when their targets remain in authority, and reject explicit/discovered file aliases whose resolved target crosses from their lexical lifecycle into another lifecycle.
- [x] Preserve relative explicit-path semantics anchored to the process current working directory and define `--repo` as the repository/container whose two immediate authority candidates and Git context are inspected.
- [x] Add RED/GREEN regression fixtures for nested, standalone, relative-path, root-symlink, equivalent-root/path deduplication, escaping leaf symlink, unrecognized-path, invalid explicit input, missing/ambiguous root, exact exit codes, JSON shape, and real active-count behavior.
- [x] Preserve existing disposition parsing, git-state handling, JSON output, advisory exit behavior, and non-mutating semantics.
- [x] Update the guard docstring/help text inside the same source file so both supported layouts and boundary outcomes are accurately advertised.
- [x] Update `tools/manifest.md` in the same change so the canonical inventory describes dual-layout authority resolution and fail-closed boundary validation.

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
| standalone closeout guard support | `feat/add-stack-capabilities@6dc5bd4` | `origin/feat/add-stack-capabilities@6dc5bd4` | n/a | release-package-owned | Lane-Promoted; delivery commit published and closeout evidence recorded |

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
| `delphi-ai` | `artifacts/analysis/standalone-foundation-closeout-guard-delivery-package.md` | `any` | bounded derived audit package; `any` admits its expected untracked pre-commit state and later tracked updates |
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
| Python source CRLF→LF normalization | necessary/justifiable need | newly added CRLF lines were rejected by required `git diff --check`; same approved path, no behavior/scope expansion; functional review uses `--ignore-space-at-eol` | retain | no renewed approval required because contract, path set, CLI, and behavior are unchanged |
| Derived package reports `??` before first commit | necessary/justifiable need | the package is an approved expected path and must exist before delivery reviews; change type now uses `any` so pre-commit and tracked review updates are both admitted | retain | no path/scope expansion and no renewed approval required |

## Bounded But Elastic Guardrails

- **May stay inside this TODO:** local helper extraction inside the guard and fixture refactors required for the same topology contract.
- **Must update or split the TODO:** CLI redesign, new policy semantics, automatic mutations, changes outside the six expected paths, or support for an additional unrelated repository layout.

## Definition of Done

- [x] `DOD-01` An explicit active TODO under standalone `<repo>/todos/active/**` reports `path_state=active` and is actually validated.
- [x] `DOD-02` `--all-active --repo <standalone>` discovers the real active TODO count and validates each file.
- [x] `DOD-03` Existing nested `<repo>/foundation_documentation/todos/**` behavior remains green.
- [x] `DOD-04` A symlink used as `--repo` resolves to the standalone repository, and two candidate roots or file aliases resolving to the same authority/TODO produce exactly one scan and one `todo_result`.
- [x] `DOD-05` Explicit outside paths, misleading suffixes, and escaping leaf symlinks emit `CLOSEOUT-TODO-OUTSIDE-AUTHORITY`, exit `2`, and no TODO result.
- [x] `DOD-06` Root-state semantics emit the exact schema codes: missing root, incomplete root, ambiguous distinct roots in both explicit/all-active modes, and valid empty active behavior.
- [x] `DOD-07` Explicit missing paths, directories, and non-Markdown files emit their exact catalog codes at exit `2` without traceback; argparse misuse remains exit `2`.
- [x] `DOD-08` Relative explicit TODO arguments remain anchored to the process current working directory and work from both nested and standalone repository roots.
- [x] `DOD-09` Explicit in-authority lifecycle classification uses only the first relative component; unknown/direct-root/deeper-lure cases emit `CLOSEOUT-TODO-LIFECYCLE-UNRECOGNIZED` in nested and standalone fixtures.
- [x] `DOD-10` All-active discovery containment is enforced separately: a leaf symlink escape is excluded with `CLOSEOUT-TODO-OUTSIDE-AUTHORITY`; an `active/` directory escape emits `CLOSEOUT-LIFECYCLE-DIRECTORY-ESCAPE`; equivalent discovered aliases deduplicate.
- [x] `DOD-11` Existing disposition parsing scenarios retain direct assertions.
- [x] `DOD-12` Advisory mode preserves the no-go envelope and returns exit `0`; normal governance no-go returns `2`; deterministic JSON-output write failure returns runtime/tool exit `1`.
- [x] `DOD-13` JSON output satisfies every Boundary Violation and Result Schema invariant, including `todo_count == len(todo_results)`, stable nullable `todo_path`, and mixed discovery results.
- [x] `DOD-14` Git metadata is taken from the resolved `--repo` Git worktree and asserted in a temporary committed repository.
- [x] `DOD-15` A before/after filesystem snapshot proves the guard is non-mutating except for an explicitly requested JSON output file.
- [x] `DOD-16` Root-level discovery violations render in text and JSON without a synthetic `todo_result`; text prints `todo_path: n/a` and JSON stores `null`.
- [x] `DOD-17` The shell harness is normalized to LF and executes directly in the declared Linux/WSL lane.
- [x] `DOD-18` The guard docstring/help advertises both authority layouts without a nested-only claim.
- [x] `DOD-19` No downstream project name/path/business concept is persisted in Delphi surfaces.
- [x] `DOD-20` Explicit mode under any recognized lifecycle directory that resolves outside authority emits `CLOSEOUT-LIFECYCLE-DIRECTORY-ESCAPE` (not the leaf outside code), with the candidate lifecycle path, count `0`, results `[]`, and exit `2`.
- [x] `DOD-21` `tools/manifest.md` describes the guard's dual-layout resolution and fail-closed authority/input behavior in the same change.
- [x] `DOD-22` Explicit file aliases crossing in every direction among lexical `active/`, `promotion_lane/`, and `completed/` emit `CLOSEOUT-TODO-LIFECYCLE-ESCAPE`; all-active covers active-origin aliases; same-lifecycle aliases remain eligible and deduplicated.
- [x] `DOD-23` A directory symlink for any recognized lifecycle targeting another lifecycle inside the same authority emits `CLOSEOUT-LIFECYCLE-DIRECTORY-SYMLINK` in explicit mode; all-active separately covers `active/`; every case reports the candidate path, count `0`, results `[]`, and exit `2`.

## Validation Steps

- [x] `VAL-01` Run `python3 -m py_compile tools/todo_closeout_guard.py`.
- [x] `VAL-02` Run `bash tools/tests/todo_closeout_guard_test.sh` directly from the Linux/WSL checkout and require direct assertions for every DOD topology and exact exit contract.
- [x] `VAL-03` Run `bash self_check.sh`.
- [x] `VAL-04` Run `python3 tools/todo_diff_expectation_guard.py foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md --repo-root .`.
- [x] `VAL-05` Run `python3 tools/todo_authority_guard.py foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md --require-delivery-gates`.
- [x] `VAL-06` Run `python3 tools/todo_completion_guard.py foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md`.
- [x] `VAL-07` Inspect `git diff --check 9ba43e8bba3618d029320bf6d7b40415881a0287 --` and `git diff --name-status --find-renames 9ba43e8bba3618d029320bf6d7b40415881a0287 --`.

## Completion Evidence Matrix

| Criterion ID | Source Section | Criterion | Evidence Type | Evidence Artifact / Command | Runtime Target | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `SCOPE-01` | Scope | Add a generic authority-root resolver that recognizes `<repo>/foundation_documentation/todos` and `<repo>/todos` without project-specific names. | source+CLI test | `tools/todo_closeout_guard.py:117-178`; dual-layout fixture suite | local CLI | passed | one shared generic resolver; both layouts pass |
| `SCOPE-02` | Scope | Classify explicit TODO paths relative to the resolved authority root instead of matching hard-coded absolute path parts after `resolve()`. | source+negative test | `tools/todo_closeout_guard.py:196-239`; misleading-suffix fixtures | local CLI | passed | authority-relative classification and outside rejection pass |
| `SCOPE-03` | Scope | Recognize lifecycle only from the first relative component below the authority root (`active`, `promotion_lane`, or `completed`); reject every other explicit in-authority state, including deeper `active` lure segments. | contract test | direct-root, unknown, and deeper-lure fixtures | local CLI | passed | exact unrecognized code and exit `2` asserted |
| `SCOPE-04` | Scope | Discover active TODOs in either supported topology, deduplicate equivalent resolved roots/paths, and reject simultaneous distinct authorities as ambiguous. | integration test | nested/standalone, alias-dedup, and ambiguous-root fixtures | local CLI | passed | exact counts and typed ambiguity asserted |
| `SCOPE-05` | Scope | Fail closed when an explicit TODO is outside every supported authority root. | negative test | outside-suffix, traversal, and leaf-escape fixtures | local CLI | passed | exact outside-authority code, zero results, exit `2` |
| `SCOPE-06` | Scope | Fail closed when `--all-active` cannot find exactly one supported TODO authority root; distinguish no root, a candidate `todos/` without `active/`, an ambiguous pair of distinct roots, and a valid empty `active/` directory. | negative+positive tests | root-state parity fixture matrix | local CLI | passed | missing/incomplete/ambiguous are typed no-go; empty active is go |
| `SCOPE-07` | Scope | Validate explicit inputs before reading: an existing regular Markdown file is required; missing paths, directories, and non-Markdown files fail closed without traceback. | negative test | explicit input catalog plus FIFO/socket fixtures | local CLI | passed | exact codes/exits and no traceback asserted |
| `SCOPE-08` | Scope | Canonicalize and containment-check every selected lifecycle directory plus every explicit/discovered TODO; reject lifecycle-directory symlinks and leaf symlinks that escape the resolved authority, and deduplicate equivalent discovered aliases. | security boundary test | lifecycle/leaf escape and alias-dedup fixtures | local CLI | passed | fail-closed containment and canonical uniqueness asserted |
| `SCOPE-09` | Scope | Treat each recognized lifecycle directory as its own containment boundary: reject symlink directories for `active`, `promotion_lane`, and `completed` even when their targets remain in authority, and reject explicit/discovered file aliases whose resolved target crosses from their lexical lifecycle into another lifecycle. | contract test | all directed lifecycle directory/file alias fixtures | local CLI | passed | symmetric lifecycle-local containment asserted |
| `SCOPE-10` | Scope | Preserve relative explicit-path semantics anchored to the process current working directory and define `--repo` as the repository/container whose two immediate authority candidates and Git context are inspected. | compatibility test | nested/standalone CWD and symlinked Git repository fixtures | local CLI | passed | process-relative path and resolved Git context retained |
| `SCOPE-11` | Scope | Add RED/GREEN regression fixtures for nested, standalone, relative-path, root-symlink, equivalent-root/path deduplication, escaping leaf symlink, unrecognized-path, invalid explicit input, missing/ambiguous root, exact exit codes, JSON shape, and real active-count behavior. | test-first evidence | fail-first record plus `bash tools/tests/todo_closeout_guard_test.sh` | local CLI | passed | desired standalone RED captured; full GREEN matrix passes |
| `SCOPE-12` | Scope | Preserve existing disposition parsing, git-state handling, JSON output, advisory exit behavior, and non-mutating semantics. | regression+snapshot tests | retained disposition/Git/JSON/advisory and filesystem digest fixtures | local CLI | passed | original contracts and read-only behavior pass |
| `SCOPE-13` | Scope | Update the guard docstring/help text inside the same source file so both supported layouts and boundary outcomes are accurately advertised. | CLI documentation test | docstring review plus `--help` fixture assertions | local CLI | passed | both layouts and fail-closed boundary advertised |
| `SCOPE-14` | Scope | Update `tools/manifest.md` in the same change so the canonical inventory describes dual-layout authority resolution and fail-closed boundary validation. | inventory review | `tools/manifest.md:86` plus self-check | local docs | passed | canonical inventory synchronized |
| `DOD-01` | Definition of Done | `DOD-01` An explicit active TODO under standalone `<repo>/todos/active/**` reports `path_state=active` and is actually validated. | test | standalone explicit fixture | local CLI | passed | path state and disposition validation asserted |
| `DOD-02` | Definition of Done | `DOD-02` `--all-active --repo <standalone>` discovers the real active TODO count and validates each file. | test | standalone all-active JSON fixture | local CLI | passed | two discovered TODOs loaded and invalid result surfaced |
| `DOD-03` | Definition of Done | `DOD-03` Existing nested `<repo>/foundation_documentation/todos/**` behavior remains green. | regression | retained original nested fixture matrix | local CLI | passed | all original scenarios pass |
| `DOD-04` | Definition of Done | `DOD-04` A symlink used as `--repo` resolves to the standalone repository, and two candidate roots or file aliases resolving to the same authority/TODO produce exactly one scan and one `todo_result`. | test | repo symlink plus equivalent root/file fixtures | local CLI | passed | canonical Git root and one result asserted |
| `DOD-05` | Definition of Done | `DOD-05` Explicit outside paths, misleading suffixes, and escaping leaf symlinks emit `CLOSEOUT-TODO-OUTSIDE-AUTHORITY`, exit `2`, and no TODO result. | negative test | outside-suffix, traversal, and leaf-alias fixtures | local CLI | passed | exact code, zero results, exit `2` |
| `DOD-06` | Definition of Done | `DOD-06` Root-state semantics emit the exact schema codes: missing root, incomplete root, ambiguous distinct roots in both explicit/all-active modes, and valid empty active behavior. | CLI integration test | root-state schema fixture matrix | local CLI | passed | integration test asserts exact schema codes, nullable paths, counts, and exits |
| `DOD-07` | Definition of Done | `DOD-07` Explicit missing paths, directories, and non-Markdown files emit their exact catalog codes at exit `2` without traceback; argparse misuse remains exit `2`. | negative test | explicit input loop plus exact argparse status | local CLI | passed | exact codes and exit `2` |
| `DOD-08` | Definition of Done | `DOD-08` Relative explicit TODO arguments remain anchored to the process current working directory and work from both nested and standalone repository roots. | regression | nested/standalone CWD fixtures | local CLI | passed | process-relative semantics retained |
| `DOD-09` | Definition of Done | `DOD-09` Explicit in-authority lifecycle classification uses only the first relative component; unknown/direct-root/deeper-lure cases emit `CLOSEOUT-TODO-LIFECYCLE-UNRECOGNIZED` in nested and standalone fixtures. | negative test | nested/standalone direct-root and lure fixtures | local CLI | passed | exact unrecognized code and exit `2` |
| `DOD-10` | Definition of Done | `DOD-10` All-active discovery containment is enforced separately: a leaf symlink escape is excluded with `CLOSEOUT-TODO-OUTSIDE-AUTHORITY`; an `active/` directory escape emits `CLOSEOUT-LIFECYCLE-DIRECTORY-ESCAPE`; equivalent discovered aliases deduplicate. | CLI integration test | mixed-discovery, directory-escape, and alias-dedup fixtures | local CLI | passed | integration test excludes escapes and retains the unique valid result |
| `DOD-11` | Definition of Done | `DOD-11` Existing disposition parsing scenarios retain direct assertions. | regression | retained original disposition scenarios plus punctuation case | local CLI | passed | strict established outcomes directly asserted |
| `DOD-12` | Definition of Done | `DOD-12` Advisory mode preserves the no-go envelope and returns exit `0`; normal governance no-go returns `2`; deterministic JSON-output write failure returns runtime/tool exit `1`. | regression+negative test | captured advisory/governance/runtime statuses | local CLI | passed | exact `0`, `2`, and `1` asserted |
| `DOD-13` | Definition of Done | `DOD-13` JSON output satisfies every Boundary Violation and Result Schema invariant, including `todo_count == len(todo_results)`, stable nullable `todo_path`, and mixed discovery results. | CLI integration test | result-schema root-error and mixed-discovery JSON assertions | local CLI | passed | integration test asserts every schema key, nullable path, and count invariant |
| `DOD-14` | Definition of Done | `DOD-14` Git metadata is taken from the resolved `--repo` Git worktree and asserted in a temporary committed repository. | integration test | symlinked temporary committed worktree fixture | local CLI | passed | canonical root and Boolean clean asserted |
| `DOD-15` | Definition of Done | `DOD-15` A before/after filesystem snapshot proves the guard is non-mutating except for an explicitly requested JSON output file. | snapshot test | tree/content/mode/link digest fixture | local CLI | passed | before/after snapshots identical |
| `DOD-16` | Definition of Done | `DOD-16` Root-level discovery violations render in text and JSON without a synthetic `todo_result`; text prints `todo_path: n/a` and JSON stores `null`. | CLI integration test | missing-root text/JSON fixture | local CLI | passed | integration test asserts both renderings and zero results |
| `DOD-17` | Definition of Done | `DOD-17` The shell harness is normalized to LF and executes directly in the declared Linux/WSL lane. | test | `file` inspection plus direct shell execution | local CLI | passed | LF executable reaches final OK marker |
| `DOD-18` | Definition of Done | `DOD-18` The guard docstring/help advertises both authority layouts without a nested-only claim. | test+review | source docstring and `--help` assertions | local CLI | passed | both layouts and generic discovery described |
| `DOD-19` | Definition of Done | `DOD-19` No downstream project name/path/business concept is persisted in Delphi surfaces. | review | bounded functional diff and independent reviews | local files | passed | no downstream concept introduced |
| `DOD-20` | Definition of Done | `DOD-20` Explicit mode under any recognized lifecycle directory that resolves outside authority emits `CLOSEOUT-LIFECYCLE-DIRECTORY-ESCAPE` (not the leaf outside code), with the candidate lifecycle path, count `0`, results `[]`, and exit `2`. | negative contract test | all-lifecycle external-symlink loop | local CLI | passed | directory escape precedence and full envelope asserted |
| `DOD-21` | Definition of Done | `DOD-21` `tools/manifest.md` describes the guard's dual-layout resolution and fail-closed authority/input behavior in the same change. | review+assertion | `tools/manifest.md:86` | local docs | passed | dual-layout fail-closed semantics present |
| `DOD-22` | Definition of Done | `DOD-22` Explicit file aliases crossing in every direction among lexical `active/`, `promotion_lane/`, and `completed/` emit `CLOSEOUT-TODO-LIFECYCLE-ESCAPE`; all-active covers active-origin aliases; same-lifecycle aliases remain eligible and deduplicated. | negative+positive contract tests | directed cross- and safe same-lifecycle fixtures | local CLI | passed | cross rejects; safe aliases classify and deduplicate |
| `DOD-23` | Definition of Done | `DOD-23` A directory symlink for any recognized lifecycle targeting another lifecycle inside the same authority emits `CLOSEOUT-LIFECYCLE-DIRECTORY-SYMLINK` in explicit mode; all-active separately covers `active/`; every case reports the candidate path, count `0`, results `[]`, and exit `2`. | negative contract tests | all-lifecycle inside-symlink loop plus all-active | local CLI | passed | exact code, path, count, results, and exit asserted |
| `VAL-01` | Validation Steps | `VAL-01` Run `python3 -m py_compile tools/todo_closeout_guard.py`. | test | `python3 -m py_compile tools/todo_closeout_guard.py` | local | passed | exit `0` on 2026-09-25 |
| `VAL-02` | Validation Steps | `VAL-02` Run `bash tools/tests/todo_closeout_guard_test.sh` directly from the Linux/WSL checkout and require direct assertions for every DOD topology and exact exit contract. | test | `bash tools/tests/todo_closeout_guard_test.sh` | local CLI | passed | final `todo_closeout_guard_test: OK` marker on 2026-09-25 |
| `VAL-03` | Validation Steps | `VAL-03` Run `bash self_check.sh`. | test | `bash self_check.sh` | local | passed | 243 files; 0 individual failures; 0 coherence failures |
| `VAL-04` | Validation Steps | `VAL-04` Run `python3 tools/todo_diff_expectation_guard.py foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md --repo-root .`. | guard | exact declared command | local | passed | overall `go`; five matched paths; zero forbidden/unclassified |
| `VAL-05` | Validation Steps | `VAL-05` Run `python3 tools/todo_authority_guard.py foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md --require-delivery-gates`. | guard | exact declared command | local | passed | overall `go`; delivery gate rows accepted |
| `VAL-06` | Validation Steps | `VAL-06` Run `python3 tools/todo_completion_guard.py foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md`. | guard | exact declared command | local | passed | parser-ready 44-row matrix; final invocation returned overall `go` |
| `VAL-07` | Validation Steps | `VAL-07` Inspect `git diff --check 9ba43e8bba3618d029320bf6d7b40415881a0287 --` and `git diff --name-status --find-renames 9ba43e8bba3618d029320bf6d7b40415881a0287 --`. | review | exact declared commands | local | passed | diff-check clean; four tracked changes plus the authorized untracked derived package; diff guard confirms five matched paths |

## External Dependency Readiness

| Dependency | Why It Matters | Status | Last Verified | Verification Method | Adjustment / Workaround |
| --- | --- | --- | --- | --- | --- |
| Python 3 standard library | guard runtime | healthy | 2026-09-25 | current guard executes | none |
| Git CLI | optional sync metadata | healthy | 2026-09-25 | current guard reports git context | fixtures must not require network |

## Profile Scope & Handoffs

- **Primary execution profile:** `strategic-cto`
- **Active technical scope:** `delphi-self-maintenance`
- **Expected supporting profiles:** `operational-coder; assurance-tester-quality`
- **Scope-check command:** `python3 tools/profile_scope_check.py --profile strategic-cto tools/todo_closeout_guard.py tools/tests/todo_closeout_guard_test.sh tools/manifest.md artifacts/analysis/standalone-foundation-closeout-guard-delivery-package.md foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md`
- **Scope-check outcome:** `review required`; the TODO is allowed and the tool/test/derived-artifact paths are explicitly routed through the handoffs below.

### Handoff Log

| From Profile | To Profile | Why the Handoff Exists | Touched Surfaces | Status / Evidence |
| --- | --- | --- | --- | --- |
| strategic-cto | operational-coder | minimal deterministic Python implementation | `tools/todo_closeout_guard.py` | completed by one serialized routine executor; compile and full fixture suite green |
| operational-coder | assurance-tester-quality | false-green regression and negative cases | `tools/tests/todo_closeout_guard_test.sh` | completed; full matrix green and fresh independent test-quality R8 returned no material findings |
| assurance-tester-quality | strategic-cto | final agnosticism/contract review, canonical tool-inventory synchronization, and derived packet | bounded diff + `tools/manifest.md` + `artifacts/analysis/**` | completed; final R1 findings remediated and fresh R2 returned GO with no material findings |

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
- [x] `D-12` Every selected recognized lifecycle directory and every explicit/discovered Markdown path are resolved before loading and must remain inside both the resolved authority and the lifecycle selected by the first lexical relative component. Lifecycle directories may never be symlinks; same-lifecycle file aliases remain allowed and deduplicated.

### Boundary Violation and Result Schema

| Condition | Exact violation code | `todo_path` | `todo_count` / `todo_results` |
| --- | --- | --- | --- |
| selected `--repo` cannot be resolved because of a cycle or filesystem error | `CLOSEOUT-REPOSITORY-UNRESOLVABLE` | lexical repository path | `0` / `[]` |
| neither candidate authority exists | `CLOSEOUT-AUTHORITY-MISSING` | `null` | `0` / `[]` |
| candidate `todos/` exists (including a dangling contained symlink) but no candidate has an `active/` directory | `CLOSEOUT-AUTHORITY-INCOMPLETE` | `null` | `0` / `[]` |
| candidate authority root resolves outside the selected repository, including a dangling external symlink | `CLOSEOUT-AUTHORITY-OUTSIDE-REPOSITORY` | lexical candidate-root path | `0` / `[]` |
| two candidate roots resolve to distinct supported authorities | `CLOSEOUT-AUTHORITY-AMBIGUOUS` | `null` | `0` / `[]` in explicit and all-active modes |
| active discovery cannot read an entry or subtree | `CLOSEOUT-DISCOVERY-UNREADABLE` | lexical unreadable entry/subtree path | unreadable subtree contributes no results and forces no-go |
| a selected recognized lifecycle directory resolves outside its resolved authority | `CLOSEOUT-LIFECYCLE-DIRECTORY-ESCAPE` | string path of the lexical lifecycle directory | `0` / `[]`; resolver rejects it before explicit leaf classification or discovery |
| a selected recognized lifecycle directory is a symlink whose resolved target remains inside authority | `CLOSEOUT-LIFECYCLE-DIRECTORY-SYMLINK` | string path of the lexical lifecycle directory | `0` / `[]`; directory aliases are rejected before explicit/discovery work |
| explicit or discovered TODO resolves outside the selected authority | `CLOSEOUT-TODO-OUTSIDE-AUTHORITY` | string path as supplied/discovered | path is excluded from count/results |
| explicit or discovered TODO alias resolves inside authority but outside the lifecycle selected by its first lexical relative component | `CLOSEOUT-TODO-LIFECYCLE-ESCAPE` | string path as supplied/discovered | path is excluded from count/results |
| explicit path does not exist, or discovered contained symlink target is missing/cyclic | `CLOSEOUT-TODO-MISSING` | supplied/discovered path string | `0` / `[]` |
| explicit/discovered path is not a regular file, including directory, FIFO, socket, or a symlink to a non-file | `CLOSEOUT-TODO-NOT-FILE` | supplied/discovered path string | `0` / `[]` |
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
| lifecycle-local containment | `D-11`, `D-12` | explicit paths and all-active discovery | Lexical lifecycle and resolved target lifecycle must agree; cross-lifecycle aliases cannot inherit the wrong closeout semantics. |
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
| authority-only containment | an `active/` alias resolves into `completed/` or `promotion_lane/` but is loaded using lexical active semantics | Lifecycle policy can be bypassed without leaving the authority root. | `none` |

### Architecture Protection Harness

| Harness Type | Surface | Command / Rule / Artifact | Regression It Must Catch | Adoption Timing | Evidence Plan / Follow-up |
| --- | --- | --- | --- | --- | --- |
| test | authority-root resolution | `todo_closeout_guard_test.sh` | standalone classified as other | implement-in-this-todo | RED/GREEN fixture |
| test | all-active discovery | `todo_closeout_guard_test.sh` | zero-count false go | implement-in-this-todo | exact count assertions |
| test | fail closed | `todo_closeout_guard_test.sh` | missing root/outside path returns go | implement-in-this-todo | negative assertions |
| test | lifecycle boundary | `todo_closeout_guard_test.sh` | unknown/direct/deeper-lure in-authority path returns go | implement-in-this-todo | exact first-component fixtures |
| test | discovery containment | `todo_closeout_guard_test.sh` | escaped or cross-lifecycle directory/leaf is loaded or classified under the wrong lifecycle | implement-in-this-todo | separate authority-escape, lifecycle-directory-symlink, leaf-escape, and lifecycle-escape fixtures |
| contract | machine-readable envelope | `Boundary Violation and Result Schema` + JSON fixtures | codes/nullable path/count/results drift or renderer crash | implement-in-this-todo | literal schema assertions |
| test | direct Linux/WSL execution | `bash tools/tests/todo_closeout_guard_test.sh` | CRLF prevents the harness from reaching fixtures | implement-in-this-todo | LF normalization + final OK assertion |

## Architecture Review Gates

- **Architecture decision review:** `required`
- **Decision review lifecycle:** `after diagnosis is closed and before APROVADO`
- **Decision review kind:** `architecture_opinion`
- **Decision review package:** `bounded-file-set`
- **Decision review status:** `no_material_findings`
- **Decision review evidence / resolution:** `Explicitly routed R9 architecture_opinion on origin/feat/add-stack-capabilities@92257fa returned GO with no material findings; performance acceptable and elegance/structural/operational fit strong-positive.`
- **Architecture adherence review:** `required`
- **Adherence review lifecycle:** `after implementation and before Completed`
- **Adherence review kind:** `architecture_adherence`
- **Adherence review package:** `bounded-file-set`
- **Adherence review status:** `no_material_findings`
- **Adherence review evidence / resolution:** `R1-R8 findings were classified and remediated in-scope; fresh R9 returned GO on the final os.walk/TodoSelection package, including unreadable subtree/leaf handling, sibling retention, strict enums, containment, evidence references, and downstream-agnostic scope.`
- **No-go handling:** return to the affected loop; do not request approval or close with unresolved divergence.

## Gate: Review Baseline Freeze

- **Gate decision:** `required`
- **Why this decision:** shared guard behavior needs an immutable review packet.
- **Trigger stage:** `before planning-side reviews`
- **Baseline branch:** `feat/add-stack-capabilities`
- **Baseline commit:** `92257fa8dd8bf8e490a60b96966e43151c43e7c9`
- **Baseline push reference:** `origin/feat/add-stack-capabilities`
- **Gate status:** `no_material_findings`
- **Findings summary:** R1-R8 material findings integrated; explicitly routed R9 architecture and critique returned no material findings against the published material baseline.
- **Evidence / reference:** `origin/feat/add-stack-capabilities@92257fa8dd8bf8e490a60b96966e43151c43e7c9`; R1-R8 architecture and critique ledgers integrated.
- **Waiver authority / reference:** `n/a`

## Gate: Review Scope Drift

- **Gate decision:** `required`
- **Why this decision:** behavior and test scope must remain identical to the reviewed baseline.
- **Trigger stage:** `after planning reviews converge and before APROVADO`
- **Baseline source:** `Gate: Review Baseline Freeze -> Baseline commit`
- **Material sections compared:** `template canonical set`
- **Guard command:** `python3 tools/review_scope_drift_guard.py --todo foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md`
- **Gate status:** `findings_integrated`
- **Findings summary:** `Post-approval same-TODO review remediation changed seven material sections. Human authority renewed approval on 2026-09-25 after explicit disclosure that paths, product boundary, CLI shape, supported layouts, and downstream exclusion remain unchanged; the evolved fail-closed hardening is integrated.`
- **Evidence / reference:** `review_scope_drift_guard: baseline 92257fa8dd8bf8e490a60b96966e43151c43e7c9; 7/22 material sections changed; renewed user APROVADO received 2026-09-25; technical R9/TQ-R8/P1P2-R4/triple-round-05 reviews are green.`
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
5. **Required behavior-changing RED tests:** standalone explicit/all-active (including standalone CWD-relative), equivalent same-lifecycle file-alias deduplication, explicit/discovered authority escape, recognized lifecycle-directory escape/symlink in both lexical directions, cross-lifecycle file aliases in both directions, unknown/direct/deeper-lure lifecycle, missing/directory/non-Markdown explicit input, missing/incomplete/distinct-ambiguous roots, new boundary/result schema and rendering, dual-layout help, and manifest description. Each asserts desired behavior and must fail against current source.
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

1. Record CRLF→LF as a harness precondition migration, capture the named baseline characterization cases as pre-fix GREEN (including repo/root aliases), then add desired behavior-changing tests and capture their failure against current source as RED (including same-lifecycle file dedup, unknown lifecycle, authority escape, cross-lifecycle aliases in both directions, and every recognized lifecycle-directory symlink).
2. Extract one generic supported-root resolver used by explicit classification and all-active discovery. Accept only contained candidates with an `active/` directory, deduplicate resolved aliases, and reject distinct simultaneous authorities.
3. Classify explicit lifecycle by the first lexical component relative to authority; reject directory aliases for every recognized lifecycle; require every resolved file to remain under that lifecycle's resolved directory; containment-check and deduplicate each all-active discovery result before loading.
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

| Repository / CI Surface | Why In Scope | Local CI-Equivalent Command | Required Before | Status | Evidence Artifact / Command | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| closeout guard syntax | Python source changed | `python3 -m py_compile tools/todo_closeout_guard.py` | Local-Implemented | passed | exit `0` on 2026-09-25 | import/parse gate |
| closeout guard fixture suite | behavior and test logic changed | `bash tools/tests/todo_closeout_guard_test.sh` | Local-Implemented | passed | `todo_closeout_guard_test: OK` on 2026-09-25 | real Linux/WSL CLI; exact topology, path, code, schema, and exit assertions |
| Delphi self-check | shared tooling coherence changed | `bash self_check.sh` | Local-Implemented | passed | 243 files; 0 individual failures; 0 coherence failures on 2026-09-25 | authoritative broad repository gate |

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
  - **Option A (chosen):** separate explicit and all-active directory-escape fixtures; both require the generic `CLOSEOUT-LIFECYCLE-DIRECTORY-ESCAPE`, candidate lifecycle path, count `0`, results `[]`, and exit `2`. Effort `low`; risk `low`; blast `shared-tool`; maintenance `low`; performance `neutral`; elegance `improves`; structure `improves`.
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
- **Issue `PR-20` — authority containment did not preserve lifecycle containment (`high`).**
  - **Evidence / why now:** R6 critique showed `active/link.md -> ../completed/done.md` and `active -> completed` stay inside authority but can make lexical and resolved lifecycle disagree, reopening explicit/all-active false-go behavior.
  - **Option A (chosen):** make lifecycle directories containment boundaries; reject directory symlinks for every recognized lifecycle, reject cross-lifecycle file aliases with a typed code, and continue allowing/deduplicating same-lifecycle file aliases. Effort `medium`; risk `low`; blast `shared-tool`; maintenance `medium`; performance `neutral`; elegance `improves`; structure `improves`.
  - **Option B:** reject every symlink below authority. Effort `low`; risk `medium`; blast `cross-project`; maintenance `low`; performance `neutral`; elegance `regresses`; structure `neutral`.
  - **Option C:** contain only to authority. Effort `none`; risk `high`; blast `release-gate`; maintenance `high`; performance `neutral`; elegance `regresses`; structure `invalid`.
  - **Resolution:** Option A is frozen in `D-12`, the literal violation schema, `DOD-22/DOD-23`, the protection harness, and explicit/all-active RED fixtures.
- **Issue `PR-21` — lifecycle containment was asymmetric outside active (`high`).**
  - **Evidence / why now:** R7 critique showed `promotion_lane -> active`, `completed -> active`, and reverse-direction file aliases could still present active content under a lexical non-active lifecycle and false-go.
  - **Option A (chosen):** reject directory symlinks for all three recognized lifecycles with generic escape/symlink codes; test cross-lifecycle file aliases in both directions while preserving same-lifecycle file aliases. Effort `low`; risk `low`; blast `shared-tool`; maintenance `low`; performance `neutral`; elegance `improves`; structure `improves`.
  - **Option B:** special-case only active-origin aliases. Effort `low`; risk `high`; blast `release-gate`; maintenance `high`; performance `neutral`; elegance `regresses`; structure `regresses`.
  - **Option C:** maintain a directory-alias ownership map. Effort `high`; risk `medium`; blast `shared-tool`; maintenance `high`; performance `neutral`; elegance `regresses`; structure `neutral`.
  - **Resolution:** Option A generalizes `D-12`, the literal schema, `DOD-20/DOD-22/DOD-23`, and RED fixtures to every recognized lifecycle and both directions.
- **Issue `PR-22` — technical scope and review routing proof were non-canonical (`medium`).**
  - **Evidence / why now:** R8 architecture found `delphi-tooling` outside the canonical scope enum, while the R8 critique reported its subagent envelope could not prove the required review model.
  - **Option A (chosen):** use canonical scope `delphi-self-maintenance`, run deterministic routing preflights for both review kinds, and dispatch R9 with explicit `gpt-5.6-sol/xhigh` no-context read-only settings. Effort `low`; risk `low`; blast `review-governance`; maintenance `low`; performance `neutral`; elegance `improves`; structure `improves`.
  - **Option B:** retain implicit inherited model/scope. Effort `none`; risk `medium`; blast `review-gate`; maintenance `medium`; performance `neutral`; elegance `neutral`; structure `regresses`.
  - **Option C:** waive model proof. Effort `low`; risk `high`; blast `formal-review`; maintenance `high`; performance `neutral`; elegance `regresses`; structure `invalid without human waiver`.
  - **Resolution:** Option A is applied in Profile Scope & Handoffs and R9 Formal Review Routing Evidence; no waiver is used.

### Failure Modes & Edge Cases

- [x] Both candidate roots resolve to the same symlink target: deduplicate and scan once.
- [x] Both candidate roots resolve to distinct authorities: typed ambiguous-authority no-go.
- [x] A candidate `todos/` exists without `active/`: typed unsupported/missing-active no-go.
- [x] A supported `active/` exists but is empty: valid `go`, count zero.
- [x] No supported root exists: typed missing-authority no-go.
- [x] Explicit TODO is outside supported roots despite a misleading suffix: exact outside-authority no-go.
- [x] Explicit leaf symlink escapes authority: exact outside-authority no-go.
- [x] Discovered leaf symlink escapes authority: exclude from results and emit exact outside-authority no-go.
- [x] Any recognized lifecycle directory symlink escapes authority: reject with exact generic lifecycle-directory-escape no-go.
- [x] Any recognized lifecycle directory symlink targets another lifecycle inside authority: reject with exact generic lifecycle-directory-symlink no-go; all-active exercises the active-origin case.
- [x] File alias crosses between any two recognized lifecycles: exclude it with exact lifecycle-escape no-go; same-lifecycle file aliases remain allowed/deduplicated.
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
| `ARQ-R5-01` | architecture R5 | operational next-step/drift/closeout update made part of the post-publish evidence procedure | integrated; R6 completed |
| `CRIT-R5-01..02` | plan critique R5 | exact 4/4 module identity/handling and operational state resolved by `PR-18/PR-19` | integrated; R6 completed |
| `ARQ-R6` | architecture R6 | no material findings | clean; critique R6 still required correction |
| `CRIT-R6-01` | plan critique R6 | lifecycle-local containment and alias policy resolved by `PR-20` | integrated; R7 completed |
| `ARQ-R7` | architecture R7 | no material findings | clean; critique R7 still required correction |
| `CRIT-R7-01` | plan critique R7 | lifecycle directory/file containment generalized symmetrically by `PR-21` | integrated; R8 completed |
| `ARQ-R8-01` | architecture R8 | canonical technical scope corrected by `PR-22` | integrated; R9 completed |
| `CRIT-R8` | plan critique R8 | no technical material findings; routing proof caveat resolved by explicit R9 preflight/model | integrated; R9 completed |
| `ARQ-R9` | explicitly routed architecture R9 | no material findings | clean |
| `CRIT-R9` | explicitly routed plan critique R9 | no material findings | clean |

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
- **Internal reviewer mandate:** `satisfied by explicitly routed fresh R9 architecture and critique reviewers on the frozen material baseline`.
- **Critique lenses:** `correctness|performance|elegance|structural-soundness|risk`.
- **Critique status:** `no_material_findings`
- **Findings summary:** `R1 through R8 were adjudicated and PR-01..PR-22 integrated; explicitly routed fresh R9 critique returned GO with no material findings`.
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
| `ARQ-R6` | `Integrated` | `useful` | `no` | `none` | `n/a` | Architecture R6 returned GO; no corrective finding required. |
| `CRIT-R6-01` | `Integrated` | `useful` | `yes` | `none` | `n/a` | Lifecycle-local containment now rejects cross-lifecycle file aliases and active-directory aliases with exact codes. |
| `ARQ-R7` | `Integrated` | `useful` | `no` | `none` | `n/a` | Architecture R7 returned GO; no corrective finding required. |
| `CRIT-R7-01` | `Integrated` | `useful` | `yes` | `none` | `n/a` | Directory symlink rejection and cross-lifecycle file containment now apply symmetrically to active, promotion_lane, and completed. |
| `ARQ-R8-01` | `Integrated` | `useful` | `yes` | `none` | `n/a` | Active technical scope now uses canonical `delphi-self-maintenance`. |
| `CRIT-R8` | `Integrated` | `useful` | `partial` | `none` | `n/a` | R8 critique returned technical GO; its routing-proof caveat is resolved by deterministic R9 preflights and explicit model/effort dispatch. |
| `ARQ-R9` | `Integrated` | `useful` | `no` | `none` | `n/a` | Explicitly routed architecture R9 returned GO with no material findings. |
| `CRIT-R9` | `Integrated` | `useful` | `no` | `none` | `n/a` | Explicitly routed critique R9 returned GO with no material findings. |
- **Evidence / reference:** `R9 formal review routing guards GO; fresh architecture and critique outputs both GO on origin/feat/add-stack-capabilities@92257fa`.
- **Waiver authority / reference:** `n/a`.

## Gate: Assumption Code Coherence

- **Gate decision:** `required`
- **Why this decision:** guard/source/test facts must still match the frozen plan before approval.
- **Trigger stage:** `after critique convergence and before APROVADO`.
- **Guard scope:** `none — direct facts/decisions, no live assumptions`.
- **Guard command:** `python3 tools/assumption_code_coherence_guard.py --todo foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md`.
- **Gate status:** `no_material_findings`
- **Findings summary:** `No live assumptions exist; frozen facts and decisions match the unchanged pre-implementation guard/test sources.`
- **Evidence / reference:** `assumption_code_coherence_guard: overall go; live assumptions checked 0; gate required/no_material_findings`.
- **Waiver authority / reference:** `n/a`.

## Approval

- **Approved by:** `human authority in the active Codex session; explicit APROVADO received 2026-09-25`.
- **Approval scope:** `the frozen R9 contract only: dual-layout authority resolution, fail-closed boundary/input behavior, regression harness, canonical manifest synchronization, bounded delivery artifact, and governing TODO evidence`.
- **Post-implementation scope revalidation:** `APROVADO by human authority on 2026-09-25 after deterministic drift reported 7/22 changed material sections; approved evolved scope preserves the same path/file/CLI/product boundaries`.
- **Pre-approval authority evidence:** `todo_authority_guard.py --pre-approval: preflight-go; no violations after R9 review, coherence, and scope-drift convergence`.
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

- **Post-approval ingestion outcome:** `completed 2026-09-25; no conflict with the frozen plan or touched surfaces`.
- **Profile-scope evidence:** `operational-coder returned review required only for the already-declared Delphi tool/test/manifest/derived-artifact handoffs; the TODO path itself is allowed`.

## Package-First Assessment

- **Query:** `bash delphi-ai/tools/query_packages.sh --project-root <downstream-project-root> --search "todo closeout authority path resolver"`.
- **Result:** `0 package(s) found`; the full registry contains only unrelated Flutter packages.
- **Decision:** extend the existing canonical `tools/todo_closeout_guard.py`; no external or proprietary package supplies this governance-specific filesystem authority contract.
- **Manifest check:** `tools/manifest.md` was inspected before implementation and remains an approved same-change surface.

## Agent Routing Preflight

- **Client surface:** `codex`
- **Current governed action:** `implementation`
- **Selected role:** `routine-executor`
- **Selected model:** `gpt-5.6-terra`
- **Selected effort:** `medium`
- **Proof mode:** `declared`
- **Exception reason:** `n/a`
- **Subagent / delegation authorization:** `one routine-executor may implement in the principal checkout; all additional writers remain serialized; fresh read-only reviewers remain required for delivery gates`
- **Execution topology:** `primary-checkout-single-writer`
- **Worktree / auxiliary-checkout authorization:** `not-authorized`
- **Worktree authorization evidence:** `n/a`
- **Writer scheduling policy:** `single-writer-serialized`
- **Guard outcome:** `go`
- **Waiver / exception reference:** `n/a`

### R9 Formal Review Routing Evidence

| Review Kind | Surface / Role | Declared Model / Effort | Proof | Guard Outcome | Isolation |
| --- | --- | --- | --- | --- | --- |
| `architecture_opinion` | `formal-review / formal-reviewer` | `gpt-5.6-sol / xhigh` | `declared` | `go` | fresh no-context, read-only |
| `critique` | `formal-review / formal-reviewer` | `gpt-5.6-sol / xhigh` | `declared` | `go` | fresh no-context, read-only |

- **Guard command pattern:** `python3 tools/agent_role_routing_guard.py --client codex --surface formal-review --role formal-reviewer --model gpt-5.6-sol --review-kind <architecture_opinion|critique> --effort xhigh --proof-mode declared`
- **Execution rule:** R9 reviewers must be spawned with the declared model/effort; the rows above are routing proof, not review completion evidence.

## Decision Adherence Validation

| Decision ID | Status | Evidence | Notes |
| --- | --- | --- | --- |
| `D-01` | Adherent | `tools/todo_closeout_guard.py:117-178`; dual-layout fixtures | exactly two immediate candidates plus typed unresolvable/external-root handling |
| `D-02` | Adherent | `tools/todo_closeout_guard.py:196-239,306-311` | resolved-authority-relative selection and classification |
| `D-03` | Adherent | `tools/todo_closeout_guard.py:130-178`; equivalent-root/file fixtures | canonical deduplication and distinct ambiguity |
| `D-04` | Adherent | `tools/todo_closeout_guard.py:196-239,615-669`; negative fixtures | explicit and discovery paths fail closed, including unreadable subtrees/leaves |
| `D-05` | Adherent | empty/incomplete authority fixtures | empty active is go; incomplete is typed no-go |
| `D-06` | Adherent | CWD-relative + symlinked temporary Git fixtures | process-relative explicit path and resolved repo Git context |
| `D-07` | Adherent | explicit input/exit fixture blocks | exact governed and runtime exits preserved |
| `D-08` | Adherent | `tools/todo_closeout_guard.py:670-736`; root/mixed JSON fixtures | stable nullable result-level violations |
| `D-09` | Adherent | LF `tools/tests/todo_closeout_guard_test.sh`; direct execution | harness precondition completed |
| `D-10` | Adherent | bounded diff + `tools/manifest.md` | no instruction/workflow/template changes |
| `D-11` | Adherent | `tools/todo_closeout_guard.py:200-211`; nested/standalone lure fixtures | exact first lexical component |
| `D-12` | Adherent | `tools/todo_closeout_guard.py:182-239,615-669`; lifecycle/non-regular/unreadable matrix | symmetric containment, regular-file-only loading, and error-aware discovery |

## Module Decision Consistency Validation

| Module Decision Ref | Planned Handling | Delivery Status | Evidence | Notes |
| --- | --- | --- | --- | --- |
| `todo-closeout-promotion-method#active-todo-scan` | Preserve | Preserved | retained disposition fixtures + workflow review | generic active scan contract remains intact |
| `todo_closeout_guard.py#path-state` | Supersede (Intentional) | Superseded (Approved) | `tools/todo_closeout_guard.py:196-239,306-311` | resolved-root-relative classification delivered |
| `todo_closeout_guard.py#all-active` | Supersede (Intentional) | Superseded (Approved) | `tools/todo_closeout_guard.py:615-669` | fail-closed error-aware shared authority discovery delivered |
| `todo_closeout_guard.py#exit-contract` | Preserve | Preserved | exact exit fixture block | normal/advisory/runtime/argparse exits preserved |

## Pipeline/Copilot P1/P2 Preflight

| Reviewer Surface / Package | Review Focus | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| standalone closeout guard diff | path escape, false go, nested regression, duplicate scans | passed | fresh Pipeline/Copilot-style R4 preflight + full harness/diff checks | none | no P1/P2 findings after strict-enum and unreadable-tree/leaf remediation |

## Rule-Spirit Anti-Pattern Hunt

| Rule / Principle Surface | Bypass or Anti-Pattern Search Lens | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| deterministic closeout | exit-0 without recognized authority, fixture-only shortcut, project alias | passed | `artifacts/tmp/standalone-foundation-closeout-guard-review/rule-spirit-bounded.json` + human adjudication | none | bounded shared/Docker scan returned zero findings; broader manifest hits were stack-irrelevant keyword false positives |

## Security Risk Assessment

- **Risk level:** `low`.
- **Why this risk level:** local read-only path resolution; malformed/untrusted paths must fail closed.
- **Attack surface in scope:** CLI paths, symlinks, recursive markdown discovery, optional JSON output.
- **Attack simulation decision:** `not_needed` (audit floor `SEC-NOT-TRIGGERED`; bounded negative path/symlink regression tests remain required).
- **Review evidence:** negative outside-root and symlink fixtures planned; no auth, tenant, secret, network, or runtime mutation surface.
- **Residual security risk:** `low`; malformed, cyclic, escaping, dangling, and non-regular filesystem inputs are covered by bounded fail-closed fixtures.

## Performance & Concurrency Risk Assessment

- **Policy schema version:** `pcv-1`
- **Global sensitivity level:** `low`
- **Why this level:** two bounded root candidates and local markdown scan; no concurrency surface.
- **Current delivery stage at review time:** `Local-Implemented`
- **Audit-floor position:** independent performance/concurrency validation is recommended for release sensitivity; all four runtime lanes remain objectively `not_needed` because no endpoint, UI, write, or pressure surface changes.

| Policy | Lane ID | Lane | Trigger Result | Trigger Severity | Trigger Reason Code | Trigger Rationale | Gate Deadline | Minimum Evidence Rule | State | Residual Risk | Uncertainty Reason Code | Recorded At UTC | Executor ID |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `pcv-1` | `EPS` | endpoint-performance-scrutiny | not_needed | low | EPS-DATA-PATH-CHANGED | no endpoint/query path changes | before_local_implemented | EPS-E1 | not_applicable | none | none | `2026-09-25T00:00:00Z` | `codex-primary` |
| `pcv-1` | `FRC` | frontend-race-condition-validation | not_needed | low | FRC-STALE-RESPONSE | no UI async surface | before_local_implemented | FRC-POLICY | not_applicable | none | none | `2026-09-25T00:00:00Z` | `codex-primary` |
| `pcv-1` | `BCI` | backend-concurrency-idempotency-validation | not_needed | low | BCI-EXACT-ONCE-SEMANTICS | no write/concurrency surface | before_local_implemented | BCI-INV | not_applicable | none | none | `2026-09-25T00:00:00Z` | `codex-primary` |
| `pcv-1` | `RLS` | runtime-load-stress-validation | not_needed | low | RLS-BATCH-OR-BULK-PATH-CHANGED | bounded local scan only; no runtime-pressure surface | before_production_ready | RLS-E1 | not_applicable | none | none | `2026-09-25T00:00:00Z` | `codex-primary` |

## Verification Debt Assessment

- **Audit outcome:** `none after semantic adjudication`.
- **Why this outcome:** the helper's raw `high` heuristic is composed of canonical policy vocabulary, intentional negative-test fixture content, five unchecked Out of Scope exclusions, and the three still-active final validation steps; none represents deferred verification work.
- **Inline code TODO debt:** `none`; bounded inspection found no actionable `TODO`, `FIXME`, `HACK`, `XXX`, or `TBD` marker in the changed implementation, test logic, or manifest. Test heredocs deliberately contain TODO governance fixtures and are executable coverage, not debt.
- **Evidence / audit artifact:** `sed 's/\r$//' tools/verification_debt_audit.sh | bash -s -- --todo foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md --repo . --path tools/todo_closeout_guard.py --path tools/tests/todo_closeout_guard_test.sh --path tools/manifest.md`; raw counts were adjudicated against their exact lines. All validation steps are now completed with concrete evidence.
- **Accepted residual debt:** `none`.

## Independent Test Quality Audit Gate

- **Audit decision:** `required`
- **Why this decision:** test logic changes and current coverage is false-green.
- **Trigger signals in scope:** `changed test logic|bugfix|shared deterministic guard`.
- **Required evidence matrix:** `CLI integration/contract + negative fixtures`.
- **Package mode:** `bounded-file-set`.
- **Audit isolation mode:** `fresh internal no-context reviewer`.
- **Internal reviewer mandate:** `required before Completed`.
- **Audit status:** `no_material_findings`
- **Findings summary:** `R1-R7 findings were remediated in the same approved TODO; fresh R8 returned GO on unreadable subtree/leaf handling, lexical provenance, readable-sibling retention, strict enum behavior, and the full prior matrix.`
- **Evidence / reference:** `independent R8 read-only review + current full CLI harness; static scanner outcome none`.

## Independent No-Context Final Review Gate

- **Final review decision:** `required`
- **Why this decision:** release-critical cross-project guard behavior.
- **Impact signals in scope:** `false-positive governance gate|nested compatibility`.
- **Package mode:** `bounded-file-set`.
- **Review isolation mode:** `fresh internal no-context reviewer`.
- **Internal reviewer mandate:** `required before Completed`.
- **Final review status:** `no_material_findings`
- **Findings summary:** `Final R1 identified a real exact-code precedence defect and incomplete parser-compatible evidence rows. Both were remediated in-scope: an unknown-lifecycle escaping Markdown alias now receives outside-authority precedence with a fail-first regression, and all 44 delivery criteria have exact row-level evidence. Fresh final R2 returned GO with no P1/P2 or closeout blocker.`
- **Evidence / reference:** `fresh independent no-context final R2; full CLI harness OK; self-check 243/0/0; deterministic/audit/coherence/diff guards and git diff-check passed`.

## Independent Multi-Lane Audit Gate

- **Audit decision:** `required`
- **Why this decision:** audit floor marks the release-critical false-positive guard as high criticality.
- **Canonical protocol:** `audit-protocol-triple-review` (additive; it does not replace planning critique, test-quality audit, or final review).
- **Required lanes:** `performance + test-quality`; cutover-integrity is not triggered.
- **Package mode:** `bounded-file-set`.
- **Run root:** `artifacts/tmp/standalone-foundation-closeout-guard-audit`.
- **Audit status:** `passed`
- **Findings summary:** `Rounds 01-03 findings/conflicts were resolved; rounds 04-05 were clean. Post-remediation round 06 lanes were substantively clean and its wording-only recommended-path conflict was explicitly resolved; fresh convergence round 07 is clean in both performance and test-quality lanes with zero findings.`
- **Evidence / reference:** `artifacts/tmp/standalone-foundation-closeout-guard-audit/session.json`; `round-07/round-summary.md` (`clean`).

## TODO Closeout Disposition

- **Disposition:** `move-completed`
- **Disposition reason:** implementation, all independent reviews/audits, verification debt adjudication, and deterministic delivery gates are green; only commit/push and the exact lifecycle move remain.
- **Post-commit/push status:** `complete — delivery commit 6dc5bd4 published to origin/feat/add-stack-capabilities`.
- **Next path/status action:** `completed — moved to foundation_documentation/todos/completed/TODO-delphi-standalone-foundation-closeout-guard.md after push`.
- **Post-move guard evidence:** explicit validation of this completed TODO is `go`; the global `--all-active` scan correctly returns no-go for two unrelated pre-existing active TODO disposition defects, proving fail-closed discovery without expanding this package's authorized scope.

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
