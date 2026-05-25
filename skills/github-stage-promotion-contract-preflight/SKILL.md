---
name: github-stage-promotion-contract-preflight
description: "Phase skill for GitHub stage promotion contract creation, source preflight, clean-status checks, and guarded wrapper setup."
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
- Next phase route.

## Non-Negotiables
- Any `Overall outcome: no-go` from preflight or guards blocks mutation.
- Do not treat the current checkout branch as authoritative without confirmation.
- Do not hide CI/promotion-tooling behavior changes inside the promotion diff.
