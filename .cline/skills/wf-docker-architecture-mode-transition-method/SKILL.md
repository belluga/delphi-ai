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
- `Strategic / CTO-Tech-Lead` profile doc and the relevant architecture/governance entries in `foundation_documentation/system_roadmap.md`.
- Project mandate, domain entities, and the relevant canonical module docs describing live behavior.
- Any regulatory or business timelines driving the transition.

## Procedure
1. **Profile alignment** – run Profile Selection Method as `Strategic / CTO-Tech-Lead` with `cross-stack` scope.
2. **Assess readiness** – verify triggers have been met (e.g., production tenant exists, expansion initiative approved).
3. **Document the target mode**
   - Update `system_architecture_principles.md` (and relevant appendices) with policies specific to the new mode (migration expectations, compatibility windows, feature-flag rules).
4. **Update roadmaps**
   - Record the transition in `foundation_documentation/system_roadmap.md` and call out required actions for each affected profile/scope combination.
5. **Notify affected modules**
   - Update the relevant canonical module docs and shared roadmap entries with the new operating constraints so future work inherits the correct mode assumptions.
6. **Method references**
   - Ensure affected methods (domain creation, repositories, deployment) mention any new operational requirements (e.g., API versioning, data migration steps).
7. **Session communication**
   - Clearly state the new mode in the session summary and any commits so future sessions load the correct assumptions.

## Outputs
- Updated `system_architecture_principles.md` describing the new mode behavior.
- Shared roadmap entries reflecting responsibilities and follow-up work per mode.
- Updated canonical module docs listing operational constraints where relevant.
- Method updates or TODOs referencing new policies.

## Validation
- The shared roadmap and affected canonical module docs clearly capture the required follow-up for each affected profile/scope combination, and future sessions can discover it there.
- CI/checklist updates exist if the mode introduces new gates (e.g., migration verification).
