---
name: wf-postgresql-change-relational-contract-method
description: "Workflow: Use when changing a PostgreSQL schema, constraint, query/index contract, transaction, role, pool, migration, or recovery surface."
---

# Change a PostgreSQL Relational Contract

1. Resolve database/schema ownership, supported version, workload, migration owner, topology, and exact commands.
2. Define constraints, keys, null/default/referential semantics, and existing-data compatibility.
3. Map reads/writes; assess indexes, plans, statistics, write/storage cost, and safe measurement authority.
4. Define transaction/isolation, locks, timeouts, concurrency conflicts, and retry/idempotency.
5. Plan expand/backfill/switch/contract, overlapping versions, irreversible steps, and forward-fix/rollback limits.
6. Validate pool/connection budgets, roles/grants, encryption, parameterization, sensitive data, backups, and restore evidence.
7. Run project-owned migration/integration/performance checks against an approved representative database.

Complete only when integrity and operational evidence match the declared topology without inferring an ORM or platform.
