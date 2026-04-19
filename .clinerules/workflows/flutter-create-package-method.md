---
name: flutter-create-package-method
description: "Create/refactor Flutter packages under packages/ with canonical README, proper exports, and checklist consolidation."
---

# Workflow: Create or Refactor Flutter Package/Library

## Purpose
Ensure Flutter packages follow the proprietary package-first architecture with clear API boundaries, canonical documentation, and checklist consolidation.

## Steps

### Step 0: Package-First Gate
Read the proprietary packages checklist at `delphi-ai/config/ecosystem_packages.yaml & foundation_documentation/local_packages.yaml` and confirm no existing package already covers this capability. If one does, extend it instead. Record the Package-First Assessment in the TODO. See `paced.core.package-first`.

### Step 1: Classify Package Category
- `core`: Foundation utilities (networking, auth, storage, logging).
- `feature`: Feature-specific reusable logic extracted from screens/domains.
- `shared`: Cross-feature contracts, models, and UI components.
- `infra`: Infrastructure adapters (APIs, databases, device services).

### Step 2: Create Package Structure
- Create `packages/<package_name>/` with standard Flutter package layout.
- Add `pubspec.yaml` with name, description, and dependencies.
- Create `lib/<package_name>.dart` as the barrel export file.
- Use `src/` for internal implementation.

### Step 3: Define Public API
- Export all public classes, functions, and types via the barrel file.
- Do not export internal implementation details.

### Step 4: Implement Package Logic
- Keep all logic within `packages/<package_name>/lib/`.
- Do not reference host app code from within the package.
- Use dependency injection for host-specific concerns.

### Step 5: Add Tests
- Create `packages/<package_name>/test/` with unit tests for public API.
- Tests must run independently of the host app.

### Step 6: Declare as Dependency
- Add path dependency in root `pubspec.yaml`.
- Run `flutter pub get` to validate resolution.

### Step 7: Create Canonical README
- Copy template from `delphi-ai/templates/package_readme_template.md`.
- Fill all sections: Purpose, Public API, Usage, Extending, Dependencies.
- README must be faithful to implemented code.

### Step 8: Run Validation
- `flutter analyze` passes with no errors in the package.
- Package tests pass.
- Host app builds successfully with the new dependency.

### Step 9: Consolidate in Proprietary Packages Checklist
- Run `bash delphi-ai/tools/verify_package_registry.sh --project-root <path>`.
- Verify the new package appears as `[x]` in `delphi-ai/config/ecosystem_packages.yaml & foundation_documentation/local_packages.yaml`.
- If ecosystem-wide package, complete publication steps before consolidation.
- This step is mandatory for both local and ecosystem packages.

## Validation
- Package exists under `packages/<package_name>/` with valid `pubspec.yaml`.
- Barrel export file exists at `lib/<package_name>.dart`.
- No references to host app `lib/` code from within the package.
- Package declared as path dependency in root `pubspec.yaml`.
- Package root contains `README.md` following canonical template.
- `flutter analyze` passes.
- Package tests pass.
- Host app builds successfully.
- Package appears as `[x]` in `delphi-ai/config/ecosystem_packages.yaml & foundation_documentation/local_packages.yaml` checklist.
