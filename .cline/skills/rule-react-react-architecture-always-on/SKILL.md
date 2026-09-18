---
name: rule-react-react-architecture-always-on
description: "Rule: Use for work in a project-declared React capability to preserve render purity, state ownership, effect discipline, accessibility, async safety, and test boundaries without inferring other stacks."
---

# React Architecture Rule

When `react` is active:

- Keep components and hooks pure during render; never mutate props, state, hook inputs, globals, or external systems there.
- Give each state value one intentional owner. Derive renderable values and avoid redundant, contradictory, duplicated, or unnecessarily deep state.
- Use effects only for external synchronization; keep user-triggered behavior in event handlers, include every reactive dependency, add cleanup where synchronization can outlive the render, and refactor rather than suppress dependency lint.
- Follow the Rules of Hooks and the project version/lint contract. Ordinary hooks stay at the top level; use the documented conditional/loop exception for the `use` API only when supported, while preserving its remaining restrictions.
- Keep visual composition, interaction/application behavior, and external adapters separated in proportion to the feature.
- Make reachable loading, empty, success, validation, authorization, and error states explicit; control stale async results and duplicate actions.
- Preserve semantic HTML, keyboard/focus behavior, accessible names, and status/error announcements.
- Use stable identity for lists and state preservation.
- Use project-owned scripts and test observable behavior. React implies neither Vite nor a runner, router, state library, backend, browser tool, or deployment platform.

Run `python3 delphi-ai/tools/node_capability_surface_audit.py --repo <repo-root> --expect react`, adding exact required scripts and `--manifest <relative/package.json>` when ownership is ambiguous. For UI boundary changes, follow `delphi-ai/workflows/react/change-ui-boundary-method.md`.
