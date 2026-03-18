---
name: rule-flutter-flutter-repository-workflow-glob
description: "Rule: MUST use whenever the scope matches this purpose: Edits in `flutter-app/lib/infrastructure/repositories/**` must run the Repository Workflow:."
---

## Rule
Edits in `flutter-app/lib/infrastructure/repositories/**` must run the Repository Workflow:
- Maintain DTO → Domain mapping discipline; no DTO leakage.
- Keep raw transport payload ownership in DAO/DTO boundaries:
  - repositories must not parse/build raw payload maps (`Map<String, Object?>`, envelope extraction, `as Map` casts, inline map payload assembly),
  - repositories consume typed DAO/decoder outputs and return domain/projection models.
- For write flows, use typed request DTO/command payload builders at DAO boundary (including multipart assembly).
- Document pagination/filtering contracts and sync Laravel roadmap entries when APIs are implied.
- Update mock data/DTO docs before merging.

## Rationale
Repositories define how Flutter consumes domain contracts. The workflow keeps them aligned with documentation and backend expectations.

## Enforcement
- Execute the Repository Workflow steps for these paths.
- Require PR references to updated docs/roadmaps.
- Run branch-delta guard when enabled by the active debt program (example: `bash tool/belluga_custom_lint/bin/check_branch_delta_raw_payload_map.sh`).
- If a branch-touched repository still contains legacy raw-map handling, either refactor it in the same branch or explicitly track the exception in the active VNext debt TODO before delivery.

## Notes
Workflow reference: `delphi-ai/workflows/flutter/create-repository-method.md`.
