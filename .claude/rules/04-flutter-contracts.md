---
description: "Maintain bidirectional contract alignment between Flutter and backend — DTO/entity mapping, API sync, mock data, and documentation-first mandates"
globs: ["flutter-app/**"]
alwaysApply: false
---

# Flutter Contract Alignment & Documentation

## Contract Alignment Rule

Maintain bidirectional contract alignment between Flutter and backend:

- Map every Flutter DTO/model to the governing entity in `foundation_documentation/domain_entities.md` and update summaries when attributes change.
- When Flutter repositories alter pagination/filtering, log in `foundation_documentation/system_roadmap.md` and update Laravel roadmap section.
- Regenerate JSON fixtures when DTOs change and ensure mocks match real contract expectations.
- Record integration dependencies in `project_mandate.md` or module docs.
- Keep repository/DAO transport contracts aligned: raw payload maps/envelopes are DAO/decoder ownership, repositories stay typed.

## Documentation-First Rule

Before touching Flutter code or mocks, update the authoritative documentation:

- Screen/flow changes: capture in `foundation_documentation/screens/*.md`.
- Mock payload/schema changes: record in `foundation_documentation/screens/prototype_data.md`.
- Roadmap updates: update `mock_roadmap.md`, `system_roadmap.md`, `submodule_flutter-app_summary.md`.

### Exception: Maintenance/Regression Fix Lane

If restoring previously documented behavior and existing docs already match intended behavior, documentation updates are NOT required. Record evidence in ephemeral TODO. If docs are missing or incorrect, use tactical TODO lane and update docs first.

## Quick Reference

| Change Type | Required Documentation |
|---|---|
| New DTO | `domain_entities.md` entry |
| DTO field change | Update entity, regenerate mocks |
| Repository change | `system_roadmap.md` entry |
| New endpoint needed | Roadmap + Laravel section |
| Feature flag | `project_mandate.md` |
| New screen | `screens/*.md` |
| New mock payload | `prototype_data.md` |
| New domain | `domain_entities_sections/*` |

## Enforcement

Reject commits that adjust mocks/DTOs without updating documentation, add new endpoints without roadmap entry, or change pagination/filtering without backend coordination.
