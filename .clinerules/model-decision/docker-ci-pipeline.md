# Docker CI Pipeline (Model Decision)

## Rule

For CI/CD changes (pipelines, build images, caching, test stages):

### Requirements
- Run the CI Pipeline Workflow
- Ensure UID/GID and cache strategies mirror local expectations; keep image reuse consistent (e.g., Flutter FVM image)
- Update documentation/README for any pipeline contract changes

## Rationale

CI changes impact all stacks; the workflow guards against permission drift, slow builds, and image inconsistencies.

## Enforcement

- Trigger this rule before CI/CD edits
- Require PR notes on image/tag changes, cache strategy, and permission handling

## Notes

Align pipeline steps with existing workflow commands (analyze/tests) from stack-specific rules.

## Workflow Reference

See: `.clinerules/workflows/docker-update-ci-pipeline.md`