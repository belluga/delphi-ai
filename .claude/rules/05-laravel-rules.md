---
description: "Laravel stack rules — ability catalog sync, settings kernel PATCH contract, tenant access guardrails, and domain resolution testing"
globs: ["laravel-app/**"]
alwaysApply: false
---

# Laravel Stack Rules

## Ability Catalog Sync

When introducing or changing Laravel ability strings (routes, settings namespaces, policies, guards):

- Register the ability in `config/abilities.php` when wildcard expansion (`*`) is used.
- Keep route/policy/settings ability names synchronized.
- Verify at least one login-token path for the protected endpoint.

## Settings Kernel PATCH Contract

For `/settings/values/{namespace}` PATCH endpoints:

- Use direct field-presence semantics.
- Nested fields use dot-path keys (for example `default_origin.lat`).
- Envelope wrappers (for example `{namespace: {...}}`) are rejected unless a documented exception exists.

## Tenant Access Guardrails

When adding or modifying tenant-authenticated API routes, enforce `CheckTenantAccess` on all `auth:sanctum` tenant routes. Document tenant resolution strategy and verify access control at the middleware level.

## Domain Resolution Testing

When tenant resolution tests are added or modified, separate web host/domains from mobile app-domain resolution. Ensure test coverage for both resolution paths and document the distinction.

## Enforcement

- Block ability string changes that skip `config/abilities.php` registration.
- Block PATCH endpoints that use envelope wrappers without documented exception.
- Block tenant routes without `CheckTenantAccess` middleware.
- Require domain resolution tests to cover both web and mobile paths.
