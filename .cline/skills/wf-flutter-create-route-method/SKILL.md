---
name: wf-flutter-create-route-method
description: "Workflow: MUST use whenever the scope matches this purpose: Define a new route in the Flutter application using AutoRoute with ModuleScope integration and RouteModelResolver for domain object hydration."
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
bash delphi-ai/tools/flutter_route_contract_audit.sh
```

For each match, enforce one of:
- `URL-Hydratable`: required correctness data is resolvable from path/query + resolver/repository hydration.
- `Internal-Only`: route intentionally not deep-link-safe and has deterministic fallback/guard when args are absent.

No unclassified required non-URL route args are allowed.

### 1.3 Classify Entry Mode and History Ownership (Mandatory)
Before implementing route behavior, classify how the route is entered:
- `Cold Entry`: URL/deeplink/startup entry where no prior in-app history can be assumed.
- `Warm Entry`: user-initiated navigation from an already-visible app route.

Required decisions:
- `Cold Entry` may remain guard/builder owned, but must define deterministic fallback when required context is absent.
- `Warm Entry` that must preserve predecessor history must commit a real router entry before any interruption/boundary logic resolves. Do not rely on unresolved guard redirects alone to create browser/device history.
- Returning to an already-existing root or shell section may use stack-aware router navigation only when preserving the predecessor route is not the goal.

### 1.4 Classify Boundary vs Ordinary Route Behavior (Mandatory)
If the route can interrupt another route family (for example permission, promotion, auth-continuation, or confirmation):
- Declare whether it is an ordinary route family or a boundary/interruption route.
- Boundary routes may be modeled as typed result-return routes when they temporarily interrupt another flow.
- Define explicit `success`, `cancel/dismiss`, and `no-history` outcomes.
- Visible back and system/device back must converge semantically for that route.
- Do not solve missing history with synthetic browser-history seeding or manual ancestry fabrication.

### 1.5 Classify Architectural Test Matrix (Mandatory)
If the route change is large or architectural, treat it as mandatory multi-lane test work rather than analyzer-only validation.

Architectural triggers include, for example:
- route guards or shell composition changes;
- route contract / resolver ownership changes;
- cold-entry/deeplink/startup-builder resolution changes;
- warm-entry predecessor history or back-stack semantics changes;
- boundary/result-return route outcome changes;
- login/logout continuation or protected-route handoff changes.

When this trigger is active:
- run `test-creation-standard` to freeze the required coverage matrix;
- run `test-orchestration-suite` for execution sequencing;
- require unit + widget + integration evidence for the affected critical paths;
- if the affected route flow is compatibility-critical or backend-coupled, require real-backend evidence for at least one web integration flow and one mobile integration flow;
- do not claim delivery-ready status while any required test lane is `blocked` or `failed` unless the current human approval authority records an explicit waiver.

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
- Test cold/deeplink entry when the route is intended to support it
- Test warm predecessor-preserving navigation when the route is entered from app chrome/CTA and back behavior is part of the contract
- Test `success`, `cancel/dismiss`, and `no-history` outcomes for boundary/result-return routes when applicable
- When Section `1.5` is triggered, run the required unit + widget + integration flows for the affected critical paths
- When Section `1.5` is triggered and the flow is compatibility-critical or backend-coupled, run the required real-backend web + mobile integration flows
- When Section `1.5` is triggered, treat `blocked` required test evidence as a delivery blocker, not as a pass
- Ensure `fvm flutter analyze` passes
- Record route contract audit result in PR/TODO notes (including explicit "no new required non-URL args" when applicable)

## Architecture Principles
- **Backend-Driven UI**: Routes should hydrate domain objects from repositories before screen build
- **Separation of Concerns**: RouteModelResolver handles data fetching; screens remain pure UI
- **Type Safety**: Use AutoRoute's type-safe navigation
- **Dependency Injection**: Register all route dependencies via ModuleScope
- **Scope Governance**: Route ownership must comply with the canonical scope/subscope policy and be documented accordingly.
- **History Truthfulness**: warm in-app flows that must preserve predecessor back behavior must commit real router history instead of depending on implicit guard redirects.
- **Boundary Explicitness**: interruption routes need explicit success/cancel/no-history contracts; back semantics are architecture, not incidental behavior.
- **Architectural Proof**: large or architectural route changes require unit + widget + integration evidence for the affected critical paths; compatibility-critical flows additionally require real-backend web + mobile integration.

## Common Patterns
- **List → Detail**: Use RouteModelResolver to fetch detail entity by ID
- **Nested Routes**: Use AutoRoute's child routes for tab navigation
- **Guarded Routes**: Implement route guards for authentication/authorization
