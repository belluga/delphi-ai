---
trigger: model_decision
description: "Before any implementation work (code/docs) that changes the project, require an explicit tactical TODO and complete planning/adherence gates."
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
- Ensure canonical module anchors are declared (`primary` module + optional `secondary` modules + promotion targets).
- Raise any missing questions/decisions that would materially change implementation, and update the TODO before proceeding.

### Gate C — COMMENT blocks (mandatory)
- Any block labeled **COMENTÁRIO:** (Portuguese) or **COMMENT:** (English) is treated as a contextual question/consideration about the content immediately following it.
- Do not start implementation until all COMMENT blocks are resolved.
- Resolution means: incorporate the outcome into the TODO (e.g., `decisions`, `scope`, `definition_of_done`) and remove the COMMENT block.
- If ambiguous, promote to `questions_to_close` and wait for user confirmation before removing.

### Gate D — Complexity classification + checkpoint policy (mandatory)
- Classify the task as `small|medium|big` and record it in the TODO before implementation.
- Baseline checkpoint cadence:
  - `small`: consolidated planning review.
  - `medium`: one review checkpoint before approval.
  - `big`: section-by-section review checkpoints.

### Gate E — Plan Review Gate (mandatory for `medium|big`)
- Evaluate Architecture, Code Quality, Tests, Performance, and Security.
- For each material issue, document:
  - `Issue ID`, severity, evidence (`file:line`), and why it matters now.
  - Options `A/B/C` (including **do nothing** when reasonable).
  - For each option: implementation effort, risk, blast radius, and maintenance burden.
  - Recommended option with rationale.
- Include `Failure Modes & Edge Cases` and an `Uncertainty Register` (`assumptions`, `unknowns`, `confidence`).
- `small` tasks can use a shortened version if risk is low and scope is local.

### Gate F — Decision baseline freeze (mandatory)
- Assign stable decision IDs (`D-01`, `D-02`, ...) and freeze approved decisions under `Decision Baseline (Frozen)` before implementation starts.

### Gate G — Explicit approval token (mandatory)
- After Gates A-F, Delphi must ask for explicit user approval of the TODO before any implementation begins.
- The approval token is: **APROVADO**.
- Until the user replies with **APROVADO** (case-insensitive), Delphi must not:
  - call `apply_patch`,
  - run write commands that change project files,
  - or make any project/submodule/code/docs modifications.

### Gate H — Decision Adherence Gate (mandatory before delivery)
- Before delivery, build a `Decision Adherence Validation` table for every baseline decision ID.
- For each decision, record `status` (`Adherent` or `Exception`) and supporting evidence (`file:line`, test result, or doc contract).
- If any decision is `Exception`, delivery is invalid until one of the following happens:
  - the decision is challenged with explicit rationale, or
  - a better alternative is proposed,
  and the TODO decisions/baseline are updated plus renewed **APROVADO** is obtained.

### Gate I — Delivery Confidence Gate (mandatory for `✅ Production-Ready`)
- Before marking any TODO as `✅ Production-Ready`, classify runtime impact (`none|low|medium|high`).
- If runtime-impacting, run and record operational confidence checks:
  - migration/index status;
  - queue/scheduler/worker health;
  - targeted load/perf sampling (or explicit N/A + reason);
  - smoke flow in the best available environment (or explicit N/A + reason).
- Store evidence artifacts in `foundation_documentation/artifacts/tmp/<run-id>/...`.
- Record confidence (`high|medium|low`) and residual risks.
- Record readiness outcome (`ready|ready_with_waiver|not_ready`).

### Gate J — Module Consolidation Gate (mandatory before closing TODO)
- Before moving a TODO to `completed`, promote stable conceptual outcomes and approved decisions into canonical module docs under `foundation_documentation/modules/`.
- Record promotion evidence in module decision/promotion sections and ensure TODO ↔ module cross-links are updated.
- If module docs still conflict with delivered implementation, TODO closure is blocked until conflicts are resolved or explicitly waived.

## Rationale
This prevents scope creep and "hub refactors" by forcing a written, reviewable contract with explicit risk framing and verifiable decision adherence before code is considered delivered.

## Enforcement
- If the user requests implementation without a TODO and the work is not exempt or eligible for the Ephemeral TODO flow, block and request the tactical TODO.
- If COMMENT blocks exist, block implementation until they are resolved and removed.
- If canonical module anchors are missing in the TODO, block implementation until anchors are added.
- If `medium|big` work does not contain Plan Review Gate output, block implementation and request completion.
- If any baseline decision lacks adherence evidence, block delivery.
- If module consolidation evidence is missing, block TODO closure.

## Notes
- This rule is stack-agnostic and applies to Flutter/Laravel/Web as long as the implementation changes project artifacts.
- Cline plans and recommendations are advisory by default; implementation authority remains the Delphi TODO + **APROVADO** + Decision Adherence Gate.
- After completion, the TODO should be moved to `foundation_documentation/todos/completed/` (or marked canceled).
