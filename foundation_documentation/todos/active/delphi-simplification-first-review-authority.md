# TODO: Establish Simplification First and Explicit TODO Extensibility Authority

## Artifact Identity
- **Artifact type:** `tactical_execution_contract`

## Context
Delphi currently asks plans and reviewers to assess elegance, structural soundness, and minimal incidental complexity, but it does not state the complete governing mandate agreed in the self-improvement session:

1. `SIMPLIFICATION FIRST` means the simplest Clean Code solution that faithfully satisfies the approved intent; it does not mean the smallest diff.
2. Simplification may require removing, consolidating, or redesigning existing over-engineered layers.
3. Simplicity must remain compatible with SOLID and cohesive decision ownership; replacing an abstraction with scattered conditionals, duplication, or hidden coupling is not simplification.
4. Foundation documentation may describe the future architecture and roadmap without automatically authorizing implementation of future-facing abstractions in the current tactical slice.
5. A tactical TODO may explicitly authorize anticipatory extensibility when that is the developer's intent. For example, a contact-channel model may intentionally establish a clean multi-channel abstraction while WhatsApp is the only currently delivered channel.
6. Reviewers must respect explicit TODO intent. They may assess whether the implementation is the simplest faithful realization, but they must neither invent absent future-facing layers nor reject explicitly authorized extensibility merely because only one concrete case exists today.
7. If the TODO is ambiguous about anticipatory extensibility, the reviewer must surface the ambiguity for developer/user resolution rather than silently choosing either speculative generalization or forced current-only design.

The current wording creates two opposite failure modes: reviewers can interpret future-aware foundational planning as permission to invent implementation layers, or they can apply YAGNI mechanically and erase an abstraction that the TODO deliberately authorized. This TODO establishes one coherent authority model for both cases.

## Framing Source & Story Slice
- **Feature brief:** `direct-to-todo`
- **Primary story ID:** `n/a`
- **Why this is the right current slice:** There is one bounded outcome: align Delphi planning and review behavior with the agreed simplification and explicit-intent mandate.
- **Direct-to-TODO rationale:** The governing conclusions were resolved directly with the user during a Delphi self-improvement session; a separate feature brief would duplicate the same decision package.

## Contract Boundary
- This TODO defines **WHAT** Delphi must establish across its canonical instruction, TODO, and reviewer contracts.
- The implementation must preserve future-aware foundation planning while separating it from tactical implementation authority.
- The implementation must use existing elegance, structural-soundness, TODO-decision, and reviewer-dispatch mechanisms where they are sufficient.
- A new abstraction, schema axis, guard, or parallel policy surface is allowed only when concrete evidence shows the current canonical mechanism cannot express or enforce the mandate cleanly.
- This TODO does not authorize downstream project changes.

## Delivery Status Canon (Required)
- **Current delivery stage:** `Pending`
- **Qualifiers:** `none`
- **Next exact step:** Freeze and push the architecture-opinion-integrated baseline, rerun the affected architecture opinion, then run the independent critique.

## Active Work State (Required While TODO Remains In `active/`)
- **Work state:** `review`
- **Why this state now:** The TODO contract has been drafted and coherence-reviewed, but implementation authority has not been granted.
- **Exit condition:** The TODO passes its required planning gates and receives explicit `APROVADO`, or a material blocker is recorded.

## Scope
- [ ] Establish `SIMPLIFICATION FIRST` as an explicit Delphi architectural and delivery mandate with Clean Code and SOLID boundaries.
- [ ] Clarify that “simplest” means least incidental complexity for the approved intent, not smallest diff, fewest files, or fewest abstractions.
- [ ] Clarify that simplification can require subtraction, consolidation, or a broader structural refactor when existing layers are unnecessary.
- [ ] Separate future-aware foundation documentation from authorization to implement future-facing abstractions in the current TODO.
- [ ] Add an explicit tactical-TODO contract for implementation horizon and anticipatory extensibility intent.
- [ ] Define a safe default when the TODO is silent: reviewers must not invent future-facing extensibility and must raise material ambiguity instead of silently deciding.
- [ ] Preserve explicitly authorized anticipatory extensibility as binding TODO intent that reviewers must evaluate faithfully.
- [ ] Require reviewers to seek the simplest clean implementation inside the authorized intent, including when the intent deliberately contains an extension seam.
- [ ] Align canonical planning review, architecture opinion, critique, final-review, and rule-spirit guidance with one shared invariant plus lifecycle-specific authority semantics.
- [ ] Protect changes to implementation horizon and authorized extension seams through the canonical review-scope-drift mechanism.
- [ ] Add proportionate deterministic regression coverage for objective prompt/template/contract requirements without pretending to automate subjective architecture judgment.
- [ ] Synchronize derived skills and compatibility mirrors from canonical sources using existing Delphi synchronization mechanisms.

