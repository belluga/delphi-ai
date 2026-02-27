# Flutter Repository Workflow (Glob Rule)

**Applies to:** `flutter-app/lib/infrastructure/repositories/**`

## Rule

Edits in repository directories must run the Repository Workflow:

### Requirements
- Maintain DTO → Domain mapping discipline; no DTO leakage
- Document pagination/filtering contracts and sync Laravel roadmap entries when APIs are implied
- Update mock data/DTO docs before merging

## Rationale

Repositories define how Flutter consumes domain contracts. The workflow keeps them aligned with documentation and backend expectations.

## Enforcement

- [ ] Execute the Repository Workflow steps for these paths
- [ ] Require PR references to updated docs/roadmaps

## Workflow Reference

See: `.clinerules/workflows/create-repository.md`

## Quick Checklist

- [ ] DTO → Domain mapping documented
- [ ] No DTO types in controller/screen
- [ ] Pagination contracts documented
- [ ] Laravel roadmap updated if API needed
- [ ] Mock data matches DTOs