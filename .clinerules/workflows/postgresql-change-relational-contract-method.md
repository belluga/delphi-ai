---
name: "postgresql-change-relational-contract-method"
description: "Change a PostgreSQL relational contract with explicit invariants, rollout compatibility, transaction/lock behavior, performance, connections, security, and recovery evidence."
---

<!-- Generated from `workflows/postgresql/change-relational-contract-method.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# Workflow: Change a PostgreSQL Relational Contract

## Procedure

1. Resolve the owning database/schema, supported PostgreSQL version, workload, migration owner, environments, maintenance constraints, and project-owned commands.
2. Define invariants through keys, constraints, null/default semantics, referential actions, and data compatibility; specify existing-data validation/backfill.
3. Map affected reads/writes and evaluate indexes, statistics, plans, write amplification, storage, and safe plan-measurement authority.
4. Define transaction/isolation, locks, ordering, timeouts, concurrency conflicts, and retry/idempotency behavior.
5. Plan expand/backfill/switch/contract rollout where old and new application versions may overlap. Identify irreversible steps and forward-fix/rollback limits.
6. Validate pool/connection budgets across every process class and operational connection.
7. Validate roles, grants, encryption, parameterization, sensitive data, audit needs, backup impact, and restore evidence.
8. Run project-owned static/migration/integration/performance checks against an approved representative database; classify unavailable infrastructure as blocked.

## Validation

- Durable invariants exist in the database where enforceable.
- Migration and overlap behavior are safe for the declared topology.
- Transaction, lock, index, connection, security, and recovery risks are dispositioned.
- No ORM, framework, container, or platform was inferred from PostgreSQL alone.
