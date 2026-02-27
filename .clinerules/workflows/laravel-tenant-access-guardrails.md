---
name: laravel-tenant-access-guardrails
description: "Ensure any tenant-authenticated API routes consistently enforce tenant access via CheckTenantAccess and keep auth boundaries explicit."
---

# Workflow: Tenant Access Guardrails (Laravel)

## Purpose

Ensure any tenant-authenticated API routes consistently enforce tenant access via `CheckTenantAccess` and keep auth boundaries explicit.

## Triggers

- Adding or modifying tenant routes
- Changes to authentication middleware
- Security review of API routes

## Prerequisites

- [ ] Laravel scope (routes/middleware changes)
- [ ] Core instructions loaded
- [ ] Tenant access rules understood

## Procedure

### Step 1: Identify Target Route Files

Find tenant route files:
```bash
ls -la laravel-app/routes/api/tenant*.php
```

Common files:
- `tenant_api_v1.php` - Tenant API routes
- `tenant_admin_api_v1.php` - Tenant admin routes
- `account_api_v1.php` - Account-scoped routes

**Verify:** Routes should only be registered under **tenant domain group** (never on main domain).

### Step 2: List Authenticated Tenant Routes

Find all `auth:sanctum` routes:
```bash
rg -n "auth:sanctum" laravel-app/routes/api/tenant*.php
```

### Step 3: Ensure CheckTenantAccess Middleware

Every authenticated tenant route must include `CheckTenantAccess`:

```php
// routes/api/tenant_api_v1.php

Route::middleware(['auth:sanctum', 'check_tenant_access'])
    ->group(function () {
        // Tenant-authenticated routes
        Route::get('/bookings', [BookingController::class, 'index']);
        Route::post('/bookings', [BookingController::class, 'store']);
    });
```

**Correct middleware stack:**
```php
// ✅ CORRECT
Route::middleware(['auth:sanctum', 'check_tenant_access'])

// ❌ WRONG - missing tenant access check
Route::middleware(['auth:sanctum'])
```

### Step 4: Verify Account-Scoped Routes

Account routes use `account` middleware, NOT tenant guards:

```php
// routes/api/account_api_v1.php

Route::middleware(['auth:sanctum', 'account'])
    ->prefix('accounts/{account_slug}')
    ->group(function () {
        // Account-scoped routes
        Route::get('/settings', [AccountSettingsController::class, 'show']);
    });
```

**Key distinctions:**
| Route Type | Middleware | Scope |
|------------|------------|-------|
| Tenant | `auth:sanctum` + `check_tenant_access` | Tenant domain |
| Account | `auth:sanctum` + `account` | Account within tenant |
| Landlord | `auth:sanctum` + `landlord` | Main domain |

### Step 5: Add/Update Tests

Create tests to verify guardrails:

```php
// tests/Feature/TenantAccessGuardrailsTest.php

class TenantAccessGuardrailsTest extends TestCase
{
    /** @test */
    public function cross_tenant_access_returns_403(): void
    {
        $landlordUser = User::factory()->landlord()->create();
        $tenant = Tenant::factory()->create();

        // Landlord token without tenant access
        $token = $landlordUser->createToken('test')->plainTextToken;

        $response = $this
            ->withHeaders([
                'Authorization' => "Bearer $token",
                'X-App-Domain' => $tenant->app_domains[0],
            ])
            ->getJson('/api/v1/bookings');

        $response->assertForbidden();
    }

    /** @test */
    public function account_tokens_cannot_access_tenant_routes(): void
    {
        $accountUser = User::factory()->create();
        $tenant = Tenant::factory()->create();
        
        $token = $accountUser->createToken('test', ['account-access'])->plainTextToken;

        $response = $this
            ->withHeaders([
                'Authorization' => "Bearer $token",
                'X-App-Domain' => $tenant->app_domains[0],
            ])
            ->getJson('/api/v1/admin/users');

        $response->assertForbidden();
    }

    /** @test */
    public function tenant_routes_unreachable_on_main_domain(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('test')->plainTextToken;

        // Main domain request
        $response = $this
            ->withHeaders([
                'Authorization' => "Bearer $token",
                'Host' => 'main.example.com',
            ])
            ->getJson('/api/v1/bookings');

        $response->assertNotFound(); // Route not registered on main domain
    }
}
```

### Step 6: Validate

```bash
# Run tests
php artisan test --filter=TenantAccessGuardrails

# List routes with middleware
php artisan route:list --middleware=check_tenant_access
```

## Middleware Stack Reference

### Tenant Routes
```php
Route::middleware(['auth:sanctum', 'check_tenant_access'])
    ->group(function () {
        // Tenant users can access
        // Landlord users with tenant access can access
        // Account users CANNOT access
    });
```

### Account Routes
```php
Route::middleware(['auth:sanctum', 'account'])
    ->prefix('accounts/{account_slug}')
    ->group(function () {
        // Account users can access their own account
        // Cross-account access denied
    });
```

### Landlord Routes
```php
Route::middleware(['auth:sanctum', 'landlord'])
    ->group(function () {
        // Landlord users only
    });
```

## Common Anti-Patterns

**❌ DO NOT:**
- Skip `check_tenant_access` on tenant routes
- Mix tenant and account middleware
- Register tenant routes on main domain
- Use tenant middleware on account routes

**✅ DO:**
- Always include `check_tenant_access` for tenant routes
- Keep route groups separate
- Test cross-scope access is denied
- Document middleware requirements

## Outputs

- [ ] Tenant route files updated with `CheckTenantAccess`
- [ ] Account routes verified using `account` middleware
- [ ] Tests for guardrails
- [ ] Route list validated

## Validation Checklist

- [ ] `php artisan test` passes
- [ ] Cross-tenant access returns 403
- [ ] Account tokens cannot access tenant routes
- [ ] Tenant routes unreachable on main domain
- [ ] `php artisan route:list` shows correct middleware