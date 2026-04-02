---
description: Establish domain-aligned data access for Flutter features, keeping DTO knowledge in infrastructure and enforcing the architecture mandates (Section 5 Data Flow, Section 8 DI).
---

# Method: Create Repository (Flutter)

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

## Procedure
1. **Run Persona Selection** – confirm Flutter Engineer persona.
2. **Define domain contract**
   - Update/create `lib/domain/repositories/<name>_repository_contract.dart` using domain verbs (no “screen” references). Annotate temporary projection returns with TODOs if the full entity is pending.
3. **Design DTO mapper**
   - Implement/update `lib/infrastructure/mappers/<feature>_dto_mapper.dart` to translate DTOs → ValueObjects.
   - Keep slugging/formatting helpers inside the mapper to avoid leaks.
4. **Design DAO/decoder transport boundary**
   - Keep raw response parsing (`data/meta` envelopes, list extraction, map casts) inside DAO/decoder artifacts under infrastructure.
   - For write operations, define typed request DTO/command builders at DAO boundary (including multipart/form-data assembly).
   - Repository methods must not declare/build/parse raw transport maps (`Map<String, Object?>`, `as Map` payload casts, inline payload map assembly).
5. **Implement repository**
   - Add `lib/infrastructure/repositories/<name>_repository.dart` that mixes in the mapper and talks to typed DAO/backends (`DTO in`, `Domain/Projection out`).
   - Ensure no presentation imports appear and no raw transport handling is owned by repository methods.
6. **Dependency injection**
   - Register the repository in `module_settings.dart` or the relevant module scope via `registerLazySingleton` / `registerFactory`.
7. **Controller adoption**
   - Update controllers/services to depend on the contract (GetIt injection). Remove any direct DTO parsing.
8. **Documentation touch**
   - Note repository availability in the affected module docs and `foundation_documentation/system_roadmap.md` if it unlocks new behavior.
   - Update `foundation_documentation/system_roadmap.md` with the new capability or technical debt payoff when it affects planned work.
9. **Verification**
   - Run `fvm flutter analyze`; add/re-run unit tests covering the repository/user of it.
   - When the debt program requires branch-delta enforcement for disabled rules, run the branch guard command (example: `bash tool/belluga_analysis_plugin/bin/check_branch_delta_raw_payload_map.sh`).

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
