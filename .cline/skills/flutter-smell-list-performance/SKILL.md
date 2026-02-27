---
name: flutter-smell-list-performance
description: "MUST use when lists/grids are slow or when large collections render. Flags non-builder lists, missing pagination, and improper item keys." 
---

# List Performance Smell

## Smell signals
- Large lists rendered with `Column`/`ListView(children: ...)` instead of builders.
- Missing pagination or over-fetching in UI lists.
- Item widgets without stable keys when needed.

## Fix guidance
- Use `ListView.builder`/`SliverList`.
- Paginate and fetch in controller/repo.
- Provide stable keys for items.
