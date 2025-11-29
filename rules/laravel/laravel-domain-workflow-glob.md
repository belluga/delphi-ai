---
activation_mode: glob
glob_pattern: "laravel-app/app/**"
summary: Apply the Laravel domain workflow when domain/model files are edited.
---

## Rule
When editing `laravel-app/app/**` domain models/services, run the Domain Workflow:
- Reflect changes in `foundation_documentation/domain_entities_sections/*` before code updates.
- Ensure models/services honor tenant resolution and ownership boundaries.
- Update related API contracts and roadmaps if domain changes affect endpoints.

## Rationale
Domain changes define the data shape and permissions model. The workflow keeps code aligned with canonical entities and multitenancy rules.

## Enforcement
- Execute the Domain Workflow steps for these files.
- Block PRs lacking documentation updates or tenant-safety checks.

## Notes
Workflow reference: `delphi-ai/workflows/laravel/create-domain-method.md`.
