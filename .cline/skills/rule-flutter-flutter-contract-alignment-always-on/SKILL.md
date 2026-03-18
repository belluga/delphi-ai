---
name: rule-flutter-flutter-contract-alignment-always-on
description: "Rule: MUST use whenever the scope matches this purpose: Maintain bidirectional contract alignment:."
---

## Rule
Maintain bidirectional contract alignment:
- Map every Flutter DTO/model to the governing entity in `foundation_documentation/domain_entities.md`; update the summaries when attributes change.
- Preserve repository/DAO transport contract boundaries in docs and implementation:
  - DAO/decoder owns raw payload envelopes/maps,
  - repository consumes typed outputs and returns domain/projection models.
- When Flutter repositories alter pagination/filtering or new endpoints are implied, log the requirement in `foundation_documentation/system_roadmap.md` and the Laravel roadmap section so backend teams can plan matching APIs.
- Sync mock data with real contract expectations: regenerate JSON fixtures when DTOs change and notify Laravel via `submodule_laravel-app_summary.md` notes.
- Record integration dependencies (e.g., tenant app data, feature flags) in `project_mandate.md` or module docs before implementing them in Flutter.

## Rationale
Flutter is the lead consumer of the platform’s Core Business Entities. Keeping contracts synchronized avoids Laravel/API divergence and ensures every mock artifact is a dependable specification.

## Enforcement
- Reviews must verify DTO → entity mapping and roadmap updates accompany any repository or API-facing change.
- Reviews must verify repository raw-map handling is not owned by repositories; violations require DAO/DTO boundary refactor or explicit debt tracking.
- Reject commits that adjust mocks/DTOs without updating the corresponding roadmap/module documentation.
- Compare `submodule_flutter-app_summary.md` hash metadata against the docker superproject gitlink (`git ls-tree HEAD flutter-app`), not `.gitmodules` text values.
- Allow documented forward drift in local implementation sessions, but require summary/pin alignment for CI, promotion, deploy, and release parity scopes.

## Notes
Use the persona roadmaps and module templates when a Flutter change creates backend work. Surface dependencies to Laravel/DevOps via roadmap entries as soon as they’re known.
