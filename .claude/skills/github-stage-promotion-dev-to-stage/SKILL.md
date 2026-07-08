---
name: github-stage-promotion-dev-to-stage
description: "Phase skill for `dev -> stage` lane-to-lane promotion after source and required gitlink work are healthy on `dev`."
---

# GitHub Stage Promotion: Dev to Stage

Use only when the user authorized `through-stage` and the required source/dev work is healthy.

## Responsibilities
- Open or reuse PR `dev -> stage`.
- Require the promotion action guard to return `Overall outcome: go`; for mixed Docker lanes this includes deterministic verification that every required Docker `-> dev` track recorded in the contract is already absorbed into `origin/dev`.
- Include `- Expected SHA: <40-char-sha>` in the PR body when the repo enforces it.
- Once `dev` is healthy on the intended SHA and no newly frozen finding has been classified as `release-blocker`, convert directly into `dev -> stage` PR action or remote wait state instead of reopening local source-lane investigation by precaution.
- Wait for all checks, review comments, and deploy/smoke jobs.
- Merge only when checks are green and pertinent comments are resolved.
- Wait for post-merge `stage` runs to finish green.
- Treat the post-merge `push` run on branch `stage` as the authoritative remote completion evidence for this phase. If the same SHA also synchronizes an already-open `stage -> main` PR and triggers `pull_request` checks there, route that evidence through failure review as next-lane/main-readiness evidence; it does not by itself reopen or block `through-stage` completion.

## Gitlink Handling
Gitlinks that reached `dev` through `bot/next-version -> dev` may travel with `dev -> stage`. Do not strip, rewrite, or hand-edit them during lane-to-lane promotion.

## Non-Negotiables
- No `main`.
- No direct pushes to lane branches.
- No merge while checks are pending, failed, flaky, or review findings are unresolved.
- No fallback to fresh broad local source-gate reruns from this phase unless the authoritative source heads changed or failure review froze and classified a new `release-blocker`.
- Do not treat a synced `stage -> main` PR run as authoritative proof against the current `dev -> stage` lane when the post-merge `stage` push run on the same SHA is still pending or green; only a current-lane finding frozen through failure review or a failed authoritative `stage` push run may block this phase.
