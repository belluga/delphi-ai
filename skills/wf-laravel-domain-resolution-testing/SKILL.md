---
name: wf-laravel-domain-resolution-testing
description: "Workflow: MUST use whenever the scope matches this purpose: Ensure tests that depend on tenant resolution clearly distinguish web (host/domains) from mobile (X-App-Domain + app_domains)."
---

# Workflow: Domain Resolution Testing Split

## Purpose
Ensure tests that depend on tenant resolution clearly distinguish web (host/domains) from mobile (X-App-Domain + app_domains).

## Preconditions
- Laravel test scope (Feature/API tests).
- Related rules loaded:
  - `delphi-ai/rules/laravel/shared/core-instructions-always-on.md`
  - `delphi-ai/rules/laravel/shared/todo-driven-execution-model-decision.md`
  - `delphi-ai/rules/laravel/shared/domain-resolution-testing-model-decision.md`

## Steps
1. Identify tests that rely on tenant resolution (branding, registration, domain/app-domain tests).
2. Classify each test as:
   - Web context: resolve by host/domains only.
   - Mobile context: resolve by `X-App-Domain` + `app_domains`.
3. For mobile-context tests, ensure:
   - `X-App-Domain` header is set.
   - Tenant `app_domains` include the header value.
4. For web-context tests, ensure:
   - No `X-App-Domain` header is required.
   - Tenant `domains` (or host) are sufficient for resolution.
5. Document the classification in the test setup or comments where needed.

## Outputs
- Tests updated to explicitly reflect web vs mobile resolution pathways.

## Validation
- Run `php artisan test` (or relevant suites) and confirm tenant resolution behavior remains stable.
