<!-- Generated from `rules/stacks/vite/vite-build-runtime-always-on.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# Vite Build and Runtime

## Rule

When `vite` is active:

- Use the owning manifest, pinned Vite version, module system, package manager, lockfile, config, and project-owned scripts as command authority.
- Treat every variable exposed to client code as public. Record names, prefixes, modes, string conversion/validation, and semantics, never values; TypeScript declarations do not provide runtime validation. Never permit an empty public env prefix or broad config-time env exposure.
- Keep Vite modes distinct from deployment environments and `NODE_ENV`. Make process-versus-mode-file `.env*` precedence explicit, keep local override files untracked, and never rely on a local file being present in CI or a hosted runtime.
- Treat the development server and proxy as local tooling. They do not prove production ingress, CORS, rewrites, TLS, or backend reachability.
- Validate `base`, asset URLs, public-directory behavior, output directory, chunk/source-map policy, and deployment subpath against the actual serving contract. Resolve the output path before a build because configured cleaning may delete its contents.
- Keep dev host, allowed-hosts, and CORS exposure narrow; do not enable broad network access as a convenience default.
- Do not use the preview server as a production server or as proof of the hosted runtime.
- Keep authored source and tests outside generated build output. Build artifacts must be reproducible from the pinned inputs.
- Activate SSR, library mode, worker handling, framework plugins, browser automation, containers, and deployment guidance only when independently declared.

## Enforcement

- Run `python3 delphi-ai/tools/node_capability_surface_audit.py --repo <repo-root> --expect vite`, adding required scripts and an owning `--manifest` when needed.
- Test the exact project build and, when browser-visible output is claimed, verify the built artifact under the real base/asset/ingress contract.

## Notes

Follow `delphi-ai/workflows/vite/change-build-runtime-boundary-method.md` for config, mode, environment, dev-server, proxy, asset, or build-output changes.

## Workflow Reference

See: `.clinerules/workflows/vite-change-build-runtime-boundary-method.md`
