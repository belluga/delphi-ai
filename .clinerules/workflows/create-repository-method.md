---
name: "create-repository-method"
description: "Establish domain-aligned data access for Flutter features, keeping DTO knowledge in infrastructure and enforcing the architecture mandates (Section 5 Data Flow, Section 8 DI)."
---

<!-- Generated from `workflows/flutter/create-repository-method.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# Workflow: Create Repository (Flutter)

## Purpose
Establish domain-aligned data access for Flutter features, keeping DTO knowledge in infrastructure and enforcing the architecture mandates (Section 5 Data Flow, Section 8 DI).

## Triggers
- A new Flutter domain requires persistence/read APIs.
- Existing repositories mix multiple aggregates or leak screen terminology.
- Backend contracts change, requiring new DTO mappers.

## Inputs
- Domain contract + projections (`lib/domain/**`).
- Architecture docs + backend DTO definitions.
- DI configuration files.

## Preferred Deterministic Helper
- Use `bash delphi-ai/tools/flutter_workflow_scaffold.sh --kind repository --name <repository_name> [--feature <feature>] [--output <path>]` to scaffold the repeatable repository contract/mapper/validation checklist before implementation.
- When exact-lookup paths are created or changed, run `bash delphi-ai/tools/exact_lookup_anti_pattern_audit.sh --path <flutter-repository-path>` to catch list-scan/page-walk heuristics.

## Procedure
1. **Package-First gate** – run `bash delphi-ai/tools/query_packages.sh --project-root <path> --search "<keyword>"` to query proprietary packages and check whether an existing Flutter library already provides the data access layer or repository contract for this domain. If a matching library exists, extend it. Record the Package-First Assessment in the TODO. See `paced.core.package-first`.
2. **Run Profile Selection** – confirm `Operational / Coder` with `flutter` scope.
3. **Define domain contract**
   - Update/create `lib/domain/repositories/<name>_repository_contract.dart` using domain verbs (no “screen” references). Annotate temporary projection returns with TODOs if the full entity is pending.
4. **Design DTO mapper**
   - Implement/update `lib/infrastructure/mappers/<feature>_dto_mapper.dart` to translate DTOs → ValueObjects.
   - Keep slugging/formatting helpers inside the mapper to avoid leaks.
5. **Design DAO/decoder transport boundary**
   - Keep raw response parsing (`data/meta` envelopes, list extraction, map casts) inside DAO/decoder artifacts under infrastructure.
   - For write operations, define typed request DTO/command builders at DAO boundary (including multipart/form-data assembly).
   - Repository methods must not declare/build/parse raw transport maps (`Map<String, Object?>`, `as Map` payload casts, inline payload map assembly).
6. **Implement repository**
   - Add `lib/infrastructure/repositories/<name>_repository.dart` that mixes in the mapper and talks to typed DAO/backends (`DTO in`, `Domain/Projection out`).
   - Ensure no presentation imports appear and no raw transport handling is owned by repository methods.
   - Exact-key fetches (`slug|id|uuid|code|handle|key`) must not iterate paginated list endpoints or scan in-memory collections when a direct endpoint/contract should exist.
7. **Dependency injection**
   - Register the repository in `module_settings.dart` or the relevant module scope via `registerLazySingleton` / `registerFactory`.
8. **Controller adoption**
   - Update controllers/services to depend on the contract (GetIt injection). Remove any direct DTO parsing.
9. **Documentation touch**
   - Note repository availability in the affected module docs and `foundation_documentation/system_roadmap.md` if it unlocks new behavior.
   - Update `foundation_documentation/system_roadmap.md` with the new capability or technical debt payoff when it affects planned work.
10. **Verification**
   - Run `fvm flutter analyze`; add/re-run unit tests covering the repository/user of it.
   - When the debt program requires branch-delta enforcement for disabled rules, run the branch guard command (example: `bash tool/belluga_analysis_plugin/bin/check_branch_delta_raw_payload_map.sh`).
   - When exact-lookup paths were touched, run `bash delphi-ai/tools/exact_lookup_anti_pattern_audit.sh --path <touched-path>` and classify every finding before delivery.

## Outputs
- Repository contract + implementation files.
- DTO mapper mixins covering new conversions.
- DI registration + controller usage.
- Documentation/roadmap notes if scope changed.

## Validation
- Analyzer/tests pass.
- Controllers/widgets import only the contract, not DTOs.
- DTO handling remains infrastructure-only.
- Repository methods do not own raw payload maps (`Map<String, Object?>`) for transport parsing/building.
