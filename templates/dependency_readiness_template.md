# Template: Dependency Readiness Register

Use this file as a persistent, non-blocking readiness memory artifact, typically at `foundation_documentation/artifacts/dependency-readiness.md`.

This register is for external systems whose health can change outside the repository:
- GitHub / `gh`
- MCP servers
- OAuth providers
- third-party APIs/services
- device lanes such as ADB
- hosted infrastructure dependencies

This register is **not**:
- a tactical TODO;
- an approval gate by itself;
- the canonical product contract;
- a substitute for tests, validation, or documented architectural decisions.

## Status Definitions

- `unknown`: relevant dependency exists, but current-session verification has not happened yet.
- `healthy`: recently verified and behaving as expected for the current work.
- `degraded`: partially usable, but with reduced confidence or known limits.
- `failing`: currently not usable for the required path.
- `rate-limited`: reachable, but constrained enough to change execution or validation behavior.
- `stale`: last known status exists, but it is old enough that Delphi should not rely on it without re-checking when the work depends on it.

## Snapshot
- **Last updated:** `<YYYY-MM-DD HH:MM TZ>`
- **Current session/profile:** `<profile + scope>`
- **Why this register matters now:** `<brief reason>`

## Dependency Register

| Dependency | Type | Why It Matters | Status | Last Verified | Verification Method | Known Failure Mode | Adjustment / Workaround |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `<GitHub App>` | `<connector|API|device|provider|service>` | `<what depends on it>` | `<unknown|healthy|degraded|failing|rate-limited|stale>` | `<timestamp or n/a>` | `<command, API probe, manual check>` | `<known issue or none>` | `<how Delphi should adapt>` |

## Operational Notes
- If a dependency status is `degraded`, `failing`, `rate-limited`, or `stale`, reflect that in the active TODO’s assumptions, validation steps, qualifiers, or blocker handling.
- `unknown` does not block by default. Re-check only when the current work materially depends on that dependency.
