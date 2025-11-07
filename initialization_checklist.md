# Documentation: Delphi Initialization Checklist

This checklist ensures every working copy—full repository or scoped submodule—loads the same canonical instructions and foundation documentation before any engineering work begins.

## 1. Required Shared Artifacts
1. `foundation_documentation/` exists at the repository root and contains the authoritative project-specific context.
2. `delphi-ai/` exists at the repository root and contains the persona, principles, templates, and this checklist.
3. Each submodule (e.g., `flutter-app/`, `laravel-app/`) exposes the shared documentation through symlinks:
   - `foundation_documentation -> ../foundation_documentation`
   - (optional) `delphi-ai -> ../delphi-ai` if the submodule is opened standalone.

## 2. Verification Script
Run the automated check from the repository root:
```bash
bash delphi-ai/tools/verify_context.sh
```
The script validates the presence of the root documentation and confirms each submodule links to it. Extend the script as additional shared artifacts become necessary.

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
2. Read `foundation_documentation/project_mandate.md` and `foundation_documentation/domain_entities.md` before touching code.
3. Consult each submodule’s `AGENTS.md`. Confirm it points to `../delphi-ai/main_instructions.md`, references the verification script, and enumerates the scope-specific duties before proceeding.

Maintaining this checklist guarantees that every scope—main repo, Flutter app, or Laravel app—operates on the same architectural truth.
