---
name: flutter-smell-list-performance
description: "MUST use when lists/grids are slow or when large collections render. Flags non-builder lists, missing pagination, and improper item keys." 
---

# List Performance Smell

## Smell signals
- Large lists rendered with `Column`/`ListView(children: ...)` instead of builders.
- Missing pagination or over-fetching in UI lists.
- Sorting, filtering, or other large-collection transforms inside `build` on every rebuild.
- Item widgets without stable identity keys in dynamic, stateful, reorderable, or insert/remove-capable lists; index keys are not stable when identity can move.

## Fix guidance
- Use `ListView.builder`/`SliverList`.
- Paginate and fetch in controller/repo.
- Prepare large collection transforms outside `build` or memoize them against explicit inputs.
- Provide stable keys for items.
