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
- Do not use directory-target analyze as the architecture gate when the project declares full-app analyze as canonical.
- Validate plugin rule activation with:
  - `bash ${PACED_GLOBAL_ANALYZER_PLUGIN_DIR:-tool/belluga_analysis_plugin}/bin/validate_rule_matrix.sh`
- First-party product packages that share a release must use a Pub Workspace. Its root `pub get` is the single dependency resolution and its full-workspace static-analysis gate must include every workspace member. Do not solve memory pressure by excluding product packages, opening-files-only analysis, per-directory gates, or disabling custom rules.
- The agent must never start `dart analyze`, `flutter analyze`, `custom_lint`, or another second analyzer process in an editor-managed Flutter workspace. The live Dart Analysis Server owns local static analysis; concurrent CLI analysis is invalid evidence because it competes for the same host resources.
- Obtain agent-readable static-analysis evidence from the project-declared read-only VS Code Problems bridge. Query its health endpoint, then query one complete Flutter-workspace scope rather than an edited-file or directory subset. Capture the payload, bridge revision, workspace folders, timestamp, scope, and payload hash in the governing TODO.
- A clean snapshot has no `Error` or `Warning` diagnostic. Every `Information` diagnostic must be either outside the changed scope and linked to an existing owner, or classified in the governing TODO; a clean snapshot must never silently discard informational debt.
- Require a stable snapshot: the bridge must be live, the reported workspace must contain the intended workspace root, and its diagnostic revision must remain unchanged across a project-declared quiet interval before interpreting the second scoped payload. If it changes, wait and capture again. If the bridge is unavailable, stale, has the wrong workspace, or never stabilizes, static-analysis evidence is `blocked`; do not fall back to a CLI analyzer.
- The public VS Code API does not expose Dart Analysis Server completion. Record this as a `live Problems snapshot`, never as a completed CLI analyzer or a guarantee that the server scanned every file after an unknown workspace event. Append-only LSP/analyzer logs remain forensic only and cannot replace the bridge snapshot.
- A project CI pipeline may still execute its own analyzer job. That remote/pipeline job is separate evidence; the agent must not reproduce it locally while the editor Analysis Server is active.
- If the editor needs recovery after workspace topology changes, invoke the supported VS Code command `Dart: Restart Analysis Server`; do not kill the language-server process. Use `Dart: Open Analyzer Diagnostics / Insights` and `dart info record-performance` for persistent performance diagnosis.
- Expected-invalid analyzer fixtures may stay outside the product workspace only when they have a mandatory dedicated rule-matrix gate. They must never be used to exclude product code or weaken the root full analyzer gate.
- If analyzer state needs recovery, the project-owned reset script must restore the shared workspace once and any explicitly isolated negative fixture separately. Do not bypass findings with per-file ignores or allowlists.
- If a rule is wrong, calibrate the global plugin or project-local plugin as appropriate; do not suppress the finding.

## Sequential Or Orchestration Checkpoint Contract
- Before any next TODO or orchestration wave starts after a Flutter-changing unit, re-load the matching architecture rules/workflows and perform a Rule-Spirit review of the changed shape.
- Complete the stable full-workspace live Problems snapshot and matching architecture/rule review for every such checkpoint. This is a static architecture/rule gate, not `stage-full`, `CI Equivalent`, or promotion evidence.
- Run only the tests and builds materially affected by that unit at the checkpoint. Run the plugin rule matrix when the analyzer plugin, its configuration, or its fixture contract changed.
- Resolve every analyzer error and warning that belongs to the current codebase before advancing. Never carry a known architecture/rule finding to a later checkpoint merely because the final broad gate remains pending.
- Reserve the parity-complete broad test/runtime gate for integrated package closeout under `ci-equivalent-governance`.

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
- Did the stable full-workspace Problems snapshot and plugin rule matrix evidence run on the project-declared Flutter surface?
- At a sequential/orchestration checkpoint, did the stable full-workspace Problems snapshot, Rule-Spirit review, and affected-area test bundle all pass before the next unit was opened?
- Did the Rule-Spirit Anti-Pattern Hunt include Flutter bypass shapes such as direct DI, DTO leakage, state-manager substitution, weakened tests, or manual navigation?

## Blockers
- Per-file lint ignores, analyzer allowlists, or wrapper scripts that hide architecture findings.
- Direct presentation access to data/services/repositories/DTOs.
- Controller navigation or `BuildContext` ownership that violates the active rules.
- New project-specific Flutter exceptions stored in Delphi core instead of downstream `foundation_documentation` or a project-local analyzer plugin.
