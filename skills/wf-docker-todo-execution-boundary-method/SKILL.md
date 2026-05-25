---
name: wf-docker-todo-execution-boundary-method
description: "Workflow phase: execute implementation only inside the approved TODO boundary while ingesting touched-surface rules."
---

# Method: TODO Execution Boundary

Use after `APROVADO` and before or during implementation. Canonical details live in `workflows/docker/todo-execution-boundary-method.md`.

## Responsibilities
- Re-read the approved TODO.
- Ingest touched-surface rules/workflows.
- Run `python3 delphi-ai/tools/todo_authority_guard.py <todo-path>` after approval/rule ingestion.
- Execute only inside the approved objective.
- Stop for renewed approval when execution reveals a new objective, behavior, or risk conversation.

## Outputs
- Implemented diff and updated execution notes inside the same governing TODO.

## Non-Negotiables
- No hidden scope expansion.
- No implementation against stale rules.
- No implementation after approval/rule ingestion unless `todo_authority_guard.py` returns `Overall outcome: go`.
