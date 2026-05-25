---
name: test-orchestration-suite
description: "Orchestrate Laravel/Flutter/Web test execution with explicit suite decisions, gate sequencing, and adherence validation before delivery."
---

# Test Orchestration Suite

Use this skill whenever delivery confidence depends on Laravel, Flutter, browser, device, or CI-equivalent test execution. It coordinates testing; it does not replace TODO governance, topology validation, or stack-specific test-quality skills.

## Purpose
Produce promotion-grade evidence for the behaviors touched by the active TODO slice. A targeted rerun or one representative flow is diagnostic evidence only unless the approved baseline explicitly says it covers every materially distinct touched behavior.

## Canonical Inputs
- Active TODO, frozen decisions, validation matrix, and local CI-equivalent suite matrix.
- Project-owned topology contract or dependency-readiness artifact for runtime owners, domains, tenants, devices, and build/publish wrappers.
- Stack workflows and skills for Laravel, Flutter, browser, integration/device, and test-quality audit.
- `tools/test_orchestration_status_report.sh` for deterministic stage accounting.

## Required Preflight
Before launching tests, resolve and record:
- orchestration scope: `small|medium|big`;
- required stages and their exact local commands;
- canonical execution owner per stage (`host`, safe runner, compose service, CI, device, browser runner);
- public/browser validation targets and tenant/subdomain if relevant;
- whether each touched behavior requires unit, widget, integration/device, browser/navigation, real-backend, or mutation evidence.

If topology is ambiguous, run the Environment Topology Contract flow and stop at `blocked` until the user validates the target. Do not guess runtime owners, domains, tenants, or publish commands.

## Stage Policy
- Required stages are `passed`, `failed`, `blocked`, `flaky`, `skipped`, or `not-applicable`.
- `blocked` is not `passed`; it can only close with an approved waiver or explicit scope exclusion.
- `flaky`, including pass-after-retry, is not promotion-grade evidence unless waived with owner/rationale.
- Targeted reruns after a fix do not replace rerunning the in-scope CI-equivalent rows.
- Browser/device evidence must prove the current reconciliation/build state is being served, not a stale bundle.
- Browser CRUD/mutation validation must use the approved non-`main` mutation lane.

## Default Sequence
1. Environment/topology preflight.
2. Laravel contract/feature tests through the project-owned safe runner.
3. Flutter unit and widget tests.
4. Flutter integration tests on required platforms with real backend when compatibility or backend coupling matters.
5. Project-owned web build/publish wrapper when Flutter web or browser-visible surfaces changed.
6. Browser navigation/mutation tests through the project-owned Playwright runner.
7. Compatibility metadata check.
8. Final stage report and decision-adherence check.

Adjust the sequence only when the TODO baseline documents why the risk surface is different.

## Failure Classification
Classify every failure before changing product code:
- `product regression`;
- `test/assertion defect`;
- `CI/harness defect`;
- `environment/transient infra defect`.

Only product regressions and test/assertion defects authorize code/test changes by themselves. Harness and environment failures invalidate that run as product evidence until the preflight issue is cleared or a valid equivalent reproduces the failure.

## Deterministic Helper
Use:

```bash
bash delphi-ai/tools/test_orchestration_status_report.sh \
  --scope <small|medium|big> \
  --require-stage <stage> \
  --stage <stage>=<passed|failed|blocked|flaky|skipped|not-applicable> \
  --decision <ID>=<adherent|exception>
```

The helper records status coherence. Suite selection, failure classification, waiver validity, and fix-loop judgment remain human-led.

## Done Criteria
- Every in-scope CI-equivalent row has a local passed row or approved waiver.
- Every touched user-visible or user-flow behavior has item-specific runtime evidence, or a recorded structure-only rationale.
- No required stage remains `blocked`, `failed`, or `flaky` without approved waiver.
- Decision adherence is resolved.
- Residual risk and follow-up actions are explicit.
