---
name: wf-docker-environment-readiness-method
description: "Workflow: MUST use whenever the scope matches this purpose: Ensure the working copy is correctly wired (symlinks, scripts, submodules, permissions, README steps) before DevOps/CI work proceeds."
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

## Preferred Deterministic Helper
- Default read-only readiness report:
  - `bash delphi-ai/tools/environment_readiness_report.sh`
- Include adherence-sync verification when the environment is expected to be fully wired:
  - `bash delphi-ai/tools/environment_readiness_report.sh --include-adherence-sync`
- For zero-state Genesis bootstrap, treat this helper as supporting evidence only. A `zero-state-ready` outcome means the install preflight passed; it does not replace Genesis canonicalization work.
- For mature downstream environments, use the report first, then follow the method for any required repair path (`verify_context.sh --repair`, project-owned fixes, or deeper environment normalization).

## Procedure
1. **Confirm repository context**
   - Identify whether we are in the canonical boilerplate repo or a downstream project.
   - If downstream, note the expected remotes (e.g., `belluga/festou_api`, `belluga/festou_app`, `belluga/festou_web`).

2. **Run canonical readiness scripts (preferred)**
   - Run Delphi context checks (symlinks, required folders):
     - `bash delphi-ai/verify_context.sh`
     - Treat this as read-only verification. If it fails only on Delphi-managed links/artifacts, run `bash delphi-ai/verify_context.sh --repair`, then rerun plain verification. If it fails on a path conflict with project-owned files/directories, stop and report it for manual remediation.
   - Run the project readiness verifier (compose config + critical drift checks):
     - `bash scripts/verify_environment.sh`
   - If either script fails, fix the reported issue before proceeding.

3. **Validate submodules (only if needed)**
   - Run `git submodule status --recursive` and ensure each submodule is checked out; no entry should start with `-` (uninitialized) or `U` (merge conflict on gitlink state).
   - Treat entries starting with `+` as local workspace drift (tracking mode) rather than immediate failure.
   - If the task requires CI/deploy parity, normalize to pinned mode before proceeding: prefer `tools/submodules/pin_to_superproject.sh` when available, otherwise run `git submodule sync --recursive && git submodule update --init --recursive`, then confirm no `+` remains.
   - Ensure `foundation_documentation` is present as a submodule; if missing, add it using the canonical docs repo before proceeding.
   - For each entry in `.gitmodules`, confirm the URL points to the project’s own repo, not `belluga/boilerplate_*`. If any still reference boilerplate sources, guide the user to `git submodule set-url` the correct fork before proceeding.

4. **Filesystem ownership**
   - Spot-check key files (`laravel-app/.env`, `flutter-app`, `web-app`) and ensure they are writable by the host/WSL user. If ownership reflects container/root users, instruct the user to `chown` the directories before continuing.

5. **Symlinked scripts**
   - Verify helper scripts exist and resolve (`flutter-app/scripts` must symlink to `../delphi-ai/scripts/flutter`). If missing, recreate the link so Flutter uses the canonical build helpers.

6. **Validation topology snapshot**
   - When local validation, browser checks, or build/publish flows are in scope, explicitly resolve:
     - the canonical runtime owner for Laravel/PHP/Composer/test commands (`host` vs safe runner vs compose service);
     - the canonical build/publish wrapper and output target for Flutter/web;
     - the canonical public validation URLs (for example landlord + tenant domains) and any preferred validation tenant/subdomain.
   - Source priority:
     - active TODO / validation notes;
     - `foundation_documentation/artifacts/dependency-readiness.md`;
     - README, compose files, `.env`, and project-owned safe runners/wrappers;
     - direct user clarification when the repo still leaves multiple plausible targets.
   - If multiple tenant/domain candidates remain and no project-owned artifact selects one, stop and ask instead of guessing.
   - Prefer project-owned safe runners when they exist (for example `laravel-app/scripts/delphi/run_laravel_tests_safe.sh` for local Laravel tests, `flutter-app/scripts/build_web.sh` for web bundle publish).
   - If these topology facts are stable and likely to matter across sessions, record or refresh them in `foundation_documentation/artifacts/dependency-readiness.md` before moving on.

7. **README alignment**
   - If the user is in setup mode, walk through the relevant README sections (env variables, submodule init, Docker commands) and confirm each step is complete. Use the README as the canonical checklist for new environments.

8. **Report status**
   - Summarise any discrepancies (missing submodule, wrong remote, permission issue, unresolved runtime owner, missing validation target) and the remediation steps provided.
   - Only proceed with further DevOps work (builds, deployments, CI tasks) after the environment is confirmed healthy.

## Outputs
- Status summary of submodules, permissions, scripts, and resolved validation topology.
- Action items (if any) for the user to fix before running builds/deploys.
