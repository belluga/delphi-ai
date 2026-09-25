# Standalone Foundation Closeout Guard — Delivery Review Package

## Artifact Contract

- **Type:** derived, bounded delivery-review package
- **Authority:** non-authoritative; the governing tactical TODO and frozen decisions remain canonical
- **Governing TODO:** `foundation_documentation/todos/active/v0.4.0/TODO-delphi-standalone-foundation-closeout-guard.md`
- **Implementation branch / pre-delivery head:** `feat/add-stack-capabilities@2e42d4ce552ee54d95e73059c901d1da2d776615`
- **Approved execution topology:** principal checkout, one serialized writer, no worktree or auxiliary checkout

## Approved Scope Boundary

The package establishes one shared filesystem authority resolver for these two immediate layouts below `--repo`:

- `foundation_documentation/todos`
- `todos`

It preserves the existing closeout-disposition validator and CLI while making missing, incomplete, ambiguous, invalid-input, authority-escape, lifecycle-directory, and cross-lifecycle conditions fail closed with the exact codes frozen in D-01 through D-12. It does not modify downstream projects, policy, workflow, templates, automatic movement, or Git topology.

## Delivered Surfaces

| Surface | Delivered behavior |
| --- | --- |
| `tools/todo_closeout_guard.py` | Shared dual-layout resolver, canonical root/path deduplication, first-component lifecycle classification, lifecycle-local containment, typed boundary result envelope, nullable path rendering, and preserved disposition/Git/exit behavior. |
| `tools/tests/todo_closeout_guard_test.sh` | LF-normalized real-CLI harness retaining all legacy scenarios and adding the complete nested/standalone, invalid-input, alias, lifecycle, schema, exit, Git, and nonmutation matrix. |
| `tools/manifest.md` | Canonical inventory synchronized to dual-layout fail-closed semantics. |

## Fail-First Evidence

- Harness precondition: the tracked shell test was normalized from CRLF to LF so the declared Linux/WSL command could execute directly.
- Baseline characterization: the original nested explicit/all-active and disposition scenarios passed before production changes.
- Behavior RED: a desired standalone explicit fixture failed against the original guard because the process exited `0`, printed `Overall outcome: go`, and classified the standalone TODO as `path_state: other` instead of `active`.
- Production code changed only after that desired-behavior RED was observed.

## Implementation Evidence

- Authority and lifecycle resolver: `tools/todo_closeout_guard.py:117`, `tools/todo_closeout_guard.py:182`.
- Resolved-authority lifecycle classification: `tools/todo_closeout_guard.py:196`, `tools/todo_closeout_guard.py:306`.
- Contained, regular-file-only, deduplicated, error-aware active discovery: `tools/todo_closeout_guard.py:615`.
- Stable result envelope and nullable text rendering: `tools/todo_closeout_guard.py:670`, `tools/todo_closeout_guard.py:704`.
- Dual-layout CLI help and exit mapping: `tools/todo_closeout_guard.py:737`, `tools/todo_closeout_guard.py:750`.
- Full real-CLI protection harness: `tools/tests/todo_closeout_guard_test.sh`.

## Validation Evidence

| Command | Outcome |
| --- | --- |
| `python3 -m py_compile tools/todo_closeout_guard.py` | passed |
| `bash tools/tests/todo_closeout_guard_test.sh` | passed; `todo_closeout_guard_test: OK` |
| `bash self_check.sh` | passed; 243 individual files checked, 0 individual failures, 0 coherence failures |
| `git diff --check` | passed |
| `python3 tools/todo_diff_expectation_guard.py <todo> --repo-root .` | `Overall outcome: go`; 5 actual/expected paths, 0 forbidden, 0 unclassified |

## Test Matrix Summary

The real CLI fixtures directly cover DOD-01 through DOD-23, including:

- nested and standalone explicit/all-active/CWD-relative operation;
- equivalent authority and file aliases, symlinked repositories, and canonical Git context;
- missing, incomplete, ambiguous, and valid-empty authorities;
- exact explicit missing/file/type/lifecycle failures;
- authority escape, lifecycle-directory escape/symlink, and every directed cross-lifecycle file alias;
- same-lifecycle aliases and all-active canonical deduplication;
- mixed discovery with retained valid results and a forcing boundary violation;
- exact exits `0`, `2`, and runtime `1`, advisory behavior, JSON/text schema, nullable paths, and count invariant;
- before/after tree/content/mode/link digest proving read-only behavior.

