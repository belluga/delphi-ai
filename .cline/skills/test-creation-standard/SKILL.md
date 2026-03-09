---
name: test-creation-standard
description: "Create and update Flutter/Laravel/Web tests with baseline governance controls, explicit compatibility gates, and decision-adherence proof."
---

# Test Creation Standard

## Purpose
Establish a high-confidence testing standard for Flutter + Laravel + Web that catches real incompatibilities before deploy and blocks false positives.

## Scope Controls
- This skill does not override TODO governance. If project artifacts change, use tactical TODO (or eligible ephemeral TODO) and obtain `APROVADO` first.
- For medium/big test initiatives, include Plan Review framing before implementation:
  - Architecture, Code Quality, Tests, Performance, Security.
- This skill is for automated test quality and coverage. It does not authorize fallback behavior in production code paths.

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
4. **Build a coverage matrix for each critical path**
   - Required layers:
     - Backend contract/feature tests.
     - Repository/controller state tests.
     - Screen integration test.
     - Navigation test from shell/entry route.
   - If behavior depends on legacy data shape, add fixture/backfill compatibility tests.
4. **Define CI prerequisites**
   - Flutter: backend reachable by domain/scheme overrides.
   - Laravel: local MongoDB with replica set.
   - Web: tests run against built bundle produced after Flutter tests pass.
   - Mobile: emulator/device availability must be explicit (`available` or `blocked`).
5. **Define artifacts and gates**
   - Flutter tests gate web bundle build.
   - Compatibility gate requires web + mobile execution (or explicit blocked status).
   - Docker validation gates deploy on bundle metadata matching pinned Flutter commit.
6. **Implement tests with anti-bypass rules**
   - No silent mock fallback for compatibility/critical-user-journey scope.
   - No committed `skip`, `only`, or committed golden update bypass.
   - No assertions that pass only on “no exception thrown” without business-state verification.
   - No success criteria based solely on HTTP status when payload semantics matter.
7. **Run validation**
   - Execute required suites and CI-equivalent commands.
   - Capture evidence for each frozen decision.
8. **Classify execution status honestly**
   - `passed`: all required gates executed and green.
   - `blocked`: required gate could not run (for example no mobile device/emulator).
   - `failed`: gate executed and failed.
   - `blocked` is never equivalent to `passed`.
9. **Decision Adherence Validation**
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
- Validate: home load, primary navigation, and one critical CTA flow.

## Required Outputs
- Test plan notes (coverage + deliberate exclusions).
- CI steps and gating rationale by stack.
- Bundle metadata evidence (`flutter_git_sha`, `build_time_utc`, `source_branch`).
- Coverage matrix evidence for each critical path.
- Explicit stage status map (`passed|blocked|failed`) for required gates.
- Decision-adherence table for frozen `D-T*` decisions.

## Done Criteria
- Compatibility-critical flows covered by real-backend integration tests across required platforms.
- Flutter tests gate bundle build.
- Deploy gate enforces metadata pin alignment.
- No unresolved `blocked` gate for required compatibility claims.
- Decision-adherence table is fully resolved (`Adherent` or approved baseline update).
