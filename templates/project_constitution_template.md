# Template: Project Constitution

Use this file as the canonical project-level constitution for `foundation_documentation/project_constitution.md`.

This document is not a roadmap and not a module replacement. Its purpose is to capture the **current system-specific constitution** of a project that inherits the Delphi stack.

The brief purpose/boundary section below is orientation only. Enduring business purpose, principles, and high-level target outcomes belong in `foundation_documentation/project_mandate.md`, while module-local contracts remain in `foundation_documentation/modules/*.md`.

## 1. Purpose

- **Project purpose:** `<what the system exists to do>`
- **System boundary:** `<what is inside vs outside this project>`
- **Inherited Delphi stack baseline:** `<which Delphi-level stack/method assumptions are inherited here>`

## 2. Authority Model

- **Delphi-level authority (inherited):**
  - `delphi-ai/system_architecture_principles.md`
  - Delphi rules, workflows, skills, and templates
- **Project-level authority (this file):**
  - system-specific inter-module rules
  - cross-stack invariants
  - project-specific exceptions to the Delphi baseline
- **Module-level authority:**
  - `foundation_documentation/modules/*.md`
- **Tactical execution authority:**
  - `foundation_documentation/todos/active/*.md`
- **Strategic direction and follow-up:**
  - `foundation_documentation/system_roadmap.md`

## 3. System Topology

### 3.1 Repositories / Runtime Surfaces
- `<repo or runtime surface>`: `<role>`

### 3.2 Major Modules / Bounded Contexts
- `<module>`: `<responsibility>`

### 3.3 External Integrations
- `<integration>`: `<purpose + boundary>`

## 4. Cross-Module Rules

- `<rule about ownership, orchestration, sequencing, data flow, or dependency direction>`

Examples:
- who owns specific fields
- which module may orchestrate which workflow
- where tenant/account/landlord boundaries are enforced
- which repo is authoritative for specific contracts

## 5. Systemic Invariants

- `<invariant that must remain true across modules>`

Examples:
- auth / tenant isolation guarantees
- API/client compatibility expectations
- promotion-lane constraints
- runtime topology invariants
- cross-stack contract rules

## 6. Approved Project-Specific Deviations From Delphi Baseline

| Deviation ID | Baseline Being Deviated From | Project-Specific Rule | Why It Exists | Evidence / Module Link |
| --- | --- | --- | --- | --- |
| `DEV-01` | `<Delphi baseline assumption>` | `<project-specific exception>` | `<rationale>` | `<doc/module ref>` |

Only include this section when the project intentionally deviates from inherited Delphi defaults.

## 7. Module Map

| Module Doc | Scope | Why It Exists | Key Dependencies |
| --- | --- | --- | --- |
| `foundation_documentation/modules/<module>.md` | `<scope>` | `<purpose>` | `<dependencies>` |

## 8. Strategic Framing

- **Current strategic stage(s):** `<high-level current stage>`
- **Strategic tensions / open fronts:** `<what still needs direction>`
- **Roadmap relationship:** `system_roadmap.md` tracks strategic stages, follow-up, sequencing, and large cross-stack movements. It is not the authoritative snapshot of the current system contract.

## 9. Maintenance Rules

- Update this document when project-level rules change.
- Keep this file focused on cross-module rules, systemic invariants, and project-level truths; do not use it as a second mandate and do not duplicate module-local contracts here.
- Do not duplicate module-local contracts here.
- Do not turn this into a changelog or TODO list.
- If a change only affects one module, update the module doc instead.
- If a change affects cross-module behavior, shared invariants, or project-specific deviations from Delphi baseline, update this document.
