# TODO-Driven Execution (Model Decision)

## Rule

Before any implementation work that changes project code, submodule code, or project-specific documentation, Cline must operate from a tactical TODO under `foundation_documentation/todos/active/` unless the change is explicitly exempt.

### Mandatory Gates

1. **TODO presence and refinement**
- Ensure TODO exists.
- Summarize scope/out-of-scope/DoD/validation.
- Ensure canonical module anchors are declared (primary module, optional secondary modules, promotion targets).
- Treat canonical module docs as the coherence authority, not the TODO text alone.
- Scan the TODO against those module anchors for gaps, conflicts, ambiguities, uncovered behavior, and missing validation/DoD alignment.
- Convert every material finding into a `Decision Pending` entry (or equivalent pending-decision section).
- Resolve pending decisions one by one with the user before coding.
- Resolve all COMMENT/COMENTARIO blocks before coding.

2. **Complexity + planning gate**
- Classify `small|medium|big` and checkpoint policy.
- Run full Plan Review Gate for `medium|big`.

3. **Approval gate**
- Request and obtain explicit **APROVADO** before any project-modifying action.

4. **Decision baseline + adherence gate**
- Assign decision IDs and freeze a `Decision Baseline (Frozen)` before implementation.
- Compare frozen decisions against canonical module anchors and mark each as `Aligned`, `Conflict`, or `Supersede`.
- The coherence reference is always the canonical module docs, never the TODO text alone.
- Block implementation while any frozen decision remains in `Conflict`.
- Block implementation while material pending decisions remain unresolved.
- Before delivery, produce `Decision Adherence Validation` with evidence per decision.
- If any baseline decision is `Exception`, delivery is invalid until decisions are updated and renewed **APROVADO** is obtained.

5. **Module consolidation gate**
- Before closing/moving TODO, promote stable conceptual outcomes and approved decisions into canonical module docs.
- Record module promotion evidence and TODO ↔ module cross-links.

### Authority
- Cline plans/recommendations are advisory by default.
- Delivery authority remains Delphi TODO + APROVADO + Decision Adherence Gate.

## Rationale

This prevents non-adherent delivery and enforces full control over implementation quality and scope.

## Enforcement

- Block implementation without TODO.
- Block implementation without APROVADO.
- Block implementation when frozen decisions conflict with canonical module anchors.
- Block delivery without decision-adherence evidence.
- Block TODO closure without module consolidation evidence.

## Workflow Reference

See: `.clinerules/workflows/docker-todo-driven-execution.md`