## Out of Scope
- [ ] Prohibit anticipatory abstractions or future-aware design.
- [ ] Require every TODO to implement future roadmap capabilities.
- [ ] Treat every abstraction as overengineering.
- [ ] Treat every removal of an abstraction as simplification.
- [ ] Let reviewers redefine, expand, or erase explicit approved TODO intent based only on personal architectural preference.
- [ ] Make a developer's informal, unrecorded intention binding when it is absent from the TODO and approved decision baseline.
- [ ] Add project-specific examples, domain rules, or Belluga-specific contact-channel contracts to reusable Delphi canon.
- [ ] Modify downstream project code or `foundation_documentation/**` outside Delphi's own repository.
- [ ] Redesign the overall TODO-driven workflow or reviewer topology.

## Implementation Horizon & Extensibility Intent
- **Mode:** `current-scope-only`
- **Current delivery:** Establish the Delphi mandate, TODO expression, reviewer behavior, and proportionate validation described in this contract.
- **Explicit future cases informing the design:** Other Delphi review kinds and future stack capabilities must inherit the same canonical mandate through existing shared/mirror mechanisms.
- **Anticipatory implementation authorized now:** Only the reusable contract and propagation needed to make the mandate effective on current Delphi TODO/reviewer surfaces.
- **Not authorized now:** A new generalized policy engine, a second review-result schema, a parallel reviewer protocol, or speculative downstream migrations.
- **Rationale:** This TODO must itself demonstrate the rule it establishes: explicit horizon, bounded future awareness, and the simplest coherent implementation.

## Definition of Done
- [ ] Canonical Delphi principles state the complete `SIMPLIFICATION FIRST` mandate and distinguish simplicity from minimal diff/minimal abstraction count.
- [ ] Canonical principles preserve future-aware foundation planning while making clear that tactical implementation authority comes from the TODO and its approved decisions.
- [ ] The tactical TODO template directly records whether a slice is `current-scope-only` or explicitly authorizes anticipatory extensibility, with rationale, bounded future cases, authorized seam, and excluded speculation.
- [ ] TODO refinement and approval workflows require ambiguity about implementation horizon to be resolved before approval when it is material.
- [ ] All reviewers share the invariant that they cannot silently invent, rewrite, or erase intent.
- [ ] Planning reviewers may challenge a proposed extension seam and recommend a decision change, but cannot rewrite it autonomously.
- [ ] Delivery/adherence reviewers treat the approved implementation horizon and seam as binding; a material defect routes back to renewed approval rather than silent redesign.
- [ ] Reviewers remain authorized to flag a materially simpler faithful realization, implementation beyond the authorized seam, SOLID violations, duplicated decision logic, hidden coupling, or needless layers.
- [ ] Reviewer language distinguishes `essential complexity authorized by intent` from `incidental complexity introduced by implementation`.
- [ ] Existing `elegance_position` and structural-soundness mechanisms are reused unless an implementation-time evidence record demonstrates that they cannot carry the contract without ambiguity.
- [ ] The canonical `Foundational, Not Minimalist` / `Complete Vision over Minimalism` language is reconciled so it cannot be read as blanket permission to implement all anticipated capabilities immediately.
- [ ] Objective contract propagation is covered by focused tests or existing self-check surfaces; subjective simplicity judgment remains reviewer-owned.
- [ ] Canonical sources, skills, generated mirrors, manifest entries, and tests are synchronized with no contradictory wording.
- [ ] Delphi agnosticism review passes; no project-specific domain truth enters reusable canon.

## Validation Steps
- [ ] Search canonical and derived instruction surfaces for contradictory future-implementation wording, including `from day one`, `Not Minimalist`, `Complete Vision over Minimalism`, and reviewer simplicity language.
- [ ] Verify the tactical TODO template contains one explicit implementation-horizon/extensibility contract and does not create a competing source of truth.
- [ ] Verify reviewer dispatch receives one shared non-invention invariant plus correct planning-versus-delivery lifecycle semantics.
- [ ] Verify changes to `Implementation Horizon & Extensibility Intent` participate in `review_scope_drift_guard.py` comparison and focused tests.
- [ ] Add/update focused tests for `tools/subagent_review_dispatch.py` when its canonical focus text changes.
- [ ] Add/update objective TODO guard tests only if the implementation adds machine-checkable labels/enums.
- [ ] Run `bash tools/tests/subagent_review_dispatch_test.sh`.
- [ ] Run any focused TODO template/guard tests touched by the implementation.
- [ ] Run `bash self_check.sh`.
- [ ] Run `git diff --check`.
- [ ] Perform a manual agnosticism review of every changed Delphi surface.
- [ ] Perform a final conversation-coherence replay against `C-01` through `C-09` below.

