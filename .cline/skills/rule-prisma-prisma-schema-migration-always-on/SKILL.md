---
name: rule-prisma-prisma-schema-migration-always-on
description: "Rule: Use for project-declared Prisma work to preserve schema, client generation, migration history, queries, transactions, and deployment ownership without inferring a database or platform."
---

# Prisma Schema and Migration Rule

- Resolve the pinned Prisma major and compatible packages first. Use its project-owned schema or contract/config, provider/database package, artifacts, manifests, lockfile, and scripts; never mix v7/v8 contracts or invent universal commands.
- Align models, relations, optionality, uniqueness, mappings, indexes, and native types with the active database contract.
- Treat generated client/contract artifacts as owned build outputs, typecheck TypeScript contracts, and keep accepted migration history immutable.
- Distinguish planning/creation, prototype synchronization, production application, drift/baseline/signing, reset, generation/emission, and backfill; synchronization or artifact success is not deploy proof.
- Treat reset/destructive operations as explicit data-loss actions and use compatibility rollouts for overlapping versions.
- Preserve transaction, concurrency, cardinality, pagination/order, batching, performance, and raw-query safety.
- Do not infer PostgreSQL, NestJS, Docker, Railway, or a migration owner.

Run the Node capability audit with `--expect prisma`, project-required scripts, and an owning manifest. Use the Prisma schema/migration workflow for changes.
