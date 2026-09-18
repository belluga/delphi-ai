# Flutter Screen Workflow (Glob Rule)

**Applies to:** `flutter-app/lib/presentation/**/screens/**`

## Rule

Whenever a file under screens directory is active or modified, run the Screen Workflow:

### Requirements
- Keep screens pure UI. Controllers own local interaction state and orchestration; canonical entity/list streams remain repository-owned and are exposed through controller delegation without copying
- Ensure ModuleScope/GetIt registrations and documentation updates (`screens/*.md`) accompany the change
- Confirm DTO projections and mock data are current before merging

## Rationale

Screens are the primary consumer of DTO projections. Enforcing the Screen Workflow guarantees consistency with architecture rules and documentation-first mandates.

## Enforcement

- [ ] Use the Screen Workflow checklist before completing edits
- [ ] Block PRs that touch these paths without following the workflow steps

## Workflow Reference

See: `.clinerules/workflows/create-screen.md`

## Quick Checklist

- [ ] Screen is pure UI (no business logic)
- [ ] Controller owns only local state/orchestration and delegates canonical repository streams
- [ ] ModuleScope registration complete
- [ ] Documentation updated (`screens/*.md`)
- [ ] DTO projections current
- [ ] Mock data matches DTOs
