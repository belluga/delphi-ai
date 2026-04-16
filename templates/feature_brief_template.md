# Template: Feature Brief / Story Decomposition

Use this template as a starting point for `foundation_documentation/artifacts/feature-briefs/<short_slug>.md`.

This artifact is a pre-TODO framing surface for work that is still feature-shaped rather than already one bounded execution slice.
It is non-authoritative by itself: it informs the tactical TODO, module updates, and any constitution/roadmap impact, but it does not replace those canonical surfaces.
Keep it lightweight. Record only what is needed to choose the current story slice and avoid pushing discovery pressure into the tactical TODO.

## Artifact Role
- **Why this brief exists now:** `<what is still too broad/ambiguous for a tactical TODO>`
- **What this brief is not:** `<canonical module doc|project constitution|system roadmap|tactical TODO|implementation authority>`

## Source Idea / Request
- `<user request, initiative, or problem statement>`

## Problem / Desired Outcome
- **Problem:** `<what is unsatisfactory today>`
- **Desired outcome:** `<what should become true>`
- **Why now:** `<timing / pressure / dependency>`

## Constraints / Non-Goals
- **Constraints:** `<hard constraints, compatibility, sequence, risk>`
- **Non-goals:** `<what this initiative must not absorb>`

## Canonical Touchpoints
- **Constitution impact:** `<none|possible|yes>` — `<where / why>`
- **Roadmap impact:** `<none|possible|yes>` — `<where / why>`
- **Primary module candidates:** `foundation_documentation/modules/<module>.md`
- **Secondary module candidates:** `foundation_documentation/modules/<module>.md`

## Evidence / References
- `<module/code/doc/test/issue/reference>`

## Ambiguities To Resolve Before TODO
| ID | Ambiguity | Why It Matters | Current Evidence | Handling (`resolve now|carry as TODO assumption|block`) |
| --- | --- | --- | --- | --- |
| `AMB-01` | <ambiguity> | <why it matters> | <evidence> | <handling> |

## Story Decomposition
Treat each row as a candidate delivery slice. A tactical TODO should normally map to one primary story slice, not to the entire table.

| Story ID | Story / User Value | Primary Module | Secondary Modules | Acceptance Boundary | Candidate Validation Signal | Candidate TODO Decision (`create-now|defer|split-further|merge-with-other`) | Dependencies / Blockers | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `ST-01` | <story> | `<module>` | `<none|module list>` | <what must be true for this slice> | <test/flow/evidence> | `<decision>` | <dependency/blocker> | <notes> |

## Retire This Brief When
- `<the active TODO exists and this brief is no longer carrying live framing ambiguity>`
