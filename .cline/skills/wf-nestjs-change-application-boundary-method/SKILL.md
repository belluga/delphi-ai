---
name: wf-nestjs-change-application-boundary-method
description: "Workflow: Use when adding or changing a NestJS controller, resolver, gateway, consumer, command, scheduled entrypoint, module export, or other application boundary."
---

# Change a NestJS Application Boundary

## Outcome

Deliver the changed NestJS boundary with explicit module ownership, thin transport adapters, runtime validation, bootstrap configuration validation, security/error semantics, and project-owned test evidence—without activating unrelated capabilities.

## Workflow

1. Select `Operational / Coder` with `nestjs` and only the other project-declared capabilities actually affected.
2. Load the project constitution, owning module/boundary contract, active topology, owning `package.json`, package-manager/lockfile evidence, and declared validation commands.
3. Run `python3 delphi-ai/tools/node_capability_surface_audit.py --repo <repo-root> --expect nestjs`; add `--require-script <script-name>` for every exact script required by the project contract. If several manifests match, pass `--manifest <relative/package.json>` for the owner; never aggregate scripts across packages.
4. Define the real transport/protocol, input/output schemas, errors, identity/authorization, compatibility, limits, and retry/idempotency semantics. Do not assume HTTP.
5. Assign behavior to the owning module. Keep exports minimal, use explicit provider tokens at adapter boundaries, and avoid global modules/circular imports as convenience shortcuts.
6. Keep the entrypoint thin: perform boundary validation/mapping, call an injected application provider, and map the result.
7. Validate external input at runtime and required configuration during bootstrap; document names and semantics without secret values.
8. Apply project-declared authorization, safe error exposure, timeouts/cancellation, resource bounds, and provider lifetime.
9. Compose persistence, queues, clients, containers, or platforms only when their independent namespaces are active.
10. Test changed business behavior, module wiring/adapters, and externally visible success/rejection paths at the required layers.
11. Update the durable module/boundary contract and run the exact project-owned lint, typecheck/build, test, and contract/e2e commands.

## Completion Check

- Exact `@nestjs/core` evidence and every required script are present.
- Module exports/provider scopes are intentional and entrypoints remain thin.
- Runtime input/configuration and security/error contracts have evidence.
- Required tests pass through project-owned commands.
- No Prisma, PostgreSQL, React, Vite, Docker, Railway, transport, or test runner was inferred from NestJS alone.
