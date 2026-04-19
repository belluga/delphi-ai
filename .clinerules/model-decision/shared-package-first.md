---
description: "Model Decision: MUST verify packages across three tiers (Local/Ecosystem/External) by reading two YAML files before implementing. Tier determines autonomy of change."
globs:
alwaysApply: false
---

# Package-First Verification Gate (Cline)

> **Canonical source:** `rules/core/package-first-model-decision.md`

## Runtime Sources

The agent reads **two YAML files** to identify proprietary packages:

| File | Scope |
| :--- | :--- |
| `delphi-ai/config/ecosystem_packages.yaml` | Ecosystem (Global) — published for cross-project reuse |
| `foundation_documentation/local_packages.yaml` | Local (Project-Bound) — auto-generated from `packages/` dirs |

## Package Tier Model

| Tier | Autonomy | Source of Truth | Behavior |
| :--- | :--- | :--- | :--- |
| **Local** (in `packages/`, path dep) | Total | `local_packages.yaml` | Treat as code. Modify freely, breaking changes OK. |
| **Ecosystem** (Belluga org, VCS/registry dep) | High | `ecosystem_packages.yaml` | Can modify, but version and evaluate cross-project impact. |
| **External** (pub.dev, Packagist, etc.) | Low | Stack manifests | Do not modify. Wrap in adapter if needed. |

## When This Activates
- Planning implementation of a new feature, endpoint, domain, or screen.
- Creating a new controller, service, repository, or utility class.
- Adding a dependency or importing a third-party library.
- Refactoring existing code that touches multiple modules.

## Mandatory Steps

1. **Read** `delphi-ai/config/ecosystem_packages.yaml` — identify ecosystem packages.
2. **Read** `foundation_documentation/local_packages.yaml` — identify local packages.
   - If missing, run: `bash delphi-ai/tools/verify_package_registry.sh --project-root <path>`
3. **Interpret fields:**
   - Ecosystem YAML: every entry is a published proprietary package.
   - Local YAML: `in_use: true` → **use directly**. `in_use: false` → **recommend adoption**.
4. **Read the README** of each relevant package to understand its API.
5. **Apply tier-appropriate autonomy:**
   - Local: modify the package directly if its API does not fit. Fix callers in the same PR.
   - Ecosystem: prefer additive extension. Version bump if breaking.
   - External: never modify. Create adapter/wrapper if behavior needs to change.
6. **Record** the Package-First Assessment in the TODO (include tier classification).
7. **After creating** a new package, run `bash delphi-ai/tools/verify_package_registry.sh` to update `local_packages.yaml`.
8. **If ecosystem-level**, add entry to `delphi-ai/config/ecosystem_packages.yaml`.

## Anti-Patterns (Hard NO)
- Duplicating proprietary package logic in host app code.
- Importing a third-party library when a proprietary package already wraps that capability.
- Creating "utils" or "helpers" in the host app for logic that belongs in a proprietary package.
- Skipping YAML consultation because "it's a small change."
- **Treating a local package as immutable** — creating workarounds in the host app to avoid touching it.
- **Forking an external package** without explicit user approval.

## Companion Rules
- `paced.core.ecosystem-reuse` (Ecosystem Reuse & Abstraction Boundary Mandate)
- `wf-laravel-create-package-method` / `wf-flutter-create-package-method` (Package creation workflows)
