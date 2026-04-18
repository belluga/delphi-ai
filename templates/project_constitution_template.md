# Template: Project Constitution

Use this file as the canonical project-level constitution for `foundation_documentation/project_constitution.md`.

This document is not a roadmap and not a module replacement. Its purpose is to capture the **current system-specific constitution** of a project that inherits the Delphi stack.

## 1. Purpose

- **Project purpose:** `<what the system exists to do>`
- **System boundary:** `<what is inside vs outside this project>`
- **Inherited Delphi stack baseline:** `<which Delphi-level stack/method assumptions are inherited here>`

## 2. Authority Model

### 2.1 Rule Subscriptions (Cascading Rules)

This project follows the PACED **Cascading Rules** hierarchy. The `verify_context.sh --repair` tool uses the `Namespace` below to establish deterministic symlinks for the active stack.

- **Namespace:** `<docker-infra | flutter-app | laravel-app | next-app | custom_stack>`
- **Rule Subscriptions:**
  - [x] **Core Rules:** Universal Delphi patterns (T.E.A.C.H., TODOs, session workflows).
  - [x] **Stack Rules:** Specialized patterns for the `<namespace>` stack.
  - [x] **Local Rules:** Project-specific constitution, modules, and decisions.

### 2.2 Authority Hierarchy

When rules conflict, the following order of precedence applies:
1.  **Local Rules (`.agents/rules/local/`):** This file, module docs, and local decisions. **Local rules always override.**
2.  **Stack Rules (`.agents/rules/stack/`):** Inherited from `delphi-ai/rules/stacks/<namespace>/`.
3.  **Core Rules (`.agents/rules/core/`):** Inherited from `delphi-ai/rules/core/`.

## 3. Ecosystem Alignment & Reuse Doctrine

This project operates within the PACED ecosystem. Implementation must deliberately consider reuse potential to avoid duplication and strengthen the collective baseline.

### 3.1 Abstraction Strategy
- **Ecosystem Bias:** If a capability is credibly reusable across projects and can be abstracted cleanly without leaking project-specific semantics, it should be designed with a **package-capable boundary**.
- **Project Sovereignty:** Capabilities tightly bound to this project's specific tenant model, product posture, or immature/volatile features must remain **project-local**.
- **Anti-Pattern:** Avoid premature abstraction. Implementation remains local unless abstraction is justified, stable, and clean.

### 3.2 Identified Reuse Candidates
| Capability | Reuse Potential | Current Status | Target (Package/Shared) |
| :--- | :--- | :--- | :--- |
| `<feature>` | `<high/med/low>` | `<local/extracting>` | `<target repo/package>` |

## 4. Architecture / Runtime Surfaces
- `<repo or runtime surface>`: `<role>`

### 4.1 Major Modules / Bounded Contexts
- `<module>`: `<responsibility>`

### 4.2 External Integrations
- `<integration>`: `<purpose + boundary>`

## 5. Cross-Module Rules
- `<rule about ownership, orchestration, sequencing, data flow, or dependency direction>`

## 6. Systemic Invariants
- `<invariant that must remain true across modules>`

## 7. Approved Project-Specific Deviations From Delphi Baseline

| Deviation ID | Baseline Being Deviated From | Project-Specific Rule | Why It Exists | Evidence / Module Link |
| --- | --- | --- | --- | --- |
| `DEV-01` | `<Delphi baseline assumption>` | `<project-specific exception>` | `<rationale>` | `<doc/module ref>` |

## 8. Module Map

| Module Doc | Scope | Why It Exists | Key Dependencies |
| --- | --- | --- | --- |
| `foundation_documentation/modules/<module>.md` | `<scope>` | `<purpose>` | `<dependencies>` |

## 9. Strategic Framing
- **Current strategic stage(s):** `<high-level current stage>`
- **Strategic tensions / open fronts:** `<what still needs direction>`
- **Roadmap relationship:** `system_roadmap.md` tracks strategic stages and sequencing.

## 10. Maintenance Rules
- Update this document when project-level rules change.
- Do not duplicate module-local contracts here.
- Do not turn this into a changelog or TODO list.
