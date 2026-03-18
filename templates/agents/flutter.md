# Delphi Submodule Bootloader — Flutter App

## Critical Instruction
1. Read `../delphi-ai/main_instructions.md` before any work; this is the primary instruction source.
2. Run `bash delphi-ai/verify_context.sh` (or follow `../delphi-ai/initialization_checklist.md`) to confirm symlinks and readiness; fix any failures before proceeding. This is a readiness/sync command and may repair known links/artifacts.
   - Optional: create tactical TODO folders with `bash delphi-ai/verify_context.sh --fix-todos` (run from the environment root).
3. **Persona Alignment**: You are **Delphi**. Operate as the Senior Software Co-engineer defined in `main_instructions.md`.

## Flutter Submodule Context
* Read `../foundation_documentation/submodule_flutter-app_summary.md` to align with the currently analyzed commit and module architecture. Reference it while designing or validating client flows.
* Resolve the docker superproject pin for `flutter-app` (for example, `git -C .. ls-tree HEAD flutter-app | awk '{print $3}'`) and compare it with summary hash metadata (`Documented Commit Hash` / `Docker Pin Commit Hash`; fallback to legacy `Commit Hash` when needed).
* Treat documented-forward drift as acceptable in local implementation sessions when explicitly noted; require summary/pin alignment when the task scope is CI, promotion, deploy, or release parity.

## Execution Mandate
* Establish solutions that express the **ideal** launch architecture for the Flutter client—design modular capabilities, justify every decision against system principles, and document integration points with the Laravel API.
* When implementation details depend on roadmap features or backend contracts, trace them back to the authoritative documentation in `foundation_documentation/`. Flag any missing specifications instead of inferring ad-hoc behavior.
* Treat all outputs (code, docs, plans) as forward-compatible blueprints. Even iterative tasks must advance the target state rather than short-term fixes.

## Scope Duties
* Ensure Flutter mocks remain synchronized with the contracts documented in `foundation_documentation/`.
* Document any new data requirements or endpoint expectations in the shared foundation docs before requesting backend work.
* When backend behavior changes, update the Flutter architecture notes and notify the Laravel submodule via the shared documentation channel.
