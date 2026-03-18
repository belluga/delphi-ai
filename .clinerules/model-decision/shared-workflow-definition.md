# Workflow Definition (Model Decision)

## Rule

When defining or editing a workflow:

### Structure
- Use `delphi-ai/templates/workflow-template.md` as scaffold
- Name files in kebab-case (no underscores)
- Include required header fields for the target surface (`description` for canonical workflows; `name` + `description` for Cline workflows)

### Rule Linkage
- Create or update the corresponding rule (glob/model_decision/manual) so the workflow is triggerable
- Reference the workflow path explicitly

### Counterpart Coherence
- If a workflow skill exists in `delphi-ai/.cline/skills/wf-*`, the matching workflow file must exist in `delphi-ai/.clinerules/workflows/**`
- If the canonical workflow skill exists in `delphi-ai/skills/wf-*`, the canonical workflow file must exist in `delphi-ai/workflows/**`
- Remove or archive obsolete workflows/rules/skills together

### Governance Baseline (Implementation-Capable Workflows)
- Encode baseline controls directly or reference TODO-driven execution controls:
  - complexity classification (`small|medium|big`)
  - Plan Review Gate for `medium|big`
  - explicit `APROVADO` gate before implementation
  - Decision Baseline freeze + Decision Adherence Gate before delivery
  - Cline planning/recommendations are advisory by default

### Placement
- Stack-specific rules under appropriate stack folder
- Shared rules in `model-decision/`

## Rationale

Workflows are only effective when triggered by rules. This rule keeps procedures consistent and ensures they're callable by the agent.

## Enforcement

- Block additions/edits that lack a matching rule or deviate from the template
- Block workflow additions that lack required skill/workflow counterparts
- Block implementation-capable workflows that omit baseline governance controls
- Require `bash delphi-ai/verify_context.sh` and `bash delphi-ai/verify_adherence_sync.sh` before completion
- Require PR reviewers to verify the rule ↔ workflow linkage

## Notes

When adding or renaming workflows, also update `CLINE.md` and `.cline/MANIFEST.md` if loading order, availability lists, or required governance artifacts change.
