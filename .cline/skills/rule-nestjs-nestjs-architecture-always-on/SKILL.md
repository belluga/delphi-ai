---
name: rule-nestjs-nestjs-architecture-always-on
description: "Rule: Use for work in a project-declared NestJS capability to preserve module, provider, runtime-validation, configuration, and testing boundaries without inferring other stacks."
---

# NestJS Architecture Rule

When `nestjs` is active:

- Treat feature/domain modules as encapsulation boundaries and exported providers as deliberate public interfaces.
- Keep controllers, resolvers, gateways, consumers, commands, and scheduled entrypoints thin; authoritative business decisions belong in application/domain providers.
- Use explicit provider contracts/tokens at infrastructure boundaries. NestJS does not imply an ORM, database, HTTP adapter, frontend, container, or deployment platform.
- Make non-singleton provider scopes exceptional and evidence-backed.
- Require runtime validation for externally controlled inputs and bootstrap validation for required configuration. TypeScript types alone are not runtime evidence; never record secret values.
- Keep identity, authorization, error exposure, limits, retries, and idempotency aligned with the project-owned boundary contract rather than a universal NestJS default.
- Use the project-declared package manager, scripts, Node/module-system contract, and test runner.
- Test business behavior, module wiring/adapters, and externally visible contracts at the layers affected by the change.

Run `python3 delphi-ai/tools/node_capability_surface_audit.py --repo <repo-root> --expect nestjs` and add `--require-script <script-name>` for exact project-required scripts. When several manifests match, select the owner with `--manifest <relative/package.json>`; never combine script evidence across packages. For boundary changes, follow `delphi-ai/workflows/nestjs/change-application-boundary-method.md`.
