---
name: wf-docker-profile-selection-method
description: "Workflow: MUST use whenever the scope matches this purpose: Ensure every session explicitly selects the correct operational profile and technical scope so authority, touched surfaces, and handoff expectations are clear before other methods run."
---

# Method: Profile Selection

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
  - for `Genesis / Product-Bootstrap`, zero-state is valid; load any existing project docs, discovery notes, or prototype surfaces without requiring canonical docs to exist yet
  - `project_constitution.md`
  - `system_roadmap.md` when strategy is in scope
  - relevant module docs
  - active TODOs when tactical execution or assurance is in scope
- Any explicit role directives from the user.

## Profile Taxonomy
| Layer | Profile | Use When |
| --- | --- | --- |
| Genesis | `Genesis / Product-Bootstrap` | project inception, zero-state discovery, prototype-led validation, first canonical doc package |
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

## Gate 0 — Genesis Eligibility
Evaluate this gate before selecting any profile.

Choose `Genesis / Product-Bootstrap` only when all statements below are true:
1. The primary objective is to instantiate or materially define the first canonical Delphi package for the project or touched scope.
2. The session is effectively zero-state for that scope:
   - canonical docs do not yet exist, or
   - the available docs are so absent/early that the real task is still project inception rather than governed evolution.
3. The dominant work is discovery, synthesis, prototype-led validation, or first-pass canonicalization, not product implementation.
4. Any prototype work is being used as evidence to validate flows, IA, language, or decisions, not as production delivery.
5. Opening a tactical implementation TODO now would be premature or misleading because the contract still needs to be established first.

Do not choose `Genesis / Product-Bootstrap` when any statement below is true:
- a usable canonical package already exists and the task is to maintain or evolve project-level direction; choose `Strategic / CTO-Tech-Lead`
- the contract is already sufficiently defined and the task is to ship product behavior or tests; choose `Operational / Coder`
- the task is primarily runtime, CI/CD, ingress, environment, or promotion-lane work; choose `Operational / DevOps`
- the task is primarily to challenge or audit an existing delivery; choose an `Assurance` profile

If the gate is inconclusive, start from the most conservative non-Genesis profile that matches the current authority and record a handoff only if the session proves to be earlier-stage than initially believed.

## Procedure
0. **Run Gate 0 — Genesis Eligibility** – explicitly decide whether the session qualifies for `Genesis / Product-Bootstrap` before considering the other profiles.
1. **Scan the request** – identify whether the user is asking for zero-state project inception, strategic guidance, tactical delivery, operational platform work, quality review, or security/adversarial review.
2. **Select profile** – choose the profile that owns the requested responsibility. If the session is mixed, declare the starting profile and note the expected handoff(s).
3. **Select technical scope** – declare the active scope overlay (`flutter`, `laravel`, `docker`, etc.).
4. **Load profile context**
   - `Genesis / Product-Bootstrap`:
     - load any existing `project_mandate.md`, `domain_entities.md`, `project_constitution.md`, `system_roadmap.md`, and module docs if they already exist
     - load discovery notes, reference material, and prototype surfaces that clarify the project intent
     - if canonical docs are missing, explicitly record that the session is zero-state and treat those docs as bootstrap outputs rather than blockers
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
6. **Record planned handoffs** – if the work is expected to cross profile boundaries, note the target handoff(s) in the active TODO before execution crosses that boundary. If the session is still in zero-state and no TODO exists yet, `Genesis / Product-Bootstrap` may record those handoffs in a bootstrap packet or session notes until the first TODO is opened.
7. **Monitor for changes** – if the user changes responsibility layer or the work crosses into another profile’s forbidden surfaces, rerun this method and either switch profiles or record a handoff.

## Outputs
- Explicit `Gate 0` decision, including whether `Genesis / Product-Bootstrap` was chosen, rejected, or ruled out as premature.
- Explicit active profile declaration.
- Explicit active technical scope declaration.
- Reference to the method set that will be used under that profile.
- Expected handoffs when the work is intentionally mixed.
- Explicit note when the session is valid zero-state bootstrap instead of a missing-document failure.

## Validation
- `Gate 0` was evaluated before `Genesis / Product-Bootstrap` is selected.
- Profile remains consistent until a deliberate switch or handoff is declared.
- Touched surfaces align with the selected profile or are justified by a recorded handoff.
- Stack workflows match the selected scope overlay.
- Missing canonical docs are acceptable only when the selected profile is `Genesis / Product-Bootstrap` and the session is intentionally bootstrapping them.
