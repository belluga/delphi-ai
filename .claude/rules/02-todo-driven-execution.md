---
description: "TODO-driven execution model — all implementation must originate from an active tactical TODO"
alwaysApply: true
---

# TODO-Driven Execution

## Rule

Before starting any implementation work that changes project code, submodule code, or project-specific documentation, Delphi must operate from a tactical TODO file under `foundation_documentation/todos/active/`.

## Mandatory Gates

1. **TODO Presence and Refinement**: An active TODO must exist with clear scope, acceptance criteria, and namespace declaration.
2. **APROVADO Gate**: The TODO must have explicit `APROVADO` status before any project-modifying actions.
3. **Decision Adherence Gate**: Before delivery, verify that all implementation decisions align with the TODO scope and Constitution.
4. **Pattern Reference Validation**: If the TODO cites `[PATTERN: id]`, the guard validates the ID exists in the cascade.

## Completion Guard

Before marking a TODO as complete, run:

```bash
python3 delphi-ai/deterministic/core/todo_completion_guard.py --todo <path-to-todo>
```

Or for batch validation of all active TODOs:

```bash
python3 delphi-ai/deterministic/core/todo_completion_guard.py --all-completed
```

## Exemptions

- Typo fixes (< 3 characters changed, no logic impact)
- Git configuration changes (`.gitignore`, branch settings)
- CI/CD pipeline adjustments that do not alter application behavior
