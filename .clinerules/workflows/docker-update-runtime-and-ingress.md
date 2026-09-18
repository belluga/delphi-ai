---
name: "docker-update-runtime-and-ingress"
description: "Ensure Docker images, Compose stacks, and ingress configurations stay aligned with project-declared service, route, health, and deployment contracts."
---

<!-- Generated from `workflows/docker/update-runtime-and-ingress-method.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# Workflow: Update Runtime & Ingress

## Purpose
Ensure Docker images, Compose stacks, and ingress configurations stay aligned with documented services, public routes, hosts, ports, health checks, and deployment contracts while keeping runtime cost and build performance under control.

## Triggers
- Changes to public routes, API prefixes, hosts, ports, or health endpoints that require ingress updates.
- Dockerfile or docker-compose modifications (base image updates, new services, resource tweaks).
- Requests to improve build time, container size, or hosting cost.

## Inputs
- Relevant `foundation_documentation/modules/*.md` entries covering active services and ingress-facing contract shape.
- Active capability namespaces and their project-owned build/start/health commands.
- Current Docker/Compose files (`docker/`, `docker-compose.yml`, CI pipeline scripts).
- Relevant DevOps/infra entries in `foundation_documentation/system_roadmap.md`.
- Any cost/build metrics motivating the change.

## Procedure
1. **Profile alignment** – run Profile Selection as `Operational / DevOps` with every affected active capability overlay. Include `docker` only when Docker or Compose assets are in scope; ingress or Railway work does not activate Docker by itself. Review roadmap items only when the runtime change has strategic follow-up.
2. **Collect diffs** – list the service, route, host, port, health, dependency, or runtime changes requested.
3. **Apply runtime/container changes when applicable**
   - Change Dockerfiles or Compose only when the project activates `docker` and those surfaces are in scope; Railway or ingress work alone must not create them.
   - For active container surfaces, use appropriate minimal or multi-stage images, deterministic dependency installation, and non-root runtime users when supported by the project contract.
   - Adjust applicable platform/container services, environment-variable names, health checks, dependencies, volumes, networks, or resource limits without recording secret values.
4. **Ingress parity**
   - Mirror project-declared public routes and hosts into proxy, gateway, platform, and container configuration.
   - Apply framework-specific route groups only for active capabilities.
5. **Verification**
   - Treat `runtime_ingress_surface_audit.sh` as a local-surface inventory. Its Laravel storage invariant applies only when a `laravel-app` surface exists. Missing local surfaces block by default; pass `--platform-owned` only when a project contract assigns them externally, then validate with fresh platform evidence.
   - Use project-owned build and Compose commands; do not invent a universal package-manager or framework runner.
   - Run readiness and smoke checks against the exact image/configuration under review.
   - Confirm public routes and health endpoints resolve through the declared ingress path.
6. **Documentation + roadmap**
   - Update the affected runtime/module contract. Update `system_roadmap.md` only when strategic sequencing or material cross-capability follow-up changes.
   - Record follow-up for every affected active consumer, provider, database, or deployment capability.
7. **Session summary** – mention the updates, verification results, and any follow-up actions.

## Outputs
- Updated applicable runtime, container, platform, or ingress surfaces; Docker/Compose files only when `docker` is active and in scope.
- Updated project-owned runtime/module contract and strategic roadmap entry only when required.

## Validation
- Project-declared build/test commands succeed; Docker build/test commands also succeed when Docker is in scope.
- Route and health checks confirm parity with canonical module/runtime docs.
- Every affected active capability has corresponding validation or an explicit bounded deferral.
