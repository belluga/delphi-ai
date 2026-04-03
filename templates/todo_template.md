# Template: Tactical TODO (Active)

Use this file as a starting point for `foundation_documentation/todos/active/<short_slug>.md`.
Do not create TODOs from scratch; always copy this template first.

## Quick Start
```bash
cp delphi-ai/templates/todo_template.md foundation_documentation/todos/active/<lane>/<TODO-name>.md
```

## Title
<Short, specific title>

## Context
<Why this matters and where it appears in the product>

## Contract Boundary
- This TODO defines **WHAT** must be delivered and what counts as done.
- `Assumptions Preview` and `Execution Plan` below define **HOW** Delphi currently intends to deliver this contract.
- If any assumption or plan step changes `Scope`, `Out of Scope`, `Definition of Done`, `Validation Steps`, public contract, or frozen decisions, update the TODO contract first and request renewed approval before execution continues.

## Delivery Status Canon (Required)
- **Current delivery stage:** `<Pending|Local-Implemented|Lane-Promoted|Production-Ready>`
- **Qualifiers:** `<none|Provisional|Blocked|Provisional+Blocked>`
- **Next exact step:** <Immediate next action required to move the TODO forward>

## Scope
- [ ] <What will be done>

## Delivery Status Semantics
- `Pending`: no meaningful delivery milestone has been reached yet.
- `Local-Implemented`: work is implemented in a local branch and validated locally.
- `Lane-Promoted`: work has been merged through the declared lane threshold (usually `dev`).
- `Production-Ready`: final required lane threshold is complete and confidence gates are satisfied.
- `Provisional`: delivery is intentionally partial/incomplete but useful for unblocking dependent work.
- `Blocked`: work cannot currently proceed; `Blocker Notes` become mandatory.

## Provisional Notes (Required if `Qualifiers` includes `Provisional`)
- **Missing for production-ready:** <What is intentionally incomplete>
- **Revisit criteria:** <What must be done to exit provisional>
- **Dependencies unblocked:** <What work can now proceed>

## Blocker Notes (Required if `Qualifiers` includes `Blocked`)
- **Blocker:** <Concrete blocker>
- **Why blocked now:** <Why the TODO cannot currently progress>
- **What unblocks it:** <Decision, dependency, fix, or evidence needed>
- **Owner / source:** <Who or what controls the unblocker>
- **Last confirmed truth:** <What is already confirmed and should not be re-investigated from scratch>

## Execution Lane Tracking (Required)
- **Local implementation branches:** `<repo>:<branch>`, `<repo>:<branch>`
- **Promotion lane path:** `<dev -> stage -> main>` or `<dev -> stage>`
- **Lane-promoted threshold for this TODO:** `<usually dev>`
- **Production-ready threshold for this TODO:** `<usually stage or main>`

## Promotion Evidence (Required Before `🟣 Lane-Promoted` / `✅ Production-Ready`)
| Scope Item | Local Branch/Commit | PR to lane threshold | PR to `stage` | PR to `main` | Current Status |
| --- | --- | --- | --- | --- | --- |
| `<item>` | `<branch@sha>` | `<url or pending>` | `<url or n/a>` | `<url or n/a>` | `<status>` |

## Out of Scope
- [ ] <What will NOT be done>

## Definition of Done
- [ ] <Concrete, testable checklist item>

## Validation Steps
- [ ] <Command, test flow, or manual validation step>

## Profile Scope & Handoffs (Required Before `APROVADO`)
- **Primary execution profile:** `<genesis-product-bootstrap|strategic-cto|operational-coder|operational-devops|assurance-tester-quality|assurance-security-adversarial>`
- **Active technical scope:** `<flutter|laravel|web|docker|cross-stack|delphi-self-maintenance>`
- **Expected supporting profiles:** `<none|profile ids>`
- **Scope-check command:** `python3 delphi-ai/tools/profile_scope_check.py --profile <profile-id>`

### Handoff Log (Update when execution crosses profile boundaries)
| From Profile | To Profile | Why the Handoff Exists | Touched Surfaces | Status / Evidence |
| --- | --- | --- | --- | --- |
| `<from>` | `<to>` | <reason> | <paths/surfaces> | <planned|active|completed> |

