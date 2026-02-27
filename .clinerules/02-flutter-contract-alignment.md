# Flutter Contract Alignment (Always-On)

## Rule

Maintain bidirectional contract alignment between Flutter and backend:

### DTO/Entity Mapping
- Map every Flutter DTO/model to the governing entity in `foundation_documentation/domain_entities.md`
- Update summaries when attributes change
- Never let DTOs diverge from documented entities

### API Changes
- When Flutter repositories alter pagination/filtering, log in `foundation_documentation/system_roadmap.md`
- Update Laravel roadmap section for matching APIs
- Record new endpoint requirements before implementation

### Mock Data Sync
- Regenerate JSON fixtures when DTOs change
- Notify Laravel via `submodule_laravel-app_summary.md` notes
- Mocks must match real contract expectations

### Integration Dependencies
- Record dependencies in `project_mandate.md` or module docs
- Document tenant app data requirements
- Document feature flag dependencies

## Rationale

Flutter is the lead consumer of the platform's Core Business Entities. Keeping contracts synchronized avoids Laravel/API divergence and ensures every mock artifact is a dependable specification.

## Enforcement

### Must Verify
- [ ] DTO → entity mapping exists
- [ ] Roadmap updated for repository changes
- [ ] Mock fixtures match current DTOs
- [ ] Integration dependencies documented

### Reject Commits That
- Adjust mocks/DTOs without updating documentation
- Add new endpoints without roadmap entry
- Change pagination/filtering without backend coordination

### Regular Checks
- Compare `submodule_flutter-app_summary.md` against `.gitmodules`
- Verify documentation reflects submodule state

## Quick Reference

| Change Type | Required Documentation |
|-------------|------------------------|
| New DTO | `domain_entities.md` entry |
| DTO field change | Update entity, regenerate mocks |
| Repository change | `system_roadmap.md` entry |
| New endpoint needed | Roadmap + Laravel section |
| Feature flag | `project_mandate.md` |