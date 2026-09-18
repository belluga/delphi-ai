---
name: rule-railway-railway-deployment-contract-always-on
description: "Rule: Use for project-declared Railway work to preserve service identity, build/start, health, variables, storage/networking, migration, release evidence, and mutation authority."
---

# Railway Deployment Contract Rule

- Resolve exact project/environment/service/source/revision, config owner, builder, build/start commands, and runtime before readiness claims; prefer current IaC and treat `railway.toml`/`railway.json` as legacy evidence requiring support verification.
- Local config/linkage is candidate evidence, not proof of remote state.
- Inventory variable names/references/scopes/sealing without values, preserve references, and treat client-exposed values as public.
- Define port, health, startup, restart, replicas, shutdown, dependencies, storage, networking, domains, and TLS when applicable.
- Assign one migration/release owner, account for pre-deploy filesystem/volume/retry limits, and define data-compatible rollback/forward-fix order.
- Treat healthchecks as startup gates, not continuous monitoring.
- Require explicit authority immediately before deploy/config apply, remote commands, variable/domain/scale changes, restart/redeploy, or rollback; output-format flags do not make mutation read-only.
- Tie hosted evidence to a fresh revision and redact secrets.
- Do not infer Docker, Vite, NestJS, PostgreSQL, Prisma, or commands.

Use the environment topology contract for target validation and the Railway service/deployment workflow for changes.
