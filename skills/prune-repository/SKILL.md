---
name: prune-repository
description: "Safely prune repositories before the next implementation cycle by auditing branches, worktrees, stale local residue, and rebaseline readiness while routing artifact deletion to `prune-artifacts`."
---

# Prune Repository

## Purpose
Prepare implementation repositories for the next work cycle without hiding user work, deleting unresolved branches, or mixing Git hygiene with artifact cleanup.

This skill is the repository-level prune router. Branch/rebaseline mechanics delegate to `branch-rebaseline-preflight`; artifact deletion delegates to `prune-artifacts`.

## Trigger
- Use this skill when the user asks to prune a repository, clean the environment for the next implementation, prepare for a fresh branch, audit stale branches/worktrees, or rebaseline to latest `dev`.
- Use this skill before `prune-artifacts` when a broader environment prune includes both repository hygiene and artifact cleanup.
- Do not use this skill as permission to delete `artifacts/**`; route that portion to `prune-artifacts`.

## Boundaries
- Do not force-delete local branches, reset unmerged work, or delete remote branches automatically.
- Do not perform manual gitlink surgery to make a root repository appear clean. Gitlink movement belongs only to the authorized promotion/pipeline flow.
- Do not widen scope to generated repos, deployment mirrors, documentation authority repositories, or artifact-only repositories unless the user explicitly includes them.
- Do not delete source files, documentation authorities, environment files, secrets, dependency lockfiles, generated delivery artifacts, or local user changes as "repository prune".
- Respect dirty worktrees. If tracked or untracked files may be user work, report them and stop before destructive cleanup.
- Keep artifact cleanup separate. If repository prune discovers `artifacts/tmp` or large artifact folders, report them as handoff candidates for `prune-artifacts`.

## Default Scope
- Include implementation repositories the user is actively preparing for the next coding cycle.
- In PACED Docker ecosystems, default include set is the Docker/orchestration root plus implementation source repositories named by the project, commonly `flutter-app` and `laravel-app`.
- Exclude by default: derived artifact repositories, generated web deploy mirrors, documentation authority repositories, and foundation documentation unless explicitly requested.

## Workflow
1. **Confirm repository set**
   - List the repositories in scope and why each is included.
   - Mark excluded adjacent repos so omission is explicit.
2. **Record current state**
   - Run `git status --short --branch` in each scoped repo.
   - Record current branch, dirty tracked files, untracked files, configured submodules, and worktree list.
3. **Run branch/rebaseline preflight**
   - Use `branch-rebaseline-preflight` for branch classification, safe local branch cleanup, remote cleanup candidate reporting, and optional `dev` rebaseline.
   - Preferred helper:
     - `bash delphi-ai/tools/branch_rebaseline_preflight.sh`
     - `bash delphi-ai/tools/branch_rebaseline_preflight.sh --apply-safe-local-cleanup`
     - `bash delphi-ai/tools/branch_rebaseline_preflight.sh --apply-safe-local-cleanup --rebaseline-dev`
   - Treat exit code `2` as a decision checkpoint, not as permission to force anything.
4. **Audit worktrees**
   - Run `git worktree list --porcelain`.
   - Run `git worktree prune --dry-run --verbose` when supported.
   - Apply `git worktree prune --verbose` only when the dry-run shows stale administrative records and no active worker checkout, mounted bind path, or open orchestration lane depends on them.
5. **Classify local residue**
   - Report caches, temporary directories, generated scratch output, and untracked local files separately.
   - Delete only clearly disposable tool-created residue that is not source, documentation, environment state, artifact evidence, or user work.
   - If in doubt, report the residue instead of deleting it.
6. **Route artifact handoff**
   - If large `artifacts/**`, `tmp/**`, review packets, or checkpoint folders are found, create a handoff note for `prune-artifacts`.
   - Include repository state, active branches/TODOs, and any references that might protect those artifacts from deletion.
7. **Report repository readiness**
   - Summarize branch blockers, patch-equivalent false positives, safe local cleanup applied, remote cleanup candidates, worktree prune result, local residue handled, and artifact handoff items.

## Suggested Checks
- Repository state:
  - `git status --short --branch`
  - `git remote -v`
  - `git submodule status --recursive`
- Branch inventory:
  - `git for-each-ref --format='%(refname:short) %(upstream:short)' refs/heads`
  - `git for-each-ref --format='%(refname:short)' refs/remotes/origin`
- Worktree inventory:
  - `git worktree list --porcelain`
  - `git worktree prune --dry-run --verbose`
- Untracked/residue inventory:
  - `git status --short --untracked-files=all`
  - `find . -maxdepth 3 -type d \( -name '.pytest_cache' -o -name '.dart_tool' -o -name 'coverage' -o -name 'tmp' -o -name 'artifacts' \) -print`

## Required Output
- Repositories included/excluded.
- Current branch and workspace cleanliness per repo.
- Branch/rebaseline result from `branch-rebaseline-preflight`.
- Worktree prune dry-run and applied result, if any.
- Local residue deleted or retained with rationale.
- Artifact handoff candidates for `prune-artifacts`.
- Final readiness status for the next implementation cycle.

## Done Criteria
- No unmerged or user-owned work is hidden by cleanup.
- Safe local branch cleanup and optional `dev` rebaseline follow `branch-rebaseline-preflight`.
- Stale worktree records are pruned only after dry-run proof.
- Artifact deletion is not performed here and is routed to `prune-artifacts`.
- The user receives a clear repository-readiness report with remaining blockers.
