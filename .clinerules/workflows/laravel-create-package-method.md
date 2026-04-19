---
name: laravel-create-package-method
description: "Create/refactor Laravel packages with strict package-host decoupling, faithful README coverage, and validation gates."
---

# Workflow: Create or Refactor Laravel Package

## Purpose
Ensure Laravel package work preserves host/package boundaries, contract ownership, and test coverage.

## Steps

1. Classify package mode:
- `self-contained`
- `host-integrated`
- `shared-kernel`
2. Classify route ownership and update `scripts/package_architecture_registry.php`:
- `host-owned-routes`
- `package-owned-routes`
3. For Belluga-style `host-integrated` and `shared-kernel` packages, prefer and enforce `host-owned-routes`.
4. For `host-owned-routes`, keep route registration in the host app and do not call `loadRoutesFrom(...)`.
5. For `package-owned-routes`, allow only middleware aliases/config strings or package-local middleware in package route files; never import `App\\Http\\Middleware\\...`.
6. Define migration scope (`tenant|landlord|mixed`) and wire migration paths correctly.
7. Keep package internals in `packages/<vendor>/<package>/src/**`; keep host adapters/listeners in host app folders.
8. Add package contracts and bind host adapters explicitly in dedicated host integration providers under `app/Providers/**`.
9. Keep `AppServiceProvider.php` package-agnostic.
10. Remove transitional wrappers once parity is validated.
11. Add/update tests for bindings, event side effects, and behavior parity.
12. Create or update package README at `packages/<vendor>/<package>/README.md` with, at minimum:
- Purpose/scope
- Domain concepts + invariants
- Data model + migration scope
- Public contracts (routes/payloads/events/commands)
- Authentication/authorization boundary (package requirements vs host responsibilities)
- Host integration steps (providers/bindings/adapters/listeners)
- Validation commands and known limitations
13. Run decoupling assertion script:

```bash
python3 delphi-ai/skills/wf-laravel-create-package-method/scripts/assert_package_decoupling.py \
  --package-dir /abs/path/to/laravel-app/packages/vendor/package \
  --app-dir /abs/path/to/laravel-app/app \
  --app-provider /abs/path/to/laravel-app/app/Providers/AppServiceProvider.php \
  --check-host-bindings
```

14. Run `composer run architecture:guardrails`.
15. Run targeted tests and full Laravel suite for milestone completion.
16. Consolidate in proprietary packages checklist:
- Run `bash delphi-ai/tools/verify_package_registry.sh --project-root <path>` to regenerate `foundation_documentation/package_registry.md`.
- Verify the new package appears with correct checkbox status.
- Mandatory for both local project packages and ecosystem-wide packages.

## Validation

- No direct `App\\...` references inside package `src/**`.
- Package is declared in `scripts/package_architecture_registry.php`.
- `package-owned-routes` do not import `App\\Http\\Middleware\\...`.
- `host-owned-routes` do not call `loadRoutesFrom(...)`.
- Host contracts/adapters are explicitly wired.
- `AppServiceProvider.php` remains package-agnostic.
- Migration scope is explicit and correctly configured.
- Package root contains faithful `README.md` aligned with implemented contracts and auth boundary ownership.
- Decoupling assertions pass.
- Architecture guardrails pass.
- Test gates pass.
- Package appears in `foundation_documentation/package_registry.md` checklist.
