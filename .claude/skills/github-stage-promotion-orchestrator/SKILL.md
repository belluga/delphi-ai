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
3. **Promotion preflight review**: once source preflight is `go` and before the first PR, create a derived remediation branch from the promotable authoritative source branch when the lane wants to preserve promotable history, then run the internal no-context subagent sweep from `copilot-pr-review`, including the dedicated `cutover-integrity` reviewer whenever the lane includes canonical cutover, legacy-path retirement, fallback bridges, or explicit compatibility exceptions; pass the governing TODO so prior adjudicated findings are carried forward into the review packet, iterate until locally clean, and for each accepted remediation wave fix it, validate it, commit it on the active review branch, rebuild the packet, update the orchestration execution plan's package-level pre-promotion review-loop ledger and Review Coverage Board, and only then rerun review. After reviewer output is collected, run a separate finding triage step: reviewers keep their normal detection behavior, while the operator classifies each finding as `release-blocker`, `follow-up-fast-follow`, `follow-up-hardening`, or `by-design/no-action`. Only `release-blocker` findings block the current promotion lane; the two follow-up classes must be routed into explicit post-version TODOs. After the internal loop is clean, run the full in-scope local `CI-Equivalent Suite Matrix` on the remediation branch. Only after that matrix is green (or has explicit approved waivers) may the accepted net effect be replayed onto the authoritative source branch as one or a few curated commits. Rebuild the packet on that source branch and only then run the external Claude/Copilot-sim confirmation there before opening the first PR. If the replay was not a pure fast-forward or conflict-free curated replay, rerun the full in-scope local `CI-Equivalent Suite Matrix` on the authoritative source branch before claiming readiness. Compare every finding against the governing TODO decisions and loop until blockers are resolved or explicitly rejected as by-design.
   - Validation-surface clarification: CI-Equivalent is the generic current-branch local proof for the branch being evaluated. It must run from the current authoritative branch (`feature/*`, `review/*`, `reconcile/*`, or equivalent) using the project-owned local build/publish path and the same product-facing suites the pipeline uses for that scope. `reconcile/*` is not a prerequisite for CI-Equivalent; it is only the execution topology for real reconciliation work. If a package was first integrated on a reconciliation branch, replay that accepted reconciliation state back onto the canonical version/source branch before promotion resumes; the reconciliation branch is evidence topology, not the promotable source branch. Proof against a published `stage` environment is a separate stage-published validation surface and must never be mislabeled as CI-Equivalent.
4. **Source to dev**: promote normal Docker/app/source branches into `dev` through guarded PR actions.
5. **Bot next-version recovery**: when Docker gitlink movement is required, ensure the lane-owned `bot/next-version -> dev` path is clean.
6. **Dev to stage**: only for `through-stage`, promote `dev -> stage` through PR.
7. **Docker finalization**: for app `through-stage` lanes, complete Docker gitlink follow-through before the lane is finished.
8. **Failure review**: when CI/Copilot/checks fail or are ambiguous, classify and resolve root cause before retrying.
9. **Closeout report**: run completion evidence and update the governing TODO/promotion status.

## Classification
The intake phase must classify exactly one scenario before mutation. Use `python3 delphi-ai/tools/github_stage_promotion_scenario_classifier.py --repo <repo> --base <base-ref> --source <source-ref>` as advisory deterministic evidence, then record the human-authorized scenario:
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
- Before the first promotion PR in a lane, run `copilot-pr-review` once the authoritative source branch is preflight-green. The mandatory order is: internal no-context subagents first, Claude/Copilot-sim second. Treat all review output as evidence, not patch authority.
- During that pre-promotion review loop, do not keep stacking uncommitted fixes while continuing to review an older diff. Each accepted remediation wave must be committed on the active review branch before the next review pass so the lane keeps a stable `base...HEAD` baseline.
- During that pre-promotion review loop, do not create a parallel manual version-status artifact. Package-level round state belongs in the orchestration execution plan; per-finding authoritative dispositions remain in the governing TODO carry-forward path.
- During that pre-promotion review loop, keep the orchestration plan's Review Coverage Board current so every governing TODO has an explicit coverage state and latest evidence round.
- When promotion history should stay readable, the active review branch must be a derived remediation branch and the promotable source branch must stay frozen until the accepted net effect is replayed back as curated commit(s).
- Do not derive the review branch from a source branch that has not already passed the current in-scope CI-equivalent matrix on that source branch's local runtime surface. If the source branch changed after its last green CI-equivalent pass, rerun CI-Equivalent on that changed source branch before opening review.
- Do not replay accepted remediation from the review branch onto the authoritative source branch before the review branch has passed the full in-scope local `CI-Equivalent Suite Matrix`.
- Reconcile-only wrappers remain special-purpose helpers for reconciliation state. They are not the definition of CI-Equivalent, and they are not automatically the canonical executor for a review-branch gate unless the branch under test is itself a real reconciliation branch.
- If a package was first integrated on `reconcile/*`, require `orchestration_reconcile_replay_guard.py` to return `Overall outcome: go` against the orchestration plan and authoritative source repo before any promotion branch is treated as ready.
- Do not open promotion PRs from an orchestration-only reconciliation branch. Replay the accepted net effect onto the canonical version/source branch first, then resume promotion from that authoritative branch.
- Do not open promotion PRs from the remediation branch. Promotion always resumes from the authoritative source branch after replay and reconfirmation.
- Every Copilot-style finding must be cross-checked against the governing TODO's approved objective, decision log, accepted behavior changes, non-goals, and validation matrix before it is classified as defect or noise.
- Compatibility/cutover findings receive an extra scrutiny rule: a finding about shim/bridge behavior blocks only when the construct is accidental drift or exceeds the TODO's explicit authorization. If the governing TODO intentionally authorizes a bounded compatibility construct, the review must challenge scope/removal criteria instead of blindly blocking on its existence.
- Repeated Copilot/no-context findings do not automatically reopen work. If the governing TODO already records the same locus/behavior as resolved, challenged, or deferred, keep that disposition unless the current lane materially changed that locus/behavior or the prior rationale is objectively insufficient.
- Always pursue root cause. Do not patch only to satisfy CI.
- CI behavior changes and promotion-tooling behavior changes require explicit user authorization in the local promotion contract.

