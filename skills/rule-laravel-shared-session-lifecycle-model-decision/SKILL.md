---
name: rule-laravel-shared-session-lifecycle-model-decision
description: "Rule: MUST use whenever the scope matches this purpose: At session start/end or when the user requests lifecycle actions."
---

## Rule
When a session begins, switches scope, or ends:
- Load the Profile Selection Workflow to anchor the active profile.
- Execute the Session Lifecycle Workflow (`delphi-ai/workflows/docker/session-lifecycle-method.md`) to log purpose, freeze work during instruction edits, and manage transitions.
- When any runtime-index predicate is true (`2+ active TODOs`, `any Blocked TODO`, `any open handoff`, or session-memory carry-over that changes the likely resume front), use `delphi-ai/workflows/docker/runtime-index-method.md` to generate a derived runtime index before resuming execution.
- For any route/module/screen scope, confirm `foundation_documentation/policies/scope_subscope_governance.md` is loaded before implementation tasks proceed.
- At session end, follow `delphi-ai/workflows/docker/post-session-review-method.md`: analyze new principles, update mandates if needed, and deliver English feedback before acknowledging closure.

## Rationale
Session lifecycle discipline keeps context consistent across profiles, reduces re-navigation overhead during tactical resumes, ensures instruction updates trigger session restarts, and enforces the mandated post-session review steps.

## Enforcement
- Trigger this rule whenever the user says “session start/end,” changes modules, or requests review.
- Do not proceed to new tasks until profile + lifecycle steps are complete.

## Notes
If instructions change mid-session, finish the change and do not proceed to architectural work until the updated instruction files have been explicitly reloaded (re-read) and confirmed.
