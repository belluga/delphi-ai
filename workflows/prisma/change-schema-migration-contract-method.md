---
description: Change a Prisma schema or migration contract with pinned-version commands, compatibility rollout, drift/baseline, generated-client, query, and deployment ownership evidence.
---

# Method: Change a Prisma Schema or Migration Contract

## Procedure

1. Resolve the owning manifest/lockfile, pinned Prisma major and compatible packages, schema or contract/config paths, provider/database package, generated artifacts, migration history, database capability, and exact project scripts. Block mixed-major assumptions.
2. Run `python3 delphi-ai/tools/node_capability_surface_audit.py --repo <repo-root> --expect prisma`, selecting the owner and required scripts.
3. Route through the pinned major's project contract: schema/client generation where declared, or contract emission/database package where declared. Never select current/latest tooling implicitly.
4. Define model/entity, relation, constraint, index, and native-type changes against actual database invariants and existing data. Classify planning/creation, prototype sync, production application, drift/baseline/signing, generation/emission, reset, or backfill using only version-owned commands.
5. Preserve accepted migration history; plan expand/backfill/switch/contract and overlapping application versions. Isolate destructive/reset operations to explicitly disposable targets.
6. Assign exactly one deployment migration owner and order migration, generation/build, application rollout, background jobs, and contract cleanup.
7. Validate query cardinality/order/pagination, transaction and concurrency semantics, batching, raw-query parameterization, and expected database performance.
8. Run project-owned schema/contract validation, typecheck when applicable, generation/emission, migration-state, tests, and representative database integration checks without exposing connection values.

## Validation

- Exact Prisma evidence, major-specific schema/contract/config, provider/database package, versions, scripts, and migration owner are resolved.
- Migration history and rollout are compatible with existing data and overlapping versions.
- Destructive/reset operations cannot target protected data implicitly.
- PostgreSQL, NestJS, Docker, Railway, or a universal Prisma command was not inferred.
