---
name: test-quality-audit
description: "Audit stack-aware test quality and test-first alignment so bypasses, weak assertions, false parity, and retrofit risk are blocked."
---

# Test Quality Audit

## Purpose

Detect bypasses, weak assertions, false environment parity, and retrofit risk across project-declared stacks. Judge evidence against the behavior and boundary claimed, without imposing an unrelated framework, runner, database, transport, browser, or device.

## Scope Controls

- This skill never bypasses TODO governance. If project artifacts change, follow TODO and `APROVADO` gates first.
- Treat tests as executable specifications. Prefer fail-first evidence for verifiable bugfixes, regressions, and behavior-defining changes.
- Classify audit complexity as `small|medium|big`; medium/big audits include Architecture, Code Quality, Tests, Performance, and Security framing.
- Resolve active capabilities, owning manifests, project-owned commands, and affected boundaries before applying stack-specific checks.
- Pair with `bug-fix-evidence-loop`, `test-creation-standard`, `verification-debt-audit`, or `frontend-race-condition-validation` when their scopes apply.

## Preferred Deterministic Helpers

- Run `bash delphi-ai/tools/test_quality_audit.sh`, optionally with `--scan-git-modified` or repeatable `--path <test-path>`.
- For Node/TypeScript capability ownership, run `python3 delphi-ai/tools/node_capability_surface_audit.py --repo <project-root> --expect <capability> [--manifest <relative/package.json>] [--require-script <script>]` before judging runner or script coverage.
- Exit code `2` from the static audit means medium/high signals were found. Review them; do not weaken the scope to clear the signal.

## Generic Guardrails

- `GF-01` Preflight, harness, and environment failures are blocked evidence, not product failures by default.
- `GF-02` Shared-lane validation uses canonical product surfaces; test-only product endpoints are forbidden.
- `GF-03` Parse and contract failures in reference assertions hard-fail.
- `GF-04` Required promotion gates cannot pass with flaky or retry-only outcomes.
- `GF-05` Artifact fallback paths that mask ownership or permission faults are forbidden.
- `GF-06` A narrow test or mocked boundary cannot substantiate a broader compatibility or end-to-end claim.

## Audit Workflow

1. **Frame the audit**
   - Record active capabilities, compatibility intent, changed behaviors, affected boundaries, topology, and relevant baseline decisions.
   - For large or architectural changes, require unit/provider/component plus integration/module/adapter evidence for each affected critical path.
2. **Check fail-first alignment**
   - Identify `test-first`, `test-after`, `not-applicable`, or `unknown` and the concrete assertion that demonstrates the pre-change failure.
   - Classify final-state-only tests that would not expose the bug as `retrofit-risk` unless a coherent non-applicability rationale exists.
3. **Scan for bypass flags**
   - Block committed skips, focused-test markers such as `test.only`/`describe.only`, CI golden-update bypasses, and shared-lane test-only routes.
4. **Match evidence to the claim**
   - Require real infrastructure only when compatibility or the contract crosses that boundary.
   - Verify both reachability and identity/authentication paths when those are part of the claim.
   - Do not accept unit-only evidence for a changed wiring, serialization, persistence, transport, or runtime boundary.
5. **Check fallback logic**
   - Block silent fallback from required real calls to mocks, from an owned fixture to ambient live data, or from canonical artifact paths to fallback directories.
6. **Verify dependency-injection parity**
   - Test replacements must preserve the relevant production token, scope/lifecycle, and failure semantics unless an explicit documented exception is itself asserted.
7. **Validate failure behavior**
   - Require loud failures for error payloads, empty required responses, parse errors, contract mismatches, and rejected dependencies.
   - Block no-exception-only and transport-status-only assertions when business semantics matter.
8. **Validate assertion quality**
   - Assert externally meaningful outcomes and explicit negative states.
   - Cover retriggerable asynchronous races when applicable.
   - Use deterministic owned proof subjects; do not rely on first-row, first-page, or first-candidate ambient data.
9. **Confirm environment and command parity**
   - Verify the exact project-owned runner/package-manager scripts and the topology prerequisites for the active capability.
   - Treat live hosted services, hardcoded production targets, or undeclared local substitutions as findings unless the approved baseline explicitly requires them.
10. **Audit build and runtime integrity when applicable**
    - Confirm authored tests are not stored in compiled output.
    - Match bundle/artifact metadata to the source revision and prove that manual/browser/device targets serve that build.
11. **Audit the claimed platform matrix**
    - Require evidence only for platforms in the claim, but mark any missing required platform `blocked`, never `passed`.
12. **Write issue cards for material findings**
    - Include issue ID, severity, `file:line` evidence, why-now, options A/B/C including do-nothing when reasonable, and recommendation.
13. **Record failure modes and uncertainty**
    - State likely edge cases, assumptions, unknowns, and confidence.
14. **Validate decision adherence**
    - Map each active baseline decision to `Adherent` or `Exception` with evidence. An unresolved exception is not delivery-ready.

## Conditional Stack Checks

- **NestJS:** test provider/use-case behavior, testing-module wiring, provider tokens/scopes/exports, and externally visible contracts at the chosen transport. Use the owning manifest's runner; do not assume Jest, Vitest, HTTP, Express, Fastify, Prisma, or PostgreSQL.
- **Laravel:** use the project-owned safe runner. Require a local MongoDB replica set and prohibit Atlas only when MongoDB is the declared test datastore.
- **Flutter:** require unit, widget, integration, web, or mobile lanes only where the change and platform claim demand them; use project-owned domain/scheme overrides.
- **Browser/Web:** keep test sources outside compiled bundles, use the project-owned browser runner, and require runtime freshness before accepting observations.

## Common Bypass Patterns (Block)

- Catching exceptions and continuing without failing.
- Tests that codify current buggy behavior instead of intended behavior.
- Mock or live-service fallbacks that hide required-boundary failures.
- Dependency-injection scope/token changes without explicit validation.
- Environment flags that disable required integration behavior in CI.
- Overly broad stubs that always succeed.
- Assertions that pass on empty data or ignore required state transitions.
- Ambient live-data selection for release-gating proof subjects.
- End-to-end or architectural safety claimed from unit-only evidence.
- Flaky required gates accepted as pass.
- Behavior-defining changes with no fail-first target and no rationale.

## Required Evidence

- Capability and owning-command inventory.
- Coverage/evidence matrix with deliberate exclusions.
- Proof of the real declared boundary where compatibility requires it.
- Fail-first target or explicit non-applicability rationale.
- Dependency-injection parity evidence or documented/asserted exception.
- Required platform status as `passed|blocked|failed|flaky`.
- Decision-adherence table when baseline decisions are in scope.

## Done Criteria

- No bypass remains in changed tests.
- No unresolved retrofit risk remains for behavior-defining work.
- Evidence layers substantiate, and do not overstate, the compatibility or architecture claim.
- Required real-boundary tests fail loudly on mismatch.
- Exact commands and topology match the declared project surface.
- Material findings have actionable issue cards.
- Required platform and decision evidence is complete or explicitly dispositioned.
