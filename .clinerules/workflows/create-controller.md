---
name: create-controller
description: "Introduce a new Flutter controller that owns UI state, side effects, and StreamValue exposure. Ensures widgets remain pure UI and controllers encapsulate logic."
---

# Workflow: Create Controller (Flutter)

## Purpose

Introduce a controller that owns UI state, side effects, and StreamValue exposure. Ensures widgets remain pure UI and controllers encapsulate logic.

## Triggers

- New screen/feature requires state management or async operations
- Shared behavior should be extracted out of widgets

## Prerequisites

- [ ] Feature documentation and domain projections identified
- [ ] Existing controllers in the feature reviewed for reference
- [ ] GetIt module registrations understood

## Procedure


### Step 0: Package-First Gate
Read the proprietary packages checklist at `foundation_documentation/package_registry.md` and check whether an existing Flutter library already provides a controller or service for this functionality. If a matching library exists, extend it. Record the Package-First Assessment. See `paced.core.package-first`.


### Step 1: Document Intent

Note the controller's responsibilities in:
- The module doc
- Flutter roadmap (if it affects API contracts or shared behavior)

### Step 2: File Location

Create the controller under:
- `lib/presentation/.../screens/<screen>/controllers/` (screen-specific)
- OR feature-level controllers folder (if shared)

### Step 3: Class Structure

```dart
class ExampleScreenController implements Disposable {
  // 1. Inject repositories/services via constructor
  final ExampleRepository _repository;
  
  ExampleScreenController({
    required ExampleRepository repository,
  }) : _repository = repository;

  // 2. Expose state via StreamValue
  final stateStreamValue = StreamValue<ExampleState>();
  
  // 3. UI controllers (if needed)
  final formKey = GlobalKey<FormState>();
  final textController = TextEditingController();

  // 4. Intent methods
  Future<void> loadData() async {
    // Update streams, not widgets
  }

  @override
  void dispose() {
    textController.dispose();
  }
}
```

Key rules:
- Implement `Disposable` when using `StreamValue` or other resources
- Inject repositories/services via constructor; resolve with GetIt
- Controllers are the *only* presentation-layer actors allowed to talk to repositories

### Step 4: State Management

- Expose state via `StreamValue<T>` fields (with default values when appropriate)
- Provide intent methods (e.g., `loadData`, `applyDecision`) that update these streams

### Step 5: UI Controllers

If `TextEditingController`, `ScrollController`, etc. are needed:
- Instantiate them inside the controller
- Dispose them in `dispose()` method
- Widgets obtain them via getters

### Step 6: BuildContext Independence

**CRITICAL:** Controllers must NOT receive `BuildContext`.

Any navigation/dialog work:
- Happens in widgets via callbacks
- OR uses route guards
- Controller emits state, widget decides navigation

### Step 7: DI Registration

Register the controller in the feature module:

```dart
// In module registration
GetIt.registerFactory<ExampleScreenController>(
  () => ExampleScreenController(
    repository: GetIt.I.get<ExampleRepository>(),
  ),
);
```

Ensure the ModuleScope provides it.

### Step 8: Realtime Delta Handling (When Applicable)

If the feature has SSE delta streams:
- Maintain a paginated cache in the controller
- Apply delta updates by `id`
- On stream reconnect, re-fetch the first page to resync

### Step 9: Tests & Analyzer

- Add controller tests if behavior is complex
- Run `fvm flutter analyze`

## Outputs

- [ ] Controller file with documented responsibilities and StreamValue exposure
- [ ] DI/module setup referencing the controller
- [ ] Updated docs/roadmap

## Validation Checklist

- [ ] Analyzer/test suite passes
- [ ] Widgets consume controller streams via GetIt
- [ ] Widgets do not own state themselves
- [ ] No `BuildContext` in controller
- [ ] All UI controllers properly disposed