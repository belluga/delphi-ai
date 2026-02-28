---
name: test-quality-audit
description: "Audit test quality for Flutter/Laravel/Web with baseline governance controls so bypasses, weak assertions, and non-adherent delivery are blocked."
---

# Test Quality Audit

## Purpose
Detect and eliminate test bypasses that allow failures to pass unnoticed, especially around Flutter ↔ Laravel compatibility, while enforcing baseline decision adherence.

## Scope Controls
- This skill never bypasses TODO governance. If project artifacts will change, follow TODO + `APROVADO` gates first.
- Classify audit complexity as `small|medium|big`:
  - `small`: focused audit, consolidated findings.
  - `medium|big`: include full Plan Review framing for test quality risks (Architecture, Code Quality, Tests, Performance, Security).

## Audit Workflow
1. **Audit framing**
   - Confirm target stacks and compatibility intent (`compatibility` vs `unit-only`).
   - If an active tactical TODO exists, capture relevant decision IDs to validate (`Decision Baseline` reference).
2. **Scan for bypass flags**
   - Block: `skip`, `test.only`, `describe.only`, and CI-level golden update bypasses.
3. **Verify real-backend coverage where required**
   - If compatibility is in scope, confirm integration tests hit a real local backend.
4. **Check fallback logic**
   - Ensure tests do not silently switch to mocks when real calls fail.
5. **Verify DI parity**
   - If tests override DI/service-locator bindings, lifecycle must match production (`registerFactory` vs `registerSingleton`) unless explicitly asserted and documented.
6. **Validate failure behavior**
   - Ensure tests fail loudly on error payloads, empty responses, and contract mismatches.
7. **Confirm CI environment parity**
   - Laravel tests use local MongoDB with replica set (not Atlas).
   - Flutter integration tests use domain/scheme overrides (not hardcoded production domains).
8. **Web bundle integrity**
   - Confirm bundle metadata matches pinned Flutter commit.
   - Browser tests belong in `web-app`, never in `flutter-app`.
9. **Issue cards (mandatory for material findings)**
   - For each issue provide: `Issue ID`, severity, evidence (`file:line`), why-now, options `A/B/C` (include do-nothing when reasonable), and recommended option.
10. **Failure Modes and Uncertainty**
   - Record likely failure modes/edge cases plus assumptions/unknowns/confidence.
11. **Decision Adherence Validation**
   - If baseline decisions exist in active TODO, map each to `Adherent`/`Exception` with evidence.
   - Any unresolved `Exception` means audit outcome is not delivery-ready.

## Common Bypass Patterns (Block)
- Catching exceptions and continuing without failing the test.
- Mock fallbacks that hide real backend failures.
- DI lifecycle changes in tests without explicit validation.
- Environment flags that disable real API calls in CI.
- Overly broad network stubs that always return success.

## Required Evidence
- Explicit assertion that real backend was used when required.
- Logs/output proving the correct domain + scheme were used.
- Evidence DI wiring matches production, or documented/validated exception.
- CI evidence showing local Mongo + replica set startup.
- Decision-adherence table when TODO decisions are in scope.

## Done Criteria
- No bypass patterns in changed tests.
- Compatibility tests are real-backend and fail loudly on mismatch.
- CI steps align with local Mongo usage and domain overrides.
- Material findings include issue cards with tradeoffs.
- Decision-adherence evidence is complete (or explicit approved exception path exists).
