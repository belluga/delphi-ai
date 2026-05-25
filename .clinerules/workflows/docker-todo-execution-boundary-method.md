---
name: "docker-todo-execution-boundary-method"
description: "Execute implementation only inside the approved TODO boundary while ingesting touched-surface rules and controlling scope changes."
---

<!-- Generated from `workflows/docker/todo-execution-boundary-method.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# Workflow: TODO Execution Boundary

## Purpose
Run implementation under the approved TODO contract without silently expanding scope or bypassing touched-surface rules.

## Inputs
- Approved TODO with `APROVADO`.
- Frozen decision baseline.
- Touched-surface rules/workflows.
- Profile scope and handoff log.

## Procedure
1. Re-read the governing TODO immediately before implementation.
2. Ingest the real rules/workflows for touched surfaces after approval and before edits.
3. Run profile scope checks when touched paths cross profile boundaries.
4. Run:
   - `python3 delphi-ai/tools/todo_authority_guard.py <todo-path>`
   - require `Overall outcome: go` before implementation proceeds.
5. Execute only inside the approved objective and approval conversation.
6. Treat TODOs as bounded but elastic:
   - local blockers and small concretization can stay inside the TODO when they preserve the same objective;
   - new independently testable behavior, a new primary objective, or a new approval/risk conversation requires TODO update/split and renewed approval.
7. Keep decisions and deviations in the TODO as they emerge; do not leave durable truth only in chat or tactical notes.

## Outputs
- Implemented diff within approved boundary.
- Updated TODO execution notes, decisions, and blockers when applicable.

## Non-Negotiables
- No hidden scope expansion.
- No implementation against stale rules.
- No implementation after approval/rule-ingestion until `todo_authority_guard.py` returns `Overall outcome: go`.
- No durable project truth left outside canonical project docs after it stabilizes.
- If execution reveals approval-material drift, stop and return to approval gates.