## Mechanical EOL Note

Both touched executable files were stored with CRLF at the baseline. The shell harness required LF by frozen D-09/DOD-17. The Python file was also normalized to LF because every newly added CRLF source line was rejected by the required `git diff --check` as trailing whitespace. This is a same-path mechanical normalization, not a contract or behavior expansion. Current functional review with `git diff --ignore-space-at-eol` reports 247 additions and 44 deletions in the Python guard, 572 additions and 7 deletions in the LF-normalized harness, and the one-row manifest synchronization.

## Delivery Review Remediation

- Architecture adherence R1 found two product defects: explicit invocation through a symlink-spelled `--repo` and traversal-spelled outside paths. Both were classified as same-TODO release blockers and fixed in the shared resolver.
- Test-quality R1 found weak nonzero-only negative assertions, incomplete explicit/all-active authority parity, and incomplete lifecycle envelope assertions. All governed negatives now assert exact exit `2`, structured no-go output, exact code, and no traceback; root states run in both modes; lifecycle directory cases assert JSON count/results/path.
- The harness contains direct regressions for symlink-spelled explicit paths and traversal precedence.
- `rg -n 'if python3|\|\| true|test "\$\?"' tools/tests/todo_closeout_guard_test.sh` returns no matches.
- Authority-root symlinks resolving outside the selected repository now fail closed with `CLOSEOUT-AUTHORITY-OUTSIDE-REPOSITORY`; explicit and all-active fixtures assert the zero-result JSON envelope. Broken/escaping discovered leaf aliases, missing leaves below lifecycle-directory aliases, and active-to-promotion/completed discovery aliases are also protected by exact typed regressions.
- Cyclic repository/lifecycle/leaf symlinks, dangling authority aliases, FIFO/socket `.md` nodes, and symlinks to non-files fail closed without a traceback or blocking read. Boundary helpers require one exact violation, zero unauthorized results, and the lexical violation path.
- Markdown-terminal punctuation in disposition enum values is rejected through a real CLI fixture, preserving the baseline strict enum contract; a JSON-output write failure preserves runtime exit `1` with a clean error instead of a traceback.
- Standalone explicit mode now proves real disposition validation, and standalone all-active mode proves that two discovered TODOs are both loaded with the invalid result retained and surfaced.
- Active discovery uses `os.walk(..., onerror=...)`; an unreadable subtree emits `CLOSEOUT-DISCOVERY-UNREADABLE` under a real mode-`000` Linux/WSL fixture instead of silently producing a false `go`.
- Unreadable discovered Markdown leaves are caught at load time with their lexical path, omitted from `todo_results`, and do not suppress readable siblings in the same scan.
- Final review found one exact-code precedence defect for an unknown-lifecycle Markdown alias resolving outside authority. A desired-behavior regression failed first; resolved-authority containment now precedes unknown-lifecycle classification, and the full harness is green.
- The same final review exposed parser-incompatible aggregate completion evidence. The governing TODO now provides exact criterion-level rows for all 14 Scope, 23 DOD, and 7 Validation items; the authority guard is green and only the deliberately last completion invocation remains.
- Fresh independent final review R2 returned GO with no material finding after both remediations.

## Risk and Residual Position

- **Security:** low; local path/symlink inputs now fail closed and no network, secret, auth, or mutation boundary was added.
- **Performance:** acceptable; exactly two authority candidates are resolved, and active discovery remains linear in discovered Markdown paths with a constant-time canonical-path set.
- **Concurrency:** not applicable; the tool is read-only except for the explicit JSON output path.
- **Compatibility:** nested behavior and all original disposition scenarios remain directly asserted.
- **Known residual risk:** Windows junction semantics are not separately claimed; the approved contract is Python `Path.resolve()` plus Linux/WSL symlink evidence.
- **Waivers:** none.

## Independent Review Inputs

Reviewers should evaluate the frozen D-01 through D-12 contract, the functional diff using `--ignore-space-at-eol`, the full shell harness, validation results above, and these specific risks:

1. false `go` from missing or unrecognized authority;
2. lexical/resolved lifecycle disagreement through directory or file aliases;
3. loss of original disposition validation behavior;
4. ineffective assertions or pass-the-test-only fixtures;
5. unbounded discovery, duplicated resolver logic, or project-specific topology leakage.
