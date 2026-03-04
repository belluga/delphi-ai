---
name: rule-docker-flutter-architecture
description: "Rule: MUST use whenever the scope matches this purpose: Apply these Flutter architectural tenets on every task:."
---

## Rule
Apply these Flutter architectural tenets on every task:
- Keep widgets pure UI; controllers own all state (`StreamValue`), UI controllers, side effects, and orchestration; widgets never touch repositories/infrastructure.
- Controllers are the only allowed data ingress gate for screens/widgets; no repository/service/state-holder bypasses are allowed in presentation non-controller files.
- Apply DI/ownership boundaries from the canonical contract in `foundation_documentation/modules/flutter_client_experience_module.md` (section `2.1.1`) and enforce rule IDs/treatments from `flutter-app/tool/belluga_custom_lint/docs/rules.md`.
- `StreamValue` in controllers is allowed for local screen/stage state and for pure delegation of repository-owned canonical streams.
- Canonical shared state (cross-controller/module lifespan, cache-backed, persistence-aligned) must be owned by repository contracts/implementations.
- Services/DAL are technical adapters only; they must not own canonical shared state via `StreamValue`, `StreamController`, `ValueNotifier`, `ChangeNotifier`, or custom `*State/*Store/*Manager` holders.
- Maintain feature-first structure (`tenant/<feature>/screens/...`) with controllers registered via ModuleScope/GetIt; controllers never accept `BuildContext`.
- Enforce DTO → Domain → Projection flow; DTOs never reach widgets, and projections expose UI-ready primitives only.
- Register routes via AutoRoute with guards (tenant shell/auth); use RouteModelResolver for hydration and keep route docs updated.
- Align repos/contracts with documented pagination/filtering expectations and mirror them in Laravel roadmaps.
- Analyzer/tests are mandatory: `fvm flutter analyze` must be clean; add targeted controller/widget tests when behaviour changes.
- For device integration tests, run with `--dds-port=0` to avoid DDS port conflicts.

## Rationale
These tenets keep the Flutter client aligned with backend contracts, maintain purity of presentation, and prevent coupling DTOs to UI. AutoRoute governance and analyzer discipline guard navigation integrity and code quality.

## Enforcement
- Structure checks during PR/code review; ensure routes/controllers follow ModuleScope and AutoRoute rules.
- Analyzer: `fvm flutter analyze` must be clean.
- Tests: add/maintain unit/widget tests where impacted flows change.

## Notes
Reference `foundation_documentation/system_architecture_principles.md` Appendix A for full context. Update module/route docs when adding screens or routes.
