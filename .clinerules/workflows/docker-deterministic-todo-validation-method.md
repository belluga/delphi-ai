---
name: "docker-deterministic-todo-validation-method"
description: "Export a machine-checkable TODO validation bundle and run deterministic structural checks so CI can block missing gate/blocker/waiver evidence with diagnostic output."
---

<!-- Generated from `workflows/docker/deterministic-todo-validation-method.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# Workflow: Deterministic TODO Validation

## Purpose
Turn the canonical tactical TODO markdown into a machine-checkable validation bundle, then run deterministic structural validation over the fields PACED already treats as objective.

This method does **not** judge architectural quality or elegance. It exists to block missing structural obligations with explicit diagnostics.
Those diagnostics should work as resolution instructions whenever possible: the operator should be able to see exactly what field or record must be added or corrected without guessing.
It applies only to tactical TODOs from `templates/todo_template.md`, not to profile-scoped capped no-code ledgers from `templates/capped_todo_template.md`.

## Triggers
- A tactical TODO is created or materially updated and the team wants deterministic validation over gate/blocker/waiver structure.
- CI / pre-merge needs objective blockers for TODO completeness.
- A TODO in `promotion_lane/`, `completed/`, or otherwise claiming `Production-Ready` should be checked before closure claims are trusted.

## Inputs
- A tactical TODO markdown file under `foundation_documentation/todos/**`
- `schemas/todo_validation_bundle.schema.json` (validated by the deterministic validator; not a replacement authority)

## Procedure
1. **Export normalized bundle**
   - Run:
     ```bash
     python3 delphi-ai/tools/todo_validation_bundle_export.py \
       --todo foundation_documentation/todos/<active|promotion_lane|completed>/<lane>/<slug>.md \
       --output foundation_documentation/artifacts/tmp/<slug>-todo-validation-bundle.json
     ```
2. **Run deterministic validator**
   - Run:
     ```bash
     python3 delphi-ai/tools/todo_deterministic_validator.py \
       --todo foundation_documentation/todos/<active|promotion_lane|completed>/<lane>/<slug>.md \
       --bundle-output foundation_documentation/artifacts/tmp/<slug>-todo-validation-bundle.json \
       --report-json foundation_documentation/artifacts/tmp/<slug>-todo-validation-report.json \
       --events-jsonl foundation_documentation/artifacts/metrics/events/rule-events.jsonl
     ```
3. **Interpret the result**
   - `PASS` means the objective fields required by the validator are structurally coherent.
   - `FAIL` means CI or local review should block until the reported fields are corrected.
   - `FAIL` is non-destructive: the validator must not rewrite or delete work; it only blocks and explains.
4. **Keep the Markdown canonical**
   - The exported bundle is derived from the TODO. Do not update the bundle instead of the markdown TODO.

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

## Outputs
- `foundation_documentation/artifacts/tmp/<slug>-todo-validation-bundle.json`
- `foundation_documentation/artifacts/tmp/<slug>-todo-validation-report.json`
- optional `foundation_documentation/artifacts/metrics/events/rule-events.jsonl` entries when PACED metrics are in scope

## Validation
- The validator must produce diagnostic messages that tell the operator exactly what field is missing or invalid and, when the remedy is objective, what needs to be added or corrected.
- The validator may block objective structural failures, but it must not pretend to judge semantics that still require human/LLM review.
- The validator's role is deterministic convergence support, not automatic mutation of the TODO or codebase.
- When event logging is enabled, repeated observations of the same issue must reuse the same episode identity so metrics count one blocker episode rather than inflating per retry.
