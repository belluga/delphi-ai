---
trigger: model_decision
description: "Before any implementation work (code/docs) that changes the project, require an explicit tactical TODO and complete planning/adherence gates."
---


## Rule
Before starting any implementation work that changes project code, submodule code, or project-specific documentation (`foundation_documentation/`), Delphi must operate from a tactical TODO file under `foundation_documentation/todos/active/`, except for the exemptions and Maintenance/Regression Fix flow below.

### Exemptions (no TODO required)
- Edits limited to `foundation_documentation/artifacts/tmp/**` (local run logs/checklists).
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
- Ensure module decision consolidation targets are declared (where approved decisions will be persisted in canonical module docs).
- Treat canonical module docs as the coherence authority, not the TODO text alone.
- Start with one broad scan of the TODO against those module anchors for gaps, conflicts, ambiguities, uncovered behavior, and missing validation/DoD alignment.
- Triage findings into:
  - `Material Decision`: contract/scope/module/UX/package-surface/validation-semantics/rollout-risk issues that need user confirmation.
  - `Implementation Detail`: local execution choices Delphi can resolve autonomously without changing the approved contract.
  - `Redundant/Already Covered`: issues already settled by the module contract or previously approved decisions and therefore not eligible to be reopened as pending questions.
- Convert only `Material Decision` findings into `Decision Pending` entries (or equivalent pending-decision section).
- Build a `Module Decision Baseline Snapshot` from relevant existing module decisions and reference those entries from TODO pending/frozen decisions (or explicitly mark `No Prior Decision`).
- Resolve implementation details autonomously and record them in the TODO only when traceability is useful.
- Group related material decisions by theme when possible and avoid serial one-by-one questioning for minor details.
- Stop escalating new decisions once the remaining findings are implementation-local and module-coherent.

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

### Gate G — Module coherence gate (mandatory before implementation)
- Compare each frozen decision against the canonical module anchors declared in the TODO (`primary` + `secondary`).
- Record per decision whether it is `Aligned`, `Conflict`, or `Supersede` with evidence (`file:line|section`).
- Produce a `Module Decision Consistency Matrix` (1-1) for relevant module decisions with planned handling: `Preserve|Supersede (Intentional)|Out of Scope`, with evidence.
- The coherence reference is always the canonical module docs, never the TODO text alone.
- If any decision is `Conflict`, block implementation until TODO/module decisions are reconciled and re-approved.
- If any module decision has unintended divergence, block implementation until it is either preserved or explicitly approved for supersede.

### Gate H — Explicit approval token (mandatory)
- After Gates A-G, Delphi must ask for explicit user approval of the TODO before any implementation begins.
- The approval token is: **APROVADO**.
- Until the user replies with **APROVADO** (case-insensitive), Delphi must not:
  - call `apply_patch`,
  - run write commands that change project files,
  - or make any project/submodule/code/docs modifications.

### Gate I — Decision Adherence Gate (mandatory before delivery)
- Before delivery, build a `Decision Adherence Validation` table for every baseline decision ID.
- For each decision, record `status` (`Adherent` or `Exception`) and supporting evidence (`file:line`, test result, or doc contract).
- Before delivery, build a `Module Decision Consistency Validation` table (1-1) for relevant module decisions with delivery status: `Preserved|Superseded (Approved)|Regression`.
- If any decision is `Exception`, delivery is invalid until one of the following happens:
  - the decision is challenged with explicit rationale, or
  - a better alternative is proposed,
  and the TODO decisions/baseline are updated plus renewed **APROVADO** is obtained.
- If any module decision is `Regression`, delivery is invalid until an intentional supersede is approved and reflected in module consolidation targets.

### Gate J — Delivery Confidence Gate (mandatory for `✅ Production-Ready`)
- Before marking any TODO as `✅ Production-Ready`, classify runtime impact (`none|low|medium|high`).
- If runtime-impacting, run and record operational confidence checks:
  - migration/index status;
  - queue/scheduler/worker health;
  - targeted load/perf sampling (or explicit N/A + reason);
  - smoke flow in the best available environment (or explicit N/A + reason).
- Store evidence artifacts in `foundation_documentation/artifacts/tmp/<run-id>/...`.
- Record confidence (`high|medium|low`) and residual risks.
- Record readiness outcome (`ready|ready_with_waiver|not_ready`).

### Gate K — Module Consolidation Gate (mandatory before closing TODO)
- Before moving a TODO to `completed`, promote stable conceptual outcomes and approved decisions into canonical module docs under `foundation_documentation/modules/`.
- Record promotion evidence in module decision/promotion sections and ensure TODO ↔ module cross-links are updated.
- If module docs still conflict with delivered implementation, TODO closure is blocked until conflicts are resolved or explicitly waived.

## Rationale
This prevents scope creep and "hub refactors" by forcing a written, reviewable contract with explicit risk framing and verifiable decision adherence before code is considered delivered.

## Enforcement
- If the user requests implementation without a TODO and the work is not exempt or eligible for the Ephemeral TODO flow, block and request the tactical TODO.
- If COMMENT blocks exist, block implementation until they are resolved and removed.
- If canonical module anchors are missing in the TODO, block implementation until anchors are added.
- If material pending decisions from the module-first TODO scan remain unresolved, block implementation.
- If redundant/already-covered or implementation-local details are still being treated as pending user decisions, block implementation until the TODO is triaged correctly.
- If any frozen decision conflicts with canonical module docs, block implementation until coherence is resolved.
- If the module decision consistency matrix (1-1) is missing, block implementation.
- If `medium|big` work does not contain Plan Review Gate output, block implementation and request completion.
- If any baseline decision lacks adherence evidence, block delivery.
- If any relevant module decision ends in `Regression`, block delivery.
- If module consolidation evidence is missing, block TODO closure.

## Notes
- This rule is stack-agnostic and applies to Flutter/Laravel/Web as long as the implementation changes project artifacts.
- Cline plans and recommendations are advisory by default; implementation authority remains the Delphi TODO + **APROVADO** + Decision Adherence Gate.
- After completion, the TODO should be moved to `foundation_documentation/todos/completed/` (or marked canceled).
