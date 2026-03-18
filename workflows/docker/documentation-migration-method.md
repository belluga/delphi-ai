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
- Identify source docs (e.g., `foundation_documentation/temporary_files/*`, uploaded specs) and target templates (module, roadmap, persona, etc.).
- Confirm submodule scope (Flutter/Laravel/web) if task lists are needed.

## Steps
1. Load core context (system principles, mandate) and relevant module templates; avoid editing temporary files directly.
2. Inventory source materials (temporary files, PRDs, prototype screens) and note authoritative vs. outdated content.
3. Map scope: determine required modules, entities, endpoints, screens, and real-time needs; note landlord vs tenant boundaries and explicit main scope/subscope ownership.
4. Perform gap analysis: validation bounds, enums, auth/abilities, real-time transport, rankings/badges, profile, catalog rules, and roadmaps.
5. Create/update canonical docs using templates:
   - `project_mandate`, `domain_entities`, module docs, persona roadmaps, system_roadmap, and landing/UX notes.
   - Define endpoints, schemas, enums, indexes, rate limits, payload samples, and SSE/WebSocket payload shapes if applicable.
   - Include route/scope (and subscope when applicable) matrices for multi-scope modules/screens.
6. Add progressive implementation milestones with testable outcomes; keep endpoints labeled (Defined/Mocked/Implemented/Tested & Ready).
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
- Real-time payload definitions (if applicable) and roadmap status updates.

## Validation
- Ensure all modified docs exist in `foundation_documentation/` (or template directory) and follow template structure.
- Verify endpoints are listed with statuses; indexes/rate limits/enums documented.
- Confirm no edits were made to temporary files; deliver landing content in docs only.
