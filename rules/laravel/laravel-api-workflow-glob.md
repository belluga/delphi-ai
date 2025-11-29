---
activation_mode: glob
glob_pattern: "laravel-app/app/Http/**"
summary: Apply the API endpoint workflow when Laravel HTTP layer files are edited.
---

## Rule
Edits under `laravel-app/app/Http/**` (controllers, middleware, requests) must follow the API Endpoint Workflow:
- Keep controllers thin; delegate business logic to services.
- Apply Sanctum abilities/guards and tenant resolution before data access.
- Document request/response schemas and update roadmaps when endpoints change.

## Rationale
HTTP-layer changes are where routing, auth, and contract enforcement converge. The workflow keeps endpoints aligned with architectural tenets and client contracts.

## Enforcement
- Run the API Endpoint Workflow steps for these paths.
- Require PR references to updated docs/roadmaps and any ingress adjustments.

## Notes
Workflow reference: `delphi-ai/workflows/laravel/create-api-endpoint-method.md`.
