---
name: github-stage-promotion-docker-finalization
description: "Phase skill for Docker gitlink follow-through after Flutter/Laravel through-stage promotion."
---

# GitHub Stage Promotion: Docker Finalization

Use when Flutter and/or Laravel source promotion is `through-stage` and Docker must carry the resulting app pins.

## Responsibilities
- Wait for the repository-dispatch flow to create or refresh Docker `bot/next-version`.
- Route stale or invalid bot branch handling to `github-stage-promotion-bot-next-version-recovery`.
- Promote `bot/next-version -> dev`, then `dev -> stage` as needed.
- Verify Docker target branch points to the expected app target SHA(s).
- Run the stage completion guard before claiming the lane is finished.

## Completion Guard
Run:
```bash
bash delphi-ai/tools/github_promotion_completion_guard.sh \
  --lane stage \
  --scenario <flutter-only|laravel-only|flutter-laravel> \
  --docker-repo <owner/name> \
  [--flutter-repo <owner/name>] \
  [--laravel-repo <owner/name>]
```

## Non-Negotiables
- App `through-stage` lanes are not complete while Docker finalization is pending.
- Docker finalization only carries the accepted app SHAs produced by the authoritative source lanes; it must not choose, reconstruct, or replace those source branches.
- Do not create a fresh Docker/root branch from `dev` or `stage` to substitute for a Flutter/Laravel authoritative source branch.
- Do not hand-edit gitlinks when dispatcher regeneration is the correct path.
- Do not create root-level reset/normalization commits that move app gitlinks away from the accepted authoritative SHAs in order to "realign" Docker to a stale baseline.
- Do not treat generated `web-app` output as a source repo.
