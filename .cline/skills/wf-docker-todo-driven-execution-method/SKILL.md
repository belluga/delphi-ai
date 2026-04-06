---
name: wf-docker-todo-driven-execution-method
description: "Workflow: MUST use whenever the scope matches this purpose: Execute work via a tactical TODO in `foundation_documentation/todos/active/`, including planning, approval, execution, and delivery gates."
---

# Method: TODO-Driven Execution

Use this skill as the operational entrypoint for the canonical workflow in `workflows/docker/todo-driven-execution-method.md`.
This skill is intentionally concise; the workflow file remains the detailed source for edge cases and full gate language.

## Purpose
Govern TODO use across profiles without collapsing no-code ledgers into tactical implementation contracts.

For operational implementation, the tactical TODO defines `WHAT` must be delivered and what counts as done.
Assumptions, execution planning, and gates define `HOW` the work will be delivered and verified.

## Triggers
- The user asks for feature work, bugfixes, refactors, or project-doc changes that alter project artifacts.

## Inputs
- Tactical TODO under `foundation_documentation/todos/active/`, or ephemeral TODO under `foundation_documentation/todos/ephemeral/` when the maintenance/regression lane applies.
- `Feature Brief / Story Decomposition` under `foundation_documentation/artifacts/feature-briefs/` when pre-TODO framing is required or intentionally chosen.
- Dependency readiness register when external systems materially affect execution.

## Procedure
1. Classify the lane first:
   - `Profile-Scoped Capped TODO` for no-code Genesis/Strategic ledgers.
   - `Operational Micro-Fix` for tiny local operational changes with no product/test/doc impact.
   - `Maintenance/Regression Fix` for restoring previously documented behavior via disposable ephemeral TODO.
   - Otherwise, use the full tactical TODO lane.
2. Before treating a tactical TODO as executable authority, decide whether the work is already one bounded execution slice.
   - For `medium|big` work that is not already one bounded slice, and for materially ambiguous work of any size, run pre-TODO framing first.
   - `Direct-to-TODO` is acceptable only when the work is already one primary story/value slice with low ambiguity and one approval conversation.
   - Otherwise, create/update a lightweight `Feature Brief / Story Decomposition` using `templates/feature_brief_template.md`.
3. Align the TODO to the canonical schema and restate:
   - framing source / story slice;
   - scope / out-of-scope / DoD / validation steps;
   - delivery stage / qualifiers / next exact step;
   - blocker state when applicable.
4. Confirm canonical anchors and execution trace:
   - primary/secondary modules;
   - decision-consolidation targets;
   - primary execution profile;
   - active technical scope;
   - handoff log when crossing profile boundaries.
5. Run TODO refinement against module truth:
   - scan for gaps/conflicts/ambiguities;
   - triage into `Material Decision`, `Implementation Detail`, or `Redundant/Already Covered`;
   - convert only material items into `Decision Pending`;
   - freeze approved decisions before implementation.
6. Classify complexity and size the TODO correctly:
   - the TODO should stay one primary story slice with one primary user/value objective;
   - one primary module and one approval/review/promotion cycle are strong sizing heuristics, not automatic split triggers when the slice is still cohesive;
   - if multiple independently testable story slices or multiple approval conversations appear, split or narrow the TODO.
   - record the **complexity policy** in the TODO (`small|medium|big` + checkpoint cadence).
7. Build `Assumptions Preview` and `Execution Plan`.
   - Assumptions must be evidence-backed, not guesses.
   - Promote an assumption into contract if it changes scope, DoD, required validation semantics, public contract, or module coherence.
   - Record touched surfaces, ordered steps, test strategy, fail-first targets when required, and rollout/runtime notes.
8. Run planning gates before approval:
   - **Plan Review Gate** for `medium|big` (or abbreviated for low-risk `small`);
   - additional bounded no-context architectural opinions when the path remains materially unclear;
   - independent no-context critique when required by complexity/impact.
   - When subagents are used programmatically for those opinions/reviews, prefer derived dispatch/merge packets from `subagent_review_dispatch.py` and `subagent_review_merge.py`.
9. Freeze the approved decisions under **Decision Baseline (Frozen)** before implementation.
10. Ask for explicit `APROVADO`.
   - No implementation starts before approval.
11. After approval, ingest the real governing rules/workflows for the touched surfaces.
   - Run the profile scope check and compare review-required paths against the TODO handoff log.
12. Execute within the approved boundary.
   - TODOs are `bounded but elastic`: local blockers and small concretization work may stay inside the TODO while they remain within the same objective and approval conversation.
   - If execution reveals a new independently testable behavior, a new primary objective, or a new approval/risk conversation, update or split the TODO and obtain renewed approval.
13. Before delivery, complete the required gates:
   - **Decision Adherence**;
   - module decision consistency;
   - security risk assessment;
   - performance/concurrency assessment;
   - validation steps;
   - independent test-quality audit when required;
   - verification-debt audit when required;
   - independent no-context final review when required.
14. If pausing blocked, set `Blocked` explicitly with blocker notes and next exact step.
15. Before close, promote stable outcomes into canonical module docs and then move the TODO to completed/canceled.

## Outputs
- Updated TODO with clear contract, decision trace, plan, gates, and delivery evidence.
- Feature brief when required.
- Canonical module updates when stable truth changed.

## Non-Negotiables
- No implementation before `APROVADO`.
- No mixed-scope execution without TODO handoff trace.
- No durable truth left only in tactical notes after close.
- No TODO may silently absorb a new independently testable behavior or new approval conversation.
