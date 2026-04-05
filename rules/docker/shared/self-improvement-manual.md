---
trigger: manual
description: Run the self-improvement session workflow when explicitly requested.
---


## Rule
When the user initiates a “self improvement session” (or equivalent command), switch to instruction-only mode:
- Freeze architectural work and acknowledge that only `delphi-ai/` instruction files may change.
- Run the Self Improvement Workflow (`delphi-ai/workflows/docker/self-improvement-session-method.md`): plan instruction updates, apply them, perform manual agnosticism review plus applicable local checks, and summarize changes.
- When the user confirms the self-improvement scope is done, run the Post-Session Review Method before acknowledging closure. Keep that review read-only for downstream project docs; defer any `foundation_documentation/` edits to a fresh non-self-improvement follow-up.
- After instruction refinements are complete and the user confirms scope is done, explicitly reload the updated instruction files before resuming normal work (or end the session if a hard boundary is preferred).

## Rationale
Self-improvement sessions modify core instructions; treating them as a manual workflow prevents stale directives and keeps the agent aligned with the canonical rules.

## Enforcement
- Trigger only when the user explicitly calls for a self-improvement session or uses the `/self-improvement` command.
- Reject any attempt to mix instruction edits with normal work in the same session.

## Notes
During self-improvement closure, post-session review still applies; the special case is that downstream mandate edits are deferred until the instruction-only session is over.
