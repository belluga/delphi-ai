---
name: github-stage-promotion-orchestrator
description: Manual-only workflow for promoting Flutter, Laravel, and Docker changes through dev and stage with strict CI gates, Copilot review triage, root-cause debugging, and docker next-version hygiene. Use only when the user explicitly asks to promote branches/repos up to stage or explicitly names this skill.
---

# GitHub Stage Promotion Orchestrator

## Scope
Use this skill only when the user explicitly requests promotion through `dev` and `stage`. Never auto-trigger it from generic CI or commit/push requests.

## Relationship To Main Promotion
- `github-main-promotion-orchestrator` may depend on this skill's lane model, evidence standards, and blocker recovery patterns as an upstream prerequisite.
- This skill never authorizes `stage -> main` actions. It defines the state that a later main-promotion workflow may rely on, but approval for `main` must still be obtained independently in that later workflow.

## Hard Rules
- Manual-only. Do not use unless explicitly requested by the user.
- Promote only up to `stage`. Never continue to `main`.
- Accept only green checks. No warnings-as-success shortcuts.
- Required promotion gates with `flaky` status are not green. Pass-after-retry does not qualify as success.
- Review Copilot comments even when CI is green. If a comment is pertinent, treat it as blocking until resolved or explicitly rejected with technical rationale.
- Every blocking review finding must pass a scrutiny gate before code changes are chosen: classify it as a real defect, an intentional/by-design behavior, an upstream-lane drift issue, or non-actionable noise. A bot finding is evidence to inspect, not authority to patch blindly.
- When a blocking finding is ambiguous, architectural, cross-module, or otherwise high-blast-radius, require an independent no-context critique via `wf-docker-independent-critique-method` before accepting or rejecting the finding.
- Always pursue root cause. Never patch only to satisfy CI.
- Do not stack branch/lane hacks on top of unresolved structure. If a finding requires product-code changes, patch the authoritative source branch for that lane instead of inventing an ad hoc base-lane blocker branch. For Flutter/Laravel promotion this means the originating feature branch; Docker `bot/next-version` remains the lane-owned exception described in Scenario 2.
- If a remote test fails, attempt local reproduction in a materially similar setup before pushing a new attempt, but classify local reproduction failures before treating them as product evidence.
- Keep commits scoped by repository. Do not mix unrelated repositories or concerns.
- Shared-lane validation must rely on canonical product APIs/surfaces; test-only backend endpoints are forbidden.
- Docker submodule gitlinks are owned by this promotion lane. If gitlink movement or `bot/next-version` recovery is required, do it here, not in generic rebaseline/cleanup workflows.

## Classification
Classify the promotion request before acting:
1. Docker non-submodule changes only.
2. Docker `bot/next-version` submodule-only promotion.
3. Docker has both non-submodule changes and submodule changes.
4. Flutter or Laravel lane promotion only.

## Common Preconditions
- Confirm target repo(s), source branch, and destination lane.
- Resolve the exact authoritative source branch/ref before running any lane steps. Do not treat the currently checked-out branch as implied authority.
- Run `git status --short` in each touched repo.
- Run the deterministic source-branch preflight before opening the first PR in the lane:
  - Flutter/Laravel feature promotion and Docker normal branch promotion:
    - `bash delphi-ai/tools/github_stage_promotion_preflight.sh --source <source-branch> --base origin/dev`
  - Docker `bot/next-version` submodule-only promotion:
    - `bash delphi-ai/tools/github_stage_promotion_preflight.sh --source origin/bot/next-version --base origin/dev --require-diff-shape submodule-only`
  - Treat any `Overall outcome: no-go` result as a hard stop. Follow the emitted `resolution_prompt` before creating or reopening promotion PRs.
- Check open PRs before creating new ones.
- For every promotion PR to `stage`, include `- Expected SHA: <40-char-sha>` in the body if the repo enforces it.
- Monitor PR checks and post-merge runs; do not assume merge success means the lane is healthy.

## Preferred Deterministic Helper
- Use `bash delphi-ai/tools/github_stage_promotion_preflight.sh --source <source-branch> --base origin/dev [--require-diff-shape submodule-only]` as the first gate for the authoritative source branch. The helper must return `Overall outcome: go` before the lane opens its first PR.
- Use `bash delphi-ai/tools/github_stage_promotion_snapshot.sh [--repo <owner/name>] [--pr <number>] [--branch <name>]` to capture the current local status, candidate PR, and check snapshot before making promotion decisions.
- Before claiming the lane is finished, use `bash delphi-ai/tools/github_promotion_completion_guard.sh --lane stage --scenario <docker-only|flutter-only|laravel-only|flutter-laravel> --docker-repo <owner/name> [--flutter-repo <owner/name>] [--laravel-repo <owner/name>]` and require `Overall outcome: go`.
- Treat the preflight helper as deterministic `GO|NO-GO` branch-shape gating that implements TEACH at runtime: objective git checks trigger it, exit code `2` enforces the stop, `context` carries the branch evidence, and `resolution_prompt` is the exact next-step guidance to follow before retrying. The snapshot helper is evidence collection only; Copilot triage, root-cause analysis, and merge decisions remain in this skill.
- Treat the completion guard as deterministic end-of-lane TEACH enforcement: if Docker finalization, target-branch health, or gitlink alignment is still missing, exit code `2` blocks the completion claim and `resolution_prompt` tells the operator what must still happen.

