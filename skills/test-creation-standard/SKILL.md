---
name: test-creation-standard
description: "Create or update tests for project-declared stacks with test-first bias, risk-based evidence layers, compatibility gates, and decision-adherence proof."
---

# Test Creation Standard

## Purpose

Establish a stack-aware testing standard that treats tests as executable specifications, selects evidence from changed behavior and contracts, and blocks false confidence without imposing an unrelated framework, runner, database, transport, browser, or device.

## Scope Controls

- This skill does not override TODO governance. If project artifacts change, use tactical TODO (or eligible ephemeral TODO) and obtain `APROVADO` first.
- For medium/big test initiatives, include Plan Review framing for Architecture, Code Quality, Tests, Performance, and Security.
- Resolve active capabilities and owning manifests before selecting commands or evidence lanes.
- Use exact project-owned package-manager, runner, build, and CI-equivalent commands. Never infer a runner from a framework name alone.
- Prefer test-first sequencing when behavior is verifiable, especially for bugfixes, regressions, user-visible behavior, and contract changes.
- A test may replace an external dependency only at an intentional boundary. Compatibility evidence must not silently fall back from required real infrastructure to a mock.
- When a test changes a stage-facing suite family, wrapper, lifecycle step, or broad local gate such as `stage-full`, load `ci-equivalent-test-surface-admission`.

## Preferred Deterministic Helpers

- Use `bash delphi-ai/tools/test_coverage_matrix_scaffold.sh --intent <compatibility|unit-regression|critical-user-journey> --strategy <test-first|test-after|not-applicable> --platform-matrix <value> --behavior "<critical path>" [--behavior "..."] [--layer "<project layer>"] [--prerequisite "<requirement>"] [--stage "<project stage>"] [--decision "D-T01:..."] [--output <path>]` to scaffold the coverage matrix. Its defaults are stack-neutral; pass the optional rows when the project contract is more specific.
- For a Node/TypeScript capability, use `python3 delphi-ai/tools/node_capability_surface_audit.py --repo <project-root> --expect <capability> [--manifest <relative/package.json>] [--require-script <script>]` to resolve the owning manifest and declared script surface without executing package scripts.
- Helpers provide repeatable facts and structure. Test design, exclusions, runner choice, and approval-sensitive tradeoffs remain judgment-led.

## Workflow

1. **Resolve the target and intent**
   - Record the active stack capabilities, owning package/workspace, changed behavior, and intent: `compatibility`, `unit-regression`, or `critical-user-journey`.
   - Resolve topology before requiring runtime, browser, device, container, or hosted-service evidence.
2. **Choose the minimum evidence layers that prove the claim**
   - Unit/provider/component: isolated decisions, transformations, state, and failure behavior.
   - Integration/module/adapter: framework wiring and collaboration across an intentional boundary.
   - Contract/application/end-to-end: externally visible behavior through the real boundary claimed by the change.
   - Browser/device: only when that surface is active and materially affected.
   - Large or architectural changes require integration evidence for affected critical paths; unit evidence alone cannot prove boundary compatibility.
3. **Freeze test decisions**
   - Record decision IDs such as `D-T01` for scope, environment, evidence lanes, deliberate exclusions, and gate criteria.
   - Freeze expected outcomes before implementation.
4. **Define fail-first targets**
   - Record `test-first`, `test-after`, or `not-applicable`.
   - For verifiable behavior, identify the assertion or scenario that should fail before the implementation changes.
   - Record a concrete rationale when test-first is not applicable.
5. **Build a coverage matrix per critical path**
   - Map each behavior to the smallest sufficient evidence layers and exact project-owned command.
   - Add fixture, migration, or backward-compatibility cases when legacy data or payload shapes are involved.
   - For retriggerable asynchronous flows, cover duplicate triggers, stale responses, cancellation/disposal, retry, or explain non-applicability.
   - Own exact proof subjects deterministically through a self-seeded entity, managed fixture, or canonical equivalent. Never depend on ambient first-row or first-candidate data.
6. **Define prerequisites and topology**
   - Record required services, hosts, environment variables, secrets, writable artifact paths, tenant/domain, and runtime owner.
   - Require real database, broker, backend, container, browser, or device infrastructure only when the claimed contract crosses that boundary.
   - Mark unavailable required infrastructure as `blocked`; do not substitute a weaker lane and call it equivalent.
