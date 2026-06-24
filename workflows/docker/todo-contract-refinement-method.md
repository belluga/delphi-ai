---
description: Refine a tactical TODO into an executable contract with anchors, decisions, complexity, evidence planning, and consumer/runtime matrices.
---

# Method: TODO Contract Refinement

## Purpose
Turn a tactical TODO into an executable contract before approval. The TODO defines `WHAT`; this phase makes the decisions, assumptions, evidence plan, and execution boundaries explicit enough for safe implementation.

## Inputs
- Governing tactical TODO.
- Framing source or feature brief.
- Project `foundation_documentation`, module docs, scope/subscope policy, dependency-readiness/topology artifacts, and touched-surface workflows.

## Procedure
1. Align the TODO to the canonical status schema:
   - delivery stage, qualifiers, next exact step;
   - provisional/blocker fields;
   - promotion lane tracking when relevant.
2. Confirm canonical anchors:
   - primary and secondary module docs;
   - decision consolidation targets;
   - primary execution profile and active technical scope;
   - handoff log when profile boundaries are crossed.
3. Scan the TODO against module truth:
   - classify gaps as `Material Decision`, `Implementation Detail`, or `Redundant/Already Covered`;
   - convert only material items into `Decision Pending`;
   - build a module decision baseline snapshot when prior module decisions matter.
4. Classify complexity as `small|medium|big` and record checkpoint cadence.
5. Build `Assumptions Preview`.
   - Assumptions must be evidence-backed.
   - Promote an assumption into contract if it changes scope, DoD, validation semantics, public contract, or module coherence.
6. Build `Execution Plan`.
   - Record touched surfaces, ordered steps, test strategy, fail-first targets when required, and rollout/runtime notes.
   - For multi-TODO packages, subagent orchestration, or promotion-readiness loops, treat the execution plan as the package-stage ledger. Record wave state, current blockers, active review/remediation branches, and next exact step there instead of creating a parallel version-status artifact.
   - Keep per-finding accepted/challenged/resolved dispositions in the governing TODOs so carry-forward extraction remains authoritative.
7. Add planning matrices before approval when triggered:
   - `Flow Evidence Planning Matrix` for user-visible, interactive, or user-flow-impacting surfaces, including non-visual refactors that feed screens or journeys.
   - `Local CI-Equivalent Suite Matrix` for repo-owned CI suites/jobs that will run for the touched slice.
     - For each row, record the exact behavior/scenario the row is intended to prove.
     - Record the fixture/seed/runtime preconditions required for that behavior to be meaningfully exercised.
     - If the intended behavior cannot be proven with ambient data, add the deterministic bootstrap/seed/preparation step to the TODO instead of treating a generic suite pass as sufficient.
     - When user-visible behavior can be proven through navigation/browser or device runtime lanes, plan that stronger evidence by default.
     - If there is real ambiguity about what exact scenario must be proven, validate that expectation with the user before approval.
   - `Frontend / Consumer Matrix` for backend endpoints, jobs, settings namespaces, payloads, schemas, projections, capabilities, read models, webhooks, or other producer surfaces.

## Outputs
- TODO with refined contract, anchors, decisions, assumptions, plan, complexity, and required matrices.

## Non-Negotiables
- No guessed assumptions.
- No missing module anchors for touched durable contracts.
- No approval request while required matrices are missing.
- Targeted test reruns are diagnostic only and cannot replace the local CI-equivalent matrix.
