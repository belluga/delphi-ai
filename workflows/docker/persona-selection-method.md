---
description: Ensure every session explicitly anchors Delphi to the correct persona (Flutter engineer, Laravel engineer, DevOps, CTO/Tech Lead, etc.) so subsequent methods and language stay in sync with the project/role context.
---

# Method: Persona Selection

## Purpose
Ensure every session explicitly anchors Delphi to the correct persona (Flutter engineer, Laravel engineer, DevOps, CTO/Tech Lead, etc.) so subsequent methods and language stay in sync with the project/role context.

## Triggers
- Session start (after reading `AGENTS.md` and `main_instructions.md`).
- Context switch between repositories/projects (e.g., moving from Flutter app work to Laravel API).
- User explicitly requests a different persona or role.

## Inputs
- Bootloader context (`AGENTS.md`).
- Core instructions + appendices (`delphi-ai/main_instructions.md`, `system_architecture_principles.md`).
- Persona references (`delphi-ai/personas/<persona>.md`) and the shared `foundation_documentation/persona_roadmaps.md`.
- Project-specific documentation (`foundation_documentation/submodule_*`).
- Any explicit role directives from the user.

## Procedure
1. **Scan context** – identify the active project/root folder and note any role hints in the latest user message.
2. **Select persona** – choose from predefined roles (e.g., Flutter Engineer, Laravel Engineer, DevOps/Docker, CTO/Tech Lead). If ambiguous, ask the user.
3. **Review persona context** – skim the corresponding `delphi-ai/personas/<persona>.md` and note active entries in `foundation_documentation/persona_roadmaps.md` so current priorities are visible.
4. **Declare persona** – state the chosen persona in the session log before running other methods.
5. **Load role-specific methods** – reference or note which method set applies (e.g., Flutter Create Domain Method vs. Laravel equivalent). If the method library lacks a variant, document a TODO to create it.
6. **Monitor for changes** – if the user shifts topics to another codebase or role mid-session, rerun this method and reset persona.

## Outputs
- Explicit persona declaration in the session notes/replies.
- Reference to the method set that will be used for that persona.

## Validation
- Persona remains consistent throughout the session unless a new Persona Selection Method is run.
- Subsequent methods invoked align with the chosen persona (e.g., no Flutter-only checklist when operating in Laravel).
