---
name: wf-docker-effort-selection-method
description: "Workflow: MUST use whenever the scope matches this purpose: Select the appropriate effort tier and GOAL policy for sessions, orchestrators, executor subagents, and review subagents."
---

# Method: Effort Selection

Use when the active client exposes named effort controls and/or persistent GOAL support. Canonical details live in `workflows/docker/effort-selection-method.md`.

## Responsibilities
- Keep `medium` as the routine default for ordinary execution and executor subagents.
- Escalate to the highest review-focused tier for self-improvement, approval/plan review, delivery/final-review/promotion-readiness adjudication, and formal review subagents.
- Treat material strategic ambiguity as the threshold for escalating strategic framing or exploratory review beyond the routine default.
- Require explicit GOAL contracts for executor subagents when the client supports persistent goals.
- Keep review subagents stateless by default unless resumable reviewer state is required by the client/tool.

## Advisory Helper
- `python3 delphi-ai/tools/effort_selection_advisor.py --surface <surface> [--material-strategic-ambiguity] [--goals-supported]`
- Advisory only; it does not replace operator judgment or workflow authority.