- If `Operational / Coder` discovers that project-level constitutional rules or invariants must change, record a handoff to `Strategic / CTO-Tech-Lead` instead of editing `project_constitution.md` directly.
- `Genesis / Product-Bootstrap` may begin with a profile-scoped capped TODO via `templates/capped_todo_template.md` while discovery and foundation refinement remain explicitly no-code. This tactical template applies only after Genesis hands off to true implementation planning.

## Complexity
- **Level (`small|medium|big`):** <classification>
- **Checkpoint policy:** <consolidated | one checkpoint | section-by-section>
- **Why this level:** <brief reasoning>

## Canonical Module Anchors (Required Before APROVADO)
- **Primary module doc:** `foundation_documentation/modules/<primary_module>.md`
- **Secondary module docs (if any):**
  - `foundation_documentation/modules/<secondary_module>.md`
- **Planned decision promotion targets (module sections):**
  - `<module section where stable decisions/plans will be consolidated>`
- **Module decision consolidation targets (required):**
  - `<module section where finalized decisions from this TODO will be persisted>`

## Decisions
- [ ] `D-01` <Decision: chosen option + short rationale + module decision ref (or `No Prior Decision`)>

## Module Decision Baseline Snapshot (Required Before APROVADO)
- | Module Decision Ref | Current Module Decision | Planned Handling (`Preserve|Supersede (Intentional)|Out of Scope`) | Evidence |
- | --- | --- | --- | --- |
- | `<module#decision-id>` | <summary> | <handling> | <file:line/section> |

## Decision Baseline (Frozen Before Implementation)
- [ ] `D-01` <Expected outcome that implementation must adhere to>

## Questions To Close
- [ ] <Question that changes implementation>

## Assumptions Preview (Required Before Plan Review)
Assumptions here must be evidence-backed inferences from canonical modules, code, docs, tests, or repository state. They are not free guesses.

- Promote an assumption to `Decisions` before planning continues if it changes `Scope`, `Definition of Done`, `Validation Steps`, public contract, or module coherence.
- Mark handling as `Block` when the assumption cannot be supported enough to plan safely.

| Assumption ID | Assumption | Evidence | If False | Confidence (`High|Medium|Low`) | Handling (`Keep as Assumption|Promote to Decision|Block`) |
| --- | --- | --- | --- | --- | --- |
| `A-01` | <assumption> | <module/code/doc/test evidence> | <impact if wrong> | <confidence> | <handling> |

## Execution Plan (Required Before `APROVADO`)
Execution planning describes **HOW** Delphi intends to deliver the TODO contract above. It must stay subordinate to the contract.

- If the plan reveals contract changes, update the TODO contract first and do not continue with stale planning notes.

### Touched Surfaces
- `<module/file/package/runtime surface>`

### Ordered Steps
1. <Concrete implementation step>

### Test Strategy
- **Strategy:** `<test-first|test-after|not-applicable>`
- **Why:** <reasoning>
- **Fail-first target(s) (when required):** <tests to fail first or rationale for non-applicability>

### Runtime / Rollout Notes
- `<migrations, feature flags, infra/runtime concerns, or n/a>`

## Plan Review Gate (Review of the Execution Plan; required for `medium|big`; abbreviated for low-risk `small`)
Review the `Assumptions Preview` and `Execution Plan` against architecture, tests, performance, and security before approval.

### Review Sections
- [ ] Architecture
- [ ] Code Quality
- [ ] Tests
- [ ] Performance
- [ ] Security

### Issue Cards
- **Issue ID:** <e.g., ARCH-01>
  - **Severity:** <high|medium|low>
  - **Evidence:** <file:line or equivalent evidence>
  - **Why it matters now:** <impact summary>
  - **Option A (Recommended):** <description>
    - **Effort:** <low|medium|high>
    - **Risk:** <low|medium|high>
    - **Blast radius:** <local|module|cross-module>
    - **Maintenance burden:** <low|medium|high>
  - **Option B (Alternative):** <description>
    - **Effort:** <low|medium|high>
    - **Risk:** <low|medium|high>
    - **Blast radius:** <local|module|cross-module>
    - **Maintenance burden:** <low|medium|high>
  - **Option C (Do Nothing):** <description or explicit N/A with reason>
    - **Effort:** <low|medium|high>
    - **Risk:** <low|medium|high>
    - **Blast radius:** <local|module|cross-module>
    - **Maintenance burden:** <low|medium|high>
  - **Recommendation:** <chosen option + rationale>

### Failure Modes & Edge Cases
- [ ] <Failure mode + mitigation>

