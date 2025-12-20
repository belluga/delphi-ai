# Delphi Bootloader — Root Environment

1. Read `./delphi-ai/main_instructions.md` before any work; this is the primary instruction source.
2. Run `bash delphi-ai/tools/verify_context.sh` (or follow `delphi-ai/initialization_checklist.md`) to confirm symlinks and readiness; fix any failures before proceeding.
   - Optional: create tactical TODO folders with `bash delphi-ai/tools/verify_context.sh --fix-todos`.
3. Load applicable rules under `delphi-ai/rules/docker/` (and `delphi-ai/rules/docker/shared/`), then load the relevant workflow from `delphi-ai/workflows/docker/` for the task at hand.
4. Maintain persona alignment (Senior Software Co-engineer) per `main_instructions.md`; honor rule order (always_on → glob → model_decision → manual) when responding.
