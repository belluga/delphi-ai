---
name: github-stage-promotion-intake-classification
description: "Phase skill for GitHub stage promotion intake: authorization, scope, source refs, repo set, generated web-app boundary, and scenario classification."
---

# GitHub Stage Promotion: Intake and Classification

Use after `github-stage-promotion-orchestrator` is explicitly triggered and before any mutating action.

## Responsibilities
- Confirm the user explicitly authorized `dev-only` or `through-stage`.
- Confirm target repo(s), authoritative source branch/ref, and destination lane.
- Classify one scenario: `docker-normal`, `docker-bot-next-version`, `docker-mixed`, `flutter-only`, `laravel-only`, or `flutter-laravel`.
- Treat `web-app` only as derived artifact evidence; never classify or promote it.
- Decide whether the request is blocked by missing source ref, unclear repo ownership, or ambiguous lane scope.

## Dev-Only Semantics
For `dev-only`, stop after the requested authoritative source repo(s) are healthy on `dev`. Docker finalization is not implicitly required unless the user explicitly includes Docker gitlink finalization in the same request.

## Through-Stage Semantics
For `through-stage`, app source promotion is not complete until Docker gitlink finalization is complete and the stage completion guard returns `Overall outcome: go`.

## Outputs
- Authorized scope: `dev-only|through-stage`.
- Scenario classification and repo/source-ref map.
- Explicit `web-app` handling note when generated artifact evidence appears.
- Blocker or next phase: `github-stage-promotion-contract-preflight`.

## Non-Negotiables
- No implicit promotion scope.
- No `main`.
- No `web-app` mutation.
- No mutation before classification is recorded.
