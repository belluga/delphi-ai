<!-- Generated from `rules/stacks/nestjs/nestjs-architecture-always-on.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# NestJS Architecture

## Rule

Apply these rules whenever the project activates the `nestjs` capability:

- Organize application behavior around explicit domain or use-case modules. Treat a module's exported providers as its public interface; do not export internal providers merely to bypass a boundary.
- Keep transport adapters thin. Controllers, resolvers, gateways, message handlers, and scheduled entrypoints validate/map inputs, invoke application behavior, and map results; they do not become the authoritative home of business rules.
- Use dependency injection through explicit provider tokens/contracts at infrastructure boundaries. Do not couple application behavior directly to a specific ORM, database, queue, HTTP adapter, deployment platform, or frontend unless that capability is also project-declared.
- Make provider lifetime deliberate. Singleton is the ordinary NestJS scope; request/transient scope requires a documented need and validation proportional to its runtime cost and state semantics.
- Validate every externally controlled boundary using runtime-capable schemas, pipes, parsers, or equivalent project-declared mechanisms. TypeScript types alone are not runtime validation. Unknown-field, coercion, defaulting, and rejection behavior must be explicit.
- Validate required configuration during bootstrap and fail before serving work when required values are missing or invalid. Record variable names and semantics, never secret values.
- Keep authentication and authorization transport-aware and explicit through the project's guards/policies/contracts. NestJS activation does not imply HTTP, JWT, RBAC, tenancy, or any particular identity provider.
- Map domain failures to stable boundary errors without leaking stack traces, credentials, database details, or framework internals.
- Keep persistence and external integrations behind owned adapters. NestJS does not imply Prisma, PostgreSQL, Docker, Railway, React, or Vite.
- Test changed behavior at the narrowest faithful layer: provider/use-case tests for business decisions, module integration tests for wiring and adapters, and application-level tests for externally visible contracts. Use the project-declared runner; NestJS does not mandate Jest or Vitest.
- Use the project-declared package manager, lockfile, scripts, Node version, module system, and build/start contract. Never invent universal commands from Delphi examples.

## Rationale

Nest modules encapsulate providers by default and expose dependencies through explicit exports. Preserving that boundary keeps domain behavior testable and prevents framework, transport, persistence, or deployment choices from silently coupling otherwise independent capabilities.

## Enforcement

- Run `python3 delphi-ai/tools/node_capability_surface_audit.py --repo <repo-root> --expect nestjs` before relying on a detected NestJS surface.
- Add `--require-script <script-name>` for each package script required by the project-owned validation contract. When multiple manifests match, select the owning package explicitly with `--manifest <relative/package.json>`; never aggregate scripts across packages.
- Review module exports, provider scopes, runtime validation, bootstrap configuration, authorization boundaries, and test evidence for every changed entrypoint.

## Notes

Follow `delphi-ai/workflows/nestjs/change-application-boundary-method.md` when adding or changing a controller, resolver, gateway, consumer, command, scheduled entrypoint, or module-owned public contract.

## Workflow Reference

See: `.clinerules/workflows/nestjs-change-application-boundary-method.md`
