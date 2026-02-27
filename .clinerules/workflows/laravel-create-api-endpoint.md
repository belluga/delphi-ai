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
- [ ] Persona roadmaps reviewed for Flutter + Laravel sections
- [ ] Existing routes and controllers understood
- [ ] Sanctum ability definitions/policies reviewed

## Procedure

### Step 1: Persona Alignment

- Select Laravel Engineer persona
- Review roadmap items
- Note Flutter requirements for the endpoint

### Step 2: Define Contract

**Before coding, document:**

1. Request schema
2. Response schema
3. Add to `foundation_documentation/domain_entities.md`
4. Update Flutter roadmap

**For feed endpoints:**
- Confirm page-based pagination
- Decide if SSE `/stream` companion is required for deltas

**For partial updates (PATCH):**
- Default to direct resource-shaped payloads (object/list)
- Use field-presence semantics (omitted fields stay unchanged)
- Do not introduce envelope wrappers (for example `paths`) unless explicitly documented in the contract
- `null` is explicit clear only for nullable fields; `null` for non-nullable fields must return `422`
- Mixed set+clear payloads must be atomic
- When standardizing PATCH semantics, add a side-job in the active TODO to align pre-existing non-conforming endpoints (or document explicit exceptions)

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

**Middleware stacks:**
- `landlord` for landlord routes
- `tenant` for tenant routes
- `account` for account routes

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

### Step 7: Documentation + Roadmap Sync

- Update Flutter roadmap with new contract
- Note client updates needed
- Record changes in Laravel submodule summary
- If SSE added, document event types in endpoint contracts

### Step 8: Verification

```bash
# Run tests
composer test

# Or targeted suites
php artisan test --filter=BookingTest

# Manual verification
php artisan route:list --path=bookings
```

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