## Required Deterministic Helpers
- Create a contract before mutating:
  - `bash delphi-ai/tools/github_promotion_contract_init.sh --output delphi-ai/artifacts/tmp/promotion-contract.json --scope dev-only`
  - `bash delphi-ai/tools/github_promotion_contract_init.sh --output delphi-ai/artifacts/tmp/promotion-contract.json --scope through-stage --gitlink-policy pipeline-only`
- Classify the scenario before mutating:
  - `python3 delphi-ai/tools/github_stage_promotion_scenario_classifier.py --repo <repo> --base <base-ref> --source <source-ref>`
- Use guarded wrappers for mutating local/manual actions:
  - `guarded_git_commit.sh`
  - `guarded_git_push.sh`
  - `guarded_pr_create.sh`
  - `guarded_pr_merge.sh`
- Run first-PR source preflight:
  - normal branches: `bash delphi-ai/tools/github_stage_promotion_preflight.sh --source <source-branch> --base origin/dev`
  - bot lane: `bash delphi-ai/tools/github_stage_promotion_preflight.sh --source origin/bot/next-version --base origin/dev --require-diff-shape submodule-only`
  - reconcile-origin package handoff: `bash delphi-ai/tools/github_stage_promotion_preflight.sh --source <canonical-source-branch> --base origin/dev --orchestration-plan foundation_documentation/artifacts/execution-plans/<short-slug>.md`
- Use `github_stage_promotion_snapshot.sh` for PR/check evidence.
- Use the pre-promotion review skills before the first PR after source preflight is green:
  - `copilot-pr-review`
  - `wf-docker-subagent-orchestration-method`
  - `claude-cli-calling`
- For `through-stage` closeout, run:
  - `bash delphi-ai/tools/github_promotion_completion_guard.sh --lane stage --scenario <docker-only|flutter-only|laravel-only|flutter-laravel> --docker-repo <owner/name> [...]`

## Finding Scrutiny
Before patching any blocking PR/check/Copilot finding:
1. Freeze the exact finding, repo, branch, PR/check, relevant diff, and intended behavior.
2. Compare it against the governing TODO's approved objective, explicit decisions, accepted behavior changes, non-goals, and validation matrix.
3. Classify as `confirmed defect | by-design intent | upstream-lane drift | non-actionable`.
4. If the same finding already exists in the TODO carry-forward packet and the lane did not materially change that locus/behavior, preserve the prior disposition instead of patching.
5. If ambiguous, architectural, cross-module, or high-blast-radius, run `wf-docker-independent-critique-method` with a bounded package.
6. If a fix is needed, patch the authoritative source branch for that scenario, then replay the lane.

## Promotion Finding Routing
Do not turn every promotion finding into a new TODO or a lane restart. Route findings this way:
- `P1`/`P2` findings block merge, lane completion, and closeout claims until fixed, re-evidenced, or explicitly waived by the current approval authority.
- Same-scope remediation stays in the governing TODO and promotion lane when it preserves the approved objective, scenario, source branch, and risk conversation. Patch the authoritative source branch and replay only the affected lane evidence.
- When the lane is using a derived remediation branch for review-loop history preservation, same-scope remediation still stays in the governing TODO and promotion lane, but the iterative commits happen on the remediation branch first; only the accepted net effect is replayed onto the authoritative source branch before PR creation and lane evidence replay.
- Reviewers/auditors do not change how they detect findings. After findings are gathered, classify each one explicitly:
  - `release-blocker`: stays in the current governing TODO/package and blocks promotion.
  - `follow-up-fast-follow`: open/split a TODO under `foundation_documentation/todos/active/fast_follow_required/followup/`.
  - `follow-up-hardening`: open/split a TODO under `foundation_documentation/todos/active/post_release_hardening/hardening/`.
  - `by-design/no-action`: record rationale only; do not patch blindly.
- The originating release/package version must be recorded in the split TODO and in the `Promotion Finding Routing Ledger`; it does not need to appear in the directory name.
- Renew approval or split only when the finding changes the approved scope, introduces a new independently testable behavior, changes promotion/tooling policy, requires an architectural decision, or asks to accept/waive a blocking risk.
- Record the routing in the TODO `Promotion Finding Routing Ledger` when findings exist, and run `python3 delphi-ai/tools/todo_authority_guard.py <todo-path> --require-delivery-gates` before delivery or promotion-readiness claims.

## Closeout
- `dev-only`: report source repo(s), PR(s), target SHA(s), check evidence, Copilot disposition, and any follow-up such as Docker finalization that was intentionally out of scope.
- `through-stage`: report source and lane PRs, post-merge run IDs, Docker finalization state, generated `web-app` evidence if relevant, and completion-guard outcome.
- Keep the same governing TODO authoritative through promotion follow-through; do not create a new tactical TODO solely for operational promotion.
