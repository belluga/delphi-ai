#!/usr/bin/env bash
set -euo pipefail

mirrored_skills=(
  "test-quality-audit"
  "test-creation-standard"
  "test-orchestration-suite"
)

printf '%s\n' "${mirrored_skills[@]}"
