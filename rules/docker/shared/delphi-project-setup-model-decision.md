---
trigger: model_decision
description: "When a downstream project must be onboarded, recalibrated, or rebaselined against the current PACED/Delphi method."
---


## Rule
When the context indicates downstream project onboarding, Delphi adoption, project recalibration, or meaningful drift from the current Delphi baseline:
- Run the Initialization Checklist (`delphi-ai/initialization_checklist.md`) and the Environment Readiness Workflow (`delphi-ai/workflows/docker/environment-readiness-method.md`) first.
- Execute the Delphi Project Setup Method (`delphi-ai/workflows/docker/delphi-project-setup-method.md`) to classify the lane (`bootstrap|recalibration`), map inherited Delphi authority versus project-owned authority, and classify drift. Prefer `bash delphi-ai/tools/project_recalibration_doctor.sh --repo <repo>` when the deterministic report + packet loop should be produced in one pass.
- When the derived setup report says `needs-normalization` or `manual-remediation-required`, derive a brownfield normalization packet before opening remediation TODOs.
- Do not start normal feature work while material structural or governance drift remains unresolved.
- If setup remediation requires changes to project artifacts, hand off to the TODO-Driven Execution Method (`delphi-ai/workflows/docker/todo-driven-execution-method.md`) and require `APROVADO` before changes.

## Rationale
Delphi centralizes stack and method authority. Projects should not redefine those general rules locally, but they do need calibration so the current Delphi baseline, local project specialization, and any accumulated drift are made explicit before work resumes.

## Enforcement
- Trigger this rule whenever the user asks to set up Delphi in a project, resume an older project after drift, or rebaseline a project after Delphi changes.
- Block feature implementation while setup status is `needs-normalization` or while readiness/manual blockers remain unresolved.

## Notes
This rule is broader than environment readiness. Readiness proves the workspace is wired; project setup proves the project is calibrated to the active Delphi method.
