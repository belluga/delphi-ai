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
- Local CI-equivalent commands and runtime/topology evidence.

## Procedure
1. Fill the `Completion Evidence Matrix`.
   - Add one concrete row for every `Definition of Done` and `Validation Steps` criterion.
   - Evidence must be criterion-specific, not aggregate or representative.
2. Execute every in-scope row in the `Local CI-Equivalent Suite Matrix` locally and mark it `passed`, or record an explicit approved `n/a`/waiver.
3. Validate decision adherence and module decision consistency.
4. Run security risk assessment.
5. Run performance/concurrency assessment.
6. Execute validation steps and map results back to the evidence matrix.
7. Run `Pipeline/Copilot P1/P2 Preflight`.
   - Review implemented diff, CI-equivalent evidence, and likely CI/Copilot failure modes.
   - Unresolved `P1|P2` blocks delivery.
8. Run `Rule-Spirit Anti-Pattern Hunt`.
   - Search direct violations and disguised bypasses against ingested rules and architecture principles.
   - Use `bash delphi-ai/tools/rule_spirit_anti_pattern_scan.sh --repo <repo-root> --stack <stack>` when applicable.
   - For non-trivial diffs, prefer `--json-output <artifact>` so severity, finding keys, and allowlist status are reviewable.
   - Allowlists are temporary exceptions only: each entry needs an owner, expiration date, and reason; expired entries remain active findings.
   - Unresolved `P1|P2` blocks delivery.
9. Run derived test-quality, verification-debt, and final-review lanes when the audit floor requires them.
10. Run:
    - `python3 delphi-ai/tools/todo_authority_guard.py <todo-path> --require-delivery-gates`
    - require `Overall outcome: go`.
11. Run:
    - `python3 delphi-ai/tools/todo_completion_guard.py <todo-path>`
    - require `Overall outcome: go`.
12. Treat the deterministic guards as necessary but not sufficient:
    - the authority guard validates approval/rule-ingestion/gate-routing evidence;
    - the completion guard validates objective close-claim evidence tables;
    - they do not replace security/performance judgment, audit-floor execution, or canonical module consolidation.

## Outputs
- Completed delivery evidence sections.
- Audit/review evidence required by the derived floor.
- Deterministic completion guard result.

## Non-Negotiables
- Visible, interactive, or user-flow-impacting criteria require item-specific integration/device or navigation/browser evidence unless an approved structure-only rationale exists.
- Browser/web-visible criteria require source-owned Playwright evidence when the repo exposes a Playwright suite.
- CRUD/mutation criteria require mutation-path evidence on the approved non-main target.
- Backend producer surfaces cannot close on backend evidence alone when the `Frontend / Consumer Matrix` declares a consumer.
- No delivery claim is valid while `todo_completion_guard.py` returns anything other than `Overall outcome: go`.
- No delivery claim is valid while `todo_authority_guard.py --require-delivery-gates` returns anything other than `Overall outcome: go`.
- No `Overall outcome: go` result may be used to bypass approval, rule ingestion, or required review/audit lanes.
