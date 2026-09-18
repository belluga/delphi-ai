---
name: "react-change-ui-boundary-method"
description: "Add or change a React UI boundary while preserving state ownership, render purity, effect discipline, accessibility, async safety, and project-declared verification."
---

<!-- Generated from `workflows/react/change-ui-boundary-method.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# Workflow: Change a React UI Boundary

## Purpose

Change a React component, hook, context/provider, form, route-facing view, or interactive state boundary without coupling it to undeclared build tools, routers, state libraries, backends, browsers, or deployment platforms.

## Inputs

- Project constitution, active capability namespaces, UI/behavior contract, and relevant design/accessibility requirements.
- Owning `package.json`, package-manager/lockfile evidence, rendering target, and exact project-owned lint, typecheck, test, build, and browser commands.
- Existing component composition, state owners, external adapters, error conventions, and test surfaces.

## Preferred Deterministic Helper

- Run `python3 delphi-ai/tools/node_capability_surface_audit.py --repo <repo-root> --expect react` to confirm exact `react-dom` evidence and inventory owning manifests and scripts.
- Add exact `--require-script <script-name>` values from the project contract. When multiple manifests match, pass `--manifest <relative/package.json>`; never aggregate scripts across packages.
- The helper inventories capability evidence. It does not select a build tool, router, state library, rendering mode, or test runner.

## Procedure

1. **Align scope and capabilities** – select `Operational / Coder` with `react` plus only independently activated capabilities. Do not infer `vite`, `nestjs`, a router, browser automation, or deployment.
2. **Define observable behavior** – record user states, inputs/actions, outputs, validation, errors, accessibility semantics, navigation effects, compatibility, and loading/empty/success paths.
3. **Assign ownership** – identify the single owner for each state value and distinguish server, URL/navigation, form, and ephemeral UI state. Remove derived or duplicated state where practical.
4. **Design component boundaries** – keep visual components driven by explicit props, move reusable stateful behavior into focused hooks/components, and keep external systems behind adapters or project-owned integration boundaries.
5. **Preserve render purity** – keep mutations and external work out of render. Put event-caused work in handlers and use effects only for synchronization with external systems, including every reactive dependency and cleanup when synchronization can outlive a render. Refactor rather than suppress dependency lint.
6. **Control async behavior** – define cancellation/ignore semantics, stale-result handling, retries, duplicate-action prevention, and visible progress/error recovery when relevant.
7. **Preserve accessibility** – validate semantic structure, accessible names, keyboard and focus flow, form labels/errors, and live status behavior for affected interactions.
8. **Compose other capabilities conditionally** – load Vite, backend, API, routing, styling, state management, browser, container, or deployment guidance only when the project declares it.
9. **Test at faithful layers** – cover pure logic/hooks where useful, component interactions and states, adapter contracts, and browser journeys only when the changed claim crosses that surface. Use project-owned tools and deterministic fixtures.
10. **Synchronize durable contracts** – update affected UI/module documentation and run exact project-owned checks; broad CI-equivalent evidence remains a package-closeout gate.

## Validation

- Exact `react-dom` evidence and required project scripts belong to the selected manifest.
- State has intentional ownership; render stays pure and effects synchronize only external systems.
- Reachable UI states, async races, and affected accessibility behavior have evidence.
- Tests assert observable outcomes without assuming a particular runner or build tool.
- No Vite, NestJS, router, state library, browser tool, container, or platform was inferred from React alone.
