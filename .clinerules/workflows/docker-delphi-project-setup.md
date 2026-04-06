---
name: "docker-delphi-project-setup"
description: "Prepare or recalibrate a downstream project to operate under the current PACED/Delphi baseline before feature work resumes."
---

<!-- Generated from `workflows/docker/delphi-project-setup-method.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# Workflow: Delphi Project Setup

## Purpose
Prepare or recalibrate a downstream project so it can operate under the current PACED method baseline packaged through `delphi-ai/`, with clear authority boundaries, explicit drift visibility, and a safe handoff into normal feature work. This method is for project bootstrap and for older projects that need re-alignment after meaningful PACED or project drift. It does not replace the TODO-driven execution method for actual remediation work.

## Triggers
- The user asks to onboard a downstream project to Delphi AI.
- The user asks to recalibrate or rebaseline an older project after Delphi drift.
- A dormant project is being resumed and the active canonical authority is unclear.
- Before a major initiative when setup, canonical coverage, or governance surfaces are suspected to be stale.

## Inputs
- Downstream repository root and active bootloader surface (`AGENTS.md`, `CLINE.md`, `GEMINI.md`, or equivalent).
- `.gitmodules`, Delphi-managed links/artifacts, and project README guidance.
- `foundation_documentation/` core files and any populated module docs.
- Current PACED baseline (`main_instructions.md`, core rules, workflows, templates, and setup/readiness scripts shipped through `delphi-ai/`).

## Preferred Deterministic Helpers
- Prefer the end-to-end recalibration helper when a full downstream pass is needed:
```bash
bash delphi-ai/tools/project_recalibration_doctor.sh \
  --repo <repo-root> \
  --lane auto \
  --artifacts-dir foundation_documentation/artifacts/tmp
