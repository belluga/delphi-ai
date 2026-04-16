# Documentation: Delphi Initialization Checklist

This checklist ensures every working copy—full repository or scoped submodule—loads the same canonical instructions and foundation documentation before any engineering work begins.

## Zero-State Bootstrap Exception

When the repository is still in zero-state and the active profile is `Genesis / Product-Bootstrap`, missing project-owned authority surfaces are valid bootstrap outputs, not readiness failures.

Use this path instead of treating the checklist as failed:
1. Run `bash delphi-ai/init.sh --check`.
2. If there are no Delphi-managed path conflicts, run `bash delphi-ai/init.sh`.
3. Instantiate the first canonical package under `foundation_documentation/`.
4. Return to `bash delphi-ai/verify_context.sh` after the downstream shape exists or when full readiness validation is intentionally needed.

## 1. Required Shared Artifacts
1. `foundation_documentation/` exists at the repository root and contains the authoritative project-specific context.
   - Zero-state exception: during `Genesis / Product-Bootstrap`, this directory may be absent at the start of the session because creating it is part of the bootstrap output.
2. `delphi-ai/` exists at the repository root and contains the persona, principles, templates, and this checklist.
3. `foundation_documentation/policies/scope_subscope_governance.md` exists and is available as canonical scope/subscope policy.
   - Zero-state exception: this policy may be missing before the first canonical package is instantiated.
4. Each submodule (e.g., `flutter-app/`, `laravel-app/`) exposes the shared documentation through symlinks:
   - `foundation_documentation -> ../foundation_documentation`
   - (optional) `delphi-ai -> ../delphi-ai` if the submodule is opened standalone.

## 2. Verification Script
Run the automated check (recommended from the repository root; safe from subdirectories as well):
```bash
bash delphi-ai/verify_context.sh
```
The script is read-only by default. It validates the presence of the root documentation and confirms each submodule links to it.
It is a readiness check only; governance mirror validation remains a separate command:
```bash
bash delphi-ai/verify_adherence_sync.sh
```

If the verification fails only because Delphi-managed links/artifacts are missing or misaligned, run:
```bash
bash delphi-ai/verify_context.sh --repair
```
Then rerun plain `bash delphi-ai/verify_context.sh`.

If the repository is still zero-state and the active session is `Genesis / Product-Bootstrap`, do not treat `verify_context.sh` failure on missing `foundation_documentation/`, submodules, or `.env` as a blocker for selecting Genesis. Use the exception path above instead.

Optional: if you want Delphi’s tactical TODO folders created, run:
```bash
bash delphi-ai/verify_context.sh --repair --fix-todos
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
4. Review `foundation_documentation/project_mandate.md` (confirm current architecture mode), `foundation_documentation/domain_entities.md`, and the relevant sections of `foundation_documentation/system_roadmap.md` so active initiatives are understood before touching code.
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
- **Plan Tracking**: Cline's built-in `task_progress` may help with local planning, but it does **not** replace Delphi's tactical TODO + `APROVADO` + Decision Adherence gates when those are required by the instructions

### Codex / Antigravity
- **Bootloader**: `AGENTS.md` at repository root
- **Skills**: `.codex/skills/` symlinked to `delphi-ai/skills/`
- **Rules/Workflows**: Managed via `.agents/` symlinked directories

### Gemini
- **Bootloader**: `GEMINI.md` at repository root
- **Skills**: `.agents/skills/` directory

### Setup
Optional preflight:
```bash
bash delphi-ai/init.sh --check
```
This preflight may be invoked from the repository root or from supported app submodules that expose `delphi-ai -> ../delphi-ai`; the helper should normalize back to the downstream environment root before evaluating Delphi-managed paths.

Run the setup script to create all necessary symlinks:
```bash
bash delphi-ai/init.sh
```
This helper also attempts to link `.agents` rules/workflows for the root repo and supported app submodules.

Or run the verification script to ensure all links are in place:
```bash
bash delphi-ai/verify_context.sh
```
Then run the adherence sync validation if you need governance mirror proof:
```bash
bash delphi-ai/verify_adherence_sync.sh
```

Maintaining this checklist guarantees that every scope—main repo, Flutter app, or Laravel app—operates on the same architectural truth.
