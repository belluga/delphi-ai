---
name: github-main-promotion-orchestrator
description: Manual-only workflow for promoting Laravel, Flutter, and Docker from `stage` to `main` with an explicit independent approval gate, strict pre/post-merge CI requirements, web-app follow-through after Flutter promotion, and final Docker production-lane completion. Use only when the user explicitly asks to promote to `main`.
---

# GitHub Main Promotion Orchestrator

## Scope
Use this skill only when the user explicitly requests promotion from `stage` to `main`. Never infer `main` approval from a prior `dev`/`stage` promotion request, a generic "continue", or a stage-only instruction.

## Relationship To Stage Promotion
- Treat `github-stage-promotion-orchestrator` as the upstream lane companion for this skill.
- Reuse its lane vocabulary, evidence model, blocker classification, and recovery patterns when diagnosing promotion issues that originated before `main`.
- Assume the pertinent code has already been promoted through `dev` and `stage`, or make that absence explicit as a blocker before continuing.
- Never inherit `main` authorization from the stage skill. Knowledge and recovery reuse are allowed; approval reuse is forbidden.

## Hard Rules
- Manual-only. Do not use unless the user explicitly requests promotion to `main`.
- `main` approval must be explicit and independent in the current conversation. It cannot be implied by prior `stage` approval.
- Accept only green checks. No warnings-as-success shortcuts.
- Required promotion gates with `flaky` status are not green. Pass-after-retry does not qualify as success.
- Review Copilot comments even when CI is green. If a comment is pertinent, treat it as blocking until resolved or explicitly rejected with technical rationale.
- Every blocking review finding must pass a scrutiny gate before code changes are chosen: classify it as a real defect, an intentional/by-design behavior, an upstream-lane drift issue, or non-actionable noise. A bot finding is evidence to inspect, not authority to patch blindly.
- When a blocking finding is ambiguous, architectural, cross-module, or otherwise high-blast-radius, require an independent no-context critique via `wf-docker-independent-critique-method` before accepting or rejecting the finding.
- Always pursue root cause. Never patch only to satisfy CI.
- If a `stage -> main` finding requires product-code changes, return to the authoritative source branch and replay the normal promotion chain. For Flutter/Laravel this means the originating feature branch, then `feature -> dev -> stage`, and only after that may `stage -> main` resume. Never patch directly on `stage` and never create an ad hoc `dev`-derived blocker branch just to unblock `main`.
- Keep commits and PRs scoped by repository. Do not mix unrelated repositories or concerns.
- Shared-lane validation must rely on canonical product APIs/surfaces; test-only backend endpoints are forbidden.
- When Flutter participates in the main promotion, `web-app` follow-through is part of the gate. Do not treat Flutter `main` as complete until the relevant downstream `web-app` PR/run path is green.
- Docker `stage -> main` is always last. Never promote Docker to `main` before every pertinent application repo is merged to `main` and its required post-merge checks are green.

## Classification
Classify the request before acting:
1. Laravel-only `stage -> main`
2. Flutter-only `stage -> main`
3. Laravel + Flutter `stage -> main`
4. Docker finalization after the pertinent app repos are complete

## Common Preconditions
- Confirm the target repo(s), source branch `stage`, and destination branch `main`.
- Confirm the user has explicitly approved promotion to `main`.
- Run the deterministic main-promotion preflight before opening the first PR in the lane:
  - `bash delphi-ai/tools/github_main_promotion_preflight.sh --scenario <docker-only|flutter-only|laravel-only|flutter-laravel> --docker-repo <owner/name> [--flutter-repo <owner/name>] [--laravel-repo <owner/name>] [--web-repo <owner/name>]`
  - Treat any `Overall outcome: no-go` result as a hard stop. Follow the emitted `resolution_prompt` before creating or reopening promotion PRs.
  - The preflight validates: stage health per repo (contains dev tip, green push runs), promotable diff beyond main, and Docker submodule alignment.
- Run `git status --short` in each touched repo for evidence collection.
- Check open PRs before creating new ones.
- For every promotion PR to `main`, include `- Expected SHA: <40-char-sha>` in the body if the repo enforces it.
- Monitor PR checks and post-merge runs; do not assume merge success means the lane is healthy.

