---
trigger: model_decision
description: Apply Flutter architecture rules during Docker/runtime work only when the project activates Flutter.
---

# Conditional Flutter Coordination

## Rule

The `docker` capability does not activate Flutter.

When project-owned topology activates both `docker` and `flutter`, load the canonical Flutter rules from `delphi-ai/rules/stacks/flutter/` and preserve their build, diagnostics, runtime-freshness, and publication contracts during Docker or ingress changes.

When `flutter` is not active, this rule has no effect. Do not introduce Flutter paths, tools, analyzers, publication assumptions, or derived-web ownership into a Docker-only or non-Flutter project.

## Rationale

Docker is a composable runtime capability. Conditional coordination preserves established Flutter behavior without making Flutter an implicit dependency of every Docker project.

## Enforcement

- Require project-owned evidence that both capabilities are active before applying Flutter-specific Docker requirements.
- Block Docker changes that break an active Flutter build/publication contract.
- Block accidental Flutter coupling when the capability is not declared.
