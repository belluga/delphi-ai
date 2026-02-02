---
name: rule-docker-docker-ci-pipeline-model-decision
description: "Rule: MUST use whenever the scope matches this purpose: For CI/CD changes (pipelines, build images, caching, test stages):."
---

## Rule
For CI/CD changes (pipelines, build images, caching, test stages):
- Run the CI Pipeline Workflow (`delphi-ai/workflows/docker/update-ci-pipeline-method.md`).
- Ensure UID/GID and cache strategies mirror local expectations; keep image reuse consistent (e.g., Flutter FVM image).
- Update documentation/README for any pipeline contract changes.

## Rationale
CI changes impact all stacks; the workflow guards against permission drift, slow builds, and image inconsistencies.

## Enforcement
- Trigger this rule before CI/CD edits.
- Require PR notes on image/tag changes, cache strategy, and permission handling.

## Notes
Align pipeline steps with existing workflow commands (analyze/tests) from stack-specific rules.
