# Docker Runtime & Ingress (Model Decision)

## Rule

When the task involves `docker/`, `docker-compose.yml`, ingress proxies, or host runtime settings:

### Requirements
- Run the Runtime & Ingress Workflow
- Keep ingress/routes aligned with documented Laravel route groups; sync manifests accordingly
- Preserve host UID/GID ownership; avoid container-owned writes

## Rationale

Runtime/ingress changes affect every stack. The workflow enforces ingress parity, permissions, and documented route contracts.

## Enforcement

- Trigger this rule before editing runtime/ingress files
- Block changes lacking ingress parity checks or ownership considerations

## Notes

Document ingress updates and ownership steps in PRs; update manifests and README guidance when routes change.

## Workflow Reference

See: `.clinerules/workflows/docker-update-runtime-and-ingress.md`