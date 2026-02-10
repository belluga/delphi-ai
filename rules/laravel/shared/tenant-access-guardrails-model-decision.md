---
trigger: model_decision
description: "When adding or modifying tenant-authenticated API routes, enforce CheckTenantAccess on all auth:sanctum tenant routes."
---

## Rule
When changing tenant API routes that require authentication, ensure `CheckTenantAccess` is present for every tenant-authenticated route. Do not apply tenant access checks to account-only routes.

## Rationale
Tenant-authenticated routes must enforce tenant access to prevent cross-tenant leakage. Account routes have separate guardrails and should remain distinct.

## Signals for Activation
- Editing `routes/api/tenant_api_v1.php` (or equivalent tenant route files).
- Adding or modifying `auth:sanctum` tenant routes.

## Enforcement
- Verify each tenant-authenticated route includes `CheckTenantAccess`.
- Add or update tests to cover cross-tenant denial (403) and account-token denial.

## Notes
Use the workflow `delphi-ai/workflows/laravel/tenant-access-guardrails.md`.
