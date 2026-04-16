---
name: wf-docker-runtime-index-method
description: "Workflow: MUST use whenever the scope matches this purpose: Generate a derived runtime/session handoff index from active tactical TODOs and bounded continuity memory so resume work does not require rediscovering every surface."
---

# Method: Runtime Index / Session Handoff Index

## Purpose
Generate a reconstructible, non-authoritative runtime index that surfaces active tactical TODOs, blocked fronts, open handoffs, and bounded session-memory carry-over.

## Triggers
- A normal downstream session resumes and there are active tactical TODOs.
- Multiple active TODOs, blocked fronts, or open handoffs make it unclear where to resume first.
- The user asks to resume, hand off, or understand “where we are now” without reopening every active TODO manually.
- Post-session review updated bounded session memory or materially changed TODO continuity.

## Procedure
1. Use this only for downstream tactical continuity, never for Delphi self-maintenance.
2. Generate the index with:
   ```bash
   python3 delphi-ai/tools/runtime_session_index.py \
     --repo . \
     --output foundation_documentation/artifacts/tmp/runtime-index.md
   ```
3. Optionally emit a JSON sidecar:
   ```bash
   python3 delphi-ai/tools/runtime_session_index.py \
     --repo . \
     --output foundation_documentation/artifacts/tmp/runtime-index.md \
     --json-output foundation_documentation/artifacts/tmp/runtime-index.json
   ```
4. Use the generated `Resume Heuristic`, `Blocked Fronts`, and `Open Handoffs` only as navigation aid.
5. Open the referenced tactical TODO and canonical module docs before execution.
6. Regenerate whenever TODO status, handoffs, or bounded session memory change materially. Never hand-edit the index.

## Validation
- The index is reconstructible and explicitly non-authoritative.
- No execution is justified from the index alone.
