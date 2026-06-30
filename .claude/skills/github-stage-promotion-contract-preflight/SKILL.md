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
- Keep `ci_behavior_change_authorized=false`, `ci_test_harness_change_authorized=false`, and `promotion_behavior_change_authorized=false` unless the user explicitly authorized those exact change classes.
- Use `ci_test_harness_change_authorized=true` only for narrow workflow diffs that merely extend or retarget existing test harness/test-selection surfaces; it does not authorize broader CI control-plane edits.
- Run `git status --short` in each touched repo.
- When a version/package TODO governs the lane, require repo-specific source authority to return `Overall outcome: go` before normal source preflight. If the governing TODO is a release-package TODO, treat that authority as live: first require the package rollup to match the current version membership under `active/<version>` plus `promotion_lane/<version>`, and require every live child TODO to already be promotion-eligible.
- When that package/version authority applies, treat the TODO-recorded version branch, typically `*-rc`, as the authoritative source branch for the first `CI-Equivalent` run. A later `review/*` branch may add validation, but it does not replace the required `*-rc` proof.
- Run first-PR preflight:
  - normal source: `bash delphi-ai/tools/github_stage_promotion_preflight.sh --source <source-branch> --base origin/dev`
  - version/package source: `bash delphi-ai/tools/github_stage_promotion_preflight.sh --source <source-branch> --base origin/dev --governing-todo <todo-path> --repo-key <key>`
    - when `<todo-path>` is a release-package TODO, this command now auto-runs `github_release_package_rollup_guard.py` before `github_promotion_source_authority_guard.py`
  - bot lane: `bash delphi-ai/tools/github_stage_promotion_preflight.sh --source origin/bot/next-version --base origin/dev --require-diff-shape submodule-only`
- If the package was first integrated on `reconcile/*`, do not let preflight start from that branch. First record replay in the orchestration execution plan and require `python3 delphi-ai/tools/orchestration_reconcile_replay_guard.py --plan <plan-path> --repo <authoritative-source-repo>` to return `Overall outcome: go`. Then run stage preflight from the canonical branch, preferably with `--orchestration-plan <plan-path>` so the preflight delegates to the replay guard before checking promotion lineage.
- Discover existing PRs before creating new ones.
- After preflight returns `Overall outcome: go` and before creating the first PR, run `copilot-pr-review` on each authoritative source repo/branch in scope.
- After those findings are collected and deduplicated, run `review-finding-classification` before deciding blocker-vs-follow-up routing or updating the governing TODO ledger.
- Load `ci-equivalent-governance` before deciding which local matrix or stage-parity contract satisfies the pre-promotion `CI-Equivalent` requirement.
- If accepted remediation changes any stage-facing test row, wrapper, lifecycle step, or readonly/mutation coverage row, load `ci-equivalent-test-surface-admission` before claiming the authoritative source branch is pre-promotion ready.
- For package/version lanes, explicitly record the authoritative `*-rc` branch name in the orchestration execution plan or equivalent review ledger before opening the remediation branch.
- The order is mandatory:
  1. internal no-context subagent sweep
  2. local fix/rerun loop until locally clean
  3. external Claude/Copilot-style confirmation
- Published `stage` probes remain separate evidence; they do not replace the local `CI-Equivalent` requirement.
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
- Governing TODO source-authority result when package/version authority applies.
- Preflight result and existing PR discovery.
- Copilot-style review disposition per authoritative source repo.
- Next phase route.
- Updated package-stage review-loop state in the orchestration execution plan when promotion-readiness review is in scope.

## Non-Negotiables
- Any `Overall outcome: no-go` from preflight or guards blocks mutation.
- A version/package promotion source is not authoritative unless the governing TODO's `Current Branch Authority` and exact `branch@sha` baseline both match the source branch under evaluation.
- A release-package TODO is not authoritative unless its `Current Diff Child Owners` still matches the live version membership and every live child owner is already at a promotable delivery stage.
- In that version/package case, a green `review/*` matrix without a prior green authoritative `*-rc` matrix is still `no-go`.
- A promotion source branch named `reconcile/*` is always a blocker. Promotion resumes only after replay onto the canonical branch is proven.
- Do not open the first promotion PR while unresolved P1/P2 pre-promotion review findings remain.
- Do not escalate Claude quota/rate-limit issues as a promotion blocker unless the mandatory internal no-context subagent sweep has already reached a locally clean state.
- Do not let a bot finding outrank an approved TODO decision; the finding must be cross-checked before patching.
- Do not treat the current checkout branch as authoritative without confirmation.
- Do not hide CI/promotion-tooling behavior changes inside the promotion diff.
