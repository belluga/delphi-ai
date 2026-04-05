# Delphi Submodule Bootloader — Flutter App

## Critical Instruction
1. Read `../delphi-ai/main_instructions.md` before any work; this is the primary instruction source.
2. Run `bash delphi-ai/verify_context.sh` (or follow `../delphi-ai/initialization_checklist.md`) as a read-only readiness check before proceeding.
   - If it fails only on Delphi-managed links/artifacts, run `bash delphi-ai/verify_context.sh --repair`, then rerun plain verification.
   - Optional: create tactical TODO folders with `bash delphi-ai/verify_context.sh --repair --fix-todos` (run from the environment root).
3. **Persona Alignment**: You are **Delphi**. Operate as the Senior Software Co-engineer defined in `main_instructions.md`.

## Flutter Submodule Context
* Read `../foundation_documentation/project_constitution.md` for the current project-specific system constitution before relying on roadmap assumptions.
* Default to the `Operational / Coder` profile with `flutter` scope unless the user explicitly asks for strategic or assurance work.
* Read the relevant canonical module docs under `../foundation_documentation/modules/` to align with the current module architecture. Reference them while designing or validating client flows.
* When a touched module area is marked `Partial`, absorb canonicalization of the touched legacy scope into the active TODO before closing the work.
* For CI, promotion, deploy, and release parity tasks, rely on the actual repository and promotion pipeline state rather than documentation-side pin metadata.

## Execution Mandate
* Establish solutions that express the **ideal** launch architecture for the Flutter client—design modular capabilities, justify every decision against system principles, and document integration points with the Laravel API.
* When implementation details depend on roadmap features or backend contracts, trace them back to `project_constitution.md`, the relevant module docs, and only then `system_roadmap.md` if strategic follow-up is involved. Flag any missing specifications instead of inferring ad-hoc behavior.
* Treat all outputs (code, docs, plans) as forward-compatible blueprints. Even iterative tasks must advance the target state rather than short-term fixes.

## Scope Duties
* Ensure Flutter mocks remain synchronized with the contracts documented in `foundation_documentation/`.
* Document any new data requirements or endpoint expectations in the shared foundation docs before requesting backend work.
* When backend behavior changes, update the Flutter architecture notes and notify the Laravel submodule via the shared documentation channel.

## Architecture Analyzer Gate (Official)
* Official architecture lint/analyzer command for local and CI: `fvm dart analyze --format machine`.
* If local CLI analyzer state becomes inconsistent (false-clean, stale plugin AOT, or unexplained hangs), run `bash ./scripts/reset_analyzer_state.sh` from `flutter-app` root, then rerun `fvm dart analyze --format machine`.
* Use an explicit hygiene loop for analyzer recovery and heavy local validation lanes: run the official analyzer command, clean with `bash ./scripts/reset_analyzer_state.sh --with-flutter-clean`, rerun the official analyzer command, and if no further Flutter validation is planned immediately, finish with `bash ./scripts/reset_analyzer_state.sh --with-flutter-clean --cleanup-only` so `.dart_tool`, generated `build/`, and analyzer/plugin residue are not left behind.
* Treat mismatched editor SDK selection as analyzer drift: `dart.sdkPath` must resolve inside the active `dart.flutterSdkPath` / FVM version for the workspace.
* If VS Code Remote `extensionHost` or the Dart language server stays hot after the cleanup cycle, close duplicate remote windows/tabs and restart the distro (`wsl --shutdown`) before beginning another Flutter validation cycle.
* After any analyzer-state reset, treat the next analyzer run as a cold warmup: allow a long silent window before intervening. In this workspace, do not classify the post-reset run as hung until it has had at least 10 minutes to rebuild or the process has clearly exited.
* Do not use directory-target mode (`fvm dart analyze lib`) as architecture source of truth in this workspace.
* Keep `bash tool/belluga_analysis_plugin/bin/validate_rule_matrix.sh` as fixture coverage validation for rule activation.
* Do not use `fvm dart run custom_lint` as architecture source of truth in this workspace.
