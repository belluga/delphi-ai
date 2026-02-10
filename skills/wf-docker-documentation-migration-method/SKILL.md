---
name: wf-docker-documentation-migration-method
description: "Workflow: MUST use whenever the scope matches this purpose: Turn temporary or legacy documentation (e.g., scratch specs, prototype UI notes) into the canonical Delphi documentation set using templates, close gaps, and produce progressive milestones plus team task lists."
---

# Workflow: Documentation Migration & Expansion

## Purpose
Turn temporary or legacy documentation (e.g., scratch specs, prototype UI notes) into the canonical Delphi documentation set using templates, close gaps, and produce progressive milestones plus team task lists.

## Preconditions
- Run `bash delphi-ai/tools/verify_context.sh` and fix any failures.
- Load main instructions and always_on rules.
- Identify source docs (e.g., `foundation_documentation/temporary_files/*`, uploaded specs) and target templates (module, roadmap, persona, etc.).
- Confirm submodule scope (Flutter/Laravel/web) if task lists are needed.

## Steps
1. Load core context (system principles, mandate) and relevant module templates; avoid editing temporary files directly.
2. Inventory source materials (temporary files, PRDs, prototype screens) and note authoritative vs. outdated content.
3. Map scope: determine required modules, entities, endpoints, screens, and real-time needs; note landlord vs tenant boundaries.
4. Perform gap analysis: validation bounds, enums, auth/abilities, real-time transport, rankings/badges, profile, catalog rules, and roadmaps.
5. Create/update canonical docs using templates:
   - `project_mandate`, `domain_entities`, module docs, persona roadmaps, system_roadmap, and landing/UX notes.
   - Define endpoints, schemas, enums, indexes, rate limits, payload samples, and SSE/WebSocket payload shapes if applicable.
6. Add progressive implementation milestones with testable outcomes; keep endpoints labeled (Defined/Mocked/Implemented/Tested & Ready).
7. Produce team task lists (Flutter, Laravel, etc.) with clear scopes and validation expectations.
8. If badges/rankings/real-time are introduced, document event → jobs → broadcast flow and polling fallbacks.
9. Surface landing/unauth content in docs (not in temp code) for client teams to implement.

## Outputs
- Updated canonical docs reflecting migrated content and resolved gaps.
- Progressive milestones and team task lists.
- Real-time payload definitions (if applicable) and roadmap status updates.

## Validation
- Ensure all modified docs exist in `foundation_documentation/` (or template directory) and follow template structure.
- Verify endpoints are listed with statuses; indexes/rate limits/enums documented.
- Confirm no edits were made to temporary files; deliver landing content in docs only.
