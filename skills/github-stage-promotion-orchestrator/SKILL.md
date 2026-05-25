---
name: github-stage-promotion-orchestrator
description: "Manual-only umbrella for promoting Flutter, Laravel, and Docker changes to `dev` or through `stage`. Use only when the user explicitly asks for dev/stage promotion or names this skill."
---

# GitHub Stage Promotion Orchestrator

Use this skill as the **manual stage-promotion umbrella**. It routes the lane by state and keeps the non-negotiable gates visible; phase details live in the phase skills below.

## Scope
- Use only when the user explicitly requests promotion to `dev` or through `stage`.
- Never auto-trigger from generic CI, commit, push, or PR requests.
- Never authorize `stage -> main`; use `github-main-promotion-orchestrator` only after explicit user request for `main`.

## Phase Skills
Load the phase skill that matches the current lane state:
- `github-stage-promotion-intake-classification`
- `github-stage-promotion-contract-preflight`
- `github-stage-promotion-source-to-dev`
- `github-stage-promotion-bot-next-version-recovery`
- `github-stage-promotion-dev-to-stage`
- `github-stage-promotion-docker-finalization`
- `github-stage-promotion-failure-review`
- `github-stage-promotion-closeout-report`

## Required State Machine
1. **Intake and classification**: confirm explicit authorization, target scope (`dev-only|through-stage`), source refs, repo set, and scenario.
2. **Contract and preflight**: create the local promotion contract, inspect clean status, run source preflight, and discover existing PRs.
3. **Source to dev**: promote normal Docker/app/source branches into `dev` through guarded PR actions.
4. **Bot next-version recovery**: when Docker gitlink movement is required, ensure the lane-owned `bot/next-version -> dev` path is clean.
5. **Dev to stage**: only for `through-stage`, promote `dev -> stage` through PR.
6. **Docker finalization**: for app `through-stage` lanes, complete Docker gitlink follow-through before the lane is finished.
7. **Failure review**: when CI/Copilot/checks fail or are ambiguous, classify and resolve root cause before retrying.
8. **Closeout report**: run completion evidence and update the governing TODO/promotion status.

## Classification
The intake phase must classify exactly one scenario before mutation:
- `docker-normal`: Docker repo has normal file changes and no intended gitlinks.
- `docker-bot-next-version`: Docker submodule gitlink promotion only.
- `docker-mixed`: Docker has both normal changes and submodule gitlink changes; split normal changes first, bot lane second.
- `flutter-only`, `laravel-only`, or `flutter-laravel`: app source promotion.

`web-app` is never a scenario. It is a generated artifact surface; treat its PRs/checks/comments only as evidence that may require fixing the authoritative source lane.

## Non-Negotiable Gates
- Manual-only. Do not continue beyond the user-authorized scope.
- If scope is `dev-only`, stop once the requested authoritative source repo(s) are healthy on `dev`. Do not continue to `stage`, and do not require Docker finalization unless the user explicitly included Docker gitlink finalization in the same `dev-only` request.
- If scope is `through-stage`, app promotions are not finished until Docker finalization is complete and the stage completion guard returns `Overall outcome: go`.
- Never push directly to `dev`, `stage`, or `main`; lane movement is PR-only.
- Feature/fix/source branches must not introduce Docker submodule gitlinks into `dev`.
- The only accepted gitlink path into `dev` is lane-owned `bot/next-version -> dev`; subsequent `dev -> stage` may carry those gitlinks forward.
- `bot/next-version` may not be promoted directly to `stage`.
- `web-app` PRs must not be manually created, merged, closed, rebased, or patched through this skill.
- Required checks with `flaky`, pending, failed, or warning-as-success status are not green.
- Review Copilot comments even when CI is green. Pertinent P1/P2 comments block until fixed or explicitly rejected with technical rationale.
- Always pursue root cause. Do not patch only to satisfy CI.
- CI behavior changes and promotion-tooling behavior changes require explicit user authorization in the local promotion contract.

## Required Deterministic Helpers
- Create a contract before mutating:
  - `bash delphi-ai/tools/github_promotion_contract_init.sh --output delphi-ai/artifacts/tmp/promotion-contract.json --scope dev-only`
  - `bash delphi-ai/tools/github_promotion_contract_init.sh --output delphi-ai/artifacts/tmp/promotion-contract.json --scope through-stage --gitlink-policy pipeline-only`
- Use guarded wrappers for mutating local/manual actions:
  - `guarded_git_commit.sh`
  - `guarded_git_push.sh`
  - `guarded_pr_create.sh`
  - `guarded_pr_merge.sh`
- Run first-PR source preflight:
  - normal branches: `bash delphi-ai/tools/github_stage_promotion_preflight.sh --source <source-branch> --base origin/dev`
  - bot lane: `bash delphi-ai/tools/github_stage_promotion_preflight.sh --source origin/bot/next-version --base origin/dev --require-diff-shape submodule-only`
- Use `github_stage_promotion_snapshot.sh` for PR/check evidence.
- For `through-stage` closeout, run:
  - `bash delphi-ai/tools/github_promotion_completion_guard.sh --lane stage --scenario <docker-only|flutter-only|laravel-only|flutter-laravel> --docker-repo <owner/name> [...]`

## Finding Scrutiny
Before patching any blocking PR/check/Copilot finding:
1. Freeze the exact finding, repo, branch, PR/check, relevant diff, and intended behavior.
2. Classify as `confirmed defect | by-design intent | upstream-lane drift | non-actionable`.
3. If ambiguous, architectural, cross-module, or high-blast-radius, run `wf-docker-independent-critique-method` with a bounded package.
4. If a fix is needed, patch the authoritative source branch for that scenario, then replay the lane.

## Closeout
- `dev-only`: report source repo(s), PR(s), target SHA(s), check evidence, Copilot disposition, and any follow-up such as Docker finalization that was intentionally out of scope.
- `through-stage`: report source and lane PRs, post-merge run IDs, Docker finalization state, generated `web-app` evidence if relevant, and completion-guard outcome.
- Keep the same governing TODO authoritative through promotion follow-through; do not create a new tactical TODO solely for operational promotion.
