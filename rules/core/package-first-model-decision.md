# Package-First Verification Gate

## Context
This project follows a **package-first architecture**. Reusable capabilities are extracted into proprietary Laravel packages (`packages/<vendor>/<package>`) and Flutter libraries (`packages/<lib>/`). The authoritative sources for what exists are the **stack manifests** (`pubspec.yaml`, `composer.json`) and the **`packages/` directories** themselves. A lightweight auto-generated checklist at `foundation_documentation/package_registry.md` provides a quick-reference index of proprietary packages with usage status.

## Rule ID
`paced.core.package-first`

## Activation
This rule activates as a **model-decision** whenever the agent is:
- Planning implementation of a new feature, endpoint, domain, or screen.
- Creating a new controller, service, repository, or utility class.
- Adding a dependency or importing a third-party library.
- Refactoring existing code that touches multiple modules.

## Mandatory Verification Steps

### Step 1 — Proprietary Package Scan
Before writing any implementation code, the agent **must**:

1. Read `foundation_documentation/package_registry.md` (the auto-generated checklist).
2. For each checked `[x]` package that seems relevant, **read its README.md** to understand its API and capabilities.
3. If the checklist is missing or stale, run `bash delphi-ai/tools/verify_package_registry.sh --project-root <path>` to regenerate it.

> **Hard Gate:** An absent checklist is not an exemption. The agent must generate it before proceeding.

### Step 2 — Overlap Assessment
For each relevant proprietary package found:

| Situation | Action |
| :--- | :--- |
| Package already provides this capability | **Extend** the existing package. Do not create a parallel implementation. |
| Package provides partial match (related domain) | **Extend** the package with the missing capability. |
| No proprietary package matches, but code is reusable | Plan as a **new proprietary package** from the start. |
| Code is strictly host-specific (tenant model, product posture) | Implement locally, document the rationale. |

### Step 3 — Decision Record
The agent must include a **Package-First Assessment** in the TODO:

```
## Package-First Assessment
- Checklist consulted: Yes
- Relevant proprietary packages: <list or "none">
- READMEs read: <list>
- Decision: Extend <package> / New package <name> / Local implementation
- Rationale: <brief>
```

### Step 4 — Post-Implementation
If a new proprietary package was created:
1. Ensure it has a `README.md` following the canonical format (`delphi-ai/templates/package_readme_template.md`).
2. Run `bash delphi-ai/tools/verify_package_registry.sh` to update the checklist automatically.

## Anti-Patterns (Hard NO)

- **Duplicating proprietary package logic in host app code.** If a package handles tracking, do not create a parallel tracking service in the host app.
- **Importing a third-party library when a proprietary package already wraps that capability.**
- **Creating "utils" or "helpers" in the host app** for logic that belongs in an existing proprietary package.
- **Skipping the checklist** because "it's a small change." Small changes compound into architectural drift.

## Enforcement

- **Planning phase:** TODO must include the Package-First Assessment.
- **Code review:** New files in `app/Services/`, `app/Helpers/`, `lib/utils/` trigger a package-first review.
- **Delivery gate:** Decision Adherence Gate verifies the assessment was completed and followed.

---
**Authority:** PACED Core Architecture
**Companion:** `paced.core.ecosystem-reuse` (Ecosystem Reuse & Abstraction Boundary Mandate)
