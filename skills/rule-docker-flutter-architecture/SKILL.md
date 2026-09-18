---
name: rule-docker-flutter-architecture
description: Coordinate Docker changes with Flutter architecture only when project-owned topology activates both capabilities; do not infer Flutter from Docker alone.
---

# Conditional Flutter Coordination

- Treat `rules/stacks/docker/flutter-architecture.md` as the canonical rule.
- Confirm both `docker` and `flutter` are project-declared before loading Flutter-specific runtime, diagnostics, or publication contracts.
- When Flutter is inactive, introduce no Flutter paths, tools, analyzers, or derived-web assumptions.
- When both are active, load `rules/stacks/flutter/` and preserve its build, runtime-freshness, diagnostics, and publication boundaries.
