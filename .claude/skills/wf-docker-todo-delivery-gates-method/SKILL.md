---
name: wf-docker-todo-delivery-gates-method
description: "Workflow phase: complete evidence, CI-equivalent validation, P1/P2 preflight, rule-spirit hunt, audits, and completion guard before delivery claims."
---

# Method: TODO Delivery Gates

Use when implementation is ready for local delivery, promotion readiness, or close-claim evidence. Canonical details live in `workflows/docker/todo-delivery-gates-method.md`.

## Responsibilities
- Fill criterion-specific `Completion Evidence Matrix`.
- Execute and record in-scope `Local CI-Equivalent Suite Matrix`.
- Run decision adherence, security/performance assessment, validation steps, P1/P2 preflight, Rule-Spirit hunt, required audits, and final review.
- Run `python3 delphi-ai/tools/todo_completion_guard.py <todo-path>`.

## Outputs
- Delivery-ready TODO evidence with guard result.

## Non-Negotiables
- No aggregate evidence in place of criterion-specific rows.
- No unresolved `P1|P2`.
- No delivery claim unless completion guard returns `Overall outcome: go`.
