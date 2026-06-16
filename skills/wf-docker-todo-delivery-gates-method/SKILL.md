---
name: wf-docker-todo-delivery-gates-method
description: "Workflow phase: complete evidence, CI-equivalent validation, P1/P2 preflight, rule-spirit hunt, audits, and completion guard before delivery claims."
---

# Method: TODO Delivery Gates

Use when implementation is ready for local delivery, promotion readiness, or close-claim evidence. Canonical details live in `workflows/docker/todo-delivery-gates-method.md`.

## Responsibilities
- Fill criterion-specific `Completion Evidence Matrix`.
- Execute and record in-scope `Local CI-Equivalent Suite Matrix`.
- Respect wrapper branch-family contracts while executing that matrix: CI-Equivalent itself is current-branch local product proof, while a reconcile-only wrapper is only a helper for real `reconcile/*` states. In real subagent orchestration, the consolidated reconciliation branch is the authoritative branch under test until that matrix is green; after that, replay the accepted net effect onto the authoritative return branch before promotion or non-orchestration closeout resumes. On any non-reconciliation branch, run the project-owned local build/publish path and the same product-facing suites directly unless the branch under test is explicitly a same-commit reconcile alias and that equivalence is recorded.
- Run decision adherence, security/performance assessment, validation steps, P1/P2 preflight, post-review finding classification, Rule-Spirit hunt, required audits, and final review.
- Reviewers/auditors keep their normal detection behavior. The blocking decision is made afterward by classifying each finding as `release-blocker | follow-up-fast-follow | follow-up-hardening | by-design/no-action`.
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
