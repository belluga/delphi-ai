---
name: wf-docker-update-ci-pipeline-method
description: "Workflow: MUST use for CI changes that must preserve validation and delivery contracts across every project-declared capability."
---

# Method: Update CI / Pipeline (Operational / DevOps)

## Purpose
Modify CI workflows safely while preserving validation, build, migration, container, browser, and deployment gates for every active capability.

## Triggers
- Need to add or change CI jobs (e.g., new analyzer, Docker publish, deployment gate).
- Credentials/secrets or runners change.
- Pipeline runtimes/cost require optimization.

## Inputs
- Existing workflow files (`.github/workflows/*.yaml`, etc.).
- Project-owned validation and delivery requirements for every active capability scope.
- Secrets management notes and DevOps roadmap.

## Preferred Deterministic Helper
- Use `bash delphi-ai/tools/ci_pipeline_surface_audit.sh [--repo <repo-root>] [--expect flutter] [--expect laravel] [--expect docker]` for the capability families it currently supports. An unsupported `--expect` value never means a newer capability is inactive; supplement the audit with project-owned validation until the helper is extended.
- Treat the helper as an audit only; job topology, caching tradeoffs, secret strategy, and final pipeline design remain in this workflow.

## Procedure
1. **Profile alignment** – select `Operational / DevOps` with every affected active capability overlay. Include `docker` only when the pipeline builds, publishes, or operates containers; this skill's historical `wf-docker` name does not activate Docker by itself. Review roadmap context only when strategic sequencing is affected.
2. **Plan changes** – list affected workflows/jobs, required secrets, and target environments.
3. **Edit workflow**
   - Add or update remote CI jobs to run exact project-declared commands; framework examples are not universal defaults.
   - A remote pipeline analyzer is separate from local agent diagnostics. Flutter agents must read the stable VS Code Problems bridge snapshot locally and must not start `dart analyze` or `flutter analyze` themselves.
   - Ensure caching and matrix strategies keep runtimes lean.
   - Load `ci-equivalent-governance` before changing any stage-facing suite/job family or broad local stage contract/profile such as `stage-full`.
   - Load `ci-equivalent-test-surface-admission` whenever the change adds, removes, or rewires a stage-facing test row, wrapper, lifecycle step, or readonly/mutation coverage row.
   - Keep any named broad local stage contract/profile aligned in the same change so it remains the parity-complete local mirror of the stage pipeline for the touched scope under `ci-equivalent-governance`.
4. **Secrets & permissions**
   - Verify required secrets exist; document any new ones in secure channels (never in repo).
5. **Dry-run / validation**
   - Use `act` or branch runs to validate workflow syntax and steps.
6. **Documentation + roadmap**
   - Note the change and expected impact in DevOps roadmap.
   - Mention new pipeline requirements in the relevant delivery profiles/scopes if they affect local workflows.
   - If the pipeline change redefines the broad local stage gate or its lifecycle steps, update the local contract wording/runbooks in the same change so that name still means full stage-pipeline parity under `ci-equivalent-governance`.
   - Update the corresponding drift guard/audit in the same change when the expected stage-facing suite shape changed.
7. **Session summary** – capture results and any follow-up (e.g., secrets to rotate).

## Outputs
- Updated workflow files.
- Roadmap entry describing the pipeline change and expected benefits only when strategic sequencing or material follow-up changed.
- Notes to other profiles/scopes if required steps changed.

## Validation
- CI run succeeds (on branch or main) with the new configuration.
- Required analyzer/test steps are enforced in the pipeline output.
