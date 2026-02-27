---
name: flutter-performance-smell-scanner
description: "Performance smell scanner for Flutter. MUST use when profiling performance, reviewing jank, or touching UI/rendering/data flows. Enforces a scan for known smells and delegates to smell-specific sub-skills (mounted checks, async navigation, build side effects, layout hotspots, list performance, image/media)."
---

# Flutter Performance Smell Scanner (Umbrella)

Use this skill to scan for performance smells and trigger the specific smell workflows.

## Required sub-skills (invoke as applicable)
- `flutter-smell-mounted-checks`
- `flutter-smell-async-navigation`
- `flutter-smell-build-side-effects`
- `flutter-smell-layout-hotspots`
- `flutter-smell-list-performance`
- `flutter-smell-image-media`

## Notes
- `FutureBuilder`/`StreamBuilder` are NOT allowed; use `StreamValueBuilder` (covered by architecture adherence).
- This scanner is a smell/diagnosis tool; fixes should follow architecture rules (controller ownership, StreamValue, repo boundaries).
