#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/teach_runtime.sh"
source "$SCRIPT_DIR/lib/promotion_contract.sh"

usage() {
  cat <<'EOF'
Usage: github_promotion_action_guard.sh --contract <path> --action <git-commit|git-push|pr-create|pr-merge> [options]

Validate whether a proposed local promotion-lane action is allowed under the current
promotion contract before mutating git or GitHub state.

Options:
  --repo-kind <docker|flutter|laravel|docs|other>  Repository kind. Default: other.
  --branch <name>                                  Branch involved in git commit/push actions.
  --target-branch <name>                           Explicit remote target branch for git push actions.
  --head <name>                                    PR head branch.
  --base <dev|stage|main>                          PR base branch.
  --repo-slug <owner/name>                         GitHub repository slug for PR actions.
  --pr <number>                                    PR number for merge actions.
  -h, --help                                       Show this help text.
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

CONTRACT_PATH=""
ACTION=""
REPO_KIND="other"
BRANCH_NAME=""
TARGET_BRANCH=""
HEAD_BRANCH=""
BASE_BRANCH=""
REPO_SLUG=""
PR_NUMBER=""

while [ $# -gt 0 ]; do
  case "$1" in
    --contract)
      [ $# -ge 2 ] || die "missing value for --contract"
      CONTRACT_PATH="$2"
      shift 2
      ;;
    --action)
      [ $# -ge 2 ] || die "missing value for --action"
      ACTION="$2"
      shift 2
      ;;
    --repo-kind)
      [ $# -ge 2 ] || die "missing value for --repo-kind"
      REPO_KIND="$2"
      shift 2
      ;;
    --branch)
      [ $# -ge 2 ] || die "missing value for --branch"
      BRANCH_NAME="$2"
      shift 2
      ;;
    --target-branch)
      [ $# -ge 2 ] || die "missing value for --target-branch"
      TARGET_BRANCH="$2"
      shift 2
      ;;
    --head)
      [ $# -ge 2 ] || die "missing value for --head"
      HEAD_BRANCH="$2"
      shift 2
      ;;
    --base)
      [ $# -ge 2 ] || die "missing value for --base"
      BASE_BRANCH="$2"
      shift 2
      ;;
    --repo-slug)
      [ $# -ge 2 ] || die "missing value for --repo-slug"
      REPO_SLUG="$2"
      shift 2
      ;;
    --pr)
      [ $# -ge 2 ] || die "missing value for --pr"
      PR_NUMBER="$2"
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
[ -n "$ACTION" ] || die "--action is required"

case "$ACTION" in
  git-commit|git-push|pr-create|pr-merge) ;;
  *) die "unsupported --action value: $ACTION" ;;
esac

case "$REPO_KIND" in
  docker|flutter|laravel|docs|other) ;;
  *) die "unsupported --repo-kind value: $REPO_KIND" ;;
esac

normalize_branch_name() {
  local branch_name="$1"
  branch_name="${branch_name#refs/heads/}"
  printf '%s' "$branch_name"
}

branch_is_lane_branch() {
  case "$1" in
    dev|stage|main)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

if [ -n "$BRANCH_NAME" ]; then
  BRANCH_NAME="$(normalize_branch_name "$BRANCH_NAME")"
fi
if [ -n "$TARGET_BRANCH" ]; then
  TARGET_BRANCH="$(normalize_branch_name "$TARGET_BRANCH")"
fi
if [ -n "$HEAD_BRANCH" ]; then
  HEAD_BRANCH="$(normalize_branch_name "$HEAD_BRANCH")"
fi
if [ -n "$BASE_BRANCH" ]; then
  BASE_BRANCH="$(normalize_branch_name "$BASE_BRANCH")"
fi

promotion_contract_load "$CONTRACT_PATH"

teach_runtime_begin "paced.github-promotion.action" "stop_before_mutating_action"

teach_add_context "action: $ACTION"
teach_add_context "repo_kind: $REPO_KIND"
teach_add_context "scope: $PROMOTION_CONTRACT_SCOPE"
teach_add_context "max_lane: $PROMOTION_CONTRACT_MAX_LANE"
teach_add_context "bot_next_version_policy: $PROMOTION_CONTRACT_BOT_NEXT_VERSION_POLICY"
teach_add_context "docs_remote_promotion: $PROMOTION_CONTRACT_DOCS_REMOTE_PROMOTION"

