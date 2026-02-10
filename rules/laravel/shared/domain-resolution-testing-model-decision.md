---
trigger: model_decision
description: "When tenant resolution tests are added or modified, separate web host/domains from mobile app-domain resolution."
---

## Rule
When tests depend on tenant resolution, explicitly separate web vs mobile contexts:
- Web: resolve via host/domains only.
- Mobile: use `X-App-Domain` header and ensure tenant `app_domains` contains the value.

## Rationale
App domains exist only for mobile contexts; web resolution must remain independent of `X-App-Domain`.

## Signals for Activation
- Editing tests under `tests/Feature/Tenants` or `tests/Api/v1` that resolve tenants.
- Adding coverage for branding, registration, or environment endpoints.

## Enforcement
- Ensure mobile-context tests set `X-App-Domain` and `app_domains`.
- Ensure web-context tests do not require `X-App-Domain`.

## Notes
Use the workflow `delphi-ai/workflows/laravel/domain-resolution-testing.md`.