```
- Or generate the read-only setup inventory directly:
  ```bash
  bash delphi-ai/tools/delphi_project_setup_report.sh \
    --repo <repo-root> \
    --lane auto \
    --json-output foundation_documentation/artifacts/tmp/project-setup-report.json
  ```
- When the report returns `needs-normalization` or `manual-remediation-required`, derive a normalization packet before opening TODOs:
  ```bash
  python3 delphi-ai/tools/project_setup_normalization_packet.py \
    --report foundation_documentation/artifacts/tmp/project-setup-report.json \
    --json-output foundation_documentation/artifacts/tmp/project-normalization-packet.json \
    --markdown-output foundation_documentation/artifacts/tmp/project-normalization-packet.md
  ```
- Treat both outputs as derived artifacts. They assist setup interpretation and normalization planning, but they never replace canonical project authority.

## Procedure
1. **Classify the setup lane**
   - Determine whether the session is:
     - `bootstrap`: first structured Delphi setup for this project, or
     - `recalibration`: project already uses Delphi surfaces but may have drifted from the current baseline.
   - Record the lane in the status summary before continuing.
   - If the repo is zero-state and the user is explicitly asking to set up submodules/runtime first, do not silently force `bootstrap`; ask whether they want `Genesis / Product-Bootstrap` first or `Operational / DevOps` first, then record that answer as the active starting path and planned handoff.

2. **Run readiness prerequisites**
   - Run the Initialization Checklist (`delphi-ai/initialization_checklist.md`).
   - If the lane is `bootstrap` and the repo is still zero-state:
     - run `bash delphi-ai/init.sh --check`;
     - if there are no Delphi-managed path conflicts and Delphi surfaces are intended, run `bash delphi-ai/init.sh`;
     - treat missing `foundation_documentation/`, module docs, submodules, `.env`, and other downstream-owned readiness surfaces as bootstrap outputs rather than failures;
     - defer the full Environment Readiness Workflow until the downstream shape exists or runtime/deploy work becomes the goal.
   - If the lane is `recalibration`, or the project already has a canonical package/runtime shape:
     - load and execute the Environment Readiness Workflow (`delphi-ai/workflows/docker/environment-readiness-method.md`);
     - treat readiness as a prerequisite for calibration, not as the full calibration itself;
     - if readiness fails because of project-owned path conflicts, stop and report the blockers for manual remediation before continuing.
   - If the full recalibration helper was already used, treat its setup report and normalization packet as derived evidence; do not rerun ad hoc commands unless the workspace changed materially.

3. **Inventory Delphi-governed surfaces**
   - Confirm bootloader/install surfaces are present and aligned (`AGENTS.md`, `.codex/skills/`, `.agents/rules/`, `.agents/workflows/`, `.agents/skills/`, `.clinerules/`, `.cline/skills/`, or the runtime-specific equivalents that apply).
   - Confirm Delphi-managed helper scripts and expected directories resolve correctly.
   - Confirm the project is operating against the current Delphi baseline rather than a stale local copy.

4. **Inventory project-owned authority**
   - Load the project-specific authority surfaces that complement Delphi:
     - `foundation_documentation/project_mandate.md`
     - `foundation_documentation/domain_entities.md`
     - `foundation_documentation/project_constitution.md`
     - `foundation_documentation/policies/scope_subscope_governance.md`
     - `foundation_documentation/system_roadmap.md` (if present and strategic for the current setup question)
     - `delphi-ai/profiles/` when the setup question is really about strategic vs operational vs assurance responsibility
     - relevant module docs under `foundation_documentation/modules/`
   - Distinguish what is inherited from Delphi versus what must remain project-owned.

5. **Detect and classify drift**
   - Evaluate drift across four buckets:
     - `structural drift`: broken/missing Delphi-managed links, stale scripts, missing required folders, install mismatch.
     - `documentation drift`: missing or stale project authority docs that Delphi cannot infer safely.
     - `canonical coverage drift`: roadmap/module surfaces are missing, stale, or still dependent on legacy pre-canonical knowledge for active scopes.
     - `governance drift`: the project is technically wired, but its active operating assumptions no longer match the current Delphi method.
   - Classify each bucket as `none|minor|material`.
   - Explicitly note which drift is Delphi-surface drift versus project-owned drift.

6. **Map the operational surface**
   - Produce a concise calibration map with three sections:
     - `Inherited from Delphi`: what is already governed by the current Delphi baseline.
     - `Project-owned specialization`: what the project must define locally and remains authoritative locally.
     - `Unsafe / unresolved`: areas where the AI should not proceed without remediation, clarification, or documentation.
   - The goal is to make explicit what the project can assume and what it still owes the method.

7. **Build a normalization packet when needed**
   - If the deterministic setup report returned `needs-normalization` or `manual-remediation-required`, derive `project-normalization-packet.{json,md}` before deciding on remediation.
   - Use the packet to separate:
     - `manual remediation` tracks for Delphi-managed/readiness blockers;
     - `normalization TODO` tracks for project-owned authority and canonical coverage drift.
   - Keep the packet bounded and non-authoritative. It is a planning aid, not a new source of truth.

8. **Decide the project status**
   - If all material drift is cleared and the operational surface is coherent, mark the project:
     - `calibrated`: ready for normal Delphi work.
   - If material drift remains, mark the project:
     - `needs-normalization`: feature work should not proceed yet.
   - If normalization requires changes to project artifacts, do not apply them ad hoc:
     - use the normalization packet to keep the TODO boundary narrow and explicit;
     - create or update a tactical TODO under `foundation_documentation/todos/active/`;
     - switch to the TODO-Driven Execution Method (`delphi-ai/workflows/docker/todo-driven-execution-method.md`);
     - request `APROVADO` before remediation starts.

9. **Publish the setup outcome**
   - Summarize:
     - lane (`bootstrap|recalibration`);
     - readiness result;
     - drift classification by bucket;
     - inherited Delphi authority;
     - project-owned authority;
     - recommended next step.
   - The next step must be one of:
     - `ready for normal work`,
     - `manual remediation required`,
     - `normalization TODO required`.
   - When normalization is still required, hand off to `workflows/docker/brownfield-normalization-method.md` so remediation stays separated into manual-remediation versus bounded normalization-TODO fronts.

## Outputs
- A setup/recalibration summary with explicit lane classification.
- Drift report covering `structural`, `documentation`, `canonical coverage`, and `governance` buckets.
- Optional derived setup artifacts for deterministic reuse:
  - `project-setup-report.txt`
  - `project-setup-report.json`
  - `project-normalization-packet.json`
  - `project-normalization-packet.md`
- Operational surface map:
  - inherited from Delphi,
  - project-owned specialization,
  - unsafe/unresolved zones.
- Clear next-step outcome: `ready for normal work`, `manual remediation required`, or `normalization TODO required`.

## Validation
- Readiness prerequisites were executed first via the Initialization Checklist plus the lane-appropriate preflight:
  - `bootstrap`: Delphi install preflight (`init.sh --check` / `init.sh`) when the downstream shape does not yet exist;
  - `recalibration`: Environment Readiness Workflow.
- If the project is declared `calibrated`, no material structural or governance drift remains unresolved.
- If the project is not ready, the blocking drift is explicitly recorded and feature work does not proceed under implicit assumptions.
- If a normalization packet was generated, it stays derived/non-authoritative and any project mutation still flows through a tactical TODO plus `APROVADO`.
- If remediation touches project artifacts, the handoff to TODO-driven execution is explicit and no implementation starts before `APROVADO`.
