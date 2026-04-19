---
name: package-first-verification
description: "Guardrail: MUST invoke before implementing any new feature, endpoint, domain, screen, controller, service, or repository. Verifies packages across three tiers (Local, Ecosystem, External) with tier-appropriate autonomy."
---

# Skill: Package-First Verification

## Purpose
Enforce the package-first architecture by ensuring every implementation begins with a package scan across all three tiers. The checklist at `foundation_documentation/package_registry.md` is auto-generated and organizes packages by tier.

## Package Tier Model

Every dependency falls into one of three tiers that determine how freely the agent can interact with it:

| Tier | Autonomy | How to Identify | Agent Behavior |
| :--- | :--- | :--- | :--- |
| **Local** | Total | In `packages/` dir, path dependency | Treat as modular code. Modify freely. Breaking changes OK — fix callers in the same PR. |
| **Ecosystem** | High | Belluga org repo, VCS/registry dependency | Can modify, but version and evaluate cross-project impact. Prefer additive changes. |
| **External** | Low | pub.dev, Packagist, npm, etc. | Do not modify. Wrap in adapter if behavior needs to change. |

## When to Invoke
- Before planning implementation of any new feature.
- Before creating a new controller, service, repository, utility, or helper.
- Before adding a third-party dependency.
- When a TODO involves creating new files in `app/Services/`, `app/Helpers/`, `lib/utils/`, or similar host-level utility paths.

## Procedure

### 1. Read the Checklist
Open `foundation_documentation/package_registry.md`. Review **all three sections**:
- Ecosystem Packages (Global)
- Local Proprietary Packages — Laravel
- Local Proprietary Packages — Flutter

If the checklist does not exist or is stale, run:
```bash
bash delphi-ai/tools/verify_package_registry.sh --project-root <path>
```

### 2. Interpret the Checkboxes

| Status | Meaning | Agent Behavior |
| :--- | :--- | :--- |
| `[x]` (in use) | Package is a declared dependency | **Use it.** Read its README, understand its API, extend if needed. |
| `[ ]` (available) | Package exists but is NOT a dependency | **Recommend adoption.** Read its README, evaluate if it covers the planned work. |

### 3. Read the README
For each relevant package, read its `README.md` to understand purpose, public API, and integration. The README is the authoritative documentation — not the checklist.

### 4. Evaluate and Decide (Tier-Aware)

| Situation | Local Package | Ecosystem Package | External Package |
| :--- | :--- | :--- | :--- |
| Package covers the need | **Use directly.** Modify API if needed. | **Use directly.** Prefer additive extension. | **Use directly.** Do not modify. |
| Partial match | **Extend.** Breaking changes OK. | **Extend** with additive API. Version bump. | **Wrap** in a local adapter. |
| No match, code is reusable | Create **new local package**. | Propose ecosystem package if cross-project. | N/A |
| Code is host-specific | Implement locally. Document rationale. | N/A | N/A |

### 5. Record the Assessment
Add to the TODO:

```markdown
## Package-First Assessment
- Checklist consulted: Yes
- Relevant packages found:
  - [Local] <name> — <action taken>
  - [Ecosystem] <name> — <action taken>
  - [External] <name> — <action taken>
- READMEs read: <list>
- Decision: Use <package> / Adopt <package> / Extend <package> / New package <name> / Local implementation
- Tier: Local / Ecosystem / External
- Rationale: <brief>
```

### 6. Post-Implementation
If a new proprietary package was created:
- [ ] Package has `README.md` following canonical format (`delphi-ai/templates/package_readme_template.md`)
- [ ] Run `bash delphi-ai/tools/verify_package_registry.sh` to update the checklist
- [ ] Package appears in the correct section (Local or Ecosystem)

## Validation
- Package-First Assessment is present in the TODO with tier classification.
- If a proprietary package was found (used or available), the implementation leverages it.
- No new host-level utility files duplicate proprietary package capabilities.
- Local packages are modified directly when needed — no workarounds in host app to avoid touching them.
- External packages are never forked without explicit user approval.
- Checklist is current (re-run script if packages were added/removed).
