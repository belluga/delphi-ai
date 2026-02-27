# Session Lifecycle (Model Decision)

## Rule

When a session begins, switches scope, or ends:

### Session Start
- Load the Persona Selection Workflow to anchor the persona
- Execute the Session Lifecycle Workflow to log purpose, freeze work during instruction edits, and manage transitions

### Session End
- Follow Post-Session Review Workflow:
  - Analyze new principles
  - Update mandates if needed
  - Deliver English feedback before acknowledging closure

## Rationale

Session lifecycle discipline keeps context consistent across personas, ensures instruction updates trigger session restarts, and enforces the mandated post-session review steps.

## Enforcement

- Trigger this rule whenever the user says "session start/end," changes modules, or requests review
- Do not proceed to new tasks until persona + lifecycle steps are complete

## Notes

If instructions change mid-session, finish the change and do not proceed to architectural work until the updated instruction files have been explicitly reloaded (re-read) and confirmed.

## Workflow References

- `.clinerules/workflows/docker-session-lifecycle.md`
- `.clinerules/workflows/docker-post-session-review.md`
- `.clinerules/workflows/docker-persona-selection.md`