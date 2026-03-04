---
name: docker-todo-driven-execution
description: "Execute implementation through tactical TODO contracts with APROVADO and decision-adherence gates."
---

# Workflow: TODO-Driven Execution

## Purpose

Guarantee implementation follows approved TODO decisions and that delivery is blocked when adherence is missing.

## Triggers

- Feature work, bugfixes, refactors, or documentation updates that change project artifacts.

## Steps

1. **Locate/refine TODO**
- Use `foundation_documentation/todos/active/` unless maintenance flow qualifies for ephemeral TODO.
- Restate scope, out-of-scope, definition of done, and validation steps.
- Ensure canonical module anchors are declared (primary module, optional secondary modules, promotion targets).
- Resolve all COMMENT/COMENTARIO blocks.

2. **Planning controls**
- Classify complexity (`small|medium|big`) and checkpoint policy.
- For `medium|big`, run Plan Review Gate (Architecture, Code Quality, Tests, Performance, Security).

3. **Decision controls**
- Assign decision IDs (`D-01`, `D-02`, ...).
- Freeze approved decisions in `Decision Baseline (Frozen)` before implementation.
- Compare frozen decisions against canonical module anchors and classify each as `Aligned`, `Conflict`, or `Supersede`.
- Do not proceed while any decision remains `Conflict`.

4. **Approval gate**
- Request explicit **APROVADO**.
- Do not implement before approval.

5. **Implementation**
- Execute within TODO scope and frozen baseline.

6. **Decision Adherence Gate (before delivery)**
- Build `Decision Adherence Validation` table for all baseline decisions.
- Provide evidence per decision (`file:line`, test output, or contract/doc reference).
- If any decision is `Exception`, stop delivery, update decisions/baseline, and request renewed **APROVADO**.

7. **Validation and closure**
- Run validation steps.
- Promote stable conceptual outcomes/decisions into canonical module docs before closing TODO.
- Close/move TODO only when all baseline decisions are adherent or superseded by approved decision changes.

## Outputs

- Refined TODO with frozen decision baseline.
- Decision adherence validation evidence.
- Delivery only when adherence gate is satisfied.

## Validation

- No project changes before APROVADO.
- No project changes while decision/module coherence is unresolved.
- No delivery with unresolved decision exceptions.
- No TODO closure without module consolidation evidence.
