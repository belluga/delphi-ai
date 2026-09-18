<!-- Generated from `rules/stacks/react/react-architecture-always-on.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# React Architecture

## Rule

Apply these rules whenever the project activates the `react` capability:

- Keep components and hooks pure during render. Do not mutate props, state, hook arguments, module globals, or external systems while rendering.
- Model each piece of state with one intentional owner. Avoid contradictory, redundant, duplicated, or unnecessarily deep state; derive renderable values from existing inputs instead of synchronizing duplicate state.
- Use effects only to synchronize with systems outside React. Put user-triggered work in event handlers and compute render-only transformations during render. Include every reactive dependency; refactor the effect or surrounding code instead of suppressing dependency lint.
- Follow the Rules of Hooks and the project's version/lint contract. Call ordinary hooks only at the top level of React components or custom hooks; apply the documented conditional/loop exception for the `use` API only when the project's React version supports it, while preserving its remaining restrictions.
- Separate UI rendering, interaction/application behavior, and external data adapters at boundaries proportionate to the feature. Do not hide domain rules or transport details inside reusable visual components.
- Represent loading, empty, success, validation, authorization, and failure states explicitly when the user flow can reach them. Prevent stale responses and duplicate actions where asynchronous work can race.
- Preserve semantic HTML, keyboard operation, focus behavior, accessible names, and error/status announcements for affected interactions.
- Keep server data, URL/navigation state, form state, and ephemeral presentation state distinct unless the project contract deliberately unifies them.
- Use stable identity for list keys and state preservation. Index keys are acceptable only when ordering and identity cannot change in a way that affects behavior.
- Test observable component and user behavior with the project-declared runner and rendering/browser tools. React does not imply Vitest, Jest, Testing Library, Playwright, Vite, a router, or a state library.
- Use the project-declared package manager, owning manifest, scripts, TypeScript/JavaScript mode, rendering target, and build/runtime contract. Never infer Vite, a browser-only target, server rendering, or a backend from React alone.

## Enforcement

- Run `python3 delphi-ai/tools/node_capability_surface_audit.py --repo <repo-root> --expect react` before relying on detected React evidence.
- Add `--require-script <script-name>` for project-required checks and select the owning package with `--manifest <relative/package.json>` when more than one manifest matches.
- Review state ownership, render purity, effects, asynchronous races, accessibility, stable identity, and observable test evidence for each changed UI boundary.

## Notes

Follow `delphi-ai/workflows/react/change-ui-boundary-method.md` when adding or changing a component, hook, context/provider, form, route-facing view, or interactive state boundary.

## Workflow Reference

See: `.clinerules/workflows/react-change-ui-boundary-method.md`
