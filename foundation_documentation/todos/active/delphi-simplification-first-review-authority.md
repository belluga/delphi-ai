# TODO: Establish Simplification First and Explicit TODO Intent

## Context
Delphi must choose the simplest Clean Code/SOLID architecture that faithfully implements approved intent. Simplicity is not minimum diff, minimum file count, or automatic avoidance of abstraction. It may require removing or consolidating existing layers, while scattered conditionals, duplicated decisions, and hidden coupling remain unacceptable.

Foundation documentation may plan future architecture. That planning does not automatically authorize future-facing implementation. A developer may intentionally authorize anticipatory extensibility, but that intention must be explicit in the governing TODO. Reviewers may question a proposed decision during planning; they may not invent absent future work or erase approved intent during delivery.

## Contract Boundary
- Establish this mandate in Delphi's canonical instructions and reviewer guidance.
- Add one direct TODO field group separating current delivery, planned next steps, and anticipatory implementation authorized now.
- Reuse existing TODO and reviewer mechanisms.
- Do not add a simplicity engine, result-schema axis, semantic prose parser, specialized approval grammar, or new reviewer topology.

## Delivery Status Canon
- **Current delivery stage:** `Pending`
- **Qualifiers:** `none`
- **Next exact step:** Await user confirmation that the coherence loop is complete.

## Active Work State
- **Work state:** `review`
- **Why this state now:** The mandate is implemented and review-driven expansions outside it were removed.
- **Exit condition:** User confirms this self-improvement session is complete.

## Scope
- [x] State `SIMPLIFICATION FIRST` as the simplest faithful Clean Code/SOLID design, not the smallest change.
- [x] State that simplification may remove, consolidate, or redesign unnecessary layers.
- [x] Reject fake simplicity through scattered conditionals, duplication, or hidden coupling.
- [x] Preserve future-aware foundation planning without treating it as implementation authority.
- [x] Require future-facing implementation intent to be explicit in the TODO.
- [x] Preserve explicitly approved anticipatory extensibility.
- [x] Prevent reviewers from inventing or erasing TODO intent autonomously.
- [x] Reuse existing reviewer fields and dispatch mechanisms.

## Out of Scope
- [ ] Judge architectural simplicity mechanically.
- [ ] Parse free-form reviewer findings or approval language.
- [ ] Change P1/P2 evidence semantics, waiver semantics, Markdown table parsing, or lifecycle CLI behavior.
- [ ] Add schemas, policy engines, reviewer kinds, or delivery gates.
- [ ] Modify downstream project code or project-specific foundation documentation.

## Implementation Horizon & Extensibility Intent
- **Current delivery:** Delphi instruction, TODO-template, and reviewer-authority alignment described in this TODO.
- **Planned next steps:** `none`
- **Anticipatory implementation authorized now:** `none`
- **Rationale:** The existing instruction, TODO, dispatch, workflow, skill, and mirror mechanisms can express the mandate without a new subsystem.

## Definition of Done
- [x] Canonical principles contain the complete mandate.
- [x] The TODO template separates current delivery, planned next steps, and anticipatory implementation authorized now.
- [x] Core TODO guidance states that foundation planning is not current implementation authority.
- [x] Planning reviewers may challenge intent; delivery reviewers preserve approved intent or return for renewed approval.
- [x] Reviewer dispatches receive the shared non-invention and simplest-faithful guidance.
- [x] Derived mirrors are synchronized.
- [x] No unrelated semantic validator or orchestration layer remains in the final diff.

## Validation Steps
- [x] Run `bash tools/tests/subagent_review_dispatch_test.sh`.
- [x] Run `bash self_check.sh`.
- [x] Run `git diff --check`.
- [x] Search canonical and derived surfaces for contradictory future-implementation or reviewer-authority wording.
- [x] Compare the final tree against the pre-expansion implementation boundary and remove unrelated review-driven changes.

