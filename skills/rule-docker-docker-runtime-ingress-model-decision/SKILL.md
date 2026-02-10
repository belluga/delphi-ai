---
name: rule-docker-docker-runtime-ingress-model-decision
description: "Rule: MUST use whenever the scope matches this purpose: When the task involves `docker/`, `docker-compose.yml`, ingress proxies, or host runtime settings:."
---

## Rule
When the task involves `docker/`, `docker-compose.yml`, ingress proxies, or host runtime settings:
- Run the Runtime & Ingress Workflow (`delphi-ai/workflows/docker/update-runtime-and-ingress-method.md`).
- Keep ingress/routes aligned with documented Laravel route groups; sync manifests accordingly.
- Preserve host UID/GID ownership; avoid container-owned writes.

## Rationale
Runtime/ingress changes affect every stack. The workflow enforces ingress parity, permissions, and documented route contracts.

## Enforcement
- Trigger this rule before editing runtime/ingress files.
- Block changes lacking ingress parity checks or ownership considerations.

## Notes
Document ingress updates and ownership steps in PRs; update manifests and README guidance when routes change.
