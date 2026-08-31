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
- **Next exact step:** Commit and publish the approved subtraction, then await user confirmation to close the self-improvement session.

## Active Work State (Required While TODO Remains In `active/`)
- **Work state:** `review`
- **Why this state now:** The mandate implementation remains intact and every post-implementation expansion unrelated to that mandate was removed by explicit user direction.
- **Exit condition:** The subtraction is committed and published, and the user confirms whether this self-improvement session is complete.

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
- [ ] Extend the existing `tools/review_scope_drift_guard.py` and its focused test to compare the normative horizon section; do not create a second drift guard.
- [ ] Bind the horizon contract to the frozen decision/approval baseline and rerun the same scope-drift guard before architecture-adherence/final delivery review.
- [ ] Run the existing scope-drift guard immediately before each applicable `architecture_adherence` and `final_review` dispatch, rerunning it after any remediation that touches protected sections; bind each review record to the approved baseline commit and guard output.
- [ ] Establish lazy adoption: new or pre-approval TODOs require the horizon section; already-approved TODOs preserve explicit frozen decisions and adopt the section at their next approval-material refresh without mass migration.
- [ ] Add proportionate deterministic regression coverage for objective prompt/template/contract requirements without pretending to automate subjective architecture judgment.
- [ ] Synchronize derived skills and compatibility mirrors from canonical sources using existing Delphi synchronization mechanisms.
- [ ] Retire the full stack-agnostic duplicate under the Laravel rule path by replacing it with a concise compatibility adjunct/pointer containing only Laravel-specific loading deltas, with the core TODO rule as the sole shared authority.
- [ ] Extend the existing instruction-baseline audit and add a focused negative regression test that rejects a Laravel compatibility adjunct when it regrows shared TODO authority.

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
- **Anticipatory implementation authorized now:** `none`
- **Not authorized now:** A new generalized policy engine, a second review-result schema, a parallel reviewer protocol, or speculative downstream migrations.
- **Rationale:** This TODO must itself demonstrate the rule it establishes: explicit horizon, bounded future awareness, and the simplest coherent implementation.

### Field Semantics
- **Mode values:** `current-scope-only|bounded-anticipatory-extensibility`.
- **`current-scope-only`:** Future roadmap/foundation capabilities do not authorize implementation now. This mode does not prohibit abstractions justified by the present contract, Clean Code, SOLID, correctness, or current operational needs.
- **`bounded-anticipatory-extensibility`:** The TODO intentionally authorizes a future-facing extension seam now.
- **Silence/adoption rule:** New and pre-approval TODOs may not remain silent. Existing already-approved TODOs retain the authority of their explicit frozen decisions and normalize to this section only at the next approval-material refresh; absence must never be reinterpreted as permission to erase an approved seam.

### Per-Mode Truth Table
| Literal Field Label | `current-scope-only` | `bounded-anticipatory-extensibility` |
| --- | --- | --- |
| `Mode` | exact enum value required | exact enum value required |
| `Current delivery` | concrete, non-placeholder required | concrete, non-placeholder required |
| `Explicit future cases informing the design` | concrete list or canonical `none`; informational only | concrete, non-placeholder future cases required |
| `Anticipatory implementation authorized now` | canonical `none` required; present-contract abstractions remain allowed | concrete, bounded authorized seam required |
| `Not authorized now` | concrete exclusions required | concrete exclusions required |
| `Rationale` | concrete, non-placeholder required | concrete, non-placeholder required |

- **Deterministic boundary:** Extend the existing `tools/todo_authority_guard.py` only to validate the enum and literal field presence/non-placeholder semantics when this section is present. Do not make it judge simplicity or infer legacy intent.
- **Adoption enforcement:** Updated templates/rules/workflows require the section for new or pre-approval TODOs. A legacy TODO may omit it only while its pre-rollout approval remains operative; it must normalize before the next review-baseline freeze or renewed approval.

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
- [ ] The same scope-drift guard protects the horizon section before approval and before architecture-adherence/final delivery review against the frozen decision/approval baseline.
- [ ] Mode and conditional-field presence are deterministically checkable, but no guard claims to decide whether an architecture is genuinely simple.
- [ ] `todo_authority_guard.py` validates the exact per-mode truth table when the section is present, with focused tests for both modes, placeholders, and legacy absence; no exporter/schema expansion or new validator is introduced.
- [ ] Lazy adoption prevents existing approved TODOs from losing explicit extensibility intent merely because they predate the new section.
- [ ] Canonical sources, skills, generated mirrors, manifest entries, and tests are synchronized with no contradictory wording.
- [ ] The Laravel TODO-rule path no longer duplicates the global rule; it points to the core authority and contains only concrete Laravel-specific adjunct behavior, if any.
- [ ] The existing `tools/audit_instruction_baselines.sh` plus a focused negative regression test reject a Laravel adjunct that regrows shared stack-agnostic TODO authority.
- [ ] Delphi agnosticism review passes; no project-specific domain truth enters reusable canon.

