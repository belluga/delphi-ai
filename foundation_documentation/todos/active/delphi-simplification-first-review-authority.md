# TODO: Establish Simplification First and Explicit TODO Intent

## Context
Delphi must choose the simplest Clean Code/SOLID architecture that faithfully implements approved intent. Simplicity is not minimum diff or automatic avoidance of abstraction. It may require removing or consolidating existing layers, while scattered conditionals, duplicated decisions, and hidden coupling remain unacceptable.

Foundation documentation may plan future architecture. That planning does not automatically authorize future-facing implementation. A developer may intentionally authorize anticipatory extensibility, but that intention must be explicit in the governing TODO. Reviewers may question a proposed decision during planning; they may not invent absent future work or erase approved intent during delivery.

## Delivery Status Canon
- **Current delivery stage:** `Pending`
- **Qualifiers:** `none`
- **Next exact step:** Await user confirmation that the coherence loop is complete.

## Active Work State
- **Work state:** `review`
- **Why this state now:** The mandate is implemented and review-driven expansions outside it were removed.
- **Exit condition:** User confirms this self-improvement session is complete.

## Scope
- [x] `C-01` Simplification first is not minimal change; judge the resulting structure, not diff size.
- [x] `C-02` The target is the simplest Clean Code/SOLID solution; do not replace an abstraction with scattered conditions or duplication.
- [x] `C-03` Existing solutions may need layers removed; consider subtraction and consolidation before addition.
- [x] `C-04` Foundation documentation may plan future architecture; preserve that planning.
- [x] `C-05` Future planning does not itself authorize implementation; current TODO-governed authority comes from the TODO.
- [x] `C-06` A developer may intentionally authorize anticipatory extensibility; record it directly in the TODO.
- [x] `C-07` Explicit approved TODO intent is binding in delivery; reviewers cannot erase it autonomously.
- [x] `C-08` Reviewers cannot invent absent future-facing complexity; ambiguity returns to the developer/user.
- [x] `C-09` Authorized extensibility remains subject to simplification; implement the simplest faithful form of the approved future-facing work.

## Out of Scope
- [ ] Require special phrases or mechanically judge architectural simplicity.
- [ ] Add or change guards, schemas, reviewer topology, evidence semantics, or lifecycle behavior.
- [ ] Modify downstream project code or project-specific foundation documentation.

## Implementation Intent
- **Current delivery:** Delphi instruction, TODO-template, and reviewer-authority alignment described in this TODO.
- **Planned next steps:** `none`
- **Anticipatory implementation authorized now:** `none`
- **Rationale:** The existing instruction, TODO, rule, dispatch, and mirror mechanisms can express the mandate without a new subsystem.

## Definition of Done
- [x] Canonical principles contain the complete mandate.
- [x] The TODO template separates current delivery, planned next steps, and anticipatory implementation authorized now.
- [x] Core TODO guidance states that foundation planning does not itself authorize future-facing implementation.
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

## Changed Surfaces
| Surface | Why It Remains |
| --- | --- |
| `main_instructions.md`, `system_architecture_principles.md` | Canonical mandate. |
| `templates/todo_template.md` | Direct expression of current, planned, and anticipatory intent. |
| `rules/core/todo-driven-execution-model-decision.md` | Canonical TODO authority. |
| `tools/subagent_review_dispatch.py` and its focused test | Reuse the existing dispatch path to carry reviewer guidance. |
| Canonical/derived instruction mirrors | Keep supported clients aligned. |

## Approval
- **Approved by:** `user on 2026-08-30`
- **Approval scope:** `retain only changes directly implementing C-01 through C-09 and remove every unrelated review-driven expansion`
- **Execution not authorized by approval:** `new validation or reviewer subsystems, or downstream changes`
- **Renewed approval required when:** `a future change proposes any excluded mechanism or materially changes C-01 through C-09`

## Rules Acknowledgement / Ingestion
- **Status:** `ingested`

| Source | Why It Applies Now | Must Preserve | Must Avoid | Execution Impact |
| --- | --- | --- | --- | --- |
| `main_instructions.md` | Primary Delphi authority. | Project agnosticism and self-improvement boundary. | Downstream-specific truth. | Keep edits inside Delphi. |
| `workflows/docker/self-improvement-session-method.md` | This is a self-improvement session. | Canonical coherence and explicit session closure. | Returning to project work before closure. | Await user confirmation after validation. |
| `rules/core/todo-driven-execution-model-decision.md` | The active TODO governs this implementation. | Approved boundary and explicit intent. | Hidden scope expansion. | Remove, rather than replace, unrelated changes. |
