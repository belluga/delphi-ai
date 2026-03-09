---
trigger: model_decision
description: "When adding or modifying tenant-authenticated API routes, enforce CheckTenantAccess on all auth:sanctum tenant routes."
---

## Rule
When changing tenant API routes that require authentication:
- ensure `CheckTenantAccess` is present for every tenant-authenticated route;
- do not apply tenant access checks to account-only routes;
- validate route matrix correctness (`tenant host` vs `main host`) for `/admin/api/v1` and `/api/v1` scopes;
- if a route group uses `Route::domain('{...}')`, verify controller signatures include domain parameters before path parameters.

## Rationale
Tenant-authenticated routes must enforce tenant access to prevent cross-tenant leakage. Account routes have separate guardrails and should remain distinct.

## Signals for Activation
- Editing `routes/api/tenant_api_v1.php` (or equivalent tenant route files).
- Adding or modifying `auth:sanctum` tenant routes.
- Editing package routes that register tenant endpoints under shared prefixes (example: `/admin/api/v1`).

## Enforcement
- Verify each tenant-authenticated route includes `CheckTenantAccess`.
- Add or update tests to cover cross-tenant denial (403) and account-token denial.
- Add route reachability/isolation tests for `tenant host` and `main host`.
- Add at least one real login-token test path (login -> bearer token -> tenant-admin endpoint).

## Notes
Use the workflow `delphi-ai/workflows/laravel/tenant-access-guardrails.md`.
