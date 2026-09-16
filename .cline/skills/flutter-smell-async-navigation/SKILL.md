---
name: flutter-smell-async-navigation
description: "MUST use when navigation happens inside async gaps, after awaits, or in UI callbacks. Flags navigation ownership issues and enforces controller/router/guard handling."
---

# Async Navigation Smell

## Smell signals
- `Navigator`/router calls after `await` in UI.
- AutoRoute/project-router calls from `.then`, `whenComplete`, stream listeners, timers, or other callbacks that run after an async gap.
- UI widgets deciding post-async navigation.
- Route changes dependent on in-widget async state.

## Fix guidance
- Move navigation decisions to controller or route guard.
- Emit navigation intents from controller; widgets execute only the resulting synchronous project-router navigation.
- Convert post-async decisions into a controller intent, then let the widget perform the resulting navigation synchronously through the project router.
- Keep async work off the widget lifecycle.
