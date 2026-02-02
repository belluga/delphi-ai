---
name: flutter-widget-local-state-heuristics
description: "MUST use whenever touching widget state (setState/StatefulWidget/local mutable fields) in Flutter presentation. Defines the boundary between ephemeral local state (allowed) and ModuleScope/controller-owned state (required)."
---

# Widget Local State Heuristics

## Allowed (ephemeral) — `setState` OK
All of the following must be true:
- UI-only state, no domain/repository usage, no side effects.
- Lifetime ends with a single sheet/dialog/screen pop.
- Not referenced by routes, ModuleScope, or shared controllers.
- Purely visual toggles (expand/collapse, selection highlight, password visibility).

## Not allowed (ModuleScope-adjacent) — controller required
Any of the following is true:
- Depends on repositories, domain models, auth, or router.
- Must survive rebuilds/navigation or is reused across widgets.
- Coordinates multiple widgets or drives validation/business logic.
- Lives inside `presentation/**/screens/**` or feature routes.

## Enforcement
- If in doubt, use a controller + StreamValue.
- Do not introduce `setState` into ModuleScope-affiliated widgets.