7. **Define artifacts and gates**
   - Order build, test, publish, metadata, and deploy gates according to the active project topology.
   - Treat browser/device evidence as valid only after runtime freshness proves the intended build is being served.
8. **Admit stage-facing changes**
   - Route changes to `CI Equivalent` or broad gate composition through `ci-equivalent-test-surface-admission`.
   - Keep local broad-stage parity and the stage pipeline on the same owner wrapper/leaf-command family.
   - Preserve readonly versus mutation separation; mutation remains non-`main` unless the approved baseline says otherwise.
9. **Implement with anti-bypass rules**
   - No silent mock or live-service fallback.
   - No committed `skip`, `only`, focused-test marker, or golden-update bypass.
   - No assertion that passes only because no exception was thrown or an HTTP status matched when business semantics matter.
   - No retrofit-only coverage when a practical fail-first path existed.
   - Centralize reusable release-gating selectors and fixtures.
10. **Run validation**
    - Run narrow affected-area checks first, then every applicable broad project-owned CI-equivalent row at package closeout.
    - Capture evidence for each frozen decision and run readiness preflights before runtime-dependent suites.
11. **Classify execution honestly**
    - `passed`: the required gate executed and is green.
    - `blocked`: the gate could not produce valid evidence.
    - `failed`: the gate executed and demonstrated a product or assertion failure.
    - `flaky`: any retry-dependent result; it is not promotion-grade evidence without an approved waiver.
    - Do not justify product changes from blocked harness, environment, permission, secret, or reachability evidence alone.
12. **Validate decision adherence**
    - Map each `D-T*` decision to `Adherent` or `Exception` with evidence.
    - An unresolved exception blocks completion.

## NestJS Overlay (Only When Active)

- Unit-test providers, guards, pipes, interceptors, and use cases at their declared boundaries.
- Use the Nest testing module for module integration and replace external ports deliberately; verify provider tokens, scopes, exports, and failure paths.
- Add application-level contract tests for externally visible behavior, using the project's chosen transport and adapter rather than assuming HTTP, Express, or Fastify.
- Use the runner and scripts declared by the owning `package.json`; Jest and Vitest are both valid when project-owned.
- Require PostgreSQL, Prisma, Docker, Railway, or any other external capability only when it is active and the tested contract crosses it.

## Flutter Overlay (Only When Active)

- Use `integration_test` for compatibility flows; large or architectural changes need unit, widget, and integration evidence for affected critical paths.
- Use project-owned `--dart-define` domain/scheme overrides and leave production defaults unchanged.
- Require web and mobile evidence only when the compatibility claim includes both platforms; otherwise record the excluded platform explicitly.
- Pair retriggerable asynchronous UI changes with `frontend-race-condition-validation`.

## Laravel Overlay (Only When Active)

- Use the project-owned safe runner and local service topology; never inherit credentials for a live hosted database.
- When the approved topology uses MongoDB, CI must use the declared local replica-set service rather than Atlas.
- Include required migrations/seeds and assert response semantics, not only status codes.
- Cover legacy payload or data migration behavior when applicable.

## Browser/Web Overlay (Only When Active)

- Keep browser tests in the project-owned authored source, never in compiled output.
- Run the project-owned build/publish path before browser evidence and attest runtime freshness.
- Preflight artifact ownership, target reachability, and required environment variables.
- Validate only the navigation and user journeys materially included in the claim.

## Required Outputs

- Coverage matrix with deliberate exclusions and exact commands.
- Test strategy plus fail-first targets or non-applicability rationale.
- Prerequisite/topology map and explicit `passed|blocked|failed|flaky` status per required gate.
- Evidence for each claimed layer and platform.
- Decision-adherence table for frozen `D-T*` decisions.
- Stack-specific build or bundle metadata only when that artifact is part of the active delivery contract.

## Done Criteria

- Evidence layers match the behavior and boundary claims.
- Large or architectural changes include integration evidence for every affected critical path.
- Applicable behavior-defining paths have a fail-first target or accepted rationale.
- Required compatibility tests use the real declared boundary and fail loudly on mismatch.
- No unresolved blocked, failed, or flaky gate supports a passing claim.
- Decision adherence is resolved.
