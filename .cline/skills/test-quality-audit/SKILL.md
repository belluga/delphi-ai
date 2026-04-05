---
name: test-quality-audit
description: "Audit test quality and test-first/TDD alignment for Flutter/Laravel/Web so bypasses, weak assertions, and retrofit-risk are blocked."
---

# Test Quality Audit

## Purpose
Detect and eliminate bypasses, weak assertions, and retrofit-risk that let regressions pass unnoticed, especially on Flutter ↔ Laravel compatibility paths and behavior-defining changes.

## Scope Controls
- This skill never bypasses TODO governance. If project artifacts will change, follow TODO + `APROVADO` gates first.
- Treat tests as executable specifications, not just post-hoc validation. When behavior is verifiable, prefer fail-first/test-first evidence over retrofitted coverage.
- Classify audit complexity as `small|medium|big`:
  - `small`: focused audit, consolidated findings.
  - `medium|big`: include full Plan Review framing for test quality risks (Architecture, Code Quality, Tests, Performance, Security).
- Pair with `bug-fix-evidence-loop` for bugfix/regression root-cause loops.
- Pair with `test-creation-standard` when the audit concludes tests must be created or rewritten.
- Pair with `verification-debt-audit` when closure risk extends beyond tests into evidence drift, waivers, or inline code TODO debt.
- Pair with `frontend-race-condition-validation` when async UI/button/search/filter flows are in scope.

## Preferred Deterministic Helper
- Default static scan for common test-quality signals:
  - `bash delphi-ai/tools/test_quality_audit.sh`
- Scan only the currently changed/untracked test paths:
  - `bash delphi-ai/tools/test_quality_audit.sh --scan-git-modified`
- Restrict the audit to explicit files or folders:
  - `bash delphi-ai/tools/test_quality_audit.sh --path <test-path> [--path <test-path> ...]`
- Exit code `2` means the audit completed and found `medium|high` quality-risk signals. Treat that as evidence to review, not as permission to weaken the test scope.

## Generic Flow Guardrails (Reusable)
- `GF-01` Preflight/harness/environment failures are `blocked` evidence, not product failures by default.
- `GF-02` Shared-lane validation must use canonical product APIs/surfaces; test-only endpoints are forbidden.
- `GF-03` Parse/contract failures in reference assertions are hard-fail conditions.
- `GF-04` Required promotion gates cannot pass with flaky outcomes (including retry-only success).
- `GF-05` Artifact fallback directories that mask permission/ownership faults are forbidden.

## Audit Workflow
1. **Audit framing**
   - Confirm target stacks and compatibility intent (`compatibility` vs `unit-only`).
   - If an active tactical TODO exists, capture relevant decision IDs to validate (`Decision Baseline` reference).
   - Identify critical user journeys that must be proven (for example Home event listing, search, create/edit flows).
2. **Check fail-first / TDD alignment**
   - Identify the recorded or implied test strategy: `test-first|test-after|unknown`.
   - For bugfix/regression or behavior-defining work, identify the concrete failing assertion(s) that should exist before implementation.
   - If current tests only validate the final implementation and would not fail on buggy behavior, classify the finding as `retrofit-risk`.
   - If test-first was intentionally not applicable, require explicit rationale and verify it is coherent with task scope.
3. **Scan for bypass flags**
   - Block: `skip`, `test.only`, `describe.only`, and CI-level golden update bypasses.
   - Block: test-only route usage in shared lanes (for example `/test-support`).
4. **Verify real-backend coverage where required**
   - If compatibility is in scope, confirm integration tests hit a real local backend.
   - Confirm both API reachability and authenticated/identity path are exercised where required.
5. **Check fallback logic**
   - Ensure tests do not silently switch to mocks when real calls fail.
   - Ensure runners do not silently switch output/artifact paths when canonical directories are not writable.
6. **Verify DI parity**
   - If tests override DI/service-locator bindings, lifecycle must match production (`registerFactory` vs `registerSingleton`) unless explicitly asserted and documented.