## Conversation Coherence Contract
| ID | Confirmed Conclusion | Required TODO/Implementation Consequence |
| --- | --- | --- |
| `C-01` | Simplification first is not minimal change. | Review impact must consider resulting structure, not diff size. |
| `C-02` | The target is the simplest Clean Code solution with consistent SOLID application. | Scattered conditionals, duplicated decisions, hidden coupling, and abstraction avoidance are not accepted as simplicity. |
| `C-03` | Existing solutions may need layers removed. | Review must explicitly consider subtraction and consolidation before adding another layer. |
| `C-04` | Foundation documentation may plan future architecture. | Future-aware documentation remains valid and is not automatically reduced to current implementation scope. |
| `C-05` | Future planning does not alone authorize implementation. | Current implementation authority must be resolved from the tactical TODO and approved decisions. |
| `C-06` | A developer may intentionally authorize anticipatory extensibility. | The TODO must directly record that intent, its rationale, bounded future cases, and authorized seam. |
| `C-07` | Explicit TODO intent must be respected by reviewers. | A reviewer cannot reject the intent merely because it would be overengineering under a current-only default. |
| `C-08` | Reviewers must not autonomously invent future-facing complexity. | Silence or ambiguity triggers clarification/decision handling, not speculative layering. |
| `C-09` | Authorized extensibility remains subject to simplification. | Reviewers assess the simplest faithful implementation of the authorized extensible contract. |

## Profile Scope & Handoffs
- **Primary execution profile:** `strategic-cto`
- **Active technical scope:** `delphi-self-maintenance`
- **Expected supporting profiles:** `operational-coder|assurance-tester-quality`
- **Scope-check command:** `n/a - Delphi self-maintenance instruction/tooling slice`

### Handoff Log
| From Profile | To Profile | Why the Handoff Exists | Touched Surfaces | Status / Evidence |
| --- | --- | --- | --- | --- |
| `strategic-cto` | `operational-coder` | After `APROVADO`, implement the bounded canonical alignment. | `main_instructions.md`, principles, rules, workflows, templates, review dispatch/tests, generated mirrors | `pending approval` |
| `operational-coder` | `assurance-tester-quality` | Independently verify reviewer behavior, propagation, and absence of contradictory authority. | bounded implemented diff + validation evidence | `pending implementation` |

## Complexity
- **Level (`small|medium|big`):** `medium`
- **Checkpoint policy:** `one full Plan Review checkpoint before APROVADO`
- **Why this level:** The semantic change is bounded but cross-cuts the foundational mandate, TODO contract, multiple reviewer kinds, derived mirrors, and deterministic prompt regression tests.

## Canonical Module Anchors
- **Primary module doc:** `main_instructions.md`
- **Secondary module docs:**
  - `system_architecture_principles.md`
  - `templates/todo_template.md`
  - `rules/core/todo-driven-execution-model-decision.md`
  - `workflows/docker/todo-contract-refinement-method.md`
  - `workflows/docker/todo-approval-gates-method.md`
  - `workflows/docker/independent-critique-method.md`
  - `workflows/docker/independent-final-review-method.md`
  - `tools/subagent_review_dispatch.py`
- **Planned decision promotion targets:** foundational delivery mandate; core architectural philosophy; tactical TODO contract boundary; planning/final reviewer focus.
- **Module decision consolidation targets:** the canonical sources above; skills and client mirrors remain derived compatibility surfaces.

## Module Decision Baseline Snapshot
| Decision Ref | Existing Position | Planned Handling | Evidence |
| --- | --- | --- | --- |
| `main_instructions.md#Foundational-Delivery-Mandate` | Complete, forward-compatible architecture is prioritized over minimalism. | `Preserve + clarify documentation/implementation boundary` | `main_instructions.md:16-24` |
| `system_architecture_principles.md#P-4` | Foundation schemas and services incorporate long-term capabilities from day one. | `Supersede wording intentionally` | `system_architecture_principles.md:32-33` |
| `todo_template.md#Contract-Boundary` | Explicit temporary constructs must be recorded; implementation horizon is not explicit. | `Extend` | `templates/todo_template.md:28-33` |
| `todo-driven-execution#Plan-Review` | Elegance means simplicity/coherence/minimal incidental complexity. | `Preserve + make authority rule explicit` | `rules/core/todo-driven-execution-model-decision.md:165-176` |
| `independent-critique#Required-Positions` | Reviewer assesses elegance and structural shortcuts. | `Preserve + bind to TODO intent` | `workflows/docker/independent-critique-method.md:67-74` |
| `independent-final-review#Review-Focus` | Reviewer checks elegance regressions and brittle shortcuts. | `Preserve + bind to TODO intent` | `workflows/docker/independent-final-review-method.md:17-29` |

## Decisions (Resolved Before Freeze)
- [x] `D-01` Establish `SIMPLIFICATION FIRST` as the default architecture-selection mandate, constrained by Clean Code, SOLID, explicit contracts, security, correctness, and approved product intent.
- [x] `D-02` Define simplicity as minimum incidental complexity for the approved intent, never as minimum diff or automatic avoidance of abstraction.
- [x] `D-03` Preserve future-aware foundation planning while making the tactical TODO the authority for whether future-facing extensibility is implemented now.
- [x] `D-04` Require the TODO to state implementation horizon directly; explicit anticipatory extensibility is valid and binding when approved.
- [x] `D-05` When the TODO is silent, reviewers cannot invent future-facing abstraction. Material ambiguity must return to decision resolution.
- [x] `D-06` Reviewers cannot erase or reject explicitly authorized extensibility solely because only one current concrete case exists.
- [x] `D-07` Reviewers may challenge the implementation as unnecessarily complex only while preserving the same authorized intent and future seam.
- [x] `D-08` Prefer extending the semantics and focus of existing elegance/structural-soundness review mechanisms over adding a parallel simplicity subsystem.
- [x] `D-09` Deterministic tooling may validate the presence and propagation of objective contract markers but must not claim to judge architectural simplicity mechanically.
- [x] `D-10` Use lifecycle-specific reviewer authority: planning reviewers may challenge proposed intent without rewriting it; delivery/adherence reviewers treat approved intent as binding and route material defects back to renewed approval.
- [x] `D-11` Use one compact dedicated `Implementation Horizon & Extensibility Intent` section as the normative TODO expression, owned semantically by the core TODO rule and protected by scope-drift comparison; workflows and dispatches carry only lifecycle-specific operational guidance.

