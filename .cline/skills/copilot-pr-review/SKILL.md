---
name: copilot-pr-review
description: "Simulate GitHub Copilot pull request review before CI or promotion. Use when the goal is to anticipate likely Copilot review comments on a PR diff, respecting official Copilot review behavior, repository instructions, excluded file classes, base-branch context, and submodule-aware review packaging."
---

# Copilot PR Review

Use this skill when the user wants a pre-PR audit that mirrors GitHub Copilot code review as closely as practical from the local workspace.

When the lane also carries delivery, readiness, or promotion claims, load `ci-equivalent-governance` before deciding whether the current branch has enough local validation to open or close the review loop.
When an accepted remediation wave adds or rewires any stage-facing test, wrapper, lifecycle step, or readonly/mutation row, load `ci-equivalent-test-surface-admission` before claiming the review branch or authoritative source branch is CI-equivalent ready.

## Official behavior to mirror

As of June 5, 2026, GitHub Docs describe Copilot code review with these constraints:

- It leaves a `Comment` review only. It does not `Approve` or `Request changes`.
- It reviews the pull request diff relative to the base branch.
- It reviews from multiple angles and can suggest ready-to-apply changes.
- It may repeat prior comments on re-review.
- It ignores some file classes entirely, notably dependency-management files (for example `package.json`, lockfiles), log files, and SVG files.
- It can use repository custom instructions from the base branch:
  - `.github/copilot-instructions.md`
  - `.github/instructions/**/*.instructions.md`
- It can use review-focused skills/MCP context when clearly relevant.

Primary sources:

- `https://docs.github.com/en/copilot/concepts/agents/code-review`
- `https://docs.github.com/en/copilot/how-tos/copilot-on-github/use-copilot-agents/copilot-code-review`

## Review contract for this simulation

Produce concise, actionable findings that look like likely Copilot PR comments:

- Focus on concrete correctness, security, performance, CI, and test-coverage risks.
- Prefer line/file-local findings over broad architecture essays.
- Do not emit approval language.
- Do not inflate nits into blockers.
- Separate likely-reviewed findings from likely-silent areas (for example excluded file classes).

## Base-branch policy

If the user does not specify a PR base, use:

- `reconcile/*`, `feature/*`, `bugfix/*` -> `origin/dev`
- `dev` -> `origin/stage`
- `stage` -> `origin/main`

If the repository has submodule gitlink changes, review the affected submodule repositories against the same logical base branch as separate producer diffs, because Copilot on the orchestrator repo only sees the gitlink movement while the source-repo PRs see the real code diff.

## Workflow

1. Determine the review base branch.
2. Build a bounded review packet with `scripts/build_copilot_review_packet.sh`.
   - When a governing TODO exists, pass it into the packet builder so prior adjudicated findings are carried forward into the no-context review package instead of being rediscovered as fresh blockers.
3. Load any repository Copilot instructions from the base branch when present.
4. Run an **internal no-context subagent sweep first** through `wf-docker-subagent-orchestration-method`.
   - Use only bounded packets; never fork the parent context into these reviewers.
   - Use at least two internal reviewer lenses:
     - `correctness/contract`: bugs, broken assumptions, missing cleanup, selector brittleness, payload drift.
     - `CI/tooling/test harness`: shard drift, timeout mismatches, artifact coupling, flaky isolation, false-green risks.
   - Add a third internal lens when workflows, test runners, release tooling, or promotion mechanics changed.
   - Add a dedicated `cutover-integrity` lens whenever the diff includes canonical cutover, legacy-path retirement, backward-compatibility exceptions, fallback bridges, or suspected shim architecture. That reviewer must cross-check the governing TODO before classifying a compatibility construct as a defect.
   - Merge findings, fix confirmed defects, validate the fix batch, and **commit that batch on the active review branch before rerunning review**.
   - On generic PR review flows, the active review branch may be the same authoritative source branch under review.
   - On promotion/readiness flows where the promotable branch history should stay clean, create a derived remediation branch from the authoritative source branch before the first review commit and keep the iterative review/fix commits there.
   - After each such commit, rebuild the bounded packet against the same base branch so the next review runs on the new `base...HEAD` from the active review branch instead of a stale worktree snapshot.
   - If that remediation wave changed a stage-facing test/harness surface, run `ci-equivalent-test-surface-admission` before treating the branch as ready for the next CI-equivalent claim.
   - On promotion/readiness flows, update the orchestration execution plan's package-level review-loop ledger after each accepted remediation wave so a no-context session can resume from the current round without inventing a parallel status file.
   - On promotion/readiness flows, update the orchestration plan's **Review Coverage Board** after each accepted remediation wave so every governing TODO is explicitly classified as `not-reviewed | in-review | reopened-fixed | clean-no-reopen | blocked`, with the latest evidence round/commit recorded.
   - On package-based promotion/readiness flows, move each governing TODO progressively from `active/` to `promotion_lane/` as soon as it is locally complete and explicitly `clean/no-reopen` in the current loop; do not wait for the entire package to go green before moving already-clean TODOs.
   - Do not accumulate multiple uncommitted remediation waves while continuing to review an older `HEAD`; that creates false re-findings and pseudo-loops.
   - Rerun the internal sweep until you honestly judge the packet `clean` or only by-design / explicitly challenged findings remain.
   - If a reviewer re-raises a finding already recorded as resolved/challenged in the carry-forward packet, do not patch blindly. Reopen it only when the current bounded package materially changed the same locus/behavior or the prior rationale is objectively insufficient.
   - Do not replay accepted remediation back onto the authoritative source branch yet. First, make the active remediation branch pass the full in-scope local `CI-Equivalent Suite Matrix` for the package/TODO set under review.
