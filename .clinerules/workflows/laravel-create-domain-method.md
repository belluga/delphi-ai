---
name: laravel-create-domain
description: "Introduce or extend a Laravel domain aggregate following MongoDB + Sanctum architecture: DocumentModels, migrations, controllers, and documentation."
---

# Workflow: Create Domain (Laravel)

## Purpose

Introduce or extend a Laravel domain aggregate following the current MongoDB + Sanctum architecture: DocumentModels, migrations, controllers, and documentation must stay aligned.

## Triggers

- Feature needs a landlord/tenant/account entity that doesn't exist
- **Any edit** to existing domain/entity model (add/remove fields, change payload)
- Mongo collections require new fields/snapshots for Flutter/API contracts
- Documentation references a domain missing or outdated in code

## Prerequisites

- [ ] `foundation_documentation/domain_entities.md` reviewed
- [ ] `foundation_documentation/submodule_laravel-app_summary.md` reviewed
- [ ] Relevant `system_roadmap.md` entries reviewed for Laravel + Flutter follow-up
- [ ] Existing DocumentModels, migrations, factories/seeders understood

## Procedure

### Step 0: Package-First Gate
Read `foundation_documentation/package_registry.md` and check whether an existing Laravel package already owns this domain. If the domain belongs to a package, implement there. Record the Package-First Assessment. See `paced.core.package-first`.


### Step 1: Persona Alignment

- Run Persona Selection (Laravel Engineer)
- Review roadmap entries tied to this domain

### Step 2: Document First

Add/expand domain entry in:
- `foundation_documentation/domain_entities.md` (fields, invariants, collections)
- System/module roadmap
- Shared roadmap entry with planned work and cross-stack follow-up

### Step 3: Plan Schema + Validations

Determine:
- Collection name
- Embedded documents
- Indexes
- Size constraints

Draft migration/update scripts under:
```
database/migrations/landlord/
database/migrations/tenant/
```

If the domain is package-owned, use package migration directories and wire tenant scope through `config/multitenancy.php` `tenant_migration_paths`.

Index lifecycle rule:
- Provision indexes via migration/provisioning flow in tenant context
- Do NOT create indexes inside runtime request/query paths

### Step 4: Implement DocumentModel

**Create/extend model:**
```
App\Models\Landlord\...
App\Models\Tenants\...
```

**Use traits as needed:**
- `DocumentModel`
- `SoftDeletes`
- `UsesTenantConnection`
- `HasSlug`

**Define:**
- `$fillable`
- Relationships
- Scopes
- Helper methods

### Step 5: MongoDB Rules (NON-NEGOTIABLE)

**❌ NEVER use Eloquent `$casts` for arrays/objects on MongoDB-backed models:**
```php
// ❌ WRONG - Never do this on MongoDB models
protected $casts = [
    'settings' => 'array',
    'metadata' => 'object',
];
```

**Why:** Persist raw BSON from the driver. Let MongoDB handle native types.

**✅ Correct approach:**
```php
// ✅ CORRECT - No casts, raw BSON
class Booking extends DocumentModel
{
    protected $fillable = [
        'id',
        'status',
        'settings', // Raw BSON
        'metadata',  // Raw BSON
    ];
    
    // No $casts for array/object fields!
}
```

**Hard Ban:**
- Do NOT add `array`, `json`, or `object` casts to Mongo-backed models
- If you find one, remove it and refactor the consumer
- Normalization belongs outside the model

### Step 6: Data Objects (When to Use)

Use `App\DataObjects\...` when you must:
- Normalize/shape nested settings or payloads
- Add array/object casts (put here instead of model)
- Introduce accessors/mutators for nested structures
- Perform payload shaping for API responses
- Enforce defaults/derived fields on nested blobs

**Data Objects should:**
- Accept raw BSON/array inputs from Mongo
- Normalize/validate/derive output for API contracts
- Keep Models free of array casts/accessors

**Example Data Object:**
```php
class BookingSettingsData
{
    public function __construct(
        public readonly bool $notificationsEnabled,
        public readonly int $maxParticipants,
        public readonly array $allowedDays,
    ) {}

    public static function fromArray(array $data): self
    {
        return new self(
            notificationsEnabled: $data['notifications_enabled'] ?? true,
            maxParticipants: $data['max_participants'] ?? 10,
            allowedDays: $data['allowed_days'] ?? [],
        );
    }

    public function toArray(): array
    {
        return [
            'notifications_enabled' => $this->notificationsEnabled,
            'max_participants' => $this->maxParticipants,
            'allowed_days' => $this->allowedDays,
        ];
    }
}

// Usage in controller/service
$settings = BookingSettingsData::fromArray($booking->settings);
```

### Step 7: Seeders/Factories

If needed, update seeder classes:
```php
// database/seeders/BookingSeeder.php
class BookingSeeder extends Seeder
{
    public function run(): void
    {
        Booking::create([
            'status' => 'pending',
            'settings' => [
                'notifications_enabled' => true,
                'max_participants' => 10,
            ],
        ]);
    }
}
```

### Step 8: Controllers/Services

- Reference new model in controllers
- Keep logic thin
- Extract reusable actions to Services

### Step 9: Tests & Validation

```bash
# Run all tests
php artisan test

# Run targeted suites
php artisan test --filter=BookingTest
```

Add/extend feature tests covering:
- New endpoints
- New behaviors
- Validation rules

### Step 10: Documentation + Roadmap Sync

- Record pending backend work for Flutter in roadmap
- Note schema/index changes in Laravel submodule summary
- Update API contracts if behavior changed

## Outputs

- [ ] Updated domain documentation
- [ ] Updated roadmaps
- [ ] New/modified DocumentModel
- [ ] Migrations/seeders if needed
- [ ] Controllers/services updated
- [ ] Tests passing

## Validation Checklist

- [ ] `php artisan test` succeeds
- [ ] Schema updates reflected in docs
- [ ] Flutter roadmap mentions new payloads
- [ ] NO array/object casts on MongoDB models
- [ ] Data Objects used for normalization (not model accessors)
- [ ] Indexes provisioned via migration/provisioning flow (not runtime query code)
