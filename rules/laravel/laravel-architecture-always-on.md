---
activation_mode: always_on
summary: Enforce Laravel/API architectural tenets across all tasks.
---

## Rule
Apply these Laravel architectural tenets on every task:
- Preserve documented route groups and middleware (ingress parity): `/api/v1/initialize` (guest), `/admin/api/v1` (landlord), `/api/v1` (tenant), `/api/v1/accounts/{account_slug}` (tenant+account). Keep ingress definitions in sync.
- Maintain the tenant resolution chain (`DomainTenantFinder` → `SwitchMongoTenantDatabaseTask`) before touching tenant data.
- Enforce stateless auth with Sanctum abilities; expand abilities only with documented contracts and Flutter alignment.
- Keep controllers thin; move business logic into services. Reuse service layers when adding endpoints.
- Align payloads/contracts with Flutter expectations; any change requires roadmap updates.

## Rationale
These tenets guard multitenancy, routing consistency, security, and client alignment. Enforcing them globally prevents drift across API work.

## Enforcement
- Validate routes against documented groups and ingress manifests.
- Reject controllers that embed business logic; require service refactors.
- Require Sanctum ability checks and documentation for new scopes.
- Ensure Flutter/API contract sync (roadmap + docs) accompanies payload changes.

## Notes
Reference `system_architecture_principles.md` Appendix B and `foundation_documentation/submodule_laravel-app_summary.md` for live snapshots.
