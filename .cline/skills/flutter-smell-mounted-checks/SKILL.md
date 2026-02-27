---
name: flutter-smell-mounted-checks
description: "MUST use whenever `mounted`/`context.mounted` checks, setState-after-await, or navigation after await appear in Flutter UI. Treats mounted checks as a smell and forces root-cause analysis + refactor guidance."
---

# Mounted Checks Smell

## Smell signals
- `if (!mounted)` / `if (!context.mounted)`
- `setState` after an `await`
- `Navigator` calls after async gaps in UI
  - **Note:** `mounted` guards used only for UI effects (snackbars/toasts) are not navigation smells but must be documented as exceptions.

## Root-cause questions (must answer)
- Why is async work owned by the widget instead of a controller?
- Why is navigation happening inside UI after awaits?
- Is lifecycle ownership unclear (controller vs widget)?

## Preferred fixes (in order)
1) Move async work + navigation into controller/router/guard.
2) Use controller disposal/cancellation instead of UI-mounted guards.
3) Replace `setState` with `StreamValue` updates.

## Acceptable exceptions (document explicitly)
- Tiny, local, UI-only widgets (ephemeral rule).
- UI-only effect callbacks (e.g., snackbars/toasts) scheduled post-frame or via stream reactions; no navigation or controller ownership.
- Legacy migration where refactor is out of scope (must add TODO).

## Exception logging (required)
- Record every accepted `mounted`/`context.mounted` exception in a project artifact.
- Preferred location (if available): `foundation_documentation/artifacts/flutter-mounted-exceptions.md`.
- The artifact must include: file path, decision (Deferred/Canceled/Resolved), rationale, date, and owner.
