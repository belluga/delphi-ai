---
trigger: always_on
description: Preserve PostgreSQL relational integrity, transaction, migration, performance, connection, security, and recovery contracts without inferring an ORM or platform.
---

## Rule

When `postgresql` is active:

- Make primary keys, foreign keys, uniqueness, nullability, defaults, checks, exclusion constraints, and delete/update behavior express durable invariants; application validation is not a substitute. Do not misuse `CHECK` for cross-row/table invariants, and remember foreign-key referencing columns are not indexed automatically.
- Design indexes from validated query and write workloads. Verify plans and statistics safely; `EXPLAIN ANALYZE` executes the statement and requires appropriate authority.
- Define transaction boundaries, isolation expectations, consistent lock order, timeout behavior, and bounded whole-transaction retry for serialization failures/deadlocks using stable SQLSTATE classification. External effects inside retryable work require explicit idempotency/coordination.
- Treat schema migration as a compatibility rollout. Prefer expand/backfill/switch/contract for live systems; identify lock/table-rewrite risk, long transactions, and rollback/forward-fix posture. `NOT VALID` constraints require later validation, and concurrent index creation has non-transactional/failure-cleanup constraints that must come from the pinned server contract.
- Budget direct and pooled connections across replicas, workers, jobs, migrations, and administration. Pooling mode must remain compatible with session/transaction features in use.
- Use least-privilege owner/migrator/runtime roles, a safe qualified-object/`search_path` contract, encrypted connections where required, parameterized queries, protected credentials, and auditable administrative ownership.
- Separate availability from recoverability. Backups, retention, restore rehearsal, RPO, and RTO require explicit operational evidence.
- PostgreSQL does not imply Prisma, another ORM, NestJS, Docker, Railway, or a migration tool.

## Notes

Follow `delphi-ai/workflows/postgresql/change-relational-contract-method.md` for schema, query, transaction, index, role, pool, or recovery changes.
