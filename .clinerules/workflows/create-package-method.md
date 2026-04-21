---
name: "create-package-method"
description: "Create or refactor Flutter packages/libraries under packages/ with canonical README, proper exports, and checklist consolidation."
---

<!-- Generated from `workflows/flutter/create-package-method.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# Workflow: Create or Refactor Flutter Package/Library

## Purpose
Create or refactor a Flutter package or library so it follows the proprietary package-first architecture, has a canonical README, proper public API exports, and is consolidated in the proprietary packages checklist.

## Triggers
- New Flutter package under `packages/`.
- Extraction of reusable logic from `lib/` into a new package.
- Package-First Assessment decision: "Create new package."
- Refactor of existing package to improve contracts or API surface.

## Inputs
- Target package path (`packages/<package_name>`).
- Root `pubspec.yaml` for dependency declaration.
- Canonical README template (`delphi-ai/templates/package_readme_template.md`).

## Procedure

1. Classify package category.
   - `core`: Foundation utilities (networking, auth, storage, logging).
   - `feature`: Feature-specific reusable logic extracted from screens/domains.
   - `shared`: Cross-feature contracts, models, and UI components.
   - `infra`: Infrastructure adapters (APIs, databases, device services).

2. Create package structure.
   - Create `packages/<package_name>/` with standard Flutter package layout.
   - Add `pubspec.yaml` with package name, description, and dependencies.
   - Create `lib/<package_name>.dart` as the barrel export file.

3. Define public API.
   - All public classes, functions, and types must be exported via the barrel file.
   - Internal implementation details must not be exported.
   - Use `src/` for internal implementation, `lib/<package_name>.dart` for public API.

4. Implement package logic.
   - Keep all logic within `packages/<package_name>/lib/`.
   - Do not reference host app code (`lib/` of the root project) from within the package.
   - Use dependency injection for host-specific concerns.

5. Add tests.
   - Create `packages/<package_name>/test/` with unit tests for public API.
   - Ensure tests can run independently of the host app.

6. Declare as dependency in root `pubspec.yaml`.
   - Add path dependency:
     ```yaml
     dependencies:
       <package_name>:
         path: packages/<package_name>
     ```
   - Run `flutter pub get` to validate resolution.

7. Create canonical README.
   - Copy template from `delphi-ai/templates/package_readme_template.md`.
   - Fill all sections: Purpose, Public API, Usage, Extending, Dependencies.
   - README must be faithful to implemented code — no aspirational content.

8. Run validation.
   - `flutter analyze` passes with no errors in the package.
   - Package tests pass.
   - Host app builds successfully with the new dependency.

9. Consolidate in proprietary packages checklist.
   - Run `bash delphi-ai/tools/verify_package_registry.sh --project-root <path>` to regenerate `delphi-ai/config/ecosystem_packages.yaml & foundation_documentation/local_packages.yaml`.
   - Verify the new package appears as `[x]` (in use) in the checklist.
   - If this is an ecosystem-wide package (published for cross-project reuse), complete publication steps before this consolidation.
   - This step is mandatory for both local project packages and ecosystem packages.

## Validation
- Package exists under `packages/<package_name>/` with valid `pubspec.yaml`.
- Barrel export file exists at `lib/<package_name>.dart`.
- No references to host app `lib/` code from within the package.
- Package is declared as path dependency in root `pubspec.yaml`.
- Package root contains `README.md` following canonical template.
- README content matches implemented public API.
- `flutter analyze` passes for the package.
- Package tests pass.
- Host app builds successfully.
- Package appears in `delphi-ai/config/ecosystem_packages.yaml & foundation_documentation/local_packages.yaml` checklist as `[x]`.

## Output
- Flutter package with clear public API boundary.
- Canonical README documenting purpose, API, usage, and extension points.
- Package integrated as dependency in host app.
- Proprietary packages checklist updated.
