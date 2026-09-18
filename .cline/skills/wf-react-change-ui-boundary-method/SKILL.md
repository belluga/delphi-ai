---
name: wf-react-change-ui-boundary-method
description: "Workflow: Use when adding or changing a React component, hook, context/provider, form, route-facing view, or interactive state boundary."
---

# Change a React UI Boundary

## Outcome

Deliver observable React behavior with intentional state ownership, pure rendering, disciplined effects, async safety, accessibility, and project-owned evidence without activating unrelated capabilities.

## Workflow

1. Load the UI/behavior contract, active capabilities, owning manifest, rendering target, and exact project commands.
2. Run `python3 delphi-ai/tools/node_capability_surface_audit.py --repo <repo-root> --expect react`; add project-required scripts and select the owner with `--manifest` when needed.
3. Define reachable user states, inputs/actions, outputs, validation/errors, accessibility, navigation effects, and compatibility expectations.
4. Assign one owner to each state value; distinguish server, URL/navigation, form, and ephemeral UI state and remove derived duplication.
5. Design focused component/hook boundaries and keep external systems behind adapters.
6. Keep render pure. Use event handlers for event-caused work and effects only for external synchronization, with every reactive dependency and appropriate cleanup; refactor rather than suppress dependency lint.
7. Define stale-result, cancellation/ignore, retry, duplicate-action, and recovery behavior for affected asynchronous flows.
8. Validate semantic structure, accessible names, keyboard/focus flow, labels/errors, and status announcements.
9. Compose Vite, backend, router, state library, styling, browser, container, or platform guidance only when independently active.
10. Test observable logic, component interactions/states, adapter contracts, and browser journeys only at the layers included in the claim, then run exact project-owned checks.

## Completion Check

- Exact `react-dom` evidence and required scripts belong to the owning manifest.
- State ownership, render purity, effects, async behavior, and accessibility are explicit.
- Tests assert user-visible or contract-visible outcomes with project-owned tools.
- No Vite, NestJS, runner, router, state library, browser tool, container, or platform was inferred from React alone.
