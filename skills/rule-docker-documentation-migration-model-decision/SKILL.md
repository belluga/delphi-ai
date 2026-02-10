---
name: rule-docker-documentation-migration-model-decision
description: "Rule: MUST use whenever the scope matches this purpose: If working from temporary notes (e.g., `temporary_files/*`, scratch specs, prototype screens) to produce canonical docs:."
---

## Rule
If working from temporary notes (e.g., `temporary_files/*`, scratch specs, prototype screens) to produce canonical docs:
- Run the Documentation Migration & Expansion Workflow (`delphi-ai/workflows/docker/documentation-migration-method.md`).
- Avoid editing temporary/source files; instead, populate template-based docs (modules, roadmap, persona, mandate, etc.).
- Include gap analysis, progressive milestones, and team task lists in the outputs.
- Document real-time payloads and event→jobs→broadcast flows when applicable.

## Rationale
Ensures ad-hoc information is standardized, gaps are closed, and teams get actionable milestones and tasks without touching temporary artifacts.

## Enforcement
- Trigger this rule before converting temporary content.
- Block merges lacking template-based docs, milestones, and team handoff deliverables.

## Notes
Update roadmap endpoint statuses as part of the migration (Defined/Mocked/Implemented/Tested & Ready).
