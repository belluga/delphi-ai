---
name: github-stage-promotion-source-to-dev
description: "Phase skill for promoting normal Docker, Flutter, or Laravel source branches into `dev` through guarded PR-only lane movement."
---

# GitHub Stage Promotion: Source to Dev

Use when a normal Docker/app/source branch is ready to move into `dev`. Do not use this phase for `bot/next-version` gitlink-only PRs.

## Responsibilities
- Commit and push the source branch only through guarded wrappers when local mutation is required.
- Open or reuse the source `-> dev` PR.
- Wait for all required checks to finish green.
- Review Copilot comments and resolve pertinent findings.
- Merge only through PR, never direct push.
- Wait for post-merge `dev` runs to finish green.

## Scenario Notes
- `docker-normal`: normal Docker files only; no intended gitlinks.
- `flutter-only|laravel-only|flutter-laravel`: promote the authoritative app feature/source branch.
- `docker-mixed`: complete normal Docker changes to `dev` first, then route gitlinks to `github-stage-promotion-bot-next-version-recovery`.

## Dev-Only Close
If scope is `dev-only`, stop after the requested source repo(s) are healthy on `dev` and route to `github-stage-promotion-closeout-report`.

## Non-Negotiables
- No feature/fix/source-branch gitlinks into `dev`.
- No `web-app` PR mutation.
- No merge with failing, pending, flaky, or unresolved review findings.