## Validation Steps
- [ ] Search canonical and derived instruction surfaces for contradictory future-implementation wording, including `from day one`, `Not Minimalist`, `Complete Vision over Minimalism`, and reviewer simplicity language.
- [ ] Verify the tactical TODO template contains one explicit implementation-horizon/extensibility contract and does not create a competing source of truth.
- [ ] Verify reviewer dispatch receives one shared non-invention invariant plus correct planning-versus-delivery lifecycle semantics.
- [ ] Verify changes to `Implementation Horizon & Extensibility Intent` participate in `review_scope_drift_guard.py` comparison and focused tests.
- [ ] Verify `todo_authority_guard.py` accepts valid truth-table instances, rejects invalid modes/placeholders/missing conditional fields when the section is present, and preserves documented legacy absence until the next baseline refresh.
- [ ] For this pre-implementation TODO cycle, perform and record a bounded direct comparison of the horizon section against the refreshed pushed baseline because the current guard does not yet recognize the new heading.
- [ ] Add/update focused tests for `tools/subagent_review_dispatch.py` when its canonical focus text changes.
- [ ] Iterate every dispatch review kind in focused tests and assert the shared non-invention invariant plus planning-versus-delivery authority text.
- [ ] Add/update objective TODO guard tests only if the implementation adds machine-checkable labels/enums.
- [ ] Run `bash tools/tests/subagent_review_dispatch_test.sh`.
- [ ] Run any focused TODO template/guard tests touched by the implementation.
- [ ] Run `bash tools/tests/todo_authority_guard_test.sh`.
- [ ] Run `bash tools/tests/review_scope_drift_guard_test.sh`, including drift introduced between architecture-adherence and final-review dispatches.
- [ ] Run `bash tools/tests/audit_instruction_baselines_test.sh`, including a negative fixture where the Laravel adjunct duplicates stack-agnostic core authority.
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
| `strategic-cto` | `operational-coder` | After `APROVADO`, implement the bounded canonical alignment. | `main_instructions.md`, principles, rules, workflows, templates, review dispatch/tests, generated mirrors | `active; renewed APROVADO received 2026-08-29` |
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
  - `workflows/docker/todo-driven-execution-method.md`
  - `workflows/docker/todo-delivery-gates-method.md`
  - `workflows/docker/independent-critique-method.md`
  - `workflows/docker/independent-final-review-method.md`
  - `tools/subagent_review_dispatch.py`
  - `tools/review_scope_drift_guard.py`
  - `tools/todo_authority_guard.py`
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
- [x] `D-07` Delivery/adherence reviewers may challenge an implementation as unnecessarily complex only while preserving the approved intent and future seam; material redesign routes back to renewed approval.
- [x] `D-08` Prefer extending the semantics and focus of existing elegance/structural-soundness review mechanisms over adding a parallel simplicity subsystem.
- [x] `D-09` Deterministic tooling may validate the presence and propagation of objective contract markers but must not claim to judge architectural simplicity mechanically.
- [x] `D-10` Use lifecycle-specific reviewer authority: planning reviewers may challenge proposed intent without rewriting it; delivery/adherence reviewers treat approved intent as binding and route material defects back to renewed approval.
- [x] `D-11` Use one compact dedicated `Implementation Horizon & Extensibility Intent` section as the normative TODO expression, owned semantically by the core TODO rule and protected by scope-drift comparison; workflows and dispatches carry only lifecycle-specific operational guidance.
- [x] `D-12` Define exact modes `current-scope-only|bounded-anticipatory-extensibility` and conditional field requirements; current-only never prohibits abstractions justified by the present contract.
- [x] `D-13` Adopt lazily: require the section for new/pre-approval TODOs; preserve existing approved frozen-decision authority and normalize at the next approval-material refresh without mass migration.
- [x] `D-14` Bind the horizon section to the frozen decision/approval baseline and rerun the existing scope-drift guard both before approval and before architecture-adherence/final delivery review.
- [x] `D-15` Run the same scope-drift guard immediately before each architecture-adherence and final-review dispatch and after protected-section remediation, binding review evidence to the approved baseline commit plus fresh guard output.
- [x] `D-16` Use the literal per-mode truth table above; `todo_authority_guard.py` validates objective semantics only when the section is present, while lazy adoption is enforced at the next review-baseline freeze/renewed approval without mass migration.
- [x] `D-17` Make `rules/core/todo-driven-execution-model-decision.md` the sole stack-agnostic TODO authority; reduce the Laravel rule path to a concise compatibility adjunct/pointer with only explicit Laravel-specific deltas.
- [x] `D-18` Extend `tools/audit_instruction_baselines.sh` and add a focused negative regression test so a Laravel adjunct that regrows shared authority fails deterministically.

