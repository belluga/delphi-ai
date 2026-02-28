---
description: Ensure the working copy is correctly wired (symlinks, scripts, submodules, permissions, README steps) before DevOps/CI work proceeds.
---

# Method: DevOps Environment Readiness

## Purpose
Ensure the working copy is correctly wired (symlinks, scripts, submodules, permissions, README steps) before executing DevOps or CI/CD tasks. Prefer deterministic script checks over manual spot-checks to prevent drift (e.g., `web-app` not being a submodule, broken `/storage` routing).

## Triggers
- User explicitly requests DevOps/setup help.
- Session starts in a repository that might not be the canonical boilerplate.
- Before running scripts that depend on submodules (Laravel, Flutter, web bundle).

## Inputs
- Root repository (`festou_docker` or downstream clone).
- `.gitmodules` and current submodule working trees.
- Project README instructions.
 - `foundation_documentation` submodule (expected for all projects; add if missing).

## Procedure
1. **Confirm repository context**
   - Identify whether we are in the canonical boilerplate repo or a downstream project.
   - If downstream, note the expected remotes (e.g., `belluga/festou_api`, `belluga/festou_app`, `belluga/festou_web`).

2. **Run canonical readiness scripts (preferred)**
   - Run Delphi context checks (symlinks, required folders):
     - `bash delphi-ai/tools/verify_context.sh`
   - Run the project readiness verifier (compose config + critical drift checks):
     - `bash scripts/verify_environment.sh`
   - If either script fails, fix the reported issue before proceeding.

3. **Validate submodules (only if needed)**
   - Run `git submodule status --recursive` and ensure each submodule is checked out; no entry should start with `-` (uninitialized) or `+` (detached from the recorded commit in `.gitmodules`).
   - Ensure `foundation_documentation` is present as a submodule; if missing, add it using the canonical docs repo before proceeding.
   - If any discrepancies appear, execute `git submodule sync --recursive && git submodule update --init --recursive` to realign the working trees with the recorded commit hashes before continuing.
   - For each entry in `.gitmodules`, confirm the URL points to the project’s own repo, not `belluga/boilerplate_*`. If any still reference boilerplate sources, guide the user to `git submodule set-url` the correct fork before proceeding.

4. **Filesystem ownership**
   - Spot-check key files (`laravel-app/.env`, `flutter-app`, `web-app`) and ensure they are writable by the host/WSL user. If ownership reflects container/root users, instruct the user to `chown` the directories before continuing.

5. **Symlinked scripts**
   - Verify helper scripts exist and resolve (`flutter-app/scripts` must symlink to `../delphi-ai/scripts/flutter`). If missing, recreate the link so Flutter uses the canonical build helpers.

6. **README alignment**
   - If the user is in setup mode, walk through the relevant README sections (env variables, submodule init, Docker commands) and confirm each step is complete. Use the README as the canonical checklist for new environments.

7. **Report status**
   - Summarise any discrepancies (missing submodule, wrong remote, permission issue) and the remediation steps provided.
   - Only proceed with further DevOps work (builds, deployments, CI tasks) after the environment is confirmed healthy.

## Outputs
- Status summary of submodules, permissions, and scripts.
- Action items (if any) for the user to fix before running builds/deploys.
