---
name: rule-docker-shared-todo-driven-execution-model-decision
description: "Rule: MUST use whenever the scope matches this purpose: Before implementation, require a tactical TODO and complete planning/adherence gates."
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
- Treat canonical module docs as the coherence authority, not the TODO text alone.
- Start with one broad scan of the TODO against those module anchors for gaps, conflicts, ambiguities, uncovered behavior, and missing validation/DoD alignment.
- Triage findings into:
  - `Material Decision`: contract/scope/module/UX/package-surface/validation-semantics/rollout-risk issues that need user confirmation.
  - `Implementation Detail`: local execution choices Delphi can resolve autonomously without changing the approved contract.
  - `Redundant/Already Covered`: issues already settled by the module contract or previously approved decisions and therefore not eligible to be reopened as pending questions.
- Convert only `Material Decision` findings into `Decision Pending` entries (or equivalent pending-decision section).
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

### Gate E — Plan Review Gate (mandatory for `medium|big`)
- Evaluate Architecture, Code Quality, Tests, Performance, and Security.
- Include issue cards with options `A/B/C`, tradeoff economics, recommendation, failure modes, and uncertainty register.

### Gate F — Decision baseline freeze (mandatory)
- Assign stable decision IDs (`D-01`, `D-02`, ...) and freeze approved decisions under `Decision Baseline (Frozen)` before implementation starts.

### Gate F2 — Module Coherence Gate (mandatory before approval)
- Compare every frozen decision (`D-xx`) against canonical module docs declared in the TODO anchors.
- Record per decision:
  - `Module Coherence`: `Aligned|Conflict|Supersede`
  - `Change Intent`: `Preserve|Supersede`
  - evidence to module source (`file:line` or section).
- The coherence reference is always the canonical module docs, never the TODO text alone.
- Block implementation while any decision remains `Conflict`.
- If any decision is `Supersede`, explicit approval is required and the TODO must include planned module update targets before coding.

### Gate G — Explicit approval token (mandatory)
- After Gates A-F, Delphi must ask for explicit user approval of the TODO before any implementation begins.
- The approval token is: **APROVADO**.

### Gate H — Decision Adherence Gate (mandatory before delivery)
- Before delivery, build a `Decision Adherence Validation` table for every baseline decision ID.
- For each decision, record `status` (`Adherent` or `Exception`) and supporting evidence (`file:line`, test result, or doc contract).
- If any decision is `Exception`, delivery is invalid until the decision/baseline is updated and renewed **APROVADO** is obtained.

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
- Block implementation without TODO (unless exempt/ephemeral-eligible).
- Block implementation with unresolved COMMENT blocks.
- Block implementation when canonical module anchors are missing from the TODO.
- Block implementation when material pending decisions from the module-first TODO scan remain unresolved.
- Block implementation when redundant/already-covered or implementation-local details are still being treated as pending user decisions.
- Block implementation when any frozen decision is `Conflict` against canonical module docs.
- Block delivery if any baseline decision lacks adherence evidence.
- Block `✅ Production-Ready` status without Delivery Confidence Gate evidence (or explicit waiver rationale).
- Block TODO closure when module consolidation evidence is missing.

## Notes
- Cline plans and recommendations are advisory by default; implementation authority remains Delphi TODO + **APROVADO** + Decision Adherence Gate.
