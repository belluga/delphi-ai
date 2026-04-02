---
name: wf-laravel-create-api-endpoint-method
description: "Workflow: MUST use whenever the scope matches this purpose: Add or modify Laravel API endpoints (controller + routes) while honoring the documented route groups, Sanctum abilities, and client contracts defined by Flutter repositories."
---

# Method: Create/Update API Endpoint (Laravel)

## Purpose
Add or modify Laravel API endpoints (controller + routes) while honoring the documented route groups, Sanctum abilities, and client contracts defined by Flutter repositories.

## Triggers
- Flutter repository contract requires a new API or payload change.
- Route groups/middleware need adjustment (tenant vs landlord vs account scope).
- Controller logic must be extracted into services for reuse.

## Inputs
- Relevant `foundation_documentation/modules/*.md` entries covering Laravel routing, middleware, abilities, and the touched contract surface.
- Relevant `foundation_documentation/system_roadmap.md` entries to capture Flutter/Laravel follow-up for the contract change.
- `foundation_documentation/todos/active/mvp_slices/TODO-v1-api-security-hardening.md` (canonical security baseline and level semantics).
- `foundation_documentation/endpoints_mvp_contracts.md` conventions section (authoritative API shape + security metadata conventions).
- Existing routes (`routes/api/*.php`) and controller files.
- Sanctum ability definitions / policies.

## Procedure
1. **Persona alignment** – select Laravel Engineer persona, review roadmap items, and note Flutter requirements.
2. **Define contract**
   - Document request/response schema in `foundation_documentation/domain_entities.md`, the relevant module docs, and the shared roadmap before coding.
   - For Cloudflare-fronted environments, define edge-vs-app responsibility explicitly:
     - Cloudflare: DDoS/WAF/bot/challenge/coarse IP controls.
     - Laravel: principal/account controls, tenant access, idempotency/replay, and deterministic API rejection contract.
   - Classify endpoint protection level using the platform baseline:
     - `L1 Core` for low-risk/public/read-heavy routes.
     - `L2 Balanced` for most authenticated APIs and non-financial writes (default).
     - `L3 High Protection` for critical mutations (`purchase|reservation|check-in|auth recovery|admin-sensitive writes`).
   - Record the level and security behavior in endpoint contracts (`foundation_documentation/endpoints_mvp_contracts.md`) and in the active tactical TODO decision/task gates.
   - If the endpoint is a feed, confirm page-based pagination and decide whether an SSE `/stream` companion is required for deltas.
   - Define deterministic machine-readable rejection/error mapping for security controls (`rate_limited|soft_blocked|hard_blocked|idempotency_missing|idempotency_replayed|idempotency_expired|idempotency_malformed`) plus transport metadata (`retry_after`, `correlation_id`, `cf_ray_id` when present).
   - Enforce idempotency/replay policy by level:
     - `L3`: mandatory `Idempotency-Key` + replay-window validation on mutating requests.
     - `L2`: idempotency required for writes that can duplicate side effects.
     - `L1`: optional unless explicit route risk requires stricter protection.
   - For partial updates (`PATCH`), default to direct resource-shaped payloads (object/list) and field-presence semantics; do not introduce envelope wrappers (for example `paths`) unless an explicit contract decision is documented.
   - For Settings Kernel endpoints (`/settings/values/{namespace}`), nested fields must be sent as canonical dot-paths (example: `default_origin.lat`) unless a documented contract decision defines another format.
   - Omitted fields remain unchanged.
   - `null` is explicit clear only for nullable fields; `null` for non-nullable fields must return `422`.
   - Mixed set+clear payloads must be atomic.
   - When standardizing PATCH semantics, add a side-job in the active TODO to align pre-existing non-conforming endpoints (or document explicit exceptions).
3. **Route planning + domain matrix gate**
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
   - Ensure route-level anti-abuse/security middleware resolves to the approved `L1|L2|L3` level and cannot downgrade below global minimum policy.
   - Ensure production origin path is Cloudflare-only (direct origin blocked by firewall/allowlist) and app-level trust-proxy configuration accepts forwarding headers only from trusted proxies.
   - If landlord and tenant share the same URI prefix (example `/admin/api/v1`), enforce domain split explicitly and validate route registration with `php artisan route:list`.
   - If any route group uses `Route::domain('{...}')`, controller signatures must account for domain parameters before path parameters (to avoid parameter misbinding).
   - **Public vs admin resource split (when applicable):**
     - Public reads should live in tenant‑public routes; admin CRUD stays in tenant‑admin or account routes.
     - If tenant‑admin can create “on behalf of” an account/profile, ensure the owner is explicitly captured and that
       **account‑admin views only their own records** (no cross‑account bleed).
     - When public lists support account filtering, allow both account‑level and profile‑level filters if the domain uses 1:1 profiles.
