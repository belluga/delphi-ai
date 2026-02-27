# Flutter Architecture Rules (Always-On)

## Core Enforcement

### Widget/Controller Boundaries
- Screens are pure UI; state/logic lives in controllers.
- Repositories and domain layers must stay aligned with documented contracts.
- Widget state is only allowed for true ephemeral UI (see local-state heuristics). Anything ModuleScope-adjacent must be controller-driven.
- UI must not own `StreamValue` instances directly; StreamValue belongs in controllers only.
- Form keys (`GlobalKey<FormState>`) must live in controllers; screens/widgets only reference `_controller.formKey`.
- Screens resolve controllers via GetIt; routes should not pass controllers.
- Widgets may accept controllers for testability, but default to resolving via GetIt when needed.
- Child widgets should resolve their own controllers via GetIt; screens must not instantiate "pass-through" child controllers just to forward them.
- Controllers must depend on repositories/services/contracts (or value objects), never on other feature controllers.
- Global DI registration must only host true app-lifecycle dependencies; feature/module controllers must be registered in their owning module.
- Do not introduce ad-hoc mutable global stores for navigation/UI flow handoff; prefer route model/query params and controller state.
- UI controllers (TextEditingController/ScrollController/AnimationController/GlobalKey<FormState>/etc.) live in feature controllers, not screens/widgets.
- Screens/widgets only accept `_controller` and static view data parameters; any controlling parameter belongs in the controller.
- Navigation is owned by widgets/screens; controllers never navigate. Widget calls controller for decisions, then performs non-async navigation.
- Widgets/screens never construct `StreamValue` or `StreamValueBuilder` sources; they only consume controller-owned `StreamValue`.

### State Management Baseline
- Official state pattern: `StreamValue` + `StreamValueBuilder` (controller-owned streams only).
- Allowed local exception: constrained `setState` for ephemeral widget concerns only.
- Any residual/legacy manager is a deviation that must be removed or justified with explicit architecture decision.
- Residual scan targets:
  - `ChangeNotifier` / `ValueNotifier`
  - `Provider` / `Riverpod`
  - `Bloc` / `Cubit`
  - `MobX` (`Observable`, `Observer`)
  - `GetX` (`Rx`, `Obx`, `GetBuilder`)
  - Ad-hoc `StreamController` owned by widgets/screens.

### Data/Domain Boundaries
- DTOs used directly in UI, controllers, or domain (DTOs belong to infrastructure only).
- Domain entities/value objects depending on DTOs or infrastructure types.
- Repositories exposing DTOs (must return domain/projection models only).
- DAOs used outside infrastructure/repository layer.
- Mapping logic inside UI/controllers (must live in repositories/infrastructure).

### Navigation & Routes
- Controllers triggering navigation directly (controllers never navigate).
- Direct `Navigator.push`/`pop` in screens (bypass router/route model).
- Route arguments passing raw DTOs instead of domain/projection models.
- Routes defined without ModuleScope/RouteModelResolver when required by feature.
- Any route with required non-URL constructor args in `app_router.gr.dart` that is not explicitly classified as either:
  - `URL-Hydratable` (path/query + resolver contract), or
  - `Internal-Only` (documented guard/fallback when opened without args).

---

## Hard NO (Blockers)

These patterns must be blocked on sight:

- Repository/domain/DAO access inside screens/widgets.
- Any state manager other than StreamValue (Provider/Bloc/GetX/ChangeNotifier/ValueNotifier/etc.).
- Multiple widgets or multiple screens in the same file.
- Business logic in screens (filters, mapping, validation, formatting).
- Direct GetIt access in widgets (controllers only).
- Network calls or side effects inside UI (no async work in widgets).
- StreamValue instances created/owned inside widgets/screens (must live in controllers).
- StreamValue passed into widgets/screens as a parameter (must be owned by controller and resolved via GetIt).
- UI controllers (TextEditingController/ScrollController/AnimationController/GlobalKey<FormState>/etc.) owned in screens/widgets.
- Screens/widgets with controlling parameters (callbacks, state flags, stream values, controllers) passed in instead of owned by controller.
- `stream.listen` subscriptions inside widgets/screens (use `StreamValueBuilder`-driven UI only; effect handling must be centralized and explicitly approved).
- Widgets/screens calling controller `onDispose()`/`dispose()` (ModuleScope owns controller lifecycles unless explicitly approved).
- Screens instantiating child widget controllers solely to pass into widgets (child should resolve via GetIt; only pass for tests).
- Controller depending on another feature controller (constructor/field/GetIt lookup) instead of repository/service contract.
- Registering feature/module controllers inside global dependency bootstrap (e.g., `registerGlobalDependencies`) instead of module registration.
- Mutable singleton store used as cross-layer navigation handoff (guard -> widget/screen) when route/query parameters can carry the intent.

---

## Soft NO (Conditional)

Allowed only if truly ephemeral:

- `setState` in presentation (allowed only for tiny, local, UI-only, single-route lifespan).
- Local mutable fields in State classes (same rule as `setState`).
  - Two acceptable paths:
    - Create a small **ephemeral wrapper widget** that owns the mutable fields and keeps them UI-only.
    - Move the fields into the **controller** when they represent cross-widget/stateful behavior or outlive the widget.

---

## Conditional (Flag + Explicit Decision Required)

- Disposing controllers in widgets (flag unless explicitly approved).
- UI decides what to fetch (should be controller-driven, backend-driven UI).
- DTOs used directly in UI (must be Projection/Domain model).
- Widget file under `presentation/**/screens/**` without a corresponding controller.
- Screen changes without updating `foundation_documentation` contracts.
- Widget performs async navigation directly after an await (should be: await controller → sync navigate).

---

## Quick Boundary Check

- If it touches a repository, router, domain model, or persists across navigation → controller + StreamValue.
- If it is a transient UI-only interaction (single sheet/dialog, no side effects) → local state allowed.

---

## Analyzer & Test Requirements

- Analyzer: `fvm flutter analyze` must be clean.
- Tests: add/maintain unit/widget tests where impacted flows change.
- Route contract audit: classify required non-URL route args in `flutter-app/lib/application/router/app_router.gr.dart`.
- Reference `foundation_documentation/system_architecture_principles.md` Appendix A for full context.
- Update module/route docs when adding screens or routes.
