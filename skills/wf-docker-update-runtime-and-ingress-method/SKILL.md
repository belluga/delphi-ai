---
name: wf-docker-update-runtime-and-ingress-method
description: "Workflow: MUST use for Docker, Compose, ingress, route, host, port, or health-contract changes across project-declared capabilities."
---

# Method: Update Runtime & Ingress (Operational / DevOps)

## Purpose
Ensure Docker images, Compose stacks, and ingress configurations stay aligned with project-declared services, public routes, hosts, ports, health checks, and deployment contracts.

## Triggers
- Changes to public routes, API prefixes, hosts, ports, or health endpoints that require ingress updates.
- Dockerfile or docker-compose modifications (base image updates, new services, resource tweaks).
- Requests to improve build time, container size, or hosting cost.

## Inputs
- Relevant `foundation_documentation/modules/*.md` entries covering active services and ingress-facing contracts.
- Active capability namespaces and their project-owned build/start/health commands.
- Current Docker/Compose files (`docker/`, `docker-compose.yml`, CI pipeline scripts).
- Relevant DevOps/infra entries in `foundation_documentation/system_roadmap.md`.
- Any cost/build metrics motivating the change.

## Preferred Deterministic Helper
- Use `bash delphi-ai/tools/runtime_ingress_surface_audit.sh [--repo <repo-root>] [--platform-owned]` to inventory Dockerfiles, compose files, ingress/runtime configs, currently supported route surfaces, and compose readiness before or after runtime edits. Its Laravel route/storage checks are conditional on a `laravel-app` surface. Use `--platform-owned` only when a project-owned contract explicitly assigns the runtime/ingress surface to Railway or another external platform, then supplement the audit with fresh platform evidence.
- Treat the helper as an audit only; ingress parity decisions, runtime topology, and cost/performance tradeoffs remain in this workflow.

## Procedure
1. **Profile alignment** – run Profile Selection as `Operational / DevOps` with every affected active capability overlay. Include `docker` only when Docker or Compose assets are in scope; ingress or Railway work does not activate Docker by itself. Review roadmap items only when the runtime change has strategic follow-up.
2. **Collect diffs** – list the service, route, host, port, health, dependency, or runtime changes requested.
3. **Apply runtime/container changes when applicable**
   - Change Dockerfiles or Compose only when the project activates `docker` and those surfaces are in scope; Railway or ingress work alone must not create them.
   - For active container surfaces, use appropriate minimal or multi-stage images, deterministic dependency installation, and non-root runtime users when supported by the project contract.
   - Adjust applicable platform/container services, variable names, health checks, dependencies, volumes, networks, or resource limits without recording secret values.
4. **Ingress parity**
   - Mirror project-declared public routes and hosts into proxy, gateway, platform, and container configuration.
   - Apply framework-specific route groups only for active capabilities.
5. **Verification**
   - Use project-owned build and Compose commands.
   - Run readiness/smoke checks against the exact image and confirm public routes and health endpoints through the declared ingress path.
6. **Documentation + roadmap**
   - Update affected runtime/module contracts; update the roadmap only for strategic sequencing or material cross-capability follow-up.
7. **Session summary** – mention the updates, verification results, and any follow-up actions.

## Outputs
- Updated applicable runtime, container, platform, or ingress surfaces; Docker/Compose files only when `docker` is active and in scope.
- Updated runtime/module contract and strategic roadmap entry only when required.

## Validation
- Project-declared build/test commands succeed; Docker build/test commands also succeed when Docker is in scope.
- Route and health checks confirm parity with canonical module/runtime docs.
- Every affected active capability has validation or an explicit bounded deferral.
