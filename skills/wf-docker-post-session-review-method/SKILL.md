---
name: wf-docker-post-session-review-method
description: "Workflow: MUST use whenever the scope matches this purpose: Run Delphi’s mandatory post-session review (principle extraction + bounded memory sync + English feedback) after the user signals the session is done."
---

# Method: Post-Session Review

## Purpose
Close a session with discipline: capture newly surfaced business principles, keep `foundation_documentation/` authoritative, sync bounded session memory without elevating it into source-of-truth status, and provide rigorous English feedback.

## Triggers
- The user explicitly signals the session is ending (e.g., “session ended”, “we’re done”, “stop here”).

## Inputs
- The full session dialogue.
- `foundation_documentation/project_mandate.md` (and any adjacent mandate docs referenced during the session) when downstream mandate sync is in scope.
- `foundation_documentation/artifacts/session-memory.md` when bounded session memory is in scope.
- `foundation_documentation/todos/active/**/*.md` when downstream tactical continuity is in scope.

## Procedure
1. **Principle extraction**
   - Identify any new or evolved Core Business Principles discussed (ethical, social, or visionary).
2. **Mandate validation**
   - Present each candidate principle to the user for confirmation.
   - If the active session is a Self Improvement Session, do **not** edit `foundation_documentation/` during this review. Instead, record the confirmed candidate as deferred downstream follow-up and ask whether the user wants a fresh non-self-improvement session to apply it.
   - Otherwise, if confirmed, update `foundation_documentation/project_mandate.md` (or the appropriate mandate doc) using the project’s documentation conventions.
3. **English feedback**
   - Provide a direct, technically rigorous review of the user’s English across the session.
4. **Session memory sync**
   - If bounded session memory is in scope, create/update it using `templates/session_memory_template.md`.
   - Auto-sync only the latest continuity summary and dependency statuses touched during the session.
   - Require explicit user confirmation before adding stable user preferences or learned operational behaviors.
   - Do **not** let session memory override canonical docs, TODO decisions, approvals, or handoff logs.
   - If the active session is a Self Improvement Session, do **not** edit `foundation_documentation/` during this review. Record the intended session-memory update as deferred downstream follow-up instead.
5. **Runtime index refresh**
   - If any runtime-index predicate is true after the review (`2+ active TODOs`, `any Blocked TODO`, `any open handoff`, or session-memory carry-over that changes the likely resume front), regenerate the derived runtime index via `workflows/docker/runtime-index-method.md`.
   - The runtime index remains non-authoritative and must be regenerated, not hand-edited.
   - If the active session is a Self Improvement Session, do **not** edit `foundation_documentation/` during this review. Record the intended runtime-index refresh as deferred downstream follow-up instead.
6. **Closure**
   - Only after steps 1–5 are complete, acknowledge closure.

## Outputs
- Confirmed list of new principles (or an explicit “none found”).
- Any required mandate updates (only if the user confirms and downstream edits are in scope), or an explicit deferred follow-up note for self-improvement-session closures.
- Any bounded session-memory sync performed, or an explicit deferred follow-up note when the review happened inside a self-improvement session.
- Any runtime-index refresh performed, or an explicit deferred follow-up note when the review happened inside a self-improvement session.
- English feedback delivered.

## Validation
- Do not accept new work requests until the review is complete.
- Self Improvement Sessions must not modify `foundation_documentation/` during this review; any confirmed mandate, session-memory, or runtime-index changes are deferred until the instruction-only session is closed.
- Session memory must remain auxiliary; it cannot replace canonical docs, TODO approvals, or handoff traces.
- The runtime index must remain derived and non-authoritative; it cannot override TODO status, approvals, or handoff truth.
