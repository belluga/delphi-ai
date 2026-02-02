---
name: rule-docker-shared-project-mandate-always-on
description: "Rule: MUST use whenever the scope matches this purpose: On every task:."
---

## Rule
On every task:
- Treat `foundation_documentation/project_mandate.md` as binding; ensure decisions advance its principles and delivery imperatives.
- Load and align with core docs: `foundation_documentation/domain_entities.md`, `foundation_documentation/system_roadmap.md`, submodule summaries, backlog entries, and relevant module/screen docs when the scope touches them.
- Log any missing or stale foundational docs and request updates before proceeding when they are critical to the task.

## Rationale
The mandate and foundational docs define the business intent and delivery roadmap. Keeping them front-and-center prevents architectural drift and ensures cross-team alignment.

## Enforcement
- Reference the mandate and core docs in design/implementation notes.
- Block changes that contradict mandate principles or bypass required documentation updates.

## Notes
Reload mandate/core docs at session start; revisit roadmap and submodule summaries when scope changes or at session end for updates.
