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
   - Any large or architectural change must explicitly record the required unit + widget + integration evidence matrix for the affected critical paths.
   - Every DoD/Validation item must have a planned evidence layer before delivery; every user-visible, interactive, or user-flow-impacting item must map to an integration/device test or navigation/browser test for that exact item, or to an explicit non-applicability rationale if it is structure-only.
   - User-flow impact is assessed case by case, not only by obvious visual wording. CRUD/mutation is a strong signal, but field refactors, DTO/domain/payload changes, validation, projections, query/filter semantics, settings/capabilities, read models, and persisted state changes require flow assessment when they can feed a screen or user journey.
   - In Flutter scope, `integration test` means device execution via ADB; `navigation/browser test` means Playwright against the final browser-facing domain after the current web bundle is published.
   - Classify flow-impacting Flutter behavior as `android-only`, `web-only`, `shared-android-web`, or `divergent-android-web`; shared behavior can close on either ADB integration or Playwright navigation, while divergent Android/Web behavior requires both lanes.
   - Browser/web-visible items must map to source-owned Playwright spec + runner evidence when the repo exposes a Playwright suite; for Flutter web, record the `tools/flutter/web_app_tests/**` spec and project-owned navigation runner after publishing the current checkout with the project-defined build/publish command from `foundation_documentation` or dependency-readiness notes and confirming the real browser-facing domain serves the refreshed bundle.
   - User-flow CRUD/mutation items must map to integration/device or navigation/browser evidence that performs the local mutation path against the approved non-main validation target.
   - Browser/web CRUD/mutation items must use the Playwright `mutation` lane on an approved non-`main` target; `readonly` Playwright is not mutation evidence.
   - Add a `Flow Evidence Planning Matrix` before `APROVADO` whenever touched surfaces could affect user flows; record the criterion, flow-impact reason, platform parity, required runtime lane, mutation requirement, real-backend requirement, planned evidence, and non-applicability rationale.
   - Add a `Local CI-Equivalent Suite Matrix` before `APROVADO` whenever the touched repositories have CI jobs/suites that will run for the slice. Record the exact repo-owned CI surface/job name, why it is in scope, the exact local command that mirrors it, and whether it must pass before local delivery or promotion. A TODO is not ready for `Local-Implemented`, `promotion_lane/`, or “promotable” claims until every in-scope row has been executed locally and passed. Targeted reruns are diagnostic only and do not replace this matrix.
   - Add a `Frontend / Consumer Matrix` before `APROVADO` whenever the TODO creates or changes backend endpoints, jobs, settings namespaces, payloads, schemas, projections, capabilities, read models, or other producer surfaces that could feed app/web/admin/operator behavior. For each producer, record the expected consumer (`Flutter`, `Web`, `Admin`, external integration, internal-only, or none), route/hub/visible action when applicable, DTO/repository/encoder/decoder path when applicable, planned render/discoverability evidence, planned request/readback evidence, and explicit waiver if no frontend consumer is required.
8. Run planning gates before approval:
   - **Plan Review Gate** for `medium|big` (or abbreviated for low-risk `small`);
   - additional bounded no-context architectural opinions when the path remains materially unclear;
   - deterministic audit-floor derivation via `wf-docker-audit-escalation-method` before trusting critique/test/final-review decisions.
   - independent no-context critique from the derived floor.
   - when the derived floor marks `triple_review` as `required|recommended`, use `audit-protocol-triple-review` as the canonical additive orchestration surface and record the audit session path plus clean/latest round evidence in the TODO.
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
   - **Completion Evidence Matrix**: one concrete evidence row for every `Definition of Done` item and every `Validation Steps` item;
   - `Local CI-Equivalent Suite Matrix`: every in-scope repo-owned CI suite/job that will run for the touched slice must have a locally executed passed row (or an explicit approved `n/a`/waiver with rationale when no CI surface truly applies). Targeted subset reruns alone do not satisfy TODO delivery or promotion readiness.
   - **Decision Adherence**;
   - module decision consistency;
   - security risk assessment;
   - performance/concurrency assessment;
   - validation steps;
   - `python3 delphi-ai/tools/todo_completion_guard.py <todo-path>` with `Overall outcome: go` before `Local-Implemented`, `promotion_lane/`, `completed/`, or `Production-Ready` claims;
   - rerun `wf-docker-audit-escalation-method` if trigger fields changed materially during implementation;
   - independent test-quality audit from the derived floor;
   - verification-debt audit when required;
   - independent no-context final review from the derived floor.
   - large or architectural changes cannot close on analyzer or unit/widget evidence alone; required integration lanes must be resolved first.
   - aggregate summaries cannot satisfy individual criteria; if a TODO names a UI control, route, endpoint, schema, migration, browser/device journey, integration test, or runtime target, the evidence row must name the same artifact or carry an explicit approved waiver/deviation.
   - code inspection, analyzer output, unit tests, widget tests, screenshots, and aggregate suite results are valid supporting implementation evidence, including for worker/subagent completion, but final orchestrator acceptance of user-visible/interactive/user-flow-impacting criteria requires item-specific integration/device evidence or navigation/browser evidence unless an approved structure-only waiver exists.
   - when Android and Web behavior is materially different, both ADB integration and Playwright navigation are required; when behavior is the same, either lane may satisfy final runtime acceptance.
   - browser/web-visible criteria cannot close without item-specific Playwright evidence when a Playwright suite exists; evidence must name the spec, runner command, target URL/lane, project-defined build/publish proof, and refreshed real-domain bundle provenance.
   - user-flow CRUD/mutation criteria cannot close from read-only navigation; they require evidence that the test executed the local mutation path on the approved non-main target.
   - browser/web CRUD/mutation criteria cannot close from `readonly` Playwright; they require the Playwright `mutation` lane on an approved non-`main` target.
   - non-visual refactors that change fields, DTOs, payloads, projections, validations, queries, settings, capabilities, or persisted state cannot close without either runtime flow evidence for the affected user journey or a recorded rationale proving no user-observable flow can change.
   - producer surfaces recorded in the `Frontend / Consumer Matrix` cannot close from backend evidence alone. Each row must have the declared consumer implemented and evidenced, or an explicit approved backend-only/internal-only/external-only waiver with rationale, owner, and follow-up if any.
   - when the derived floor uses the dedicated three-lane external audit loop, the governing evidence must come from `audit-protocol-triple-review` rather than ad hoc reviewer sequencing.
14. If pausing blocked, set `Blocked` explicitly with blocker notes and next exact step.
15. Before close, promote stable outcomes into canonical module docs; then move the same governing TODO to `promotion_lane/` when only lane follow-through remains. Use `github-stage-promotion-orchestrator` for `dev-only|through-stage` promotion and `github-main-promotion-orchestrator` only when the user explicitly requests `main`. Do not create a new tactical TODO solely for operational promotion follow-through unless the promotion process itself is the active requested work. Move the TODO to `completed/`/canceled once the final required lane threshold is complete.

## Outputs
- Updated TODO with clear contract, decision trace, plan, gates, and delivery evidence.
- Feature brief when required.
- Canonical module updates when stable truth changed.

## Non-Negotiables
- No implementation before `APROVADO`.
- No mixed-scope execution without TODO handoff trace.
- No durable truth left only in tactical notes after close.
- No TODO may silently absorb a new independently testable behavior or new approval conversation.
