---
name: wf-flutter-create-package-method
description: "Workflow: Create or refactor Flutter packages/libraries under packages/ with canonical README, proper exports, and checklist consolidation."
---

# Skill: Create or Refactor Flutter Package/Library

## Purpose
Guide the creation or refactoring of Flutter packages following the proprietary package-first architecture.

## When to Invoke
- Creating a new Flutter package under `packages/`.
- Extracting reusable logic from `lib/` into a new package.
- Package-First Assessment decision is "Create new package."

## Procedure
Follow the canonical workflow at `workflows/flutter/create-package-method.md`.

Key steps:
1. Classify package category (core/feature/shared/infra).
2. Create package structure with barrel export.
3. Implement, keeping host app decoupled.
4. Add tests.
5. Declare in root `pubspec.yaml`.
6. Create canonical README from `delphi-ai/templates/package_readme_template.md`.
7. Run validation (`flutter analyze` + tests + host build).
8. **Consolidate:** run `bash delphi-ai/tools/verify_package_registry.sh` to update the checklist.

## Validation
- Package appears in `bash delphi-ai/tools/query_packages.sh --detail "<name>"` output.
- README follows canonical template.
- No host app references inside package code.
