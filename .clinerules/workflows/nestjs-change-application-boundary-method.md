---
name: "nestjs-change-application-boundary-method"
description: "Add or change a NestJS application boundary while preserving module ownership, runtime validation, configuration, security, and project-declared verification contracts."
---

<!-- Generated from `workflows/nestjs/change-application-boundary-method.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# Workflow: Change a NestJS Application Boundary

## Purpose

Change a NestJS controller, resolver, gateway, consumer, command, scheduled entrypoint, or module public interface without coupling the application to undeclared transports, persistence technologies, clients, containers, or deployment platforms.

## Triggers

- Add or change an externally reachable NestJS boundary.
- Change a module's imports, exports, provider tokens, or public contract.
- Change validation, configuration, authentication, authorization, error mapping, or provider lifetime.

## Inputs

- Project constitution and every relevant module/boundary contract.
- Active capability namespaces and topology evidence.
- The owning `package.json`, package-manager/lockfile contract, Node version, and project-declared validation scripts.
- Existing module, provider, adapter, bootstrap, and test surfaces.

## Preferred Deterministic Helper

- Run `python3 delphi-ai/tools/node_capability_surface_audit.py --repo <repo-root> --expect nestjs` to confirm exact dependency evidence and inventory manifests, package-manager evidence, and scripts.
- Add `--require-script <script-name>` once for each exact script required by the project contract. When multiple manifests match, pass `--manifest <relative/package.json>` for the owning package; script evidence must not be aggregated across packages. Audit one capability at a time when different packages have different required scripts.
- The helper inventories contracts; it does not execute package scripts or decide architecture.

## Procedure

1. **Profile and capability alignment** – select `Operational / Coder` with `nestjs` plus every other capability actually affected. Do not add `prisma`, `postgresql`, `docker`, `railway`, `react`, or `vite` unless project-owned topology activates it.
2. **Define the boundary contract** – identify protocol/transport, input/output schemas, error mapping, identity and authorization context, idempotency/retry behavior, compatibility expectations, and resource bounds that apply. Do not assume HTTP when the entrypoint is RPC, events, jobs, CLI, GraphQL, or a standalone application.
3. **Assign module ownership** – place the behavior in the domain/use-case module that owns it. Keep exports minimal, use explicit provider tokens at adapter boundaries, and avoid global modules or circular imports as convenience shortcuts.
4. **Implement a thin adapter** – validate and map input at the entrypoint, invoke application behavior through an injected provider, and map the result. Keep domain decisions independent of Nest decorators and transport-specific response objects where practical.
5. **Validate input and configuration** – define runtime validation semantics for external input and bootstrap validation for required configuration. Document variable names/default semantics without storing secrets.
6. **Apply security and lifecycle controls** – enforce project-declared authentication/authorization, safe error exposure, request limits, cancellation/timeouts, and provider lifetime. Add idempotency or concurrency controls only where the contract requires them.
7. **Compose other capabilities conditionally** – load persistence, queues, observability, containers, clients, or deployment workflows only for active namespaces. Keep adapters replaceable and avoid importing provider-specific concerns into the application contract.
8. **Test the changed contract** – cover business decisions at provider/use-case level, module wiring and adapters at integration level, and externally visible success/rejection paths at application level. Use real infrastructure only where the project contract requires it; otherwise replace ports at the module boundary.
9. **Synchronize durable documentation** – update the affected project-owned module/boundary contract. Update the roadmap only for material strategic sequencing or cross-capability follow-up.
10. **Run project-owned verification** – execute the exact declared lint, typecheck/build, test, and contract/e2e commands relevant to the change. Do not substitute package-manager guesses or a Delphi example for the project's command authority.

## Outputs

- Updated NestJS modules, providers, adapters, entrypoints, configuration/validation, and tests within the approved scope.
- Updated project-owned boundary/module documentation and bounded cross-capability follow-up where required.
- Evidence from the Node capability audit and exact project-declared validation commands.

## Validation

- The exact `@nestjs/core` dependency is present in an owning manifest and the project-declared scripts exist.
- Module exports and provider scopes remain intentional; entrypoints stay thin.
- Runtime input/configuration validation and security/error contracts are covered.
- Required unit, integration, and application-level evidence passes through project-owned commands.
- No undeclared capability was activated or treated as implied by NestJS.
