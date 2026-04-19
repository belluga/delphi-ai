---
description: "Define SSE delta streams that complement page-based list endpoints without replacing pagination."
---

# Workflow: Realtime Delta Streams (SSE)

## Purpose
Specify realtime SSE streams that deliver delta updates for paginated feeds (events, invites, map POIs) while keeping page-based listing as the source of truth.

## Preconditions
- `delphi-ai/system_architecture_principles.md` (P-15 Deterministic Pagination + Delta Streams).
- Current contracts in `foundation_documentation/endpoints_mvp_contracts.md`.
- Relevant route files under `routes/api/`.
- Related rules to load: `rules/core/core-instructions-always-on.md`, `rules/core/project-mandate-always-on.md`.

## Steps
1. Confirm the list endpoint remains page-based and define its filters.
2. Define the SSE stream route name and scope (tenant/app vs landlord/account).
3. Specify stream filters to match the list endpoint (search/tags/categories/geo).
4. Define event types (created/updated/deleted) and the minimal delta payload.
5. Document resync behavior (client refreshes page 1 on reconnect or invalidation).
6. Update `foundation_documentation/endpoints_mvp_contracts.md` with the SSE contract.
7. Update `foundation_documentation/system_roadmap.md` with the realtime workstream item.
8. Record any required client changes in the relevant `system_roadmap.md` entries and update the affected canonical module docs when the implementation snapshot materially changed.

## Outputs
- SSE endpoint definitions aligned with page-based list contracts.
- Roadmap entry for realtime delivery.
- Clear client resync strategy captured in documentation.

## Validation
- Contract review confirms page-based listing remains canonical.
- SSE payload is delta-only and does not duplicate list pagination.
