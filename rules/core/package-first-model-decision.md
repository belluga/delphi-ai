# Package-First Verification Gate

## Context
This project follows a **package-first architecture**. Reusable capabilities are extracted into proprietary Laravel packages (`packages/<vendor>/<package>`) and Flutter libraries (`packages/<lib>/`).

The agent queries proprietary packages via a **deterministic CLI tool**:

```bash
bash delphi-ai/tools/query_packages.sh --project-root <path> [options]
```

This script reads two YAML sources internally and returns structured results:

| Source | Scope | Maintained by |
| :--- | :--- | :--- |
| `delphi-ai/config/ecosystem_packages.yaml` | **Ecosystem (Global)** — published for cross-project reuse | Manually in PACED |
| `foundation_documentation/local_packages.yaml` | **Local (Project-Bound)** — auto-generated from `packages/` dirs | `verify_package_registry.sh` |

The agent **must not** read these files directly. The CLI is the only interface.

## Rule ID
`paced.core.package-first`

## Package Tier Model

Every dependency falls into one of three tiers. The tier determines the **autonomy of change** — how freely the agent can modify, refactor, or extend the package.

| Tier | Autonomy | Behavior |
| :--- | :--- | :--- |
| **Local (Project-Bound)** | **Total** — it is our code, impact is contained | Treat as modular code. Can modify, refactor, introduce breaking changes freely. Resolve impact in the same PR. No versioning ceremony needed. |
| **Ecosystem (Belluga)** | **High** — it is ours, but impact is cross-project | Can modify, but must evaluate impact on other consumers. Semantic versioning required. Breaking changes need a migration plan. |
| **External (Third-Party)** | **Low** — we do not control it | Do not modify. Adapt via wrappers, adapters, or extension. Contribute upstream if needed. Pin versions. |

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

### Step 1 — Query Proprietary Packages
Before writing any implementation code, the agent **must** run the CLI:

```bash
# Search by capability keyword (e.g., "tracking", "state", "push", "validation")
bash delphi-ai/tools/query_packages.sh --project-root <path> --search "<keyword>"

# Or list all to get full picture
bash delphi-ai/tools/query_packages.sh --project-root <path> --all
```

The script auto-generates `local_packages.yaml` if missing. No manual file reading needed.

**CLI options:**

| Option | Purpose |
| :--- | :--- |
| `--all` | List all proprietary packages |
| `--search <term>` | Search by name or description |
| `--tier local\|ecosystem` | Filter by tier |
| `--stack flutter\|laravel` | Filter by stack |
| `--unused` | Show local packages not yet adopted |
| `--detail <name>` | Full detail including README content |

> **Hard Gate:** The agent must run the query before proceeding. Skipping is a governance violation.

### Step 2 — Read READMEs for Relevant Packages
For each package returned by the query, use `--detail <name>` to read its README content inline:

```bash
bash delphi-ai/tools/query_packages.sh --project-root <path> --detail "<package_name>"
```

### Step 3 — Overlap Assessment
For each relevant package found, the action depends on both the overlap and the **tier**:

| Situation | Tier: Local | Tier: Ecosystem | Tier: External |
| :--- | :--- | :--- | :--- |
| Package already provides this capability | **Use directly.** Modify API if needed. | **Use directly.** Prefer additive extension. | **Use directly.** Do not modify. |
| Package provides partial match | **Extend** the package. Breaking changes OK. | **Extend** with additive API. Version bump. | **Wrap** in a local adapter package. |
| No match, but code is reusable | Create a **new local package**. | Propose new ecosystem package (if cross-project). | N/A |
| Code is strictly host-specific | Implement locally. Document rationale. | N/A | N/A |

### Step 4 — Decision Record
The agent must include a **Package-First Assessment** in the TODO:

```
## Package-First Assessment
- Query executed: bash delphi-ai/tools/query_packages.sh --search "<term>"
- Relevant packages found:
  - [Local] <name> — <action taken>
  - [Ecosystem] <name> — <action taken>
  - [External] <name> — <action taken>
- READMEs read: <list>
- Decision: Use <package> / Adopt <package> / Extend <package> / New package <name> / Local implementation
- Tier: Local / Ecosystem / External
- Rationale: <brief>
```

### Step 5 — Post-Implementation
If a new proprietary package was created:
1. Ensure it has a `README.md` following the canonical format (`delphi-ai/templates/package_readme_template.md`).
2. Run `bash delphi-ai/tools/verify_package_registry.sh` to regenerate `local_packages.yaml`.
3. If the package is ecosystem-level, add it to `delphi-ai/config/ecosystem_packages.yaml`.
4. Verify with `bash delphi-ai/tools/query_packages.sh --detail "<new_package>"`.

## Promotion Path (Local → Ecosystem)

When a local package matures and becomes domain-agnostic, it can be promoted to an ecosystem package. Criteria:

1. **Domain agnosticism:** No business logic specific to the original project.
2. **Contract stability:** Public API is mature and documented (canonical README).
3. **Test independence:** Tests run without the host app.

Promotion procedure:
1. Create independent repository under the org.
2. Move package content; update manifests to use VCS/registry instead of path.
3. Tag first semantic version.
4. Add entry to `delphi-ai/config/ecosystem_packages.yaml`.
5. Run `verify_package_registry.sh` — package moves from local YAML to ecosystem YAML.

## Anti-Patterns (Hard NO)

- **Duplicating proprietary package logic in host app code.** If a package handles tracking, do not create a parallel tracking service in the host app.
- **Importing a third-party library when a proprietary package already wraps that capability.**
- **Creating "utils" or "helpers" in the host app** for logic that belongs in an existing proprietary package.
- **Skipping the package query** because "it's a small change." Small changes compound into architectural drift.
- **Reading YAML files directly** instead of using the CLI tool.
- **Forking an external package** without explicit user approval and documented justification.
- **Treating a local package as immutable.** Local packages exist to be changed — do not create workarounds in the host app to avoid touching a local package.

## Enforcement

- **Planning phase:** TODO must include the Package-First Assessment with query output.
- **Code review:** New files in `app/Services/`, `app/Helpers/`, `lib/utils/` trigger a package-first review.
- **Delivery gate:** Decision Adherence Gate verifies the assessment was completed and followed.

---
**Authority:** PACED Core Architecture
**Companion:** `paced.core.ecosystem-reuse` (Ecosystem Reuse & Abstraction Boundary Mandate)
