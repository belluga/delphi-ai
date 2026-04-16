---
trigger: always_on
description: Enforce Flutter architectural tenets across all tasks.
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
- Register routes via AutoRoute with guards (tenant shell/auth); use RouteModelResolver for hydration and keep route docs updated.
- AutoRoute is the canonical navigation authority; do not bypass it with ad-hoc `Navigator` usage, synthetic browser-history seeding, manual ancestry fabrication, or mutable singleton handoff stores whose only responsibility is route outcome transfer.
- Distinguish cold entry (`URL`, deeplink, startup builder) from warm in-app navigation. Warm flows that must preserve predecessor history must commit a real router entry before any interruption/boundary logic resolves.
- Boundary/interruption routes (permission gates, promotion/auth handoffs, confirmation boundaries) must declare explicit success, cancel/dismiss, and no-history outcomes. Visible back and system/device back must converge semantically for the same boundary route.
- Result-return boundary routes are valid architectural shapes when a flow interrupts another route; model them explicitly in router contracts instead of letting dismissal behavior emerge from ad-hoc `replace/pop` combinations.
- Align repos/contracts with documented pagination/filtering expectations and mirror them in Laravel roadmaps.
- Any large or architectural Flutter change must carry a multi-lane test matrix for the affected critical paths: unit + widget + integration. Routing/navigation/shell/guard changes are examples, not the only trigger.
- Compatibility-critical or backend-coupled architectural changes must additionally prove real-backend integration on the required platform matrix; analyzer or widget-only confidence is insufficient.
- Analyzer/tests are mandatory: `fvm flutter analyze` must be clean; add targeted unit/widget tests when behaviour changes and do not treat them as a substitute for required integration evidence on architectural scope.
- For device integration tests, run with `--dds-port=0` to avoid DDS port conflicts.

## Rationale
These tenets keep the Flutter client aligned with backend contracts, maintain purity of presentation, and prevent coupling DTOs to UI. AutoRoute governance and analyzer discipline guard navigation integrity and code quality.

## Enforcement
- Structure checks during PR/code review; ensure routes/controllers follow ModuleScope and AutoRoute rules.
- Analyzer: `fvm flutter analyze` must be clean.
- Tests: add/maintain unit/widget tests where impacted flows change, and require integration evidence for any large/architectural change before delivery closure.

## Notes
Reference `foundation_documentation/system_architecture_principles.md` Appendix A for full context. Update module/route docs when adding screens or routes.
