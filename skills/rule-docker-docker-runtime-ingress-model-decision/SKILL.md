---
name: rule-docker-docker-runtime-ingress-model-decision
description: "Rule: MUST use whenever the scope matches this purpose: When modifying Docker runtime, compose, ingress, or host/env settings."
---

## Rule
When the task involves `docker/`, `docker-compose.yml`, ingress proxies, or host runtime settings:
- Run the Runtime & Ingress Workflow (`delphi-ai/workflows/docker/update-runtime-and-ingress-method.md`).
- Keep ingress, routes, hosts, ports, health checks, and service dependencies aligned with every project-declared application and deployment capability; apply provider-specific contracts only when active.
- Preserve host UID/GID ownership; avoid container-owned writes.

## Rationale
Runtime/ingress changes affect every stack. The workflow enforces ingress parity, permissions, and documented route contracts.

## Enforcement
- Trigger this rule before editing runtime/ingress files.
- Block changes lacking ingress parity checks or ownership considerations.

## Notes
Document ingress updates and ownership steps in PRs; update manifests and project-owned runtime guidance when public routes, hosts, ports, or health contracts change.
