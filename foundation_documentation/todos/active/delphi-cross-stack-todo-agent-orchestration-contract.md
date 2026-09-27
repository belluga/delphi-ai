# TODO: Orchestrated Single Tactical TODO Implementation

## Artifact Identity

- **Artifact type:** tactical_execution_contract
- **Origin:** bounded single-TODO implementation method
- **Authority rule:** `config/agent_role_routing.json` remains the sole role/model routing authority.

## Context

This TODO defines an explicitly invoked Codex skill for implementing exactly one approved tactical TODO. The approved TODO may name Laravel, Flutter, Docker, or Delphi paths; those cross-stack paths are allowed only when this same canonical TODO explicitly lists them.

The method preserves the principal checkout, one normal material writer, deterministic intake, ignored raw artifacts, compact TODO summaries, and provider-reported token totals.

## Contract Boundary

- The exact canonical TODO is the sole scope authority. It must provide a frozen baseline, approval and authority gates, and bounded expected paths.
- Every changed path must match an expected path authorized by that same TODO. A cross-stack path is valid only when explicitly listed there.
- Existing JSON is the only role/model authority. Resolver output is execution evidence, never a second authority.
- The routine executor is the sole normal material writer. Provider fallback and automatic dispatch are prohibited.
- Raw Problems, test, review, and usage payloads stay under `artifacts/tmp/todo-execution/<todo-id>/<session-id>/` and are never staged or tracked.
- The TODO stores only compact command/result summaries and provider-reported token totals; missing usage is `unavailable`.

## Implementation Intent

- **Current delivery:** one explicit skill and deterministic intake helpers for one approved tactical TODO.
- **Allowed work:** any Laravel, Flutter, Docker, or Delphi change explicitly listed by that TODO.
- **Not implied:** permission for another TODO, broad initiative, automatic coordination, or unlisted path.

## Delivery Status Canon (Required)

- **Current delivery stage:** Local-Implemented
- **Qualifiers:** none
- **Next exact step:** validate the skill, helpers, focused test, TODO contract, and working-tree diff.

## Active Work State (Required While TODO Remains In active)

- **Work state:** implementation
- **Why this state now:** the single-TODO method is being implemented against the existing routing JSON.
- **Exit condition:** all bounded intake and validation evidence is green.

## Execution Boundary Clarification

- **Prerequisites:** this canonical TODO, its frozen baseline, approved authority gates, and bounded expected paths.
- **Explicit invocation:** the skill is never selected automatically; invoke it by name.
- **Cross-stack rule:** downstream paths are permitted only when explicitly named by this same TODO.
- **Writer rule:** the routine executor is the sole normal material writer.

## Scope

- [ ] Add a concise, explicitly invoked skill for one approved tactical TODO.
- [ ] Resolve declared role/model selections from the existing JSON without duplicating its matrix.
- [ ] Require canonical TODO, frozen baseline, approval/authority gates, and bounded expected paths before implementation.
- [ ] Enforce that every changed path, including cross-stack paths, is authorized by the same TODO.
- [ ] Preserve no provider fallback, single-writer execution, ignored raw artifacts, compact summaries, and provider-reported token totals.
- [ ] Add focused tests for the resolver and single-TODO intake boundaries.

## Out of Scope

- [ ] Broad or multiple-TODO initiatives.
- [ ] Any implementation without a canonical approved TODO.
- [ ] Automatic dispatch, automatic subagent spawning, automatic waiver approval, or automatic delivery.
- [ ] A second routing authority or hardcoded role/model matrix.
- [ ] Provider fallback or changes to global guards, workflows, or unrelated project configuration.

## Diff Expectation Contract

- **Contract status:** required
- **Policy:** strict; only paths explicitly authorized by this single tactical TODO may change
- **User validation:** required on deviation
- **Comparison mode:** working_tree

### Repository Baselines

| Repository | Path | Baseline ref | Comparison mode |
| --- | --- | --- | --- |
| delphi-ai | . | v0.6.2-rc@634b546 | working_tree |

### Expected Changed Paths

