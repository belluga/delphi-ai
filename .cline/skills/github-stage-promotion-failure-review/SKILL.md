---
name: github-stage-promotion-failure-review
description: "Phase skill for CI/Copilot failure triage, root-cause classification, local reproduction, and independent critique escalation during stage promotion."
---

# GitHub Stage Promotion: Failure Review

Use whenever CI, Copilot, checks, deploy/smoke jobs, or local reproduction produce a blocker or ambiguous finding.

## Procedure
1. Freeze evidence: exact finding text, repo, branch, PR/check, logs, relevant diff, and intended behavior.
2. Compare the finding against the governing TODO's approved objective, explicit decisions, accepted behavior changes, non-goals, and validation matrix.
3. Classify the finding as `confirmed defect | by-design intent | upstream-lane drift | non-actionable`.
4. If the same finding was already adjudicated in the TODO carry-forward packet and the failing lane did not materially change that locus/behavior, preserve the prior disposition instead of reopening the loop.
5. Before scheduling any broad local rerun inside the promotion flow, check whether the authoritative source heads or runtime contract materially changed since the last green local `CI-Equivalent` artifact. If they did not, keep that artifact authoritative unless the new evidence is frozen and classified as `release-blocker` or the invalidation guard requires rerun.
6. When a lower-lane merge advances a branch that already has an open higher-lane PR (for example `stage` advancing while `stage -> main` is open), treat any synchronized higher-lane `pull_request` run as next-lane evidence first. Do not let that sync run reopen or block the current lane unless the authoritative target-branch `push` run for the current lane also fails, or the finding is otherwise frozen and classified as a current-lane `release-blocker`.
6. Attempt local reproduction in the closest materially similar setup when possible.
7. If local reproduction is blocked by harness/environment limitations, mark that attempt invalid evidence instead of treating it as product proof.
8. If classification or fix is ambiguous, architectural, cross-module, or high-blast-radius, run `wf-docker-independent-critique-method` with a bounded package.
9. If the blocker originated in the pre-promotion review flow, preserve the review order on replay: fresh internal no-context subagents first, then a fresh internal no-context confirmation pass.
10. Fix root cause on the authoritative source branch for the scenario, then replay the lane.
11. Record promotion routing in the governing TODO when findings exist:
   - same-scope remediation stays in the same TODO/lane;
   - scope/risk/architecture/tooling changes require TODO update, renewed approval, or split;
   - unresolved P1/P2 findings remain delivery and promotion blockers.

## Copilot Priority
1. Security / auth / tenant isolation.
2. Data loss, regression, or broken contract.
3. CI/pipeline false-green risk.
4. Flaky or weak tests masking real bugs.
5. Minor cleanup.

## Non-Negotiables
- Green checks do not override pertinent P1/P2 comments.
- A P1/P2 finding blocks promotion completion, but does not automatically create a new TODO when the fix preserves the same approved objective and scenario.
- An approved TODO decision outranks a bot inference until the finding is shown to contradict the agreed contract.
- A local/remote mismatch does not by itself invalidate the last authoritative current-head green local artifact. Before reopening the whole lane, prove source drift, guard-mandated invalidation, or classify a newly frozen `release-blocker`.
- A synchronized higher-lane PR run triggered only because the current lane advanced its source branch is not current-lane proof by itself. Evaluate the authoritative push run for the lane that just moved before calling the finding a blocker.
- Do not patch generated `web-app` output directly.
- Do not patch `dev` or `stage` just because the finding appeared there unless that lane is the authoritative source for the scenario.
