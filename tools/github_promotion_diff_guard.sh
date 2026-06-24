#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/teach_runtime.sh"
source "$SCRIPT_DIR/lib/promotion_contract.sh"

usage() {
  cat <<'EOF'
Usage: github_promotion_diff_guard.sh --contract <path> [--repo <path>] --mode <staged|worktree|range> [--base-ref <ref>] [--source-ref <ref>]

Deterministically classify a promotion-lane diff and emit a TEACH runtime blocker when
the staged/worktree/range includes forbidden surfaces such as gitlinks, CI control-plane
changes, CI test-harness changes, or promotion-tooling changes without explicit authorization.
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

CONTRACT_PATH=""
REPO_INPUT="."
MODE=""
BASE_REF=""
SOURCE_REF="HEAD"

while [ $# -gt 0 ]; do
  case "$1" in
    --contract)
      [ $# -ge 2 ] || die "missing value for --contract"
      CONTRACT_PATH="$2"
      shift 2
      ;;
    --repo)
      [ $# -ge 2 ] || die "missing value for --repo"
      REPO_INPUT="$2"
      shift 2
      ;;
    --mode)
      [ $# -ge 2 ] || die "missing value for --mode"
      MODE="$2"
      shift 2
      ;;
    --base-ref)
      [ $# -ge 2 ] || die "missing value for --base-ref"
      BASE_REF="$2"
      shift 2
      ;;
    --source-ref)
      [ $# -ge 2 ] || die "missing value for --source-ref"
      SOURCE_REF="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

[ -n "$CONTRACT_PATH" ] || die "--contract is required"
[ -n "$MODE" ] || die "--mode is required"

case "$MODE" in
  staged|worktree) ;;
  range)
    [ -n "$BASE_REF" ] || die "--base-ref is required when --mode=range"
    ;;
  *)
    die "unsupported --mode value: $MODE"
    ;;
esac

REPO_ROOT="$(git -C "$REPO_INPUT" rev-parse --show-toplevel 2>/dev/null || true)"
[ -n "$REPO_ROOT" ] || die "path is not inside a git repository: $REPO_INPUT"

promotion_contract_load "$CONTRACT_PATH"

teach_runtime_begin "paced.github-promotion.diff" "stop_before_mutating_action"
teach_set_context_none_label "changed_paths: none"

git_args=()
case "$MODE" in
  staged)
    git_args=(diff --cached --raw --ignore-submodules=none --)
    ;;
  worktree)
    git_args=(diff --raw --ignore-submodules=none --)
    ;;
  range)
    git_args=(diff --raw --ignore-submodules=none "$BASE_REF..$SOURCE_REF" --)
    ;;
esac

declare -a CHANGED_PATHS=()
declare -a GITLINK_PATHS=()
declare -a CI_SURFACE_PATHS=()
declare -a CI_TEST_HARNESS_SURFACE_PATHS=()
declare -a CI_CONTROL_PLANE_SURFACE_PATHS=()
declare -a PROMOTION_SURFACE_PATHS=()

append_unique() {
  local target_name="$1"
  local candidate="$2"
  local existing
  declare -n target_ref="$target_name"

  [ -n "$candidate" ] || return
  for existing in "${target_ref[@]}"; do
    if [ "$existing" = "$candidate" ]; then
      return
    fi
  done

  target_ref+=("$candidate")
}

