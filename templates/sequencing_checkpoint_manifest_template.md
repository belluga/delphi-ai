# Template: Sequencing Checkpoint Manifest

Use this file as a starting point for:

`foundation_documentation/artifacts/checkpoints/<short-slug>-<YYYY-MM-DD>.md`

This artifact belongs to the downstream project's `foundation_documentation/artifacts/checkpoints/` tree. It is a recoverability and continuity record, not a tactical TODO, approval gate, or delivery authority.

## Artifact Identity
- **Artifact type:** `sequencing_checkpoint_manifest`
- **Checkpoint status:** `<todo_validated_checkpoint|package_ready_checkpoint|superseded_checkpoint>`
- **Created:** `<YYYY-MM-DD>`
- **Governing workflow / skill:** `delphi-ai/workflows/docker/todo-sequencing-method.md`
- **Authority boundary:** governing TODOs remain authoritative; this manifest only records the green checkpoint state.
- **Non-authoritative sequencing note:** if the recorded checkpoint gate was only a prefix gate, keep TODO/package state provisional here until replay plus the authoritative broad local gate later pass.
- **Stage-full-derived prefix note:** if the recorded checkpoint gate was a `stage-full`-derived prefix, record the exact pre-browser cutoff and explicitly note that local-public web build plus readonly/mutation browser proof were deferred.

## Completed TODO Snapshot
| Order | Governing TODO | Included In Checkpoint | Delivery Stage After Checkpoint | Next Exact Step |
| --- | --- | --- | --- | --- |
| `<1>` | `foundation_documentation/todos/active/<lane>/<todo>.md` | `<yes|no>` | `<Local-Implemented|other>` | `<next action>` |

## Repository Checkpoint SHAs
Fill this after commits are created and pushed.

| Repository | Branch | Commit SHA | Push Target | Included | Notes |
| --- | --- | --- | --- | --- | --- |
| `<docker-root>` | `<sequence/<slug>>` | `<sha>` | `<origin/branch>` | `<yes|no>` | `<notes>` |
| `<flutter-app>` | `<sequence/<slug>>` | `<sha>` | `<origin/branch>` | `<yes|no>` | `<notes>` |
| `<laravel-app>` | `<sequence/<slug>>` | `<sha>` | `<origin/branch>` | `<yes|no>` | `<notes>` |

## Evidence Summary
| Area | Evidence | Status |
| --- | --- | --- |
| `current TODO guards` | `<commands and outcomes>` | `<passed|blocked|n/a>` |
| `recorded checkpoint gate` | `<command and outcome>` | `<passed|blocked|n/a>` |
| `later authoritative broad local gate` | `<command and outcome or deferred rationale>` | `<passed|blocked|deferred|n/a>` |
| `runtime/browser/device freshness` | `<commands and outcomes>` | `<passed|blocked|n/a>` |
| `user validation state` | `<requested|pending|passed|changes_requested|n/a>` | `<passed|blocked|n/a>` |

## Exclusions / Dirty Surfaces
List intentionally uncommitted surfaces so the checkpoint does not imply they were saved.

| Path / Repository | Reason Excluded | Follow-up |
| --- | --- | --- |
| `<path>` | `<generated artifact|local config|unrelated dirty state>` | `<leave dirty|clean later|promote separately>` |

## Branch Lifecycle Decision
- **Current sequencing branch:** `<sequence/<slug>>`
- **Next exact step:** `<start next TODO|request user validation|replay to canonical branch|supersede>`
- **Same-branch continuation allowed:** `<yes|no>`
- **Why:** `<same approved plan continues|new plan or replay required>`

## Notes
- Do not use this manifest to manufacture delivery truth. It records only the checkpoint git state and the evidence that already existed when the checkpoint was created.
- Never collapse a non-authoritative checkpoint prefix into a `stage-full`, `CI-Equivalent`, web-build-complete, readonly-complete, mutation-complete, or authoritative runtime-freshness claim.
