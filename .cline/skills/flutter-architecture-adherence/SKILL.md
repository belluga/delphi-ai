---
name: flutter-architecture-adherence
description: "Architecture guardrail for Flutter. MUST use whenever touching Flutter presentation, controllers, repositories, routes, domain models, or widget state. Enforces adherence rules, selects the correct sub-skills, and blocks improper setState usage."
---

# Flutter Architecture Adherence (Umbrella)

Use this skill as the entrypoint for any Flutter change that can impact architecture.

## Required sub-skills (invoke as applicable)
- `rule-flutter-flutter-screen-workflow-glob` for `lib/presentation/**/screens/**`
- `rule-flutter-flutter-controller-workflow-glob` for `lib/presentation/**/controllers/**`
- `rule-flutter-flutter-repository-workflow-glob` for `lib/infrastructure/repositories/**`
- `rule-flutter-flutter-domain-workflow-glob` for `lib/domain/**`
- `rule-flutter-flutter-route-workflow-glob` for `lib/**/routes/**`
- `flutter-widget-local-state-heuristics` for any widget state (`setState`, `StatefulWidget`, local mutable fields)

## Canonical Sources (Single Source Policy)
- Canonical architecture contract: `foundation_documentation/modules/flutter_client_experience_module.md` (section `2.1.1 Presentation DI Matrix (Canonical)`).
- Executable lint contract and treatments: `flutter-app/tool/belluga_analysis_plugin/docs/rules.md`.
- Tactical delivery/debt status: `foundation_documentation/todos/active/mvp_slices/TODO-v1-flutter-architecture-rules-consolidation-and-custom-lint.md`.
- If wording differs across files, prefer these sources in this exact precedence order.

## Analyzer Plugin Enforcement Contract
- Mandatory command for architecture checks (run at `flutter-app` root): `fvm dart analyze --format machine`.
- If local CLI analyzer state goes false-clean, stale, or hangs unexpectedly, run `bash ./scripts/reset_analyzer_state.sh` from `flutter-app` root, then rerun `fvm dart analyze --format machine`.
- Do not use directory-target mode as architecture gate (for example: `fvm dart analyze lib`), because it can report false-clean in this workspace.
- Rule matrix validation command (plugin regression only): `bash tool/belluga_analysis_plugin/bin/validate_rule_matrix.sh`.
- `tool/belluga_analysis_plugin/bin/run_project_analyze.sh` was removed from the workflow; do not reintroduce file-list wrappers as architecture gate.
- `SEM EXCEÇÃO`: do not bypass architecture findings with per-file ignores/allowlists.
- If a finding is wrong, calibrate the lint rule; do not suppress it.
- When an active debt TODO requires branch-delta enforcement for disabled rules, run the branch guard command(s) declared in the TODO before delivery.
- Rule IDs currently enforced for architecture governance:
  - P0: `ui_getit_non_controller_forbidden`, `ui_direct_repository_service_resolution_forbidden`, `ui_cross_feature_controller_resolution_forbidden`, `module_scoped_controller_dispose_forbidden`, `ui_streamvalue_ownership_forbidden`, `ui_dto_import_forbidden`, `domain_dto_dependency_forbidden`, `module_direct_getit_registration_forbidden`, `repository_json_parsing_forbidden`, `repository_raw_transport_typing_forbidden`, `repository_raw_payload_map_forbidden` (branch-delta when globally disabled), `service_json_parsing_forbidden`, `repository_inline_dto_to_domain_mapper_forbidden`.
  - P1: `ui_navigation_after_await_forbidden`, `controller_direct_navigation_forbidden`, `ui_navigator_usage_forbidden`, `ui_build_side_effects_forbidden`, `ui_future_stream_builder_forbidden`, `ui_controller_ownership_forbidden`.
  - P2: `screen_controller_resolution_pattern_required`, `multi_widget_file_warning`, `controller_buildcontext_dependency_forbidden`, `global_ui_controller_naming_forbidden`.

## Core enforcement
- Screens are pure UI; state/logic lives in controllers.
- Controllers are the only allowed data ingress gate for screens/widgets.
- Screens/widgets must never fetch, resolve, or proxy data through repository/service/state-holder directly.
- In presentation `screens/widgets`, `GetIt` resolution is allowed only for same-feature controllers.
- In presentation `screens/widgets`, resolving cross-feature controllers is forbidden.
- Repositories and domain layers must stay aligned with documented contracts.
- Repository transport boundary is strict:
  - DAO/decoder layers own raw payload envelopes and map parsing/building,
  - repositories consume typed DAO outputs (DTO/domain mappers) and return domain/projections only.