5. **After the internal sweep looks clean**, run one fresh internal no-context confirmation pass with the highest-risk applicable lens:
   - `correctness/contract`: common bugs, security issues, and obvious CI/test problems.
   - `cross-module`: performance, contract, and coverage risks.
   - `tooling`: workflows, test runners, or tooling changes.
   - The confirming reviewer must not be an implementing agent or a reviewer from the preceding sweep.
6. Merge and deduplicate findings by locus.
7. Run **post-review finding triage** through `review-finding-classification`.
   - Do this after reviewer output is collected.
   - Do **not** change reviewer prompts, reviewer heuristics, or detection standards to force fewer findings.
   - Load `review-finding-classification` as the canonical triage surface before routing findings into the governing TODO.
   - Classify each finding as:
     - `release-blocker`
     - `follow-up-fast-follow`
     - `follow-up-hardening`
     - `by-design/no-action`
   - Only `release-blocker` findings block the current release/promotion claim.
   - Do not reopen the internal review loop solely because of `follow-up-*` or `by-design/no-action` findings. Either fix them inline without rerunning when they are purely documentary/packet polish, or route them to the explicit follow-up ledger/TODO flow.
   - If a finding is real but non-blocking, route it into an explicit post-version TODO under:
     - `foundation_documentation/todos/active/fast_follow_required/followup/`, or
     - `foundation_documentation/todos/active/post_release_hardening/hardening/`
     while recording the originating release/package version in the TODO and routing ledger.
8. Classify results into:
   - `Likely Copilot Findings`
   - `Likely Silent / Excluded / Non-Comment`
   - `Instruction or Context Gaps`
9. If the user wants the lane ready for CI or promotion, fix blocking findings before claiming readiness.

## Internal-First Rule

For promotion, CI-equivalent, or readiness claims, the review order is mandatory:

1. fresh internal no-context subagents
2. local fixes, targeted validation, commit on the active review branch, and packet rebuild
3. a fresh internal no-context confirmation pass

Do not invoke an external provider as a promotion review gate. If the internal reviewer capacity is unavailable, recycle an internal review lane or record the required gate as blocked pending a human waiver.

## Promotion-lane constraint

This skill proposes likely review comments. It does not decide whether a finding is authoritative.

When used during a promotion lane, every finding must be cross-checked against the governing TODO before patching:

- approved objective
- explicit decision log
- accepted behavior changes
- stated non-goals
- acceptance criteria and validation matrix

If the finding matches approved by-design behavior, record it as challenged or non-actionable instead of patching blindly.
If the finding matches a previously adjudicated carry-forward item and the current diff did not materially change that locus/behavior, keep the prior disposition and classify the repeat as historical/noise instead of creating a fix-revert loop.

This is especially important for compatibility/cutover findings: do not patch away an explicitly approved bounded compatibility construct just because a reviewer flags it. Cross-check the TODO first, then decide whether the finding identifies real drift, unclear temporary scope, or a by-design exception.

The same scrutiny rule applies to internal subagent findings. Internal reviewers are not patch authority; they are the independent defect sieve.

