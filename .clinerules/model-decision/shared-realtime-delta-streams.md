# Realtime Delta Streams (Model Decision)

## Rule

When adding or revising realtime feed behavior (SSE streams, delta updates, or pagination policies):

### Requirements
- Run the Realtime Delta Streams Workflow
- Keep list endpoints page-based and treat SSE as delta-only
- Document SSE routes, event types, and resync behavior in `foundation_documentation/endpoints_mvp_contracts.md`
- Ensure a roadmap entry exists for realtime delivery

## Rationale

Realtime updates must complement, not replace, deterministic pagination. This keeps caching predictable while enabling live UI updates.

## Enforcement

- Block SSE additions that do not include a paginated list source of truth
- Block pagination changes without updating the realtime workflow outputs

## Workflow Reference

See: `.clinerules/workflows/docker-realtime-delta-streams.md`