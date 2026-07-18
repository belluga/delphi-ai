---
name: "docker-todo-delivery-gates-method"
description: "Complete evidence, CI-equivalent validation, P1/P2 preflight, rule-spirit hunt, audits, and deterministic guard before any TODO delivery claim."
---

<!-- Generated from `workflows/docker/todo-delivery-gates-method.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# Workflow: TODO Delivery Gates

## Purpose
Prove the implemented TODO slice before any `Local-Implemented`, `promotion_lane/`, `completed/`, or `Production-Ready` claim.

## Inputs
- Implemented diff.
- Governing TODO with DoD, validation steps, matrices, decisions, and audit-floor output.
- Approved sequencing execution plan when the current TODO belongs to a `sequence/*` package wave.
- Local CI-equivalent commands and runtime/topology evidence.

## Procedure
1. Fill the `Completion Evidence Matrix`.
   - Add one concrete row for every `Definition of Done` and `Validation Steps` criterion.
   - Evidence must be criterion-specific, not aggregate or representative.
   - For any manual/browser/device/runtime-visible validation row, record a runtime freshness attestation before interpreting the result: authoritative `branch@sha`, local build/publish artifact or fingerprint, served runtime target, and proof that the served target matched that exact build.
2. Execute every in-scope row in the `Local CI-Equivalent Suite Matrix` locally and mark it `passed`, or record an explicit approved `n/a`/waiver.
   - Load `ci-equivalent-governance` before deciding whether a row truly satisfies `CI-Equivalent`, whether a reconcile-only wrapper is valid on the current branch family, or whether a broad local stage gate such as `stage-full` is parity-complete rather than diagnostic.
   - If the current TODO is part of an approved sequencing plan, obey that plan's recorded branch-state gate topology. Run the current sequencing unit's exact checkpoint gate now; when that gate is only a non-authoritative prefix from an isolated sequencing worktree, keep the delivery claim provisional and defer the authoritative broad local gate until replay onto the principal authoritative branch.
   - A row is valid only when the executed evidence proves the row's declared behavior/scenario under its declared fixture/seed/runtime preconditions.
   - A generic suite pass is invalid when the target behavior was not actually exercised because required seed data, user linkage, fixtures, runtime bootstrap, or publication state were missing.
   - If the row depends on a real browser/device/manual runtime surface, do not run or interpret it until the runtime freshness attestation proves the served target is fresh for the current authoritative build. Missing or mismatched freshness keeps the row `blocked`.
   - When the declared scenario says navigation/browser or device runtime proof is the strongest available lane, do not close the row on backend-only, unit/widget-only, or aggregate suite evidence.
3. Validate decision adherence and module decision consistency.
4. Run security risk assessment.
5. Run performance/concurrency assessment.
6. Execute validation steps and map results back to the evidence matrix.
7. Run `Pipeline/Copilot P1/P2 Preflight`.
   - Review implemented diff, CI-equivalent evidence, and likely CI/Copilot failure modes.
   - Unresolved `P1|P2` blocks delivery.
   - Load `workflows/docker/effort-selection-method.md` when the active client exposes named effort controls or persistent GOAL support. Delivery/final-review/promotion-readiness judgment and any gate-satisfying review subagents use the highest review-focused tier; review subagents remain stateless by default unless the tool/client requires resumable reviewer state for a bounded package.
8. Run `Review Finding Classification`.
   - Do this **after** Copilot/audit/reviewer findings are collected and deduplicated.
   - Do **not** weaken reviewer prompts or detection behavior to reduce findings.
   - Use `review-finding-classification` as the canonical triage surface before writing ledger routing.
   - Classify each finding as `release-blocker`, `follow-up-fast-follow`, `follow-up-hardening`, or `by-design/no-action`.
   - Only `release-blocker` findings block the current release/promotion claim.
   - If a non-blocking finding still needs real work, split it into an explicit TODO under:
     - `foundation_documentation/todos/active/fast_follow_required/followup/`, or
     - `foundation_documentation/todos/active/post_release_hardening/hardening/`
     and record the originating release/package version in the split TODO plus the governing TODO routing ledger.
9. Run `Rule-Spirit Anti-Pattern Hunt`.
   - Search direct violations and disguised bypasses against ingested rules and architecture principles.
   - Use `bash delphi-ai/tools/rule_spirit_anti_pattern_scan.sh --repo <repo-root> --stack <stack>` when applicable.
   - For non-trivial diffs, prefer `--json-output <artifact>` so severity, finding keys, and allowlist status are reviewable.
   - Allowlists are temporary exceptions only: each entry needs an owner, expiration date, and reason; expired entries remain active findings.
   - Unresolved `P1|P2` blocks delivery.
10. Run the derived architecture adherence review when `architecture_adherence_review = required`:
    - dispatch a fresh internal no-context reviewer with `review_kind=architecture_adherence`; the reviewer cannot be the implementing agent and external providers do not satisfy the gate;
    - bound the package to the frozen Architecture Change Governance contract, Decision Baseline, delivered diff/touched surfaces, protection-harness evidence, and the decision-adherence/module-consistency evidence;
    - block closure on an unresolved divergence from the approved target state, a missing required protection harness, or an unapproved architecture change.
11. Run derived test-quality, verification-debt, and final-review lanes when the audit floor requires them.
12. Run:
    - `python3 delphi-ai/tools/todo_authority_guard.py <todo-path> --require-delivery-gates`
    - require `Overall outcome: go`.
13. Run:
    - `python3 delphi-ai/tools/todo_completion_guard.py <todo-path>`
    - require `Overall outcome: go`.
14. Treat the deterministic guards as necessary but not sufficient:
    - the authority guard validates approval/rule-ingestion/gate-routing evidence;
    - the completion guard validates objective close-claim evidence tables;
    - they do not replace security/performance judgment, audit-floor execution, or canonical module consolidation.

## Outputs
- Completed delivery evidence sections.
- Audit/review evidence required by the derived floor.
- Deterministic completion guard result.
- Explicit provisional-status evidence whenever the current sequencing unit closes only on a non-authoritative checkpoint prefix.

## Non-Negotiables
- Visible, interactive, or user-flow-impacting criteria require item-specific integration/device or navigation/browser evidence unless an approved structure-only rationale exists.
- Browser/web-visible criteria require source-owned Playwright evidence when the repo exposes a Playwright suite.
- Browser/manual/device evidence is invalid unless it records a runtime freshness attestation proving the exercised runtime matched the current authoritative build before the result was trusted.
- CRUD/mutation criteria require mutation-path evidence on the approved non-main target.
- CI-equivalent rows must prove the intended behavior, not merely prove that the suite can run. Missing behavior-targeted data/fixtures/preconditions keep the row `blocked`, even if the command itself exits green.
- A row that claims broad stage-pipeline parity is invalid whenever `ci-equivalent-governance` would reject its contract shape, branch topology, lifecycle-step coverage, or stale-precondition assumptions.
- Do not relabel a non-authoritative sequencing prefix gate as `CI-Equivalent`, promotable `stage-full`, `local-public-web-build` completion, or authoritative browser/runtime freshness proof.
- Do not run `browser-stage-full`, `local-public-web-build`, readonly smoke, or mutation smoke from an isolated sequencing worktree when the sequencing plan records only the pre-browser checkpoint prefix.
- Backend producer surfaces cannot close on backend evidence alone when the `Frontend / Consumer Matrix` declares a consumer.
- No delivery claim is valid while `todo_completion_guard.py` returns anything other than `Overall outcome: go`.
- No delivery claim is valid while `todo_authority_guard.py --require-delivery-gates` returns anything other than `Overall outcome: go`.
- No `Overall outcome: go` result may be used to bypass approval, rule ingestion, or required review/audit lanes.
- A required architecture adherence review must be resolved or explicitly waived before `Completed` or `Production-Ready`.
- Follow-up/hardening findings are not blockers by default, but they are not disposable either: they must be fixed in-scope or split into an explicit post-version TODO with authoritative reference before delivery can be claimed cleanly.
