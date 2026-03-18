# Documentation: Delphi Initialization Checklist

This checklist ensures every working copy—full repository or scoped submodule—loads the same canonical instructions and foundation documentation before any engineering work begins.

## 1. Required Shared Artifacts
1. `foundation_documentation/` exists at the repository root and contains the authoritative project-specific context.
2. `delphi-ai/` exists at the repository root and contains the persona, principles, templates, and this checklist.
3. `foundation_documentation/policies/scope_subscope_governance.md` exists and is available as canonical scope/subscope policy.
4. Each submodule (e.g., `flutter-app/`, `laravel-app/`) exposes the shared documentation through symlinks:
   - `foundation_documentation -> ../foundation_documentation`
   - (optional) `delphi-ai -> ../delphi-ai` if the submodule is opened standalone.

## 2. Verification Script
Run the automated check (recommended from the repository root; safe from subdirectories as well):
```bash
bash delphi-ai/verify_context.sh
```
The script validates the presence of the root documentation and confirms each submodule links to it. Extend the script as additional shared artifacts become necessary.

Optional: if you want Delphi’s tactical TODO folders created, run:
```bash
bash delphi-ai/verify_context.sh --fix-todos
```

## 3. Manual Remediation Steps
If the script reports missing links:
1. Ensure you are inside the repository root that contains `foundation_documentation/`.
2. Recreate the symlink for the affected module, e.g.:
   ```bash
   ln -s ../foundation_documentation flutter-app/foundation_documentation
   ```
3. Rerun the verification script until it passes.

## 4. Bootloader Expectations
After verification:
1. Open `delphi-ai/main_instructions.md` to load the Delphi persona.
2. Read `delphi-ai/system_architecture_principles.md` (including appendices) to refresh the cross-stack mandates.
3. Read `foundation_documentation/policies/scope_subscope_governance.md` before any route/module/screen task.
4. Review `foundation_documentation/project_mandate.md` (confirm current architecture mode), `foundation_documentation/domain_entities.md`, _and_ `foundation_documentation/persona_roadmaps.md` so active initiatives per persona are understood before touching code.
5. Consult each submodule's `AGENTS.md`. Confirm it points to `../delphi-ai/main_instructions.md`, references the verification script, and enumerates the scope-specific duties before proceeding.

For route-related sessions, explicitly confirm this policy context is loaded:
- `EnvironmentType` is binary (`landlord|tenant`),
- approved main scope/subscope catalog is fixed unless explicitly re-decided.

## 5. AI Agent Integration

Delphi supports multiple AI coding agents with agent-specific instruction loading:

### Cline
- **Bootloader**: `CLINE.md` at repository root
- **Rules**: `.clinerules/` directory (auto-loaded by Cline)
- **Artifacts**: `.cline/skills/`, `.clinerules/workflows/`, `.clinerules/hooks/` (symlinked to `delphi-ai/.cline/` and `delphi-ai/.clinerules/`)
- **Plan Tracking**: Uses Cline's built-in `task_progress` feature instead of external TODO files

### Codex / Antigravity
- **Bootloader**: `GEMINI.md` at repository root
- **Skills**: `.codex/skills/` symlinked to `delphi-ai/skills/`
- **Rules/Workflows**: Managed via `.agent/` directories

### Setup
Run the setup script to create all necessary symlinks:
```bash
bash delphi-ai/init.sh
```

Or run the verification script to ensure all links are in place:
```bash
bash delphi-ai/verify_context.sh
```

Maintaining this checklist guarantees that every scope—main repo, Flutter app, or Laravel app—operates on the same architectural truth.
