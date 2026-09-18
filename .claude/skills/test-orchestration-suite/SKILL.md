---
name: test-orchestration-suite
description: "Orchestrate stack-aware test execution with topology preflight, risk-ordered evidence layers, project-owned commands, and adherence validation."
---

# Test Orchestration Suite

Use this skill whenever delivery confidence depends on coordinated test lanes. It coordinates testing; it does not replace TODO governance, topology validation, stack-specific quality rules, or the project's own CI authority.

## Purpose

Produce promotion-grade evidence for every materially distinct behavior touched by the active TODO slice. A targeted rerun is diagnostic evidence unless the approved baseline explicitly makes it sufficient.

## Canonical Inputs

- Active TODO, frozen decisions, validation matrix, declared stack capabilities, and local CI-equivalent matrix.
- Owning package/workspace manifests and their exact project-owned scripts.
- Topology/readiness contract for runtime owners, dependencies, targets, and build/publish wrappers.
- Applicable stack workflows and `test-quality-audit`.
- `tools/test_orchestration_status_report.sh` for deterministic stage accounting.

## Required Preflight

Before launching tests, resolve and record:

- orchestration scope: `small|medium|big`;
- active stack capabilities and affected boundaries;
- required stages and exact local commands;
- execution owner per stage: host, package script, safe runner, compose service, CI, browser, or device;
- service/database/broker/browser/device prerequisites only where the claim crosses those boundaries;
- runtime freshness for every manual, browser, or device target: authoritative `branch@sha`, build/publish command, artifact/fingerprint, served target, and matching probe;
- evidence layer for each touched behavior: static/contract, unit/provider/component, integration/module/adapter, application/contract/e2e, browser, or device.

If topology or ownership is ambiguous, run the Environment Topology Contract flow and stop the affected lane at `blocked`. Do not guess owners, domains, transports, databases, tenants, or publish commands. Do not debug behavior against an unproven runtime.

## Stage Policy

- Load `ci-equivalent-governance` before calling any local suite, profile, or runner `CI Equivalent` or a broad parity gate.
- Load `ci-equivalent-test-surface-admission` when adding or rewiring a stage-facing row, wrapper, lifecycle step, or readonly/mutation lane.
- Statuses are `passed`, `failed`, `blocked`, `flaky`, `skipped`, or `not-applicable`.
- `blocked` and `flaky` are not passing evidence; close them only through successful evidence, explicit scope exclusion, or approved waiver.
- Targeted reruns do not replace applicable broad project-owned closeout rows.
- Browser/device evidence requires a current-build freshness attestation.
- Mutation evidence must use the approved non-`main` lane unless the baseline explicitly authorizes otherwise.
- Respect wrapper branch-family contracts; never cite a reconciliation-only wrapper as proof for another branch without recorded same-commit equivalence.
- At an approved narrow checkpoint, run only the affected-area bundle plus independently required static architecture enforcement. Reserve broad CI-equivalent parity for package closeout.

## Risk-Ordered Default Sequence

1. Resolve capabilities, owning manifests, environment, topology, and readiness.
2. Run static checks and contract/schema validation for touched scopes.
3. Run narrow unit/provider/component tests.
4. Run integration/module/adapter tests for crossed internal or external boundaries.
5. Run application/contract/end-to-end evidence required by the behavior claim.
6. Build/publish and run browser/device lanes only when those surfaces are active and affected.
7. Attest runtime freshness before accepting manual/browser/device observations.
8. Run applicable broad project-owned CI-equivalent rows at package closeout.
9. Produce the final stage report and decision-adherence result.

Adjust this order only when the frozen baseline documents a safer dependency order. Do not insert Laravel, Flutter, NestJS, a database, a transport, a browser, or a device merely because this skill supports it.

## Conditional Stack Routing

- **NestJS:** resolve the owning `package.json`; use its runner/scripts for provider/unit, testing-module integration, and externally visible application contract evidence. Require database/container/platform lanes only when active.
- **Laravel:** use the project-owned safe runner and approved local services; apply MongoDB replica-set rules only when MongoDB is the declared datastore.
- **Flutter:** run affected unit/widget/integration lanes, then project-owned web build/browser or device lanes only for claimed platforms.
- **Browser/Web:** use authored browser tests and project-owned build/publish runners; compiled outputs are not test source.

## Failure Classification

Classify every failure before changing product code:

- `product regression`;
- `test/assertion defect`;
- `CI/harness defect`;
- `environment/transient infrastructure defect`.

Only product regressions and test/assertion defects authorize product/test changes by themselves. Harness and environment failures invalidate the run as product evidence until readiness is restored or a valid equivalent reproduces the failure.

## Deterministic Helper

Use:

```bash
bash delphi-ai/tools/test_orchestration_status_report.sh \
  --scope <small|medium|big> \
  --require-stage <stage> \
  --stage <stage>=<passed|failed|blocked|flaky|skipped|not-applicable> \
  --decision <ID>=<adherent|exception>
```

The helper records status coherence. Capability selection, command ownership, failure classification, waiver validity, and fix-loop judgment remain human-led.

## Done Criteria

- Every affected behavior has sufficient item-specific evidence or a recorded structure-only rationale.
- Every applicable CI-equivalent row has a local passed row or approved waiver.
- No required stage remains blocked, failed, or flaky without approved disposition.
- Runtime-dependent evidence proves the intended build and topology.
- Decision adherence, residual risk, and follow-up actions are explicit.
