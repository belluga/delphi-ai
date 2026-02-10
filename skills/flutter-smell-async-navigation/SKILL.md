---
name: flutter-smell-async-navigation
description: "MUST use when navigation happens inside async gaps, after awaits, or in UI callbacks. Flags navigation ownership issues and enforces controller/router/guard handling."
---

# Async Navigation Smell

## Smell signals
- `Navigator`/router calls after `await` in UI.
- UI widgets deciding post-async navigation.
- Route changes dependent on in-widget async state.

## Fix guidance
- Move navigation decisions to controller or route guard.
- Emit navigation intents from controller; UI only renders.
- Keep async work off the widget lifecycle.
