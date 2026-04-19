---
description: "Enforce Flutter architectural tenets across all tasks — widget/controller boundaries, state management, DI, routing, and transport contracts"
globs: ["flutter-app/**"]
alwaysApply: false
---

# Flutter Architecture Rules

## Core Enforcement

### Widget/Controller Boundaries

- Screens are pure UI; state/logic lives in controllers.
- Repositories and domain layers must stay aligned with documented contracts.
- Widget state is only allowed for true ephemeral UI. Anything ModuleScope-adjacent must be controller-driven.
- UI must not own `StreamValue` instances directly; StreamValue belongs in controllers only.
- Form keys (`GlobalKey<FormState>`) must live in controllers; screens/widgets only reference `_controller.formKey`.
- Screens resolve controllers via GetIt; routes should not pass controllers.
- Child widgets should resolve their own controllers via GetIt; screens must not instantiate "pass-through" child controllers.
- Controllers must depend on repositories/services/contracts, never on other feature controllers.
- Global DI registration must only host true app-lifecycle dependencies; feature/module controllers must be registered in their owning module.
- UI controllers (TextEditingController/ScrollController/AnimationController/GlobalKey<FormState>/etc.) live in feature controllers, not screens/widgets.
- Navigation is owned by widgets/screens; controllers never navigate.

### State Management Baseline

- Official state pattern: `StreamValue` + `StreamValueBuilder` (controller-owned streams only).
- Allowed local exception: constrained `setState` for ephemeral widget concerns only.
- `StreamValue` in controllers is allowed for local screen/stage state and for pure delegation of repository-owned canonical streams.
- Canonical shared state (cross-controller/module lifespan, cache-backed, persistence-aligned) must be owned by repository contracts/implementations.
- Services/DAL are technical adapters only; they must not own canonical shared state.

### Data/Domain Boundaries

- DTOs used directly in UI, controllers, or domain (DTOs belong to infrastructure only).
- Enforce DTO → Domain → Projection flow; DTOs never reach widgets.
- Repositories exposing DTOs (must return domain/projection models only).
- Enforce repository transport boundary: DAO/decoder layers own raw map payload parsing/building.
- Mapping logic inside UI/controllers (must live in repositories/infrastructure).

### Navigation & Routes

- AutoRoute is the canonical navigation authority; do not bypass it.
- Register routes via AutoRoute with guards (tenant shell/auth); use RouteModelResolver for hydration.
- Distinguish cold entry (URL, deeplink, startup builder) from warm in-app navigation.
- Boundary/interruption routes must declare explicit success, cancel/dismiss, and no-history outcomes.
- Enforce canonical scope/subscope ownership from `foundation_documentation/policies/scope_subscope_governance.md`.
- Never create implicit/undefined subscopes; new subscope introduction requires explicit decision and policy update first.

## Hard NO (Blockers)

These patterns must be blocked on sight:

- Repository/domain/DAO access inside screens/widgets.
- Any state manager other than StreamValue (Provider/Bloc/GetX/ChangeNotifier/ValueNotifier/etc.).
- Multiple widgets or multiple screens in the same file.
- Business logic in screens (filters, mapping, validation, formatting).
- Direct GetIt access in widgets (controllers only).
- Network calls or side effects inside UI.
- StreamValue instances created/owned inside widgets/screens.
- `stream.listen` subscriptions inside widgets/screens.
- Controller depending on another feature controller.
- Mutable singleton store used as cross-layer navigation handoff.

## Soft NO (Conditional)

Allowed only if truly ephemeral:

- `setState` in presentation (allowed only for tiny, local, UI-only, single-route lifespan).
- Local mutable fields in State classes (same rule as `setState`).

## Analyzer & Test Requirements

- Analyzer: `fvm flutter analyze` must be clean.
- Tests: add/maintain unit/widget tests where impacted flows change.
- Any large or architectural Flutter change must carry a multi-lane test matrix.
- Reference `foundation_documentation/system_architecture_principles.md` Appendix A for full context.
