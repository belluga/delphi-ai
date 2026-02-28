---
name: test-creation-standard
description: "Create and update Flutter/Laravel/Web tests with baseline governance controls, explicit compatibility gates, and decision-adherence proof."
---

# Test Creation Standard

## Purpose
Establish a consistent, low-ops testing standard for Flutter + Laravel + Web that catches real incompatibilities before deploy, while keeping delivery governance explicit.

## Scope Controls
- This skill does not override TODO governance. If project artifacts change, use tactical TODO (or eligible ephemeral TODO) and obtain `APROVADO` first.
- For medium/big test initiatives, include Plan Review framing before implementation:
  - Architecture, Code Quality, Tests, Performance, Security.

## Workflow
1. **Define target and intent**
   - Target stack: Flutter / Laravel / Web.
   - Intent: `compatibility` vs `unit-regression`.
2. **Choose minimum test types that prove intent**
   - Compatibility requires integration tests against real local backend.
3. **Freeze test decisions**
   - Record decision IDs (e.g., `D-T01`, `D-T02`) for scope, environments, and gate criteria.
   - Freeze expected outcomes before implementation.
4. **Define CI prerequisites**
   - Flutter: backend reachable by domain/scheme overrides.
   - Laravel: local MongoDB with replica set.
   - Web: tests run against built bundle produced after Flutter tests pass.
5. **Define artifacts and gates**
   - Flutter tests gate web bundle build.
   - Docker validation gates deploy on bundle metadata matching pinned Flutter commit.
6. **Implement tests with anti-bypass rules**
   - No silent mock fallback for compatibility scope.
   - No committed `skip`, `only`, or committed golden update bypass.
7. **Run validation**
   - Execute required suites and CI-equivalent commands.
   - Capture evidence for each frozen decision.
8. **Decision Adherence Validation**
   - Build a `Decision Adherence Validation` table for `D-T*` decisions.
   - Any unresolved `Exception` blocks completion until decisions are updated and approved.

## Flutter Guidelines
- Use `integration_test` for compatibility flows.
- Use `--dart-define` for local backend targeting:
  - `LANDLORD_DOMAIN` (e.g., `local.test`)
  - `API_SCHEME` (e.g., `http`)
- Keep production defaults untouched (`https` + production domains).

## Laravel Guidelines
- CI must run against local MongoDB service container with replica set enabled.
- Never use Atlas in CI.
- Include migrations/seed steps required for integration scenarios.

## Web Guidelines
- Browser tests only in `web-app`.
- Run web navigation tests only after Flutter tests pass and bundle is built.
- Validate: home load, primary navigation, and one critical CTA flow.

## Required Outputs
- Test plan notes (coverage + deliberate exclusions).
- CI steps and gating rationale by stack.
- Bundle metadata evidence (`flutter_git_sha`, `build_time_utc`, `source_branch`).
- Decision-adherence table for frozen `D-T*` decisions.

## Done Criteria
- Compatibility-critical flows covered by real-backend integration tests.
- Flutter tests gate bundle build.
- Deploy gate enforces metadata pin alignment.
- Decision-adherence table is fully resolved (`Adherent` or approved baseline update).
