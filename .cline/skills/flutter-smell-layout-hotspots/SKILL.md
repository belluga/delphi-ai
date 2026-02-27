---
name: flutter-smell-layout-hotspots
description: "MUST use when UI jank or layout cost spikes are suspected. Flags layout anti-patterns (intrinsics, heavy builders, unbounded columns) and enforces efficient layout." 
---

# Layout Hotspots Smell

## Smell signals
- `IntrinsicHeight/IntrinsicWidth` in hot paths.
- Large `Column` without scrolling.
- `LayoutBuilder`/`MediaQuery` used repeatedly in deep trees.
- Missing `RepaintBoundary` for heavy subtrees.

## Fix guidance
- Prefer `ListView/SliverList` for large content.
- Use `const` widgets and extract heavy subtrees.
- Add `RepaintBoundary` where repaint cost is high.
