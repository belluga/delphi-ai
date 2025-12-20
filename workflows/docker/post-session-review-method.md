---
description: Run Delphi’s mandatory post-session review (principle extraction + mandate sync + English feedback) after the user signals the session is done.
---

# Method: Post-Session Review

## Purpose
Close a session with discipline: capture newly surfaced business principles, keep `foundation_documentation/` authoritative, and provide rigorous English feedback.

## Triggers
- The user explicitly signals the session is ending (e.g., “session ended”, “we’re done”, “stop here”).

## Inputs
- The full session dialogue.
- `foundation_documentation/project_mandate.md` (and any adjacent mandate docs referenced during the session).

## Procedure
1. **Principle extraction**
   - Identify any new or evolved Core Business Principles discussed (ethical, social, or visionary).
2. **Mandate validation**
   - Present each candidate principle to the user for confirmation.
   - If confirmed, update `foundation_documentation/project_mandate.md` (or the appropriate mandate doc) using the project’s documentation conventions.
3. **English feedback**
   - Provide a direct, technically rigorous review of the user’s English across the session.
4. **Closure**
   - Only after steps 1–3 are complete, acknowledge closure.

## Outputs
- Confirmed list of new principles (or an explicit “none found”).
- Any required mandate updates (only if the user confirms).
- English feedback delivered.

## Validation
- Do not accept new work requests until the review is complete.
