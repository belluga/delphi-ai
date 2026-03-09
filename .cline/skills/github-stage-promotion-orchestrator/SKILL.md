---
name: github-stage-promotion-orchestrator
description: Manual-only workflow for promoting Flutter, Laravel, and Docker changes through dev and stage with strict CI gates, Copilot review triage, root-cause debugging, and docker next-version hygiene. Use only when the user explicitly asks to promote branches/repos up to stage or explicitly names this skill.
---

# GitHub Stage Promotion Orchestrator

## Scope
Use this skill only when the user explicitly requests promotion through `dev` and `stage`. Never auto-trigger it from generic CI or commit/push requests.

## Hard Rules
- Manual-only. Do not use unless explicitly requested by the user.
- Promote only up to `stage`. Never continue to `main`.
- Accept only green checks. No warnings-as-success shortcuts.
- Review Copilot comments even when CI is green. If a comment is pertinent, treat it as blocking until resolved or explicitly rejected with technical rationale.
- Always pursue root cause. Never patch only to satisfy CI.
- If a remote test fails, reproduce locally in a materially similar setup before pushing a new attempt.
- Keep commits scoped by repository. Do not mix unrelated repositories or concerns.

## Classification
Classify the promotion request before acting:
1. Docker non-submodule changes only.
2. Docker `bot/next-version` submodule-only promotion.
3. Docker has both non-submodule changes and submodule changes.
4. Flutter or Laravel lane promotion only.

## Common Preconditions
- Confirm target repo(s), source branch, and destination lane.
- Run `git status --short` in each touched repo.
- Check open PRs before creating new ones.
- For every promotion PR to `stage`, include `- Expected SHA: <40-char-sha>` in the body if the repo enforces it.
- Monitor PR checks and post-merge runs; do not assume merge success means the lane is healthy.

## Scenario 1: Docker Changes That Are Not Submodules
Use when `belluga_now_docker` has changes in normal files and no submodule gitlink updates are intended.

Steps:
1. Commit and push the Docker branch.
2. Open PR from the working branch to `dev`.
3. Wait for all checks.
4. Review Copilot comments and fix any pertinent issue.
5. Merge only when all checks are green and comments are resolved.
6. Wait for post-merge `dev` runs to finish green.
7. Open PR `dev -> stage`.
8. Wait for all checks, review comments, merge only on full green.
9. Wait for post-merge `stage` runs, including deploy/smoke jobs.

## Scenario 2: Docker `bot/next-version` With Submodule Changes Only
Use only for submodule gitlink promotion in Docker.

Required branch:
- `bot/next-version`

Rules:
- The branch must contain only submodule gitlink changes.
- It must be based on the latest `origin/dev`.
- If it diverges from `origin/dev` with regular file changes or stale commits, treat it as invalid.
- The repository-dispatch flow may prepare/update `bot/next-version`, but PR creation is manual by policy. Do not expect or restore automatic PR creation for this branch.

Recovery path when invalid:
1. Delete or recreate `bot/next-version` from the latest `origin/dev`.
2. Re-dispatch the promotion callbacks from `flutter-app stage` and/or `laravel-app stage` so the branch is regenerated cleanly.
3. Re-check that the diff from `origin/dev` contains only submodule gitlinks.

Promotion steps:
1. Open PR `bot/next-version -> dev`.
2. Wait for all checks.
3. Review Copilot comments.
4. Merge only on full green.
5. Wait for post-merge `dev` runs to finish green.
6. Open PR `dev -> stage`.
7. Wait for all checks and deploy-related runs.
8. Merge only on full green.
9. Wait for post-merge `stage` runs to finish green.

## Scenario 3: Docker Has Both Normal Changes And Submodule Changes
This must be split in two phases.

Phase A:
- Execute Scenario 1 first for the non-submodule Docker changes.
- Merge to `dev` and wait for post-merge `dev` green.

Phase B:
- Execute Scenario 2 after Phase A is green.
- Ensure `bot/next-version` is recreated from the new latest `origin/dev`.
- Only then promote the gitlink changes.

Never mix these into a single PR to `dev`.

## Scenario 4: Flutter Or Laravel Promotion Only
Use when the change is limited to `flutter-app` or `laravel-app`.

Steps:
1. Promote the feature branch to `dev`.
2. Wait for checks and Copilot review resolution.
3. Merge and wait for post-merge `dev` runs.
4. Promote `dev -> stage`.
5. Wait for checks and comments.
6. Merge and wait for post-merge `stage` runs.
7. Expect the Docker dispatcher to create/update Scenario 2 state automatically.

## Failure Handling
If any run fails:
1. Identify the exact failing job and log.
2. Determine whether the failure is product, test, CI, or environment.
3. Evaluate Copilot comments in the same cycle.
4. Reproduce locally in a materially similar setup.
5. Fix the root cause.
6. Re-run targeted local validation.
7. Push only after local confidence is high.

## Local Reproduction Rule
Before retrying a remote run after failure:
- Reproduce with the closest equivalent local path.
- For Playwright/web failures, use the same test source and same runner topology used by the pipeline.
- For Laravel failures, run the closest safe local CI-equivalent command.
- For Flutter failures, run the targeted suite locally and add/adjust tests if the regression escaped coverage.

## Copilot Review Gate
Treat review comments in this order:
1. Security / auth / tenant isolation
2. Data-loss / regression / broken contract
3. CI/pipeline false-green risk
4. Flaky or weak tests masking real bugs
5. Minor cleanup

A green check does not override a pertinent P1/P2 comment.

## Completion Report
When the promotion finishes, report:
- repo and branch promoted
- PR numbers for `-> dev` and `dev -> stage`
- final SHAs in `stage`
- post-merge run IDs
- whether Docker Scenario 2 was regenerated cleanly
- any residual blocker requiring user action
