---
description: Add or modify Laravel API endpoints (controller + routes) while honoring the documented route groups, Sanctum abilities, and client contracts defined by Flutter repositories.
---

# Method: Create/Update API Endpoint (Laravel)

## Purpose
Add or modify Laravel API endpoints (controller + routes) while honoring the documented route groups, Sanctum abilities, and client contracts defined by Flutter repositories.

## Triggers
- Flutter repository contract requires a new API or payload change.
- Route groups/middleware need adjustment (tenant vs landlord vs account scope).
- Controller logic must be extracted into services for reuse.

## Inputs
- `foundation_documentation/submodule_laravel-app_summary.md` (routing, middleware, abilities).
- `foundation_documentation/persona_roadmaps.md` (Flutter + Laravel sections) to capture contract changes.
- Existing routes (`routes/api/*.php`) and controller files.
- Sanctum ability definitions / policies.

## Procedure
1. **Persona alignment** – select Laravel Engineer persona, review roadmap items, and note Flutter requirements.
2. **Define contract**
   - Document request/response schema in `foundation_documentation/domain_entities.md` and the Flutter roadmap before coding.
   - If the endpoint is a feed, confirm page-based pagination and decide whether an SSE `/stream` companion is required for deltas.
3. **Route planning**
   - **Separate domain scope from auth scope (do not mix):**
     - Domain decides which route sets are reachable (main domain → landlord; tenant domain → tenant + account).
     - Auth/abilities decide who may access a reachable endpoint (landlord user vs account user).
   - **User access matrix (abilities still required):**
     - Landlord users: landlord + tenant‑admin + tenant‑non‑admin + account routes.
     - Account users: tenant‑non‑admin + account routes only.
   - Choose the correct route file/group (tenant vs landlord vs account route files under `routes/api/`).
   - Tenant‑admin routes live under `/admin/api/v1/...` on tenant domains; tenant‑non‑admin remain `/api/v1/...`.
   - Account routes stay under `/api/v1/accounts/{account_slug}/...` on tenant domains (already admin).
   - Apply middleware stacks (`landlord`, `tenant`, `account`) and ability requirements.
   - **Public vs admin resource split (when applicable):**
     - Public reads should live in tenant‑public routes; admin CRUD stays in tenant‑admin or account routes.
     - If tenant‑admin can create “on behalf of” an account/profile, ensure the owner is explicitly captured and that
       **account‑admin views only their own records** (no cross‑account bleed).
     - When public lists support account filtering, allow both account‑level and profile‑level filters if the domain uses 1:1 profiles.
4. **Controller + service logic**
   - Keep controllers lightweight (validation, request handling). Extract business rules into dedicated services/actions when logic grows.
   - Ensure validation rules enforce the documented bounds (P‑14).
5. **Sanctum + policies**
   - Update abilities/policies if new permissions are required. Document them in the Laravel summary.
6. **Tests**
   - Add/extend feature tests covering happy paths, validation errors, and ability checks.
   - If public reads exist, add tests that private entities never leak into public routes.
   - If “create on behalf” is supported, add tests proving items appear only in the target account’s admin scope.
7. **Documentation + roadmap sync**
   - Update the Flutter roadmap with the new contract and note any client updates needed.
   - Record changes in the Laravel submodule summary (routes, controllers, permissions).
   - If SSE was added, document event types + minimal payloads in `foundation_documentation/endpoints_mvp_contracts.md`.
8. **Verification**
   - Run `composer test` or targeted suites; optionally hit endpoints via Postman/cURL or contract tests.

## Outputs
- Updated routes, controllers, services, validation rules, and tests.
- Roadmap entries communicating API availability to Flutter.
- Laravel submodule summary reflecting the new endpoint.

## Validation
- Tests pass and manual endpoint checks succeed.
- Flutter roadmap acknowledges the new contract so clients can adopt it.