## Conversation Coherence Contract
| ID | Confirmed Conclusion | Required Consequence |
| --- | --- | --- |
| `C-01` | Simplification first is not minimal change. | Judge resulting structure, not diff size. |
| `C-02` | The target is the simplest Clean Code/SOLID solution. | Do not replace ownership with scattered conditions or duplication. |
| `C-03` | Existing solutions may need layers removed. | Consider subtraction and consolidation before addition. |
| `C-04` | Foundation documentation may plan future architecture. | Preserve future planning. |
| `C-05` | Future planning does not itself authorize implementation. | Current authority comes from the TODO. |
| `C-06` | A developer may intentionally authorize anticipatory extensibility. | Record it directly in the TODO. |
| `C-07` | Explicit approved TODO intent is binding in delivery. | Reviewers cannot erase it autonomously. |
| `C-08` | Reviewers cannot invent absent future-facing complexity. | Ambiguity returns to the developer/user. |
| `C-09` | Authorized extensibility remains subject to simplification. | Implement the simplest faithful form of the approved seam. |

## Decisions
- [x] `D-01` Use the simplest faithful Clean Code/SOLID architecture for approved intent.
- [x] `D-02` Treat subtraction, consolidation, and redesign as valid simplification tools.
- [x] `D-03` Keep foundation planning separate from tactical implementation authority.
- [x] `D-04` Express anticipatory implementation intent directly in the TODO.
- [x] `D-05` Treat explicit approved intent as binding during delivery review.
- [x] `D-06` Let planning review challenge decisions without rewriting them.
- [x] `D-07` Reuse existing reviewer fields and dispatch mechanisms.
- [x] `D-08` Keep deterministic checks limited to existing structural/coherence checks; do not automate architectural judgment.
- [x] `D-09` Remove every review-driven change without a direct line to this mandate rather than correcting or replacing it.

## Changed Surfaces
| Surface | Why It Remains |
| --- | --- |
| `main_instructions.md`, `system_architecture_principles.md` | Canonical mandate. |
| `templates/todo_template.md` | Direct expression of current, planned, and anticipatory intent. |
| `rules/core/todo-driven-execution-model-decision.md` | Canonical TODO authority. |
| TODO refinement/approval/execution and independent-review workflows | Lifecycle-appropriate reviewer authority. |
| `tools/subagent_review_dispatch.py` and its focused test | Reuse the existing dispatch path to carry reviewer guidance. |
| Canonical/derived instruction mirrors | Keep supported clients aligned. |

## Approval
- **Approved by:** `user on 2026-08-30`
- **Approval scope:** `retain only changes directly implementing C-01 through C-09 and remove every unrelated review-driven expansion`
- **Execution not authorized by approval:** `new guards, phrase grammars, waiver rules, Markdown parsing, lifecycle CLI changes, reviewer topology, schemas, or downstream changes`
- **Renewed approval required when:** `a future change proposes any excluded mechanism or materially changes C-01 through C-09`

## Rules Acknowledgement / Ingestion
- **Status:** `ingested`

| Source | Why It Applies Now | Must Preserve | Must Avoid | Execution Impact |
| --- | --- | --- | --- | --- |
| `main_instructions.md` | Primary Delphi authority. | Project agnosticism and self-improvement boundary. | Downstream-specific truth. | Keep edits inside Delphi. |
| `workflows/docker/self-improvement-session-method.md` | This is a self-improvement session. | Canonical coherence and explicit session closure. | Returning to project work before closure. | Await user confirmation after validation. |
| `rules/core/todo-driven-execution-model-decision.md` | The active TODO governs this implementation. | Approved boundary and explicit intent. | Hidden scope expansion. | Remove, rather than replace, unrelated changes. |

## Coherence Result
- Canonical conclusions `C-01` through `C-09`: `preserved`
- Unrelated post-implementation review machinery: `removed`
- Remaining specialized simplicity subsystem: `none`
- Project-specific content in reusable Delphi canon: `none`
- Required additional reviewer loop: `none`
