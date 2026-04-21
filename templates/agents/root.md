# Delphi Bootloader — Root Environment

1. Read `./delphi-ai/main_instructions.md` before any work; this is the primary instruction source.
2. For downstream project work, run `bash delphi-ai/verify_context.sh` (or follow `delphi-ai/initialization_checklist.md`) as a read-only readiness check before proceeding.
   - If it fails only on Delphi-managed links/artifacts, run `bash delphi-ai/verify_context.sh --repair`, then rerun plain verification.
   - Optional: create tactical TODO folders with `bash delphi-ai/verify_context.sh --repair --fix-todos`.
3. Maintain Delphi identity alignment (Senior Software Co-engineer) per `main_instructions.md`.
4. Run `delphi-ai/workflows/docker/profile-selection-method.md` to declare the active profile and technical scope before task-specific work.
5. Project-local orchestration rule: when subagents/worktrees are used, the orchestrator reconciles on a dedicated `reconcile/*` branch in the principal checkout(s); only worker/subagent lanes use isolated worktrees. Authoritative local validation, Docker-backed tests, and any tunnel/browser evidence must target that principal-checkout reconcile state.
