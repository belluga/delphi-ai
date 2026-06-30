---
name: github-stage-promotion-closeout-report
description: "Phase skill for GitHub stage-promotion completion evidence, completion guard usage, TODO lane status, and final report."
---

# GitHub Stage Promotion: Closeout Report

Use after the authorized promotion lane reaches its stopping point.

## Green-To-Promotion Accounting
For any promotion lane that obtained a current-head broad local green gate before remote promotion:
- report the exact artifact/command that established that green state;
- if any additional broad local rerun happened afterward, report the precise reopen trigger: authoritative head movement, `ci_equivalent_evidence_invalidation_guard.py` output requiring rerun, or a newly frozen finding classified as `release-blocker`.

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
- keep in `active/` while implementation evidence, package-wide review, decisions, or promotion preparation remain open; when it stays in `active/`, record `Active Work State` as `implementation`, `review`, or `blocked`;
- during package-wide review or Copilot-mimic loops, move TODOs progressively to `promotion_lane/` as each individual TODO becomes `Local-Complete` and explicitly clean in the current loop; do not hold already-clean TODOs in `active/` only because sibling TODOs are still under review;
- move to `promotion_lane/` when local implementation is complete and only authorized lane follow-through remains;
- once a current-head authoritative green local gate exists and only promotion follow-through remains, do not keep the TODO/package in open-ended local review without an explicit reopen trigger;
- move to `completed/` only after the final required lane threshold for that TODO is complete.

Run `python3 delphi-ai/tools/todo_authority_guard.py <todo-path> --require-delivery-gates` before any path/status close-claim change when the TODO is available locally.
Rerun `todo_completion_guard.py` before any path/status close-claim change.
