---
name: wf-docker-todo-driven-execution-method
description: "Workflow: MUST use whenever work is executed through a tactical TODO, including lane classification, approval, implementation, delivery gates, and closeout."
---

# Method: TODO-Driven Execution

Use this as the TODO-driven umbrella. It is a phase router, not the place for all phase details.

## Canonical Workflow
- `workflows/docker/todo-driven-execution-method.md`

## Phase Skills
Load the phase skill that matches the current TODO state:
- `wf-docker-todo-lane-framing-method`
- `wf-docker-todo-contract-refinement-method`
- `wf-docker-todo-approval-gates-method`
- `wf-docker-todo-execution-boundary-method`
- `wf-docker-todo-delivery-gates-method`
- `wf-docker-todo-closeout-promotion-method`

## Required State Machine
1. Classify lane and framing.
2. Refine the TODO contract.
3. Run approval gates and obtain explicit `APROVADO`.
4. Record approval/rule-ingestion evidence and require `todo_authority_guard.py <todo-path>` to return `Overall outcome: go`.
5. Execute only inside the approved boundary.
6. Complete delivery gates and deterministic guards.
7. Close, block, or promote through the same governing TODO.

## Gates That Must Stay Visible
- No tactical implementation before `APROVADO`.
- `Decision Baseline (Frozen)` before implementation.
- Complexity policy (`small|medium|big`) and `Plan Review Gate` before approval when required.
- `python3 delphi-ai/tools/todo_authority_guard.py <todo-path>` before implementation after approval/rule ingestion.
- `Completion Evidence Matrix` before delivery claims.
- `Local CI-Equivalent Suite Matrix` executed locally for in-scope CI jobs.
- `Decision Adherence` before delivery.
- `Pipeline/Copilot P1/P2 Preflight` before delivery claims.
- `Rule-Spirit Anti-Pattern Hunt` before delivery claims.
- `python3 delphi-ai/tools/todo_authority_guard.py <todo-path> --require-delivery-gates` must return `Overall outcome: go` before any close/delivery claim.
- `python3 delphi-ai/tools/todo_completion_guard.py <todo-path>` must return `Overall outcome: go` before any close/delivery claim.

## Non-Negotiables
- Do not skip a phase silently; mark it `n/a` only with rationale.
- Do not split into a new TODO for promotion follow-through unless promotion itself is the active work.
- Do not leave stable decisions only in tactical notes or chat.
