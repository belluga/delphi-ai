---
name: laravel-create-api-endpoint
description: "Add or modify Laravel API endpoints (controller + routes) while honoring documented route groups, Sanctum abilities, and client contracts defined by Flutter repositories."
---

# Workflow: Create/Update API Endpoint (Laravel)

## Purpose

Add or modify Laravel API endpoints (controller + routes) while honoring documented route groups, Sanctum abilities, and client contracts defined by Flutter repositories.

## Triggers

- Flutter repository contract requires a new API or payload change
- Route groups/middleware need adjustment (tenant vs landlord vs account scope)
- Controller logic must be extracted into services for reuse

## Prerequisites

- [ ] Laravel submodule summary reviewed (`foundation_documentation/submodule_laravel-app_summary.md`)
- [ ] Relevant `system_roadmap.md` entries reviewed for Flutter + Laravel follow-up
- [ ] API security hardening baseline reviewed (`foundation_documentation/todos/active/mvp_slices/TODO-v1-api-security-hardening.md`)
- [ ] Endpoint conventions reviewed (`foundation_documentation/endpoints_mvp_contracts.md`)
- [ ] Cloudflare edge assumptions reviewed (origin behind Cloudflare and trusted-proxy policy defined)
- [ ] Existing routes and controllers understood
- [ ] Sanctum ability definitions/policies reviewed

## Procedure

### Step 0: Package-First Gate
Read the proprietary packages checklist at `delphi-ai/config/ecosystem_packages.yaml & foundation_documentation/local_packages.yaml` and check whether an existing Laravel package already provides the capability this endpoint needs. If a matching package exists, extend it instead of creating new host-level services. Record the Package-First Assessment in the TODO. See `paced.core.package-first`.


### Step 1: Persona Alignment

- Select Laravel Engineer persona
- Review roadmap items
- Note Flutter requirements for the endpoint

### Step 2: Define Contract

**Before coding, document:**

1. Request schema
2. Response schema
3. Add to `foundation_documentation/domain_entities.md`
4. Update the shared roadmap entry with client/backend follow-up

**Security hardening baseline (mandatory):**
- Classify each endpoint as `L1 Core`, `L2 Balanced`, or `L3 High Protection`.
- `L2 Balanced` is default; upgrades to `L3` for critical mutation routes (`purchase|reservation|check-in|auth recovery|admin-sensitive writes`).
- Record level assignment + error metadata conventions in `foundation_documentation/endpoints_mvp_contracts.md`.
- Keep level assignment monotonic: route overrides may strengthen controls, never weaken below global minimum.
- Define edge-vs-app responsibility:
  - Cloudflare: edge DDoS/WAF/bot/challenge/coarse IP controls.
  - Laravel: principal/account controls + mutation safety + deterministic rejection mapping.

**For feed endpoints:**
- Confirm page-based pagination
- Decide if SSE `/stream` companion is required for deltas

**For partial updates (PATCH):**
- Default to direct resource-shaped payloads (object/list)
- Use field-presence semantics (omitted fields stay unchanged)
- Do not introduce envelope wrappers (for example `paths`) unless explicitly documented in the contract
- For Settings Kernel endpoints (`/settings/values/{namespace}`), nested fields must use canonical dot-path keys (for example `default_origin.lat`) unless an explicit contract exception exists
- `null` is explicit clear only for nullable fields; `null` for non-nullable fields must return `422`
- Mixed set+clear payloads must be atomic
- When standardizing PATCH semantics, add a side-job in the active TODO to align pre-existing non-conforming endpoints (or document explicit exceptions)

**Idempotency/replay + rejection contract:**
- `L3` mutations require `Idempotency-Key` + replay-window validation.
- `L2` mutations require idempotency when duplicate side effects are possible.
- Define deterministic machine-readable rejection reasons (`rate_limited|soft_blocked|hard_blocked|idempotency_missing|idempotency_replayed|idempotency_expired|idempotency_malformed`) and include `retry_after` + `correlation_id` metadata (`cf_ray_id` when present).

### Step 3: Route Planning

**Separate domain scope from auth scope (do not mix):**

| Domain | Route Sets | Access |
|--------|------------|--------|
| Main domain | Landlord routes | Landlord users |
| Tenant domain | Tenant + Account routes | Tenant & Account users |

**User access matrix:**
- **Landlord users**: landlord + tenant-admin + tenant-non-admin + account routes
- **Account users**: tenant-non-admin + account routes only

**Route file selection:**
- Tenant-admin: `/admin/api/v1/...` on tenant domains
- Tenant-non-admin: `/api/v1/...` on tenant domains
- Account: `/api/v1/accounts/{account_slug}/...` on tenant domains

**Domain matrix gate (mandatory):**
- If landlord and tenant share URI prefixes (for example `/admin/api/v1`), enforce host/domain split explicitly.
- Validate final registration with `php artisan route:list`.
- If route groups use `Route::domain('{...}')`, verify controller signatures include domain params before path params.

