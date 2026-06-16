---
name: github-stage-promotion-dev-to-stage
description: "Phase skill for `dev -> stage` lane-to-lane promotion after source and required gitlink work are healthy on `dev`."
---

# GitHub Stage Promotion: Dev to Stage

Use only when the user authorized `through-stage` and the required source/dev work is healthy.

## Responsibilities
- Open or reuse PR `dev -> stage`.
- Include `- Expected SHA: <40-char-sha>` in the PR body when the repo enforces it.
- Wait for all checks, review comments, and deploy/smoke jobs.
- Merge only when checks are green and pertinent comments are resolved.
- Wait for post-merge `stage` runs to finish green.

## Gitlink Handling
Gitlinks that reached `dev` through `bot/next-version -> dev` may travel with `dev -> stage`. Do not strip, rewrite, or hand-edit them during lane-to-lane promotion.

## Non-Negotiables
- No `main`.
- No direct pushes to lane branches.
- No merge while checks are pending, failed, flaky, or review findings are unresolved.
