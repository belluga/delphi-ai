# Flutter Controller Workflow (Glob Rule)

**Applies to:** `flutter-app/lib/presentation/**/controllers/**`

## Rule

When working inside controller directories, run the Controller Workflow:

### Controller Responsibilities
- Own StreamValue state
- Own UI controllers (TextEditingController, ScrollController, etc.)
- Orchestrate repository calls
- Never accept `BuildContext`

### Requirements
- Register controllers via ModuleScope/GetIt
- Document responsibilities in controller docstring
- Ensure analyzer/tests cover new behavior

## Rationale

Controllers enforce the separation between UI and domain logic. The workflow keeps every controller aligned with architecture tenets.

## Enforcement

- [ ] Run the Controller Workflow checklist for any edits to these paths
- [ ] PRs must show analyzer/test evidence when controller logic changes
- [ ] No `BuildContext` parameters in controller methods

## Workflow Reference

See: `.clinerules/workflows/create-controller.md`

## Quick Checklist

- [ ] Controller registered in ModuleScope
- [ ] StreamValue used for state (not ChangeNotifier/ValueNotifier)
- [ ] No BuildContext accepted
- [ ] Repository injected via constructor
- [ ] Tests cover key behaviors