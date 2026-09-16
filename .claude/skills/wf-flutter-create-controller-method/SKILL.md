---
name: wf-flutter-create-controller-method
description: "Workflow: MUST use whenever the scope matches this purpose: Introduce a Flutter controller with local UI-state ownership and delegation of repository-owned canonical streams."
---

# Method: Create Controller (Flutter)

## Purpose
Introduce a controller that owns UI state, side effects, and StreamValue exposure per Sections 5 and 9 of the Flutter architecture doc. Ensures widgets remain pure UI and controllers encapsulate logic.

## Triggers
- New screen/feature requires state management or async operations.
- Shared behaviour should be extracted out of widgets.

## Inputs
- Feature documentation and domain projections involved.
- Existing controllers in the feature for reference.
- GetIt module registrations.

## Preferred Deterministic Helper
- Use `bash delphi-ai/tools/flutter_workflow_scaffold.sh --kind controller --name <controller_name> [--feature <feature>] [--output <path>]` to scaffold the doc/file/test checklist before implementation.
- Treat the helper as a checklist generator only; controller ownership, state shape, and DI decisions remain in this workflow.

## Procedure
1. **Document intent** – note the controller’s responsibilities in the module doc and Flutter roadmap if it affects API contracts or shared behaviour.
2. **File location** – create the controller under `lib/presentation/.../screens/<screen>/controllers/` (or feature-level controllers folder if shared).
3. **Class structure**
   - Implement `Disposable` when using `StreamValue` or other resources.
   - Inject repositories/services via constructor; resolve with GetIt.
   - Controllers (and domain services they call) are the *only* presentation-layer actors allowed to talk to repositories or infrastructure adapters. Widgets, routes, and helper builders must depend on controller APIs instead of touching data sources.
4. **State management**
   - Use controller-owned `StreamValue<T>` only for screen-, stage-, form-, or interaction-local state (with default values when appropriate).
   - Expose canonical cross-screen, paginated, cache-backed, or persistence-aligned state by delegating the persistent repository-owned `StreamValue`; do not copy it into controller lists, maps, `_cache`, `cached*`, or equivalent mutable stores.
   - Provide intent methods (e.g., `loadData`, `applyDecision`) that update local controller streams or invoke repository operations that update the canonical stream.
5. **UI controllers** – if `TextEditingController`, `ScrollController`, etc. are needed, instantiate and dispose them inside the controller (`onDispose`). Widgets obtain them via getters.
6. **BuildContext independence** – controllers must not receive `BuildContext`. Any navigation/dialog work happens in widgets via callbacks.
7. **DI registration** – register the controller in the feature module (`GetIt.registerFactory` or `registerLazySingleton`) and ensure the ModuleScope provides it.
8. **Realtime delta handling (when applicable)** – if the feature has SSE delta streams:
   - Keep the persistent repository-owned `StreamValue` as the canonical paginated reactive cache; apply delta updates by `id` and reconnect resyncs to that stream.
   - Keep cursor, `hasMore`, and in-flight guards as clearly owned operational metadata; do not create a second canonical collection cache in the controller.
   - Let the controller request repository refresh/reconnect work and expose/delegate the resulting stream.
9. **Tests/static analysis** – add controller tests if behaviour is complex; capture the stable full-workspace VS Code Problems snapshot. Do not start a concurrent CLI analyzer.
10. **Race-condition validation (when applicable)** – if the controller owns async actions that can be retriggered or reordered in flight, pair the work with `frontend-race-condition-validation`.

## Outputs
- Controller file with documented responsibilities and StreamValue exposure.
- DI/module setup referencing the controller.
- Updated docs/roadmap.

## Validation
- Stable full-workspace Problems snapshot and test suite pass.
- Widgets consume controller streams/controllers via GetIt without owning state themselves.
