---
name: wf-docker-todo-delivery-gates-method
description: "Workflow phase: complete evidence, CI-equivalent validation, P1/P2 preflight, rule-spirit hunt, audits, and completion guard before delivery claims."
---

# Method: TODO Delivery Gates

Use when implementation is ready for local delivery, promotion readiness, or close-claim evidence. Canonical details live in `workflows/docker/todo-delivery-gates-method.md`.

## Responsibilities
- Fill criterion-specific `Completion Evidence Matrix`.
- Execute and record in-scope `Local CI-Equivalent Suite Matrix`.
- Load `ci-equivalent-governance` before deciding whether a row truly satisfies `CI-Equivalent`, whether a reconcile-only wrapper is valid, or whether a broad local stage gate such as `stage-full` is parity-complete rather than merely diagnostic.
- When the delivered change also changes a stage-facing test row, wrapper, lifecycle step, or readonly/mutation coverage row, load `ci-equivalent-test-surface-admission` before claiming the matrix is current.
- Load `workflows/docker/effort-selection-method.md` when the active client exposes named effort controls or persistent GOAL support. Delivery/final-review/promotion-readiness judgment and any gate-satisfying review subagents use the highest review-focused tier; keep review subagents stateless by default.
- Run decision adherence, security/performance assessment, validation steps, P1/P2 preflight, post-review finding classification, Rule-Spirit hunt, required audits, and final review.
- Reviewers/auditors keep their normal detection behavior. Run `review-finding-classification` for the blocking decision afterward, classifying each finding as `release-blocker | follow-up-fast-follow | follow-up-hardening | by-design/no-action`.
- Non-blocking findings that still require work must be split into explicit post-version TODOs under `active/fast_follow_required/followup/` or `active/post_release_hardening/hardening/` and referenced from the governing TODO.
- When using `rule_spirit_anti_pattern_scan.sh`, prefer JSON evidence for non-trivial diffs; any scanner allowlist must be owner-bound, reasoned, and expiration-bound.
- Run `python3 delphi-ai/tools/todo_authority_guard.py <todo-path> --require-delivery-gates`.
- Run `python3 delphi-ai/tools/todo_completion_guard.py <todo-path>`.
- Treat deterministic `Overall outcome: go` results as necessary evidence, not a replacement for required audits, security/performance judgment, or canonical module consolidation.

## Outputs
- Delivery-ready TODO evidence with guard result.

## Non-Negotiables
- No aggregate evidence in place of criterion-specific rows.
- No unresolved `P1|P2`.
- No delivery claim unless both authority guard and completion guard return `Overall outcome: go`.
- No guard pass may be used to bypass required review/audit lanes.
