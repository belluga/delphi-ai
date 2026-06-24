#!/usr/bin/env bash
set -euo pipefail

mirrored_skills=(
  "review-finding-classification"
  "test-quality-audit"
  "test-creation-standard"
  "test-orchestration-suite"
  "wf-docker-subagent-worktree-reconciliation-method"
)

printf '%s\n' "${mirrored_skills[@]}"
