---
description: Generate a derived runtime/session handoff index from active tactical TODOs and bounded continuity memory so resume work can reduce initial re-navigation overhead.
---

# Method: Runtime Index / Session Handoff Index

## Purpose
Generate a reconstructible, non-authoritative runtime index that surfaces active tactical TODOs, blocked fronts, open handoffs, and bounded session-memory carry-over.

This method exists to reduce initial re-navigation overhead at session resume time. It does **not** create a new source of truth.

## Triggers
- A normal downstream session resumes and **two or more** active tactical TODOs exist.
- Any active tactical TODO is `Blocked`.
- Any open handoff exists in an active TODO.
- Bounded session memory carries a `Current active TODO` / `Current active front` that changes the likely resume front.
- Post-session review changed one of the conditions above, so the derived index should be refreshed for the next session.

## Inputs
- `foundation_documentation/todos/active/**/*.md`
- `foundation_documentation/artifacts/session-memory.md` when present
- Current repository root

## Procedure
1. **Confirm scope**
   - Use this method only for downstream tactical continuity.
   - Do **not** use it for Delphi self-maintenance sessions; use the temporary self-improvement work ledger instead.
2. **Generate the derived index**
   - Run:
     ```bash
     python3 delphi-ai/tools/runtime_session_index.py \
       --repo . \
       --output foundation_documentation/artifacts/tmp/runtime-index.md
     ```
   - Optional machine-readable sidecar:
     ```bash
     python3 delphi-ai/tools/runtime_session_index.py \
       --repo . \
       --output foundation_documentation/artifacts/tmp/runtime-index.md \
       --json-output foundation_documentation/artifacts/tmp/runtime-index.json
     ```
3. **Use it as navigation aid only**
   - Read the generated `Resume Heuristic`, `Blocked Fronts`, and `Open Handoffs` sections to decide what to open first.
   - If the generator does not emit a single confident resume target, treat the summary tables as the source for choosing the next front; do not invent false confidence.
   - Then open the referenced tactical TODO and relevant canonical module docs before doing any execution work.
4. **Never hand-edit the index**
   - If continuity changes, regenerate the index.
   - Do not patch the index to manufacture status, approval, or handoff truth.
5. **Refresh when continuity changes**
   - Regenerate after session-memory sync only when any of these predicates is true:
     - two or more active TODOs exist;
     - any active TODO is `Blocked`;
     - any open handoff exists;
     - bounded session memory now points to a different likely resume front.

## Outputs
- `foundation_documentation/artifacts/tmp/runtime-index.md`
- Optional `foundation_documentation/artifacts/tmp/runtime-index.json`

## Validation
- The generated index is reconstructible from active TODOs + bounded session memory.
- The index remains explicitly non-authoritative.
- No execution is justified from the index alone; the active TODO and canonical module docs must still be opened before work resumes.
