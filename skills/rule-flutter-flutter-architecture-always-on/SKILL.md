---
name: rule-flutter-flutter-architecture-always-on
description: "Rule: MUST use whenever the scope matches this purpose: Enforce Flutter architectural tenets across all tasks."
---

## Rule
Apply these Flutter architectural tenets on every task:
- Keep widgets pure UI; controllers own all state (`StreamValue`), UI controllers, side effects, and orchestration; widgets never touch repositories/infrastructure.
- Controllers are the only allowed data ingress gate for screens/widgets; no repository/service/state-holder bypasses are allowed in presentation non-controller files.
- Apply DI/ownership boundaries from the canonical contract in `foundation_documentation/modules/flutter_client_experience_module.md` (section `2.1.1`) and enforce rule IDs/treatments from `flutter-app/tool/belluga_analysis_plugin/docs/rules.md`.
- `StreamValue` in controllers is allowed for local screen/stage state and for pure delegation of repository-owned canonical streams.
- Canonical shared state (cross-controller/module lifespan, cache-backed, persistence-aligned) must be owned by repository contracts/implementations.
- Services/DAL are technical adapters only; they must not own canonical shared state via `StreamValue`, `StreamController`, `ValueNotifier`, `ChangeNotifier`, or custom `*State/*Store/*Manager` holders.
- Maintain feature-first structure (`tenant/<feature>/screens/...`) with controllers registered via ModuleScope/GetIt; controllers never accept `BuildContext`.
- Enforce DTO → Domain → Projection flow; DTOs never reach widgets, and projections expose UI-ready primitives only.
- Enforce repository transport boundary: DAO/decoder layers own raw map payload parsing/building, while repositories consume typed outputs and must not own `Map<String, Object?>` transport extraction/assembly.
- Register routes via AutoRoute with guards (tenant shell/auth); use RouteModelResolver for hydration and keep route docs updated.
- Enforce canonical scope/subscope ownership from `foundation_documentation/policies/scope_subscope_governance.md` for any route/screen placement.
- Never create implicit/undefined subscopes; new subscope introduction requires explicit decision and policy update first.
- Align repos/contracts with documented pagination/filtering expectations and mirror them in Laravel roadmaps.
- Analyzer/tests are mandatory: `fvm flutter analyze` must be clean; add targeted controller/widget tests when behaviour changes.
- When an active debt TODO requires branch-delta enforcement for disabled lint rules, run the documented branch guard command(s) before delivery and fail on new/preserved violations in branch-touched files.

## Rationale
These tenets keep the Flutter client aligned with backend contracts, maintain purity of presentation, and prevent coupling DTOs to UI. AutoRoute governance and analyzer discipline guard navigation integrity and code quality.

## Enforcement
- Structure checks during PR/code review; ensure routes/controllers follow ModuleScope and AutoRoute rules.
- Analyzer: `fvm flutter analyze` must be clean.
- Tests: add/maintain unit/widget tests where impacted flows change.

## Notes
Reference `foundation_documentation/system_architecture_principles.md` Appendix A for full context. Update module/route docs when adding screens or routes.
