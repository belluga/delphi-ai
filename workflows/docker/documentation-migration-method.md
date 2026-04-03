---
description: "Migrate ad-hoc/temporary docs into Delphi templates with gap analysis, milestones, and team handoff."
---

# Workflow: Documentation Migration & Expansion

## Purpose
Turn temporary or legacy documentation (e.g., scratch specs, prototype UI notes) into the canonical Delphi documentation set using templates, close gaps, and produce progressive milestones plus team task lists.

## Preconditions
- Run `bash delphi-ai/verify_context.sh`.
- If it fails only on Delphi-managed links/artifacts, run `bash delphi-ai/verify_context.sh --repair`, then rerun plain verification.
- Load main instructions and always_on rules.
- Load `foundation_documentation/policies/scope_subscope_governance.md` for route/module/screen ownership.
- Identify source docs (e.g., `foundation_documentation/temporary_files/*`, uploaded specs) and target templates (module, roadmap, screen, etc.).
- Confirm submodule scope (Flutter/Laravel/web) if task lists are needed.

## Steps
1. Load core context (system principles, mandate) and relevant module templates; avoid editing temporary files directly.
2. Inventory source materials (temporary files, PRDs, prototype screens, other repositories used as references) and note authoritative vs. outdated content.
   - When another repository is used as reference, explicitly separate:
     - what is being borrowed as architecture/topology/pattern guidance;
     - what is project-specific and must not be inherited automatically.
   - If names, business entities, or feature behavior might carry over, confirm that with the user before canonicalizing it.
3. Map scope: determine required project-level rules, modules, entities, endpoints, screens, and real-time needs; note landlord vs tenant boundaries and explicit main scope/subscope ownership.
4. Perform gap analysis: validation bounds, enums, auth/abilities, real-time transport, rankings/badges, profile, catalog rules, and roadmaps.
5. Create/update canonical docs using templates:
   - `project_mandate`, `domain_entities`, `project_constitution`, module docs, `system_roadmap` (when strategic), profile docs (when operating-mode guidance changes), and landing/UX notes.
   - Define endpoints, schemas, enums, indexes, rate limits, payload samples, and SSE/WebSocket payload shapes if applicable.
   - Include route/scope (and subscope when applicable) matrices for multi-scope modules/screens.
6. Add strategic stages, cross-team follow-up, or milestone framing only where they matter; do not use the roadmap as an endpoint status ledger.
7. Produce team task lists (Flutter, Laravel, etc.) with clear scopes and validation expectations.
8. If badges/rankings/real-time are introduced, document event → jobs → broadcast flow and polling fallbacks.
9. Surface landing/unauth content in docs (not in temp code) for client teams to implement.
10. Treat `web-app` as derived/compiled for governance purposes:
   - author route/navigation test sources in source-owned locations,
   - synchronize to `web-app` via build tooling,
   - do not use direct `web-app` test authoring as canonical source.

## Outputs
- Updated canonical docs reflecting migrated content and resolved gaps.
- Progressive milestones and team task lists.
- Real-time payload definitions (if applicable) and strategic roadmap follow-up when relevant.

## Validation
- Ensure all modified docs exist in `foundation_documentation/` (or template directory) and follow template structure.
- Verify project-level rules land in `project_constitution.md` when appropriate, and confirm indexes/rate limits/enums are documented.
- Confirm no edits were made to temporary files; deliver landing content in docs only.