4. **Controller + service logic**
   - **Controllers must be thin.** They should only: validate, delegate, and return responses.
   - **Controllers must not:**
     - build query filters, pagination, or sorting logic,
     - format/shape response payloads,
     - encode domain rules or side effects,
     - reach into models directly beyond basic route binding.
   - **Do instead:** move logic to Application Services / Query Services; use Data Objects or Resources to normalize payloads.
   - Ensure validation rules enforce the documented bounds (P‑14).
5. **Sanctum + policies**
   - Update abilities/policies if new permissions are required. Document them in the affected module docs.
   - **Ability catalog sync gate:** every newly introduced ability string must be registered in `config/abilities.php` when tokens can be expanded from wildcard (`*`) into explicit ability lists.
6. **Tests**
   - Add/extend feature tests covering happy paths, validation errors, and ability checks.
   - If public reads exist, add tests that private entities never leak into public routes.
   - If “create on behalf” is supported, add tests proving items appear only in the target account’s admin scope.
   - Add at least one real authentication-path test (login -> bearer token -> endpoint) for tenant-admin routes. Do not rely only on `Sanctum::actingAs`.
   - For domain-split routes, test both route reachability and route isolation (`main host` vs `tenant host`).
   - For settings namespace routes, test namespace-level authorization (`403`) and payload shape contract (`200/422`) for nested fields.
   - For `L2|L3` mutations, add replay/idempotency tests and deterministic rejection contract tests.
   - For throttling/challenge behavior, add tests covering legitimate retry safety (avoid false-positive lockouts).
   - Add infrastructure/security tests (or deployment checks) validating direct-origin denial and spoofed client-IP header rejection when not from trusted proxies.
7. **Documentation + roadmap sync**
   - Update `foundation_documentation/system_roadmap.md` with the new contract and note any client/backend follow-up needed.
   - Record the durable contract, routing, controller, and permission changes in the affected module docs.
   - If the touched module area is still marked `Partial`, migrate that touched legacy scope into the module as part of the same TODO.
   - If SSE was added, document event types + minimal payloads in `foundation_documentation/endpoints_mvp_contracts.md`.
8. **Verification**
   - Run `composer test` or targeted suites; optionally hit endpoints via Postman/cURL or contract tests.
   - Run architecture guardrails (`composer run architecture:guardrails`) as mandatory static compliance gate.
   - API-security lint gate (mandatory when hardening policy changes):
     - `php scripts/architecture_guardrails.php` must pass.
     - Guardrails must fail if `config/api_security.php` is missing core invariants (`L1/L2/L3`, `route_overrides`, `observe_mode`) or if `ApiSecurityHardening`/trusted-proxy baseline is not wired in `bootstrap/app.php`.
   - Run PHP lint/static checks configured by the project (`composer run lint`, `./vendor/bin/pint --test`, `composer run static-analysis`, or `./vendor/bin/phpstan analyse`).
   - Run targeted style checks for touched endpoint/security files (`./vendor/bin/pint --test <changed-files...>`).
   - Validate trusted-proxy configuration and Cloudflare header handling in runtime environment.
   - Validate origin lock (only Cloudflare can reach origin) and trace propagation (`CF-Ray` + `correlation_id`) in logs/telemetry.
   - Validate route map explicitly (`php artisan route:list`) for expected host + prefix combinations.
   - Validate ability presence in token expansion paths when wildcard permissions are used.
   - If endpoint levels or rejection taxonomy changed, confirm contract docs and guardrail rules were updated in the same change set.

## Outputs
- Updated routes, controllers, services, validation rules, and tests.
- Shared roadmap entries communicating API availability and follow-up work.
- Affected module docs reflecting the new endpoint and any touched legacy-scope canonicalization.

## Validation
- Tests pass and manual endpoint checks succeed.
- The shared roadmap acknowledges the new contract so downstream clients/teams can adopt it.
- The affected module docs are the durable source of truth for the changed endpoint behavior.
