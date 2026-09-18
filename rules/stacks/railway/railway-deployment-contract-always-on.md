---
trigger: always_on
description: Preserve Railway service, environment, build/start, health, variable, migration, volume, domain, and release evidence without granting deployment authority.
---

## Rule

When `railway` is active:

- Resolve the exact project, environment, service, source/root directory, branch/revision, builder, build command, start command, region/runtime, and config-as-code ownership before evaluating readiness. Prefer the platform's current IaC surface; legacy `railway.toml`/`railway.json` evidence requires current-support verification and is not a recommended default.
- Treat local config and CLI linkage as candidate evidence only. They do not prove the currently deployed service, environment variables, domains, volumes, health, or revision.
- Inventory variable names, references, scope, sealing, and required/optional semantics without exposing values. Preserve references instead of materializing them; client-exposed variables remain public even when supplied by Railway.
- Define health endpoint/protocol, startup deadline, restart policy, replica behavior, graceful shutdown, port binding, and dependency readiness from project-owned runtime contracts.
- Make persistent-volume mount/ownership, ephemeral filesystem assumptions, private/public networking, domains, TLS, and service-to-service references explicit when used.
- Assign one migration/release owner and order migrations, build, deploy, health, smoke evidence, and cleanup. A pre-deploy container has its own filesystem/volume constraints and retry semantics. Database rollback may require forward-fix rather than image rollback.
- Treat healthcheck success as startup/deployment gating, not continuous monitoring; volume-backed services can retain distinct downtime behavior.
- A deployment, config apply, variable mutation, remote-command execution, domain change, scale change, restart/redeploy, or rollback requires explicit external-mutation authority. Output format flags never make a mutating command read-only.
- Redact secrets from commands, logs, evidence, and reports. Stop when service/environment identity or fresh deployed revision cannot be proven.
- Railway does not imply Docker, Vite, NestJS, PostgreSQL, Prisma, or any build/start command.

## Enforcement

- Use the environment topology contract to distinguish local candidate evidence from user-validated targets.
- Accept hosted proof only when tied to a fresh authoritative revision and exact service/environment identity.

## Notes

Follow `delphi-ai/workflows/railway/change-service-deployment-contract-method.md` for Railway configuration or release-readiness changes.