## Decision Baseline (Frozen Before Implementation)
- [x] Freeze `D-01` through `D-18` after the Plan Review Gate, required critique handling, conversation-coherence replay, and renewed explicit user approval converge.

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
| Full stack-agnostic rule duplicated under a stack path | Stack file repeats the global TODO gate while declaring itself stack-agnostic | Creates a second authority and predictable drift. | Replace with concise compatibility adjunct containing only real stack deltas. |

### Architecture Protection Harness
| Harness Type | Surface | Command / Rule / Artifact | Regression It Must Catch | Adoption Timing (`already-enforced|implement-in-this-todo|follow-up-approved|manual-only-with-rationale`) | Evidence Plan / Follow-up |
| --- | --- | --- | --- | --- | --- |
| canonical prose | `main_instructions.md`, `system_architecture_principles.md` | canonical mandate text | Future planning interpreted as blanket implementation authority | `implement-in-this-todo` | manual coherence review + `bash self_check.sh` |
| TODO contract | `templates/todo_template.md` + refinement workflow | implementation-horizon contract | Missing/ambiguous implementation horizon | `implement-in-this-todo` | focused template/guard tests where objective |
| reviewer dispatch | `tools/subagent_review_dispatch.py` | dispatch focus contract | Reviewer invents or erases extensibility intent | `implement-in-this-todo` | `bash tools/tests/subagent_review_dispatch_test.sh` |
| scope-drift guard | `tools/review_scope_drift_guard.py` | existing guard + focused test | Post-review changes to horizon mode, authorized seam, exclusions, or rationale escape reconvergence | `implement-in-this-todo` | `bash tools/tests/review_scope_drift_guard_test.sh` |
| TODO authority guard | `tools/todo_authority_guard.py` | existing guard + focused test | Present horizon sections use invalid modes, placeholders, or missing conditional fields | `implement-in-this-todo` | `bash tools/tests/todo_authority_guard_test.sh` |
| delivery review freshness | TODO delivery workflows/skills | same drift guard before each applicable dispatch | Adherence remediation makes final-review evidence stale | `implement-in-this-todo` | focused workflow audit + drift-guard test scenario |
| canonical duplication audit | core + Laravel TODO rule path | `bash tools/audit_instruction_baselines.sh` | Stack compatibility path regrows into a full shared-rule copy | `implement-in-this-todo` | `bash tools/tests/audit_instruction_baselines_test.sh` negative regression + self-check evidence |
| review workflows | critique/final/approval methods | canonical review focus | Elegance assessed independently of approved TODO intent | `implement-in-this-todo` | textual contract audit + `bash self_check.sh` |
| compatibility sync | skills and client mirrors | existing sync/self-check surfaces | Canonical/derived wording drift | `implement-in-this-todo` | run applicable sync checks and `bash self_check.sh` |

## Architecture Review Gates (Deterministically Derived From Architecture Change Governance)
- **Architecture decision review:** `required`
- **Decision review lifecycle:** `after diagnosis is closed and before APROVADO`
- **Decision review kind:** `architecture_opinion`
- **Decision review package:** `bounded-file-set`
- **Decision review status:** `passed`
- **Decision review evidence / resolution:** `three fresh no-context passes: initial findings integrated; operational gate defects integrated; final pass reported no material findings and architectural convergence`
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
| `A-01` | Current elegance and structural-soundness fields can carry the mandate without a new result-schema axis. | `tools/subagent_review_dispatch.py:19-153`; `schemas/subagent_review_result.schema.json:6-18`; existing dispatch regression test at `tools/tests/subagent_review_dispatch_test.sh`. | A schema change remains unauthorized; concrete insufficiency requires TODO refresh and renewed approval. | `High` | `Keep as Assumption` |
| `A-02` | One compact dedicated TODO section is the simplest reliable direct authority surface for anticipatory implementation intent. | `templates/todo_template.md:28-33` owns current WHAT/authorization semantics; ARCH-02 in this TODO records the three-way placement comparison and D-11 resolves it. | Reopen ARCH-02 and select the simpler proven placement before implementation. | `High` | `Promote to Decision D-11` |
| `A-03` | Objective presence/enum checks may be deterministic, but architectural simplicity remains judgment-led. | `main_instructions.md:217-225` requires proportionate tooling and rejects faux-deterministic judgment; `skills/deterministic-tooling-register.md` is the classification surface. | Reassess only if a precise, low-false-positive invariant is discovered. | `High` | `Promote to Decision D-09` |

