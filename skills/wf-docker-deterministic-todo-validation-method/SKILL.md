---
name: wf-docker-deterministic-todo-validation-method
description: "Workflow: MUST use whenever the scope matches this purpose: Export a machine-checkable TODO validation bundle and run deterministic structural checks so CI can block missing gate/blocker/waiver evidence with diagnostic output."
---

# Method: Deterministic TODO Validation

## Purpose
Turn the canonical tactical TODO markdown into a machine-checkable validation bundle, then run deterministic structural validation over the fields PACED already treats as objective.
This applies only to tactical TODOs from `templates/todo_template.md`, not to profile-scoped capped no-code ledgers from `templates/capped_todo_template.md`.

## Procedure
1. Export normalized bundle:
   ```bash
   python3 delphi-ai/tools/todo_validation_bundle_export.py \
     --todo foundation_documentation/todos/active/<lane>/<slug>.md \
     --output foundation_documentation/artifacts/tmp/<slug>-todo-validation-bundle.json
   ```
2. Run deterministic validator:
   ```bash
   python3 delphi-ai/tools/todo_deterministic_validator.py \
     --todo foundation_documentation/todos/active/<lane>/<slug>.md \
     --bundle-output foundation_documentation/artifacts/tmp/<slug>-todo-validation-bundle.json \
     --report-json foundation_documentation/artifacts/tmp/<slug>-todo-validation-report.json
   ```
3. Treat `FAIL` as objective structural blocker until the TODO fields are corrected.
4. Keep the markdown canonical; never patch the derived bundle instead of the TODO.

## Current Deterministic Coverage
- `Delivery Status Canon` subset: current delivery stage, next exact step, and blocked-state support
- canonical `Qualifiers` value validation
- `Provisional Notes` when `Qualifiers` includes `Provisional`
- `Blocked` qualifier coherence vs `Blocker Notes`
- `Independent No-Context Critique Gate`
- `Independent Test Quality Audit Gate`
- `Independent No-Context Final Review Gate`
- required waiver references for waived gates
- unresolved required-gate states for completed / `Production-Ready` TODOs
