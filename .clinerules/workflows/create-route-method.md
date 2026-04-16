---
name: create-route
description: "Define a new route in Flutter using AutoRoute with ModuleScope integration and RouteModelResolver for domain object hydration."
---

# Workflow: Create Route (Flutter)

## Purpose

Define a new route in the Flutter application using AutoRoute with ModuleScope integration and RouteModelResolver for domain object hydration.

## Triggers

- New screen needs navigation
- Existing route needs modification
- Feature requires domain object hydration on navigation

## Prerequisites

- [ ] Feature domain entities defined
- [ ] Screen widget implemented
- [ ] Controller implemented (if needed)
- [ ] Canonical scope policy loaded: `foundation_documentation/policies/scope_subscope_governance.md`

## Procedure

### Step 1: Define Route in AutoRoute

Add route definition to router file:

```dart
// lib/core/routing/app_router.dart
@AutoRouterConfig()
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => [
    // ... existing routes
    AutoRoute(
      page: YourFeatureRoute.page,
      path: '/your-feature/:id',
    ),
  ];
}
```

### Step 1.1: Validate Scope/Subscope Ownership (Mandatory)

Before finalizing route definition, declare:
- `EnvironmentType` (`landlord|tenant`)
- main scope ownership (`site_public`, `landlord_area`, `tenant_public`, `tenant_admin`)
- subscope ownership when applicable (`account_workspace`)

Do not introduce undefined subscope keys/folders without explicit decision and policy update.

### Step 1.2: Run Route Contract Audit (Mandatory)

After defining/changing routes, scan generated router contracts and classify required non-URL args:

```bash
rg -n "required _i|required .*State|required String .*Name" flutter-app/lib/application/router/app_router.gr.dart
```

For each match, enforce one of:
- `URL-Hydratable`: required correctness data is resolvable from path/query + resolver/repository hydration.
- `Internal-Only`: route intentionally not deep-link-safe and has deterministic fallback/guard when args are absent.

No unclassified required non-URL route args are allowed.

### Step 2: Create RouteModelResolver (if needed)

For routes that need domain object hydration:

```dart
// lib/presentation/your_feature/routes/your_feature_route_resolver.dart
class YourFeatureRouteResolver extends RouteModelResolver<YourEntity> {
  final YourRepository _repository;

  YourFeatureRouteResolver(this._repository);

  @override
  Future<YourEntity> resolve(RouteData routeData) async {
    final id = routeData.pathParams.getString('id');
    return await _repository.fetchById(id);
  }
}
```

**When to use RouteModelResolver:**
- Detail screens that need entity pre-loaded
- Routes with path parameters
- Routes requiring data before screen build

### Step 3: Create Route Page with ModuleScope

```dart
// lib/presentation/your_feature/routes/your_feature_route.dart
@RoutePage(name: 'YourFeatureRoute')
class YourFeatureRoutePage extends StatelessWidget {
  final String id;

  const YourFeatureRoutePage({
    super.key,
    @PathParam('id') required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return ModuleScope<YourFeatureModule>(
      child: YourFeatureScreen(id: id),
    );
  }
}
```

### Step 4: Register with ModuleScope

Ensure dependencies are registered:

```dart
@module
abstract class YourFeatureModule {
  @singleton
  YourFeatureRouteResolver provideRouteResolver(YourRepository repository) {
    return YourFeatureRouteResolver(repository);
  }
  
  @factory
  YourFeatureController provideController(YourRepository repository) {
    return YourFeatureController(repository: repository);
  }
}
```

### Step 5: Update Screen to Accept Parameters

```dart
@RoutePage()
class YourFeatureScreen extends StatefulWidget {
  final String id;

  const YourFeatureScreen({
    super.key,
    @PathParam('id') required this.id,
  });

  @override
  State<YourFeatureScreen> createState() => _YourFeatureScreenState();
}

class _YourFeatureScreenState extends State<YourFeatureScreen> {
  final _controller = GetIt.I.get<YourFeatureController>();

  @override
  void initState() {
    super.initState();
    _controller.loadIfNeeded(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Feature')),
      body: StreamValueBuilder<YourEntity?>(
        streamValue: _controller.entityStreamValue,
        builder: (context, entity) {
          if (entity == null) {
            return const LoadingWidget();
          }
          return YourFeatureContent(entity: entity);
        },
      ),
    );
  }
}
```

### Step 6: Generate Routes

```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 7: Verify

- [ ] Test navigation to new route
- [ ] Verify domain objects properly hydrated
- [ ] Run `fvm flutter analyze`
- [ ] Test route parameters work correctly
- [ ] Record route contract audit result in PR/TODO notes (including explicit "no new required non-URL args" when applicable)

## Route Patterns

### Simple Route (no parameters)

```dart
AutoRoute(
  page: HomeRoute.page,
  path: '/home',
)
```

### Route with Path Parameters

```dart
AutoRoute(
  page: DetailRoute.page,
  path: '/detail/:id',
)
```

### Route with Query Parameters

```dart
AutoRoute(
  page: SearchRoute.page,
  path: '/search',
)

// Navigation with query params
context.router.push(SearchRoute(query: 'flutter'));
```

### Nested Routes (Tabs)

```dart
AutoRoute(
  path: '/settings',
  page: SettingsRoute.page,
  children: [
    AutoRoute(path: 'profile', page: ProfileRoute.page),
    AutoRoute(path: 'preferences', page: PreferencesRoute.page),
  ],
)
```

### Guarded Routes (Auth)

```dart
AutoRoute(
  page: AdminRoute.page,
  path: '/admin',
  guards: [AuthRouteGuard],
)
```

## Architecture Principles

| Principle | Description |
|-----------|-------------|
| Backend-Driven UI | Routes hydrate domain objects from repositories before screen build |
| Separation of Concerns | RouteModelResolver handles data fetching; screens remain pure UI |
| Type Safety | Use AutoRoute's type-safe navigation |
| Dependency Injection | Register all route dependencies via ModuleScope |

## Common Anti-Patterns

**❌ DO NOT:**
- Pass controllers through routes
- Pass DTOs through routes
- Do data fetching in screen build
- Use `Navigator.push` directly

**✅ DO:**
- Use AutoRoute for all navigation
- Use RouteModelResolver for data hydration
- Pass only IDs/primitives through routes
- Let ModuleScope handle DI

## Outputs

- [ ] Route definition in app_router.dart
- [ ] RouteModelResolver (if needed)
- [ ] ModuleScope wrapper
- [ ] Module registration
- [ ] Generated route files
- [ ] Analyzer passes

## Validation Checklist

- [ ] Navigation works correctly
- [ ] Path parameters resolved
- [ ] Query parameters work
- [ ] Domain objects hydrated
- [ ] No `Navigator.push` usage
- [ ] No controllers passed through routes
