---
name: flutter-smell-build-side-effects
description: "MUST use when build/didChangeDependencies triggers IO, repo calls, logging, telemetry, or side effects. Enforces controller-driven side effects and guarded init." 
---

# Build Side-Effects Smell

## Smell signals
- Repository/network calls in `build`/`didChangeDependencies` without guard.
- Telemetry/logging in build.
- `Future` work started from widget lifecycle without controller mediation.
- `Timer`, periodic work, or `Stream.listen` subscriptions started from `build`/`didChangeDependencies`, including callbacks that can be registered again on rebuild.

## Fix guidance
- Move IO to controller init.
- Use one-time guards (StreamValue or controller flags).
- Create timers/subscriptions from controller-managed initialization and dispose them with the controller lifecycle.
- Keep widgets pure UI.
