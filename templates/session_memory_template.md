# Template: Session Memory

Use this file as a bounded, non-authoritative continuity artifact, typically at `foundation_documentation/artifacts/session-memory.md`.

This artifact may help Delphi resume work across sessions, but it must never override:
- `project_constitution.md`
- `system_roadmap.md`
- canonical module docs
- tactical TODO decisions, approvals, or handoff logs

## Artifact Role
- **Purpose:** bounded continuity + confirmed preferences/behaviors + dependency references.
- **What it is not:** canonical contract, approval ledger, or authority for mixed-scope execution.

## Update Policy
- **Auto-eligible updates:**
  - latest session continuity summary;
  - dependency statuses touched during the session.
- **Confirmation required before updating:**
  - stable user preferences;
  - learned operational behaviors that should persist across sessions.
- **Never update here instead of canonical docs:**
  - architectural decisions;
  - module/constitution/roadmap truth;
  - tactical TODO approvals or profile handoffs.

## Latest Session Continuity
- **Last updated:** `<YYYY-MM-DD HH:MM TZ>`
- **Current active front:** `<what the next session should understand first>`
- **Last confirmed truth:** `<what remains true and should not be rediscovered>`
- **Next likely step:** `<single likely continuation>`

## Confirmed User Preferences
- `<only stable preferences that were explicitly confirmed>`

## Confirmed Learned Behaviors
- `<only stable operational habits or session-level lessons that were explicitly confirmed for persistence>`

## Dependency References
- **Dependency readiness register:** `foundation_documentation/artifacts/dependency-readiness.md`
- **Relevant status carry-over:** `<brief note or none>`
