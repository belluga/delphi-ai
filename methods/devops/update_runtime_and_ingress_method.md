# Method: Update Runtime & Ingress (DevOps)

## Purpose
Ensure Docker images, Compose stacks, and ingress configs stay aligned with the documented API routes while keeping runtime cost and build performance under control.

## Triggers
- Changes to Laravel routes/API prefixes that require ingress updates.
- Dockerfile or docker-compose modifications (base image updates, new services, resource tweaks).
- Requests to improve build time, container size, or hosting cost.

## Inputs
- `foundation_documentation/submodule_laravel-app_summary.md` (routing layout).
- Current Docker/Compose files (`docker/`, `docker-compose.yml`, CI pipeline scripts).
- DevOps section of `foundation_documentation/persona_roadmaps.md`.
- Any cost/build metrics motivating the change.

## Procedure
1. **Persona alignment** – run Persona Selection (DevOps) and review roadmap items tied to ingress/runtime work.
2. **Collect diffs** – list the route or runtime changes requested (e.g., new `/admin/api/v1/...` path, base image bump).
3. **Apply Docker/Compose changes**
   - Update Dockerfiles with minimal base images and shared layers.
   - Adjust `docker-compose.yml` services, env vars, or resource limits.
4. **Ingress parity**
   - Mirror Laravel routing groups (tenant, landlord, account) into Nginx/ingress configs. Ensure prefixes/hosts match the summary doc.
5. **Verification**
   - Build images (`docker compose build`) and run smoke checks or relevant pipeline stages.
   - Confirm new routes resolve correctly (curl, Postman, or automated tests).
6. **Documentation + roadmap**
   - Record the change in the DevOps section of `foundation_documentation/persona_roadmaps.md` (noting cost/time impact).
   - If routes changed, notify Flutter/Laravel personas via the roadmap entry.
7. **Session summary** – mention the updates, verification results, and any follow-up actions.

## Outputs
- Updated Docker/Compose/ingress files.
- DevOps roadmap entry detailing the change and its impact.
- Notes to other personas if route contracts shifted.

## Validation
- Docker build/test commands succeed.
- Route checks confirm parity with Laravel summary.
- Roadmap entry exists for the change.
