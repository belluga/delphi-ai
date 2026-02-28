---
name: rule-laravel-shared-todo-driven-execution-model-decision
description: "Rule: MUST use whenever the scope matches this purpose: Before implementation, require a tactical TODO and complete planning/adherence gates."
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

### Gate D — Complexity classification + checkpoint policy (mandatory)
- Classify the task as `small|medium|big` and record it in the TODO before implementation.

### Gate E — Plan Review Gate (mandatory for `medium|big`)
- Evaluate Architecture, Code Quality, Tests, Performance, and Security.
- Include issue cards with options `A/B/C`, tradeoff economics, recommendation, failure modes, and uncertainty register.

### Gate F — Decision baseline freeze (mandatory)
- Assign stable decision IDs (`D-01`, `D-02`, ...) and freeze approved decisions under `Decision Baseline (Frozen)` before implementation starts.

### Gate G — Explicit approval token (mandatory)
- After Gates A-F, Delphi must ask for explicit user approval of the TODO before any implementation begins.
- The approval token is: **APROVADO**.

### Gate H — Decision Adherence Gate (mandatory before delivery)
- Before delivery, build a `Decision Adherence Validation` table for every baseline decision ID.
- For each decision, record `status` (`Adherent` or `Exception`) and supporting evidence (`file:line`, test result, or doc contract).
- If any decision is `Exception`, delivery is invalid until the decision/baseline is updated and renewed **APROVADO** is obtained.

## Rationale
This prevents scope creep and "hub refactors" by forcing a written, reviewable contract with explicit risk framing and verifiable decision adherence before code is considered delivered.

## Enforcement
- Block implementation without TODO (unless exempt/ephemeral-eligible).
- Block implementation with unresolved COMMENT blocks.
- Block delivery if any baseline decision lacks adherence evidence.

## Notes
- Cline plans and recommendations are advisory by default; implementation authority remains Delphi TODO + **APROVADO** + Decision Adherence Gate.
