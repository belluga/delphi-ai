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
5. Attempt local reproduction in the closest materially similar setup when possible.
6. If local reproduction is blocked by harness/environment limitations, mark that attempt invalid evidence instead of treating it as product proof.
7. If classification or fix is ambiguous, architectural, cross-module, or high-blast-radius, run `wf-docker-independent-critique-method` with a bounded package.
8. If the blocker originated in the pre-promotion review flow, preserve the review order on replay: internal no-context subagents first, Claude/Copilot-style confirmation second.
9. Fix root cause on the authoritative source branch for the scenario, then replay the lane.
10. Record promotion routing in the governing TODO when findings exist:
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
- Do not patch generated `web-app` output directly.
- Do not patch `dev` or `stage` just because the finding appeared there unless that lane is the authoritative source for the scenario.
