---
name: flutter-smell-image-media
description: "MUST use when image/media loads are slow, broken, or cause jank. Flags missing caching, placeholders, and excessive rebuilds." 
---

# Image/Media Smell

## Smell signals
- Large images without caching/placeholder/error handling.
- Image widgets rebuilt frequently (no memoization/keys).
- Media decode on main thread due to oversized assets.
- Network images displayed at bounded dimensions without decode sizing (`cacheWidth`/`cacheHeight` or an equivalent provider constraint).

## Fix guidance
- Use cached image providers where applicable.
- Add placeholders and error widgets.
- Size network-image decodes to the rendered bounds where the image provider supports it.
- Avoid rebuilding image widgets unnecessarily.
