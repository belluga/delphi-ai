---
name: wf-docker-todo-approval-gates-method
description: "Workflow phase: run plan review, audit-floor decisions, critique/triple-review gates, and obtain explicit APROVADO."
---

# Method: TODO Approval Gates

Use when the TODO contract is refined and ready for pre-execution review. Canonical details live in `workflows/docker/todo-approval-gates-method.md`.

## Responsibilities
- Freeze or refresh `Decision Baseline (Frozen)`.
- Run module coherence, plan review, audit escalation, and required critique/triple-review lanes.
- Ask for explicit `APROVADO`.
- Record compact `Approval` evidence in the TODO after approval: approver/reference, authorized scope, exclusions, and renewal trigger.

## Outputs
- Approval-ready TODO with review/audit evidence.
- Explicit approval record.

## Non-Negotiables
- No tactical implementation before `APROVADO`.
- Do not rely on chat memory alone after approval; the TODO must carry the approval evidence.
- Approval-material changes require renewed approval.
