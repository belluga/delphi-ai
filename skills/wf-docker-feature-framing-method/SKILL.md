---
name: wf-docker-feature-framing-method
description: "Workflow: MUST use whenever a request is still feature-shaped or ambiguous enough that Delphi needs to decompose it into story-sized execution slices before opening or refining a tactical TODO."
---

# Method: Feature Framing + Story Decomposition

## Purpose
Create a bounded pre-TODO framing pass so medium/big work that is not already one bounded slice, and materially ambiguous work of any size, are decomposed into story-sized execution slices without turning the tactical TODO into a discovery document.

## Triggers
- The request is `medium|big` and not already one clearly bounded execution slice.
- The request is materially ambiguous or still feature-shaped rather than one clearly bounded execution slice.
- The user explicitly asks for story decomposition or feature framing before TODO execution.

## Inputs
- User request / feature idea.
- Relevant canonical docs (`project_constitution.md`, `system_roadmap.md`, module docs) and any directly relevant code/doc/test evidence.

## Procedure
1. Decide whether `direct-to-todo` is acceptable or whether a feature brief is required.
2. If required, create/update `foundation_documentation/artifacts/feature-briefs/<short_slug>.md` using `templates/feature_brief_template.md`, keeping it lightweight.
3. Decompose the work into candidate story slices with module ownership, acceptance boundaries, and candidate validation signals.
4. Recommend the current story slice that should become the tactical TODO now.
5. Hand off the story slice into the tactical TODO with the feature brief path or explicit direct-to-TODO rationale.

## Outputs
- Decision: `direct-to-todo` or `feature-brief-required`.
- Feature brief when required.
- Identified current story slice for TODO execution.
