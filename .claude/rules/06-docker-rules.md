---
description: "Docker stack rules — architecture mode transitions, CI pipeline governance, and runtime/ingress configuration"
globs: ["docker/**", "docker-compose.yml", ".github/workflows/**"]
alwaysApply: false
---

# Docker Stack Rules

## Architecture Mode Transition

If adjusting architecture modes or related governance (Foundational/Operational/Expansion):

- Run the Architecture Mode Transition Workflow (`delphi-ai/workflows/docker/architecture-mode-transition-method.md`).
- Document the mode change in the project constitution or roadmap.
- Ensure all downstream artifacts reflect the new mode.

## CI Pipeline

For CI/CD changes (pipelines, build images, caching, test stages):

- Run the CI Pipeline Workflow.
- Validate that fail-closed CI engines pass before merging.
- Document pipeline changes in the system roadmap.

## Runtime & Ingress

When the task involves `docker/`, `docker-compose.yml`, ingress proxies, or host runtime settings:

- Run the Runtime & Ingress Workflow.
- Document changes to ports, volumes, and networking.
- Ensure ingress configuration is consistent with the deployment environment.

## Enforcement

- Block architecture mode changes without workflow execution.
- Block CI changes that bypass fail-closed engine validation.
- Block runtime changes without documentation updates.
