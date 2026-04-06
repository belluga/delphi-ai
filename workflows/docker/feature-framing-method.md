---
description: Frame feature-shaped work before tactical TODO execution so medium/big or ambiguous requests are decomposed into story-sized execution slices without creating a competing source of truth.
---

# Method: Feature Framing + Story Decomposition

## Purpose
Create a bounded pre-TODO framing pass when the request is still idea-shaped, feature-shaped, or ambiguous enough that jumping straight into a tactical TODO would turn the TODO into a discovery document.

This method is intentionally auxiliary and non-authoritative. It helps Delphi decide whether work may go direct to a tactical TODO or first needs a `Feature Brief / Story Decomposition` artifact under `foundation_documentation/artifacts/feature-briefs/`.
Keep the brief lightweight. Capture only what is needed to pick the current story slice and keep ambiguity out of the tactical TODO.

## Triggers
- The requested work is `medium|big` and not already one clearly bounded execution slice.
- The requested work is materially ambiguous or still phrased as a feature/initiative rather than a clearly bounded execution slice.
- The current request would otherwise force a tactical TODO to absorb multiple independent stories or unresolved framing questions.
- The user explicitly asks to break an idea/feature into stories or TODO candidates.

## Inputs
- User request / feature idea.
- Relevant canonical docs (`project_constitution.md`, `system_roadmap.md`, module docs) and any directly relevant code/doc/test evidence.
- Existing active TODOs when the new work may be an extension, split, or follow-up rather than a brand-new slice.

## Procedure
1. **Decide whether direct-to-TODO is allowed**
   - `Direct-to-TODO` is allowed only when all of the following are true:
     - the request already represents one primary delivery story/value slice;
     - one primary module can own the work;
     - ambiguity is low enough that TODO refinement will not become broad discovery;
     - the expected work can stay within one main approval/review/promotion cycle;
     - roadmap/constitution impact is either absent or already explicit enough to avoid a separate framing pass.
   - Otherwise, create or update a `Feature Brief / Story Decomposition` artifact first.
2. **Create or update the feature brief**
   - Use `templates/feature_brief_template.md`.
   - Store the artifact under `foundation_documentation/artifacts/feature-briefs/<short_slug>.md`.
   - Record only the minimum needed:
     - problem / desired outcome;
     - constraints / non-goals;
     - canonical touchpoints;
     - evidence / references;
     - ambiguities that still matter;
     - story decomposition.
3. **Decompose into candidate stories**
   - Each story must identify:
     - user/value slice;
     - primary module;
     - secondary module involvement, if any;
     - acceptance boundary;
     - candidate validation signal;
     - whether it should become a tactical TODO now, later, or after further split.
   - Do not collapse unrelated stories just because they came from the same user request.
4. **Choose the current execution slice**
   - Recommend the current story slice that should become the tactical TODO now.
   - The recommended slice should normally be one primary story.
   - One primary module and one main approval/review/promotion cycle are strong default sizing heuristics, not automatic split triggers when the slice is still one cohesive behavior.
5. **Hand off to the tactical TODO**
   - If a tactical TODO is needed now, create/update it with:
     - the feature brief path (or explicit `direct-to-todo` rationale);
     - the primary story ID;
     - the current slice rationale.
   - The tactical TODO remains the implementation contract; this brief does not authorize implementation.

## Outputs
- Decision: `direct-to-todo` or `feature-brief-required`.
- If required, a populated feature brief under `foundation_documentation/artifacts/feature-briefs/`.
- One recommended current story slice for tactical TODO execution.

## Validation
- `medium|big`, feature-shaped, or materially ambiguous work does not jump straight into a tactical TODO without either:
  - a feature brief, or
  - an explicit direct-to-TODO rationale that explains why the work is already one bounded slice.
- The feature brief does not replace module docs, constitution, roadmap, or the tactical TODO.
- The recommended current slice is bounded enough that the tactical TODO can remain a coherent execution contract rather than a backlog surrogate.
