# Template: Orchestration Checkpoint Manifest

Use this file as a starting point for:

`foundation_documentation/artifacts/checkpoints/<short-slug>-<YYYY-MM-DD>.md`

This artifact belongs to the downstream project's `foundation_documentation/artifacts/checkpoints/` tree. It is a recoverability and continuity record, not a tactical TODO, approval gate, or delivery authority.

## Artifact Identity
- **Artifact type:** `orchestration_checkpoint_manifest`
- **Checkpoint status:** `<wip_checkpoint|validated_local_checkpoint|promotion_ready_checkpoint|superseded_checkpoint>`
- **Created:** `<YYYY-MM-DD>`
- **Governing workflow / skill:** `delphi-ai/workflows/docker/subagent-worktree-reconciliation-method.md`
- **Authority boundary:** governing TODOs and canonical module docs remain authoritative.

## Scope
| ID | Governing TODO | Included in checkpoint | Delivery stage after checkpoint |
| --- | --- | --- | --- |
| `<SR-A>` | `foundation_documentation/todos/active/<lane>/<todo>.md` | `<yes|no>` | `<Pending|Local-Implemented|promotion_lane|completed|n/a>` |

## Repository Checkpoint SHAs
Fill this after commits are created.

| Repository | Branch | Commit SHA | Push target | Included | Notes |
| --- | --- | --- | --- | --- | --- |
| `<docker-root>` | `<branch>` | `<sha>` | `<origin/branch>` | `<yes|no>` | `<notes>` |
| `<flutter-app>` | `<branch>` | `<sha>` | `<origin/branch>` | `<yes|no>` | `<notes>` |
| `<laravel-app>` | `<branch>` | `<sha>` | `<origin/branch>` | `<yes|no>` | `<notes>` |
| `<foundation_documentation>` | `<branch>` | `<sha>` | `<origin/branch>` | `<yes|no>` | `<notes>` |
| `<web-app>` | `<branch>` | `<sha>` | `<origin/branch>` | `<yes|no>` | `<usually no unless explicitly promoting built artifact>` |

## Evidence Summary
| Area | Evidence | Status |
| --- | --- | --- |
| `completion guards` | `<commands and outcomes>` | `<passed|blocked|n/a>` |
| `tests` | `<commands and outcomes>` | `<passed|blocked|n/a>` |
| `runtime/browser/device` | `<commands and outcomes>` | `<passed|blocked|n/a>` |
| `build/publish freshness` | `<commands and outcomes>` | `<passed|blocked|n/a>` |

## Exclusions / Dirty Surfaces
List intentionally uncommitted surfaces so the checkpoint does not imply they were saved.

| Path / Repository | Reason Excluded | Follow-up |
| --- | --- | --- |
| `<path>` | `<generated artifact|local config|stale build|unrelated dirty state>` | `<leave dirty|clean later|promote separately>` |

## Branch Lifecycle Decision
- **Next exact step:** `<promote to dev|promote through stage|supersede|continue same approved wave|discard recovery branch>`
- **Same-branch continuation allowed:** `<yes|no>`
- **Why:** `<same approved wave with next exact step|or new work requires fresh branch>`

## Notes
- Do not use this manifest to manufacture delivery truth. It only records the git state and evidence that already exist in authoritative TODOs, execution plans, and validation outputs.
