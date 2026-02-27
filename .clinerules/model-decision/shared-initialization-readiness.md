# Initialization Readiness (Model Decision)

## Rule

When the context indicates environment setup, repository verification, or session start:

### Initialization Steps
- Run the Initialization Checklist (`initialization_checklist.md`) and `tools/verify_context.sh`
- Execute the Environment Readiness Workflow to confirm submodule links, permissions, and README guidance
- Document any remediation (symlinks, ownership fixes) before moving to feature work

### TODO Directory Setup
If tactical TODO discipline is in use, ensure `foundation_documentation/todos/{active,completed}` exists (create via `tools/verify_context.sh --fix-todos` if desired).

## Rationale

Proper initialization prevents stale instructions, broken symlinks, and container permissions issues. Automating this via a rule ensures the workspace reaches a known-good state before touching code.

## Enforcement

- Triggered automatically at session start and whenever the user mentions setup/CI/CD/env readiness
- Block other workflows until the checklist passes

## Notes

If `verify_context.sh` fails due to missing symlinks, pause, fix the issue, and rerun the script before continuing.

## Workflow Reference

See: `.clinerules/workflows/docker-environment-readiness.md`