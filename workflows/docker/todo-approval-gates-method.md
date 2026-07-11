---
description: Run planning review, audit-floor decisions, critique, and explicit approval gates before TODO implementation starts.
---

# Method: TODO Approval Gates

## Purpose
Validate the refined TODO before execution and obtain explicit approval. This phase protects against implementing under ambiguous scope, stale decisions, weak evidence planning, or insufficient audit floor.

## Inputs
- Refined tactical TODO.
- Complexity classification.
- Optional bounded pre-approval RED evidence capture plan when the TODO is a bugfix/regression and symptom reproduction is still materially ambiguous.
- Audit trigger matrix when required.
- Bounded review packages for critique/dedicated multi-lane audit when triggered.
- Assumption-vs-code coherence evidence for the still-live assumptions.

## Procedure
1. Freeze or refresh the `Decision Baseline (Frozen)` before execution.
2. Freeze a pushed review baseline before the first planning-side review or guard:
   - commit and push the governing TODO package in its authoritative repo (normally `foundation_documentation`); when that authoritative documentation lane is documented as autonomous for baseline refresh/freeze writes, no extra per-action confirmation is required unless the user set a stricter boundary;
   - before those direct writes, run `python3 delphi-ai/tools/git_write_authority_guard.py --repo <authoritative-repo-path> --action <git-commit|git-push>` and require `Overall outcome: go`;
   - record `Gate: Review Baseline Freeze` with the baseline branch, commit SHA, push reference, and evidence;
   - if the baseline-evidence update itself changes any scope-governing section, refresh the freeze so the recorded baseline matches the package that will actually enter review.
   - if the TODO is still drafting its review packet before this gate is satisfied or waived, record that work only as packet preparation using explicit provisional wording such as `prepared-pre-freeze` or `pending-freeze`; do **not** mark planning-side review/guard rows as `passed` until the freeze requirement is satisfied or explicitly waived and the authoritative review/guard actually ran.
3. Run the Module Coherence Gate:
   - check that active decisions align with module docs and project constitution;
   - raise approval-material drift before implementation.
4. Resolve COMMENT blocks and open material decisions.
5. Run Plan Review Gate:
   - `small`: abbreviated unless risk requires full review;
   - `medium|big`: full issue cards, failure modes, and residual unknowns.
   - Load `workflows/docker/effort-selection-method.md` when the active client exposes named effort controls or persistent GOAL support. TODO approval/plan review and any gate-satisfying review subagents use the highest review-focused tier; review subagents remain stateless by default unless the tool/client requires resumable reviewer state for a bounded package.
   - When those controls apply, predeclare the planned implementation, monitoring, and review lanes so post-approval execution can record `Agent Routing Preflight` and run the deterministic routing guard fail-closed.
6. Populate the TODO `Audit Trigger Matrix` and run:
   - `python3 delphi-ai/tools/audit_escalation_guard.py --todo <todo-path>`
   - require `Overall outcome: go` before trusting audit decisions.
7. If the TODO records `Pre-APROVADO RED Evidence Capture = required|recommended`, run that bounded RED capture now:
   - allow edits only in the test/support surfaces explicitly listed in the TODO;
   - prohibit production/runtime/doc changes;
   - record the outcome as `red_reproduced|red_not_reproduced|blocked`;
   - if the RED result invalidates the current direction or widens the failure surface, refresh the TODO and rerun the audit floor before approval resumes.
8. Run the derived architecture decision review when `architecture_decision_review = required`:
   - only after the diagnosis (including any required RED capture) is closed and before the proposed solution is frozen;
   - dispatch a fresh no-context reviewer with `review_kind=architecture_opinion` and a bounded package containing the diagnosis, viable paths, Architecture Change Governance contract, Decision Baseline draft, and material trade-offs;
   - resolve material findings into the TODO before critique and `APROVADO` continue.
9. Run the derived critique/dedicated multi-lane audit lanes when required or recommended by the audit floor.
10. After the planning reviews converge, including any bounded RED capture updates, run the assumption-vs-code coherence guard:
   - `python3 delphi-ai/tools/assumption_code_coherence_guard.py --todo <todo-path>`
   - require `Overall outcome: go` before requesting `APROVADO`, unless the guard is explicitly waived by the current human approval authority.
   - if the guard surfaces a wrong code assumption or any approval-material/significant change, send the TODO back to the review loop: refresh the TODO and rerun the affected review/critique lane before approval.
11. Run the post-review scope-drift guard:
   - `python3 delphi-ai/tools/review_scope_drift_guard.py --todo <todo-path>`
   - require `Overall outcome: go` before requesting `APROVADO`, unless the current human approval authority explicitly waives the guard;
   - if the guard reports material drift in scope-governing sections, return the TODO to the review loop, revalidate the evolved scope with the user, refresh the pushed baseline when needed, and rerun the affected review/guard lanes before approval; treat this as a reconvergence checkpoint, not a rigid rejection.
12. Ask the user to reply with **`APROVADO`** for tactical and ephemeral TODO lanes.
13. After approval, record the compact `Approval` evidence section in the TODO: approver/reference, exact approved scope, exclusions, and renewed-approval trigger.

## Outputs
- Plan Review Gate evidence.
- Audit-floor evidence and required critique/dedicated multi-lane audit evidence.
- Optional bounded RED evidence capture results when used.
- Frozen decision baseline.
- Explicit approval record.

## Non-Negotiables
- No implementation before `APROVADO`.
- Bounded pre-approval RED evidence capture is allowed only when the TODO explicitly authorizes it and only on listed test/support surfaces; it never authorizes production changes.
- No planning-side review or guard run before `Gate: Review Baseline Freeze` is satisfied or explicitly waived.
- Pre-freeze packet preparation must not masquerade as authoritative review completion; use explicit provisional wording such as `prepared-pre-freeze` or `pending-freeze` until the freeze requirement is satisfied or waived and the actual review/guard has run.
- The assumption-vs-code coherence guard must be clean or explicitly waived before `APROVADO`.
- The post-review scope-drift guard must be clean or explicitly waived before `APROVADO`.
- A required architecture decision review must be resolved or explicitly waived before `APROVADO`.
- Approval evidence must be recorded in the TODO; do not rely on chat memory alone after the gate has passed.
- If approval-material scope, decision, validation, or architecture facts change, refresh the TODO, revalidate the new scope with the user, and request renewed `APROVADO`.
- Do not treat post-review scope-drift `no-go` as terminal failure; it means the TODO must reconverge through renewed user scope validation before approval resumes.
- Do not substitute ad hoc reviewer sequencing for the dedicated multi-lane audit workflow when the derived floor requires or recommends it.
