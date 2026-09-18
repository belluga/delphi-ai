---
description: Change a Railway service/deployment contract with explicit identity, build/start, health, variables, storage/networking, migration order, evidence, and mutation authority.
---

# Method: Change a Railway Service or Deployment Contract

## Procedure

1. Resolve project/environment/service identity, source/root, authoritative revision, config ownership, builder/runtime, region, build/start commands, and allowed authority.
2. Scaffold or load the environment topology contract. Classify local files and linkage as candidate evidence until the remote target is freshly verified.
3. Inventory variable names/references/scopes and client exposure without values; define missing/invalid startup behavior.
4. Define port binding, health path/protocol, startup deadline, restart/replica/graceful-shutdown behavior, and dependency readiness.
5. Validate persistent volumes, ephemeral paths, permissions, private/public networking, domains, TLS, and service references when applicable.
6. Assign one migration owner and order migration, build, deploy, health, smoke, and cleanup. Record data-compatible rollback/forward-fix constraints.
7. Run local config/build checks, then obtain explicit authority before any remote mutation. Re-resolve identity immediately before mutation and stop on ambiguity.
8. Attest the deployed revision/config, health, logs, domain/API smoke, and rollback posture without leaking secrets.

## Validation

- Exact project/environment/service/revision identity is fresh and evidenced.
- Build/start/health/variable/storage/network/migration contracts are explicit.
- Remote changes stayed within granted authority and post-change evidence is current.
- No application, database, container, or frontend capability was inferred from Railway alone.