**Middleware stacks:**
- `landlord` for landlord routes
- `tenant` for tenant routes
- `account` for account routes
- security/anti-abuse middleware aligned to `L1|L2|L3` profile for each route
- production origin locked to Cloudflare path only + trusted-proxy header parsing enforced

**Public vs admin split:**
- Public reads → tenant-public routes
- Admin CRUD → tenant-admin or account routes
- Account-admin views only their own records (no cross-account bleed)

### Step 4: Controller + Service Logic

**Controllers MUST be thin:**
- ✅ Validate input
- ✅ Delegate to services
- ✅ Return responses

**Controllers MUST NOT:**
- ❌ Build query filters, pagination, sorting logic
- ❌ Format/shape response payloads
- ❌ Encode domain rules or side effects
- ❌ Reach into models directly beyond route binding

**Do instead:**
- Move logic to Application Services / Query Services
- Use Data Objects or Resources to normalize payloads
- Ensure validation rules enforce documented bounds

**Example thin controller:**
```php
class BookingController extends Controller
{
    public function __construct(
        private BookingService $bookingService,
    ) {}

    public function index(BookingIndexRequest $request): JsonResponse
    {
        $bookings = $this->bookingService->getBookings(
            $request->validated(),
            $request->user(),
        );
        
        return BookingResource::collection($bookings);
    }

    public function store(BookingStoreRequest $request): JsonResponse
    {
        $booking = $this->bookingService->createBooking(
            $request->validated(),
            $request->user(),
        );
        
        return new BookingResource($booking);
    }
}
```

### Step 5: Sanctum + Policies

- Update abilities/policies if new permissions required
- Document in Laravel summary
- **Ability catalog sync gate:** any newly introduced ability string must be present in `config/abilities.php` when wildcard (`*`) permissions are expanded into explicit token abilities.

**Policy example:**
```php
class BookingPolicy
{
    public function view(User $user, Booking $booking): bool
    {
        return $user->account_id === $booking->account_id;
    }

    public function createOnBehalf(User $user, Account $account): bool
    {
        return $user->isTenantAdmin() || $user->account_id === $account->id;
    }
}
```

### Step 6: Tests

Add/extend feature tests covering:
- [ ] Happy paths
- [ ] Validation errors
- [ ] Ability checks
- [ ] Public routes don't leak private entities
- [ ] "Create on behalf" items appear only in target account scope
- [ ] At least one real login-token path for tenant-admin endpoints (not only `Sanctum::actingAs`)
- [ ] Settings namespace PATCH contract checks (dot-path success `200`, envelope rejection `422`)
- [ ] `L2|L3` replay/idempotency rejection cases are deterministic
- [ ] Rate-limit/challenge logic preserves legitimate retries (false-positive safety)
- [ ] Direct-origin access is blocked and spoofed client-IP headers are not trusted outside approved proxy chain

### Step 7: Documentation + Roadmap Sync

- Update Flutter roadmap with new contract
- Note client updates needed
- Record changes in Laravel submodule summary
- If SSE added, document event types in endpoint contracts

### Step 8: Verification

```bash
# Run tests
composer test

# Run architecture guardrails (mandatory)
composer run architecture:guardrails

# API-security lint gate (mandatory when hardening policy changes)
php scripts/architecture_guardrails.php
# Must fail when api_security baseline invariants or middleware/proxy wiring are missing

# Run PHP lint/static checks (use project-defined entrypoints)
composer run lint || ./vendor/bin/pint --test
composer run static-analysis || ./vendor/bin/phpstan analyse

# Targeted style check for touched endpoint/security files
./vendor/bin/pint --test <changed-files...>

# Or targeted suites
php artisan test --filter=BookingTest

# Manual verification
php artisan route:list --path=bookings
```

Additional checks:
- `php artisan route:list | rg "admin/api/v1|api/v1"` for host/prefix matrix validation.
- Validate changed abilities are present in `config/abilities.php` when wildcard token expansion applies.
- If endpoint level assignments or rejection taxonomy changed, verify docs + architecture guardrails were updated in the same change set.
- Validate trusted-proxy configuration for Cloudflare forwarding headers and origin lock at deployment/runtime.
- Validate trace correlation (`CF-Ray` + `correlation_id`) is observable in logs/telemetry for rejected requests.

## Route Structure Quick Reference

```
routes/api/
├── landlord.php      # Main domain, landlord users
├── tenant.php        # Tenant domain, public + authenticated
├── tenant-admin.php  # Tenant domain, tenant-admin users
└── account.php       # Tenant domain, account users
```

## Outputs

- [ ] Updated routes
- [ ] Updated controllers
- [ ] Updated services
- [ ] Updated validation rules
- [ ] Updated tests
- [ ] Roadmap entries for Flutter
- [ ] Laravel submodule summary updated

## Validation Checklist

- [ ] Tests pass
- [ ] Manual endpoint checks succeed
- [ ] Flutter roadmap acknowledges new contract
- [ ] Controllers are thin (no business logic)
- [ ] Public/private boundaries enforced
- [ ] Cross-account isolation verified
