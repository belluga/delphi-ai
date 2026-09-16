---
name: wf-docker-effort-selection-method
description: "Workflow: MUST use whenever the scope matches this purpose: Select the appropriate effort tier, model routing, executor state policy, and GOAL policy for sessions, orchestrators, executor subagents, monitors, and review subagents."
---

# Method: Effort Selection

Use when the active client exposes named effort controls, model selection, custom/sticky agent state, and/or persistent GOAL support. Canonical details live in `workflows/docker/effort-selection-method.md`.

## Responsibilities
- Keep `medium` as the routine default for ordinary chat/orchestrator turns and routine executor subagents.
- Keep the chat/orchestrator out of implementation-code creation when executor subagents are available; it plans, packages handoffs, reconciles evidence, and adjudicates gates.
- Prefer the contract-selected `routine_executor` model for routine code executor subagents, with one sticky compact executor per chat/TODO when supported.
- Reset/recompact sticky executor state at TODO closeout, major scope/module change, high-volume context ingestion, stale/confused state, or material branch/worktree authority change.
- Use deterministic monitoring first; if an LLM is needed, use ephemeral low/medium mini summarization over bounded output instead of continuous main-chat log watching.
- Escalate to the contract-selected strongest-review model plus the highest review-focused tier for self-improvement and formal review subagents. Primary-chat approval and delivery adjudication use the contract-selected chat/orchestrator model at the highest review-focused tier unless a separate formal reviewer is dispatched.
- Treat material strategic ambiguity as the threshold for escalating strategic framing or exploratory review beyond the routine default.
- Require explicit GOAL contracts for executor subagents when the client supports persistent goals.
- Keep review subagents stateless by default unless resumable reviewer state is required by the client/tool.
- Record `Agent Routing Preflight` and require `python3 delphi-ai/tools/agent_role_routing_guard.py ...` to resolve to `go` before governed execution/review begins.
- Keep role routing and Git topology independent: executor subagents default to `primary-checkout-single-writer`; `worktree-isolated` requires separate explicit human authorization naming worktrees or auxiliary checkouts.

## Advisory Helper
- `python3 delphi-ai/tools/effort_selection_advisor.py --surface <surface> [--material-strategic-ambiguity] [--goals-supported]`
- Advisory only; it does not replace operator judgment or workflow authority.
