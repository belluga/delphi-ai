---
description: "Shared model-decision rules — session lifecycle, initialization readiness, foundation docs sync, workflow definition, realtime delta streams, and project setup"
alwaysApply: true
---

# Shared Model-Decision Rules

These rules apply across all stacks and are triggered by model decision (contextual activation).

## Session Lifecycle

When a session begins, switches scope, or ends:

- Load the Profile Selection Workflow to anchor the active profile.
- Execute the Session Lifecycle Workflow (`delphi-ai/workflows/docker/session-lifecycle-method.md`) to log purpose, freeze work during instruction edits, and manage transitions.
- When any runtime-index predicate is true (2+ active TODOs, any Blocked TODO, any open handoff, or session-memory carry-over), use `delphi-ai/workflows/docker/runtime-index-method.md` to generate a derived runtime index before resuming execution.
- At session end, follow `delphi-ai/workflows/docker/post-session-review-method.md`: analyze new principles, update mandates if needed, and deliver English feedback before acknowledging closure.

## Initialization Readiness

When starting a new session, CI/CD readiness, or session start in a downstream project:

- Run the Initialization Checklist (`delphi-ai/initialization_checklist.md`) and `bash delphi-ai/verify_context.sh`.
- Execute the Environment Readiness Workflow (`delphi-ai/workflows/docker/environment-readiness-method.md`) to confirm submodule links, permissions, and README guidance.
- Verify `foundation_documentation/policies/scope_subscope_governance.md` exists and is loaded before any route/module/screen task.
- Do **not** use this rule to block Delphi self-maintenance inside the `delphi-ai/` repo itself.

## Foundation Docs Sync

If a task touches routes, screens, repositories, or domain models:

- Verify documentation is up-to-date before implementation.
- Update `foundation_documentation/` artifacts as part of the change.
- Ensure submodule summaries reflect current state.

## Workflow Definition

When defining or editing a workflow:

- Use `delphi-ai/templates/workflow-template.md` as the scaffold.
- Name files in kebab-case and include required header fields.
- Create or update the corresponding rule so the workflow is triggerable.
- For implementation-capable workflows, encode governance gates (complexity classification, Plan Review Gate, Decision Baseline freeze, APROVADO gate, Decision Adherence Gate).

## Realtime Delta Streams

When adding or revising realtime feed behavior (SSE streams, delta updates, or pagination policies):

- Keep list endpoints page-based and treat SSE as delta-only.
- Document SSE routes, event types, and resync behavior in `foundation_documentation/endpoints_mvp_contracts.md`.
- Block SSE additions that do not include a paginated list source of truth.

## Package-First Verification (Tier-Aware)

When planning implementation of any new feature, endpoint, domain, screen, controller, service, repository, or utility:

- Read the auto-generated checklist at `foundation_documentation/package_registry.md`.
- Review **all three sections**: Ecosystem (Global), Local Laravel, Local Flutter.
- `[x]` packages are in use — **use directly**. Read their README to understand the API.
- `[ ]` packages are available but not in use — **recommend adoption**. Read their README to evaluate fit.
- Apply **tier-appropriate autonomy**:
  - **Local** (in `packages/`, path dep): Treat as code. Modify freely, breaking changes OK — fix callers in same PR.
  - **Ecosystem** (Belluga org repo, VCS dep): Can modify, but version and evaluate cross-project impact.
  - **External** (pub.dev, Packagist, etc.): Do not modify. Wrap in adapter if behavior needs to change.
- Record a Package-First Assessment in the TODO (include tier classification).
- After creating a new package, run `bash delphi-ai/tools/verify_package_registry.sh` to update the checklist.
- See canonical rule: `rules/core/package-first-model-decision.md`.

## Delphi Project Setup

When setting up, re-initializing, or verifying the Delphi framework in a downstream project:

- Run `bash delphi-ai/verify_context.sh` (read-only by default).
- If it fails on Delphi-managed links/artifacts, run `bash delphi-ai/verify_context.sh --repair`.
- Ensure `foundation_documentation/todos/{active,completed}` directories exist.
