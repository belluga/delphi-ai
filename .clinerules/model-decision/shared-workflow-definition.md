# Workflow Definition (Model Decision)

## Rule

When defining or editing a workflow:

### Structure
- Use workflow template as scaffold
- Name files in kebab-case (no underscores)
- Include header fields: `name`, `description`

### Rule Linkage
- Create or update the corresponding rule (glob/model_decision/manual) so the workflow is triggerable
- Reference the workflow path explicitly

### Placement
- Stack-specific rules under appropriate stack folder
- Shared rules in `model-decision/`

### Maintenance
- Remove or archive obsolete workflows/rules together to avoid drift

## Rationale

Workflows are only effective when triggered by rules. This rule keeps procedures consistent and ensures they're callable by the agent.

## Enforcement

- Block additions/edits that lack a matching rule or deviate from the template
- Require PR reviewers to verify the rule ↔ workflow linkage

## Notes

When adding a new workflow, also update CLINE.md if the loading order or commands change.