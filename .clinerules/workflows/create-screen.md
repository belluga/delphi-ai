---
name: create-screen
description: "Scaffold a new Flutter feature screen following Feature-First architecture with proper separation between Controller (state) and Screen (UI)."
---

# Workflow: Create Screen (Flutter)

## Purpose

Scaffold a new feature screen following the Feature-First architecture with proper separation between Controller (state) and Screen (UI).

## Triggers

- New feature requires a screen
- New route/page needs to be added
- UI implementation for existing controller

## Prerequisites

- [ ] Feature domain entities defined
- [ ] Repository contract defined (if needed)
- [ ] Controller exists or will be created (use `create-controller` workflow)

## Procedure

### Step 0: Package-First Gate
Run `bash delphi-ai/tools/query_packages.sh --project-root <path> --search "<keyword>"` to query proprietary packages and check whether an existing Flutter library already provides UI components or shared widgets that cover this screen. If a matching library exists, extend it. Record the Package-First Assessment. See `paced.core.package-first`.

### Step 1: Create Feature Directory Structure

```
lib/presentation/<module>/<feature>/
├── <feature>_screen.dart          # Pure UI
├── controllers/
│   └── <feature>_controller.dart  # State management
├── widgets/                        # Feature-specific widgets
│   └── <widget>_widget.dart
└── models/                         # UI-specific models (if needed)
```

### Step 2: Implement Controller First

If controller doesn't exist, create it first (see `create-controller` workflow):

```dart
// controllers/<feature>_controller.dart
class YourFeatureController implements Disposable {
  final YourRepository _repository;
  
  YourFeatureController({required YourRepository repository})
      : _repository = repository;

  // State using StreamValue
  final stateStreamValue = StreamValue<YourEntity?>(initialValue: null);
  
  // UI controllers (if needed)
  final formKey = GlobalKey<FormState>();
  final textController = TextEditingController();

  // Intent methods
  Future<void> loadData(String id) async {
    final entity = await _repository.fetchById(id);
    stateStreamValue.value = entity;
  }

  Future<void> performAction() async {
    // Business logic here
  }

  @override
  void dispose() {
    textController.dispose();
  }
}
```

### Step 3: Implement Screen (Pure UI)

```dart
// <feature>_screen.dart
class YourFeatureScreen extends StatefulWidget {
  const YourFeatureScreen({super.key});

  @override
  State<YourFeatureScreen> createState() => _YourFeatureScreenState();
}

class _YourFeatureScreenState extends State<YourFeatureScreen> {
  final _controller = GetIt.I.get<YourFeatureController>();

  @override
  void initState() {
    super.initState();
    _controller.loadIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Feature')),
      body: StreamValueBuilder<YourEntity?>(
        streamValue: _controller.stateStreamValue,
        builder: (context, entity) {
          if (entity == null) {
            return const LoadingWidget();
          }
          return YourFeatureContent(
            entity: entity,
            onAction: _controller.performAction,
          );
        },
      ),
    );
  }
}
```

### Step 4: Create Feature-Specific Widgets

Follow **one widget per file** rule:

```dart
// widgets/your_feature_content.dart
class YourFeatureContent extends StatelessWidget {
  final YourEntity entity;
  final VoidCallback onAction;

  const YourFeatureContent({
    super.key,
    required this.entity,
    required this.onAction,
  });

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

### Step 5: Register Route

Create route file with ModuleScope:

```dart
// routes/<feature>_route.dart
@RoutePage(name: 'YourFeatureRoute')
class YourFeatureRoutePage extends StatelessWidget {
  const YourFeatureRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleScope<YourFeatureModule>(
      child: const YourFeatureScreen(),
    );
  }
}
```

Add to `app_router.dart`:

```dart
AutoRoute(
  page: YourFeatureRoute.page,
  path: '/your-feature',
),
```

### Step 6: Register Dependencies

Add to the appropriate module:

```dart
@module
abstract class YourFeatureModule {
  @factory
  YourFeatureController provideController(YourRepository repository) {
    return YourFeatureController(repository: repository);
  }
}
```

### Step 7: Generate Code

```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 8: Verification

- Run `fvm flutter analyze` - must be clean
- Test screen navigation
- Verify state updates correctly
- Check error handling

## Architecture Principles

| Principle | Description |
|-----------|-------------|
| Controller Owns State | All business logic and state in controller, never in widgets |
| Pure UI | Screens and widgets are stateless, receive data via streams or parameters |
| StreamValue Pattern | Use `StreamValue` for reactive state management |
| Dependency Injection | Controllers injected via GetIt, registered in modules |
| Feature-First | All feature code in one directory |

## Critical Rules

- **NO StatefulWidget for business state** - only for UI state (animations, focus)
- **NO business logic in widgets** - delegate to controller
- **ONE widget per file** - improves readability and reusability
- **Pass primitives to widgets** - or use DI fallback for shared services
- **NO BuildContext in controllers** - navigation happens in widgets

## Outputs

- [ ] Screen file with pure UI implementation
- [ ] Feature-specific widgets (one per file)
- [ ] Route with ModuleScope
- [ ] Module registration for dependencies
- [ ] Analyzer passes with no warnings