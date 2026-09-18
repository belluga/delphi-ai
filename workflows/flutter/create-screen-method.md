---
description: Scaffold a new feature screen with controller-local UI state, repository-owned canonical stream delegation, and pure Screen UI.
---

# Create Screen Method

## Purpose
Scaffold a new feature screen following the Feature-First architecture with proper separation between controller-local state, repository-owned canonical streams, and screen UI.

## Prerequisites
- Feature domain entities defined
- Repository contract defined (if needed)
- Canonical scope policy loaded: `foundation_documentation/policies/scope_subscope_governance.md`

## Steps

### 0. Package-First Gate
Run `bash delphi-ai/tools/query_packages.sh --project-root <path> --search "<keyword>"` to query proprietary packages and check whether an existing Flutter library already provides UI components, controllers, or shared widgets that cover this screen's functionality. If a matching library exists, extend it instead of creating new screen-level code. Record the Package-First Assessment in the TODO. See `paced.core.package-first`.

### 1. Create Feature Directory Structure
```

### 1.1 Validate Screen Scope/Subscope Placement (Mandatory)
Before creating files, declare and document:
- `EnvironmentType` ownership,
- main scope ownership,
- subscope ownership when applicable.

Do not place new screens in ambiguous legacy folders or create undefined subscopes without explicit decision and policy update.
lib/presentation/<module>/<feature>/
├── <feature>_screen.dart          # Pure UI
├── <feature>_controller.dart      # State management
├── widgets/                        # Feature-specific widgets
│   └── <widget>_widget.dart
└── models/                         # UI-specific models (if needed)
```

### 2. Implement Controller
The controller owns orchestration and only its local UI state. It delegates canonical entity/list streams to the repository instead of copying or owning them:

```dart
@injectable
class YourFeatureController {
  final YourRepository _repository;

  YourFeatureController(this._repository);

  // Controller-local interaction state.
  final isSubmitting = StreamValue<bool>(false);

  // Canonical entity state belongs to the repository and is delegated only.
  StreamValue<YourEntity?> get entity => _repository.entity;

  // Repository operations update the canonical stream.
  Future<void> loadData(String id) async {
    await _repository.loadById(id);
  }

  Future<void> performAction() async {
    isSubmitting.add(true);
    try {
      await _repository.performAction();
    } finally {
      isSubmitting.add(false);
    }
  }

  void dispose() {
    isSubmitting.close(); // Owns this local stream.
    // Never close `entity`: repository owns its canonical stream lifecycle.
  }
}
```

### 3. Implement Screen (Pure UI)
The screen is a pure UI component that consumes controller state:

```dart
@RoutePage()
class YourFeatureScreen extends StatelessWidget {
  const YourFeatureScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = GetIt.I<YourFeatureController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Feature')),
      body: StreamValueBuilder<YourEntity?>(
        streamValue: controller.entity,
        builder: (context, entity) {
          if (entity == null) {
            return const LoadingWidget();
          }

          return YourFeatureContent(
            entity: entity,
            onAction: controller.performAction,
          );
        },
      ),
    );
  }
}
```

### 4. Create Feature-Specific Widgets
Follow "one widget per file" rule:

```dart
// widgets/your_feature_content.dart
class YourFeatureContent extends StatelessWidget {
  final YourEntity entity;
  final VoidCallback onAction;

  const YourFeatureContent({
    Key? key,
    required this.entity,
    required this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(entity.name),
        ElevatedButton(
          onPressed: onAction,
          child: const Text('Perform Action'),
        ),
      ],
    );
  }
}
```

### 5. Register Dependencies
Add to the appropriate module:

```dart
@module
abstract class YourFeatureModule {
  @singleton
  YourFeatureController provideController(YourRepository repository) {
    return YourFeatureController(repository);
  }
}
```

### 6. Register Route
Add to `app_router.dart`:

```dart
AutoRoute(
  page: YourFeatureRoute.page,
  path: '/your-feature',
),
```

### 7. Generate Code
```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

### 8. Verify
- Capture the stable full-workspace VS Code Problems snapshot with no `Error` or `Warning`; do not start a concurrent CLI analyzer
- Test screen navigation
- Verify state updates correctly
- Check error handling
- For async CTA/search/filter/pagination flows, pair verification with `frontend-race-condition-validation`

## Architecture Principles
- **Controller Owns Local State**: Controllers own local interaction streams, UI controllers, and orchestration; repositories own canonical entity/list streams that controllers delegate.
- **Pure UI**: Screens and widgets are stateless, receive data via streams or parameters
- **StreamValue Pattern**: Use a controller `StreamValue` for local interaction state and a persistent repository `StreamValue` as the canonical reactive entity/list cache; dispose only resources owned by the controller.
- **Dependency Injection**: Controllers injected via GetIt, registered in modules
- **Feature-First**: All feature code in one directory
- **Scope Governance**: Screen placement/ownership must match canonical scope/subscope policy.

## Critical Rules
- **NO StatefulWidget for business state** - only for UI state (animations, focus)
- **NO business logic in widgets** - delegate to controller
- **ONE widget per file** - improves readability and reusability
- **Pass primitives to widgets** - or use DI fallback for shared services
