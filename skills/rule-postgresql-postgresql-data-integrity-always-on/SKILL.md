---
name: rule-postgresql-postgresql-data-integrity-always-on
description: "Rule: Use for project-declared PostgreSQL work to preserve constraints, transactions, migrations, performance, connections, security, and recovery without inferring an ORM or platform."
---

# PostgreSQL Data Integrity Rule

- Encode durable invariants with appropriate keys, constraints, null/default semantics, and referential actions; do not use `CHECK` for cross-row/table invariants and assess indexes on foreign-key referencing columns.
- Design indexes from real workloads and measure plans safely; remember `EXPLAIN ANALYZE` executes statements.
- Define transactions, isolation, consistent lock order, timeouts, stable SQLSTATE classification, and bounded whole-transaction retry without duplicate external effects.
- Treat migrations as compatibility rollouts with lock/rewrite, backfill, overlap, `NOT VALID` completion, concurrent-index failure handling, and rollback/forward-fix analysis.
- Budget connections and pooling across every process class.
- Require least-privilege role separation, safe `search_path`/qualification, parameterization, protected credentials, and explicit backup/restore evidence.
- Do not infer Prisma, an ORM, framework, Docker, Railway, or migration tooling.

Use the PostgreSQL relational-contract workflow for schema, query, transaction, index, pool, role, or recovery changes.