- Widget state is only allowed for true ephemeral UI (see local-state heuristics). Anything ModuleScope-adjacent must be controller-driven.
- UI must not own `StreamValue` instances directly; StreamValue belongs in controllers only.
- `StreamValue` in controllers is valid in two cases only:
  - local screen/stage state,
  - pure delegation of repository-owned canonical streams.
- Canonical shared state (cross-controller/module lifespan, cache-backed, persistence-aligned) must be owned by repository contracts/implementations.
- Services/DAL are technical adapters and must not own canonical shared state via `StreamValue`, `StreamController`, `ValueNotifier`, `ChangeNotifier`, or equivalent holders.
- Form keys (`GlobalKey<FormState>`) must live in controllers; screens/widgets only reference `_controller.formKey`.
- Screens resolve controllers via GetIt; routes should not pass controllers.
- Route/screen ownership must follow `foundation_documentation/policies/scope_subscope_governance.md`.
- Do not create undefined subscopes or ambiguous legacy scope folders; new subscope requires explicit decision + policy update.
- Screen files must not own UI controllers/keys directly (`TextEditingController`, `FocusNode`, `ScrollController`, `AnimationController`, `GlobalKey<FormState>`, etc.); ownership belongs to the feature controller.
- Auxiliary widgets may own UI controllers/keys only when fully isolated. If that local UI controller/key is bridged into feature controller calls, ownership must move to the feature controller.
- Widgets may accept controllers for testability, but default to resolving via GetIt when needed.
- Child widgets should resolve their own controllers via GetIt; screens must not instantiate “pass‑through” child controllers just to forward them.
- Controllers must depend on repositories/services/contracts (or value objects), never on other feature controllers.
- Global DI registration must only host true app-lifecycle dependencies; feature/module controllers must be registered in their owning module.
- Classes extending `ModuleContract` must not call direct `GetIt.I.register*`; use module lifecycle wrappers (`registerLazySingleton/registerFactory/registerRouteResolver`) for teardown-safe scope ownership.
- Global app-lifecycle registrations must not use UI controller naming (`*Controller` / `*ControllerContract`).
- Do not introduce ad-hoc mutable global stores for navigation/UI flow handoff; prefer route model/query params and controller state.
- UI controllers (TextEditingController/ScrollController/AnimationController/GlobalKey<FormState>/etc.) live in feature controllers, not screens/widgets.
- Screens/widgets only accept `_controller` and static view data parameters; any controlling parameter belongs in the controller.
- Navigation is owned by widgets/screens; controllers never navigate. Widget calls controller for decisions, then performs non-async navigation.
- Widgets/screens never construct `StreamValue` or `StreamValueBuilder` sources; they only consume controller-owned `StreamValue`.

## Quick boundary check
- If it touches a repository, router, domain model, or persists across navigation → controller + StreamValue.
- If it is a transient UI-only interaction (single sheet/dialog, no side effects) → local state allowed.

## Presentation DI Matrix (Canonical)

| Context | Allowed | Forbidden |
|---|---|---|
| Screen (`presentation/**/screens/**`) | Resolve same-feature controller via `GetIt`; consume controller-owned state/controllers/keys. | Resolve repository/service/DAO/backend/DTO; resolve cross-feature controller; own UI controllers/keys locally. |
| Auxiliary widget (`presentation/**/widgets/**`) isolated | Local UI controllers/keys only if fully local and not bridged to feature controller API. | Non-controller DI; cross-feature controller DI; side-effectful data ingress bypassing feature controller. |
| Auxiliary widget interacting with feature controller | Consume UI controllers/keys owned by feature controller; trigger controller intents only. | Keep local UI controller/key and pass/bridge it into feature controller methods. |
| Module class (`ModuleContract`) | `registerLazySingleton`, `registerFactory`, `registerRouteResolver`. | Direct `GetIt.I.register*` or `GetIt.instance.register*`. |
| Global bootstrap (`main.dart`, `ModuleSettings`, app bootstrap repository) | App-lifecycle non-UI services/contracts/gates/coordinators. | Any global type named `*Controller` / `*ControllerContract`. |

