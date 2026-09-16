---
name: ci-equivalent-test-surface-admission
description: "Canonical admission workflow for adding or changing tests, wrappers, lifecycle steps, or suite rows that affect CI Equivalent or broad local stage gates such as `stage-full`."
---

# CI Equivalent Test-Surface Admission

Use this skill whenever a change adds, removes, rehomes, renames, or materially rewires any test, wrapper, fixture/bootstrap step, lifecycle step, or suite row that contributes to `CI Equivalent` or a broad local stage gate such as `stage-full`.

## Purpose
Prevent local-only, pipeline-only, or order-divergent test additions from drifting the broad stage-parity contract over time.

## Load First
- Load `ci-equivalent-governance` before deciding whether the touched surface is part of `CI Equivalent` or a broad stage gate.

## Required Decisions
1. Classify the owning surface:
   - repo-owned Flutter workspace tests
   - browser/navigation readonly
   - browser/navigation mutation
   - runtime/build/preflight lifecycle
   - other explicit stage-facing suite family
2. Decide whether the change affects:
   - suite membership
   - execution order
   - wrapper/leaf-command ownership
   - bootstrap/fixture/cleanup lifecycle
   - readonly vs mutation coverage
3. Record whether the touched branch is the authoritative branch for the claim being made.

## Admission Rules
- Do not add the test only to a local wrapper while leaving the pipeline on different leaf commands.
- Do not add the test only to the pipeline while leaving the broad local stage gate narrower.
- Keep local parity contracts and stage workflow ownership aligned through the same canonical wrapper or leaf command family.
- Preserve explicit ordering when the pipeline depends on ordered lifecycle work.
- If mutation coverage is required, keep it on the approved non-`main` lane. Do not move mutation validation onto production/main proof surfaces.
- If the change is narrower than the broad stage gate, give it a narrower name instead of silently expanding or shrinking `stage-full`.

## Required Operator Actions
1. Update the owning suite/wrapper/contract surface.
2. Update the corresponding pipeline-owned stage surface in the same change when the stage-facing family changed.
3. Update fail-closed drift guards or audits that prove the two surfaces stay aligned.
4. Rerun the broad local CI-equivalent contract on the authoritative branch when the admission affects that branch's claim.
5. Record the exact commands/contracts used as evidence.

## Relationship To Other Skills
- `test-creation-standard` defines what coverage should exist.
- This skill decides how new coverage enters the canonical CI/pipeline surface without drift.
- `test-orchestration-suite` executes the resulting matrix.
- `wf-docker-update-ci-pipeline-method` uses this skill when CI workflow changes affect stage-facing test ownership.
- Promotion skills use this skill when remediation changes stage-facing test/harness surfaces before claiming the lane is ready.

## Done Criteria
- The new or changed test surface has one clear owner.
- Local broad-stage parity and stage pipeline use the same suite family and ordered lifecycle steps for that surface.
- Readonly/mutation semantics remain explicit and lane-correct.
- Drift guards/audits were updated when the expected stage-facing shape changed.
- The authoritative local CI-equivalent rerun is green before readiness or promotion is claimed.
