# Laravel Settings Kernel PATCH Contract (Model Decision)

## Rule
For `/settings/values/{namespace}` PATCH endpoints:
- use direct field-presence semantics;
- nested fields use dot-path keys (for example `default_origin.lat`);
- envelope wrappers (for example `{namespace: {...}}`) are rejected unless a documented exception exists.

## Enforcement
- Require tests for valid dot-path payloads (`200`) and envelope rejection (`422`).
- Require client serialization tests asserting dot-path payload output.

## Workflow Reference
Use with `.clinerules/workflows/laravel-create-api-endpoint.md`.
