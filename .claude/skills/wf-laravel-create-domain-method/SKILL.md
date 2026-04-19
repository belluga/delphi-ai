---
name: wf-laravel-create-domain-method
description: "Workflow: MUST use whenever the scope matches this purpose: Introduce or extend a Laravel domain aggregate following the current MongoDB + Sanctum architecture: DocumentModels, migrations, controllers, and documentation must stay aligned with canonical module docs and the system principles."
---

# Method: Create Domain (Laravel)

## Purpose
Introduce or extend a Laravel domain aggregate following the current MongoDB + Sanctum architecture: DocumentModels, migrations, controllers, and documentation must stay aligned with canonical module docs and the system principles.

## Triggers
- A feature needs a landlord/tenant/account entity that does not exist yet.
- Mongo collections require new fields/snapshots to satisfy Flutter/API contracts.
- Documentation references a domain that is missing or outdated in code.

## Inputs
- `foundation_documentation/domain_entities.md` and project mandate (confirm architecture mode).
- Relevant `foundation_documentation/modules/*.md` entries for routing, schema, and touched domain context.
- Relevant `foundation_documentation/system_roadmap.md` entries for Laravel/Flutter follow-up.
- Existing DocumentModels, migrations, factories/seeders related to the domain.

## Preferred Deterministic Helper
- Use `bash delphi-ai/tools/laravel_workflow_scaffold.sh --kind domain --name <domain_name> [--module <module>] [--output <path>]` to scaffold the repeatable docs/model/migration/test checklist before changing Laravel domain surfaces.
- Treat the helper as preparation only; schema/invariant design and migration strategy remain in this workflow.

## Procedure
1. **Profile alignment** – run Profile Selection as `Operational / Coder` with `laravel` scope and review roadmap entries only when strategic follow-up is part of the change.
2. **Document first**
   - Add/expand the domain entry in `foundation_documentation/domain_entities.md` (fields, invariants, collections).
   - Update `foundation_documentation/system_roadmap.md` and any affected module docs with the planned work and cross-stack follow-up.
3. **Plan schema + validations**
   - Determine collection name, embedded documents, indexes, and size constraints (per P‑14).
   - Draft migration/update scripts under `database/migrations/landlord|tenant` or package migration directories when the domain is package-owned.
   - For tenant-scoped domains, enforce Spatie tenant migration flow (`tenant_migration_paths` + tenant connection/context).
   - Do not create indexes in runtime request/query paths; indexes must be provisioned via migration/provisioning flow.
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
   - Record schema/index and domain-behavior changes in the affected module docs.
   - If the touched module area is still marked `Partial`, migrate that touched legacy scope into the module as part of the same TODO.

## Outputs
- Updated domain documentation, affected module docs, and roadmaps.
- New/modified DocumentModel + migrations/seeders/tests checked in.
- Controllers/services referencing the new model.

## Validation
- `php artisan test` (or targeted suites) succeeds.
- Schema updates are reflected in docs; Flutter roadmap entries mention any new payloads.
- Do not add Eloquent casts for arrays or objects on MongoDB-backed models; leave these fields uncast so the MongoDB driver persists native BSON types.
