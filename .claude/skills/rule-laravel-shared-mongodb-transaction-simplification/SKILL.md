---
name: rule-laravel-shared-mongodb-transaction-simplification
description: "Rule: MUST use when creating, changing, or reviewing Laravel MongoDB transaction boundaries, retries, commit handling, or concurrency-conflict behavior."
---

# Rule: Laravel MongoDB Transaction Simplification

Load and follow the canonical rule:

`rules/stacks/laravel/shared/mongodb-transaction-simplification-model-decision.md`

The rule requires the domain concurrency policy to be decided before retry
mechanics, defaults to one explicit connection-owned transaction attempt when a
stable rejection contract is sufficient, and forbids compensating retry layers,
sentinel attempt counts, split sessions, or opportunistic cleanup outside the
active TODO. When the repository already has a canonical architecture guard,
the rule requires extending that guard instead of creating parallel enforcement.
