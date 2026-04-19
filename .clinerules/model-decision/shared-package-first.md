---
description: "Model Decision: MUST verify proprietary packages checklist before implementing any new feature, endpoint, domain, screen, controller, service, or repository. Prevents architectural drift by ensuring agents use or recommend existing proprietary packages."
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

1. **Read** the auto-generated checklist at `foundation_documentation/package_registry.md`.
2. **Interpret checkboxes:**
   - `[x]` = in use — **use directly**. Read the package README to understand its API.
   - `[ ]` = available but not in use — **recommend adoption**. Read the README to evaluate fit.
3. **Read the README** of each relevant proprietary package to understand capabilities.
4. **Decide:** Use existing / Adopt available / Extend / Create new package / Local implementation.
5. **Record** the Package-First Assessment in the TODO.
6. **After creating** a new package, run `bash delphi-ai/tools/verify_package_registry.sh` to update the checklist.

## Anti-Patterns (Hard NO)
- Duplicating proprietary package logic in host app code.
- Importing a third-party library when a proprietary package already wraps that capability.
- Creating "utils" or "helpers" in the host app for logic that belongs in a proprietary package.
- Skipping checklist consultation because "it's a small change."

## Companion Rules
- `paced.core.ecosystem-reuse` (Ecosystem Reuse & Abstraction Boundary Mandate)
- `wf-laravel-create-package-method` (Package creation workflow)