## State Management Baseline (must enforce)
- Official state pattern: `StreamValue` + `StreamValueBuilder` (controller-owned streams only).
- Allowed local exception: constrained `setState` for ephemeral widget concerns only.
- State manager choices are never an ownership bypass. Any mutable holder used for canonical shared state must follow repository ownership.
- Any residual/legacy manager is a deviation that must be removed or justified with explicit architecture decision.
- Residual scan targets:
  - `ChangeNotifier` / `ValueNotifier`
  - `Provider` / `Riverpod`
  - `Bloc` / `Cubit`
  - `MobX` (`Observable`, `Observer`)
  - `GetX` (`Rx`, `Obx`, `GetBuilder`)
  - Ad-hoc `StreamController` owned by widgets/screens.

## Concrete examples (preferred pattern)

### Route (ModuleScope only, no controller passing)
```dart
@RoutePage(name: 'CityMapRoute')
class CityMapRoutePage extends StatelessWidget {
  const CityMapRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleScope<MapModule>(
      child: const MapScreen(),
    );
  }
}
```

### Screen (resolve controller via GetIt; init in initState only if needed)
```dart
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _controller = GetIt.I.get<MapScreenController>();

  @override
  void initState() {
    super.initState();
    _controller.loadIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamValueBuilder<MapState>(
        streamValue: _controller.stateStreamValue,
        builder: (_, state) => MapBody(state: state),
      ),
    );
  }
}
```

### Widget (controller optional for tests; default to GetIt)
```dart
class InviteCard extends StatelessWidget {
  const InviteCard({super.key, this.controller});

  final InviteFlowScreenController? controller;

  InviteFlowScreenController get _controller =>
      controller ?? GetIt.I.get<InviteFlowScreenController>();

  @override
  Widget build(BuildContext context) {
    return StreamValueBuilder<List<InviteModel>>(
      streamValue: _controller.invitesStreamValue,
      builder: (_, invites) => InviteList(invites: invites),
    );
  }
}
```

### Auxiliary widget (isolated local state allowed)
```dart
class GalleryScroller extends StatefulWidget {
  const GalleryScroller({super.key});

  @override
  State<GalleryScroller> createState() => _GalleryScrollerState();
}

class _GalleryScrollerState extends State<GalleryScroller> {
  final _scrollController = ScrollController(); // local-only, no controller bridge

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(controller: _scrollController);
  }
}
```

### Auxiliary widget (when interacting with feature controller, ownership moves)
```dart
class SearchHeader extends StatelessWidget {
  const SearchHeader({super.key});

  SearchScreenController get _controller => GetIt.I.get<SearchScreenController>();

  @override
  Widget build(BuildContext context) {
    return TextField(controller: _controller.searchTextController);
  }
}
```

### UI controllers (owned by feature controller; screen only consumes)
```dart
class TenantAdminAccountCreateController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final documentController = TextEditingController();

  void dispose() {
    nameController.dispose();
    documentController.dispose();
  }
}

class TenantAdminAccountCreateScreen extends StatefulWidget {
  const TenantAdminAccountCreateScreen({super.key});

  @override
  State<TenantAdminAccountCreateScreen> createState() =>
      _TenantAdminAccountCreateScreenState();
}

class _TenantAdminAccountCreateScreenState
    extends State<TenantAdminAccountCreateScreen> {
  final _controller = GetIt.I.get<TenantAdminAccountCreateController>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _controller.formKey,
      child: TextField(controller: _controller.nameController),
    );
  }
}
```

### Anti-patterns (do not copy)
```dart
class BadFormScreenState extends State<BadFormScreen> {
  final formKey = GlobalKey<FormState>(); // ❌ form key in widget
  final localStream = StreamValue<int>(); // ❌ StreamValue owned by widget

  @override
  Widget build(BuildContext context) {
    return StreamValueBuilder<int>(streamValue: localStream, builder: ...);
  }
}
```

## Adherence flags (scan + fix)

### Hard NO (blockers)
- Repository/domain/DAO access inside screens/widgets.
- Any screen/widget data ingress that bypasses controllers (repository/service/state-holder/helper directly in presentation non-controller files).
- Any state manager other than StreamValue (Provider/Bloc/GetX/ChangeNotifier/ValueNotifier/etc.).
- Multiple widgets or multiple screens in the same file.
- Business logic in screens (filters, mapping, validation, formatting).
- Direct GetIt resolution of non-controller types in `screens/widgets`.
- Direct GetIt resolution of cross-feature controllers in `screens/widgets`.
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
- Service/domain-service owning canonical shared state holders (`StreamValue`, `StreamController`, `ValueNotifier`, `ChangeNotifier`, custom `*State`/`*Store`/`*Manager`) instead of repositories.

