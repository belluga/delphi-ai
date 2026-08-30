---
name: wf-docker-todo-delivery-gates-method
description: "Workflow phase: complete evidence, CI-equivalent validation, P1/P2 preflight, rule-spirit hunt, audits, and completion guard before delivery claims."
---

# Method: TODO Delivery Gates

Before each architecture-adherence or final-review dispatch, rerun `review_scope_drift_guard.py` against the approved baseline; rerun it after protected-section remediation. Each review package/evidence record must bind the approved baseline SHA and the exact fresh guard output; protected remediation requires a new binding from the rerun. Treat approved implementation-horizon intent as binding unless renewed approval changes it.

Use when implementation is ready for local delivery, promotion readiness, or close-claim evidence. Canonical details live in `workflows/docker/todo-delivery-gates-method.md`.

## Responsibilities
- Fill criterion-specific `Completion Evidence Matrix`.
- Execute and record in-scope `Local CI-Equivalent Suite Matrix`.
- Load `ci-equivalent-governance` before deciding whether a row truly satisfies `CI-Equivalent`, whether a reconcile-only wrapper is valid, or whether a broad local stage gate such as `stage-full` is parity-complete rather than merely diagnostic.
- Keep topology conditional: principal-checkout single-writer orchestration validates the current authoritative branch without `reconcile/*`; only explicitly worktree-authorized orchestration uses reconcile/replay gates. Subagent use alone must never trigger those gates.
- When the governing TODO is part of an approved sequencing plan, inherit that plan's recorded checkpoint-gate topology instead of improvising a broader gate; isolated pre-browser prefixes keep the delivery claim provisional until replay plus the deferred authoritative broad gate succeed.
- When the delivered change also changes a stage-facing test row, wrapper, lifecycle step, or readonly/mutation coverage row, load `ci-equivalent-test-surface-admission` before claiming the matrix is current.
- Load `workflows/docker/effort-selection-method.md` when the active client exposes named effort controls or persistent GOAL support. Delivery/final-review/promotion-readiness judgment and any gate-satisfying review subagents use the highest review-focused tier; keep review subagents stateless by default.
- Run decision adherence, security/performance assessment, validation steps, P1/P2 preflight, post-review finding classification, Rule-Spirit hunt, required audits, and final review.
- Reviewers/auditors keep their normal detection behavior. Run `review-finding-classification` for the blocking decision afterward, classifying each finding as `release-blocker | follow-up-fast-follow | follow-up-hardening | by-design/no-action`.
- Non-blocking findings that still require work must be split into explicit post-version TODOs under the project-approved active classification/version topology and referenced from the governing TODO. When both families and version packages are active, classification chooses the family root and package authority decides admitted wave membership.
- When using `rule_spirit_anti_pattern_scan.sh`, prefer JSON evidence for non-trivial diffs; any scanner allowlist must be owner-bound, reasoned, and expiration-bound.
- Run `python3 delphi-ai/tools/todo_authority_guard.py <todo-path> --require-delivery-gates`.
- Run `python3 delphi-ai/tools/todo_completion_guard.py <todo-path>`.
- Run `python3 delphi-ai/tools/todo_diff_expectation_guard.py <todo-path> --repo-root <authoritative-checkout>` and require `Overall outcome: go`.
- Treat deterministic `Overall outcome: go` results as necessary evidence, not a replacement for required audits, security/performance judgment, or canonical module consolidation.

## Outputs
- Delivery-ready or provisional-delivery-ready TODO evidence with guard result.

## Non-Negotiables
- No aggregate evidence in place of criterion-specific rows.
- No unresolved `P1|P2`.
- No delivery claim unless both authority guard and completion guard return `Overall outcome: go`.
- No delivery claim unless the diff expectation guard also returns `Overall outcome: go`.
- Any unclassified, forbidden, or incompatible diff path/type requires `Diff Deviation Analysis`: classify it as scope deviation, necessary/justifiable need, or noise. A strict no-go is not an automatic rollback; defend necessary changes with evidence, clean noise, revert unnecessary deviations, and obtain user validation plus renewed TODO approval for necessary scope expansion.
- No guard pass may be used to bypass required review/audit lanes.
- No isolated sequencing worktree may relabel a pre-browser checkpoint prefix as `CI-Equivalent`, promotable `stage-full`, `local-public-web-build`, or authoritative readonly/mutation proof.