| Repository | Path glob | Change types | Reason |
| --- | --- | --- | --- |
| delphi-ai | foundation_documentation/todos/active/delphi-cross-stack-todo-agent-orchestration-contract.md | any | This exact TODO contract and bounded evidence. |
| delphi-ai | skills/orchestrated-single-todo-implementation/** | any | Explicitly invoked skill package. |
| delphi-ai | tools/orchestrated_single_todo_routing.py | any | Deterministic JSON-authority resolver. |
| delphi-ai | tools/orchestrated_single_todo_teach.py | any | Deterministic single-TODO intake gate. |
| delphi-ai | tools/tests/orchestrated_single_todo_test.sh | any | Focused intake and resolver fixtures. |

### Not Expected Changed Paths

| Repository | Path glob | Change types | Reason |
| --- | --- | --- | --- |
| delphi-ai | config/agent_role_routing.json | any | Existing JSON authority is unchanged. |
| delphi-ai | tools/agent_role_routing_guard.py | any | Global routing guard is unchanged. |
| delphi-ai | tools/effort_selection_advisor.py | any | Global advisor is unchanged. |
| delphi-ai | tools/todo_authority_guard.py | any | Global TODO guard is unchanged. |
| delphi-ai | tools/todo_completion_guard.py | any | Global TODO guard is unchanged. |
| delphi-ai | workflows/** | any | Existing workflows are unchanged. |
| delphi-ai | downstream/** | any | Unlisted downstream work is out of scope. |

## Bounded But Elastic Guardrails

- **May stay inside this TODO:** the named skill, helpers, focused test, and explicitly listed cross-stack paths.
- **Must update or split the TODO:** any second TODO, unlisted path, broad initiative, or missing approval/authority evidence.

## Definition of Done

- [ ] The skill is explicit-only and accepts exactly one approved tactical TODO.
- [ ] Intake requires the canonical TODO, frozen baseline, approval gate, authority gate, and bounded expected paths.
- [ ] Every changed path matches an expected path present in that same TODO.
- [ ] JSON remains the sole routing authority and the resolver does not mutate or duplicate it.
- [ ] The routine executor remains the sole normal material writer and provider fallback is prohibited.
- [ ] Raw artifacts are ignored; the TODO contains only compact summaries and provider-reported totals or `unavailable`.
- [ ] Focused tests, TODO validation, diff expectation, self-check, and diff check pass.

## Validation Steps

- [ ] Resolver fixture proves JSON-authoritative role/model selection.
- [ ] Intake fixtures reject missing/non-canonical TODO, unfrozen baseline, failed approval/authority gates, and unlisted paths.
- [ ] Intake fixture accepts an explicitly authorized cross-stack path and rejects one absent from the same TODO.
- [ ] Focused test and Python compilation pass.
- [ ] `python3 tools/todo_deterministic_validator.py` passes for this TODO.
- [ ] `python3 tools/todo_diff_expectation_guard.py` passes for this TODO.
- [ ] `bash self_check.sh` and `git diff --check` pass.

### Flow Evidence Planning Matrix

| Criterion / Flow | Why Flow-Impacting | Required Lane | Planned Evidence | Non-Applicability Rationale |
| --- | --- | --- | --- | --- |
| Single-TODO intake and execution | exact scope and writer authority | JSON route plus approved TODO | deterministic fixtures, skill validation, self-check | no second TODO or automatic coordinator is admitted |
| Explicit cross-stack path | path may touch Laravel, Flutter, or Docker | same TODO authorization | expected-path fixture and diff guard | unlisted product paths remain out of scope |

### Local CI-Equivalent Suite Matrix

| Repository / CI Surface | Behavior | Preconditions | Command | Required Before | Status |
| --- | --- | --- | --- | --- | --- |
| routing resolver | JSON-authoritative role/model selection | deterministic JSON fixtures | python3 tools/orchestrated_single_todo_routing.py --client codex --surface implementation --role routine-executor | Local-Implemented | planned |
| single-TODO intake | canonical TODO, frozen baseline, approval/authority gates, and bounded paths | exact TODO contract | bash tools/tests/orchestrated_single_todo_test.sh | Local-Implemented | planned |
| Delphi coherence | canonical wording and mirrors | none | bash self_check.sh | Local-Implemented | planned |
| approval-readiness | named skill/helpers/tests match this contract | approved exact TODO | python3 tools/todo_deterministic_validator.py --todo foundation_documentation/todos/active/delphi-cross-stack-todo-agent-orchestration-contract.md; python3 tools/todo_diff_expectation_guard.py foundation_documentation/todos/active/delphi-cross-stack-todo-agent-orchestration-contract.md | APROVADO | planned |

## Profile Scope & Handoffs

- **Primary execution profile:** operational-coder
- **Active technical scope:** single tactical TODO implementation
- **Expected supporting profiles:** assurance-tester-quality
- **Scope-check command:** `bash self_check.sh`

## Complexity

- **Level:** medium
- **Checkpoint policy:** validate the skill, helper, test, and exact TODO contract together.
- **Why:** the method spans routing evidence, scope admission, and bounded execution evidence without creating a coordinator.

## Canonical Module Anchors

- `config/agent_role_routing.json`
- `tools/orchestrated_single_todo_routing.py`
- `tools/orchestrated_single_todo_teach.py`
- `skills/orchestrated-single-todo-implementation/SKILL.md`
- `tools/todo_deterministic_validator.py`
- `tools/todo_diff_expectation_guard.py`

## Decisions

- [x] D-01: the existing routing JSON is the only role/model authority.
- [x] D-02: skill invocation is explicit-only.
- [x] D-03: exactly one approved canonical TODO controls scope.
- [x] D-04: a frozen baseline, approval/authority gates, and bounded expected paths are mandatory intake evidence.
- [x] D-05: cross-stack Laravel, Flutter, or Docker work is allowed only when explicitly named by that same TODO.
- [x] D-06: the routine executor is the sole normal material writer and provider fallback is prohibited.
- [x] D-07: raw artifacts remain ignored and the TODO retains compact summaries plus provider-reported token totals.
