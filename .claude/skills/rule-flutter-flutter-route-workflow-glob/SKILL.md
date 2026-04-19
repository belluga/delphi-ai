---
name: rule-flutter-flutter-route-workflow-glob
description: "Rule: MUST use whenever the scope matches this purpose: Apply the route workflow whenever Flutter routing files are edited."
---

## Rule
Edits under `flutter-app/lib/**/routes/**` must follow the Route Workflow:
- Load and reference `foundation_documentation/policies/scope_subscope_governance.md` before defining ownership.
- Register new routes in AutoRoute with guards and ModuleScope wiring.
- Validate and document target ownership for each route (`EnvironmentType`, main scope, subscope when applicable).
- Use RouteModelResolver for hydration; update documentation (`screens/tenant_app.md`, route sections) accordingly.
- Run a generated-router contract audit (`app_router.gr.dart`) for required non-URL args and classify each as `URL-Hydratable` or `Internal-Only` with explicit fallback behavior.
- Classify route entry mode (`Cold Entry` vs `Warm Entry`) and ensure predecessor-preserving warm flows commit real router history before any interruption/boundary logic resolves.
- Classify boundary/interruption routes explicitly and define `success`, `cancel/dismiss`, and `no-history` outcomes. Visible back and system/device back must converge semantically.
- If the route change is large or architectural, require unit + widget + integration evidence for the affected critical paths. Route guards, shell composition, route-contract/resolver ownership, cold-entry resolution, warm-history ownership, boundary/back semantics, and login/protected-route handoff are examples of this trigger.
- If that architectural route change is compatibility-critical or backend-coupled, require real-backend web + mobile integration evidence for the affected flow.
- Do not use synthetic browser-history seeding or manual ancestry fabrication as a substitute for proper route/history design.
- Do not create or imply undefined subscopes/folders; explicit decision + policy update is required first.
- Regenerate routes via build_runner and ensure analyzer passes.

## Rationale
Routing governs navigation and domain hydration. The workflow preserves RouteModelResolver discipline and documentation parity.

## Enforcement
- Run the Route Workflow steps before merging changes to these files.
- PRs should reference the updated docs and analyzer output.
- PRs must include the route contract audit result (or explicit statement that no new required non-URL args were introduced).
- PRs should record the route entry-mode classification and boundary-route contract whenever affected.
- PRs/TODOs must record the required unit + widget + integration evidence for architectural route changes, plus required real-backend web + mobile evidence when the affected flow is compatibility-critical or backend-coupled, or an explicit human waiver/blocker reference.

## Notes
Workflow reference: `delphi-ai/workflows/flutter/create-route-method.md`. If a route starts elsewhere (e.g., doc-first updates), the glob serves as a safety net for code edits.
