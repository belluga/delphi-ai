---
name: wf-docker-todo-lane-framing-method
description: "Workflow phase: classify the TODO lane and decide whether feature framing is required before tactical TODO execution."
---

# Method: TODO Lane and Framing

Use for the first TODO-driven phase. Canonical details live in `workflows/docker/todo-lane-framing-method.md`.

## Responsibilities
- Classify `Profile-Scoped Capped TODO`, `Operational Micro-Fix`, `Maintenance/Regression Fix`, or `Tactical TODO`.
- Decide whether pre-TODO feature framing is required.
- Create or update the governing TODO only when the lane requires one.

## Outputs
- Lane classification and rationale.
- Feature brief when needed.
- Tactical or ephemeral TODO ready for refinement, or a validated micro-fix path.

## Non-Negotiables
- No implementation before lane classification.
- No tactical TODO that bundles multiple independent story slices.
