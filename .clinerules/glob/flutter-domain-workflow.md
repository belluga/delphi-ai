# Flutter Domain Workflow (Glob Rule)

**Applies to:** `flutter-app/lib/domain/**`

## Rule

When editing domain files, run the Domain Workflow:

### Requirements
- Reflect changes in `foundation_documentation/domain_entities_sections/*` before updating code
- Ensure projections align with DTOs and update prototype data as needed
- Record implications for repositories and APIs in the roadmap

## Rationale

Domain models are the bridge between DTOs and screens. The workflow preserves single source of truth and contract traceability.

## Enforcement

- [ ] Execute the Domain Workflow steps for these files
- [ ] Block PRs lacking documentation updates
- [ ] Verify entity documentation exists before code changes

## Workflow Reference

See: `.clinerules/workflows/create-domain.md`

## Quick Checklist

- [ ] Entity documented in `domain_entities_sections/*`
- [ ] Projection models align with DTOs
- [ ] Prototype data updated if needed
- [ ] Repository implications noted in roadmap
- [ ] API changes documented