## Execution Plan
### Expected Touched Surfaces
- `main_instructions.md`
- `system_architecture_principles.md`
- `templates/todo_template.md`
- `rules/core/todo-driven-execution-model-decision.md`
- relevant stack rule mirrors only where they duplicate the canonical review contract
- `workflows/docker/todo-contract-refinement-method.md`
- `workflows/docker/todo-approval-gates-method.md`
- `workflows/docker/todo-driven-execution-method.md`
- `workflows/docker/todo-delivery-gates-method.md`
- `workflows/docker/independent-critique-method.md`
- `workflows/docker/independent-final-review-method.md`
- `tools/subagent_review_dispatch.py`
- `tools/tests/subagent_review_dispatch_test.sh`
- `tools/review_scope_drift_guard.py`
- `tools/tests/review_scope_drift_guard_test.sh`
- `tools/todo_authority_guard.py`
- `tools/tests/todo_authority_guard_test.sh`
- `tools/audit_instruction_baselines.sh`
- `tools/tests/audit_instruction_baselines_test.sh`
- `skills/wf-docker-todo-driven-execution-method/SKILL.md`
- `skills/wf-docker-todo-delivery-gates-method/SKILL.md`
- other objective TODO guards/tests only if the final contract adds machine-checkable fields
- `tools/manifest.md` (mandatory because the materially changed canonical tools must remain registered)
- `skills/deterministic-tooling-register.md` (refresh materially affected skill classifications/support links)
- concise canonical skill entrypoints affected by the workflow changes
- derived `.clinerules/**`, `.cline/**`, `.claude/**`, and tracked public Codex mirrors selected by existing mirror inventories
- this TODO and its review/evidence artifacts

### Canonical / Derived Ownership and Sync Contract
| Surface | Classification | Required Handling |
| --- | --- | --- |
| `main_instructions.md`, `system_architecture_principles.md` | canonical core | Edit directly; keep project-agnostic. |
| `rules/core/todo-driven-execution-model-decision.md` | canonical shared rule | Own horizon semantics, adoption, lifecycle authority, and delivery recheck. |
| `rules/stacks/laravel/shared/todo-driven-execution-model-decision.md` | compatibility adjunct, not shared authority | Replace the full stack-agnostic duplicate with a concise pointer to the core rule plus only concrete Laravel-specific loading deltas. |
| `templates/todo_template.md` | canonical TODO expression | Add the compact normative horizon section and gate labels. |
| `workflows/docker/todo-*.md`, `independent-*.md` | canonical operational workflows | Carry lifecycle/gate procedures; do not duplicate the full principle. |
| `tools/subagent_review_dispatch.py`, `tools/review_scope_drift_guard.py`, `tools/todo_authority_guard.py`, `tools/audit_instruction_baselines.sh` | canonical deterministic tools | Reuse existing mechanisms; update focused tests and manifest. |
| affected `skills/**/SKILL.md` | concise canonical entrypoints | Update only when their operational responsibilities materially change; refresh deterministic-tooling register. |
| `.clinerules/**` | generated mirror | Run `bash tools/sync_clinerules_mirrors.sh`. |
| `.cline/**`, `.claude/**`, public Codex skills | curated derived mirrors | Discover affected skills with existing inventories, then run `bash tools/sync_cline_skill_mirrors.sh <skill>`, `bash tools/sync_claude_skill_mirrors.sh <skill>`, and `bash tools/sync_codex_public_skill_mirrors.sh <skill>` only where tracked. |

`review_session.md` is excluded from the implementation boundary because no canonical instruction references it as an authority surface; adding another normative home would violate simplification and mirror discipline.

### Ordered Steps
1. Reconcile the foundational mandate wording so future-aware architecture remains valid but does not silently authorize future implementation.
2. Add the implementation-horizon/extensibility-intent contract to the tactical TODO template and refinement/approval flow.
3. Add the dedicated horizon section to the existing scope-drift comparison contract and focused guard tests; require a fresh run before architecture adherence, before final review, and after protected-section remediation.
4. Extend `todo_authority_guard.py` to validate the literal truth table when present, with legacy-absence coverage and no simplicity judgment.
5. Align core TODO/review rules with the explicit-intent authority, lifecycle-specific reviewer semantics, and simplest-faithful-design criteria.
6. Update reviewer workflows and inject one shared dispatch focus fragment while reusing existing elegance and structural-soundness result fields by default; test every review kind.
7. Collapse the Laravel full-rule duplicate into a concise compatibility adjunct; extend the existing instruction-baseline audit and add a negative regression test that rejects shared-authority regrowth.
8. Add focused objective regression coverage and run Delphi self-maintenance checks.
9. Replay `C-01` through `C-09`, run final review gates, and resolve findings without widening the mandate.

