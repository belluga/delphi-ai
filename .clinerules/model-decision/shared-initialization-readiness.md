# Initialization Readiness (Model Decision)

## Rule

When the context indicates downstream environment setup, repository verification, CI/CD readiness, or session start in a downstream project:

### Initialization Steps
- Run the Initialization Checklist (`initialization_checklist.md`) and `bash delphi-ai/verify_context.sh`
- Execute the Environment Readiness Workflow to confirm submodule links, permissions, and README guidance
- Document any remediation (symlinks, ownership fixes) before moving to feature work

### TODO Directory Setup
If tactical TODO discipline is in use, ensure `foundation_documentation/todos/{active,completed}` exists (create via `bash delphi-ai/verify_context.sh --fix-todos` if desired).
Do not use this rule to block Delphi self-maintenance inside the `delphi-ai/` repo itself; that path is governed by the self-improvement workflow and manual agnosticism review.

## Rationale

Proper initialization prevents stale instructions, broken symlinks, and container permissions issues. Automating this via a rule ensures the workspace reaches a known-good state before touching code.

## Enforcement

- Triggered automatically at session start for downstream project sessions and whenever the user mentions setup/CI/CD/env readiness
- Block other workflows until the checklist passes

## Notes

`bash delphi-ai/verify_context.sh` is a readiness/sync command. If it reports issues, accept its repairs or finish the remaining remediation, then rerun it before continuing.

## Workflow Reference

See: `.clinerules/workflows/docker-environment-readiness.md`
