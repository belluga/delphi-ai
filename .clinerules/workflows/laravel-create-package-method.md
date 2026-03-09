---
name: laravel-create-package-method
description: "Create/refactor Laravel packages with strict package-host decoupling and validation gates."
---

# Workflow: Create or Refactor Laravel Package

## Purpose
Ensure Laravel package work preserves host/package boundaries, contract ownership, and test coverage.

## Steps

1. Classify package mode:
- `self-contained`
- `host-integrated`
2. Define migration scope (`tenant|landlord|mixed`) and wire migration paths correctly.
3. Keep package internals in `packages/<vendor>/<package>/src/**`; keep host adapters/listeners in host app folders.
4. Add package contracts and bind host adapters explicitly.
5. Remove transitional wrappers once parity is validated.
6. Add/update tests for bindings, event side effects, and behavior parity.
7. Run decoupling assertion script:

```bash
python3 delphi-ai/skills/wf-laravel-create-package-method/scripts/assert_package_decoupling.py \
  --package-dir /abs/path/to/laravel-app/packages/vendor/package \
  --app-dir /abs/path/to/laravel-app/app \
  --app-provider /abs/path/to/laravel-app/app/Providers/AppServiceProvider.php \
  --check-host-bindings
```

8. Run targeted tests and full Laravel suite for milestone completion.

## Validation

- No direct `App\\...` references inside package `src/**`.
- Host contracts/adapters are explicitly wired.
- Migration scope is explicit and correctly configured.
- Decoupling assertions pass.
- Test gates pass.
