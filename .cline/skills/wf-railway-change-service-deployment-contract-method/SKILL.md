---
name: wf-railway-change-service-deployment-contract-method
description: "Workflow: Use when changing Railway service config, variables, build/start, health, storage/networking, domain, migration order, deployment, or rollback readiness."
---

# Change a Railway Service or Deployment Contract

1. Resolve exact project/environment/service, source/root/revision, config ownership, builder/runtime, region, build/start commands, and authority.
2. Load the environment topology contract; keep local evidence candidate-only until remote verification.
3. Inventory variable names/references/scopes and client exposure without values.
4. Define port, health/startup, restart/replicas/shutdown, dependency, storage, network, domain, and TLS behavior.
5. Assign one migration owner and explicit migration/build/deploy/health/smoke/cleanup order plus data-safe rollback/forward-fix posture.
6. Run local checks, then obtain explicit authority and re-resolve target identity immediately before remote mutation.
7. Attest deployed revision/config, health, logs, domain/API smoke, and recovery without leaking secrets.

Complete only with fresh target evidence and no inferred application, database, container, or frontend capability.
