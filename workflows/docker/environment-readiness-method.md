---
description: Ensure the working copy is correctly wired (symlinks, scripts, submodules, permissions, README steps) before DevOps/CI work proceeds.
---

# Method: DevOps Environment Readiness

## Purpose
Ensure the working copy is correctly wired (symlinks, scripts, submodules, permissions, README steps) before executing DevOps or CI/CD tasks. Prefer deterministic script checks over manual spot-checks to prevent drift (for example derived web bundle wiring or broken runtime storage routing).

## Triggers
- User explicitly requests DevOps/setup help.
- Session starts in a repository that might not be the canonical boilerplate.
- Before running scripts that depend on submodules (for example backend source, client source, or derived web bundle).

Do not use this method as the profile-selection gate for a zero-state `Genesis / Product-Bootstrap` session. In that scenario, readiness checks are supporting evidence only and must not block Genesis from instantiating the first canonical package.

## Inputs
- Root repository (`<project>_docker` or downstream clone).
- `.gitmodules` and current submodule working trees.
- Project README instructions.
- `foundation_documentation` submodule (expected for all projects; add if missing).
- Delphi stack capability registry (`delphi-ai/config/stack_capabilities.yaml`) for available-capability context only.
- Environment topology contract (`foundation_documentation/artifacts/environment-topology.md`) when present, or enough repo evidence to scaffold it.

## Procedure
1. **Confirm repository context**
   - Identify whether we are in the canonical boilerplate repo or a downstream project.
   - If downstream, note the expected remotes from `.gitmodules`, project README, or `foundation_documentation`.
   - Distinguish available Delphi capabilities from project-active stacks. `config/stack_capabilities.yaml` can say Delphi supports Flutter/Laravel/Docker/Go, but active stack usage must come from project-owned docs/config/repo shape.
   - If the repo is still zero-state (for example no `foundation_documentation/` yet and the request is to initialize/bootstrap the project), stop this method here, record that full downstream readiness is premature, and hand control back to `Genesis / Product-Bootstrap`.

2. **Run canonical readiness scripts (preferred)**
   - Run Delphi context checks (symlinks, required folders):
     - `bash delphi-ai/verify_context.sh`
     - Treat this as read-only verification. If it fails only on Delphi-managed links/artifacts, run `bash delphi-ai/verify_context.sh --repair`, then rerun plain verification. If it fails on a path conflict with project-owned files/directories, stop and report it for manual remediation.
   - Run the project readiness verifier (compose config + critical drift checks):
     - `bash scripts/verify_environment.sh`
     - This helper is topology-configurable. Belluga Docker defaults cover the current Flutter/Laravel/web artifact topology for backward compatibility; projects select active wiring through project docs/config and variables such as `DELPHI_SCRIPT_LINK_SPECS`, `DELPHI_DERIVED_ARTIFACT_SUBMODULES`, `DELPHI_COMPOSE_CONFIG_PROFILES`, and `DELPHI_LOCAL_DB_ENV_FILE`. Future Go support should add Delphi scripts/rules without making Go active in projects that have no Go contract.
   - If either script fails, fix the reported issue before proceeding.
   - For zero-state Genesis bootstrap, replace this step with `bash delphi-ai/init.sh --check` and, when appropriate, `bash delphi-ai/init.sh`; do not require `verify_context.sh` or `scripts/verify_environment.sh` until the downstream shape exists.

3. **Validate submodules (only if needed)**
   - Run `git submodule status --recursive` and ensure each submodule is checked out; no entry should start with `-` (uninitialized) or `U` (merge conflict on gitlink state).
   - Treat entries starting with `+` as local workspace drift (tracking mode) rather than immediate failure.
   - If the task requires CI/deploy parity, normalize to pinned mode before proceeding: prefer `tools/submodules/pin_to_superproject.sh` when available, otherwise run `git submodule sync --recursive && git submodule update --init --recursive`, then confirm no `+` remains.
   - Ensure `foundation_documentation` is present as a submodule; if missing, add it using the canonical docs repo before proceeding.
   - For each entry in `.gitmodules`, confirm the URL points to the project’s own repo, not a boilerplate/template source. If any still reference boilerplate sources, guide the user to `git submodule set-url` the correct fork before proceeding.

4. **Filesystem ownership**
   - Spot-check key environment files, source submodules, and derived bundle directories named by `.gitmodules` or project docs, and ensure they are writable by the host/WSL user. If ownership reflects container/root users, instruct the user to `chown` the directories before continuing.

5. **Symlinked scripts**
   - Verify project-declared helper script links exist and resolve. Flutter helpers remain available in Delphi even when a project does not use Flutter. Belluga Flutter defaults use `flutter-app/scripts -> ../delphi-ai/scripts/flutter` for projects that declare that topology; additional stack helpers should be added to Delphi and wired only when the project declares them through `DELPHI_SCRIPT_LINK_SPECS` or project docs.

6. **Validation topology snapshot**
   - When local validation, browser checks, or build/publish flows are in scope, explicitly resolve:
     - the canonical runtime owner for backend/service/test commands (`host` vs safe runner vs compose service);
     - the canonical build/publish wrapper and output target for client/web artifacts;
     - the canonical public validation URLs and any preferred validation tenant/subdomain when the project declares tenant/domain topology.
   - Source priority:
     - active TODO / validation notes;
     - `foundation_documentation/artifacts/dependency-readiness.md`;
     - README, compose files, `.env`, and project-owned safe runners/wrappers;
     - direct user clarification when the repo still leaves multiple plausible targets.
   - If multiple tenant/domain candidates remain and no project-owned artifact selects one, stop and ask instead of guessing. Do not promote a guessed domain, tenant slug, or host into Delphi.
   - Prefer project-owned safe runners when they exist. Belluga defaults include `laravel-app/scripts/delphi/run_laravel_tests_safe.sh` for local Laravel tests and `flutter-app/scripts/build_web.sh` for web bundle publish; future stack capabilities such as Go should document equivalent backend/client commands in `foundation_documentation` and configure readiness helpers instead of bypassing them.
   - If these topology facts are stable and likely to matter across sessions, record or refresh them in `foundation_documentation/artifacts/dependency-readiness.md` before moving on.
   - If no durable topology artifact exists, or the current artifact is stale/ambiguous, run the Environment Topology Contract Method:
     - `python3 delphi-ai/tools/environment_topology_contract_scaffold.py --repo <repo-root> --output foundation_documentation/artifacts/environment-topology.md`
     - The scaffold should prefill available repo/env/config evidence, redact secrets, and mark inferred rows as `user_validation_required`.
     - Review the generated draft with the user before treating any inferred domain, tenant, runtime owner, compose profile, safe runner, or active stack as authoritative.

7. **README alignment**
   - If the user is in setup mode, walk through the relevant README sections (env variables, submodule init, Docker commands) and confirm each step is complete. Use the README as the canonical checklist for new environments.

8. **Report status**
   - Summarise any discrepancies (missing submodule, wrong remote, permission issue, unresolved runtime owner, missing validation target) and the remediation steps provided.
   - Only proceed with further DevOps work (builds, deployments, CI tasks) after the environment is confirmed healthy.

## Outputs
- Status summary of submodules, permissions, scripts, and resolved validation topology.
- Action items (if any) for the user to fix before running builds/deploys.
