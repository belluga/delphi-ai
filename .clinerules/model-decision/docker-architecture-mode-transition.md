# Docker Architecture Mode Transition (Model Decision)

## Rule

If adjusting architecture modes or related governance (Foundational/Operational/Expansion):

### Requirements
- Run the Architecture Mode Transition Workflow
- Update persona roadmaps and policies per the workflow before declaring the new mode

## Rationale

Mode changes alter compatibility and governance rules; the workflow ensures coordinated updates across personas and docs.

## Enforcement

- Trigger this rule before modifying mode-related documents/policies
- Block changes without roadmap/persona updates as prescribed in the workflow

## Notes

Coordinate with CTO/Tech Lead persona to ratify mode changes and communicate downstream impacts.

## Workflow Reference

See: `.clinerules/workflows/docker-architecture-mode-transition.md`