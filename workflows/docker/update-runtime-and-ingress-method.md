---
description: Ensure Docker images, Compose stacks, and ingress configs stay aligned with the documented API routes while keeping runtime cost and build performance under control.
---

# Method: Update Runtime & Ingress (Operational / DevOps)

## Purpose
Ensure Docker images, Compose stacks, and ingress configs stay aligned with the documented API routes while keeping runtime cost and build performance under control.

## Triggers
- Changes to Laravel routes/API prefixes that require ingress updates.
- Dockerfile or docker-compose modifications (base image updates, new services, resource tweaks).
- Requests to improve build time, container size, or hosting cost.

## Inputs
- Relevant `foundation_documentation/modules/*.md` entries covering Laravel routing layout and ingress-facing contract shape.
- Current Docker/Compose files (`docker/`, `docker-compose.yml`, CI pipeline scripts).
- Relevant DevOps/infra entries in `foundation_documentation/system_roadmap.md`.
- Any cost/build metrics motivating the change.

## Procedure
1. **Profile alignment** – run Profile Selection as `Operational / DevOps` with `docker` scope and review roadmap items only when the runtime change has strategic follow-up.
2. **Collect diffs** – list the route or runtime changes requested (e.g., new `/admin/api/v1/...` path, base image bump).
3. **Apply Docker/Compose changes**
   - Update Dockerfiles with minimal base images and shared layers.
   - Adjust `docker-compose.yml` services, env vars, or resource limits.
4. **Ingress parity**
   - Mirror Laravel routing groups (tenant, landlord, account) into Nginx/ingress configs. Ensure prefixes/hosts match the canonical module docs.
5. **Verification**
   - Build images (`docker compose build`) and run smoke checks or relevant pipeline stages.
   - Confirm new routes resolve correctly (curl, Postman, or automated tests).
6. **Documentation + roadmap**
   - Record the change in the relevant `foundation_documentation/system_roadmap.md` entry (including cost/time impact when applicable).
   - If routes changed, capture Flutter/Laravel/DevOps follow-up actions in the shared roadmap entry.
7. **Session summary** – mention the updates, verification results, and any follow-up actions.

## Outputs
- Updated Docker/Compose/ingress files.
- Shared roadmap entry detailing the change, impact, and any cross-stack follow-up.

## Validation
- Docker build/test commands succeed.
- Route checks confirm parity with canonical module docs.
- Roadmap entry exists for the change.
