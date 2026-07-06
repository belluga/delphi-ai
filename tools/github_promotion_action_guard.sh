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

branch_is_reconcile_branch() {
  case "$1" in
    reconcile/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

branch_is_sequence_branch() {
  case "$1" in
    sequence/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

branch_is_topology_replay_branch() {
  case "$1" in
    reconcile/dev-contains-stage-*)
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

if [ "$ACTION" = "pr-create" ] || [ "$ACTION" = "pr-merge" ]; then
  repo_name="${REPO_SLUG##*/}"
  if [ "$repo_name" = "web-app" ]; then
    teach_add_violation "Generated 'web-app' repositories are derived artifact surfaces and cannot be manually promoted or mutated through this stage promotion guard."
    teach_add_resolution "Fix the authoritative source repository that produced the web artifact, then replay the source lane. Treat the web-app PR only as derived evidence."
  fi
  if branch_is_reconcile_branch "${HEAD_BRANCH:-}" && { ! branch_is_topology_replay_branch "${HEAD_BRANCH:-}" || [ "${BASE_BRANCH:-}" != "dev" ]; }; then
    teach_add_violation "Promotion PR head '$HEAD_BRANCH' is a reconciliation branch. Promotion may not advance directly from reconcile/*."
    teach_add_resolution "Replay the accepted reconcile state onto the canonical version/source branch first, then open the promotion PR from that canonical branch."
  fi
  if branch_is_sequence_branch "${HEAD_BRANCH:-}"; then
    teach_add_violation "Promotion PR head '$HEAD_BRANCH' is a sequencing branch. Promotion may not advance directly from sequence/*."
    teach_add_resolution "Validate the accepted sequence state with the user, replay it onto the canonical version/source branch first, then open the promotion PR from that canonical branch."
  fi
  if branch_is_reconcile_branch "${BASE_BRANCH:-}"; then
    teach_add_violation "Promotion PR base '$BASE_BRANCH' is a reconciliation branch. reconcile/* is orchestration-only topology, not a promotable lane."
    teach_add_resolution "Use the canonical lane branch (dev, stage, or main) as the PR base after the accepted reconcile state has been replayed onto its authoritative source branch."
  fi
  if branch_is_sequence_branch "${BASE_BRANCH:-}"; then
    teach_add_violation "Promotion PR base '$BASE_BRANCH' is a sequencing branch. sequence/* is checkpoint-only topology, not a promotable lane."
    teach_add_resolution "Use the canonical lane branch (dev, stage, or main) as the PR base after the accepted sequence state has been user-validated and replayed onto its authoritative source branch."
  fi
fi

if [ "$is_bot_branch" = true ]; then
  case "$PROMOTION_CONTRACT_BOT_NEXT_VERSION_POLICY" in
    forbidden)
      teach_add_violation "The contract forbids any action involving 'bot/next-version'."
      teach_add_resolution "Do not use 'bot/next-version' in this promotion scope. Continue only with the explicitly allowed non-gitlink lane actions."
      ;;
    pipeline-owned-only)
      case "$ACTION" in
        pr-create|pr-merge)
          if [ "$HEAD_BRANCH" = "bot/next-version" ] && [ "$BASE_BRANCH" != "dev" ]; then
            teach_add_violation "'bot/next-version' PR movement is allowed only as 'bot/next-version -> dev'."
            teach_add_resolution "Do not open or merge 'bot/next-version' directly to '$BASE_BRANCH'. Merge it to 'dev' first, then use the normal 'dev -> stage' lane-to-lane promotion."
          fi
          if [ "$BASE_BRANCH" = "bot/next-version" ]; then
            teach_add_violation "'bot/next-version' cannot be used as a promotion PR base branch."
            teach_add_resolution "Use 'bot/next-version' only as the head branch for the lane-owned submodule PR into 'dev'."
          fi
          ;;
        *)
          teach_add_violation "The contract treats 'bot/next-version' commits and pushes as pipeline-owned only."
          teach_add_resolution "Do not commit or push 'bot/next-version' manually. Wait for the pipeline-owned branch to exist in the authorized stage flow, then move it only through PR create/merge."
          ;;
      esac
      ;;
  esac
