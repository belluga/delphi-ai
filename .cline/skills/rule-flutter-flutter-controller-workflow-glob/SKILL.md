---
name: rule-flutter-flutter-controller-workflow-glob
description: "Rule: MUST use whenever the scope matches this purpose: Apply the controller workflow whenever controller files are edited."
---

## Rule
When working inside `flutter-app/lib/presentation/**/controllers/**`, run the Controller Workflow:
- Controllers own StreamValue state, UI controllers, and orchestration; they never accept `BuildContext`.
- Register controllers via ModuleScope/GetIt and document responsibilities.
- Ensure a stable full-workspace VS Code Problems bridge snapshot and tests cover new behaviour; do not start a CLI analyzer locally.

## Rationale
Controllers enforce the separation between UI and domain logic. The workflow keeps every controller aligned with architecture tenets.

## Enforcement
- Run the Controller Workflow checklist for any edits to these paths.
- PRs must show the stable full-workspace Problems bridge snapshot and test evidence when controller logic changes.

## Notes
Workflow reference: `delphi-ai/workflows/flutter/create-controller-method.md`.
