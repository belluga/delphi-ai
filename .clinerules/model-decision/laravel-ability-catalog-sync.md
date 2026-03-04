# Laravel Ability Catalog Sync (Model Decision)

## Rule
When introducing or changing Laravel ability strings (routes, settings namespaces, policies, guards):
- register the ability in `config/abilities.php` when wildcard expansion (`*`) is used;
- keep route/policy/settings ability names synchronized;
- verify at least one login-token path for the protected endpoint.

## Enforcement
- Block delivery when new ability strings are missing from `config/abilities.php` in wildcard token paths.
- Require authorized (`2xx`) and forbidden (`403`) coverage for affected abilities.

## Workflow Reference
Use with `.clinerules/workflows/laravel-create-api-endpoint.md`.
