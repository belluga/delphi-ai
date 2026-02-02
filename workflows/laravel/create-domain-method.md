---
description: Introduce or extend a Laravel domain aggregate following the current MongoDB + Sanctum architecture: DocumentModels, migrations, controllers, and documentation must stay aligned with `foundation_documentation/submodule_laravel-app_summary.md` and the system principles.
---

# Method: Create Domain (Laravel)

## Purpose
Introduce or extend a Laravel domain aggregate following the current MongoDB + Sanctum architecture: DocumentModels, migrations, controllers, and documentation must stay aligned with `foundation_documentation/submodule_laravel-app_summary.md` and the system principles.

## Triggers
- A feature needs a landlord/tenant/account entity that does not exist yet.
- Mongo collections require new fields/snapshots to satisfy Flutter/API contracts.
- Documentation references a domain that is missing or outdated in code.

## Inputs
- `foundation_documentation/domain_entities.md` and project mandate (confirm architecture mode).
- `foundation_documentation/submodule_laravel-app_summary.md` for live routing/schema context.
- `foundation_documentation/persona_roadmaps.md` (Laravel + Flutter sections).
- Existing DocumentModels, migrations, factories/seeders related to the domain.

## Procedure
1. **Persona alignment** – run Persona Selection (Laravel Engineer) and review roadmap entries tied to this domain.
2. **Document first**
   - Add/expand the domain entry in `foundation_documentation/domain_entities.md` (fields, invariants, collections).
   - Update the system/module roadmap plus persona roadmap with the planned work.
3. **Plan schema + validations**
   - Determine collection name, embedded documents, indexes, and size constraints (per P‑14).
   - Draft migration/update scripts under `database/migrations/landlord|tenant`.
4. **Implement DocumentModel**
   - Create/extend `App\Models\Landlord|Tenants\...` using `DocumentModel`, `SoftDeletes`, and relevant traits (UsesTenantConnection, HasSlug, etc.).
   - Define `$fillable`, `$casts`, relationships, scopes, and helper methods consistent with existing models.
5. **Seeders/factories** (if needed)
   - Update seeder classes to provision required documents for bootstrap flows.
6. **Controllers / services**
   - Ensure existing controllers reference the new model; keep logic thin by extracting reusable actions into Services when possible.
7. **Tests & validation**
   - Add/extend feature tests covering new endpoints or behaviors.
   - Re-run `composer test` or targeted suites as appropriate.
8. **Documentation + roadmap sync**
   - Record any pending backend work for Flutter in the roadmap (e.g., API blueprints that need client coordination).
   - Note schema/index changes in the Laravel submodule summary if behavior deviates from the last published version.

## Outputs
- Updated domain documentation and roadmaps.
- New/modified DocumentModel + migrations/seeders/tests checked in.
- Controllers/services referencing the new model.

## Validation
- `php artisan test` (or targeted suites) succeeds.
- Schema updates are reflected in docs; Flutter roadmap entries mention any new payloads.
- Do not add Eloquent casts for arrays or objects on MongoDB-backed models; leave these fields uncast so the MongoDB driver persists native BSON types.
