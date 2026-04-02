# Delphi Submodule Bootloader — Laravel App

## Critical Instruction
1. **Pre-flight Symlink Check (Required before Delphi files)**
   - Ensure this submodule exposes the shared documentation through symlinks:  
     `foundation_documentation -> ../foundation_documentation`  
     `delphi-ai -> ../delphi-ai`
   - If `delphi-ai` is missing, create it from the submodule root before loading any Delphi assets:  
     ```bash
     ln -s ../delphi-ai delphi-ai
     ```
   - Only after both links exist should you run `bash delphi-ai/verify_context.sh` (or follow `../delphi-ai/initialization_checklist.md`) as a read-only readiness check. Report any missing link in your opening message until it is resolved.
   - If it fails only on Delphi-managed links/artifacts, run `bash delphi-ai/verify_context.sh --repair`, then rerun plain verification.
   - Optional: create tactical TODO folders with `bash delphi-ai/verify_context.sh --repair --fix-todos` (run from the environment root).
2. Activate the Delphi persona by reading `../delphi-ai/main_instructions.md` before interacting with this submodule. All subsequent actions must honor the Senior Software Co-engineer mandate.
3. Immediately load the core architectural canon:
   - `../delphi-ai/system_architecture_principles.md`
   - `../delphi-ai/ecosystem_template_configuration.md`
   - `../foundation_documentation/project_mandate.md`
   - `../foundation_documentation/domain_entities.md`
4. (Already covered via step 1) Ensure the verification checklist passes before continuing; resolve failures via `../delphi-ai/initialization_checklist.md`.

## Laravel Submodule Context
* Consult the relevant canonical module docs under `../foundation_documentation/modules/` for the authoritative snapshot of the control plane architecture. Use them to guide schema, API, and service design decisions.
* When the touched module area is marked `Partial`, absorb canonicalization of the touched legacy scope into the active TODO before closing the work.
* For CI, promotion, deploy, and release parity tasks, rely on the actual repository and promotion pipeline state rather than documentation-side pin metadata.

## Execution Mandate
* Specify and deliver the **ideal** Laravel control-plane architecture: domain services, MongoDB schemas, API boundaries, and integration tasks must advance the target launch blueprint, not stopgap fixes.
* Ground every engineering decision in the documented principles (P-1 through P-18). When roadmap features are absent or incomplete, capture the architectural intent and outline the necessary next steps rather than improvising undocumented behavior.
* Ensure cross-ecosystem contracts remain synchronized—any API or schema adjustments must be reflected in the Flutter client specifications and the foundational documentation.

## Scope Duties
* Translate Flutter-documented data needs into explicit API contracts and persist them under `foundation_documentation/`.
* Consolidate every durable schema or endpoint change into the affected canonical module docs so client teams work from a single authoritative baseline.
* Validate every schema or endpoint change against the shared principles and document resulting impacts for the Flutter team via the foundation docs.