## Decision Baseline (Frozen Before Implementation)
- [ ] Freeze `D-01` through `D-11` after the refreshed architecture opinion, Plan Review Gate, required critique handling, conversation-coherence replay, and renewed explicit user approval converge.

## Architecture Change Governance (Required When This TODO Establishes, Corrects, or Supersedes Architecture)
- **Applicability (`required|not_needed`):** `required`
- **Why this applies:** The TODO corrects a reusable architectural-review ambiguity that can repeatedly create extra layers or incorrectly remove intentional extension seams.
- **Deviation / debt being retired:** Conflation of future-aware foundational planning, tactical implementation authorization, and reviewer architectural preference.
- **Target steady-state after closeout:** Every tactical TODO declares its implementation horizon; Delphi and its reviewers choose the simplest clean realization of explicit intent without adding or erasing future-facing design autonomously.
- **Temporary exceptions allowed:** `none`; a materially different authority model requires TODO refresh and renewed approval.
- **Cutover / removal condition:** Canonical rules, TODO template, workflows, reviewer dispatch, tests, skills, and mirrors express one non-contradictory authority model.

### Patterns To Enforce (Required when applicability = `required`)
| Pattern / Decision | Source / ID | Scope | Why It Must Hold After Cutover |
| --- | --- | --- | --- |
| `Simplest faithful design` | `D-01,D-02` | planning + implementation + review | Complexity is evaluated against approved intent, not reviewer preference. |
| `Explicit extensibility authority` | `D-03,D-04` | tactical TODO | Anticipatory design becomes deliberate and reviewable. |
| `Subtraction before addition` | `C-03` | existing solutions | Existing overengineering is considered before another layer is proposed. |
| `Cohesive decision ownership` | `C-02` | Clean Code/SOLID | Simplicity cannot scatter decisions through conditionals or duplication. |

### Prohibited Anti-Patterns
| Anti-Pattern / Wrong Path | Detection Signal | Why Forbidden | Exception Policy |
| --- | --- | --- | --- |
| Reviewer-invented extensibility | New layer justified only by hypothetical future use absent from TODO | Expands scope and incidental complexity without authority. | Requires TODO update and renewed approval. |
| Reviewer-erased extensibility | Explicit approved extension seam rejected only because one implementation exists | Replaces developer intent with reviewer preference. | Only valid after TODO decision is challenged and re-approved. |
| Minimal-diff simplification | Existing needless layers retained solely to reduce touched files | Preserves structural debt. | None; assess target structure. |
| Abstraction avoidance | Shared decision becomes repeated `if`/switch logic or duplicated policy | Violates cohesion and increases complexity. | None unless bounded evidence proves local ownership. |
| Speculative policy subsystem | New schema/guard/layer added when existing review fields can carry the rule | The mandate would implement its own overengineering. | Requires concrete insufficiency evidence in the TODO. |

### Architecture Protection Harness
| Harness Type | Surface | Command / Rule / Artifact | Regression It Must Catch | Adoption Timing (`already-enforced|implement-in-this-todo|follow-up-approved|manual-only-with-rationale`) | Evidence Plan / Follow-up |
| --- | --- | --- | --- | --- | --- |
| canonical prose | `main_instructions.md`, `system_architecture_principles.md` | canonical mandate text | Future planning interpreted as blanket implementation authority | `implement-in-this-todo` | manual coherence review + `bash self_check.sh` |
| TODO contract | `templates/todo_template.md` + refinement workflow | implementation-horizon contract | Missing/ambiguous implementation horizon | `implement-in-this-todo` | focused template/guard tests where objective |
| reviewer dispatch | `tools/subagent_review_dispatch.py` | dispatch focus contract | Reviewer invents or erases extensibility intent | `implement-in-this-todo` | `bash tools/tests/subagent_review_dispatch_test.sh` |
| review workflows | critique/final/approval methods | canonical review focus | Elegance assessed independently of approved TODO intent | `implement-in-this-todo` | textual contract audit + `bash self_check.sh` |
| compatibility sync | skills and client mirrors | existing sync/self-check surfaces | Canonical/derived wording drift | `implement-in-this-todo` | run applicable sync checks and `bash self_check.sh` |

