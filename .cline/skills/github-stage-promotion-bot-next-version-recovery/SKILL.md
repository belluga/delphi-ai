---
name: github-stage-promotion-bot-next-version-recovery
description: "Phase skill for Docker lane-owned `bot/next-version` submodule gitlink recovery, verification, and PR movement into `dev`."
---

# GitHub Stage Promotion: Bot Next-Version Recovery

Use only for Docker submodule gitlink promotion through the lane-owned `bot/next-version -> dev` path.

## Required Shape
- Head branch: `bot/next-version`.
- Base branch: `dev`.
- Diff shape: submodule gitlinks only.
- Branch must contain the current `origin/dev` tip.
- PR creation is manual; branch content may be prepared by repository-dispatch automation.

## Procedure
1. Run:
   ```bash
   bash delphi-ai/tools/github_stage_promotion_preflight.sh \
     --source origin/bot/next-version \
     --base origin/dev \
     --require-diff-shape submodule-only
   ```
2. If stale but already carrying desired pins, do not hand-edit gitlinks. With explicit operator approval, delete/reset the remote branch so the dispatcher can recreate it from current `origin/dev`.
3. Re-dispatch the required Flutter/Laravel stage callback after stale branch removal/reset.
4. Open PR `bot/next-version -> dev` through `guarded_pr_create.sh`.
5. Merge only after checks and Copilot comments are green/resolved.
6. Wait for post-merge `dev` runs.

## Non-Negotiables
- Never promote `bot/next-version` directly to `stage`.
- Never introduce manual gitlinks through feature/fix/source branches.
- Destructive remote branch reset/deletion requires explicit operator approval unless approved automation performs it.