### Residual Unknowns / Risks
- [ ] <Unknown, residual risk, or review note that still matters after plan review>

## Rules Acknowledgement / Ingestion (Required After `APROVADO` and Before Execution)
Complete this after the execution plan is approved and the touched surfaces are known.

- Load the rules/workflows that actually govern the touched surfaces.
- Run the profile scope check for the active execution profile and review any `review required` paths against the TODO handoff log.
- If ingestion reveals a material conflict with the approved plan, stop execution, update the plan/TODO, and request renewed approval before continuing.

| Source | Why It Applies Now | Must Preserve | Must Avoid | Execution Impact |
| --- | --- | --- | --- | --- |
| `<rule/workflow path>` | <why it applies> | <non-negotiable constraints> | <forbidden shortcuts/regressions> | <what changes in execution/validation> |

## Decision Adherence Validation (Mandatory Before Delivery)
- | Decision ID | Status (`Adherent`/`Exception`) | Evidence | Notes |
- | --- | --- | --- | --- |
- | `D-01` | <status> | <file:line/test/doc> | <notes> |

## Module Decision Consistency Validation (1-1 Mandatory Before Delivery)
- | Module Decision Ref | Planned Handling | Delivery Status (`Preserved|Superseded (Approved)|Regression`) | Evidence | Notes |
- | --- | --- | --- | --- | --- |
- | `<module#decision-id>` | <handling> | <status> | <file:line/test/doc> | <notes> |

### Exception Handling
- If any decision is `Exception`, delivery is blocked until:
  - the decision is explicitly challenged with rationale, or
  - a better alternative is proposed,
  and the updated decision/baseline receives renewed **APROVADO**.
- If any module decision is `Regression`, delivery is blocked until:
  - an intentional supersede decision is approved, and
  - canonical module consolidation targets are updated accordingly.

## Security Risk Assessment (Mandatory Before Delivery)
- **Risk level:** `<none|low|medium|high>`
- **Why this risk level:** <short rationale tied to touched surfaces and behavior>
- **Attack surface in scope:** <auth/public endpoints/trust boundaries/secrets/multi-tenant/payment/agents/prompt-ingestion/etc.>
- **Attack simulation decision:** `<required|recommended|not_needed>`
- **Review evidence:** `<security-adversarial-review artifact, stack-specific security evidence, or rationale for not running a deeper review>`
- **Residual security risk:** <known accepted risk, or `none`>

## Verification Debt Assessment (Required Before `Completed`; mandatory audit for `medium|big` or when debt signals exist)
- **Audit outcome:** `<none|low|medium|high>`
- **Why this outcome:** <brief rationale>
- **Inline code TODO debt:** `<none|accepted|cleanup-required>`
- **Evidence / audit artifact:** `<verification-debt-audit artifact, grep output, or rationale for not running a full audit>`
- **Accepted residual debt:** <what remains and why it is accepted, or `none`>

## Delivery Confidence Gate (Required for `✅ Production-Ready`)
- [ ] **Lane promotion evidence complete:** local commits and required PR merges recorded in `Promotion Evidence`.
- [ ] **Runtime impact classified:** <none | low | medium | high>
- [ ] **Operational checks run (if runtime-impacting):**
  - [ ] migration/index status checked
  - [ ] queue/scheduler/worker health checked
  - [ ] targeted load/perf sampling executed (or justified as N/A)
  - [ ] smoke flow executed in the best available environment (or justified as N/A)
- [ ] **Evidence artifacts recorded:** `foundation_documentation/artifacts/tmp/<run-id>/...`
- [ ] **Confidence stated:** <high|medium|low> + <known residual risks>
- [ ] **Release readiness outcome:** <ready|ready_with_waiver|not_ready>

## Module Consolidation Gate (Required Before `Completed`)
- [ ] Canonical module docs were updated with stable conceptual outcomes and final decisions from this TODO.
- [ ] Decision promotion ledger (or equivalent trace table) in module docs links back to this TODO.
- [ ] Every relevant prior module decision is either preserved or intentionally superseded with explicit traceability.
- [ ] Superseded/conflicting tactical notes were removed or replaced by canonical module references.
- [ ] TODO/module cross-links were updated (including active/completed path changes).

## Commands (Run Locally)
- `fvm flutter analyze`
- <Any manual steps>

## Files Expected (Optional)
- `<path>`

## COMENTÁRIO:
- <Contextual question about the section below>

<Section the comment refers to>
