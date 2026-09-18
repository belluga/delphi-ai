---
description: Change a Vite build/runtime boundary with explicit mode, environment exposure, asset, proxy, output, and hosted-runtime evidence.
---

# Method: Change a Vite Build or Runtime Boundary

## Procedure

1. Resolve the owning manifest, pinned Vite version, module system, config files, rendering target, deployment subpath, and exact project scripts.
2. Run the Node capability audit with `--expect vite`; select the owning manifest and require only project-declared scripts.
3. Define mode and environment precedence. Inventory client-exposed variable names/prefixes and runtime validation without recording values.
4. Separate local dev-server/proxy behavior from production ingress, rewrites, CORS, TLS, domains, and backend discovery.
5. Validate `base`, public assets, imported assets, chunking, source maps, output directory, clean/build behavior, and cache expectations against the serving contract.
6. Apply SSR, library mode, workers, framework plugins, or custom transforms only when active; preserve their distinct server/client and build contracts.
7. Run project-owned lint/typecheck/test/build commands. Use preview only as a local built-output check, never as production evidence.
8. If hosted behavior is claimed, attest the built revision and exercise the real base path, asset loading, navigation/reload, and required API boundary.

## Validation

- Exact `vite` evidence and required scripts belong to one owning manifest.
- No secret is client-exposed and mode/env semantics are explicit.
- Dev proxy and preview are not cited as production parity.
- Build/base/assets work under the declared serving target.
- React, another UI framework, browser tooling, Docker, or Railway was not inferred from Vite alone.
