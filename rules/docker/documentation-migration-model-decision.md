---
trigger: model_decision
description: "When migrating temporary/legacy docs into Delphi templates and producing milestones/task lists."
---


## Rule
If working from temporary notes (e.g., `temporary_files/*`, scratch specs, prototype screens) to produce canonical docs:
- Run the Documentation Migration & Expansion Workflow (`delphi-ai/workflows/docker/documentation-migration-method.md`).
- Load and apply `foundation_documentation/policies/scope_subscope_governance.md` for any route/module/screen ownership statements.
- Avoid editing temporary/source files; instead, populate template-based docs (modules, roadmap, profile, mandate, etc.).
- Include gap analysis, progressive milestones, and team task lists in the outputs.
- Document real-time payloads and event→jobs→broadcast flows when applicable.
- For route/navigation tests tied to web bundle behavior, treat `web-app` as derived/compiled and keep canonical sources outside direct `web-app` authoring.

## Rationale
Ensures ad-hoc information is standardized, gaps are closed, and teams get actionable milestones and tasks without touching temporary artifacts.

## Enforcement
- Trigger this rule before converting temporary content.
- Block merges lacking template-based docs, milestones, and team handoff deliverables.

## Notes
When migration changes project-level rules, cross-module invariants, or stack-specific exceptions, update `project_constitution.md`. Use `system_roadmap.md` only for strategic stages or follow-up, not as an endpoint status ledger.
