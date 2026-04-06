---
name: wf-docker-self-improvement-session-method
description: "Workflow: MUST use whenever the scope matches this purpose: Run instruction-only sessions safely, ensuring `delphi-ai/` stays project-agnostic and no architectural work proceeds under stale directives, per Section 3 of `main_instructions.md`."
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
3. **Correction scope triage** – classify the triggering gap as `Session|Project|Delphi`; stop without editing `delphi-ai/` if it is not a reusable Delphi gap.
4. **Temporary work-ledger decision** – if the self-improvement scope is long or multi-step, create/update `delphi-ai/artifacts/tmp/self-improvement-work-ledger.md` from `templates/self_improvement_work_ledger_template.md`. This ledger is temporary, local to the self-improvement scope, and never a tactical TODO or source of truth.
5. **Plan updates** – list the instruction files to edit and the rationale.
6. **Apply changes** – edit `delphi-ai/*.md` (and templates) as required.
7. **Agnosticism & consistency verification**
   - Review the edited Delphi files and diffs to ensure no project-specific paths/data creep into `delphi-ai/`, `.clinerules/`, or `.cline/`.
   - Cross-check updated files against `system_architecture_principles.md` and template expectations so instructions remain internally consistent.
   - Confirm references to project-specific files live under `foundation_documentation/` instead.
   - Run any applicable local checks for the touched surfaces. When the session is happening from a fully wired downstream environment and that validation is relevant, `bash delphi-ai/verify_context.sh` may be used as an additional readiness check, but it is not a prerequisite for Delphi self-maintenance.
8. **Documentation sync** – if instruction changes affect project docs (e.g., new templates), note the required updates.
9. **Session closure**
   - Summarise instruction changes.
   - If a temporary self-improvement work ledger was used, delete it when the scope is complete or intentionally refresh its `Next Exact Step` if the same instruction-only arc remains open.
   - Do **not** prematurely end the session during discussion. Close only when the user confirms the self-improvement scope is complete for this session.
   - If we will resume normal work in the same conversation, explicitly reload the updated instruction files (re-read the changed docs) before proceeding.
   - If the user prefers a hard boundary, explicitly state "session ended" after the summary so normal work resumes under a fresh start.

## Outputs
- Updated instruction/template files.
- Temporary self-improvement work ledger when the scope was long enough to require one.
- Verification note confirming agnosticism check passed.
- Session closure statement.

## Validation
- Temporary work ledger, when used, remains local to `delphi-ai/artifacts/tmp/`, non-authoritative, and is deleted or refreshed intentionally at closure.
- Documented manual agnosticism review of the edited Delphi surfaces.
- Applicable local checks recorded for the changed file types (or explicit N/A rationale).
- User acknowledgement (or log) that the session ended before any architectural tasks resume.
