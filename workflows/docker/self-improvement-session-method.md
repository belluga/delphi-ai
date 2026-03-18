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
- Manual agnosticism review of the edited Delphi surfaces.
- Applicable local checks for the changed file types (for example `bash self_check.sh` for governance surfaces or `bash -n` for edited shell scripts).

## Procedure
1. **Persona Selection** – run the Persona Selection Method; typically CTO/Tech Lead persona.
2. **Freeze architectural work** – acknowledge that implementation work (project code, submodule code, and project-specific docs) is paused; this session is for discussion + instruction refinement only. Editing within `delphi-ai/` is permitted.
3. **Plan updates** – list the instruction files to edit and the rationale.
4. **Apply changes** – edit `delphi-ai/*.md` (and templates) as required.
5. **Agnosticism & consistency verification**
   - Review the edited Delphi files and diffs to ensure no project-specific paths/data creep into `delphi-ai/`, `.clinerules/`, or `.cline/`.
   - Cross-check updated files against `system_architecture_principles.md` and template expectations so instructions remain internally consistent.
   - Confirm references to project-specific files live under `foundation_documentation/` instead.
   - Run any applicable local checks for the touched surfaces. When the session is happening from a fully wired downstream environment and that validation is relevant, `bash delphi-ai/verify_context.sh` may be used as an additional readiness check, but it is not a prerequisite for Delphi self-maintenance.
6. **Documentation sync** – if instruction changes affect project docs (e.g., new templates), note the required updates.
7. **Session closure**
   - Summarise instruction changes.
   - Do **not** prematurely end the session during discussion. Close only when the user confirms the self-improvement scope is complete for this session.
   - If we will resume normal work in the same conversation, explicitly reload the updated instruction files (re-read the changed docs) before proceeding.
   - If the user prefers a hard boundary, explicitly state "session ended" after the summary so normal work resumes under a fresh start.

## Outputs
- Updated instruction/template files.
- Verification note confirming agnosticism check passed.
- Session closure statement.

## Validation
- Documented manual agnosticism review of the edited Delphi surfaces.
- Applicable local checks recorded for the changed file types (or explicit N/A rationale).
- User acknowledgement (or log) that the session ended before any architectural tasks resume.
