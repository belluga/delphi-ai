---
name: wf-laravel-create-package-method
description: "Workflow: MUST use whenever creating or refactoring Laravel packages. Establish package boundaries with contracts/adapters, remove app wrappers, and run mandatory decoupling assertions plus full-suite validation before completion."
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
- Host provider path (typically `app/Providers/AppServiceProvider.php`).
- Multitenancy config path (`config/multitenancy.php`) and migration directories.
- Active tactical TODO scope + DoD (when project docs/code are in scope).

## Procedure
1. Classify package integration mode.
- `self-contained`: package owns dependencies internally.
- `host-integrated`: package needs host app data/services via contracts.

2. Classify multitenancy data scope before coding.
- Choose one: `tenant`, `landlord`, or `mixed`.
- Record where each migration directory belongs:
  - tenant path: `packages/<vendor>/<package>/database/migrations`
  - landlord path: `packages/<vendor>/<package>/database/migrations_landlord` (if needed)
- Wire migration execution accordingly:
  - tenant paths must be included in `config/multitenancy.php` `tenant_migration_paths`
  - landlord paths run only with landlord connection/path
- In tenant-isolated DB flows (Spatie context switching), do not model `tenant_id` inside tenant-scoped collections unless there is an explicit approved exception.

3. Establish the boundary.
- Keep package logic in `packages/<vendor>/<package>/src/**`.
- Keep host implementations in `app/Integration/**` and listeners/jobs in `app/Listeners/**` + `app/Jobs/**`.
- Do not keep direct host-model/service coupling inside package internals.

4. Define contracts for host-integrated dependencies.
- Add interfaces in `src/Contracts/**`.
- Bind fail-fast placeholders in package service provider for host-required contracts.

5. Wire host adapters/listeners.
- Bind contracts to adapters in host provider.
- Subscribe host listeners to package domain events.
- Route side effects through queue/jobs after persistence boundary.

6. Remove transitional wrappers.
- Replace route/schedule/use-sites to reference package classes directly once parity is validated.
- Delete app wrappers that only extend package classes.

7. Add or update tests.
- Binding test: package contracts resolve to host adapters.
- Side-effect test: lifecycle events dispatch expected jobs.
- Keep external API behavior tests intact.

8. Run decoupling assertions.
- Execute:

```bash
python3 delphi-ai/skills/wf-laravel-create-package-method/scripts/assert_package_decoupling.py \
  --package-dir /abs/path/to/laravel-app/packages/vendor/package \
  --app-dir /abs/path/to/laravel-app/app \
  --app-provider /abs/path/to/laravel-app/app/Providers/AppServiceProvider.php \
  --check-host-bindings
```

9. Run validation gate.
- Run targeted tests for touched package flows.
- Run full Laravel suite (`php artisan test`) as final gate for important milestones.

## Validation
- No direct `App\\...` references in package `src/**`.
- No app wrappers extending target package namespace.
- Host-required contracts are bound in host provider.
- Package migration scope is explicitly classified as `tenant`, `landlord`, or `mixed`.
- Tenant migration paths are wired in `config/multitenancy.php` when tenant scope is used.
- Landlord migrations are isolated from tenant migration paths.
- Targeted tests pass.
- Full Laravel suite passes.

## Output
- Decoupled package with explicit contracts/adapters boundaries.
- Side effects routed by package events + host listeners/jobs.
- Transitional wrappers removed.
- Validation evidence recorded.
