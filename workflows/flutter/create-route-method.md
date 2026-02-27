---
description: Define a new route in the Flutter application using AutoRoute with ModuleScope integration and RouteModelResolver for domain object hydration.
---

# Create Route Method

## Purpose
Define a new route in the Flutter application using AutoRoute with ModuleScope integration and RouteModelResolver for domain object hydration.

## Prerequisites
- Feature domain entities defined
- Screen widget implemented
- Controller implemented (if needed)
- Canonical scope policy loaded: `foundation_documentation/policies/scope_subscope_governance.md`

## Steps

### 1. Define Route in AutoRoute
Add the route definition to the appropriate router file (e.g., `lib/core/routing/app_router.dart`):

```dart
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

### 1.1 Validate Scope/Subscope Ownership (Mandatory)
Before finalizing route definition, declare:
- `EnvironmentType` (`landlord|tenant`),
- main scope ownership (`site_public`, `landlord_area`, `tenant_public`, `tenant_admin`),
- subscope ownership when applicable (`account_workspace`).

Do not introduce undefined subscope keys/folders without explicit decision and policy update.

### 1.2 Run Route Contract Audit (Mandatory)
After defining/changing routes, scan generated router contracts and classify required non-URL args:

```bash
rg -n "required _i|required .*State|required String .*Name" flutter-app/lib/application/router/app_router.gr.dart
```

For each match, enforce one of:
- `URL-Hydratable`: required correctness data is resolvable from path/query + resolver/repository hydration.
- `Internal-Only`: route intentionally not deep-link-safe and has deterministic fallback/guard when args are absent.

No unclassified required non-URL route args are allowed.

### 2. Create RouteModelResolver (if needed)
If the route needs to hydrate domain objects before building the screen:

```dart
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

### 3. Register with ModuleScope
Ensure the route and its dependencies are registered in the appropriate module:

```dart
@module
abstract class YourFeatureModule {
  @singleton
  YourFeatureRouteResolver provideRouteResolver(YourRepository repository) {
    return YourFeatureRouteResolver(repository);
  }
}
```

### 4. Update Screen to Accept Resolved Data
```dart
@RoutePage()
class YourFeatureScreen extends StatelessWidget {
  final YourEntity entity; // Injected by RouteModelResolver

  const YourFeatureScreen({
    Key? key,
    required this.entity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use entity directly - already hydrated
    return Scaffold(
      appBar: AppBar(title: Text(entity.name)),
      body: YourFeatureContent(entity: entity),
    );
  }
}
```

### 5. Generate Routes
Run code generation:
```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

### 6. Verify
- Test navigation to the new route
- Verify domain objects are properly hydrated
- Ensure `fvm flutter analyze` passes
- Record route contract audit result in PR/TODO notes (including explicit "no new required non-URL args" when applicable)

## Architecture Principles
- **Backend-Driven UI**: Routes should hydrate domain objects from repositories before screen build
- **Separation of Concerns**: RouteModelResolver handles data fetching; screens remain pure UI
- **Type Safety**: Use AutoRoute's type-safe navigation
- **Dependency Injection**: Register all route dependencies via ModuleScope
- **Scope Governance**: Route ownership must comply with the canonical scope/subscope policy and be documented accordingly.

## Common Patterns
- **List → Detail**: Use RouteModelResolver to fetch detail entity by ID
- **Nested Routes**: Use AutoRoute's child routes for tab navigation
- **Guarded Routes**: Implement route guards for authentication/authorization
