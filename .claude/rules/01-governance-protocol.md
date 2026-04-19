---
description: "PACED governance protocol, T.E.A.C.H. framework, and cascading patterns authority"
alwaysApply: true
---

# Governance Protocol

## PACED Framework

PACED (Progressively Accelerated Controlled Engineering through Determinism) governs all engineering decisions. The four Surfaces of Authority, in descending precedence:

1. **Constitution** (`foundation_documentation/project_constitution.md`) — DNA of the project, non-negotiable rules
2. **Roadmap** (`foundation_documentation/system_roadmap.md`) — Strategic direction and sequencing
3. **Modules** (`foundation_documentation/modules/*.md`) — Stable contracts and decisions per module
4. **TODOs** (`foundation_documentation/todos/active/*.md`) — Immediate execution contracts

## T.E.A.C.H. Feedback Protocol

When correcting or learning from errors, apply the T.E.A.C.H. framework:

- **T**rigger: What triggered the correction
- **E**nforced: The rule or pattern that was violated — cite `[PATTERN: id]` when applicable
- **A**ction: What was done wrong
- **C**orrection: The correct approach
- **H**ardening: How to prevent recurrence (rule update, guard, test)

## Cascading Patterns Library

Patterns follow the authority cascade: Core → Stack → Local. When referencing a pattern in TODOs or code, use the format `[PATTERN: PAT-CORE-001-v1]`. The `todo_completion_guard.py` validates that cited pattern IDs exist in the cascade.

See `delphi-ai/patterns/` for the full library.
