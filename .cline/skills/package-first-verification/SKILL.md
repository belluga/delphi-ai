---
name: package-first-verification
description: "Guardrail: MUST invoke before implementing any new feature, endpoint, domain, screen, controller, service, or repository. Verifies that the agent has consulted the Package & Library Registry and assessed whether an existing package covers the planned capability."
---

# Skill: Package-First Verification

## Purpose
Enforce the package-first architecture by ensuring every implementation begins with a registry consultation. This skill prevents architectural drift where agents create parallel implementations instead of extending existing packages.

## When to Invoke
- Before planning implementation of any new feature.
- Before creating a new controller, service, repository, utility, or helper.
- Before adding a third-party dependency.
- When a TODO involves creating new files in `app/Services/`, `app/Helpers/`, `lib/utils/`, or similar host-level utility paths.

## Procedure

### 1. Locate the Registry
Read `foundation_documentation/package_registry.md`. If it does not exist:
- Copy from `delphi-ai/templates/package_registry_template.md`.
- Populate it by scanning the current codebase:
  - Laravel: `ls packages/` and read each package's `composer.json` + `README.md`.
  - Flutter: `ls packages/` or scan `lib/core/` and read `pubspec.yaml` + `README.md`.
- Commit the populated registry before proceeding.

### 2. Search for Overlap
For the planned capability, search the registry tables using keywords. Check:

| Registry Section | What to Look For |
| :--- | :--- |
| Laravel Packages | Package whose Purpose column matches the planned feature |
| Flutter Libraries | Library whose Purpose or Public API column matches |
| Shared Contracts | DTOs or schemas that the feature will consume or produce |

### 3. Evaluate and Decide

| Overlap Level | Action |
| :--- | :--- |
| **Exact match** (package already does this) | Use the existing package. Do not create new code. |
| **Partial match** (70%+ overlap) | Extend the existing package. Add the missing capability there. |
| **Candidate for new package** | Implement as a new package from the start. |
| **Strictly host-specific** | Implement locally. Document why it cannot be a package. |

### 4. Record the Assessment
Add to the TODO or implementation plan:

```markdown
## Package-First Assessment
- Registry consulted: Yes
- Matching packages found: <list or "none">
- Decision: Extend <package> / New package <name> / Local implementation
- Rationale: <explanation>
```

### 5. Post-Implementation Gate
If a new package or library was created:
- [ ] Added to `foundation_documentation/package_registry.md`
- [ ] Package has `README.md` with canonical sections
- [ ] Laravel: registered in `scripts/package_architecture_registry.php` (if exists)
- [ ] Flutter: library exported and public API documented in `pubspec.yaml`

## Validation
- Package-First Assessment is present in the TODO/plan.
- If an existing package was found, the implementation extends it (not duplicates it).
- If a new package was created, it is registered in the registry.
- No new `app/Services/`, `app/Helpers/`, or `lib/utils/` files exist that duplicate package capabilities.

## Output
- Package-First Assessment recorded in the TODO.
- Registry updated if a new package was created.
- Implementation uses existing packages where applicable.
