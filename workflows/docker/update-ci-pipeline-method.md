---
description: Modify CI workflows safely while preserving project-declared validation and delivery contracts for every active capability.
---

# Method: Update CI / Pipeline (Operational / DevOps)

## Purpose
Modify CI workflows safely while keeping validation, build, migration, container, browser, and deployment gates for every active capability intact and cost-effective.

## Triggers
- Need to add or change CI jobs (e.g., new analyzer, Docker publish, deployment gate).
- Credentials/secrets or runners change.
- Pipeline runtimes/cost require optimization.

## Inputs
- Existing workflow files (`.github/workflows/*.yaml`, etc.).
- Project-owned lint, typecheck, test, build, migration, container, browser, and deployment requirements for active capability scopes.
- Secrets management notes and DevOps roadmap.

## Procedure
1. **Profile alignment** – select `Operational / DevOps` with every affected active capability overlay. Include `docker` only when the pipeline builds, publishes, or operates containers; this workflow's historical location under `workflows/docker/` does not activate Docker by itself. Review roadmap context only when strategic sequencing is affected.
2. **Plan changes** – list affected workflows/jobs, required secrets, and target environments.
3. **Edit workflow**
   - Add or update remote CI jobs to run exact commands declared by the project. Framework examples are not universal defaults.
   - A remote pipeline analyzer is separate from local agent diagnostics. Flutter agents must read the stable VS Code Problems bridge snapshot locally and must not start `dart analyze` or `flutter analyze` themselves.
   - Ensure caching and matrix strategies keep runtimes lean.
   - Load `ci-equivalent-governance` before changing any stage-facing suite/job family or named broad local stage contract/profile such as `stage-full`.
   - When the repo exposes a named broad local stage contract/profile, update that local contract in the same change and keep it aligned with the parity rules from `ci-equivalent-governance`. Do not leave the pipeline broader than the named local parity gate.
   - Wrapper-identical means more than sharing the same inner smoke command. If the pipeline owns explicit fixture/bootstrap seed, cleanup/teardown, provenance checks, runtime override setup, restore/readback preparation, or similar lifecycle steps around that smoke suite, the named local stage contract must execute the same lifecycle too.
4. **Secrets & permissions**
   - Verify required secrets exist; document any new ones in secure channels (never in repo).
5. **Dry-run / validation**
   - Use `act` or branch runs to validate workflow syntax and steps.
6. **Documentation + roadmap**
   - Note the change and expected impact in DevOps roadmap.
   - Mention new pipeline requirements in the relevant delivery profiles/scopes if they affect local workflows.
   - If the pipeline change alters which suites define the broad local stage gate, update the local contract/runbook wording in the same change so `stage-full` (or equivalent) still means full stage-pipeline parity under `ci-equivalent-governance`.
   - If the pipeline adds or reclassifies explicit pre/post lifecycle steps around a stage-facing validation surface, update the named local stage contract in the same change so those steps are no longer implicit or assumed from prior state.
7. **Session summary** – capture results and any follow-up (e.g., secrets to rotate).

## Outputs
- Updated workflow files.
- Roadmap entry describing the pipeline change and expected benefits only when strategic sequencing or material follow-up changed.
- Notes to other profiles/scopes if required steps changed.

## Validation
- CI run succeeds (on branch or main) with the new configuration.
- Required analyzer/test steps are enforced in the pipeline output.
