# TODO-Driven Execution (Model Decision)

## Rule

Before any implementation work that changes project code, submodule code, or project-specific documentation, Cline must operate from a tactical TODO under `foundation_documentation/todos/active/` unless the change is explicitly exempt.

### Mandatory Gates

1. **TODO presence and refinement**
- Ensure TODO exists.
- Summarize scope/out-of-scope/DoD/validation.
- Resolve all COMMENT/COMENTARIO blocks before coding.

2. **Complexity + planning gate**
- Classify `small|medium|big` and checkpoint policy.
- Run full Plan Review Gate for `medium|big`.

3. **Approval gate**
- Request and obtain explicit **APROVADO** before any project-modifying action.

4. **Decision baseline + adherence gate**
- Assign decision IDs and freeze a `Decision Baseline (Frozen)` before implementation.
- Before delivery, produce `Decision Adherence Validation` with evidence per decision.
- If any baseline decision is `Exception`, delivery is invalid until decisions are updated and renewed **APROVADO** is obtained.

### Authority
- Cline plans/recommendations are advisory by default.
- Delivery authority remains Delphi TODO + APROVADO + Decision Adherence Gate.

## Rationale

This prevents non-adherent delivery and enforces full control over implementation quality and scope.

## Enforcement

- Block implementation without TODO.
- Block implementation without APROVADO.
- Block delivery without decision-adherence evidence.

## Workflow Reference

See: `.clinerules/workflows/docker-todo-driven-execution.md`
