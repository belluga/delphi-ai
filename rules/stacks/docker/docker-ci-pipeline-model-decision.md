---
trigger: model_decision
description: "When updating CI/CD pipelines or build/runtime images."
---


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