## Architecture Review Gates (Deterministically Derived From Architecture Change Governance)
- **Architecture decision review:** `required`
- **Decision review lifecycle:** `after diagnosis is closed and before APROVADO`
- **Decision review kind:** `architecture_opinion`
- **Decision review package:** `bounded-file-set`
- **Decision review status:** `findings_integrated; refreshed rerun required`
- **Decision review evidence / resolution:** `fresh no-context reviewer simplification_architecture_opinion; three medium findings integrated as D-10, D-11, scope-drift coverage, and expanded Plan Review alternatives; material integration requires refreshed baseline and affected-lane rerun`
- **Architecture adherence review:** `required`
- **Adherence review lifecycle:** `after implementation and before Completed`
- **Adherence review kind:** `architecture_adherence`
- **Adherence review package:** `bounded-file-set`
- **Adherence review status:** `not_run`
- **Adherence review evidence / resolution:** `pending implementation`
- **No-go handling:** `when either required review is absent, blocked, or exposes an unresolved approval-breaking divergence, return to the affected diagnosis/decision or delivery-evidence loop; do not claim APROVADO or Completed.`

## Assumptions Preview
| ID | Assumption | Evidence | If False | Confidence | Handling |
| --- | --- | --- | --- | --- | --- |
| `A-01` | Current elegance and structural-soundness fields can carry the mandate without a new result-schema axis. | Dispatch and result schema already require both positions for all relevant reviewer kinds. | Add a narrowly justified schema evolution after recording insufficiency evidence. | `High` | `Keep as Assumption` |
| `A-02` | One compact dedicated TODO section is the simplest reliable direct authority surface for anticipatory implementation intent. | Existing TODO decisions/approval govern implementation, while the architecture opinion compared dedicated-section, Contract Boundary, and decision-only placements. | Reopen ARCH-02 and select the simpler proven placement before implementation. | `High` | `Promote to Decision D-11` |
| `A-03` | Objective presence/enum checks may be deterministic, but architectural simplicity remains judgment-led. | Delphi already prohibits faux-deterministic tooling for judgment-heavy governance. | Reassess only if a precise, low-false-positive invariant is discovered. | `High` | `Promote to Decision D-09` |

## Execution Plan
### Expected Touched Surfaces
- `main_instructions.md`
- `system_architecture_principles.md`
- `templates/todo_template.md`
- `rules/core/todo-driven-execution-model-decision.md`
- relevant stack rule mirrors only where they duplicate the canonical review contract
- `workflows/docker/todo-contract-refinement-method.md`
- `workflows/docker/todo-approval-gates-method.md`
- `workflows/docker/independent-critique-method.md`
- `workflows/docker/independent-final-review-method.md`
- `review_session.md`
- `tools/subagent_review_dispatch.py`
- `tools/tests/subagent_review_dispatch_test.sh`
- objective TODO guards/tests only if the final contract adds machine-checkable fields
- `tools/manifest.md` only if a canonical tool is materially changed
- concise skill entrypoints and generated client mirrors affected by canonical sync
- this TODO and its review/evidence artifacts

### Ordered Steps
1. Reconcile the foundational mandate wording so future-aware architecture remains valid but does not silently authorize future implementation.
2. Add the implementation-horizon/extensibility-intent contract to the tactical TODO template and refinement/approval flow.
3. Add the dedicated horizon section to the scope-drift comparison contract and focused guard tests.
4. Align core TODO/review rules with the explicit-intent authority, lifecycle-specific reviewer semantics, and simplest-faithful-design criteria.
5. Update reviewer workflows and inject one shared dispatch focus fragment while reusing existing elegance and structural-soundness result fields by default.
6. Synchronize stack duplicates, skills, and generated mirrors through canonical sync mechanisms.
7. Add focused objective regression coverage and run Delphi self-maintenance checks.
8. Replay `C-01` through `C-09`, run final review gates, and resolve findings without widening the mandate.

### Test Strategy
- **Strategy:** `test-first where objective prompt/template contracts change; review-first for semantic prose`
- **Fail-first targets:** Dispatch tests should initially demonstrate missing explicit TODO-authority/simplification focus; any added objective TODO field guard should first reject an absent or invalid implementation-horizon marker.
- **Judgment boundary:** No test may claim that a particular code design is universally “simple”; tests protect contract propagation, not architectural taste.

## Diff Expectation Contract
- **Repository baseline:** `delphi-ai@3a30f21c611486fa353868d4aab2ec4b350385ef`
- **Comparison mode:** `working_tree`
- **Expected changed paths:** only the Delphi instruction, rule, workflow, template, reviewer dispatch/test, manifest/register, generated mirror, and TODO surfaces enumerated above.
- **Not expected changed paths:** downstream project repositories/docs, runtime/deploy configuration, unrelated skills/tools, product code, or submodule gitlinks.
- **Deviation policy:** Any unclassified path requires explicit analysis; necessary scope expansion requires TODO refresh and renewed approval.

## Plan Review Gate
- **Status:** `draft self-review complete; authoritative review-baseline freeze and independent critique pending`
- **Required lenses:** `Architecture|Code Quality|Tests|Performance|Security|Elegance|Structural Soundness`