fi

if [ "$ACTION" = "git-commit" ] && branch_is_lane_branch "${BRANCH_NAME:-}"; then
  teach_add_violation "Direct local commits on lane branch '$BRANCH_NAME' are forbidden."
  teach_add_resolution "Create or switch to the authoritative source branch for the change. Lane branches must move only through PR merges."
fi

if [ "$ACTION" = "git-commit" ] && branch_is_reconcile_branch "${BRANCH_NAME:-}" && ! branch_is_topology_replay_branch "${BRANCH_NAME:-}"; then
  teach_add_violation "Promotion-lane commits may not happen on reconciliation branch '$BRANCH_NAME'."
  teach_add_resolution "Finish reconcile on reconcile/*, replay the accepted net effect onto the canonical source branch, and continue promotion work from that canonical branch instead."
fi

if [ "$ACTION" = "git-commit" ] && branch_is_sequence_branch "${BRANCH_NAME:-}"; then
  teach_add_violation "Promotion-lane commits may not happen on sequencing branch '$BRANCH_NAME'."
  teach_add_resolution "Finish the sequence lane with user validation, replay the accepted net effect onto the canonical source branch, and continue promotion work from that canonical branch instead."
fi

if [ "$ACTION" = "git-push" ] && branch_is_lane_branch "${BRANCH_NAME:-}"; then
  teach_add_violation "Direct pushes from lane branch '$BRANCH_NAME' are forbidden."
  teach_add_resolution "Do not push lane branches directly. Push the authoritative source branch and move '$BRANCH_NAME' only through the reviewed PR path."
fi

if [ "$ACTION" = "git-push" ] && branch_is_reconcile_branch "${BRANCH_NAME:-}" && ! branch_is_topology_replay_branch "${BRANCH_NAME:-}"; then
  teach_add_violation "Promotion-lane pushes may not originate from reconciliation branch '$BRANCH_NAME'."
  teach_add_resolution "Replay the accepted reconcile state onto the canonical source branch and push that canonical branch instead of reconcile/*."
fi

if [ "$ACTION" = "git-push" ] && branch_is_sequence_branch "${BRANCH_NAME:-}"; then
  teach_add_violation "Promotion-lane pushes may not originate from sequencing branch '$BRANCH_NAME'."
  teach_add_resolution "Replay the accepted sequence state onto the canonical source branch after user validation and push that canonical branch instead of sequence/*."
fi

if [ "$ACTION" = "git-push" ] && branch_is_lane_branch "${TARGET_BRANCH:-}"; then
  teach_add_violation "Direct pushes targeting lane branch '$TARGET_BRANCH' are forbidden."
  teach_add_resolution "Do not push to '$TARGET_BRANCH' directly. Open or advance the reviewed PR path for that lane instead."
fi

if [ "$ACTION" = "git-push" ] && branch_is_reconcile_branch "${TARGET_BRANCH:-}" && ! branch_is_topology_replay_branch "${TARGET_BRANCH:-}"; then
  teach_add_violation "Promotion-lane pushes may not target reconciliation branch '$TARGET_BRANCH'."
  teach_add_resolution "Keep reconcile branches inside orchestration only. Promotion push activity must target the canonical source or remediation branch after replay."
fi

if [ "$ACTION" = "git-push" ] && branch_is_sequence_branch "${TARGET_BRANCH:-}"; then
  teach_add_violation "Promotion-lane pushes may not target sequencing branch '$TARGET_BRANCH'."
  teach_add_resolution "Keep sequence branches inside TODO sequencing only. Promotion push activity must target the canonical source or remediation branch after replay."
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
