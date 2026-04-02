---
trigger: model_decision
description: "When changing architecture mode or governance policies."
---


## Rule
If adjusting architecture modes or related governance (Foundational/Operational/Expansion):
- Run the Architecture Mode Transition Workflow (`delphi-ai/workflows/docker/architecture-mode-transition-method.md`).
- Update `system_roadmap.md`, affected canonical module docs, and policies per the workflow before declaring the new mode.

## Rationale
Mode changes alter compatibility and governance rules; the workflow ensures coordinated updates across roadmap, canonical docs, and policies.

## Enforcement
- Trigger this rule before modifying mode-related documents/policies.
- Block changes without the roadmap/documentation updates prescribed in the workflow.

## Notes
Coordinate with CTO/Tech Lead persona to ratify mode changes and communicate downstream impacts.
