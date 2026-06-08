---
name: github-stage-promotion-contract-preflight
description: "Phase skill for GitHub stage promotion contract creation, source preflight, clean-status checks, guarded wrapper setup, mandatory internal no-context subagent review loop, and final Claude/Copilot-style pre-promotion confirmation before the first PR."
---

# GitHub Stage Promotion: Contract and Preflight

Use after intake has classified the scenario and before opening or mutating any PR.

## Responsibilities
- Create the local promotion contract:
  - `dev-only`: `bash delphi-ai/tools/github_promotion_contract_init.sh --output delphi-ai/artifacts/tmp/promotion-contract.json --scope dev-only`
  - `through-stage`: `bash delphi-ai/tools/github_promotion_contract_init.sh --output delphi-ai/artifacts/tmp/promotion-contract.json --scope through-stage --gitlink-policy pipeline-only`
- Keep `ci_behavior_change_authorized=false` and `promotion_behavior_change_authorized=false` unless the user explicitly authorized those behavior changes.
- Run `git status --short` in each touched repo.
- Run first-PR preflight:
  - normal source: `bash delphi-ai/tools/github_stage_promotion_preflight.sh --source <source-branch> --base origin/dev`
  - bot lane: `bash delphi-ai/tools/github_stage_promotion_preflight.sh --source origin/bot/next-version --base origin/dev --require-diff-shape submodule-only`
- Discover existing PRs before creating new ones.
- After preflight returns `Overall outcome: go` and before creating the first PR, run `copilot-pr-review` on each authoritative source repo/branch in scope.
- The order is mandatory:
  1. internal no-context subagent sweep
  2. local fix/rerun loop until locally clean
  3. external Claude/Copilot-style confirmation
- Use the orchestration execution plan as the package-stage ledger for this loop. Record current round, authoritative source branch, active remediation branch, open blockers, and next exact step there. Do not create a separate manual version-status file for promotion readiness.
- For every review finding, compare it against the governing TODO before classifying it:
  - approved objective
  - explicit decision log
  - accepted behavior changes
  - stated non-goals
  - acceptance criteria and validation matrix
- Loop the review/fix cycle until blockers are resolved, routed upstream, or explicitly rejected as by-design with technical rationale.

## Guarded Mutations
Use guarded wrappers, not raw mutating commands:
- `guarded_git_commit.sh`
- `guarded_git_push.sh`
- `guarded_pr_create.sh`
- `guarded_pr_merge.sh`

The wrappers enforce action/diff policy only. They do not prove PR checks, review comments, or merge readiness are green.

## Outputs
- Promotion contract path.
- Clean/dirty status per repo.
- Preflight result and existing PR discovery.
- Copilot-style review disposition per authoritative source repo.
- Next phase route.
- Updated package-stage review-loop state in the orchestration execution plan when promotion-readiness review is in scope.

## Non-Negotiables
- Any `Overall outcome: no-go` from preflight or guards blocks mutation.
- Do not open the first promotion PR while unresolved P1/P2 pre-promotion review findings remain.
- Do not escalate Claude quota/rate-limit issues as a promotion blocker unless the mandatory internal no-context subagent sweep has already reached a locally clean state.
- Do not let a bot finding outrank an approved TODO decision; the finding must be cross-checked before patching.
- Do not treat the current checkout branch as authoritative without confirmation.
- Do not hide CI/promotion-tooling behavior changes inside the promotion diff.
