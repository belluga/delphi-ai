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

## Architecture Diagnostics Gate (Official)
* When multiple first-party packages form one product, declare a Pub Workspace and require the full-workspace static-analysis gate to cover every member. Never recover performance by excluding product code, using only open files, allowing only selected paths, or disabling custom rules.
* The agent must not start `dart analyze`, `flutter analyze`, `custom_lint`, or another concurrent analyzer in an editor-managed workspace. Read the Dart Analysis Server result through the project-declared read-only VS Code Problems bridge instead.
* The bridge evidence must query its health endpoint and a full Flutter-workspace scoped snapshot, record workspace folders, diagnostic revision, timestamp, and payload hash, and become stable across the project-declared quiet interval. Any `Error` or `Warning` blocks the gate. Retained `Information` diagnostics require explicit TODO classification.
* A bridge snapshot is current Problems evidence, not a proof that the public VS Code API observed Analysis Server completion. Label it accurately and do not substitute append-only LSP/analyzer logs. If the bridge is unavailable, unstable, or points at the wrong workspace, static analysis is blocked; do not fall back to the CLI.
* A pipeline may retain its project-owned analyzer job as separate CI evidence. For a deliberate editor recovery after workspace changes, use `Dart: Restart Analysis Server`; never kill the language-server process. Use `Dart: Open Analyzer Diagnostics / Insights` and `dart info record-performance` only for persistent performance diagnosis.
* If local analyzer state becomes inconsistent, run the project-owned reset script. In a Pub Workspace it must rehydrate the workspace once and any explicitly isolated expected-invalid lint fixture separately. The fixture matrix remains mandatory and cannot be used to exclude product code from the full gate.
* Treat mismatched editor SDK selection as analyzer drift: `dart.sdkPath` must resolve inside the active `dart.flutterSdkPath` / FVM version for the workspace.
* Do not use an edited-file or directory-only Problems snapshot as architecture source of truth in this workspace.
* Treat `tool/belluga_analysis_plugin` as the PACED ecosystem-global analyzer plugin default. Project-local analyzer plugins must be declared in `foundation_documentation` and analyzer config before use.
* Keep `bash ${PACED_GLOBAL_ANALYZER_PLUGIN_DIR:-tool/belluga_analysis_plugin}/bin/validate_rule_matrix.sh` as fixture coverage validation for global rule activation.
* Do not use `fvm dart run custom_lint` as architecture source of truth in this workspace.
* At every sequential/orchestration checkpoint that changes Flutter, complete the stable full-workspace Problems snapshot plus matching architecture/rule review, then only the affected-area tests/builds. Do not carry analyzer errors/warnings to the next checkpoint. Reserve `stage-full` and broad CI-equivalent test/runtime proof for integrated package closeout.
