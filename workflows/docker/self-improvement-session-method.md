---
description: Run instruction-only sessions safely, ensuring `delphi-ai/` stays project-agnostic and no architectural work proceeds under stale directives, per Section 3 of `main_instructions.md`.
---

# Method: Self Improvement Session

## Purpose
Run instruction-only sessions safely, ensuring `delphi-ai/` stays project-agnostic and no architectural work proceeds under stale directives, per Section 3 of `main_instructions.md`.

## Triggers
- User initiates a "Self Improvement Session".
- Delphi instructions (`delphi-ai/*.md`) require updates/refactors.

## Inputs
- Current `delphi-ai` core files (main instructions, system principles, ecosystem config, templates).
- `templates/self_improvement_work_ledger_template.md` when the self-improvement scope is long enough to need a temporary tracked ledger.
- Manual agnosticism review of the edited Delphi surfaces.
- Applicable local checks for the changed file types (for example `bash self_check.sh` for governance surfaces or `bash -n` for edited shell scripts).

## Procedure
1. **Profile Selection** – run the Profile Selection Method; typically `Strategic / CTO-Tech-Lead` for instruction work.
2. **Freeze architectural work** – acknowledge that implementation work (project code, submodule code, and project-specific docs) is paused; this session is for discussion + instruction refinement only. Editing within `delphi-ai/` is permitted.
3. **Correction scope triage** – when the trigger is a user correction or a newly noticed behavior gap, classify it before editing anything:
   - `Session`: current-session recalibration only; do not edit `delphi-ai/`.
   - `Project`: downstream/project-specific correction; do not edit `delphi-ai/` unless the user explicitly expands it into Delphi method.
   - `Delphi`: reusable method/instruction gap appropriate for canonical Delphi refinement.
   - Ask the user to validate scope only when the correction appears eligible for canonization beyond the current local fix. In that case, I may suggest the recommended scope (`Session`, `Project`, or `Delphi`) instead of asking neutrally.
   - If the correction invalidates prior assumptions, explicitly restate confirmed facts, invalidated assumptions, and open questions before deciding to edit Delphi.
4. **Temporary work-ledger decision** – decide whether the current self-improvement scope is long or multi-step enough to need a temporary session ledger.
   - Use a temporary ledger when the work spans multiple rounds, multiple instruction surfaces, or non-trivial sequencing/blocker management.
   - If needed, create/update `delphi-ai/artifacts/tmp/self-improvement-work-ledger.md` using `templates/self_improvement_work_ledger_template.md`.
   - This ledger is strictly temporary and non-authoritative:
     - it is not a tactical TODO;
     - it does not authorize implementation outside `delphi-ai/`;
     - it does not replace canonical instructions;
     - it must be deleted or explicitly refreshed when the active self-improvement scope closes.
5. **Plan updates** – list the instruction files to edit and the rationale. If the correction was not classified as `Delphi`, stop here and record the appropriate non-Delphi follow-up instead of editing `delphi-ai/`.
6. **Apply changes** – edit `delphi-ai/*.md` (and templates) as required.
7. **Agnosticism & consistency verification**
   - Review the edited Delphi files and diffs to ensure no project-specific paths/data creep into `delphi-ai/`, `.clinerules/`, or `.cline/`.
   - Cross-check updated files against `system_architecture_principles.md` and template expectations so instructions remain internally consistent.
   - Confirm references to project-specific files live under `foundation_documentation/` instead.
   - Run any applicable local checks for the touched surfaces. When the session is happening from a fully wired downstream environment and that validation is relevant, `bash delphi-ai/verify_context.sh` may be used as an additional readiness check, but it is not a prerequisite for Delphi self-maintenance.
8. **Documentation sync** – if instruction changes affect project docs (e.g., new templates), note the required updates.
9. **Session closure**
   - Summarise instruction changes.
   - If a temporary self-improvement work ledger was used:
     - delete it when the self-improvement scope is complete;
     - or refresh its `Next Exact Step` and blocker state if the same instruction-only arc will continue later;
     - never promote it into canonical instruction docs.
   - Do **not** prematurely end the session during discussion. Close only when the user confirms the self-improvement scope is complete for this session.
   - Before acknowledging closure, run the Post-Session Review Method (`workflows/docker/post-session-review-method.md`).
   - During that review, preserve the instruction-only boundary: identify and validate any downstream `project_mandate.md` candidates, but defer actual `foundation_documentation/` edits until after the self-improvement session is explicitly closed and a fresh non-self-improvement follow-up is opened.
   - If we will resume normal work in the same conversation, explicitly reload the updated instruction files (re-read the changed docs) before proceeding.
   - If the user prefers a hard boundary, explicitly state "session ended" after the summary so normal work resumes under a fresh start.

## Outputs
- Updated instruction/template files.
- Recorded correction-scope decision (`Session`, `Project`, or `Delphi`) for the triggering issue.
- Temporary self-improvement work ledger when the scope was long enough to require one.
- Verification note confirming agnosticism check passed.
- Any deferred downstream follow-up created by the post-session review.
- Session closure statement.

## Validation
- Documented correction-scope triage for the triggering issue, including explicit user validation when the scope was ambiguous.
- Temporary work ledger, when used, remains local to `delphi-ai/artifacts/tmp/`, non-authoritative, and is deleted or refreshed intentionally at closure.
- Documented manual agnosticism review of the edited Delphi surfaces.
- Applicable local checks recorded for the changed file types (or explicit N/A rationale).
- If post-session review surfaced project-mandate candidates, documented deferral of downstream edits until after self-improvement closure.
- User acknowledgement (or log) that the session ended before any architectural tasks resume.
