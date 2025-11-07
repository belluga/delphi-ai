# Method: Update CI / Pipeline (DevOps)

## Purpose
Modify CI workflows (GitHub Actions, GitLab CI, etc.) safely—ensuring analyzer/test steps for Flutter, Laravel, and Docker stay intact and cost-effective.

## Triggers
- Need to add or change CI jobs (e.g., new analyzer, Docker publish, deployment gate).
- Credentials/secrets or runners change.
- Pipeline runtimes/cost require optimization.

## Inputs
- Existing workflow files (`.github/workflows/*.yaml`, etc.).
- Analyzer/test requirements from personas (Flutter analyzer, `php artisan test`, Docker build).
- Secrets management notes and DevOps roadmap.

## Procedure
1. **Persona alignment** – select DevOps persona and review roadmap context.
2. **Plan changes** – list affected workflows/jobs, required secrets, and target environments.
3. **Edit workflow**
   - Add/update jobs to run required commands (e.g., `fvm flutter analyze`, `composer test`, Docker build/push).
   - Ensure caching and matrix strategies keep runtimes lean.
4. **Secrets & permissions**
   - Verify required secrets exist; document any new ones in secure channels (never in repo).
5. **Dry-run / validation**
   - Use `act` or branch runs to validate workflow syntax and steps.
6. **Documentation + roadmap**
   - Note the change and expected impact in DevOps roadmap.
   - Mention new pipeline requirements in relevant personas if they affect local workflows.
7. **Session summary** – capture results and any follow-up (e.g., secrets to rotate).

## Outputs
- Updated workflow files.
- Roadmap entry describing the pipeline change and expected benefits.
- Notes to other personas if required steps changed.

## Validation
- CI run succeeds (on branch or main) with the new configuration.
- Required analyzer/test steps are enforced in the pipeline output.
