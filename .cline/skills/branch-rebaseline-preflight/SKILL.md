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
- This skill must not manually edit, stage, or rewrite Docker submodule gitlinks as part of "getting the workspace ready". Gitlink creation, adjustment, or reconciliation belongs only to the promotion-lane workflow.
- In multi-repository ecosystems, restrict the default rebaseline scope to the implementation repositories that the user is actively preparing for the next coding cycle. Do not automatically widen the audit to adjacent generated repos, deployment mirrors, documentation mirrors, or artifact-only repositories unless the user explicitly asks.
- Belluga ecosystem default:
  - include: `belluga_now_docker`, `flutter-app`, `laravel-app`
  - exclude by default: `web-app`, `foundation_documentation`
  - if those excluded surfaces need cleanup or rebaseline, require explicit user instruction for that broader scope.
- Do not treat ancestry-only mismatch as a blocker until you verify whether the branch content is already present in `origin/dev` through cherry-pick/replay or equivalent patch uptake.
- If a branch is not merged by ancestry but its non-merge commit set is patch-equivalent to content already in `origin/dev`, classify it as a `patch-equivalent false positive`, not as a real blocker.
- Safe automatic cleanup is limited to local branches that:
  - are outside the promotion lane
  - have no remote/upstream branch
  - are already present in `origin/dev` by ancestry or validated patch-equivalence
- If any non-lane branch still contains work not present in `origin/dev` after ancestry + patch-equivalence validation, do not continue with destructive rebaseline/reset behavior until the user decides how to treat it.

## Preferred Deterministic Helper
- Default audit path:
  - `bash delphi-ai/tools/branch_rebaseline_preflight.sh`
- Apply safe local cleanup when desired:
  - `bash delphi-ai/tools/branch_rebaseline_preflight.sh --apply-safe-local-cleanup`
- Rebaseline to `dev` only when you want the helper to switch/update the branch after the audit:
  - `bash delphi-ai/tools/branch_rebaseline_preflight.sh --apply-safe-local-cleanup --rebaseline-dev`
- The helper must distinguish:
  - real blockers: content not present in `origin/dev`
  - `patch-equivalent false positives`: ancestry mismatch only, but content already present in `origin/dev`
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
     - is merged into `origin/dev` by ancestry
     - if not merged by ancestry, whether its non-merge commit set is already present in `origin/dev` by patch-equivalence (`git cherry -v origin/dev <branch>`)
     - is the current branch
3. **Classify remote branches**
   - List remote branches outside the lane.
   - Mark whether each is:
     - merged into `origin/dev` by ancestry
     - if not merged by ancestry, already present in `origin/dev` by patch-equivalence
   - Ignore symbolic remote-head aliases such as bare `origin`; they are not actionable branches.
4. **Build the branch buckets**
   - `blocking branches`
     - local or remote branches outside the lane whose content is not present in `origin/dev` after ancestry + patch-equivalence validation
   - `patch-equivalent false positives`
     - local or remote branches outside the lane that are not merged by ancestry but whose content is already present in `origin/dev`
   - `safe local cleanup`
     - local branches outside the lane, without upstream remote, already present in `origin/dev` by ancestry or validated patch-equivalence
   - `remote cleanup candidates`
     - remote branches outside the lane, already present in `origin/dev` by ancestry or validated patch-equivalence
     - local branches with upstream remote that are already present in `origin/dev` should also point to the matching remote cleanup candidate
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
     - the repo does not require manual gitlink adjustment to appear "clean"; if gitlink movement would be needed, stop and defer that work to the promotion-lane workflow instead of editing submodule pointers here
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
- Patch-equivalence check:
  - `git cherry -v origin/dev <branch>`
- Provenance follow-up when ancestry and patch-equivalence disagree:
  - `git log --left-right --cherry-mark --oneline <branch>...origin/dev --no-merges`

## Required Output
- Current branch and workspace cleanliness
- `blocking branches`
- `patch-equivalent false positives`
- `safe local cleanup` actually performed
- `remote cleanup candidates` reported to the user
- `local anomalies`
- Final `dev` rebaseline result, if executed

## Done Criteria
- Unmerged non-lane work is surfaced before cleanup or reset.
- Ancestry-only false positives are not reported as blockers when equivalent content already exists in `origin/dev`.
- Safe local-only merged branches are removed when applicable.
- Merged remote branches are reported, not auto-deleted.
- `bot/next-version` is treated as a remote promotion-lane branch, not a normal local branch.
- Gitlink ownership remains with the promotion lane; this skill never performs manual gitlink surgery as part of rebaseline.
- The repository only lands on updated `dev` when no blocking branch ambiguity remains.