classify_path() {
  local path="$1"

  append_unique CHANGED_PATHS "$path"

  case "$path" in
    .github/workflows/*|.github/actions/*|.github/scripts/*)
      append_unique CI_SURFACE_PATHS "$path"
      ;;
  esac

  case "$path" in
    tools/github_*promotion*.sh|tools/guarded_*.sh|tools/lib/promotion_contract.sh|tools/lib/teach_runtime.sh|skills/github-stage-promotion-orchestrator/SKILL.md|skills/github-main-promotion-orchestrator/SKILL.md|.cline/skills/github-stage-promotion-orchestrator/SKILL.md|.cline/skills/github-main-promotion-orchestrator/SKILL.md)
      append_unique PROMOTION_SURFACE_PATHS "$path"
      ;;
  esac
}

workflow_line_is_test_harness_safe() {
  local line="$1"

  if [[ "$line" =~ ^[+-][[:space:]]*$ ]]; then
    return 0
  fi

  if [[ "$line" =~ ^[+-][[:space:]]*# ]]; then
    return 0
  fi

  if [[ "$line" =~ ^[+-][[:space:]]*[A-Z0-9_]*(NAV|PLAYWRIGHT|PWDEBUG|TEST|TESTS|MUTATION|READONLY|INTEGRATION|E2E|SMOKE|SHARD|SPEC|FIXTURE)[A-Z0-9_]*:[[:space:]].*$ ]]; then
    return 0
  fi

  if [[ "$line" =~ (integration_test/|(^|[^A-Za-z0-9_])tests?/|(^|[^A-Za-z0-9_])specs?/|\.spec\.[A-Za-z0-9]+|\.test\.[A-Za-z0-9]+|_test\.[A-Za-z0-9]+|[A-Za-z0-9._/-]*(fixture|shard|mutation|readonly|playwright)[A-Za-z0-9._/-]*\.(json|ya?ml|cjs|js|ts)) ]]; then
    return 0
  fi

  return 1
}

classify_ci_surface_path() {
  local path="$1"
  local line
  local has_relevant_lines=false

  case "$path" in
    .github/workflows/*) ;;
    .github/actions/*|.github/scripts/*)
      append_unique CI_CONTROL_PLANE_SURFACE_PATHS "$path"
      return
      ;;
    *)
      append_unique CI_CONTROL_PLANE_SURFACE_PATHS "$path"
      return
      ;;
  esac

  while IFS= read -r line; do
    case "$line" in
      diff\ --git\ *|index\ *|@@\ *|---\ *|+++\ *)
        continue
        ;;
      +*|-*)
        has_relevant_lines=true
        ;;
      *)
        continue
        ;;
    esac

    if ! workflow_line_is_test_harness_safe "$line"; then
      append_unique CI_CONTROL_PLANE_SURFACE_PATHS "$path"
      return
    fi
  done < <(
    case "$MODE" in
      staged)
        git -C "$REPO_ROOT" diff --cached -U0 --ignore-submodules=none -- "$path"
        ;;
      worktree)
        git -C "$REPO_ROOT" diff -U0 --ignore-submodules=none -- "$path"
        ;;
      range)
        git -C "$REPO_ROOT" diff -U0 --ignore-submodules=none "$BASE_REF..$SOURCE_REF" -- "$path"
        ;;
    esac
  )

  if [ "$has_relevant_lines" = true ]; then
    append_unique CI_TEST_HARNESS_SURFACE_PATHS "$path"
    return
  fi

  append_unique CI_CONTROL_PLANE_SURFACE_PATHS "$path"
}

while IFS=$'\t' read -r meta primary_path secondary_path; do
  path="$primary_path"
  [ -n "${secondary_path:-}" ] && path="$secondary_path"
  [ -n "${path:-}" ] || continue
  classify_path "$primary_path"
  if [ -n "${secondary_path:-}" ]; then
    classify_path "$secondary_path"
  fi

  set -- $meta
  old_mode="${1#:}"
  new_mode="${2:-000000}"

  if [ "$old_mode" = "160000" ] || [ "$new_mode" = "160000" ]; then
    append_unique GITLINK_PATHS "$path"
  fi
done < <(git -C "$REPO_ROOT" "${git_args[@]}")

teach_add_context "repo_root: $REPO_ROOT"
teach_add_context "inspection_mode: $MODE"
teach_add_context "scope: $PROMOTION_CONTRACT_SCOPE"
teach_add_context "gitlink_policy: $PROMOTION_CONTRACT_GITLINK_POLICY"
teach_add_context "ci_behavior_change_authorized: $PROMOTION_CONTRACT_CI_BEHAVIOR_CHANGE_AUTHORIZED"
teach_add_context "ci_test_harness_change_authorized: $PROMOTION_CONTRACT_CI_TEST_HARNESS_CHANGE_AUTHORIZED"
teach_add_context "promotion_behavior_change_authorized: $PROMOTION_CONTRACT_PROMOTION_BEHAVIOR_CHANGE_AUTHORIZED"

if [ -n "$BASE_REF" ]; then
  teach_add_context "base_ref: $BASE_REF"
  teach_add_context "source_ref: $SOURCE_REF"
fi

if [ "${#CHANGED_PATHS[@]}" -gt 0 ]; then
  teach_add_context "changed_path_count: ${#CHANGED_PATHS[@]}"
fi

if [ "${#GITLINK_PATHS[@]}" -gt 0 ]; then
  local_gitlinks="$(printf '%s, ' "${GITLINK_PATHS[@]}")"
  local_gitlinks="${local_gitlinks%, }"
  teach_add_context "gitlink_paths: $local_gitlinks"

  gitlinks_allowed=false
  if [ "$PROMOTION_CONTRACT_GITLINK_POLICY" = "pipeline-only" ] && [ "$MODE" = "range" ]; then
    normalized_source_ref="${SOURCE_REF#refs/heads/}"
    normalized_source_ref="${normalized_source_ref#origin/}"
    normalized_base_ref="${BASE_REF#refs/heads/}"
    normalized_base_ref="${normalized_base_ref#origin/}"
    if [ "$normalized_source_ref" = "bot/next-version" ] && [ "$normalized_base_ref" = "dev" ]; then
      gitlinks_allowed=true
    fi
    if [ "$normalized_source_ref" = "dev" ] && [ "$normalized_base_ref" = "stage" ]; then
      gitlinks_allowed=true
    fi
  fi

  if [ "$gitlinks_allowed" = false ]; then
    teach_add_violation "Gitlink changes are present in the inspected diff."
    case "$PROMOTION_CONTRACT_GITLINK_POLICY" in
      forbidden)
        teach_add_resolution "Remove the gitlink changes from this diff. Gitlinks are forbidden in the current promotion contract."
        ;;
      pipeline-only)
        teach_add_resolution "Remove the manual gitlink changes from this diff. Gitlinks are pipeline-owned only and are allowed only for 'bot/next-version -> dev' or subsequent 'dev -> stage' lane propagation."
        ;;
    esac
  fi
fi

if [ "${#CI_SURFACE_PATHS[@]}" -gt 0 ]; then
  for path in "${CI_SURFACE_PATHS[@]}"; do
    classify_ci_surface_path "$path"
  done
fi

if [ "${#CI_TEST_HARNESS_SURFACE_PATHS[@]}" -gt 0 ]; then
  ci_test_paths="$(printf '%s, ' "${CI_TEST_HARNESS_SURFACE_PATHS[@]}")"
  ci_test_paths="${ci_test_paths%, }"
  teach_add_context "ci_test_harness_surface_paths: $ci_test_paths"
fi

if [ "${#CI_CONTROL_PLANE_SURFACE_PATHS[@]}" -gt 0 ]; then
  ci_control_paths="$(printf '%s, ' "${CI_CONTROL_PLANE_SURFACE_PATHS[@]}")"
  ci_control_paths="${ci_control_paths%, }"
  teach_add_context "ci_control_plane_surface_paths: $ci_control_paths"
fi

if [ "${#CI_TEST_HARNESS_SURFACE_PATHS[@]}" -gt 0 ] \
  && [ "$PROMOTION_CONTRACT_CI_TEST_HARNESS_CHANGE_AUTHORIZED" != "true" ] \
  && [ "$PROMOTION_CONTRACT_CI_BEHAVIOR_CHANGE_AUTHORIZED" != "true" ]; then
  teach_add_violation "CI workflow test-harness surfaces changed without explicit authorization."
  teach_add_resolution "Revert CI workflow test-harness changes or regenerate the contract with ci_test_harness_change_authorized=true after explicit user approval."
fi

if [ "${#CI_CONTROL_PLANE_SURFACE_PATHS[@]}" -gt 0 ] && [ "$PROMOTION_CONTRACT_CI_BEHAVIOR_CHANGE_AUTHORIZED" != "true" ]; then
  teach_add_violation "CI workflow control-plane surfaces changed without explicit authorization."
  teach_add_resolution "Revert CI workflow control-plane changes or regenerate the contract with ci_behavior_change_authorized=true after explicit user approval."
fi

if [ "${#PROMOTION_SURFACE_PATHS[@]}" -gt 0 ] && [ "$PROMOTION_CONTRACT_PROMOTION_BEHAVIOR_CHANGE_AUTHORIZED" != "true" ]; then
  teach_add_violation "Promotion automation surfaces changed without explicit authorization."
  teach_add_resolution "Revert local promotion tooling/skill changes or regenerate the contract with promotion_behavior_change_authorized=true after explicit user approval."
  promo_paths="$(printf '%s, ' "${PROMOTION_SURFACE_PATHS[@]}")"
  promo_paths="${promo_paths%, }"
  teach_add_context "promotion_surface_paths: $promo_paths"
fi

if [ "${#CHANGED_PATHS[@]}" -eq 0 ]; then
  teach_add_context "changed_paths: none"
  teach_add_resolution "Proceed. No forbidden diff surfaces were detected."
  teach_emit_ready
  exit 0
fi

if [ "${#TEACH_VIOLATIONS[@]}" -eq 0 ]; then
  changed_paths="$(printf '%s, ' "${CHANGED_PATHS[@]}")"
  changed_paths="${changed_paths%, }"
  teach_add_context "changed_paths: $changed_paths"
  teach_add_resolution "Proceed. The inspected diff matches the active promotion contract."
  teach_emit_ready
  exit 0
fi

teach_add_resolution "Rerun the diff guard and require 'Overall outcome: go' before continuing with commit, push, or PR actions."
teach_emit_blocked
exit 2