### Soft NO (allowed only if truly ephemeral)
- `setState` in presentation (allowed only for tiny, local, UI-only, single-route lifespan).
- Local mutable fields in State classes (same rule as `setState`).
  - Two acceptable paths:
    - Create a small **ephemeral wrapper widget** that owns the mutable fields and keeps them UI-only.
    - Move the fields into the **controller** when they represent cross-widget/stateful behavior or outlive the widget.

### Conditional (flag + explicit decision required)
- Disposing controllers in widgets (flag unless explicitly approved).
- UI decides what to fetch (should be controller-driven, backend-driven UI).
- DTOs used directly in UI (must be Projection/Domain model).
- Widget file under `presentation/**/screens/**` without a corresponding controller.
- Screen changes without updating `foundation_documentation` contracts.
- Widget performs async navigation directly after an await (should be: await controller → sync navigate).

### Workflow compliance (must enforce)
- Screen edits without running Screen Workflow.
- Domain edits without running Domain Workflow.
- Repository edits without running Repository Workflow.

## Fast Audit Commands (recommended)
- `rg -n "\\bsetState\\b" flutter-app/lib/presentation`
- `rg -n "ChangeNotifier|ValueNotifier|Provider|Riverpod|Bloc|Cubit|MobX|Observable|Observer|GetBuilder|Obx|\\bRx\\b" flutter-app/lib`
- `rg -n "StreamController<" flutter-app/lib/presentation`
- `rg -n "FutureBuilder|StreamBuilder" flutter-app/lib/presentation`
- `rg -n "class .*Controller|Controller\\(" flutter-app/lib/presentation/**/controllers`
- `rg -n "GetIt\\.I\\.get<.*Controller>|final .*Controller|.*Controller\\?" flutter-app/lib/presentation/**/controllers`
- `rg -n "GetIt\\.I\\.get<.*Repository|GetIt\\.I\\.get<.*Service|RepositoryContract|ServiceContract" flutter-app/lib/presentation --glob '!**/controllers/**'`
- `rg -n "StreamValue\\(|StreamController<|ValueNotifier<|ChangeNotifier|class .*State|class .*Store|class .*Manager" flutter-app/lib/infrastructure/services flutter-app/lib/domain/services`
- `rg -n "required _i|required .*State|required String .*Name" flutter-app/lib/application/router/app_router.gr.dart`

## Data/Domain boundaries adherence flags

### Hard NO (blockers)
- DTOs used directly in UI, controllers, or domain (DTOs belong to infrastructure only).
- Domain entities/value objects depending on DTOs or infrastructure types.
- Repositories exposing DTOs (must return domain/projection models only).
- DAOs used outside infrastructure/repository layer.
- Mapping logic inside UI/controllers (must live in repositories/infrastructure).

### Soft NO
- Projections skipping domain/value objects when domain exists (prefer Domain → Projection).
- Domain constructors accepting raw `Map<String, dynamic>` without validation.

### Conditional (flag + review)
- Domain models leaking backend-specific fields/names.
- Repositories mixing persistence concerns with domain rules.
- Multiple mapping steps inside screens/widgets (should be centralized).

## Navigation & routes adherence flags

### Hard NO (blockers)
- Controllers triggering navigation directly (controllers never navigate).
- Direct `Navigator.push`/`pop` in screens (bypass router/route model).
- Route arguments passing raw DTOs instead of domain/projection models.
- Routes defined without ModuleScope/RouteModelResolver when required by feature.
- Any route with required non-URL constructor args in `app_router.gr.dart` that is not explicitly classified as either:
  - `URL-Hydratable` (path/query + resolver contract), or
  - `Internal-Only` (documented guard/fallback when opened without args).

### Soft NO
- Deep-link or route parsing inside UI (should live in resolver/route layer).
- Conditional navigation based on auth/tenant inside UI (should be guard-driven).

### Conditional (flag + doc/guard review)
- Routes that skip documented guards or use ad-hoc guard logic.
- Route names/paths changed without updating foundation docs.
