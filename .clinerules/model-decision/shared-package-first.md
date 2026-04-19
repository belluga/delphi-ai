---
description: "Model Decision: MUST query proprietary packages via CLI tool before implementing. Three tiers (Local/Ecosystem/External) determine autonomy of change."
globs:
alwaysApply: false
---

# Package-First Verification Gate (Cline)

> **Canonical source:** `rules/core/package-first-model-decision.md`

## Mandatory Action: Query Packages via CLI

Before writing any implementation code, **run the deterministic CLI tool**:

```bash
bash delphi-ai/tools/query_packages.sh --project-root <path> --search "<keyword>"
```

**Do not read YAML files directly.** The CLI is the only interface.

### CLI Options
| Option | Purpose |
| :--- | :--- |
| `--all` | List all proprietary packages |
| `--search <term>` | Search by name or description |
| `--tier local\|ecosystem` | Filter by tier |
| `--stack flutter\|laravel` | Filter by stack |
| `--unused` | Show available but unused local packages |
| `--detail <name>` | Full detail with README content |

## Package Tier Model

| Tier | Autonomy | Behavior |
| :--- | :--- | :--- |
| **Local** (in `packages/`, path dep) | Total | Treat as code. Modify freely, breaking changes OK. |
| **Ecosystem** (Belluga org, VCS/registry dep) | High | Can modify, but version and evaluate cross-project impact. |
| **External** (pub.dev, Packagist, etc.) | Low | Do not modify. Wrap in adapter if needed. |

## When This Activates
- Planning implementation of a new feature, endpoint, domain, or screen.
- Creating a new controller, service, repository, or utility class.
- Adding a dependency or importing a third-party library.
- Refactoring existing code that touches multiple modules.

## Mandatory Steps

1. **Query** packages via CLI: `bash delphi-ai/tools/query_packages.sh --search "<keyword>"`
2. **Read details** for relevant results: `--detail "<package_name>"`
3. **Apply tier-appropriate autonomy:**
   - Local: modify the package directly if its API does not fit. Fix callers in the same PR.
   - Ecosystem: prefer additive extension. Version bump if breaking.
   - External: never modify. Create adapter/wrapper if behavior needs to change.
4. **Record** the Package-First Assessment in the TODO (include query executed and tier classification).
5. **After creating** a new package, run `bash delphi-ai/tools/verify_package_registry.sh` to update local YAML.
6. **If ecosystem-level**, add entry to `delphi-ai/config/ecosystem_packages.yaml`.

## Anti-Patterns (Hard NO)
- Duplicating proprietary package logic in host app code.
- Importing a third-party library when a proprietary package already wraps that capability.
- Creating "utils" or "helpers" in the host app for logic that belongs in a proprietary package.
- **Reading YAML files directly** instead of using the CLI tool.
- Skipping the package query because "it's a small change."
- **Treating a local package as immutable** — creating workarounds in the host app to avoid touching it.
- **Forking an external package** without explicit user approval.

## Companion Rules
- `paced.core.ecosystem-reuse` (Ecosystem Reuse & Abstraction Boundary Mandate)
- `wf-laravel-create-package-method` / `wf-flutter-create-package-method` (Package creation workflows)
