---
name: wf-laravel-tenant-access-guardrails
description: "Workflow: MUST use whenever the scope matches this purpose: Ensure any tenant-authenticated API routes consistently enforce tenant access via `CheckTenantAccess` and keep auth boundaries explicit."
---

# Workflow: Tenant Access Guardrails

## Purpose
Ensure any tenant-authenticated API routes consistently enforce tenant access via `CheckTenantAccess` and keep auth boundaries explicit.

## Preconditions
- Laravel scope (routes/middleware changes).
- Related rules loaded:
  - `delphi-ai/rules/laravel/shared/core-instructions-always-on.md`
  - `delphi-ai/rules/laravel/shared/todo-driven-execution-model-decision.md`
  - `delphi-ai/rules/laravel/shared/tenant-access-guardrails-model-decision.md`

## Steps
1. Identify the target tenant route file(s) (ex: `laravel-app/routes/api/tenant_api_v1.php`) and confirm they are only registered under the **tenant domain group** (never on the main domain).
2. List all routes that are authenticated with `auth:sanctum` in tenant scope.
3. Ensure each authenticated tenant route includes `CheckTenantAccess` in its middleware stack.
4. Confirm account-scoped routes continue to use `account` middleware (and not tenant guards).
5. Update or add tests that verify:
   - Cross-tenant access returns 403 for landlord tokens without tenant access.
   - Account tokens cannot access tenant routes.
   - Tenant routes are unreachable on the main domain (domain scoping is enforced).
6. Note changes in the active tactical TODO and ensure DoD remains aligned.

## Outputs
- Tenant route files updated with `CheckTenantAccess` for authenticated endpoints.
- Tests that confirm tenant access guardrails.

## Validation
- Run `php artisan test` or the relevant API suites.
- Verify cross-tenant access is denied (403) where expected.
