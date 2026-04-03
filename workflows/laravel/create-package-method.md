---
description: Create or refactor Laravel packages with explicit contract boundaries, faithful package README coverage, host adapters, and mandatory decoupling assertions before completion.
---

# Workflow: Create or Refactor Laravel Package

## Purpose
Create or refactor a Laravel package so package internals remain decoupled from host app implementation details while preserving behavior.

## Triggers
- New package under `packages/**`.
- Existing package refactor to remove coupling with `App\\...` internals.
- Host wrappers in `app/**` that only extend package classes.
- Domain side effects that should move to package events + host listeners/jobs.

## Inputs
- Target package path (`packages/<vendor>/<package>`).
- Host providers path (use `app/Providers/AppServiceProvider.php` or scan `app/Providers/**`).
- Multitenancy config path (`config/multitenancy.php`) and migration directories.
- Package architecture registry path (`scripts/package_architecture_registry.php`).
- Active tactical TODO scope + DoD (when project docs/code are in scope).

## Procedure
1. Classify package integration mode.
- `self-contained`: package owns dependencies internally.
- `host-integrated`: package needs host app data/services via contracts.
- `shared-kernel`: package exposes reusable contracts/registries and host/domain code extends it without direct package-to-package imports.

2. Classify route ownership before coding and record both classifications in `scripts/package_architecture_registry.php`.
- `host-owned-routes`: host app registers host-facing route files; package must not call `loadRoutesFrom(...)` or keep package route files.
- `package-owned-routes`: package may call `loadRoutesFrom(...)`, but route files may only use approved alias/config strings or package-local middleware, never `App\\Http\\Middleware\\...`.
- For Belluga-style `host-integrated` and `shared-kernel` packages, prefer and enforce `host-owned-routes`.

3. Classify multitenancy data scope before coding.
- Choose one: `tenant`, `landlord`, or `mixed`.
- Record where each migration directory belongs:
  - tenant path: `packages/<vendor>/<package>/database/migrations`
  - landlord path: `packages/<vendor>/<package>/database/migrations_landlord` (if needed)
- Wire migration execution accordingly:
  - tenant paths must be included in `config/multitenancy.php` `tenant_migration_paths`
  - landlord paths run only with landlord connection/path
- In tenant-isolated DB flows (Spatie context switching), do not model `tenant_id` inside tenant-scoped collections unless there is an explicit approved exception.

4. Establish the boundary.
- Keep package logic in `packages/<vendor>/<package>/src/**`.
- Keep host implementations in `app/Integration/**` and listeners/jobs in `app/Listeners/**` + `app/Jobs/**`.
- Do not keep direct host-model/service coupling inside package internals.

5. Define contracts for host-integrated dependencies.
- Add interfaces in `src/Contracts/**`.
- Bind fail-fast placeholders in package service provider for host-required contracts.

6. Wire host adapters/listeners.
- Bind contracts to adapters in dedicated host integration providers under `app/Providers/**`.
- Subscribe host listeners to package domain events.
- Route side effects through queue/jobs after persistence boundary.
- Keep `AppServiceProvider.php` package-agnostic.

7. Remove transitional wrappers.
- Replace route/schedule/use-sites to reference package classes directly once parity is validated.
- Delete app wrappers that only extend package classes.

8. Add or update tests.
- Binding test: package contracts resolve to host adapters.
- Side-effect test: lifecycle events dispatch expected jobs.
- Keep external API behavior tests intact.

9. Create or update package README.
- Required location: `packages/<vendor>/<package>/README.md`.
- README must be faithful and complete enough for a new AI engineer to understand package behavior without guessing hidden rules.
- Minimum required sections:
  - Purpose and bounded scope.
  - Domain concepts and invariants.
  - Data model and migration scope (`tenant|landlord|mixed`) plus index/collection notes when relevant.
  - Public contracts (routes/endpoints, request/response shapes, domain events, commands/queries).
  - Authentication and authorization boundary:
    - what the package requires (`request()->user()`, identity fields, etc.),
    - what the host must provide (middleware, guards, tenant access checks, ability gates),
    - what the package intentionally does not own.
  - Host integration guide (providers, bindings, adapters/listeners/jobs).
  - Validation commands and expected test gates.
  - Known limitations and explicit non-goals.
- README must match implemented code contracts; stale or aspirational docs are non-adherent.

10. Run decoupling assertions.
- Execute:

```bash
python3 delphi-ai/skills/wf-laravel-create-package-method/scripts/assert_package_decoupling.py \
  --package-dir /abs/path/to/laravel-app/packages/vendor/package \
  --app-dir /abs/path/to/laravel-app/app \
  --app-provider /abs/path/to/laravel-app/app/Providers/AppServiceProvider.php \
  --check-host-bindings
```

11. Run architecture guardrail gate.
- Execute `composer run architecture:guardrails`.
- Confirm the package is registered in `scripts/package_architecture_registry.php`.
- Confirm `package-owned-routes` files do not import `App\\Http\\Middleware\\...`.
- Confirm `host-owned-routes` packages do not call `loadRoutesFrom(...)`.

12. Run validation gate.
- Run targeted tests for touched package flows.
- Run full Laravel suite (`php artisan test`) as final gate for important milestones.

## Validation
- No direct `App\\...` references in package `src/**`.
- No app wrappers extending target package namespace.
- Host-required contracts are bound in host provider.
- Package-related bindings/listeners/settings registrars do not drift back into `AppServiceProvider.php`.
- Package is declared in `scripts/package_architecture_registry.php` with valid `integration_mode` and `route_ownership`.
- `package-owned-routes` use middleware aliases/strings or package-local middleware only.
- `host-owned-routes` packages do not ship package route files or call `loadRoutesFrom(...)`.
- Package migration scope is explicitly classified as `tenant`, `landlord`, or `mixed`.
- Tenant migration paths are wired in `config/multitenancy.php` when tenant scope is used.
- Landlord migrations are isolated from tenant migration paths.
- Package root contains `README.md` with the required sections and explicit auth boundary ownership.
- README contract details are aligned with implemented behavior/routes and host integration responsibilities.
- `composer run architecture:guardrails` passes.
- Targeted tests pass.
- Full Laravel suite passes.

## Output
- Decoupled package with explicit contracts/adapters boundaries.
- Faithful package README that captures contracts, auth boundaries, integration steps, and usage.
- Side effects routed by package events + host listeners/jobs.
- Transitional wrappers removed.
- Validation evidence recorded.
