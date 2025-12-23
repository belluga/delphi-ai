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
   - Choose the correct route file/group (tenant vs landlord vs account route files under `routes/api/`).
   - Apply middleware stacks (`landlord`, `tenant`, `account`) and ability requirements.
4. **Controller + service logic**
   - Keep controllers lightweight (validation, request handling). Extract business rules into dedicated services/actions when logic grows.
   - Ensure validation rules enforce the documented bounds (P‑14).
5. **Sanctum + policies**
   - Update abilities/policies if new permissions are required. Document them in the Laravel summary.
6. **Tests**
   - Add/extend feature tests covering happy paths, validation errors, and ability checks.
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
