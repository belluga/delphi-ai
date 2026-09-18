---
name: wf-prisma-change-schema-migration-contract-method
description: "Workflow: Use when changing a Prisma schema, migration history, generated client, query boundary, transaction, drift/baseline, or deployment migration contract."
---

# Change a Prisma Schema or Migration Contract

1. Resolve owner manifest/lockfile, pinned major and compatible packages, schema or contract/config, provider/database package, generated artifacts, history, database capability, and exact scripts; block mixed-major assumptions.
2. Audit exact Prisma dependency evidence without aggregating manifests.
3. Route through the pinned major's declared schema/client-generation or contract/emission path; never select latest tooling implicitly.
4. Define model/entity/relation/constraint/index/native-type changes and classify planning/creation, prototype sync, production apply, drift/baseline/signing, generation/emission, reset, or backfill using only version-owned commands.
5. Preserve accepted history and plan expand/backfill/switch/contract across overlapping versions; isolate destructive work.
6. Assign one deployment migration owner and explicit release ordering.
7. Validate query/order/pagination/cardinality, transaction/concurrency, batching, raw SQL safety, and performance.
8. Run project-owned validation, generation, migration-state, and database integration evidence without exposing connection values.

Complete only when migration and generated-client state match the declared database and release contract.
