---
name: wf-docker-todo-driven-execution-method
description: "Workflow: MUST use whenever the scope matches this purpose: Execute implementation through a tactical TODO with mandatory planning and decision-adherence gates before delivery."
---

# Method: TODO-Driven Execution

## Purpose
Guarantee every implementation starts from a concrete, reviewable contract (scope + DoD), with explicit risk framing, issue-level tradeoff analysis, module-first coherence proof, and decision-adherence proof before delivery.

## Triggers
- The user asks for feature work, bugfixes, refactors, or documentation updates that change project artifacts.

## Inputs
- A TODO file under `foundation_documentation/todos/active/`, or an ephemeral TODO under `foundation_documentation/todos/ephemeral/` when eligible.

## Procedure
1. **Determine which lane applies**
   - If changes are limited to `foundation_documentation/artifacts/tmp/**` or `foundation_documentation/todos/**`, proceed without a TODO and still describe intent + results in your response.
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
5. **Confirm canonical module anchors (mandatory)**
   - Ensure the TODO declares canonical module anchors:
     - primary module doc under `foundation_documentation/modules/`;
     - secondary module docs (if any);
     - planned promotion targets (where stable outcomes will be consolidated).
     - module decision consolidation targets (sections where approved decisions will be persisted).
   - If anchors are missing, block implementation and update the TODO first.
6. **Classify complexity and checkpoint policy**
   - Classify as `small|medium|big` and record the level in the TODO.
   - Baseline policy:
     - `small`: lightweight, consolidated planning review.
     - `medium`: full Plan Review Gate + one checkpoint before approval.
     - `big`: full Plan Review Gate + section-by-section checkpoints.
   - If the scope grows, reclassify and update the TODO before proceeding.