### Test Strategy
- **Strategy:** `test-first where objective prompt/template contracts change; review-first for semantic prose`
- **Fail-first targets:** Dispatch tests should initially demonstrate missing explicit TODO-authority/simplification focus; the authority guard should reject invalid horizon truth-table instances; the instruction baseline audit test should first prove the current audit incorrectly accepts a regrown Laravel full-rule duplicate.
- **Judgment boundary:** No test may claim that a particular code design is universally “simple”; tests protect contract propagation, not architectural taste.

## Diff Expectation Contract
- **Contract status:** `required`
- **Policy:** `strict; unclassified or forbidden paths block delivery`
- **User validation:** `required on deviation`
- **Comparison mode:** `working_tree`
- **Deviation policy:** Any unclassified path requires explicit analysis; necessary scope expansion requires TODO refresh and renewed approval.

### Repository Baselines
| Repository | Path | Baseline ref | Comparison mode |
| --- | --- | --- | --- |
| `delphi-ai` | `.` | `hooks-implementation@a6e8e95b8431e81e3a0b073d7260c92a62c942f6` | `working_tree` |

### Expected Changed Paths
| Repository | Path glob | Change types (`A|M|D|R|any`) | Reason |
| --- | --- | --- | --- |
| `delphi-ai` | `main_instructions.md` | `M` | Foundational delivery mandate. |
| `delphi-ai` | `system_architecture_principles.md` | `M` | Foundational/future implementation boundary. |
| `delphi-ai` | `templates/todo_template.md` | `M` | Normative horizon truth table. |
| `delphi-ai` | `rules/core/todo-driven-execution-model-decision.md` | `M` | Sole stack-agnostic TODO authority. |
| `delphi-ai` | `rules/stacks/laravel/shared/todo-driven-execution-model-decision.md` | `M` | Concise Laravel compatibility adjunct. |
| `delphi-ai` | `workflows/docker/todo-driven-execution-method.md` | `M` | Umbrella lifecycle invariant. |
| `delphi-ai` | `workflows/docker/todo-contract-refinement-method.md` | `M` | Horizon refinement semantics. |
| `delphi-ai` | `workflows/docker/todo-approval-gates-method.md` | `M` | Planning reviewer authority. |
| `delphi-ai` | `workflows/docker/todo-delivery-gates-method.md` | `M` | Delivery drift freshness and binding authority. |
| `delphi-ai` | `workflows/docker/independent-critique-method.md` | `M` | Planning challenge boundary. |
| `delphi-ai` | `workflows/docker/independent-final-review-method.md` | `M` | Delivery adherence boundary. |
| `delphi-ai` | `skills/wf-docker-todo-driven-execution-method/SKILL.md` | `M` | Concise umbrella entrypoint. |
| `delphi-ai` | `skills/wf-docker-todo-delivery-gates-method/SKILL.md` | `M` | Concise delivery entrypoint. |
| `delphi-ai` | `skills/rule-laravel-shared-todo-driven-execution-model-decision/SKILL.md` | `M` | Concise Laravel trigger entrypoint pointing to the sole core authority. |
| `delphi-ai` | `skills/deterministic-tooling-register.md` | `M` | Refresh support notes for the materially changed workflow skills. |
| `delphi-ai` | `.clinerules/**` | `M` | Generated rule/workflow mirrors. |
| `delphi-ai` | `.cline/skills/wf-docker-todo-*/SKILL.md` | `M` | Curated Cline skill mirrors. |
| `delphi-ai` | `.claude/skills/wf-docker-todo-*/SKILL.md` | `M` | Curated Claude skill mirrors. |
| `delphi-ai` | `.cline/skills/rule-laravel-shared-todo-driven-execution-model-decision/SKILL.md` | `M` | Derived Cline mirror of the concise Laravel trigger entrypoint. |
| `delphi-ai` | `.claude/skills/rule-laravel-shared-todo-driven-execution-model-decision/SKILL.md` | `M` | Derived Claude mirror of the concise Laravel trigger entrypoint. |
| `delphi-ai` | `tools/audit_instruction_baselines.sh` | `M` | Laravel authority-regrowth audit. |
| `delphi-ai` | `tools/manifest.md` | `M` | Updated deterministic tool purposes. |
| `delphi-ai` | `tools/review_scope_drift_guard.py` | `M` | Horizon becomes a protected section. |
| `delphi-ai` | `tools/subagent_review_dispatch.py` | `M` | Shared and lifecycle-specific reviewer authority. |
| `delphi-ai` | `tools/todo_authority_guard.py` | `M` | Objective horizon truth-table validation. |
| `delphi-ai` | `tools/verify_adherence_sync.sh` | `M` | Existing semantic sync validator covers the full simplification mandate. |
| `delphi-ai` | `tools/tests/audit_instruction_baselines_test.sh` | `any` | Negative Laravel duplicate-authority fixture (untracked until the implementation commit). |
| `delphi-ai` | `tools/tests/review_scope_drift_guard_test.sh` | `M` | Explicit horizon drift regression. |
| `delphi-ai` | `tools/tests/subagent_review_dispatch_test.sh` | `M` | All-kind reviewer authority assertions. |
| `delphi-ai` | `tools/tests/todo_authority_guard_test.sh` | `M` | Per-mode, placeholder, missing-field, and legacy coverage. |
| `delphi-ai` | `foundation_documentation/todos/active/delphi-simplification-first-review-authority.md` | `M` | Approval, execution, and delivery evidence. |

