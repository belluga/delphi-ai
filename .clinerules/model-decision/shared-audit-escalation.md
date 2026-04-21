<!-- Generated from `rules/core/audit-escalation-model-decision.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# Audit Escalation (Model Decision)

## Rule
Before Delphi finalizes audit decisions for a tactical TODO, it must derive the minimum audit floor from the canonical `Audit Trigger Matrix` in that TODO.

The deterministic authority for that decision is:

```bash
python3 delphi-ai/tools/audit_escalation_guard.py --todo <todo-path> [--json-output <artifact-path>]
```

### Required TODO Input
The TODO must contain an `Audit Trigger Matrix` section with exactly these trigger rows:
- `complexity`
- `blast_radius`
- `behavioral_change_or_bugfix`
- `changes_public_contract`
- `touches_auth_or_tenant`
- `touches_runtime_or_infra`
- `touches_tests`
- `critical_user_journey`
- `release_or_promotion_critical`
- `high_severity_plan_review_issue`
- `explicit_three_lane_request`

Each row must use the canonical enum domain defined by the tactical TODO template and the guard. Free-text substitutes are not acceptable.

### Deterministic Floor Policy
- The guard defines the **minimum** required audit path.
- Manual escalation may be stricter than the guard result.
- Manual execution may never be weaker than the guard result.
- A guard result of `required` cannot be downgraded without changing the trigger matrix and rerunning the guard.

### Lifecycle Placement Authority
The derived floor must be recorded into the correct TODO gate sections:
- planning critique before `APROVADO`
- delivery-side test-quality audit before closure when triggered
- delivery-side final review before closure
- security/performance/debt lanes in their own canonical delivery sections
- dedicated three-lane external audit only where the TODO lifecycle already has evidence to review

The dedicated three-lane external audit is additive unless a future canonical rule explicitly authorizes replacement semantics.

### Rerun Requirement
Delphi must rerun the guard whenever any trigger changes materially after implementation starts, especially when:
- tests were touched unexpectedly;
- auth/tenant scope expanded;
- runtime/infra scope expanded;
- release/promotion criticality changed;
- a `high` severity plan-review issue appeared or the reasoning around it changed materially.

### Workflow Reference
Execute the policy through:
- `delphi-ai/workflows/docker/audit-escalation-method.md`

## Rationale
PACED should not depend on fuzzy memory to decide whether external critique, final review, or specialized assurance lanes are required. This rule makes the audit floor explicit, repeatable, and teachable while still allowing the operator to be more conservative.

## Enforcement
- Block audit decisions that do not come from a successful guard run.
- Block TODOs that omit the canonical `Audit Trigger Matrix`.
- Block attempts to downgrade a guard-derived `required` lane without rerunning the guard on an updated matrix.
- Block silent use of the three-lane external audit as an implicit replacement for critique, final review, or test-quality audit.

## Workflow Reference

See: `.clinerules/workflows/docker-audit-escalation-method.md`