Reviewers do not decide blocker-vs-follow-up by themselves. They surface likely issues. The release/process triage happens afterward against the governing TODO and current promotion goal.
That triage must run through `review-finding-classification`, including when the findings came from real GitHub Copilot/Codex review surfaces rather than only local mimic passes.

## Promotion Remediation Branch Mode

When this review is part of promotion-readiness or pre-promotion preflight, prefer preserving the promotable source branch history:

- Freeze the authoritative source branch that is intended for promotion.
- Do not open the derived remediation branch yet if that authoritative source branch has not already passed the current in-scope CI-equivalent matrix for its codebase on that same branch. If the source branch changed after its last green CI-equivalent pass, rerun CI-Equivalent on that changed source branch first.
- Before the first review-loop commit, create a derived remediation branch from that source branch. Recommended naming: `review/<source-branch-slug>-internal-YYYYMMDD>`.
- Run the iterative fix/validate/commit loop only on that derived remediation branch.
- Once the review branch is locally clean, compare `source-branch..review-branch` and decide the accepted net effect.
- Before replaying anything, run the full in-scope local `CI-Equivalent Suite Matrix` on the **review branch**. Consolidation/replay is allowed only after that matrix is green or has explicit approved waivers.
- Validation-surface rule for that gate: the remediation history branch remains `review/*`, and `ci-equivalent-governance` decides what qualifies as valid current-branch local proof there, including reconcile-wrapper exceptions and broad stage-gate naming.
- Replay the accepted net effect onto the authoritative source branch as one or a few curated commits only after the review-branch CI-equivalent run is green.
- Rebuild the bounded packet on the authoritative source branch after the replay and run a fresh internal no-context final confirmation pass there before claiming CI-equivalent or promotion readiness.

Authoritative-source post-replay validation policy:
- If the replay is a pure fast-forward or conflict-free curated cherry-pick/rebase with no semantic divergence from the validated review branch, a bounded sanity pass is sufficient:
  - clean worktree / expected diff check;
  - packet rebuild against the authoritative source branch;
  - final fresh internal no-context confirmation on that rebuilt packet.
- If the replay introduced conflicts, manual reconciliation, dropped hunks, reordered commits with non-trivial overlap, or any source-branch-only edits, rerun the full in-scope local `CI-Equivalent Suite Matrix` on the authoritative source branch before claiming readiness.

The derived remediation branch is evidence and working history. The authoritative source branch remains the promotable lane.

Package-level review-loop stage belongs in the orchestration execution plan. Per-finding dispositions belong in the governing TODOs and their carry-forward packets. Do not create an additional manual version-status artifact for the same promotion/readiness loop.

## Commit-Based Review Reset

This simulation must be run on a stable diff baseline, not on an ever-growing uncommitted worktree.

- A remediation wave is complete only when:
  - the confirmed findings for that wave were fixed,
  - the relevant validations were rerun,
  - and the fix wave was committed on the active review branch for that loop.
- Once that commit exists, rebuild the packet and restart review from the new `base...HEAD`.
- If promotion-readiness is using a derived remediation branch, do not open PRs or claim readiness from that branch. Replay the accepted net effect onto the authoritative source branch first, then rebuild/reconfirm there.
- If a reviewer comments on an older baseline that no longer matches the current committed `HEAD`, classify it as stale review evidence instead of reopening the same fix blindly.
- Do not spin additional no-context review passes against pre-commit state once you have already decided the fixes are real and should stay.

## Expected output shape

Lead with findings only. For each finding include:

- severity: `high|medium|low`
- locus: `file:line` when possible
- why Copilot would likely flag it
- concise fix direction

Keep the final report short. This is a PR-comment simulator, not a design document.

## Commands

Build a packet:

```bash
bash /home/elton/.codex/skills/copilot-pr-review/scripts/build_copilot_review_packet.sh \
  --repo-root <repo_root> \
  [--todo <todo_path>] \
  [--base <base_branch>] \
  [--output-dir <dir>]
```

When the diff is large, review the generated packet first and only open raw diffs for files implicated by the internal reviewers.

## Subagent Execution Note

When the active client exposes subagent tools, prefer real no-context subagents over simulated local self-review:

- `fork_context=false`
- pass only the bounded packet and the exact reviewer lens
- keep reviewer write scopes empty; this stage is review-only
- merge their outputs before the fresh internal confirmation pass and finding triage
