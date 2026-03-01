# Cline Artifacts Manifest

This file tracks the Cline-specific governance artifacts that must stay aligned with Delphi canonical rules/workflows.

## Required Governance Artifacts

### Core instructions
- `.clinerules/00-main-instructions.md`

### Model-decision rules
- `.clinerules/model-decision/shared-todo-driven-execution.md`
- `.clinerules/model-decision/shared-session-lifecycle.md`
- `.clinerules/model-decision/shared-workflow-definition.md`

### Workflows
- `.clinerules/workflows/docker-todo-driven-execution.md`
- `.clinerules/workflows/docker-todo-driven-execution-method.md`
- `.clinerules/workflows/docker-session-lifecycle.md`
- `.clinerules/workflows/docker-self-improvement-session.md`
- `.clinerules/workflows/docker-update-skill-method.md`
- `.clinerules/workflows/laravel-create-package-method.md`

### Manual rules
- `.clinerules/manual/shared-self-improvement.md`

### Skill Mirrors (Critical)
- `.cline/skills/wf-docker-update-skill-method/SKILL.md`
- `.cline/skills/wf-docker-todo-driven-execution-method/SKILL.md`
- `.cline/skills/rule-docker-shared-todo-driven-execution-model-decision/SKILL.md`
- `.cline/skills/wf-laravel-create-package-method/SKILL.md`
- `.cline/skills/test-quality-audit/SKILL.md`
- `.cline/skills/test-creation-standard/SKILL.md`
- `.cline/skills/test-orchestration-suite/SKILL.md`

### Hooks
- `.clinerules/hooks/session_start`

## Notes

- Cline planning is advisory. Delivery authority remains Delphi TODO + APROVADO + Decision Adherence Gate.
- Validation scripts must fail if required Cline governance artifacts are missing.
