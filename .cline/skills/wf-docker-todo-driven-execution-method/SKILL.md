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
- `Gate: Review Baseline Freeze` committed and pushed before the first planning-side review/guard run.
- `python3 delphi-ai/tools/review_scope_drift_guard.py --todo <todo-path>` must return `Overall outcome: go` before `APROVADO` whenever the TODO used the review loop.
- Complexity policy (`small|medium|big`) and `Plan Review Gate` before approval when required.
- If the user/TODO/external reference asks for a `devil's advocate` loop, map it canonically to `wf-docker-independent-critique-method`; add `audit-protocol-triple-review` when the request also implies a persistent objection ledger, evidence-based reopening, or repeated no-context rounds until blocking objections are closed.
- `python3 delphi-ai/tools/todo_authority_guard.py <todo-path>` before implementation after approval/rule ingestion.
- `Completion Evidence Matrix` before delivery claims.
- `Local CI-Equivalent Suite Matrix` executed locally for in-scope CI jobs.
- `Decision Adherence` before delivery.
- `Pipeline/Copilot P1/P2 Preflight` before delivery claims.
- `Review Finding Classification` after review/audit findings are collected and before delivery claims. Run `review-finding-classification`; reviewers do not change how they detect issues, classification happens afterward as `release-blocker | follow-up-fast-follow | follow-up-hardening | by-design/no-action`, and the governing TODO must carry the authoritative triage in its `Promotion Finding Routing Ledger`.
- `Rule-Spirit Anti-Pattern Hunt` before delivery claims.
- `python3 delphi-ai/tools/todo_authority_guard.py <todo-path> --require-delivery-gates` must return `Overall outcome: go` before any close/delivery claim.
- `python3 delphi-ai/tools/todo_completion_guard.py <todo-path>` must return `Overall outcome: go` before any close/delivery claim.
- `python3 delphi-ai/tools/todo_closeout_guard.py <todo-path>` must return `Overall outcome: go` before pausing after a delivered TODO or changing closeout path/status.

## Non-Negotiables
- Do not skip a phase silently; mark it `n/a` only with rationale.
- Do not open planning-side review from an unpushed worktree snapshot.
- Do not split into a new TODO for promotion follow-through unless promotion itself is the active work.
- Do not leave stable decisions only in tactical notes or chat.
- Do not treat review-scope-drift `no-go` as a hard rejection; it means the scope evolved and must be revalidated with the user before the loop resumes.
- Do not leave delivered TODOs in `active/` without a valid closeout disposition and actionable next step.
