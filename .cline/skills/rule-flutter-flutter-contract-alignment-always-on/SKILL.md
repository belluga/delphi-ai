---
name: rule-flutter-flutter-contract-alignment-always-on
description: "Rule: MUST use whenever the scope matches this purpose: Keep Flutter contracts aligned with domain entities and downstream teams."
---

## Rule
Maintain bidirectional contract alignment:
- Map every Flutter DTO/model to the governing entity in `foundation_documentation/domain_entities.md`; update the affected canonical module docs when attributes change.
- Preserve repository/DAO transport contract boundaries in docs and implementation:
  - DAO/decoder owns raw payload envelopes/maps,
  - repository consumes typed outputs and returns domain/projection models.
- When Flutter repositories alter pagination/filtering or new endpoints are implied, log the requirement in `foundation_documentation/system_roadmap.md` and the affected module docs so backend teams can plan matching APIs.
- Sync mock data with real contract expectations: regenerate JSON fixtures when DTOs change and notify Laravel via shared module docs and roadmap updates.
- Record integration dependencies (e.g., tenant app data, feature flags) in `project_mandate.md` or module docs before implementing them in Flutter.

## Rationale
Flutter is the lead consumer of the platform’s Core Business Entities. Keeping contracts synchronized avoids Laravel/API divergence and ensures every mock artifact is a dependable specification.

## Enforcement
- Reviews must verify DTO → entity mapping and roadmap updates accompany any repository or API-facing change.
- Reject commits that adjust mocks/DTOs without updating the corresponding roadmap/module documentation.
- Reject commits that introduce repository-owned raw transport map parsing/building without corresponding DAO/DTO boundary refactor and TODO tracking.

## Notes
Use canonical module docs plus `system_roadmap.md` when a Flutter change creates backend work. Surface Laravel/DevOps dependencies in the shared roadmap as soon as they’re known.
