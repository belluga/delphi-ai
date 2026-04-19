# Package-First Verification Gate

## Context
This project follows a **package-first architecture**. Reusable capabilities are extracted into Laravel packages (`packages/<vendor>/<package>`) and Flutter libraries (`packages/<lib>/` or `lib/core/`). The canonical registry of all packages and libraries is maintained at `foundation_documentation/package_registry.md`.

## Rule ID
`paced.core.package-first`

## Activation
This rule activates as a **model-decision** whenever the agent is:
- Planning implementation of a new feature, endpoint, domain, or screen.
- Creating a new controller, service, repository, or utility class.
- Adding a dependency or importing a third-party library.
- Refactoring existing code that touches multiple modules.

## Mandatory Verification Steps

### Step 1 — Registry Consultation
Before writing any implementation code, the agent **must** read `foundation_documentation/package_registry.md` and search for packages or libraries whose purpose overlaps with the planned work.

> **Hard Gate:** If the agent cannot locate or read the package registry, it must create it from the template (`delphi-ai/templates/package_registry_template.md`) before proceeding. An absent registry is not an exemption from the package-first rule.

### Step 2 — Overlap Assessment
For each matching registry entry found, the agent must evaluate:

| Question | If YES |
| :--- | :--- |
| Does an existing package already provide this capability? | **Extend** the existing package. Do not create a parallel implementation. |
| Does an existing package provide a partial match (70%+ overlap)? | **Extend** the existing package with the missing capability. Document the extension in the package README. |
| Is the planned code a good candidate for extraction into a new package? | Plan the implementation as a new package from the start. Register it in the registry. |
| Is the planned code strictly host-specific (tenant model, product posture)? | Implement locally, but document the decision and the reason it cannot be a package. |

### Step 3 — Decision Record
The agent must include a **Package-First Assessment** section in the TODO planning or implementation notes:

```
## Package-First Assessment
- Registry consulted: Yes/No
- Matching packages found: <list or "none">
- Decision: Extend <package> / New package <name> / Local implementation
- Rationale: <why this decision>
```

### Step 4 — Post-Implementation Registration
If a new package or library was created during the TODO:
1. Add it to `foundation_documentation/package_registry.md` with all required fields.
2. Ensure the package has a `README.md` with the canonical sections.
3. For Laravel: register in `scripts/package_architecture_registry.php` if it exists.
4. For Flutter: ensure the library is properly exported and its public API is documented.

## Anti-Patterns (Hard NO)

- **Duplicating package logic in host app code.** If `packages/belluga/settings-kernel` handles settings, do not create a parallel `app/Services/SettingsService.php`.
- **Importing a third-party library when an internal package already wraps that capability.** Check the registry first.
- **Creating a "utils" or "helpers" file in the host app** for logic that belongs in an existing core package or library.
- **Skipping registry consultation** because "it's a small change." Small changes compound into architectural drift.

## Enforcement

- **Planning phase:** TODO planning must include the Package-First Assessment.
- **Code review:** Any new file in `app/Services/`, `app/Helpers/`, `lib/utils/`, or similar host-level utility paths triggers a package-first review.
- **Delivery gate:** The Decision Adherence Gate must verify that the Package-First Assessment was completed and the decision was followed.

---
**Authority:** PACED Core Architecture
**Companion:** `paced.core.ecosystem-reuse` (Ecosystem Reuse & Abstraction Boundary Mandate)