## Preferred Deterministic Helpers
- **Preflight (before first PR):** Use `bash delphi-ai/tools/github_main_promotion_preflight.sh --scenario <scenario> --docker-repo <owner/name> [--flutter-repo <owner/name>] [--laravel-repo <owner/name>] [--web-repo <owner/name>]` as the first gate. The helper must return `Overall outcome: go` before the lane opens its first PR. Treat it as deterministic `GO|NO-GO` lane-health gating that implements TEACH at runtime: objective remote-repo checks trigger it, exit code `2` enforces the stop, `context` carries per-repo evidence, and `resolution_prompt` is the exact next-step guidance to follow before retrying.
- **Snapshot (evidence collection):** Use `bash delphi-ai/tools/github_stage_promotion_snapshot.sh [--repo <owner/name>] [--pr <number>] [--branch <name>]` to capture current local status, candidate PR, and check snapshot before promotion decisions. Treat as evidence collection only; main-promotion gating, comment triage, and merge decisions remain manual in this skill.
- **Completion guard (after all merges):** Before claiming the lane is finished, use `bash delphi-ai/tools/github_promotion_completion_guard.sh --lane main --scenario <docker-only|flutter-only|laravel-only|flutter-laravel> --docker-repo <owner/name> [--flutter-repo <owner/name>] [--laravel-repo <owner/name>] [--web-repo <owner/name>] [--web-pr <number>]` and require `Overall outcome: go`. Treat as deterministic end-of-lane TEACH enforcement for Docker finalization and Flutter web follow-through.

## Finding Scrutiny Gate
For any blocking PR/review finding, perform this gate before deciding to patch:
1. Freeze the evidence: exact finding text, affected repo/branch/PR, relevant diff, and the intended design/behavior.
2. Classify the finding as `confirmed defect | by-design intent | upstream-lane drift | non-actionable`.
3. If the classification is not obviously objective, or the fix would touch architecture/ownership/flow decisions, run `wf-docker-independent-critique-method` with a bounded package before implementation.
4. Record the resolution as `integrate | challenge with rationale | defer/block as upstream`.
5. If implementation is required, return to the authoritative source branch before replaying promotion:
   - Flutter/Laravel: fix on the originating feature branch, replay `feature -> dev -> stage`, then return to the pending `stage -> main` promotion.
   - Docker-specific blockers: fix on the authoritative Docker source branch/lane, replay `-> dev -> stage`, then reopen `stage -> main`.
6. Never patch directly on `stage` or `main` just because the finding appeared there, unless that branch is already the authoritative source lane for the scenario.

## Repo Promotion Rules

### Laravel and Flutter
- Promote only the repos that are pertinent to the delivered change set.
- If both repos contain the released behavior, promote both.
- For each pertinent repo:
  1. Open PR `stage -> main`.
  2. Wait for all PR checks.
  3. Review Copilot comments.
  4. Merge only on full green.
  5. Wait for post-merge `main` runs to finish green.

### Flutter Web Follow-through
- If Flutter is part of the main promotion:
  - inspect the post-merge `main` run in `flutter-app`
  - identify the downstream `web-app` publish/PR/update path triggered by that run
  - wait until the relevant `web-app` pre/post-merge path is green
- Do not proceed to Docker `stage -> main` while the required `web-app` follow-through is still pending, failed, or ambiguous.
- Do not claim main-lane completion until the completion guard confirms the required `web-app` evidence and Docker finalization together.

### Docker Finalization
- Only after every pertinent application repo is green on `main`, and the required `web-app` path is green when Flutter participated:
  1. Open PR `stage -> main` in `belluga_now_docker`.
  2. Wait for all PR checks.
  3. Review Copilot comments.
  4. Merge only on full green.
  5. Wait for post-merge `main` runs to finish green, including production-lane jobs.

## Failure Handling
If any run fails:
1. Identify the exact failing job and log.
2. Determine whether the failure is product, test, CI, or environment.
3. Evaluate Copilot comments in the same cycle.
4. Attempt local reproduction in a materially similar setup when the failure is product-facing and a trustworthy local path exists.
5. If the local path is blocked by temporary harness/environment issues, classify it as invalid local evidence rather than a product failure.
6. Fix the root cause.
7. Re-run targeted local validation when the local path is valid, or rely on the authoritative remote failure plus the closest valid local equivalent when it is not.
8. Push only after confidence is high in the classified root cause.

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
- which pertinent repos were promoted to `main`
- PR numbers for each `stage -> main`
- final SHAs in `main`
- post-merge run IDs
- `web-app` downstream evidence when Flutter participated
- whether Docker production-lane completion finished green
- completion-guard outcome and the exact command used
- any residual blocker requiring user action
