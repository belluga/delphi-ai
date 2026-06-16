---
name: flutter-architecture-adherence
description: "Architecture guardrail for Flutter. MUST use whenever touching Flutter presentation, controllers, repositories, routes, domain models, or widget state. Enforces adherence rules, selects the correct sub-skills, and blocks improper setState usage."
---

# Flutter Architecture Adherence

Use this umbrella skill for any Flutter change that can affect presentation, controllers, repositories, routes, domain models, module wiring, or widget state.

## Required Sub-Skills
Invoke the specific skill that matches the touched surface:
- `rule-flutter-flutter-screen-workflow-glob` for `lib/presentation/**/screens/**`
- `rule-flutter-flutter-controller-workflow-glob` for `lib/presentation/**/controllers/**`
- `rule-flutter-flutter-repository-workflow-glob` for `lib/infrastructure/repositories/**`
- `rule-flutter-flutter-domain-workflow-glob` for `lib/domain/**`
- `rule-flutter-flutter-route-workflow-glob` for route/router work
- `flutter-widget-local-state-heuristics` for `setState`, `StatefulWidget`, or local mutable widget fields

## Canonical Sources
- Project Flutter module docs and scope/subscope policy under `foundation_documentation`.
- Global analyzer plugin docs, normally `tool/belluga_analysis_plugin/docs/rules.md`, or the path in `PACED_GLOBAL_ANALYZER_PLUGIN_DIR`.
- Active TODO decisions and validation matrices.
- Stack rules and workflows under `delphi-ai/rules/stacks/flutter/` and `delphi-ai/workflows/flutter/`.

If these sources differ, prefer project-owned module/scope contracts for project topology and the global analyzer plugin for reusable lint semantics. Do not encode project-specific Flutter topology in this global skill.

## Analyzer Contract
- Run the official architecture gate from the Flutter app root:
  - `fvm dart analyze --format machine`
- Do not use directory-target analyze as the architecture gate when the project declares full-app analyze as canonical.
- Validate plugin rule activation with:
  - `bash ${PACED_GLOBAL_ANALYZER_PLUGIN_DIR:-tool/belluga_analysis_plugin}/bin/validate_rule_matrix.sh`
- If analyzer state is stale or false-clean, use the project-owned reset script before rerunning. Do not bypass findings with per-file ignores or allowlists.
- If a rule is wrong, calibrate the global plugin or project-local plugin as appropriate; do not suppress the finding.

## Architecture Invariants
- Screens and widgets are UI surfaces. State, effects, and data ingress belong in controllers.
- Controllers are the only allowed data ingress gate for screens/widgets.
- Presentation code must not resolve repositories, services, DAOs, backend clients, or DTOs directly.
- Same-feature controller resolution is allowed only where the project/module contract permits it; cross-feature controller resolution is forbidden.
- Controllers depend on repositories/services/contracts or value objects, not on other feature controllers.
- Repositories consume typed DAO/DTO outputs and return domain/projection values. Raw payload parsing belongs in DAO/decoder layers.
- Module-scoped registrations must use lifecycle-safe module wrappers, not direct global `GetIt.I.register*`.
- Global bootstrap may register true app-lifecycle services, not feature UI controllers.
- Route/screen ownership must follow the project scope/subscope policy. New subscopes require explicit decision and policy update.

## State And Navigation
- Official shared state pattern is controller-owned `StreamValue` consumed by UI builders.
- Widget-local state is allowed only for isolated ephemeral UI with no repository/service calls, persistence, navigation handoff, or feature-controller ownership.
- UI controllers and keys (`TextEditingController`, `FocusNode`, `ScrollController`, `AnimationController`, `GlobalKey<FormState>`) belong in feature controllers when they drive feature behavior.
- AutoRoute/project router is the navigation authority. Avoid ad hoc `Navigator` usage, synthetic browser-history seeding, or controller-owned navigation.
- Controllers may decide; widgets/screens perform non-async navigation from those decisions.

## Review Checklist
- Did every touched file load the matching sub-skill/rule/workflow?
- Does presentation stay DTO/service/repository-free?
- Does domain stay independent from transport DTOs?
- Are route parameters, scopes, and ownership aligned with `foundation_documentation`?
- Does widget state remain ephemeral, or has ownership moved to the controller?
- Did analyzer and plugin rule matrix evidence run on the project-declared Flutter surface?
- Did the Rule-Spirit Anti-Pattern Hunt include Flutter bypass shapes such as direct DI, DTO leakage, state-manager substitution, weakened tests, or manual navigation?

## Blockers
- Per-file lint ignores, analyzer allowlists, or wrapper scripts that hide architecture findings.
- Direct presentation access to data/services/repositories/DTOs.
- Controller navigation or `BuildContext` ownership that violates the active rules.
- New project-specific Flutter exceptions stored in Delphi core instead of downstream `foundation_documentation` or a project-local analyzer plugin.