### Material Issue Cards
- **Issue ID:** `ARCH-01`
  - **Severity:** `high`
  - **Evidence:** `system_architecture_principles.md:32-33`; `main_instructions.md:23`
  - **Why it matters now:** Current wording can collapse future planning into immediate implementation authority.
  - **Option A (Recommended):** Preserve future-aware planning and explicitly route current implementation authority through the TODO horizon/decision contract.
    - **Effort / risk / blast radius / maintenance:** `medium / low / cross-stack / low`
    - **Performance / elegance / structural soundness:** `neutral / improves / improves`
  - **Option B (Alternative):** Remove future-aware planning from foundational principles.
    - **Effort / risk / blast radius / maintenance:** `medium / high / cross-stack / medium`
    - **Performance / elegance / structural soundness:** `neutral / regresses / regresses`
  - **Option C (Do Nothing):** Retain ambiguous wording.
    - **Effort / risk / blast radius / maintenance:** `low / high / cross-stack / high`
    - **Performance / elegance / structural soundness:** `neutral / regresses / regresses`
  - **Recommendation:** `Option A`; it preserves the clarified product-development intent without granting reviewers implicit implementation scope.

- **Issue ID:** `ARCH-02`
  - **Severity:** `high`
  - **Evidence:** `templates/todo_template.md:28-33`; absence of an explicit implementation-horizon field
  - **Why it matters now:** Reviewer authority cannot be deterministic when anticipatory intent remains implicit.
  - **Option A (Recommended):** Add one compact, dedicated `Implementation Horizon & Extensibility Intent` section, semantically owned by the core TODO rule and protected by scope-drift.
    - **Effort / risk / blast radius / maintenance:** `medium / low / cross-stack / low`
    - **Performance / elegance / structural soundness:** `neutral / improves / improves`
  - **Option B (Alternative):** Put labeled horizon fields inside `Contract Boundary`.
    - **Effort / risk / blast radius / maintenance:** `low / medium / cross-stack / medium`
    - **Performance / elegance / structural soundness:** `neutral / mixed / acceptable`
    - **Tradeoff:** Fewer headings, but weaker discoverability and a mixed descriptive/decision section.
  - **Option C (Do Nothing / decision-only encoding):** Depend on arbitrary decision text or infer intent from roadmap/foundation docs.
    - **Effort / risk / blast radius / maintenance:** `low / high / cross-stack / high`
    - **Performance / elegance / structural soundness:** `neutral / regresses / regresses`
  - **Recommendation:** `Option A`; one compact normative section is the simplest reliable and reviewable expression, provided no parallel schema/policy subsystem is created.

- **Issue ID:** `ARCH-03`
  - **Severity:** `medium`
  - **Evidence:** `tools/subagent_review_dispatch.py:19-153`; `schemas/subagent_review_result.schema.json:6-18`
  - **Why it matters now:** Reviewers receive elegance/structural axes but no direct instruction about explicit extensibility authority.
  - **Option A (Recommended):** Inject one shared authority/simplicity focus fragment into existing review kinds and reuse current result fields.
    - **Effort / risk / blast radius / maintenance:** `low / low / local-tool / low`
    - **Performance / elegance / structural soundness:** `neutral / improves / improves`
  - **Option B (Alternative):** Add a dedicated simplicity result axis.
    - **Effort / risk / blast radius / maintenance:** `medium / medium / cross-tool / medium`
    - **Performance / elegance / structural soundness:** `neutral / regresses unless proven necessary / mixed`
  - **Option C (Do Nothing):** Leave reviewer focus implicit.
    - **Effort / risk / blast radius / maintenance:** `low / high / cross-stack / high`
    - **Performance / elegance / structural soundness:** `neutral / regresses / regresses`
  - **Recommendation:** `Option A`; reopen Option B only on concrete insufficiency evidence.

- **Issue ID:** `ARCH-04`
  - **Severity:** `medium`
  - **Evidence:** `workflows/docker/todo-approval-gates-method.md:45-48`; `workflows/docker/independent-critique-method.md:8-11,72-74`; `workflows/docker/independent-final-review-method.md:29,92-94`
  - **Why it matters now:** A blanket binding or challenge rule would either suppress legitimate planning challenge or authorize delivery-time redesign.
  - **Option A (Recommended):** One shared non-invention invariant plus lifecycle-specific planning and delivery semantics.
    - **Effort / risk / blast radius / maintenance:** `medium / low / cross-review / low`
    - **Performance / elegance / structural soundness:** `neutral / improves / improves`
  - **Option B (Alternative):** Treat intent as binding for every reviewer stage.
    - **Effort / risk / blast radius / maintenance:** `low / high / cross-review / medium`
    - **Performance / elegance / structural soundness:** `neutral / mixed / regresses`
  - **Option C (Do Nothing):** Let each reviewer infer its authority.
    - **Effort / risk / blast radius / maintenance:** `low / high / cross-review / high`
    - **Performance / elegance / structural soundness:** `neutral / regresses / regresses`
  - **Recommendation:** `Option A`; planning may challenge but never rewrite, while delivery treats approved intent as binding and routes defects to renewed approval.

