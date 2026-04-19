# Package & Library Registry

> **Authority:** PACED Core Architecture — `paced.core.package-first`
>
> This document is the **Single Source of Truth** for all reusable packages and libraries in this project. Every agent must consult this registry before implementing new functionality. If a capability already exists here, the agent must extend or integrate the existing package rather than creating an alternative implementation.

## How to Use This Registry

1. **Before planning any feature**, search this document for keywords related to the capability you need.
2. **If a matching package exists**, read its README and extend it. Do not create parallel implementations in the host app.
3. **If no matching package exists**, evaluate whether the new code should become a package (see Extraction Criteria below).
4. **After creating a new package or library**, register it here immediately. An unregistered package is a governance violation.

## Extraction Criteria

A capability should be extracted into a package or library when it meets **two or more** of the following conditions:

- It is credibly reusable across projects in the PACED ecosystem.
- It encapsulates a bounded domain concept with clear contracts.
- It has no dependency on host-specific tenant model, auth, or product posture.
- It has been validated in at least one real usage context (no premature abstraction).

---

## Laravel Packages

Packages located under `laravel-app/packages/<vendor>/<package>/`.

| Package | Vendor | Purpose | Integration Mode | Route Ownership | Data Scope | README |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `example-package` | `belluga` | _Brief description of what this package does_ | `host-integrated` | `host-owned-routes` | `tenant` | `packages/belluga/example-package/README.md` |

### Integration Mode Reference

| Mode | Description |
| :--- | :--- |
| `self-contained` | Package owns all dependencies internally; no host bindings needed |
| `host-integrated` | Package needs host app data/services via contracts (interfaces) |
| `shared-kernel` | Package exposes reusable contracts/registries; host/domain code extends it |

---

## Flutter Libraries

Libraries and core modules within the Flutter app. This includes both local packages under `flutter-app/packages/` and shared core modules under `flutter-app/lib/core/` or equivalent.

| Library | Location | Purpose | Public API | Depends On | README |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `example_lib` | `packages/example_lib/` | _Brief description_ | `ExampleService`, `ExampleModel` | `core_network` | `packages/example_lib/README.md` |

### Flutter Library Categories

| Category | Location Pattern | Description |
| :--- | :--- | :--- |
| `core` | `lib/core/**` or `packages/core_*/` | Foundation utilities: networking, auth, storage, logging |
| `feature` | `packages/<feature>_*/` or `lib/features/<feature>/` | Feature-specific reusable logic extracted from screens |
| `shared` | `packages/shared_*/` | Cross-feature contracts, models, and UI components |
| `infra` | `packages/infra_*/` | Infrastructure adapters: APIs, databases, device services |

---

## Shared Contracts (Cross-Stack)

Contracts, DTOs, or schemas that must remain aligned between Laravel and Flutter.

| Contract | Laravel Location | Flutter Location | Sync Mechanism | Last Verified |
| :--- | :--- | :--- | :--- | :--- |
| `ExampleDTO` | `packages/belluga/example/src/DTOs/` | `packages/example_lib/lib/models/` | Manual / API contract tests | `YYYY-MM-DD` |

---

## Registry Maintenance Rules

1. **Every new package or library** must be added to this registry within the same TODO that creates it.
2. **Every package must have a README.md** at its root with the sections defined in `wf-laravel-create-package-method` (Laravel) or equivalent Flutter documentation standard.
3. **Stale entries** (packages that were removed or renamed) must be marked as `DEPRECATED` with a pointer to the replacement, not silently deleted.
4. **Quarterly audit**: During project health reviews, verify that all entries in this registry match the actual codebase. Use `delphi-ai/tools/verify_package_registry.sh` when available.

---

## Changelog

| Date | Author | Change |
| :--- | :--- | :--- |
| `YYYY-MM-DD` | `<agent or human>` | Initial registry creation |
