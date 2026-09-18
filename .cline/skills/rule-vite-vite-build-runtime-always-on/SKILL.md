---
name: rule-vite-vite-build-runtime-always-on
description: "Rule: Use for project-declared Vite work to preserve mode, environment exposure, dev/prod, asset, output, and runtime boundaries without inferring a UI framework or platform."
---

# Vite Build and Runtime Rule

- Use the owning manifest, pinned Vite version, module system, config, lockfile, and project scripts.
- Treat client-exposed environment variables as public; validate string conversion/semantics, never record values, and forbid empty/broad public env-prefix exposure.
- Keep modes distinct from deployment environments and `NODE_ENV`; document process/file precedence and keep local override files untracked.
- A dev proxy does not prove production ingress/CORS/TLS, and preview is not a production server.
- Validate base paths, assets, output, chunks/source maps, and hosted subpaths against the real serving contract; resolve destructive output cleaning before build.
- Keep dev host, allowed-hosts, and CORS exposure narrow.
- Keep source/tests outside generated output and require reproducible builds.
- Load SSR, library, framework, browser, container, or platform guidance only when independently active.

Run `python3 delphi-ai/tools/node_capability_surface_audit.py --repo <repo-root> --expect vite` with project-required scripts and an owning `--manifest` when ambiguous. Use the Vite boundary workflow for config/runtime changes.