### Not Expected Changed Paths
| Repository | Path glob | Change types (`A|M|D|R|any`) | Reason |
| --- | --- | --- | --- |
| `delphi-ai` | `config/**` | `any` | No routing/config contract change is authorized. |
| `delphi-ai` | `schemas/**` | `any` | No new or changed result-schema axis is authorized. |
| `delphi-ai` | `artifacts/**` | `any` | No generated evidence artifact is required in the tracked diff. |
| `delphi-ai` | `rules/stacks/flutter/**` | `any` | Flutter-specific rules are outside this stack-agnostic correction. |
| `delphi-ai` | `workflows/flutter/**` | `any` | Flutter implementation workflows are out of scope. |
| `delphi-ai` | `workflows/laravel/**` | `any` | Laravel application workflows are out of scope; only the shared compatibility adjunct changes. |
| `delphi-ai` | `.env*` | `any` | Secrets/runtime environment files are forbidden. |
| `delphi-ai` | `.gitmodules` | `any` | Submodule topology is outside this instruction-only session. |

### Diff Deviation Analysis
| Diff item | Classification (`scope deviation|necessary need|noise`) | Evidence / agent defense | Decision (`revert|clean noise|retain with renewed approval`) | User validation / renewed approval |
| --- | --- | --- | --- | --- |
| `none` | `necessary need` | `All current paths are explicitly classified above.` | `n/a` | `renewed APROVADO already recorded for D-01 through D-18` |

## Plan Review Gate
- **Status:** `architecture opinion converged; independent critique pending`
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
| `AO-RR-01-push-ref` | `Integrated` | `useful` | Push reference corrected to the resolvable `origin/hooks-implementation` ref; commit identity remains separately recorded. |
| `AO-RR-02-current-cycle-horizon-drift` | `Integrated` | `useful` | Existing guard/test are now explicit implementation surfaces; current cycle uses a bounded direct horizon-section comparison until the approved guard update lands. |
| `AO-FP-01-stale-status` | `Integrated` | `useful` | Updated Next Exact Step and Plan Review status to reflect the completed baseline freeze and converged architecture opinion. |

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
- [ ] Exact affected skill mirror inventory must be resolved with the existing list/sync helpers after canonical workflow edits identify the materially changed entrypoints.
- [ ] Any evidence that current elegance/structural fields are insufficient is approval-material and requires TODO refresh; no new result-schema axis is authorized by this baseline.

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
- **Baseline commit:** `a6e8e95b8431e81e3a0b073d7260c92a62c942f6`
- **Baseline push reference:** `origin/hooks-implementation`
- **Gate status:** `no_material_findings`
- **Findings summary:** `Planning review converged at ddfb82a; the user then renewed APROVADO for D-01 through D-18, and a6e8e95 records that approval, the frozen-decision checkbox, rule ingestion, and implementation routing without changing scope or intent.`
- **Evidence / reference:** `planning-reviewed baseline ddfb82a + renewed user APROVADO + approval-recorded baseline a6e8e95 pushed to origin/hooks-implementation`
- **Waiver authority / reference:** `n/a`
- **Pre-freeze packet-prep rule:** `all current loop results are self-review preparation, not gate-satisfying independent review evidence`

