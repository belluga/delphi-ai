# Package-First Verification Gate

## Context
This project follows a **package-first architecture**. Reusable capabilities are extracted into proprietary Laravel packages (`packages/<vendor>/<package>`) and Flutter libraries (`packages/<lib>/`). The authoritative sources for what exists are the **stack manifests** (`pubspec.yaml`, `composer.json`) and the **`packages/` directories** themselves. A lightweight auto-generated checklist at `foundation_documentation/package_registry.md` provides a quick-reference index with usage status, organized by package tier.

## Rule ID
`paced.core.package-first`

## Package Tier Model

Every dependency falls into one of three tiers. The tier determines the **autonomy of change** — how freely the agent can modify, refactor, or extend the package.

| Tier | Autonomy | Scope | Behavior |
| :--- | :--- | :--- | :--- |
| **Local (Project-Bound)** | **Total** — it is our code, impact is contained | Lives in `packages/` within the project repo. Integrated via path. | Treat as modular code. Can modify, refactor, introduce breaking changes freely. Resolve impact in the same PR. No versioning ceremony needed. |
| **Ecosystem (Belluga)** | **High** — it is ours, but impact is cross-project | Independent repository under the org. Integrated via VCS/registry. | Can modify, but must evaluate impact on other consumers. Semantic versioning required. Breaking changes need a migration plan. |
| **External (Third-Party)** | **Low** — we do not control it | Published on pub.dev, Packagist, npm, etc. | Do not modify. Adapt via wrappers, adapters, or extension. Contribute upstream if needed. Pin versions. |

The checklist at `foundation_documentation/package_registry.md` separates packages by tier automatically.

### Practical Implications

**Local packages are almost code.** They exist to centralize and modularize, not to create rigid contracts. If a local package's API needs to change to serve a new feature, change it. The "breaking change" only affects the same repository — fix the callers in the same commit.

**Ecosystem packages carry more weight.** They are still ours, so we have full autonomy over direction and decisions. But other projects depend on them, so changes must be versioned and communicated. The agent should prefer additive changes (new methods, optional parameters) over breaking ones.

**External packages are constraints.** The agent must not assume they can be changed. If the external package does not fit, the correct approach is to wrap it in a local or ecosystem package that provides the interface we need. Never fork an external package unless there is no alternative and the user explicitly approves.

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
2. Review **all three sections**: Ecosystem (Global), Local Laravel, Local Flutter.
3. For each checked `[x]` package that seems relevant, **read its README.md** to understand its API and capabilities.
4. For each unchecked `[ ]` package, evaluate if adopting it would avoid new implementation.
5. If the checklist is missing or stale, run `bash delphi-ai/tools/verify_package_registry.sh --project-root <path>` to regenerate it.

> **Hard Gate:** An absent checklist is not an exemption. The agent must generate it before proceeding.

### Step 2 — Overlap Assessment
For each relevant package found, the action depends on both the overlap and the **tier**:

| Situation | Tier: Local | Tier: Ecosystem | Tier: External |
| :--- | :--- | :--- | :--- |
| Package already provides this capability | **Use directly.** Modify API if needed. | **Use directly.** Prefer additive extension. | **Use directly.** Do not modify. |
| Package provides partial match | **Extend** the package. Breaking changes OK. | **Extend** with additive API. Version bump. | **Wrap** in a local adapter package. |
| No match, but code is reusable | Create a **new local package**. | Propose new ecosystem package (if cross-project). | N/A |
| Code is strictly host-specific | Implement locally. Document rationale. | N/A | N/A |

### Step 3 — Decision Record
The agent must include a **Package-First Assessment** in the TODO:

```
## Package-First Assessment
- Checklist consulted: Yes
- Relevant packages found:
  - [Local] <name> — <action taken>
  - [Ecosystem] <name> — <action taken>
  - [External] <name> — <action taken>
- READMEs read: <list>
- Decision: Extend <package> / New local package <name> / Local implementation
- Tier: Local / Ecosystem / External
- Rationale: <brief>
```

### Step 4 — Post-Implementation
If a new proprietary package was created:
1. Ensure it has a `README.md` following the canonical format (`delphi-ai/templates/package_readme_template.md`).
2. Run `bash delphi-ai/tools/verify_package_registry.sh` to update the checklist automatically.
3. The package will appear in the correct section (Local or Ecosystem) based on its integration method.

## Promotion Path (Local → Ecosystem)

When a local package matures and becomes domain-agnostic, it can be promoted to an ecosystem package. Criteria:

1. **Domain agnosticism:** No business logic specific to the original project.
2. **Contract stability:** Public API is mature and documented (canonical README).
3. **Test independence:** Tests run without the host app.

Promotion procedure:
1. Create independent repository under the org.
2. Move package content; update manifests to use VCS instead of path.
3. Tag first semantic version.
4. Run `verify_package_registry.sh` — package moves from Local to Ecosystem section.

## Anti-Patterns (Hard NO)

- **Duplicating proprietary package logic in host app code.** If a package handles tracking, do not create a parallel tracking service in the host app.
- **Importing a third-party library when a proprietary package already wraps that capability.**
- **Creating "utils" or "helpers" in the host app** for logic that belongs in an existing proprietary package.
- **Skipping the checklist** because "it's a small change." Small changes compound into architectural drift.
- **Forking an external package** without explicit user approval and documented justification.
- **Treating a local package as immutable.** Local packages exist to be changed — do not create workarounds in the host app to avoid touching a local package.

## Enforcement

- **Planning phase:** TODO must include the Package-First Assessment with tier classification.
- **Code review:** New files in `app/Services/`, `app/Helpers/`, `lib/utils/` trigger a package-first review.
- **Delivery gate:** Decision Adherence Gate verifies the assessment was completed and followed.

---
**Authority:** PACED Core Architecture
**Companion:** `paced.core.ecosystem-reuse` (Ecosystem Reuse & Abstraction Boundary Mandate)
