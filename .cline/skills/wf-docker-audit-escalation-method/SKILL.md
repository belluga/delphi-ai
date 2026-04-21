---
name: wf-docker-audit-escalation-method
description: "Workflow: MUST use whenever a tactical TODO needs a deterministic audit floor so critique, delivery review, and specialized audit lanes are placed consistently."
---

# Workflow: Audit Escalation

Use this skill as the operational entrypoint for the canonical workflow in `workflows/docker/audit-escalation-method.md`.

## Purpose
Derive the minimum PACED audit floor from a tactical TODO with a deterministic trigger matrix and a TEACH guard.

## Triggers
- A tactical TODO needs deterministic audit decisions instead of ad hoc judgment.
- Planning or delivery gates are deciding critique, final review, test-quality audit, or triple-review requirements.
- The user asks for a deterministic audit policy.

## Inputs
- Tactical TODO under `foundation_documentation/todos/active/`.
- Canonical `Audit Trigger Matrix` inside that TODO.
- Guard command:
  - `python3 delphi-ai/tools/audit_escalation_guard.py --todo <todo-path>`

## Procedure
1. Fill the TODO `Audit Trigger Matrix` with the exact canonical trigger names and enum values.
2. Run the guard and require `Overall outcome: go`.
3. Record the derived floor into the TODO gate sections for:
   - critique
   - security review
   - performance/concurrency
   - verification debt
   - test-quality audit
   - final review
   - triple-review protocol when applicable
4. Run critique before `APROVADO`.
5. Run delivery-side audits only after implementation plus primary validation/adherence evidence exist.
6. Treat triple review as additive only; it does not silently replace critique.
7. Rerun the guard whenever trigger fields change materially after implementation.

## Outputs
- TEACH audit-floor decision.
- Updated TODO with deterministic audit placement.
