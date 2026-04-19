---
description: "Model Decision: MUST verify the Package & Library Registry before implementing any new feature, endpoint, domain, screen, controller, service, or repository. Prevents architectural drift by ensuring agents extend existing packages instead of creating parallel implementations."
globs:
alwaysApply: false
---

# Package-First Verification Gate (Cline)

> **Canonical source:** `rules/core/package-first-model-decision.md`

## When This Activates
- Planning implementation of a new feature, endpoint, domain, or screen.
- Creating a new controller, service, repository, or utility class.
- Adding a dependency or importing a third-party library.
- Refactoring existing code that touches multiple modules.

## Mandatory Steps

1. **Read** `foundation_documentation/package_registry.md` before writing implementation code.
2. **Search** for packages/libraries whose purpose overlaps with the planned work.
3. **Decide:** Extend existing package / Create new package / Local implementation.
4. **Record** the Package-First Assessment in the TODO.
5. **Register** any new package/library in the registry after creation.

## Anti-Patterns (Hard NO)
- Duplicating package logic in host app code.
- Importing a third-party library when an internal package already wraps that capability.
- Creating "utils" or "helpers" in the host app for logic that belongs in a core package.
- Skipping registry consultation because "it's a small change."

## Companion Rules
- `paced.core.ecosystem-reuse` (Ecosystem Reuse & Abstraction Boundary Mandate)
- `wf-laravel-create-package-method` (Package creation workflow)
