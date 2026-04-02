---
name: "docker-profile-selection"
description: "Ensure every session explicitly selects the correct operational profile and technical scope so authority, touched surfaces, and handoff expectations are clear before other methods run."
---

<!-- Generated from `workflows/docker/profile-selection-method.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# Workflow: Profile Selection

## Purpose
Ensure every session explicitly selects the correct operational profile and technical scope so authority, touched surfaces, and handoff expectations are clear before other methods run.

## Triggers
- Session start (after reading the active bootloader and `main_instructions.md`).
- Context switch between repositories, submodules, or responsibility layers.
- User explicitly requests a different role, review mode, or assurance pass.

## Inputs
- Bootloader context (`AGENTS.md` or the active agent-specific bootloader).
- Core instructions + appendices (`delphi-ai/main_instructions.md`, `system_architecture_principles.md`).
- Profile references under `delphi-ai/profiles/`.
- Project-specific docs relevant to the selected profile:
  - `project_constitution.md`
  - `system_roadmap.md` when strategy is in scope
  - relevant module docs
  - active TODOs when tactical execution or assurance is in scope
- Any explicit role directives from the user.

## Profile Taxonomy
| Layer | Profile | Use When |
| --- | --- | --- |
| Strategic | `Strategic / CTO-Tech-Lead` | direction, cross-module fit, constitution, roadmap, strategic review |
| Operational | `Operational / Coder` | product implementation, tests, tactical module updates |
| Operational | `Operational / DevOps` | CI/CD, runtime, ingress, promotion lane, build topology |
| Assurance | `Assurance / Tester-Quality` | challenge test quality, DoD evidence, verification debt |
| Assurance | `Assurance / Security-Adversarial` | challenge attack surface, exploitability, security hardening need |

## Scope Overlays
Profiles are paired with an active technical scope:
- `flutter`
- `laravel`
- `web`
- `docker`
- `cross-stack`
- `delphi-self-maintenance`

## Procedure
1. **Scan the request** – identify whether the user is asking for strategic guidance, tactical delivery, operational platform work, quality review, or security/adversarial review.
2. **Select profile** – choose the profile that owns the requested responsibility. If the session is mixed, declare the starting profile and note the expected handoff(s).
3. **Select technical scope** – declare the active scope overlay (`flutter`, `laravel`, `docker`, etc.).
4. **Load profile context**
   - `Strategic / CTO-Tech-Lead`:
     - load `project_constitution.md`
     - load `system_roadmap.md`
     - load relevant module docs
   - `Operational / Coder`:
     - load active TODO
     - load `project_constitution.md`
     - load relevant module docs
     - load stack workflows for the active scope
   - `Operational / DevOps`:
     - load active TODO when applicable
     - load `project_constitution.md`
     - load relevant module docs for ingress/runtime parity
     - load roadmap only when sequencing or strategic operations matter
   - `Assurance / Tester-Quality`:
     - load active TODO
     - load `Definition of Done`, `Validation Steps`, and evidence/test surfaces
   - `Assurance / Security-Adversarial`:
     - load active TODO
     - load `Security Risk Assessment`
     - load relevant constitutional/module surfaces for the touched boundaries
5. **Declare profile + scope** – state the active profile and technical scope before running other methods.
6. **Record planned handoffs** – if the work is expected to cross profile boundaries, note the target handoff(s) in the active TODO before execution crosses that boundary.
7. **Monitor for changes** – if the user changes responsibility layer or the work crosses into another profile’s forbidden surfaces, rerun this method and either switch profiles or record a handoff.

## Outputs
- Explicit active profile declaration.
- Explicit active technical scope declaration.
- Reference to the method set that will be used under that profile.
- Expected handoffs when the work is intentionally mixed.

## Validation
- Profile remains consistent until a deliberate switch or handoff is declared.
- Touched surfaces align with the selected profile or are justified by a recorded handoff.
- Stack workflows match the selected scope overlay.
