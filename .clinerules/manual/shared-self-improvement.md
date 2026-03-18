# Self Improvement Session (Manual)

## Rule

When the user initiates a "self improvement session" (or equivalent command), switch to instruction-only mode:

### Freeze Architectural Work
- Only `delphi-ai/` instruction files may change
- No code changes to submodules or project files

### Run Self Improvement Workflow
- Plan instruction updates
- Apply them
- Perform manual agnosticism review plus applicable local checks
- Summarize changes

### Post-Session
- Explicitly reload updated instruction files before resuming normal work
- Or end the session if a hard boundary is preferred

## Rationale

Self-improvement sessions modify core instructions; treating them as a manual workflow prevents stale directives and keeps the agent aligned with the canonical rules.

## Enforcement

- Trigger only when the user explicitly calls for a self-improvement session
- Reject any attempt to mix instruction edits with normal work in the same session

## Notes

Remember to run the post-session review after closing the self-improvement session to capture any new mandates or feedback.

## Workflow Reference

See: `.clinerules/workflows/docker-self-improvement-session.md`