## Gate: Review Scope Drift
- **Gate decision:** `required`
- **Why this decision:** The cross-canonical scope must remain faithful to the user conclusions after reviewer findings are integrated.
- **Trigger stage:** `after the planning-side review/guard cycle converges and before APROVADO`
- **Baseline source:** `Review Baseline Freeze -> Baseline commit`
- **Material sections compared:** `Context|Contract Boundary|Scope|Out of Scope|Implementation Horizon & Extensibility Intent|Definition of Done|Validation Steps|Canonical Module Anchors|Decisions|Decision Baseline|Architecture Change Governance|Assumptions Preview|Execution Plan`
- **Guard command:** `python3 delphi-ai/tools/review_scope_drift_guard.py --todo foundation_documentation/todos/active/delphi-simplification-first-review-authority.md`
- **Current-cycle horizon bootstrap comparison:** `required; directly compare the complete Implementation Horizon & Extensibility Intent section against the refreshed pushed baseline and require no drift before renewed APROVADO`
- **Gate status:** `no_material_findings`
- **Findings summary:** `The approval-recorded baseline contains the complete frozen D-01 through D-18 contract; approval bookkeeping introduced no scope, authority, horizon, or implementation-obligation drift.`
- **Evidence / reference:** `planning close at ddfb82a + renewed APROVADO + approval-recorded baseline a6e8e95; delivery-side fresh guard evidence recorded before each required dispatch`
- **Waiver authority / reference:** `n/a`

## Questions To Close
- [x] Should future-aware planning be removed? `No; preserve it and separate it from tactical implementation authority.`
- [x] Can anticipatory abstraction be valid? `Yes, when directly recorded and approved in the TODO.`
- [x] May reviewers invent or erase that intent? `No; they evaluate the simplest faithful realization of explicit intent.`
- [x] Does the final implementation require a new review-result schema axis? `No. Existing elegance/structural fields are authoritative; concrete insufficiency requires TODO refresh and renewed approval.`

## Independent No-Context Critique Gate
- **Critique decision:** `required`
- **Why this decision:** `medium`, cross-stack reusable behavior, public TODO/reviewer contract change, and high-severity architecture issues.
- **Package mode:** `bounded-file-set`
- **Critique isolation mode:** `fresh internal no-context reviewer`
- **Critique status:** `no_material_findings`
- **Findings summary:** `Three high, eight medium, and one low finding were integrated across the full loop; the final D-18 traceability rerun found no material issue and only two non-blocking wording corrections, both applied.`
- **Evidence / reference:** `fresh no-context reviewers simplification_independent_critique through simplification_d18_final_critique plus simplification_editorial_scope_close; final refreshed baseline ddfb82af08895458176dade6bb0aa8950154330a`
- **Waiver authority / reference:** `n/a`

### Critique Finding Resolution
| Finding ID | Severity | Resolution | Usefulness | Rationale / Evidence |
| --- | --- | --- | --- | --- |
| `CR-01-D07-lifecycle` | `high` | `Integrated` | `useful` | D-07 is now delivery/adherence-specific; D-10 retains planning challenge authority. |
| `CR-02-full-lifecycle-drift` | `high` | `Integrated` | `useful` | D-14 binds horizon to frozen approval and reruns the existing guard before delivery review. |
| `CR-03-mode-schema` | `medium` | `Integrated` | `useful` | Exact modes and conditional field semantics are defined before approval. |
| `CR-04-lazy-adoption` | `medium` | `Integrated` | `useful` | D-13 preserves approved legacy decisions and adopts at next approval-material refresh. |
| `CR-05-ownership-sync` | `medium` | `Integrated` | `useful` | Canonical/derived table, sync commands, mandatory manifest/register updates, and `review_session.md` exclusion are explicit. |
| `CR-06-path-evidence` | `medium` | `Integrated` | `useful` | A-01 now cites dispatch, schema, and focused test paths; schema-axis question is closed. |
| `CR-07-all-kind-tests` | `low` | `Integrated` | `useful` | Validation now requires every dispatch review kind to assert shared and lifecycle-specific semantics. |
| `CR-RR-01-delivery-drift-operationalization` | `high` | `Integrated` | `useful` | Added D-15, exact umbrella/delivery workflow and skill surfaces, per-dispatch/after-remediation timing, approved-baseline binding, and focused stale-between-reviews coverage. |
| `CR-RR-02-truth-table-adoption` | `medium` | `Integrated` | `useful` | Added literal per-mode truth table, canonical `none`, current-only abstraction clarification, legacy adoption boundary, existing authority-guard owner, and focused tests. |
| `CR-FP-01-laravel-duplicate-authority` | `medium` | `Integrated` | `useful` | D-17 makes the core rule sole shared authority and converts the Laravel path into a concise compatibility adjunct with Laravel-only deltas. |
| `CR-OC-01-duplication-harness-boundary` | `medium` | `Integrated` | `useful` | Added the existing baseline-audit script and focused negative test to scope, expected diff, DoD, validation, harness, and ordered execution. |
| `CR-HC-01-D18-DoD-traceability` | `medium` | `Integrated` | `useful` | Definition of Done now explicitly requires the existing baseline audit plus a negative regression test to reject renewed Laravel duplication of shared authority. |

