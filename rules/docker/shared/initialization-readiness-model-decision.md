---
trigger: model_decision
description: "When downstream project environment/setup tasks are requested or a downstream session starts."
---


## Rule
When the context indicates downstream environment setup, repository verification, CI/CD readiness, or session start in a downstream project:
- Run the Initialization Checklist (`delphi-ai/initialization_checklist.md`) and `bash delphi-ai/verify_context.sh`.
- Execute the Environment Readiness Workflow (`delphi-ai/workflows/docker/environment-readiness-method.md`) to confirm submodule links, permissions, and README guidance.
- Verify `foundation_documentation/policies/scope_subscope_governance.md` exists and is loaded before any route/module/screen task.
- Document any remediation (symlinks, ownership fixes) before moving to feature work.
- If tactical TODO discipline is in use, ensure `foundation_documentation/todos/{active,completed}` exists (create via `bash delphi-ai/verify_context.sh --repair --fix-todos` if desired).
- Do **not** use this rule to block Delphi self-maintenance inside the `delphi-ai/` repo itself; that path is governed by the Self Improvement Session Workflow and manual agnosticism review.

## Rationale
Proper initialization prevents stale instructions, broken symlinks, and container permissions issues. Automating this via a rule ensures the workspace reaches a known-good state before touching code.

## Enforcement
- Triggered automatically at session start for downstream project sessions and whenever the user mentions setup/CI/CD/env readiness.
- Block other workflows until the checklist passes.

## Notes
`bash delphi-ai/verify_context.sh` is read-only by default. If it fails only on Delphi-managed links/artifacts, run `bash delphi-ai/verify_context.sh --repair`, then rerun plain verification before continuing.
