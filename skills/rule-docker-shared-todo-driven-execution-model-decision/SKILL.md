---
name: rule-docker-shared-todo-driven-execution-model-decision
description: "Rule: MUST use whenever the scope matches this purpose: Before starting any implementation work that changes project code, submodule code, or project-specific documentation (`foundation_documentation/`), Delphi must operate from a tactical TODO file under `foundation_documentation/todos/active/`."
---

## Rule
Before starting any implementation work that changes project code, submodule code, or project-specific documentation (`foundation_documentation/`), Delphi must operate from a tactical TODO file under `foundation_documentation/todos/active/`, except for the exemptions and Maintenance/Regression Fix flow below.

### Exemptions (no TODO required)
- Edits limited to `.agent/**` (local run logs/checklists).
- Edits limited to `foundation_documentation/todos/**` (creating/updating TODOs themselves).

### Maintenance/Regression Fix Flow (Ephemeral TODO)
If the change restores previously documented or verifiably working behavior (including test failures), Delphi may use a local-only TODO in `foundation_documentation/todos/ephemeral/` and still require **APROVADO** before changes. Eligibility:
- Must restore previously documented behavior or a known working baseline; reference the evidence in the TODO (doc/test/issue/prior commit).
- No net-new features and no API/contract/schema changes. If contracts must change or new behavior is added, use the full tactical TODO gate.
- Documentation updates are **not** required if the existing docs already match the intended behavior. If docs are missing or incorrect, use a tactical TODO and update docs first.
- Any files may be touched if necessary to restore the known behavior.
- Ephemeral TODOs are local-only and should not be committed. Keep the folder in git via `.gitkeep`, and add a `.gitignore` in `foundation_documentation/todos/ephemeral/` that ignores all other files.

### Gate A — TODO existence
- If no relevant TODO exists, do not start implementation.
- Ask the user to create one (or ask permission to draft one), then proceed only after the TODO is present.

### Gate B — TODO refinement (no code)
- Read the TODO.
- Summarize `scope`, `out_of_scope`, `definition_of_done`, and `validation_steps`.
- Raise any missing questions/decisions that would materially change implementation, and update the TODO before proceeding.

### Gate C — COMMENT blocks (mandatory)
- Any block labeled **COMENTÁRIO:** (Portuguese) or **COMMENT:** (English) is treated as a contextual question/consideration about the content immediately following it.
- Do not start implementation until all COMMENT blocks are resolved.
- Resolution means: incorporate the outcome into the TODO (e.g., `decisions`, `scope`, `definition_of_done`) and remove the COMMENT block.
- If ambiguous, promote to `questions_to_close` and wait for user confirmation before removing.

### Gate D — Explicit approval token (mandatory)
- After Gates A–C, Delphi must ask for explicit user approval of the TODO before any implementation begins.
- The approval token is: **APROVADO**.
- Until the user replies with **APROVADO** (case-insensitive), Delphi must not:
  - call `apply_patch`,
  - run write commands that change project files,
  - or make any project/submodule/code/docs modifications.

## Rationale
This prevents scope creep and “hub refactors” by forcing a written, reviewable contract (scope + DoD) that must be validated before code begins.

## Enforcement
- If the user requests implementation without a TODO and the work is not exempt or eligible for the Ephemeral TODO flow, block and request the tactical TODO.
- If COMMENT blocks exist, block implementation until they are resolved and removed.

## Notes
- This rule is stack-agnostic and applies to Flutter/Laravel/Web as long as the implementation changes project artifacts.
- After completion, the TODO should be moved to `foundation_documentation/todos/completed/` (or marked canceled).
