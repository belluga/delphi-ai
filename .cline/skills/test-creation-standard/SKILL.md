---
name: test-creation-standard
description: "Create and update Flutter/Laravel/Web tests with test-first/TDD bias, compatibility gates, and decision-adherence proof."
---

# Test Creation Standard

## Purpose
Establish a high-confidence testing standard for Flutter + Laravel + Web that treats tests as executable specifications, catches real incompatibilities before deploy, and blocks false positives.

## Scope Controls
- This skill does not override TODO governance. If project artifacts change, use tactical TODO (or eligible ephemeral TODO) and obtain `APROVADO` first.
- For medium/big test initiatives, include Plan Review framing before implementation:
  - Architecture, Code Quality, Tests, Performance, Security.
- This skill is for automated test quality and coverage. It does not authorize fallback behavior in production code paths.
- This skill must prevent false negatives caused by harness/environment readiness defects from being misclassified as product regressions.
- Prefer test-first sequencing when behavior is verifiable, especially for bugfixes, regressions, user-visible behavior, and contract-level changes.

## Preferred Deterministic Helper
- Use `bash delphi-ai/tools/test_coverage_matrix_scaffold.sh --intent <compatibility|unit-regression|critical-user-journey> --strategy <test-first|test-after|not-applicable> --platform-matrix <value> --behavior "<critical path>" [--behavior "..."] [--decision "D-T01:..."] [--output <path>]` to scaffold the repeatable coverage matrix before filling in the real decisions.
- Treat the helper as the planning skeleton only; actual test design, exclusions, and approval-sensitive tradeoffs remain in this workflow.

## Workflow
1. **Define target and intent**
   - Target stack: Flutter / Laravel / Web.
   - Intent: `compatibility` vs `unit-regression` vs `critical-user-journey`.
2. **Choose minimum test types that prove intent**
   - Compatibility and critical-user-journey require integration tests against real backend.
   - Unit-regression cannot be used to claim end-to-end safety.
3. **Freeze test decisions**
   - Record decision IDs (e.g., `D-T01`, `D-T02`) for scope, environments, and gate criteria.
   - Freeze expected outcomes before implementation.
4. **Define fail-first targets**
   - Record the test strategy as `test-first|test-after|not-applicable`.
   - If behavior is verifiable, define the concrete failing assertion(s) or failing scenario(s) that should go red before implementation.
   - If test-first is not applicable, record why.
5. **Build a coverage matrix for each critical path**
   - Required layers:
     - Backend contract/feature tests.
     - Repository/controller state tests.
     - Screen integration test.
     - Navigation test from shell/entry route.
   - If behavior depends on legacy data shape, add fixture/backfill compatibility tests.
   - If the changed flow includes async UI/buttons/search/filter/pagination/retry behavior, add explicit race-condition scenarios (duplicate trigger, stale response, dispose/navigation mid-flight) or record why they are not applicable.
6. **Define CI prerequisites**
   - Flutter: backend reachable by domain/scheme overrides.
   - Laravel: local MongoDB with replica set.
   - Web: tests run against built bundle produced after Flutter tests pass.
   - Mobile: emulator/device availability must be explicit (`available` or `blocked`).
   - Harness/runtime readiness must be explicit where relevant: writable artifact dirs, required secrets/vars, host/domain reachability, and any lane-specific prerequisites such as local+tunnel topology.
7. **Define artifacts and gates**
   - Flutter tests gate web bundle build.
   - Compatibility gate requires web + mobile execution (or explicit blocked status).
   - Docker validation gates deploy on bundle metadata matching pinned Flutter commit.
8. **Implement tests with anti-bypass rules**
   - No silent mock fallback for compatibility/critical-user-journey scope.
   - No committed `skip`, `only`, or committed golden update bypass.
   - No assertions that pass only on “no exception thrown” without business-state verification.
   - No success criteria based solely on HTTP status when payload semantics matter.
   - No retrofitted tests that only validate the post-fix implementation when a fail-first path was practical.
9. **Run validation**
   - Execute required suites and CI-equivalent commands.
   - Capture evidence for each frozen decision.
   - Run preflight checks before the suite so environment/harness defects are caught as readiness issues, not test failures.
10. **Classify execution status honestly**
   - `passed`: all required gates executed and green.
   - `blocked`: required gate could not run (for example no mobile device/emulator).
   - `failed`: gate executed and failed.
   - `blocked` is never equivalent to `passed`.
   - If the suite cannot produce valid evidence because of local/transient infra, harness readiness, permission ownership, missing secrets, or target unreachability, classify it as `blocked`/invalid evidence rather than `failed`.
   - Do not justify product-code changes from `blocked` local evidence alone.
11. **Decision Adherence Validation**
   - Build a `Decision Adherence Validation` table for `D-T*` decisions.
   - Any unresolved `Exception` blocks completion until decisions are updated and approved.

## Flutter Guidelines
- Use `integration_test` for compatibility flows.
- Use `--dart-define` for local backend targeting:
  - `LANDLORD_DOMAIN` (e.g., `local.test`)
  - `API_SCHEME` (e.g., `http`)
- Keep production defaults untouched (`https` + production domains).
- For critical-user-journey claims, run at least:
  - one web integration flow,
  - one mobile integration flow.
- When async UI actions or rapid user re-entry are in scope, pair the test design with `frontend-race-condition-validation`.

## Laravel Guidelines
- CI must run against local MongoDB service container with replica set enabled.
- Never use Atlas in CI.
- Local/manual Docker runs must use the canonical safe runner:
  - `./laravel-app/scripts/delphi/run_laravel_tests_safe.sh <test-args>`
  - The runner must fail fast when APP/Mongo hosts are not local-safe.
- Include migrations/seed steps required for integration scenarios.
- Add explicit assertions for canonical response semantics (not only status codes).
- Include regression tests for legacy payload/data migration cases when applicable.

## Web Guidelines
- Browser test source-of-truth belongs in `tools/flutter/web_app_tests`.
- Execute web navigation tests through `tools/flutter/run_web_navigation_smoke.sh`, which runs Playwright from `tools/flutter/web_app_smoke_runner/`.
- `web-app` is the compiled bundle output and must not become the authored source location for browser tests.
- Run web navigation tests only after Flutter tests pass and bundle is built.
- Prefer explicit preflight in web runners for artifact directory ownership, reachable target host, and required environment variables. A preflight failure is a harness/readiness outcome, not a product failure.
- Validate: home load, primary navigation, and one critical CTA flow.

## Required Outputs
- Test plan notes (coverage + deliberate exclusions).
- Recorded test strategy plus fail-first targets or explicit non-applicability rationale.
- CI steps and gating rationale by stack.
- Bundle metadata evidence (`flutter_git_sha`, `build_time_utc`, `source_branch`).
- Coverage matrix evidence for each critical path.
- Explicit stage status map (`passed|blocked|failed`) for required gates.
- Decision-adherence table for frozen `D-T*` decisions.

## Done Criteria
- Compatibility-critical flows covered by real-backend integration tests across required platforms.
- When TDD/test-first is applicable, at least one fail-first target exists for each behavior-defining path under change.
- Flutter tests gate bundle build.
- Deploy gate enforces metadata pin alignment.
- No unresolved `blocked` gate for required compatibility claims.
- Decision-adherence table is fully resolved (`Adherent` or approved baseline update).
