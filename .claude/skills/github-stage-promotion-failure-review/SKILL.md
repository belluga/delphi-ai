---
name: github-stage-promotion-failure-review
description: "Phase skill for CI/Copilot failure triage, root-cause classification, local reproduction, and independent critique escalation during stage promotion."
---

# GitHub Stage Promotion: Failure Review

Use whenever CI, Copilot, checks, deploy/smoke jobs, or local reproduction produce a blocker or ambiguous finding.

## Procedure
1. Freeze evidence: exact finding text, repo, branch, PR/check, logs, relevant diff, and intended behavior.
2. Classify the finding as `confirmed defect | by-design intent | upstream-lane drift | non-actionable`.
3. Attempt local reproduction in the closest materially similar setup when possible.
4. If local reproduction is blocked by harness/environment limitations, mark that attempt invalid evidence instead of treating it as product proof.
5. If classification or fix is ambiguous, architectural, cross-module, or high-blast-radius, run `wf-docker-independent-critique-method` with a bounded package.
6. Fix root cause on the authoritative source branch for the scenario, then replay the lane.

## Copilot Priority
1. Security / auth / tenant isolation.
2. Data loss, regression, or broken contract.
3. CI/pipeline false-green risk.
4. Flaky or weak tests masking real bugs.
5. Minor cleanup.

## Non-Negotiables
- Green checks do not override pertinent P1/P2 comments.
- Do not patch generated `web-app` output directly.
- Do not patch `dev` or `stage` just because the finding appeared there unless that lane is the authoritative source for the scenario.
