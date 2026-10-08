---
name: register-builder-project
description: Guide optional Project registration with Builder through the shared API, including initialization guidance for an unregistered Project.
---

# Register a Project with Builder

Keep this skill a thin, consent-aware API consumer. The API registers integration metadata and makes the explicitly admitted Project content selectable in Builder. Registration does not approve documentation, grant tenant access or authorize serving a complete repository. Do not request, store, derive or return a Project URL; local artifact validation and registration do not depend on an external page or public publication.

## Resolve and call the shared API

Resolve the shared Delphi checkout independently of the caller's cwd and read its `local-api/contract.md`. Use only the shared `local-api/run` operations and their documented response. The API owns shared state and physical Project/Foundation bindings; do not read or edit `registry.json` directly. If the launcher or API-owned state is unavailable, stop before claiming absence or readiness. Never use `knowledge-status` as a registration lookup.

Public clients invoke the API from the selected Project checkout and supply identities only: `builder-project list`, `builder-project status --project-id <id>`, `builder-project register --project-id <id> --project-name <name> --company-id <id> --company-name <name>`, and `builder-project decline --project-id <id>`. Status may select one artifact with `--artifact-kind landing|design-system|prototype`; a requested Prototype also requires `--artifact-id <id>`. Use `context --project-id <id> [--company-id <id>]` for a local authoring destination; select a Design System owner with `--owner-level project|company|default` and provide `--default-owner-id` when authoring the default source. Never ask for or pass state, workspace, Project, Foundation, or source-binding paths. Context output is for the local authoring process only and must never enter a browser result. Project IDs cannot be silently rebound.

## Guide registration

1. Select the Project explicitly. Confirm its stable Project and Company identities from owner-provided context; ask only for missing or conflicting identities. Never infer the Company from folders or silently rebind an existing Project. The API resolves checkout and Foundation context.
2. Obtain fresh Project status through the API. An unavailable lookup is not proof that registration is absent. An existing matching registration needs no new write or consent question; show its actual state and next action.
3. When registration is confirmed absent, present the API's T.E.A.C.H. explanation and procedure, then ask whether the user wants optional Builder integration of the explicitly selected content unless that action was already explicitly requested. Initialization invoking this skill is not consent to register. Registration does not independently authorize public exposure or an access-policy change. If the documented API reports a prior refusal, do not repeat the question unless the user asks to reconsider. Missing registration does not block ordinary Delphi work.
4. If declined, call `decline` for the confirmed Project identity. It records an optional integration preference only when no registration exists; it cannot unregister a Project or remove its snapshots. Do not create an alternative local preference file.
5. If accepted, call the documented registration operation with confirmed Project/Company identities and display names, then report its authoritative outcome. The API owns matching identity, persistence, private bindings, bounded content preparation and consumer-readiness checks; this skill must not duplicate them in a separate verification flow. Integration-ready success means the Project is selectable under the confirmed Company with resolvable admitted content, not merely that metadata was written. If persistence succeeds but consumer preparation fails, retain that distinction and show the API's recovery guidance. Do not create duplicate records on retry or silently overwrite conflicting identities.

Missing Landing, Design System or Prototype artifacts remain individual pending items, not prerequisites for the Project to appear. Registration never creates placeholder artifacts or human-review markers. Keep local paths and credentials out of browser-facing output. Projects validate portable authored artifacts locally; Builder consumes those same declared files and assets. Do not add an external browser probe or manual publication step to registration.

## Handoff

Report registration outcome, Company/Project identity, consumer readiness, available versus pending artifacts, and the next concrete action. Registration does not require a separate visibility-validation skill. Distinguish registration, artifact integrity/freshness, human review and local visual validation. Read the live API contract again when the environment moves from provisional local storage to a remote database; preserve the skill's consent and status responsibilities without bypassing the API.
