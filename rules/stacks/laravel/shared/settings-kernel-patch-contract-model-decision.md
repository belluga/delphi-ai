---
trigger: model_decision
description: "When touching Settings Kernel PATCH endpoints, enforce canonical payload semantics (dot-path field presence, no envelope wrappers)."
---

## Rule
For Settings Kernel PATCH endpoints (`/settings/values/{namespace}`):
- payload must use direct field-presence semantics;
- nested fields must use canonical dot-path keys (example: `default_origin.lat`);
- envelope wrappers (example: `{namespace: {...}}`) are invalid unless an explicit contract decision documents an exception;
- omitted fields remain unchanged;
- `null` clears only nullable fields; non-nullable `null` returns `422`.

## Rationale
Divergent payload shapes between clients and kernel validation create late-cycle integration regressions (`403/422`) and fragile fallbacks.

## Signals for Activation
- Editing settings kernel controllers/routes/validators.
- Editing Flutter/Laravel repositories that call `/settings/values/{namespace}`.
- Updating settings namespace schemas/definitions.

## Enforcement
- Add/update contract tests for:
  - valid dot-path payload (`200`),
  - envelope payload rejection (`422`),
  - nullable clear behavior.
- Ensure client repository tests assert the serialized PATCH payload shape.
