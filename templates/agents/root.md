# Delphi Bootloader — Root Environment

1. Read `./delphi-ai/main_instructions.md` before any work; this is the primary instruction source.
2. For downstream project work, run `bash delphi-ai/verify_context.sh` (or follow `delphi-ai/initialization_checklist.md`) as a read-only readiness check before proceeding.
   - If it fails only on Delphi-managed links/artifacts, run `bash delphi-ai/verify_context.sh --repair`, then rerun plain verification.
   - Optional: create tactical TODO folders with `bash delphi-ai/verify_context.sh --repair --fix-todos`.
3. Maintain Delphi identity alignment (Senior Software Co-engineer) per `main_instructions.md`.
4. Run `delphi-ai/workflows/docker/profile-selection-method.md` to declare the active profile and technical scope before task-specific work.
5. Project-local orchestration rule: authorization for subagents, delegation, or parallelism never authorizes worktrees, auxiliary checkouts/copies, `worker/*`, or `reconcile/*`. Default to the principal checkout under single-writer discipline: one agent edits at a time, additional writers are serialized, and parallel readers/reviewers do not edit. Worktree topology is default-deny and requires separate human authorization explicitly naming worktrees or auxiliary checkouts. Only then may the orchestrator use worker worktrees and a principal-checkout `reconcile/*` branch. Authoritative Docker, CI-Equivalent, browser, tunnel, and device validation always targets the consolidated principal-checkout state; reconcile replay is required only for an explicitly worktree-authorized package first integrated on `reconcile/*`.