7. **Run module-first TODO scan and raise pending decisions (refinement)**
   - Treat canonical module docs declared in the TODO anchors as the architectural source of truth; the TODO is the execution contract and cannot be refined in isolation.
   - Start with one broad scan of the TODO against the canonical module anchors (`primary` + `secondary`) for:
     - gaps,
     - conflicts,
     - ambiguities,
     - uncovered behavior,
     - or validation/DoD statements that are not yet coherent with the module contract.
   - Triage every finding into one of three buckets:
     - `Material Decision`: affects contract, scope, module coherence, UX semantics, public package/API surface, validation semantics, rollout risk, or could reasonably cause meaningful rework if assumed incorrectly.
     - `Implementation Detail`: local execution choice that can be resolved autonomously without changing the approved contract/module semantics.
     - `Redundant/Already Covered`: already implied by frozen/approved decisions or by the canonical module contract and must not be reopened as a new user-facing decision.
   - Convert only `Material Decision` findings into `Decision Pending` entries (or the TODO's equivalent pending-decision section). Do not promote `Implementation Detail` or `Redundant/Already Covered` items into user-facing decision churn.
   - Resolve `Implementation Detail` findings autonomously and record them in the TODO only when traceability helps execution or later review.
   - Group related material findings by theme when possible and bring only the smallest set of decisions needed to unblock implementation readiness. Avoid serial one-by-one questioning for minor details.
   - For each material pending decision, propose concrete options (A/B/C with clear impact), assign stable decision IDs (`D-01`, `D-02`, ...), and resolve them with the user.
   - Build a `Module Decision Baseline Snapshot` from relevant prior decisions in canonical module anchors and reference those entries from TODO pending/frozen decisions (or explicitly mark `No Prior Decision` when applicable).
   - After each approval, consolidate the result back into the TODO and, when the module contract is being superseded or clarified, update the module doc or explicitly record the required module promotion target before implementation.
   - Stop escalating new decisions once the remaining findings are implementation-local and module-coherent.
   - Do not proceed while material pending decisions remain unresolved.
8. **Freeze Decision Baseline (mandatory)**
   - Before implementation, freeze the approved decision IDs and expected outcomes under `Decision Baseline (Frozen)` in the TODO.
9. **Run Module Coherence Gate (mandatory before approval)**
   - Compare each frozen `D-xx` decision against canonical module docs (`primary` + `secondary` anchors).
   - Record per decision in the TODO:
     - `Module Coherence`: `Aligned|Conflict|Supersede`
     - `Change Intent`: `Preserve|Supersede`
     - Evidence (`file:line|section`) for the compared module rule/decision.
   - The coherence reference is always the canonical module docs, never the TODO text alone.
   - Produce a `Module Decision Consistency Matrix` (1-1) for relevant module decisions with planned handling: `Preserve|Supersede (Intentional)|Out of Scope`, plus evidence.
   - Block implementation while any decision is `Conflict`.
   - If `Supersede`, capture why replacement is needed, the target module section update, and require explicit approval before implementation.
   - Any unintended divergence from relevant module decisions blocks implementation.
10. **Resolve COMMENT blocks (mandatory gate)**
   - Treat each **COMENTÁRIO:** / **COMMENT:** block as a question/consideration for the content immediately following it.
   - Resolve by updating the TODO (e.g., `decisions`, `scope`, `definition_of_done`) and then remove the comment block.
   - If resolution requires user input, stop and wait for confirmation before removing.
11. **Run Plan Review Gate (mandatory for `medium|big`)**
   - Evaluate Architecture, Code Quality, Tests, Performance, and Security.
   - For each material issue, document an issue card with:
     - `Issue ID`, severity, evidence (`file:line`), and why it matters now.
     - Options `A/B/C` (include **do nothing** when reasonable).
     - For each option: implementation effort, risk, blast radius, and maintenance burden.
     - Recommended option and rationale.
   - Add a `Failure Modes & Edge Cases` section.
   - Add an `Uncertainty Register` with assumptions, unknowns, and confidence.
12. **Request explicit approval**
   - Ask the user to reply with **APROVADO** to confirm the refined TODO and review outcome.
   - Do not implement anything until approval is received.
13. **Execute implementation**
   - Load the relevant stack workflows (Flutter/Laravel/etc.) and proceed with implementation strictly within `scope` and the frozen decision baseline.
14. **Decision Adherence Gate (mandatory before delivery)**
   - Build a `Decision Adherence Validation` table for every baseline decision ID.
   - For each decision, record: `status` (`Adherent` or `Exception`), evidence (`file:line`, test, or doc contract), and notes.
   - Build a `Module Decision Consistency Validation` table (1-1) for relevant module decisions with delivery status: `Preserved|Superseded (Approved)|Regression`.
   - If any decision is `Exception`, block delivery, update decisions/baseline, and request renewed **APROVADO** before continuing.
   - If any module decision is `Regression`, block delivery until an explicit supersede decision is approved and module consolidation targets are updated.
15. **Delivery Confidence Gate (mandatory for `✅ Production-Ready`)**
   - Classify runtime impact (`none|low|medium|high`).
   - If runtime-impacting, run operational confidence checks and capture evidence:
     - migration/index status;
     - queue/scheduler/worker health;
     - targeted load/perf sampling (or explicit N/A + reason);
     - smoke flow in the best available environment (or explicit N/A + reason).
   - Record artifacts under `foundation_documentation/artifacts/tmp/<run-id>/...`.
   - Record a confidence statement (`high|medium|low`) plus residual risks.
   - Mark release readiness outcome: `ready|ready_with_waiver|not_ready`.
16. **Validate**
   - Run the `validation_steps` from the TODO (or explicitly report what cannot be run and why).
17. **Module Consolidation Gate (mandatory before close)**
   - Promote stable conceptual outcomes and finalized decisions from the TODO into canonical module docs.
   - Update module decision/promotion ledgers with traceability to this TODO.
   - Remove/replace superseded tactical notes that conflict with canonical module docs.
   - Update TODO/module cross-links if files moved from `active` to `completed`.
18. **Close TODO**
   - Only mark delivery complete when all baseline decisions are `Adherent` or explicitly superseded via approved decision changes.
   - Update the TODO with outcome notes and move it to `foundation_documentation/todos/completed/` (or mark canceled).

## Outputs
- Updated TODO with resolved decisions and removed COMMENT blocks.
- TODO with canonical module anchors recorded.
- TODO scan results triaged into material decisions vs implementation-local findings, with module-based coherence evidence.
- Complexity classification and checkpoint policy recorded in the TODO.
- Decision baseline and decision-adherence validation table with evidence.
- Module coherence matrix per decision (`Aligned|Conflict|Supersede` + `Preserve|Supersede`) with evidence.
- Module decision baseline snapshot + 1-1 consistency matrices (planned and delivered) with evidence.
- Canonical module docs updated with promoted stable outcomes and decision traceability.
- Implementation changes aligned with the TODO's scope and DoD.

## Validation
- No implementation begins before COMMENT blocks are resolved.
- No implementation begins without canonical module anchors in the TODO.
- No implementation begins while material pending decisions from the module-first TODO scan remain unresolved.
- No implementation begins while redundant/already-covered or implementation-local details are still being treated as pending user decisions.
- No implementation begins while any frozen decision remains in `Conflict` with canonical module docs.
- No implementation begins before a module decision consistency matrix (1-1) is recorded for relevant module decisions.
- No implementation begins before the user replies **APROVADO**.
- No delivery is considered complete while any baseline decision lacks adherence evidence.
- No delivery is considered complete while any relevant module decision is in `Regression`.
- No TODO can be marked `✅ Production-Ready` without a completed Delivery Confidence Gate (or explicit waiver rationale).
- No TODO can be closed as completed before module consolidation evidence is recorded.
