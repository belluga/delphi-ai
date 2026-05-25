---
name: github-stage-promotion-closeout-report
description: "Phase skill for GitHub stage-promotion completion evidence, completion guard usage, TODO lane status, and final report."
---

# GitHub Stage Promotion: Closeout Report

Use after the authorized promotion lane reaches its stopping point.

## Dev-Only Closeout
Report:
- source repo(s), branch(es), PR(s), and final `dev` SHA(s);
- post-merge `dev` run/check evidence;
- Copilot finding disposition;
- whether Docker finalization was explicitly out of scope or still pending as follow-up.

Do not run the stage completion guard for pure `dev-only` app promotion unless the user explicitly included Docker gitlink finalization in the same scope.

## Through-Stage Closeout
Before claiming completion, run:
```bash
bash delphi-ai/tools/github_promotion_completion_guard.sh \
  --lane stage \
  --scenario <docker-only|flutter-only|laravel-only|flutter-laravel> \
  --docker-repo <owner/name> [...]
```

Report:
- repo and branch promoted;
- PR numbers for `-> dev` and `dev -> stage`;
- final SHAs in reached lanes;
- post-merge run IDs;
- Docker Scenario 2 regeneration/finalization status;
- generated `web-app` artifact evidence if it influenced source-lane decisions, labeled as derived and not promoted;
- completion-guard outcome and exact command;
- residual blocker requiring user action.

## TODO Closeout
Keep the same governing TODO authoritative:
- keep in `active/` while implementation evidence, decisions, or promotion preparation remain open;
- move to `promotion_lane/` when local implementation is complete and only authorized lane follow-through remains;
- move to `completed/` only after the final required lane threshold for that TODO is complete.

Rerun `todo_completion_guard.py` before any path/status close-claim change.