### Failure Modes & Edge Cases
- [ ] A planning reviewer mistakes “respect intent” for “never challenge a proposed decision”; lifecycle guidance must preserve challenge authority.
- [ ] A delivery reviewer treats challenge authority as permission to redesign approved intent; delivery guidance must route material defects back to renewed approval.
- [ ] The horizon mode changes after review without scope-drift detection; the section must be in the canonical comparison list and focused tests.
- [ ] A TODO declares future-aware mode but leaves the authorized seam or excluded speculation empty; material ambiguity must block approval.
- [ ] A current-only TODO is incorrectly used to prohibit abstractions required by Clean Code/SOLID for the present contract.
- [ ] A future-aware TODO becomes blanket authorization for every roadmap capability; bounded cases and exclusions must remain explicit.
- [ ] Shared reviewer focus is copied into each dispatch kind and drifts; use one shared fragment or equivalently single-owned canonical source.

### Architecture Opinion Finding Resolution
| Finding ID | Resolution | Usefulness | Rationale / Evidence |
| --- | --- | --- | --- |
| `AO-01-lifecycle-authority` | `Integrated` | `useful` | Added D-10, ARCH-04, lifecycle-specific DoD, and failure modes. |
| `AO-02-scope-drift` | `Integrated` | `useful` | Added D-11 and explicit scope/DoD/validation coverage for horizon drift. |
| `AO-03-placement-comparison` | `Integrated` | `useful` | ARCH-02 now compares dedicated section, Contract Boundary fields, and decision-only encoding with full tradeoffs. |

## Coherence Loop Record
| Pass | Lens | Result | Evidence / Resolution |
| --- | --- | --- | --- |
| `L-01` | Conversation fidelity | `passed` | Every user conclusion is mapped 1:1 in `C-01` through `C-09`. |
| `L-02` | Foundation-vs-implementation boundary | `passed` | `D-03` preserves future planning and routes implementation through explicit TODO authority. |
| `L-03` | Intentional extensibility | `passed` | `D-04`, `D-06`, and the horizon contract protect the contact-channel class of deliberate abstraction. |
| `L-04` | Reviewer non-invention | `passed` | `D-05` prohibits silent speculative generalization; ambiguity returns to decision resolution. |
| `L-05` | Clean Code/SOLID | `passed` | `C-02` and anti-patterns reject scattered conditional logic and abstraction avoidance. |
| `L-06` | Simplification of existing solutions | `passed` | `C-03` and required patterns force subtraction/consolidation consideration before new layers. |
| `L-07` | Self-application / no new overengineering | `passed` | `D-08`, `D-09`, and `A-01` reuse existing review/schema mechanisms by default. |
| `L-08` | Agnosticism | `passed` | Contact channels remain an explanatory session example only; no project-specific rule enters canonical scope. |
| `L-09` | Execution boundary | `passed` | TODO creation is the only current mutation; all canonical implementation remains pending `APROVADO`. |
| `L-10` | Reviewer lifecycle authority | `passed after integration` | D-10 separates planning challenge from delivery adherence while preserving the shared non-invention invariant. |
| `L-11` | Scope-drift protection | `passed after integration` | D-11 makes the horizon section normative and explicitly adds it to drift comparison and tests. |

## Residual Unknowns / Risks
- [ ] Confirm during implementation whether an explicit enum label in the TODO template needs deterministic guard enforcement or whether template/workflow/reviewer coverage is proportionate.
- [ ] Confirm the canonical synchronization command(s) for every touched skill/client mirror before editing derived surfaces.
- [ ] Verify whether the Laravel stack duplicate of the TODO rule is generated or independently canonical before changing it.
- [ ] Reassess `A-01` only if reviewer prompt tests demonstrate that the existing elegance/structural fields cannot express the mandate clearly.

## Audit Trigger Matrix (Required Before Audit Decisions Are Trusted)
- **Canonical method:** `wf-docker-audit-escalation-method`
- **Guard command:** `python3 delphi-ai/tools/audit_escalation_guard.py --todo foundation_documentation/todos/active/delphi-simplification-first-review-authority.md`
- **Latest TEACH evidence / artifact:** `Overall outcome: go; fingerprint 5c30969f94cd; critique, architecture decision/adherence review, test-quality audit, final review, and verification-debt audit required; triple review, security review, and performance/concurrency lanes not needed`

| Trigger | Value | Notes |
| --- | --- | --- |
| `complexity` | `medium` | Cross-canonical instruction and reviewer contract. |
| `blast_radius` | `cross-stack` | Reusable Delphi behavior applies across supported stacks. |
| `behavioral_change_or_bugfix` | `yes` | Changes agent/reviewer behavior. |
| `changes_public_contract` | `yes` | Changes tactical TODO and reviewer contracts. |
| `touches_auth_or_tenant` | `no` | No product auth/tenant behavior. |
| `touches_runtime_or_infra` | `no` | No downstream runtime change. |
| `touches_tests` | `yes` | Focused contract propagation tests expected. |
| `critical_user_journey` | `no` | Instruction-only Delphi scope. |
| `release_or_promotion_critical` | `no` | No promotion behavior change. |
| `high_severity_plan_review_issue` | `yes` | `ARCH-01` and `ARCH-02`. |
| `explicit_three_lane_request` | `no` | No dedicated delivery-side triple audit requested. |