7. **Validate failure behavior**
   - Ensure tests fail loudly on error payloads, empty responses, and contract mismatches.
   - Block tests that only assert “no exception” or only assert HTTP status without payload semantics when behavior depends on payload.
8. **Validate assertion quality**
   - Ensure assertions check business outcomes, not only transport outcomes.
   - Ensure positive path tests verify expected data presence when the scenario requires data presence.
   - Ensure negative path tests verify explicit failure/error states.
   - Ensure async UI coverage includes race-sensitive scenarios when the product flow can be retriggered or reordered in flight.
9. **Confirm CI environment parity**
   - Laravel tests use local MongoDB with replica set (not Atlas).
   - Local/manual Laravel test execution uses `./laravel-app/scripts/delphi/run_laravel_tests_safe.sh` (or equivalent local-safe env override) and never raw `php artisan test` with inherited environment.
   - Flutter integration tests use domain/scheme overrides (not hardcoded production domains).
10. **Web bundle integrity**
   - Confirm bundle metadata matches pinned Flutter commit.
   - Browser test source-of-truth belongs in `tools/flutter/web_app_tests`.
   - Browser execution must go through `tools/flutter/run_web_navigation_smoke.sh` / `tools/flutter/web_app_smoke_runner`, not via authored tests inside `web-app`.
   - `web-app` must remain a compiled bundle output, not the source location for browser-test authoring.
11. **Platform matrix audit**
   - If compatibility claim includes mobile and web, verify evidence exists for both.
   - Mark missing required platform execution as `blocked`, not `passed`.
12. **Issue cards (mandatory for material findings)**
   - For each issue provide: `Issue ID`, severity, evidence (`file:line`), why-now, options `A/B/C` (include do-nothing when reasonable), and recommended option.
13. **Failure Modes and Uncertainty**
   - Record likely failure modes/edge cases plus assumptions/unknowns/confidence.
14. **Decision Adherence Validation**
   - If baseline decisions exist in active TODO, map each to `Adherent`/`Exception` with evidence.
   - Any unresolved `Exception` means audit outcome is not delivery-ready.

## Common Bypass Patterns (Block)
- Catching exceptions and continuing without failing the test.
- Tests that merely codify current buggy behavior instead of intended behavior.
- Mock fallbacks that hide real backend failures.
- DI lifecycle changes in tests without explicit validation.
- Environment flags that disable real API calls in CI.
- Overly broad network stubs that always return success.
- Assertions that pass on empty data where non-empty behavior is expected.
- Assertions that ignore required UI state transitions (loading -> success/error).
- Assertions coupled only to implementation details while missing user-visible or contract-visible outcomes.
- Test harnesses that bypass navigation/entry flow while claiming end-to-end coverage.
- Flaky-required gates accepted as pass in CI/promotion flow.
- Runner fallback output dirs that hide ownership/permission defects.
- Behavior-defining changes with no clear fail-first target and no rationale for skipping test-first work.

## Required Evidence
- Explicit assertion that real backend was used when required.
- For bugfix/regression or behavior-defining work, evidence of a fail-first target (or explicit rationale for non-applicability).
- Logs/output proving the correct domain + scheme were used.
- Evidence DI wiring matches production, or documented/validated exception.
- CI evidence showing local Mongo + replica set startup.
- Evidence that required platform matrix was executed (`web`, `mobile`) or explicitly marked `blocked`.
- Decision-adherence table when TODO decisions are in scope.

## Done Criteria
- No bypass patterns in changed tests.
- No unresolved `retrofit-risk` for bugfix/regression or behavior-defining work.
- Compatibility tests are real-backend and fail loudly on mismatch.
- CI steps align with local Mongo usage and domain overrides.
- Material findings include issue cards with tradeoffs.
- Required platform execution evidence is complete for claimed compatibility scope.
- Decision-adherence evidence is complete (or explicit approved exception path exists).
