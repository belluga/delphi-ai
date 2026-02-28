---
description: Execute work via a tactical TODO in `foundation_documentation/todos/active/`, including mandatory planning and adherence gates before implementation and delivery.
---

# Method: TODO-Driven Execution

## Purpose
Guarantee every implementation starts from a concrete, reviewable contract (scope + DoD), with explicit risk framing, issue-level tradeoff analysis, and decision-adherence proof before delivery.

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
   - Restate the TODO in 1-2 lines.
   - Restate `scope`, `out_of_scope`, `definition_of_done`, and `validation_steps`.
5. **Classify complexity and checkpoint policy**
   - Classify as `small|medium|big` and record the level in the TODO.
   - Baseline policy:
     - `small`: lightweight, consolidated planning review.
     - `medium`: full Plan Review Gate + one checkpoint before approval.
     - `big`: full Plan Review Gate + section-by-section checkpoints.
   - If the scope grows, reclassify and update the TODO before proceeding.
6. **Raise missing decisions (refinement)**
   - Identify questions that would change implementation (UX, routes, contracts, data, privacy, fallbacks).
   - Add them under `questions_to_close` and propose options under `decisions` (A/B/C with clear impact).
   - Assign stable decision IDs (`D-01`, `D-02`, ...).
   - Iterate with the user until resolved; then update `decisions` with the chosen outcome.
7. **Freeze Decision Baseline (mandatory)**
   - Before implementation, freeze the approved decision IDs and expected outcomes under `Decision Baseline (Frozen)` in the TODO.
   - This baseline is the contract for adherence validation.
8. **Resolve COMMENT blocks (mandatory gate)**
   - Treat each **COMENTÁRIO:** / **COMMENT:** block as a question/consideration for the content immediately following it.
   - Resolve by updating the TODO (e.g., `decisions`, `scope`, `definition_of_done`) and then remove the comment block.
   - If resolution requires user input, stop and wait for confirmation before removing.
9. **Run Plan Review Gate (mandatory for `medium|big`)**
   - Evaluate Architecture, Code Quality, Tests, Performance, and Security.
   - For each material issue, document an issue card with:
     - `Issue ID`, severity, evidence (`file:line`), and why it matters now.
     - Options `A/B/C` (include **do nothing** when reasonable).
     - For each option: implementation effort, risk, blast radius, and maintenance burden.
     - Recommended option and rationale.
   - Add a `Failure Modes & Edge Cases` section.
   - Add an `Uncertainty Register` with assumptions, unknowns, and confidence.
   - `small` tasks can use a shortened version of this gate if risks are low and local.
10. **Request explicit approval**
   - Ask the user to reply with **APROVADO** to confirm the refined TODO and review outcome.
   - Do not implement anything until approval is received.
11. **Execute implementation**
   - Load the relevant stack workflows (Flutter/Laravel/etc.) and proceed with implementation strictly within `scope` and the frozen decision baseline.
12. **Decision Adherence Gate (mandatory before delivery)**
   - Build a `Decision Adherence Validation` table for every baseline decision ID.
   - For each decision, record: `status` (`Adherent` or `Exception`), evidence (`file:line`, test, or doc contract), and notes.
   - If any decision is `Exception`, block delivery and do one of:
     - Challenge the decision with explicit rationale, or
     - Propose a better alternative.
   - In either case, update the TODO decisions, refresh the frozen baseline, and request renewed **APROVADO** before proceeding.
13. **Validate**
   - Run the `validation_steps` from the TODO (or explicitly report what cannot be run and why).
14. **Close TODO**
   - Only mark delivery complete when all baseline decisions are `Adherent` or explicitly superseded via approved decision changes.
   - Update the TODO with outcome notes and move it to `foundation_documentation/todos/completed/` (or mark canceled).

## Outputs
- Updated TODO with resolved decisions and removed COMMENT blocks.
- Complexity classification and checkpoint policy recorded in the TODO.
- Plan Review Gate output (issue cards + failure modes + uncertainty register) for `medium|big` work.
- Decision baseline and decision-adherence validation table with evidence.
- Implementation changes aligned with the TODO's scope and DoD.

## Validation
- No implementation begins before COMMENT blocks are resolved.
- No `medium|big` implementation begins before Plan Review Gate is completed.
- No implementation begins before the user replies **APROVADO**.
- No delivery is considered complete while any baseline decision lacks adherence evidence.
- Implementation stays within `scope`; deviations require updating the TODO and re-confirmation.