## Gate: Review Baseline Freeze
- **Gate decision:** `required`
- **Why this decision:** The first planning-side independent review must evaluate one immutable TODO package.
- **Trigger stage:** `before the first planning-side review or guard run`
- **Baseline branch:** `hooks-implementation`
- **Baseline commit:** `pending refreshed baseline after architecture-opinion integration`
- **Baseline push reference:** `pending refreshed push`
- **Gate status:** `running`
- **Findings summary:** `The original package was frozen at fe89bcc; three material architecture-opinion refinements were integrated and require a refreshed freeze before the affected review reruns.`
- **Evidence / reference:** `original baseline fe89bcc; refreshed commit pending`
- **Waiver authority / reference:** `n/a`
- **Pre-freeze packet-prep rule:** `all current loop results are self-review preparation, not gate-satisfying independent review evidence`

## Gate: Review Scope Drift
- **Gate decision:** `required`
- **Why this decision:** The cross-canonical scope must remain faithful to the user conclusions after reviewer findings are integrated.
- **Trigger stage:** `after the planning-side review/guard cycle converges and before APROVADO`
- **Baseline source:** `Review Baseline Freeze -> Baseline commit`
- **Material sections compared:** `Context|Contract Boundary|Scope|Out of Scope|Implementation Horizon & Extensibility Intent|Definition of Done|Validation Steps|Canonical Module Anchors|Decisions|Decision Baseline|Architecture Change Governance|Assumptions Preview|Execution Plan`
- **Guard command:** `python3 delphi-ai/tools/review_scope_drift_guard.py --todo foundation_documentation/todos/active/delphi-simplification-first-review-authority.md`
- **Gate status:** `not_run`
- **Findings summary:** `pending review convergence`
- **Evidence / reference:** `pending`
- **Waiver authority / reference:** `n/a`

## Questions To Close
- [x] Should future-aware planning be removed? `No; preserve it and separate it from tactical implementation authority.`
- [x] Can anticipatory abstraction be valid? `Yes, when directly recorded and approved in the TODO.`
- [x] May reviewers invent or erase that intent? `No; they evaluate the simplest faithful realization of explicit intent.`
- [ ] Does the final implementation require a new review-result schema axis? `Default no; reopen only on concrete insufficiency evidence.`

## Independent No-Context Critique Gate
- **Critique decision:** `required`
- **Why this decision:** `medium`, cross-stack reusable behavior, public TODO/reviewer contract change, and high-severity architecture issues.
- **Package mode:** `bounded-file-set`
- **Critique isolation mode:** `fresh internal no-context reviewer`
- **Critique status:** `not_run`
- **Findings summary:** `pending review-baseline freeze and dispatch`
- **Evidence / reference:** `pending`
- **Waiver authority / reference:** `n/a`

## Gate: Assumption Code Coherence
- **Gate decision:** `required`
- **Why this decision:** `A-01` through `A-03` cite exact existing template, schema, dispatch, and governance behavior that must be verified after critique.
- **Trigger stage:** `after critique convergence and before APROVADO`
- **Guard scope:** `A-01,A-02,A-03`
- **Guard command:** `python3 delphi-ai/tools/assumption_code_coherence_guard.py --todo foundation_documentation/todos/active/delphi-simplification-first-review-authority.md`
- **Gate status:** `not_run`
- **Findings summary:** `pending`
- **Evidence / reference:** `pending`
- **Waiver authority / reference:** `n/a`

## Approval
- **Approved by:** `user on 2026-08-29 via explicit APROVADO; superseded for execution by material architecture-opinion integration`
- **Approval scope:** `historically approved D-01 through D-09; current D-01 through D-11 package requires renewed approval after planning gates converge`
- **Execution not authorized by approval:** `all implementation; architecture-opinion findings materially refined reviewer lifecycle authority and scope-drift protection`
- **Renewed approval required when:** `scope, mandate semantics, implementation horizon, reviewer authority, validation, or architecture changes materially`

## Agent Routing Preflight
- **Client surface:** `codex`
- **Current governed action:** `todo-approval`
- **Selected role:** `primary-chat`
- **Selected model:** `gpt-5.4`
- **Selected effort:** `ExtraRight-or-closest-equivalent`
- **Proof mode:** `declared`
- **Subagent / delegation authorization:** `authorized by this TODO's required internal review gates and user APROVADO`
- **Execution topology:** `primary-checkout-single-writer`
- **Worktree / auxiliary-checkout authorization:** `not-authorized`
- **Writer scheduling policy:** `single-writer-serialized`
- **Guard outcome:** `go`
- **Evidence:** `agent_role_routing_guard.py returned Overall outcome: go before planning-side review orchestration`

## Rules Acknowledgement / Ingestion
- **Status:** `pending APROVADO; this section must be populated before implementation`
- **Pre-approval state:** No ingestion row is claimed yet. Populate the canonical table from the then-current rule/workflow sources only after approval and before implementation.
