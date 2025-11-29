---
activation_mode: always_on
summary: Keep Laravel contracts aligned with domain entities and Flutter clients.
---

## Rule
Maintain bidirectional contract alignment:
- Map every API/DTO to the governing entity in `foundation_documentation/domain_entities.md`; update summaries when fields change.
- When endpoints change pagination/filtering or introduce new resources, log the requirement in `foundation_documentation/system_roadmap.md` and the Laravel roadmap section; flag Flutter if payloads shift.
- Sync request/response schemas with Flutter mocks and DTOs; update `foundation_documentation/screens/prototype_data.md` and module docs before merging.
- Record ingress/routing changes so DevOps can update manifests.

## Rationale
Laravel APIs must mirror the platform’s Core Business Entities and client contracts. Keeping documentation and roadmaps current avoids client/API divergence.

## Enforcement
- Reviews must verify DTO ↔ domain mapping and roadmap updates for API-facing changes.
- Block commits that alter payloads without updating documentation and roadmap entries.
- Ensure ingress updates are tracked when route groups change.

## Notes
Use submodule summaries to confirm commit hashes and surface desyncs; request updated summaries if stale.