if [ -n "$BRANCH_NAME" ]; then
  teach_add_context "branch: $BRANCH_NAME"
fi
if [ -n "$TARGET_BRANCH" ]; then
  teach_add_context "target_branch: $TARGET_BRANCH"
fi
if [ -n "$HEAD_BRANCH" ]; then
  teach_add_context "head: $HEAD_BRANCH"
fi
if [ -n "$BASE_BRANCH" ]; then
  teach_add_context "base: $BASE_BRANCH"
fi
if [ -n "$REPO_SLUG" ]; then
  teach_add_context "repo_slug: $REPO_SLUG"
fi
if [ -n "$PR_NUMBER" ]; then
  teach_add_context "pr: $PR_NUMBER"
fi

is_bot_branch=false
case "${TARGET_BRANCH:-${BRANCH_NAME:-${HEAD_BRANCH:-}}}" in
  bot/next-version)
    is_bot_branch=true
    ;;
esac

if [ "$is_bot_branch" = true ]; then
  case "$PROMOTION_CONTRACT_BOT_NEXT_VERSION_POLICY" in
    forbidden)
      teach_add_violation "The contract forbids any action involving 'bot/next-version'."
      teach_add_resolution "Do not use 'bot/next-version' in this promotion scope. Continue only with the explicitly allowed non-gitlink lane actions."
      ;;
    pipeline-owned-only)
      teach_add_violation "The contract treats 'bot/next-version' as pipeline-owned only."
      teach_add_resolution "Do not create, push, or merge 'bot/next-version' manually. Wait for the pipeline-owned branch to exist in the authorized stage flow."
      ;;
  esac
fi

if [ "$ACTION" = "git-commit" ] && branch_is_lane_branch "${BRANCH_NAME:-}"; then
  teach_add_violation "Direct local commits on lane branch '$BRANCH_NAME' are forbidden."
  teach_add_resolution "Create or switch to the authoritative source branch for the change. Lane branches must move only through PR merges."
fi

if [ "$ACTION" = "git-push" ] && branch_is_lane_branch "${BRANCH_NAME:-}"; then
  teach_add_violation "Direct pushes from lane branch '$BRANCH_NAME' are forbidden."
  teach_add_resolution "Do not push lane branches directly. Push the authoritative source branch and move '$BRANCH_NAME' only through the reviewed PR path."
fi

if [ "$ACTION" = "git-push" ] && branch_is_lane_branch "${TARGET_BRANCH:-}"; then
  teach_add_violation "Direct pushes targeting lane branch '$TARGET_BRANCH' are forbidden."
  teach_add_resolution "Do not push to '$TARGET_BRANCH' directly. Open or advance the reviewed PR path for that lane instead."
fi

if [ -n "$BASE_BRANCH" ]; then
  case "$PROMOTION_CONTRACT_MAX_LANE:$BASE_BRANCH" in
    dev:stage|dev:main|stage:main)
      teach_add_violation "Base branch '$BASE_BRANCH' exceeds the maximum authorized lane '$PROMOTION_CONTRACT_MAX_LANE'."
      teach_add_resolution "Do not open or merge promotion PRs beyond the contract scope. Regenerate the contract with a broader scope only after explicit user approval."
      ;;
  esac
fi

if [ "$REPO_KIND" = "docs" ] && [ -n "$BASE_BRANCH" ] && [ "$BASE_BRANCH" = "main" ] && [ "$PROMOTION_CONTRACT_DOCS_REMOTE_PROMOTION" = "forbidden" ]; then
  teach_add_violation "Remote documentation promotion to 'main' is forbidden by the current contract."
  teach_add_resolution "Keep docs changes local only for this session. Do not open or merge a docs PR until the user explicitly authorizes remote docs promotion."
fi

if [ "${#TEACH_VIOLATIONS[@]}" -eq 0 ]; then
  teach_add_resolution "Proceed. The requested action is within the current promotion contract."
  teach_emit_ready
  exit 0
fi

teach_add_resolution "Rerun the action guard and require 'Overall outcome: go' before executing the underlying git or GitHub command."
teach_emit_blocked
exit 2
