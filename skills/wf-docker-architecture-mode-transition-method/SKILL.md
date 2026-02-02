---
name: wf-docker-architecture-mode-transition-method
description: "Workflow: MUST use whenever the scope matches this purpose: Provide a controlled workflow for switching between Foundational, Operational, and Expansion modes (see `system_architecture_principles.md`). Ensures documentation, roadmaps, and enforcement rules stay coherent during the transition."
---

# Method: Architecture Mode Transition

## Purpose
Provide a controlled workflow for switching between Foundational, Operational, and Expansion modes (see `system_architecture_principles.md`). Ensures documentation, roadmaps, and enforcement rules stay coherent during the transition.

## Triggers
- First production tenant onboards (Foundational → Operational).
- Major re-architecture initiative launches alongside the live system (Operational → Expansion track).
- Expansion work completes and merges back into the Operational baseline.

## Inputs
- Current `system_architecture_principles.md` (mode definitions and affected principles).
- CTO/Tech Lead persona doc and roadmap section in `foundation_documentation/persona_roadmaps.md`.
- Project mandate, domain entities, and submodule summaries describing live behavior.
- Any regulatory or business timelines driving the transition.

## Procedure
1. **Persona alignment** – run Persona Selection Method as CTO/Tech Lead.
2. **Assess readiness** – verify triggers have been met (e.g., production tenant exists, expansion initiative approved).
3. **Document the target mode**
   - Update `system_architecture_principles.md` (and relevant appendices) with policies specific to the new mode (migration expectations, compatibility windows, feature-flag rules).
4. **Update roadmaps**
   - Record the transition in the CTO section of `foundation_documentation/persona_roadmaps.md` and call out required actions for each persona (Flutter/Laravel/DevOps).
5. **Notify submodules**
   - Add notes to `foundation_documentation/submodule_*` summaries describing the new operating constraints.
6. **Method references**
   - Ensure affected methods (domain creation, repositories, deployment) mention any new operational requirements (e.g., API versioning, data migration steps).
7. **Session communication**
   - Clearly state the new mode in the session summary and any commits so future sessions load the correct assumptions.

## Outputs
- Updated `system_architecture_principles.md` describing the new mode behavior.
- Persona roadmaps reflecting responsibilities per mode.
- Submodule summaries listing operational constraints.
- Method updates or TODOs referencing new policies.

## Validation
- All personas acknowledge the new mode in their next sessions (via roadmap updates or summary notes).
- CI/checklist updates exist if the mode introduces new gates (e.g., migration verification).
