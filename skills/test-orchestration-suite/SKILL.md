---
name: test-orchestration-suite
description: "Orchestrate Laravel/Flutter/Web test execution with explicit suite decisions, gate sequencing, and adherence validation before delivery."
---

# Test Orchestration Suite

## Purpose
Provide a single, consistent workflow to execute and validate tests across Laravel, Flutter, and Web with explicit gates, fix-loop controls, and anti-false-positive safeguards.

## Scope Controls
- This skill coordinates execution; it does not bypass TODO governance for code/doc changes.
- Classify orchestration scope:
  - `small`: one stack or targeted rerun.
  - `medium`: multi-stack with one checkpoint before continue.
  - `big`: end-to-end run with checkpointed stage approvals.
- Local transient failures are evidence-quality problems first, not product failures by default.

## Generic Flow Guardrails (Reusable)
- `GF-01` Preflight is mandatory before any suite that can influence promotion decisions.
- `GF-02` Preflight/harness/environment failures are classified as `blocked`, never as product failures by default.
- `GF-03` Shared-lane validation must use canonical product APIs/surfaces; test-only endpoints are forbidden.
- `GF-04` Required promotion gates cannot pass with flaky outcomes (including retry-only success).
- `GF-05` Artifact fallback directories that mask permission/ownership faults are forbidden.
- `GF-06` Contract/payload parse failures in reference assertions are hard-fail conditions.

## Orchestration Flow (Baseline)
1. Preflight environment gate (backend reachability, domain overrides, device/emulator availability, writable artifact/runtime directories, required secrets/vars).
2. Laravel contract/feature tests (local Mongo).
3. Flutter unit + widget tests.
4. Flutter integration tests on web (real backend when compatibility matters).
5. Flutter integration tests on mobile (real backend when compatibility matters).
6. Build web bundle.
7. Web navigation tests from `tools/flutter/web_app_tests` via the dedicated runner (`tools/flutter/run_web_navigation_smoke.sh`), not from inside `web-app`.
8. Compatibility gate: bundle metadata matches pinned Flutter commit.
9. Final report with decision-adherence status.

## Decision Gate: Compatibility vs Speed
- If scope includes compatibility/integration/e2e, real-backend integration is mandatory.
- If scope is unit-only regression, unit/widget suites may be sufficient.
- Freeze this decision before execution as `D-RUN-*`.
- Freeze required platform matrix (`web-only` vs `web+mobile`) as a decision; do not downgrade mid-run without explicit baseline update.

## Stage Procedure
1. **Plan and freeze**
   - Record `D-RUN-*` decisions for required suites, sequence, fail-fast behavior, and acceptance criteria.
   - Record required platform matrix and required user journeys.
2. **Execute stages in order**
   - Stop on first failed gate.
3. **Fix loop control**
   - If a fix is needed, apply TODO discipline (ephemeral or tactical lane as eligible), get approvals, then rerun failed stage.
   - Fixes must target root cause; relaxing assertions, adding fallback/mocks, or skipping stages to turn red into green is invalid.
4. **Execution status policy**
   - Mark each required stage as `passed`, `failed`, or `blocked`.
   - `blocked` (for example no mobile device/emulator) is not `passed` and blocks compatibility closure unless baseline explicitly excludes it.
   - Any required stage with `flaky` status (including pass-after-retry) is `failed` for promotion purposes unless an explicit approved waiver exists.
   - If preflight or harness readiness is invalid, classify the stage as `blocked`/invalid evidence before reading it as a product failure.
   - Do not open product investigation or patch product code when the failing cause is local/transient infrastructure, harness readiness, permission ownership, missing secrets, or target reachability outside the product boundary.
4. **Failure Modes and uncertainty**
   - Capture edge cases (flaky env, backend mismatch, metadata mismatch), assumptions, unknowns, and confidence.
5. **Decision Adherence Validation**
   - Validate each `D-RUN-*` decision as `Adherent` or `Exception` with evidence.
   - Unresolved `Exception` blocks run closure.

## Failure Classification Rule
- Before investigating product code, classify each failure into one of:
  - `product regression`
  - `test or assertion defect`
  - `CI or harness defect`
  - `environment or transient infra defect`
- Only the first two categories authorize product/test-code investigation on their own.
- `CI or harness defect` and `environment or transient infra defect` invalidate that execution as product evidence until the readiness issue is cleared or a valid equivalent gate reproduces the failure.
- A valid remote failure can still be authoritative when a local reproduction attempt is itself `blocked` by unrelated harness/environment issues.

## Laravel Stage
- Run against local MongoDB with replica set.
- Never use Atlas in CI-oriented flows.
- On failure, stop and escalate with actionable error context.
- Include contract-critical suites for API payload semantics that power UI critical paths.
- Local Docker execution must use the canonical safe runner:
  - `./laravel-app/scripts/delphi/run_laravel_tests_safe.sh <test-args>`
  - (equivalent canonical source: `delphi-ai/scripts/laravel/run_laravel_tests_safe.sh`)
- Direct `docker compose exec ... php artisan test` is forbidden in orchestration flows unless the command explicitly overrides `APP_URL/APP_HOST/DB_URI/DB_URI_LANDLORD/DB_URI_TENANTS` to local-safe values.
- If the safe runner blocks for non-local hosts/URIs, stop and fix environment inputs; do not bypass.

## Flutter Stage
- Run unit + widget first.
- For unstable environments, use resilient detached runner when appropriate.
- Run integration with domain/scheme overrides for local backend.
- No mock fallback when real backend is required.
- For compatibility claims, require both:
  - web integration flow(s),
  - mobile integration flow(s).
- If one platform cannot run, mark `blocked` and stop compatibility closure.

## Web Stage
- Browser test source-of-truth lives in `tools/flutter/web_app_tests`.
- Execute browser tests only through the dedicated runner `tools/flutter/run_web_navigation_smoke.sh`, which uses `tools/flutter/web_app_smoke_runner/` as the Playwright runtime.
- `web-app` is the built bundle output only; do not treat it as the source location for navigation tests.
- Browser runners must establish preflight readiness before execution (artifact directory writable, host reachable, required env present). If that readiness is not met, stop with `blocked`; do not treat the result as a product failure.
- Validate home load, primary route, and one critical CTA flow.
- Enforce metadata pin check before declaring success.

## Required Outputs
- Concise stage report:
  - suites run
  - passed/failed/blocked gates
  - reruns/fix loops executed
  - follow-up actions
- Decision-adherence table for `D-RUN-*` decisions.
- Explicit statement of root cause for each failed stage and the fix applied.

## Done Criteria
- Requested suites completed with expected gate behavior.
- Compatibility gates satisfied when in scope.
- No required stage remains `blocked` unless baseline explicitly excludes it.
- Decision-adherence table fully resolved.
- Any residual risk documented explicitly.
