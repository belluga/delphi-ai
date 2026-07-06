---
name: wf-docker-todo-approval-gates-method
description: "Workflow phase: run plan review, audit-floor decisions, critique/triple-review gates, and obtain explicit APROVADO."
---

# Method: TODO Approval Gates

Use when the TODO contract is refined and ready for pre-execution review. Canonical details live in `workflows/docker/todo-approval-gates-method.md`.

## Responsibilities
- Freeze or refresh `Decision Baseline (Frozen)`.
- Freeze and push the review baseline before the first planning-side review or guard run.
- If the review packet is being prepared before that freeze is satisfied or waived, keep those rows explicitly provisional (`prepared-pre-freeze` / `pending-freeze`) instead of marking them `passed`.
- Run module coherence, plan review, audit escalation, and required critique/triple-review lanes.
- Run optional bounded pre-`APROVADO` RED evidence capture when the TODO explicitly authorizes it for bugfix/regression ambiguity reduction.
- Load `workflows/docker/effort-selection-method.md` when the active client exposes named effort controls or persistent GOAL support. TODO approval/plan review and any gate-satisfying review subagents use the highest review-focused tier; keep review subagents stateless by default.
- Run the assumption-vs-code coherence guard after critique convergence and before approval.
- Run the post-review scope-drift guard before approval.
- Ask for explicit `APROVADO`.
- Record compact `Approval` evidence in the TODO after approval: approver/reference, authorized scope, exclusions, and renewal trigger.

## Outputs
- Approval-ready TODO with review/audit evidence.
- Assumption-vs-code coherence evidence recorded in the TODO.
- Review baseline freeze evidence and review-scope-drift evidence recorded in the TODO.
- Explicit approval record.

## Non-Negotiables
- No tactical implementation before `APROVADO`.
- Pre-`APROVADO` RED evidence capture is not implementation and may touch only the TODO-listed test/support surfaces.
- No planning-side review or guard run before the review baseline freeze is satisfied or explicitly waived.
- Do not mark planning-side review/guard rows `passed` while the review baseline freeze is still pending; use explicit provisional wording until the real freeze-backed run exists.
- No tactical implementation before the assumption-vs-code coherence guard is clean or explicitly waived.
- No tactical implementation before the post-review scope-drift guard is clean or explicitly waived.
- Do not rely on chat memory alone after approval; the TODO must carry the approval evidence.
- Approval-material changes require renewed user scope validation plus renewed approval.
- Do not treat post-review scope-drift `no-go` as a hard rejection; it is a revalidation/reconvergence checkpoint that returns the TODO to the review loop.
