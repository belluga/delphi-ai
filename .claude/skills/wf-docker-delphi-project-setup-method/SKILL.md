---
name: wf-docker-delphi-project-setup-method
description: "Workflow: MUST use whenever the scope matches this purpose: Prepare or recalibrate a downstream project to operate under the current PACED/Delphi baseline before feature work resumes."
---

# Method: PACED Project Setup

Use this skill as the operational entrypoint for the canonical workflow in `workflows/docker/delphi-project-setup-method.md`.
The workflow file is the normative source for lane handling, drift classification, and normalization handoff details.

## Purpose
Prepare or recalibrate a downstream project against the current Delphi baseline while keeping three boundaries explicit:
- inherited Delphi method/capability authority;
- project-owned active topology and specialization;
- unsafe or unresolved drift that blocks normal feature work.

## Canonical Sources
- `workflows/docker/delphi-project-setup-method.md`
- `workflows/docker/environment-readiness-method.md`
- `config/stack_capabilities.yaml`
- `ecosystem_template_configuration.md`
- `rules/core/delphi-project-setup-model-decision.md`

## Procedure
1. Classify the lane as `bootstrap` or `recalibration`.
2. Run the lane-appropriate readiness prerequisite from the canonical workflow.
3. Inventory Delphi-governed surfaces and load `config/stack_capabilities.yaml` as available-capability context only.
4. Inventory project-owned authority from `foundation_documentation`, `.gitmodules`, README, project config/env, and safe runners.
5. Separate available stack capabilities from stacks actively declared by the project.
6. Classify drift as `structural`, `documentation`, `canonical coverage`, or `governance`.
7. Publish the outcome as `ready for normal work`, `manual remediation required`, or `normalization TODO required`.

## Preferred Deterministic Helpers
- `bash delphi-ai/tools/project_recalibration_doctor.sh --repo <repo-root> [--lane auto|bootstrap|recalibration] [--include-adherence-sync] [--artifacts-dir foundation_documentation/artifacts/tmp]`
- `bash delphi-ai/tools/delphi_project_setup_report.sh --repo <repo-root> [--lane auto|bootstrap|recalibration] [--include-adherence-sync] [--json-output foundation_documentation/artifacts/tmp/project-setup-report.json]`
- `python3 delphi-ai/tools/project_setup_normalization_packet.py --report foundation_documentation/artifacts/tmp/project-setup-report.json ...`

## Non-Negotiables
- Capability presence in Delphi does not activate a stack in the project.
- Environment, tenants, domains, runtime owners, validation targets, and safe runners are project-owned contracts.
- If remediation mutates project artifacts, hand off to TODO-driven execution and require `APROVADO`.
