---
name: github-stage-promotion-intake-classification
description: "Phase skill for GitHub stage promotion intake: authorization, scope, source refs, repo set, generated web-app boundary, and scenario classification."
---

# GitHub Stage Promotion: Intake and Classification

Use after `github-stage-promotion-orchestrator` is explicitly triggered and before any mutating action.

## Responsibilities
- Confirm the user explicitly authorized `dev-only` or `through-stage`.
- Confirm target repo(s), authoritative source branch/ref, and destination lane.
- When the lane is governed by a version/package TODO, confirm that governing TODO path up front and record the matching repo-authority key (`root|flutter-app|laravel-app|web-app|foundation_documentation`) that preflight will validate.
- Run `python3 delphi-ai/tools/github_stage_promotion_scenario_classifier.py --repo <repo> --base <base-ref> --source <source-ref>` as advisory deterministic evidence.
- Record the primary promotable surface first: `docker`, `flutter`, `laravel`, or `flutter+laravel`.
- For Docker, record the Docker diff shape as the secondary routing fact: `gitlink-only`, `source-only`, or `source+gitlinks`.
- Keep the existing scenario id as a compatibility alias from tool evidence plus explicit user authorization: `docker-normal`, `docker-bot-next-version`, `docker-mixed`, `flutter-only`, `laravel-only`, or `flutter-laravel`.
- Treat `web-app` only as derived artifact evidence; never classify or promote it.
- Decide whether the request is blocked by missing source ref, unclear repo ownership, or ambiguous lane scope.

## Dev-Only Semantics
For `dev-only`, stop after the requested authoritative source repo(s) are healthy on `dev`. Docker finalization is not implicitly required unless the user explicitly includes Docker gitlink finalization in the same request.

## Through-Stage Semantics
For `through-stage`, app source promotion is not complete until Docker gitlink finalization is complete and the stage completion guard returns `Overall outcome: go`.

## Outputs
- Authorized scope: `dev-only|through-stage`.
- Scenario classification, classifier outcome, and repo/source-ref map.
- Governing TODO path + repo-authority key when the promotion is package/version governed.
- Explicit `web-app` handling note when generated artifact evidence appears.
- Blocker or next phase: `github-stage-promotion-contract-preflight`.

## Non-Negotiables
- No implicit promotion scope.
- No `main`.
- No `web-app` mutation.
- No mutation before classification is recorded.
