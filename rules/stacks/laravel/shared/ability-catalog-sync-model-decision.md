---
trigger: model_decision
description: "When introducing/changing Laravel abilities, keep namespace/route/policy abilities synchronized with token issuance catalogs and auth-path tests."
---

## Rule
When introducing or changing Laravel ability strings (routes, settings namespaces, policies, guards):
- register the ability in the canonical token catalog (`config/abilities.php`) when wildcard (`*`) expansion is used;
- ensure all references use the same ability string (route middleware, settings namespace definition, policy checks, tests);
- validate at least one real auth path (login -> token -> protected endpoint) using the changed ability.

## Rationale
Ability drift between route protection and token issuance creates false-positive permissions in tests and runtime `403` in production flows.

## Signals for Activation
- Editing `config/abilities.php`.
- Adding/changing `abilities:` middleware strings.
- Adding/changing settings namespace `ability` fields.
- Modifying auth/token generation logic that expands wildcard permissions.

## Enforcement
- Block delivery when a newly referenced ability is not present in `config/abilities.php` (for wildcard-expansion token paths).
- Require tests that prove both:
  - authorized path succeeds (`200/2xx`),
  - missing ability path fails (`403`).
- Prefer login-based token generation in at least one test path; do not rely only on `Sanctum::actingAs`.
