# Foundation Docs Sync (Model Decision)

## Rule

If a task touches routes, screens, repositories, or domain models:

### Documentation Updates
- Update `foundation_documentation/modules/` and `foundation_documentation/screens/` to reflect new flows/routes and UI behaviors
- Sync DTO/mock payloads with `foundation_documentation/screens/prototype_data.md` and related roadmap entries
- Align domain vocabulary with `foundation_documentation/domain_entities_sections/*` and refresh summaries when fields change
- Update `foundation_documentation/system_roadmap.md`, backlog, and submodule summaries with new API/contract work
- When API payload shape conventions change (especially `PATCH` semantics), record the canonical rule in `foundation_documentation/endpoints_mvp_contracts.md` conventions and in the affected module contract sections

### Team Notification
- Notify downstream teams by recording roadmap deltas before code merges

### Exception (Maintenance/Regression Fix Lane)
If restoring previously documented behavior and existing docs already match intended behavior:
- Documentation updates NOT required
- Record evidence in ephemeral TODO
- If docs are missing or incorrect, use tactical TODO and update docs first

## Rationale

Foundation docs are the contract source for all stacks. Keeping them synchronized with route/screen/repo/domain changes prevents drift and preserves traceability.

## Enforcement

- Trigger this rule whenever route/screen/repo/domain work is requested
- Block merges lacking corresponding foundation doc updates or roadmap/submodule summary notes

## Notes

Apply stack-specific rules (Flutter/Laravel glob rules) alongside this sync rule to ensure code and documentation stay in lockstep.

Also apply the TODO-Driven Execution Rule so tactical TODOs define scope and decisions before implementation begins.