## Gate: Assumption Code Coherence
- **Gate decision:** `required`
- **Why this decision:** `A-01` through `A-03` cite exact existing template, schema, dispatch, and governance behavior that must be verified after critique.
- **Trigger stage:** `after critique convergence and before APROVADO`
- **Guard scope:** `A-01,A-02,A-03`
- **Guard command:** `python3 delphi-ai/tools/assumption_code_coherence_guard.py --todo foundation_documentation/todos/active/delphi-simplification-first-review-authority.md`
- **Gate status:** `no_material_findings`
- **Findings summary:** `A-01 direction matches the existing dispatch/result schema and focused test surfaces; A-02 and A-03 were promoted into frozen-candidate decisions D-11 and D-09 rather than left as ungoverned assumptions.`
- **Evidence / reference:** `tools/subagent_review_dispatch.py:19-153; schemas/subagent_review_result.schema.json:6-18; tools/tests/subagent_review_dispatch_test.sh; templates/todo_template.md:28-33; main_instructions.md:217-225`
- **Waiver authority / reference:** `n/a`

## Approval
- **Approved by:** `user on 2026-08-30; retain the D-01 through D-18 mandate implementation and remove every change not derived from that mandate`
- **Approval scope:** `the repository tree represented by a2e0cd8, before delivery-review expansions into phrase parsing, waiver semantics, escaped-pipe parsing, and lifecycle orchestration`
- **Execution not authorized by approval:** `downstream project changes, runtime/deploy changes, new policy engines or schemas, speculative migrations, and any objective outside this TODO`
- **Renewed approval required when:** `any reviewer or implementation proposes restoring or replacing a removed expansion`

## Agent Routing Preflight
- **Client surface:** `codex`
- **Current governed action:** `implementation`
- **Selected role:** `routine-executor`
- **Selected model:** `gpt-5.6-terra`
- **Selected effort:** `medium`
- **Proof mode:** `declared`
- **Subagent / delegation authorization:** `authorized by this TODO's required internal review gates and user APROVADO`
- **Execution topology:** `primary-checkout-single-writer`
- **Worktree / auxiliary-checkout authorization:** `not-authorized`
- **Writer scheduling policy:** `single-writer-serialized`
- **Guard outcome:** `go`
- **Evidence:** `agent_role_routing_guard.py returned Overall outcome: go for routine-executor implementation on the primary-checkout-single-writer topology after renewed APROVADO`

## Rules Acknowledgement / Ingestion
- **Status:** `ingested after renewed APROVADO and before implementation`

| Source | Why It Applies Now | Must Preserve | Must Avoid | Execution Impact |
| --- | --- | --- | --- | --- |
| `main_instructions.md` | Primary authority for Delphi self-maintenance and foundational behavior. | Project agnosticism, documented authority, proportional determinism, and guarded git writes. | Downstream-specific truth, competing policy homes, or unguarded commit/push. | Keep all mutations inside Delphi and validate canonical consistency before closeout. |
| `rules/core/todo-driven-execution-model-decision.md` | This is an approved full tactical TODO changing canonical rules and tools. | Frozen D-01 through D-18, strict diff boundary, criterion-specific evidence, and renewed approval on material drift. | Hidden scope expansion or delivery claims without guards. | Run the authority guard before execution and all delivery guards before completion. |
| `workflows/docker/self-improvement-session-method.md` | The user explicitly opened a Delphi self-improvement session. | Instruction-only scope, agnosticism review, canonical synchronization, and explicit session closure. | Mixing downstream product work into this session. | Treat canonical instruction/tool changes and their tests as the only implementation scope. |
| `workflows/docker/todo-execution-boundary-method.md` | Execution is starting after renewed approval. | One serialized writer in the principal checkout and approved touched surfaces only. | Worktrees, concurrent writers, or unapproved objectives. | Route writing to the declared routine executor and stop on approval-material discoveries. |
| `workflows/docker/todo-delivery-gates-method.md` | Cross-canonical delivery requires evidence, reviews, and deterministic completion gates. | Scope-drift freshness before adherence/final review and criterion-specific validation. | Aggregate-only evidence or stale reviewer baselines. | Populate delivery evidence and run required audit/review lanes before closeout. |
| `workflows/docker/update-skill-method.md` | Canonical workflow skills and derived client mirrors are expected to change. | Concise skills pointing to canonical sources and synchronized Cline/Claude/Codex mirrors. | Full-body duplication or hand-edited derived drift. | Use existing sync scripts and refresh the tooling register only for materially changed skills. |
| `skills/test-creation-standard/SKILL.md` | Objective guards and focused regression tests change. | Test-first behavior contracts, meaningful negative fixtures, and no faux simplicity automation. | Tests that only assert text presence without the approved conditional semantics. | Add fail-first cases for horizon truth tables, dispatch lifecycle authority, drift freshness, and Laravel authority regrowth. |
