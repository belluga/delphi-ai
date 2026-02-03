---
description: Execute work via a tactical TODO in `foundation_documentation/todos/active/`, including mandatory refinement and COMMENT resolution before implementation.
---

# Method: TODO-Driven Execution

## Purpose
Guarantee every implementation starts from a concrete, reviewable contract (scope + DoD) and that any contextual comments are resolved before coding.

## Triggers
- The user asks for feature work, bugfixes, refactors, or documentation updates that change project artifacts.

## Inputs
- A TODO file under `foundation_documentation/todos/active/`, or an ephemeral TODO under `foundation_documentation/todos/ephemeral/` when eligible.

## Procedure
1. **Determine which lane applies**
   - If changes are limited to `.agent/**` or `foundation_documentation/todos/**`, proceed without a TODO and still describe intent + results in your response.
   - If the work qualifies for the Maintenance/Regression Fix flow, use the corresponding lane below.
   - Otherwise, use the full tactical TODO lane.
2. **Maintenance/Regression Fix lane (Ephemeral TODO)**
   - Confirm eligibility: restore previously documented or verifiably working behavior (including test failures); no net-new features and no API/contract/schema changes.
   - If documentation must change because the existing docs are missing or incorrect, use the tactical TODO lane instead.
   - Ensure `foundation_documentation/todos/ephemeral/` contains `.gitkeep` and a `.gitignore` that ignores all other files.
   - Create a short TODO in `foundation_documentation/todos/ephemeral/` capturing `scope`, `out_of_scope`, `definition_of_done`, `validation_steps`, and the **evidence** (doc/test/issue/prior commit) that proves the expected behavior.
   - Request **APROVADO** before any change.
   - Execute within scope, validate, and leave the ephemeral TODO as a local-only record (do not commit).
3. **Tactical TODO lane (default)**
   - Find the relevant TODO in `foundation_documentation/todos/active/`.
   - If none exists, ask the user to create one or ask permission to draft one.
4. **Read and restate**
   - Restate the TODO in 1–2 lines.
   - Restate `scope`, `out_of_scope`, `definition_of_done`, and `validation_steps`.
5. **Raise missing decisions (refinement)**
   - Identify questions that would change implementation (UX, routes, contracts, data, privacy, fallbacks).
   - Add them under `questions_to_close` and propose options under `decisions` (A/B with short impact).
   - Iterate with the user until resolved; then update `decisions` with the chosen outcome.
6. **Resolve COMMENT blocks (mandatory gate)**
   - Treat each **COMENTÁRIO:** / **COMMENT:** block as a question/consideration for the content immediately following it.
   - Resolve by updating the TODO (e.g., `decisions`, `scope`, `definition_of_done`) and then remove the comment block.
   - If resolution requires user input, stop and wait for confirmation before removing.
7. **Request explicit approval**
   - Ask the user to reply with **APROVADO** to confirm the refined TODO.
   - Do not implement anything until approval is received.
8. **Execute implementation**
   - Load the relevant stack workflows (Flutter/Laravel/etc.) and proceed with implementation strictly within `scope`.
9. **Validate**
   - Run the `validation_steps` from the TODO (or explicitly report what cannot be run and why).
10. **Close TODO**
   - Update the TODO with outcome notes and move it to `foundation_documentation/todos/completed/` (or mark canceled).

## Outputs
- Updated TODO with resolved decisions and removed COMMENT blocks.
- Implementation changes aligned with the TODO’s scope and DoD.

## Validation
- No implementation begins before COMMENT blocks are resolved.
- No implementation begins before the user replies **APROVADO**.
- Implementation stays within `scope`; deviations require updating the TODO and re-confirmation.
