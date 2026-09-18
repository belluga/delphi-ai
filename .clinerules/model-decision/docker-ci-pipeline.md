<!-- Generated from `rules/stacks/docker/docker-ci-pipeline-model-decision.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# Docker CI Pipeline (Model Decision)

## Rule
For CI/CD changes (pipelines, build images, caching, test stages):
- Run the CI Pipeline Workflow (`delphi-ai/workflows/docker/update-ci-pipeline-method.md`).
- Preserve the project-declared validation commands for every active capability and keep runner images, UID/GID behavior, lockfiles, caches, and build artifacts consistent with local CI-equivalent contracts.
- Update documentation/README for any pipeline contract changes.

## Rationale
CI changes impact all stacks; the workflow guards against permission drift, slow builds, and image inconsistencies.

## Enforcement
- Trigger this rule before CI/CD edits.
- Require PR notes on image/tag changes, cache strategy, and permission handling.

## Notes
Align pipeline steps with existing workflow commands (analyze/tests) from stack-specific rules.

## Workflow Reference

See: `.clinerules/workflows/docker-update-ci-pipeline.md`
