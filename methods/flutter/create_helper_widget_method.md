---
description: Create a helper widget in the Flutter application
---

# Create Helper Widget Method

## Purpose
Create reusable, pure UI widgets following the "one widget per file" rule and proper dependency injection patterns.

## Prerequisites
- Understanding of widget's purpose and data requirements
- Feature or shared directory identified

## Steps

### 1. Determine Widget Location
**Feature-specific widgets:**
```
lib/presentation/<module>/<feature>/widgets/<widget_name>.dart
```

**Shared widgets:**
```
lib/presentation/shared/widgets/<widget_name>.dart
```

### 2. Create Pure UI Widget
Widgets should be stateless and receive all data via parameters:

```dart
class YourHelperWidget extends StatelessWidget {
  // Primitives or domain objects as parameters
  final String title;
  final YourEntity entity;
  final VoidCallback? onTap;

  const YourHelperWidget({
    Key? key,
    required this.title,
    required this.entity,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(entity.description),
        onTap: onTap,
      ),
    );
  }
}
```

### 3. For Widgets Needing Services (DI Fallback)
If a widget needs access to shared services (e.g., navigation, theme):

```dart
class YourHelperWidget extends StatelessWidget {
  final YourEntity entity;
  
  // Optional DI - can be overridden for testing
  final NavigationService? navigationService;

  const YourHelperWidget({
    Key? key,
    required this.entity,
    this.navigationService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nav = navigationService ?? GetIt.I<NavigationService>();
    
    return GestureDetector(
      onTap: () => nav.navigateTo('/details/${entity.id}'),
      child: Text(entity.name),
    );
  }
}
```

### 4. For Complex Widgets with Local UI State
Use StatefulWidget ONLY for UI state (animations, focus, scroll):

```dart
class YourAnimatedWidget extends StatefulWidget {
  final YourEntity entity;
  final VoidCallback onComplete;

  const YourAnimatedWidget({
    Key? key,
    required this.entity,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<YourAnimatedWidget> createState() => _YourAnimatedWidgetState();
}

class _YourAnimatedWidgetState extends State<YourAnimatedWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Text(widget.entity.name),
    );
  }
}
```

### 5. Create Widget Variants (if needed)
For different visual states:

```dart
// Base widget
class YourCard extends StatelessWidget {
  final YourEntity entity;
  final bool isSelected;

  const YourCard({
    Key? key,
    required this.entity,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: isSelected 
          ? Border.all(color: Colors.blue, width: 2)
          : null,
      ),
      child: YourCardContent(entity: entity),
    );
  }
}

// Named constructors for variants
class YourCard extends StatelessWidget {
  // ... same as above

  const YourCard.compact({
    Key? key,
    required YourEntity entity,
  }) : this(
    key: key,
    entity: entity,
    isSelected: false,
  );
}
```

### 6. Document Widget Usage
Add documentation comments:

```dart
/// A card widget displaying [YourEntity] information.
///
/// This widget is pure UI and requires all data to be passed
/// via parameters. For interactive behavior, pass callbacks.
///
/// Example:
/// ```dart
/// YourHelperWidget(
///   title: 'Example',
///   entity: myEntity,
///   onTap: () => print('Tapped'),
/// )
/// ```
class YourHelperWidget extends StatelessWidget {
  // ...
}
```

### 7. Verify
- Widget is in its own file
- No business logic in widget
- All data passed via parameters or DI fallback
- `fvm flutter analyze` passes

## Architecture Principles
- **One Widget Per File**: Improves discoverability and reusability
- **Pure UI**: Widgets receive data, don't fetch or manage business state
- **Pass Primitives**: Prefer passing simple types over complex objects when possible
- **DI Fallback Pattern**: Allow service injection for testing, fallback to GetIt
- **StatefulWidget Only for UI State**: Animations, focus, scroll - never business state

## Common Patterns

### List Item Widget
```dart
class YourListItem extends StatelessWidget {
  final YourEntity entity;
  final VoidCallback onTap;

  const YourListItem({
    Key? key,
    required this.entity,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(entity.name),
      subtitle: Text(entity.description),
      onTap: onTap,
    );
  }
}
```

### Empty State Widget
```dart
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyStateWidget({
    Key? key,
    required this.message,
    this.onAction,
    this.actionLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message),
          if (onAction != null && actionLabel != null)
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}
```

### Loading Widget
```dart
class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!),
          ],
        ],
      ),
    );
  }
}
```

## Critical Rules
- **NO controller ownership in widgets** - controllers belong to screens
- **NO GetIt calls without DI fallback** - makes testing harder
- **NO business logic** - widgets are presentation only
- **ONE responsibility** - each widget does one thing well
