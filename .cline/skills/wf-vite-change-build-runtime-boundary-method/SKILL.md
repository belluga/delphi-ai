---
name: wf-vite-change-build-runtime-boundary-method
description: "Workflow: Use when changing Vite config, modes, environment exposure, dev server/proxy, assets, base path, or build output."
---

# Change a Vite Build or Runtime Boundary

1. Resolve the owner manifest, version, config/module system, rendering target, serving subpath, and project commands.
2. Audit exact `vite` evidence and required scripts without aggregating manifests.
3. Define mode/env precedence and public client-variable names without exposing values.
4. Separate dev server/proxy from production ingress, CORS, TLS, domains, and API discovery.
5. Validate base path, public/imported assets, output, chunk/source-map policy, and caching assumptions.
6. Apply SSR, library, worker, plugin, framework, browser, container, or platform behavior only when declared.
7. Run exact lint/typecheck/test/build commands; preview is local build evidence only.
8. For a hosted claim, attest the revision and test real asset, navigation/reload, and API boundaries.

Complete only when build/runtime evidence matches the declared target and no unrelated capability was inferred.
