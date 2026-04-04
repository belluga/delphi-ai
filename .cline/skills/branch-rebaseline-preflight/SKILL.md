---
name: branch-rebaseline-preflight
description: "Prepare a repository for the next implementation cycle by auditing non-lane branches, cleaning safe local leftovers, reporting merged remote cleanup candidates, and rebaselining to the latest `origin/dev` only when it is safe."
---

# Branch Rebaseline Preflight

## Purpose
Prepare a repository for the next implementation cycle without hiding unmerged work or polluting the local workspace with stale branches.

## Scope Controls
- Run this skill when the user explicitly asks to reset/rebaseline the repository to the latest `dev`, prepare for the next implementation, or audit local/remote branch leftovers before cleanup.
- This skill is a preflight plus safe cleanup flow. It must not destroy unmerged work.
- Remote branch deletion is never automatic here. The skill only reports merged remote cleanup candidates.
- Safe automatic cleanup is limited to local branches that:
  - are outside the promotion lane
  - have no remote/upstream branch
  - are already merged into `origin/dev`
- If any non-lane branch still contains work not merged into `origin/dev`, do not continue with destructive rebaseline/reset behavior until the user decides how to treat it.

## Preferred Deterministic Helper
- Default audit path:
  - `bash delphi-ai/tools/branch_rebaseline_preflight.sh`
- Apply safe local cleanup when desired:
  - `bash delphi-ai/tools/branch_rebaseline_preflight.sh --apply-safe-local-cleanup`
- Rebaseline to `dev` only when you want the helper to switch/update the branch after the audit:
  - `bash delphi-ai/tools/branch_rebaseline_preflight.sh --apply-safe-local-cleanup --rebaseline-dev`
- Exit code `2` means the audit completed but blockers or unsafe conditions remain. Treat that as a decision checkpoint, not as permission to force-reset anything.

## Promotion Lane Classification

### Local branches that belong to the normal lane
- `dev`
- `stage`
- `main`

### Special remote-only lane branch
- `bot/next-version`
  - Treat this as a Docker promotion-lane branch that is normally created or updated remotely by the promotion pipeline.
  - Do not treat a local `bot/next-version` checkout as expected baseline workspace state.
  - If a local `bot/next-version` exists, classify it as a local anomaly/stale branch candidate unless the user is explicitly doing remote branch recovery for the promotion lane.

## Audit Workflow
1. **Refresh branch truth**
   - Run `git fetch --all --prune`.
   - Read `git status --short --branch`.
   - Confirm the authoritative merge target is `origin/dev`.
2. **Classify local branches**
   - List local branches.
   - Mark whether each branch:
     - is in the normal promotion lane
     - has an upstream remote
     - is merged into `origin/dev`
     - is the current branch
3. **Classify remote branches**
   - List remote branches outside the lane.
   - Mark whether each is already merged into `origin/dev`.
4. **Build the branch buckets**
   - `blocking branches`
     - local or remote branches outside the lane that are not merged into `origin/dev`
   - `safe local cleanup`
     - local branches outside the lane, without upstream remote, already merged into `origin/dev`
   - `remote cleanup candidates`
     - remote branches outside the lane, already merged into `origin/dev`
     - local branches with upstream remote that are already merged into `origin/dev` should also point to the matching remote cleanup candidate
   - `local anomalies`
     - local `bot/next-version`
     - any unexpected local branch that looks like stale promotion-lane residue
5. **Apply safe local cleanup**
   - Delete only `safe local cleanup` branches with `git branch -d`.
   - Do not force-delete.
6. **Report remote cleanup candidates**
   - Inform the user which remote branches are already merged and can be deleted remotely if desired.
   - If a corresponding local branch still exists because it has a remote/upstream, keep it unless the user explicitly wants local cleanup after remote deletion.
7. **Rebaseline to `dev`**
   - Proceed only if:
     - no blocking branches remain
     - the current workspace state is safe to move away from
   - Then:
     - switch to `dev`
     - update it to the latest `origin/dev`
     - confirm the repo is ready for a fresh implementation branch

## Suggested Checks
- Local branches:
  - `git for-each-ref --format='%(refname:short) %(upstream:short)' refs/heads`
- Remote branches:
  - `git for-each-ref --format='%(refname:short)' refs/remotes/origin`
- Merge check:
  - `git merge-base --is-ancestor <branch> origin/dev`

## Required Output
- Current branch and workspace cleanliness
- `blocking branches`
- `safe local cleanup` actually performed
- `remote cleanup candidates` reported to the user
- `local anomalies`
- Final `dev` rebaseline result, if executed

## Done Criteria
- Unmerged non-lane work is surfaced before cleanup or reset.
- Safe local-only merged branches are removed when applicable.
- Merged remote branches are reported, not auto-deleted.
- `bot/next-version` is treated as a remote promotion-lane branch, not a normal local branch.
- The repository only lands on updated `dev` when no blocking branch ambiguity remains.
