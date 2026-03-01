# Template: Tactical TODO (Active)

Use this file as a starting point for `foundation_documentation/todos/active/<short_slug>.md`.

## Title
<Short, specific title>

## Context
<Why this matters and where it appears in the product>

## Scope
- [ ] <What will be done>

## Delivery Stages
- [ ] **Provisional** (unblocks dependencies; requires revisit before production-ready)
- [ ] **Production-Ready** (complete, hardened, ready for release)

## Provisional Notes (Required if Provisional)
- **Missing for production-ready:** <What is intentionally incomplete>
- **Revisit criteria:** <What must be done to exit provisional>
- **Dependencies unblocked:** <What work can now proceed>

## Out of Scope
- [ ] <What will NOT be done>

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

## Decisions
- [ ] `D-01` <Decision: chosen option + short rationale>

## Decision Baseline (Frozen Before Implementation)
- [ ] `D-01` <Expected outcome that implementation must adhere to>

## Questions To Close
- [ ] <Question that changes implementation>

## Plan Review Gate (Required for `medium|big`; abbreviated for low-risk `small`)

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

### Uncertainty Register
- [ ] **Assumption:** <assumption>
- [ ] **Unknown:** <unknown to resolve>
- [ ] **Confidence:** <high|medium|low and why>

## Decision Adherence Validation (Mandatory Before Delivery)
- | Decision ID | Status (`Adherent`/`Exception`) | Evidence | Notes |
- | --- | --- | --- | --- |
- | `D-01` | <status> | <file:line/test/doc> | <notes> |

### Exception Handling
- If any decision is `Exception`, delivery is blocked until:
  - the decision is explicitly challenged with rationale, or
  - a better alternative is proposed,
  and the updated decision/baseline receives renewed **APROVADO**.

## Delivery Confidence Gate (Required for `✅ Production-Ready`)
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
- [ ] Superseded/conflicting tactical notes were removed or replaced by canonical module references.
- [ ] TODO/module cross-links were updated (including active/completed path changes).

## Definition of Done
- [ ] <Concrete, testable checklist item>

## Commands (Run Locally)
- `fvm flutter analyze`
- <Any manual steps>

## Files Expected (Optional)
- `<path>`

## COMENTÁRIO:
- <Contextual question about the section below>

<Section the comment refers to>
