---
description: "Glob-triggered Flutter workflows — controller, domain, repository, route, and screen workflows activated by file path patterns"
globs: ["flutter-app/lib/**"]
alwaysApply: false
---

# Flutter Glob Workflows

These workflows are triggered when editing files matching specific path patterns within the Flutter app.

## Controller Workflow

**Applies to:** `flutter-app/lib/presentation/**/controllers/**`

When working inside controller directories, run the Controller Workflow:

- Controllers own local `StreamValue` state, UI controllers, and orchestration; they expose repository-owned canonical `StreamValue` state by delegation and never accept `BuildContext`.
- Register controllers via ModuleScope/GetIt and document responsibilities.
- Follow the canonical contract in `foundation_documentation/modules/flutter_client_experience_module.md`.

**Workflow Reference:** `delphi-ai/workflows/flutter/create-controller-method.md`

## Domain Workflow

**Applies to:** `flutter-app/lib/domain/**`

When editing domain files, run the Domain Workflow:

- Domain models are the bridge between DTOs and screens.
- Preserve single source of truth and contract traceability.
- Entity must be documented in `domain_entities_sections/*`.

**Workflow Reference:** `delphi-ai/workflows/flutter/create-domain-method.md`

## Repository Workflow

**Applies to:** `flutter-app/lib/infrastructure/repositories/**`

Edits in repository directories must run the Repository Workflow:

- Maintain DTO → Domain mapping discipline; no DTO leakage.
- Keep raw transport payload ownership at DAO/DTO boundary.
- Use typed request DTO/command builders for writes.
- Document pagination/filtering contracts and sync Laravel roadmap entries.

**Workflow Reference:** `delphi-ai/workflows/flutter/create-repository-method.md`

## Route Workflow

**Applies to:** `flutter-app/lib/**/routes/**`

Edits under route directories must follow the Route Workflow:

- Load `foundation_documentation/policies/scope_subscope_governance.md` before defining ownership.
- Register new routes in AutoRoute with guards and ModuleScope wiring.
- Run generated-router contract audit for required non-URL args.
- Regenerate routes via build_runner and capture the stable full-workspace VS Code Problems snapshot; pipeline analyzer jobs remain separate CI evidence.

**Workflow Reference:** `delphi-ai/workflows/flutter/create-route-method.md`

## Screen Workflow

**Applies to:** `flutter-app/lib/presentation/**/screens/**`

When a file under screens directory is active or modified, run the Screen Workflow:

- Keep screens pure UI. Controllers own local interaction state and orchestration; canonical entity/list streams remain repository-owned and are delegated without copying.
- Ensure ModuleScope/GetIt registrations and documentation updates accompany the change.
- Confirm DTO projections and mock data are current.

**Workflow Reference:** `delphi-ai/workflows/flutter/create-screen-method.md`
