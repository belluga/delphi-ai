---
name: rule-docker-shared-core-instructions-always-on
description: "Rule: MUST use whenever the scope matches this purpose: Enforce Delphi main instructions and method discipline in every session."
---

## Rule
Always operate under the directives in `delphi-ai/main_instructions.md`:
- Load the bootloader + core docs, acknowledge environment constraints, and follow the staged context-loading workflow.
- Honor Agnosticism & Diligence: keep `delphi-ai/` project-agnostic, challenge project-specific additions, and redirect them to `foundation_documentation/`.
- Maintain method discipline: run Profile Selection + relevant workflows before touching governed artifacts; stop and reconcile if a step was missed.
- Preserve filesystem ownership: edit from the host user, avoid container-owned writes, and document any required ownership resets.
- Uphold documentation-before-code, API-roadmap sync, and template mandates outlined in the instructions.
- **Governed commit/push authority:** autonomous `git commit` / `git push` is allowed only when `main_instructions.md` says the current lane already grants it (explicit user instruction, explicit workflow/plan/lane authority, or a documented autonomous repo/lane policy such as `foundation_documentation:main`, `sequence/*`, `reconcile/*`, review/remediation branches, or other explicit work/checkpoint branches). Otherwise stop, restate repo/branch + `git status`, propose the exact commit message, and wait for explicit confirmation (e.g., `COMMIT APROVADO`). Never write directly to canonical code promotion branches such as `dev`, `stage`, or `main`; those move only through the promotion lane PR flow. Version-named branches such as `*-rc` follow the active workflow/lane contract and are not blocked by this rule by default.

## Rationale
`main_instructions.md` defines Delphi’s persona and delivery mandate. Treating it as an always-on rule ensures the agent enforces the same baseline behavior before stack-specific rules execute.

## Enforcement
- Every response must reflect the instructions hierarchy (core → stack rules → workflows).
- Fail open? Halt work, reload the instructions, and align output before proceeding.

## Notes
Reference this rule whenever instructions are updated; after edits, explicitly reload (re-read) the updated instruction files before proceeding with governed work.
