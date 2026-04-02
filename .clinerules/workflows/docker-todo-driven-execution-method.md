---
name: docker-todo-driven-execution
description: "Execute implementation through tactical TODO contracts with APROVADO and decision-adherence gates."
---

# Workflow: TODO-Driven Execution

## Purpose

Guarantee implementation follows an approved TODO contract (`WHAT`), an explicit execution plan (`HOW`), and rule ingestion for the touched surfaces before code changes begin.

## Triggers

- Feature work, bugfixes, refactors, or documentation updates that change project artifacts.

## Steps

1. **Locate/refine TODO**
- Use `foundation_documentation/todos/active/` unless maintenance flow qualifies for ephemeral TODO.
- Restate scope, out-of-scope, definition of done, and validation steps.
- Ensure canonical module anchors are declared (primary module, optional secondary modules, promotion targets).
- Treat canonical module docs as the coherence authority, not the TODO text alone.
- Start with one broad scan of the TODO against those module anchors for gaps, conflicts, ambiguities, uncovered behavior, and missing validation/DoD alignment.
- Triage findings into `Material Decision`, `Implementation Detail`, or `Redundant/Already Covered`.
- Convert only `Material Decision` findings into a `Decision Pending` entry (or equivalent pending-decision section).
- Resolve implementation details autonomously and avoid reopening redundant/already-covered items.
- Group related material decisions by theme when possible and stop escalating new decisions once the remaining findings are implementation-local and module-coherent.
- Resolve all COMMENT/COMENTARIO blocks.
- Make sure definition of done and validation steps are concrete enough to tell whether the work is actually complete.

2. **Planning controls**
- Build `Assumptions Preview` from code/module/doc evidence, not free guesses.
- Build `Execution Plan` with touched surfaces, ordered steps, test strategy, fail-first targets when required, and runtime/rollout notes.
- Classify complexity (`small|medium|big`) and checkpoint policy.
- For `medium|big`, run Plan Review Gate against the assumptions and execution plan.

3. **Decision controls**
- Assign decision IDs (`D-01`, `D-02`, ...).
- Freeze approved decisions in `Decision Baseline (Frozen)` before implementation.
- Compare frozen decisions against canonical module anchors and classify each as `Aligned`, `Conflict`, or `Supersede`.
- The coherence reference is always the canonical module docs, never the TODO text alone.
- Do not proceed while any decision remains `Conflict`.
- Do not proceed while material pending decisions remain unresolved.

4. **Approval gate**
- Request explicit **APROVADO**.
- Do not implement before approval.

5. **Rules ingestion**
- After `APROVADO`, ingest the rules/workflows that govern the plan's touched surfaces.
- Record what must be preserved, what must be avoided, and the execution impact.

6. **Implementation**
- Execute within TODO scope and frozen baseline.

7. **Decision Adherence Gate (before delivery)**
- Build `Decision Adherence Validation` table for all baseline decisions.
- Provide evidence per decision (`file:line`, test output, or contract/doc reference).
- If any decision is `Exception`, stop delivery, update decisions/baseline, and request renewed **APROVADO**.

8. **Security + debt closure checks**
- Record explicit security risk level and `attack simulation` decision.
- If attack simulation is `required`, run the adversarial/security review before delivery.
- Audit verification debt when the TODO is `medium|big` or debt signals exist, including inline code TODO hygiene.

9. **Validation and closure**
- Run validation steps.
- Promote stable conceptual outcomes/decisions into canonical module docs before closing TODO.
- Close/move TODO only when all baseline decisions are adherent or superseded by approved decision changes.

## Outputs

- Refined TODO with frozen decision baseline.
- Evidence-backed assumptions preview and explicit execution plan.
- Decision adherence validation evidence.
- Explicit security-risk outcome and verification-debt outcome.
- Delivery only when adherence gate is satisfied.

## Validation

- No project changes before APROVADO.
- No project changes before relevant rules/workflows are ingested for the touched surfaces.
- No project changes while decision/module coherence is unresolved.
- No project changes while assumptions that materially affect the TODO contract remain only implicit.
- No project changes while redundant/already-covered or implementation-local details are still being treated as pending user decisions.
- No delivery with unresolved decision exceptions.
- No delivery without explicit security-risk assessment.
- No TODO closure without verification-debt handling when the scope/risk demands it.
- No TODO closure without module consolidation evidence.
