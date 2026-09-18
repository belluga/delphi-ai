---
trigger: always_on
description: Preserve Prisma schema, generated-client, migration-history, query, transaction, and deployment boundaries without inferring a database or platform.
---

## Rule

When `prisma` is active:

- Resolve the pinned Prisma major before any command. Treat the project's schema/contract/config form, provider/database package, generated artifacts, owning manifests, and scripts as authority; do not assume v7 and v8 share commands or file contracts.
- Keep models/entities, relations, optionality, uniqueness, defaults, mappings, referential behavior, indexes, and native types aligned with the independently declared database contract.
- Treat generated client/contract artifacts as build outputs with an explicit generation owner and ordering; do not hand-edit them. TypeScript contract sources also require the project typecheck.
- Keep accepted migration history immutable. Create corrective migrations rather than rewriting migrations already applied outside an isolated disposable environment.
- Distinguish development migration planning/creation, schema or database synchronization/prototyping, production application, drift diagnosis, baseline/signing, reset, contract emission/client generation, and data backfill. Generation/emission or direct synchronization is not deployment-migration proof.
- Treat reset and destructive schema operations as data-loss actions requiring explicit scope and disposable targets.
- Use expand/backfill/switch/contract when application versions or jobs may overlap. Separate schema migration from application-level data transformation when risk warrants it.
- Define transaction boundaries, isolation/conflict behavior, query cardinality, pagination/order, batching, and raw-query parameterization; ORM use does not remove database semantics.
- Prisma does not imply PostgreSQL, NestJS, Docker, Railway, or a deployment migration owner.

## Enforcement

- Run the Node capability audit with `--expect prisma`, required project scripts, and the owning manifest. Exact `prisma` or `@prisma/client` evidence is accepted; the project config/contract determines the major-specific path.
- Validate schemas and migration state using commands declared for the pinned version and environment; never invent a destructive or production command.

## Notes

Follow `delphi-ai/workflows/prisma/change-schema-migration-contract-method.md` for schema, migration, generation, query, or transaction changes.
