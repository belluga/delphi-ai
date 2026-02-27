---
name: laravel-domain-resolution-testing
description: "Ensure tests that depend on tenant resolution clearly distinguish web (host/domains) from mobile (X-App-Domain + app_domains)."
---

# Workflow: Domain Resolution Testing (Laravel)

## Purpose

Ensure tests that depend on tenant resolution clearly distinguish web (host/domains) from mobile (X-App-Domain + app_domains).

## Triggers

- Writing or modifying tests that depend on tenant resolution
- Tests involving branding, registration, domain/app-domain functionality
- Test failures related to tenant context

## Prerequisites

- [ ] Laravel test scope (Feature/API tests)
- [ ] Core instructions loaded
- [ ] Domain resolution rules understood

## Procedure

### Step 1: Identify Tenant Resolution Tests

Find tests that rely on tenant resolution:
- Branding tests
- Registration tests
- Domain/app-domain tests
- Multi-tenant context tests

```bash
# Find tenant-related tests
rg -n "tenant|domain|X-App-Domain" tests/
```

### Step 2: Classify Each Test

**Web Context Tests:**
- Resolve by `host` / `domains` only
- No `X-App-Domain` header required
- Tenant `domains` field is sufficient for resolution

**Mobile Context Tests:**
- Resolve by `X-App-Domain` header + `app_domains`
- Header must be set explicitly
- Tenant `app_domains` must include the header value

### Step 3: Implement Web Context Tests

```php
// tests/Feature/Web/TenantResolutionTest.php
class TenantResolutionTest extends TestCase
{
    /** @test */
    public function resolves_tenant_by_host(): void
    {
        $tenant = Tenant::factory()->create([
            'domains' => ['tenant.example.com'],
        ]);

        $response = $this
            ->withHeaders(['Host' => 'tenant.example.com'])
            ->get('/api/v1/branding');

        $response->assertOk();
        $this->assertEquals($tenant->id, app('current_tenant')->id);
    }

    /** @test */
    public function web_context_does_not_require_app_domain_header(): void
    {
        $tenant = Tenant::factory()->create([
            'domains' => ['shop.example.com'],
        ]);

        // No X-App-Domain header - web context
        $response = $this
            ->withHeaders(['Host' => 'shop.example.com'])
            ->get('/api/v1/branding');

        $response->assertOk();
    }
}
```

### Step 4: Implement Mobile Context Tests

```php
// tests/Feature/Mobile/AppDomainResolutionTest.php
class AppDomainResolutionTest extends TestCase
{
    /** @test */
    public function resolves_tenant_by_app_domain_header(): void
    {
        $tenant = Tenant::factory()->create([
            'domains' => ['tenant.example.com'],
            'app_domains' => ['tenant-app.example.com'],
        ]);

        $response = $this
            ->withHeaders([
                'X-App-Domain' => 'tenant-app.example.com',
            ])
            ->getJson('/api/v1/branding');

        $response->assertOk();
        $this->assertEquals($tenant->id, app('current_tenant')->id);
    }

    /** @test */
    public function mobile_context_requires_app_domain_in_tenant_config(): void
    {
        $tenant = Tenant::factory()->create([
            'domains' => ['tenant.example.com'],
            'app_domains' => ['valid-app.example.com'],
        ]);

        // Invalid X-App-Domain - not in app_domains
        $response = $this
            ->withHeaders([
                'X-App-Domain' => 'invalid-app.example.com',
            ])
            ->getJson('/api/v1/branding');

        $response->assertNotFound(); // Or appropriate error
    }
}
```

### Step 5: Document Classification

Add clear comments to test files:

```php
/**
 * WEB CONTEXT TESTS
 * 
 * These tests verify tenant resolution via host/domains.
 * Used for web browser requests where tenant is identified by URL.
 * No X-App-Domain header is required.
 */
class WebTenantResolutionTest extends TestCase
{
    // ...
}

/**
 * MOBILE CONTEXT TESTS
 * 
 * These tests verify tenant resolution via X-App-Domain header.
 * Used for mobile app requests where tenant is identified by header.
 * Tenant must have the domain in their app_domains array.
 */
class MobileTenantResolutionTest extends TestCase
{
    // ...
}
```

### Step 6: Validate Tests

```bash
# Run all tests
php artisan test

# Run specific test file
php artisan test tests/Feature/Web/TenantResolutionTest.php
php artisan test tests/Feature/Mobile/AppDomainResolutionTest.php

# Run with filter
php artisan test --filter=TenantResolution
```

## Test Classification Quick Reference

| Context | Resolution Method | Required Headers | Tenant Field |
|---------|------------------|------------------|--------------|
| Web | `Host` header | `Host: tenant.example.com` | `domains` |
| Mobile | `X-App-Domain` header | `X-App-Domain: app.example.com` | `app_domains` |

## Common Patterns

### Web Request
```php
$this
    ->withHeaders(['Host' => 'tenant.example.com'])
    ->get('/api/v1/branding');
```

### Mobile Request
```php
$this
    ->withHeaders(['X-App-Domain' => 'tenant-app.example.com'])
    ->getJson('/api/v1/branding');
```

### Both Contexts
```php
/** @test */
public function tenant_resolves_in_both_contexts(): void
{
    $tenant = Tenant::factory()->create([
        'domains' => ['web.example.com'],
        'app_domains' => ['app.example.com'],
    ]);

    // Web context
    $webResponse = $this
        ->withHeaders(['Host' => 'web.example.com'])
        ->get('/api/v1/branding');
    $webResponse->assertOk();

    // Mobile context
    $mobileResponse = $this
        ->withHeaders(['X-App-Domain' => 'app.example.com'])
        ->getJson('/api/v1/branding');
    $mobileResponse->assertOk();
}
```

## Outputs

- [ ] Tests classified as web or mobile context
- [ ] Web context tests use Host/domains
- [ ] Mobile context tests use X-App-Domain + app_domains
- [ ] Test documentation updated

## Validation Checklist

- [ ] `php artisan test` passes
- [ ] Web context tests work without X-App-Domain
- [ ] Mobile context tests require X-App-Domain
- [ ] Tenant resolution behavior is stable