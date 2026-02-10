---
name: flutter-smell-image-media
description: "MUST use when image/media loads are slow, broken, or cause jank. Flags missing caching, placeholders, and excessive rebuilds." 
---

# Image/Media Smell

## Smell signals
- Large images without caching/placeholder/error handling.
- Image widgets rebuilt frequently (no memoization/keys).
- Media decode on main thread due to oversized assets.

## Fix guidance
- Use cached image providers where applicable.
- Add placeholders and error widgets.
- Avoid rebuilding image widgets unnecessarily.
