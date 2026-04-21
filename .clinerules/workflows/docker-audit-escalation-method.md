---
name: "docker-audit-escalation-method"
description: "Derive the minimum required PACED audit path from a tactical TODO with a deterministic trigger matrix and TEACH guard, then place each audit at the correct TODO lifecycle gate."
---

<!-- Generated from `workflows/docker/audit-escalation-method.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# Workflow: Audit Escalation

## Purpose
Establish a deterministic minimum audit floor for tactical TODOs so critique, delivery review, and specialized assurance lanes are triggered consistently.

This workflow decides the minimum required path. Operators may escalate to stricter review, but they must not silently go lighter than the derived floor.

## Preconditions
- Active tactical TODO under `foundation_documentation/todos/active/`.
- `delphi-ai/templates/todo_template.md` has been used or the TODO has already been aligned to the canonical schema.
- Related governance loaded:
  - `delphi-ai/rules/core/audit-escalation-model-decision.md`
  - `delphi-ai/rules/core/todo-driven-execution-model-decision.md`
- Use the deterministic guard:
  - `python3 delphi-ai/tools/audit_escalation_guard.py --todo <todo-path> [--json-output <artifact-path>]`

## Steps
1. Populate the TODO `Audit Trigger Matrix` with exact canonical values.
   - Required triggers:
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
2. Run the deterministic guard and require `Overall outcome: go`.
   - If the guard returns `no-go`, fix the matrix or the TODO inconsistency it reported before continuing.
3. Record the derived floor in the existing TODO sections.
   - `critique` -> `Independent No-Context Critique Gate`
   - `security_review` -> `Security Risk Assessment`
   - `performance_concurrency` -> `Performance & Concurrency Risk Assessment`
   - `verification_debt` -> `Verification Debt Assessment`
   - `test_quality_audit` -> `Independent Test Quality Audit Gate`
   - `final_review` -> `Independent No-Context Final Review Gate`
   - `triple_review` -> the `Canonical multi-lane audit protocol` field inside the applicable review sections
4. Place each audit in the lifecycle exactly where it belongs.
   - `critique` is the planning challenge lane and must run before `APROVADO`.
   - `security_review`, `performance_concurrency`, and `verification_debt` stay in their own delivery gates and deadlines.
   - `test_quality_audit`, `final_review`, and any `triple_review` run after implementation and after primary validation/adherence evidence exist.
5. Treat the dedicated three-lane external audit as additive only.
   - `audit-protocol-triple-review` never replaces the mandatory planning critique.
   - Unless a future canonical rule says otherwise, it also does not silently waive required test-quality or final-review gates.
6. Allow stricter escalation, never weaker execution.
   - If human judgment wants more review than the guard requires, that is allowed.
   - If the guard marks a lane `required`, it cannot be downgraded without changing the trigger matrix and rerunning the guard.
7. Rerun the guard whenever the trigger matrix changes materially after implementation.
   - Typical causes:
     - tests were touched unexpectedly;
     - auth/tenant scope expanded;
     - runtime/infra scope expanded;
     - the TODO became release-critical;
     - a high-severity plan-review finding appeared or was resolved differently than expected.

## Outputs
- TEACH runtime response showing the derived minimum audit floor.
- Optional structured JSON artifact from `--json-output`.
- Updated TODO sections with deterministic audit decisions and correct lifecycle placement.

## Validation
- `python3 delphi-ai/tools/audit_escalation_guard.py --todo <todo-path>` returns `Overall outcome: go`.
- The TODO records the derived floor in the correct gate sections.
- Any later trigger change causes a rerun before the TODO claims closure.
