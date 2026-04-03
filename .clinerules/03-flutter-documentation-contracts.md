# Flutter Documentation Contracts (Always-On)

## Rule

Before touching Flutter code or mocks, update the authoritative documentation:

### Screen/Flow Changes
- Capture in `foundation_documentation/screens/*.md`
- Reference DTO contracts in `modules/` where applicable

### Mock Payload/Schema Changes
- Record in `foundation_documentation/screens/prototype_data.md`
- Refresh DTO notes in `foundation_documentation/domain_entities.md` when vocabulary evolves

### Roadmap Updates
- Update `mock_roadmap.md`, `system_roadmap.md`, `submodule_flutter-app_summary.md`
- Ensure Laravel and other consumers see new scope before implementation

### Exception: Maintenance/Regression Fix Lane
If restoring previously documented behavior and existing docs already match intended behavior:
- Documentation updates NOT required
- Record evidence in ephemeral TODO
- If docs are missing or incorrect, use tactical TODO lane and update docs first

## Rationale

Per Project Mandate P-B6 ("Documentation Before Code"), the Flutter prototype defines launch contracts for Laravel and future clients. Keeping docs ahead of code prevents schema drift and maintains domain traceability.

## Enforcement

### Must Verify
- [ ] PRs link to refreshed documentation sections
- [ ] DTO changes have `domain_entities.md` updates
- [ ] Mock changes have `prototype_data.md` updates
- [ ] Roadmap entries exist for new APIs

### Block Changes That
- Modify DTOs without `domain_entities.md` update
- Change mocks without `prototype_data.md` update
- Alter UI flows without screen documentation
- Add new domains without entity documentation

### Validation Tools
```bash
# Verify context
bash delphi-ai/verify_context.sh

# Check referenced files exist
ls foundation_documentation/domain_entities.md
ls foundation_documentation/screens/
```

## Documentation Flow

```
1. Update domain_entities.md
2. Update prototype_data.md (if mocks affected)
3. Update screens/*.md (if UI affected)
4. Update system_roadmap.md
5. THEN implement code changes
```

## Quick Reference

| Change Type | Required Documentation |
|-------------|------------------------|
| New DTO field | `domain_entities.md` |
| New mock payload | `prototype_data.md` |
| New screen | `screens/*.md` |
| New API needed | `system_roadmap.md` |
| New domain | `domain_entities_sections/*` |

## Notes

If new domains are introduced:
1. Update `foundation_documentation/domain_entities_sections/*` first
2. Regenerate DTO/prototype data references
3. Include roadmap deltas in `system_roadmap.md`