## Finding Scrutiny Gate
For any blocking PR/review finding, perform this gate before deciding to patch:
1. Freeze the evidence: exact finding text, affected repo/branch/PR, relevant diff, and the intended design/behavior.
2. Classify the finding as `confirmed defect | by-design intent | upstream-lane drift | non-actionable`.
3. If the classification is not obviously objective, or the fix would touch architecture/ownership/flow decisions, run `wf-docker-independent-critique-method` with a bounded package before implementation.
4. Record the resolution as `integrate | challenge with rationale | defer/block as upstream`.
5. If implementation is required, return to the authoritative source branch for that lane before replaying promotion:
   - Flutter/Laravel: fix on the originating feature branch, then replay `feature -> dev -> stage`.
   - Docker normal changes: fix on the working source branch, then replay `branch -> dev -> stage`.
   - Docker submodule-only lane: keep the fix inside the lane-owned `bot/next-version` recovery/promotion path defined in Scenario 2.
6. Never patch directly on `dev` or `stage` just because the finding appeared there, unless that lane is itself the authoritative source branch for the scenario.

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
- The repository-dispatch flow may prepare/update the remote `bot/next-version`, but PR creation is manual by policy. Do not expect or restore automatic PR creation for this branch.
- A local `bot/next-version` checkout is not part of the normal workflow baseline. Treat local copies as stale/anomalous unless the user is explicitly doing remote branch recovery.
- Manual gitlink edits are allowed only inside this scenario's recovery/promotion work, and only to restore the canonical `origin/dev`-based submodule-only branch shape.

Recovery path when invalid:
1. Re-dispatch the promotion callbacks from `flutter-app stage` and/or `laravel-app stage` so the remote branch is regenerated cleanly from the latest `origin/dev`.
2. If the remote branch remains invalid, recreate/reset the remote `bot/next-version` from the latest `origin/dev` through the promotion-lane maintenance path.
3. Re-check that the remote diff from `origin/dev` contains only submodule gitlinks.

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
0. Identify the exact feature branch/ref to promote, run the deterministic preflight on that authoritative source, and stop on any `no-go`.
1. Promote the feature branch to `dev`.
2. Wait for checks and Copilot review resolution.
3. Merge and wait for post-merge `dev` runs.
4. Promote `dev -> stage`.
5. Wait for checks and comments.
6. Merge and wait for post-merge `stage` runs.
7. Wait for the Docker dispatcher/repository-dispatch flow to create or refresh the Docker submodule promotion state, then complete the required Docker lane work.
8. Run the completion guard and require `Overall outcome: go` before claiming the promotion is finished. A Flutter/Laravel-only promotion is not complete while Docker finalization is still pending.

## Failure Handling
If any run fails:
1. Identify the exact failing job and log.
2. Determine whether the failure is product, test, CI, or environment.
3. Evaluate Copilot comments in the same cycle.
4. Attempt local reproduction in a materially similar setup.
5. If the local path is blocked by temporary harness/environment issues, classify it as invalid local evidence rather than a product failure.
6. Fix the root cause.
7. Re-run targeted local validation when the local path is valid, or rely on the authoritative remote failure plus the closest valid local equivalent when it is not.
8. Push only after confidence is high in the classified root cause.

## Local Reproduction Rule
Before retrying a remote run after failure:
- Reproduce with the closest equivalent local path.
- For Playwright/web failures, use the same test source and same runner topology used by the pipeline.
- For Laravel failures, run the closest safe local CI-equivalent command.
- For Flutter failures, run the targeted suite locally and add/adjust tests if the regression escaped coverage.
- Before reading reproduction as product evidence, pass a preflight gate (required vars/secrets present, target reachable, artifact directory writable, ownership/permissions valid).
- If local reproduction is prevented by temporary environment/harness issues (for example missing target reachability, wrong file ownership, unavailable tunnel, or missing secrets), mark the local attempt as `blocked`/invalid evidence.
- A `blocked` local attempt does not authorize product-code changes by itself and does not overrule a valid remote diagnosis.
- If the remote failure is valid and specific while the local path is `blocked` for unrelated reasons, continue root-cause analysis from the remote evidence and the closest valid local equivalent instead of forcing a misleading local patch.

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
- completion-guard outcome and the exact command used
- any residual blocker requiring user action
