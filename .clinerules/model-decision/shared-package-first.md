---
description: "Model Decision: MUST verify packages across three tiers (Local/Ecosystem/External) before implementing. Tier determines autonomy of change."
globs:
alwaysApply: false
---

# Package-First Verification Gate (Cline)

> **Canonical source:** `rules/core/package-first-model-decision.md`

## Package Tier Model

| Tier | Autonomy | Behavior |
| :--- | :--- | :--- |
| **Local** (in `packages/`, path dep) | Total | Treat as code. Modify freely, breaking changes OK. |
| **Ecosystem** (Belluga org repo, VCS dep) | High | Can modify, but version and evaluate cross-project impact. |
| **External** (pub.dev, Packagist, etc.) | Low | Do not modify. Wrap in adapter if needed. |

## When This Activates
- Planning implementation of a new feature, endpoint, domain, or screen.
- Creating a new controller, service, repository, or utility class.
- Adding a dependency or importing a third-party library.
- Refactoring existing code that touches multiple modules.

## Mandatory Steps

1. **Read** the auto-generated checklist at `foundation_documentation/package_registry.md`.
2. **Review all three sections:** Ecosystem (Global), Local Laravel, Local Flutter.
3. **Interpret checkboxes:**
   - `[x]` = in use — **use directly**. Read the package README to understand its API.
   - `[ ]` = available but not in use — **recommend adoption**. Read the README to evaluate fit.
4. **Apply tier-appropriate autonomy:**
   - Local: modify the package directly if its API does not fit. Fix callers in the same PR.
   - Ecosystem: prefer additive extension. Version bump if breaking.
   - External: never modify. Create adapter/wrapper if behavior needs to change.
5. **Record** the Package-First Assessment in the TODO (include tier classification).
6. **After creating** a new package, run `bash delphi-ai/tools/verify_package_registry.sh` to update the checklist.

## Anti-Patterns (Hard NO)
- Duplicating proprietary package logic in host app code.
- Importing a third-party library when a proprietary package already wraps that capability.
- Creating "utils" or "helpers" in the host app for logic that belongs in a proprietary package.
- Skipping checklist consultation because "it's a small change."
- **Treating a local package as immutable** — creating workarounds in the host app to avoid touching it.
- **Forking an external package** without explicit user approval.

## Companion Rules
- `paced.core.ecosystem-reuse` (Ecosystem Reuse & Abstraction Boundary Mandate)
- `wf-laravel-create-package-method` / `wf-flutter-create-package-method` (Package creation workflows)
