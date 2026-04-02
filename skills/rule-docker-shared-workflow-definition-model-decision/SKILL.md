---
name: rule-docker-shared-workflow-definition-model-decision
description: "Rule: MUST use whenever the scope matches this purpose: When creating or updating a workflow/procedure."
---

## Rule
When defining or editing a workflow:
- Use `delphi-ai/templates/workflow-template.md` as the scaffold.
- Name files in kebab-case (no underscores) and include required header fields exactly.
- Create or update the corresponding rule (glob/model_decision/manual) so the workflow is triggerable; reference the workflow path explicitly.
- Keep counterparts coherent:
  - if a workflow skill (`skills/wf-*`) exists, a canonical workflow file under `delphi-ai/workflows/**` must exist;
  - if a Cline workflow skill (`delphi-ai/.cline/skills/wf-*`) exists, a Cline workflow counterpart under `delphi-ai/.clinerules/workflows/**` must exist.
- For workflows that can lead to implementation, explicitly encode governance gates or reference the TODO-driven execution rule/workflow:
  - complexity classification (`small|medium|big`);
  - Plan Review Gate for `medium|big`;
  - Decision Baseline freeze;
  - explicit `APROVADO` gate;
  - Decision Adherence Gate before delivery;
  - Cline advisory-only planning boundary.
- Place stack-specific rules under the appropriate stack folder; shared rules go in `rules/docker/shared/` (symlinked to other stacks).
- Remove or archive obsolete workflows/rules/skills together to avoid drift.

## Rationale
Workflows are only effective when triggered by rules. This rule keeps procedures consistent and ensures they’re callable by the agent in Codex CLI (and similar harnesses).

## Enforcement
- Block additions/edits that lack a matching rule or deviate from the template.
- Block workflow additions that lack required skill/workflow counterparts across canonical and Cline surfaces.
- Block implementation-capable workflows that omit baseline governance gates (directly or by explicit reference).
- For downstream environment work, require `bash delphi-ai/verify_context.sh` and `bash delphi-ai/verify_adherence_sync.sh` before completion.
- For Delphi self-maintenance, require manual agnosticism review plus applicable local checks (for example `bash self_check.sh`) before completion.
- Require PR reviewers to verify the rule ↔ workflow linkage.

## Notes
When adding or renaming workflows, update AGENTS/CLINE instructions and `.cline/MANIFEST.md` when required.
