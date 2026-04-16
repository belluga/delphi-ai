#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: branch_rebaseline_preflight.sh [--repo <path>] [--apply-safe-local-cleanup] [--rebaseline-dev]

Audit local/remote branches against the Delphi promotion lane policy using ancestry plus patch-equivalence checks, and optionally:
- delete safe local-only merged branches outside the lane;
- switch to local `dev` and align it to `origin/dev` when it is safe.

Options:
  --repo <path>                 Repository to inspect. Defaults to current directory.
  --apply-safe-local-cleanup    Delete eligible local-only merged branches outside the lane.
  --rebaseline-dev              Switch to `dev` and align it to `origin/dev` when safe.
  -h, --help                    Show this help text.

Exit codes:
  0  Audit/actions completed without blockers.
  2  Audit completed, but blockers or unsafe conditions remain.
  1  Operational error (not a git repo, missing origin/dev, command failure, etc.).
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

REPO_INPUT="."
APPLY_SAFE_LOCAL_CLEANUP=false
REBASELINE_DEV=false

while [ $# -gt 0 ]; do
  case "$1" in
    --repo)
      [ $# -ge 2 ] || die "missing value for --repo"
      REPO_INPUT="$2"
      shift 2
      ;;
    --apply-safe-local-cleanup)
      APPLY_SAFE_LOCAL_CLEANUP=true
      shift
      ;;
    --rebaseline-dev)
      REBASELINE_DEV=true
      shift
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

REPO_ROOT="$(git -C "$REPO_INPUT" rev-parse --show-toplevel 2>/dev/null || true)"
[ -n "$REPO_ROOT" ] || die "path is not inside a git repository: $REPO_INPUT"

repo_git() {
  git -C "$REPO_ROOT" "$@"
}

is_local_lane_branch() {
  case "$1" in
    dev|stage|main) return 0 ;;
    *) return 1 ;;
  esac
}

is_remote_lane_branch() {
  case "$1" in
    origin|origin/HEAD|origin/dev|origin/stage|origin/main|origin/bot/next-version) return 0 ;;
    *) return 1 ;;
  esac
}

is_local_anomaly() {
  [ "$1" = "bot/next-version" ]
}

has_live_remote_ref() {
  local upstream="$1"
  [ -n "$upstream" ] || return 1
  repo_git show-ref --verify --quiet "refs/remotes/$upstream"
}

ref_merged_into_origin_dev() {
  local ref="$1"
  repo_git merge-base --is-ancestor "$ref" origin/dev
}

ref_patch_equivalent_to_origin_dev() {
  local ref="$1"
  local cherry_output

  cherry_output="$(repo_git cherry -v origin/dev "$ref" 2>/dev/null || true)"
  [ -n "$cherry_output" ] || return 1

  while IFS= read -r line; do
    [ -n "$line" ] || continue
    case "$line" in
      -*)
        ;;
      *)
        return 1
        ;;
    esac
  done <<< "$cherry_output"

  return 0
}

append_assoc_list() {
  local key="$1"
  local value="$2"
  if [ -n "${REMOTE_TRACKING_LOCALS[$key]:-}" ]; then
    REMOTE_TRACKING_LOCALS["$key"]+=", $value"
  else
    REMOTE_TRACKING_LOCALS["$key"]="$value"
  fi
}

format_yes_no() {
  if [ "$1" = true ]; then
    printf 'yes'
  else
    printf 'no'
  fi
}

format_list() {
  local title="$1"
  shift
  local items=("$@")

  printf '%s\n' "$title"
  if [ "${#items[@]}" -eq 0 ]; then
    printf '  - none\n'
    return
  fi
  local item
  for item in "${items[@]}"; do
    printf '  - %s\n' "$item"
  done
}

repo_git fetch --all --prune --quiet
repo_git show-ref --verify --quiet refs/remotes/origin/dev || die "missing authoritative merge target refs/remotes/origin/dev"

declare -A LOCAL_UPSTREAM=()
declare -A LOCAL_HAS_LIVE_UPSTREAM=()
declare -A LOCAL_IS_CURRENT=()
declare -A SAFE_LOCAL_IS_CURRENT=()
declare -A REMOTE_TRACKING_LOCALS=()

declare -a BLOCKING_BRANCHES=()
declare -a SAFE_LOCAL_CLEANUP_CANDIDATES=()
declare -a LOCAL_ANOMALIES=()
declare -a PATCH_EQUIVALENT_FALSE_POSITIVES=()
declare -a REMOTE_CLEANUP_CANDIDATES=()
declare -a SAFE_LOCAL_CLEANUP_PERFORMED=()
declare -a SAFE_LOCAL_CLEANUP_SKIPPED=()
declare -a SAFE_LOCAL_CLEANUP_FAILED=()
declare -a OPERATION_FLAGS=()

CURRENT_BRANCH="$(repo_git symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
if [ -z "$CURRENT_BRANCH" ]; then
  CURRENT_BRANCH="DETACHED"
fi

STATUS_BRANCH="$(repo_git status --short --branch)"
if [ -n "$(repo_git status --porcelain)" ]; then
  WORKSPACE_DIRTY=true
else
  WORKSPACE_DIRTY=false
fi

GIT_DIR="$(repo_git rev-parse --git-dir)"
if [ -f "$GIT_DIR/MERGE_HEAD" ]; then
  OPERATION_FLAGS+=("merge in progress")
fi
if [ -d "$GIT_DIR/rebase-merge" ] || [ -d "$GIT_DIR/rebase-apply" ]; then
  OPERATION_FLAGS+=("rebase in progress")
fi
if [ -f "$GIT_DIR/CHERRY_PICK_HEAD" ]; then
  OPERATION_FLAGS+=("cherry-pick in progress")
fi
if [ -f "$GIT_DIR/REVERT_HEAD" ]; then
  OPERATION_FLAGS+=("revert in progress")
fi
if [ -f "$GIT_DIR/BISECT_LOG" ]; then
  OPERATION_FLAGS+=("bisect in progress")
fi

while IFS=$'\t' read -r branch upstream; do
  [ -n "$branch" ] || continue

  LOCAL_UPSTREAM["$branch"]="$upstream"
  if has_live_remote_ref "$upstream"; then
    LOCAL_HAS_LIVE_UPSTREAM["$branch"]=true
  else
    LOCAL_HAS_LIVE_UPSTREAM["$branch"]=false
  fi

  if [ "$branch" = "$CURRENT_BRANCH" ]; then
    LOCAL_IS_CURRENT["$branch"]=true
  else
    LOCAL_IS_CURRENT["$branch"]=false
  fi

  if is_local_lane_branch "$branch"; then
    continue
  fi

  local_detail="$branch"
  if [ -n "$upstream" ]; then
    local_detail+=" (upstream: $upstream"
    if [ "${LOCAL_HAS_LIVE_UPSTREAM[$branch]}" = false ]; then
      local_detail+=", remote missing"
    fi
    local_detail+=")"
  else
    local_detail+=" (no upstream)"
  fi
  if [ "${LOCAL_IS_CURRENT[$branch]}" = true ]; then
    local_detail+=" [current]"
  fi

  if is_local_anomaly "$branch"; then
    LOCAL_ANOMALIES+=("$local_detail")
  fi

  if ref_merged_into_origin_dev "$branch"; then
    if [ "${LOCAL_HAS_LIVE_UPSTREAM[$branch]}" = true ]; then
      append_assoc_list "$upstream" "$branch"
    elif ! is_local_anomaly "$branch"; then
      SAFE_LOCAL_CLEANUP_CANDIDATES+=("$branch")
      SAFE_LOCAL_IS_CURRENT["$branch"]="${LOCAL_IS_CURRENT[$branch]}"
    fi
  elif ref_patch_equivalent_to_origin_dev "$branch"; then
    PATCH_EQUIVALENT_FALSE_POSITIVES+=(
      "local: $local_detail (ancestry mismatch; non-merge commits already present in origin/dev)"
    )
    if [ "${LOCAL_HAS_LIVE_UPSTREAM[$branch]}" = true ]; then
      append_assoc_list "$upstream" "$branch"
    elif ! is_local_anomaly "$branch"; then
      SAFE_LOCAL_CLEANUP_CANDIDATES+=("$branch")
      SAFE_LOCAL_IS_CURRENT["$branch"]="${LOCAL_IS_CURRENT[$branch]}"
    fi
  else
    BLOCKING_BRANCHES+=("local: $local_detail")
  fi
done < <(repo_git for-each-ref --sort=refname --format='%(refname:short)%09%(upstream:short)' refs/heads)

while IFS= read -r remote_ref; do
  [ -n "$remote_ref" ] || continue
  if is_remote_lane_branch "$remote_ref"; then
    continue
  fi

  remote_detail="$remote_ref"
  if [ -n "${REMOTE_TRACKING_LOCALS[$remote_ref]:-}" ]; then
    remote_detail+=" (local tracking: ${REMOTE_TRACKING_LOCALS[$remote_ref]})"
  fi

  if ref_merged_into_origin_dev "$remote_ref"; then
    REMOTE_CLEANUP_CANDIDATES+=("$remote_detail")
  elif ref_patch_equivalent_to_origin_dev "$remote_ref"; then
    PATCH_EQUIVALENT_FALSE_POSITIVES+=(
      "remote: $remote_detail (ancestry mismatch; non-merge commits already present in origin/dev)"
    )
    REMOTE_CLEANUP_CANDIDATES+=("$remote_detail")
  else
    BLOCKING_BRANCHES+=("remote: $remote_detail")
  fi
done < <(repo_git for-each-ref --sort=refname --format='%(refname:short)' refs/remotes/origin)

BRANCHES_BLOCKING=false
if [ "${#BLOCKING_BRANCHES[@]}" -gt 0 ]; then
  BRANCHES_BLOCKING=true
fi

cleanup_safe_branches() {
  local phase="$1"
  local branch

  for branch in "${SAFE_LOCAL_CLEANUP_CANDIDATES[@]}"; do
    if [ "$phase" = "pre-switch" ] && [ "${SAFE_LOCAL_IS_CURRENT[$branch]}" = true ]; then
      if [ "$REBASELINE_DEV" = true ]; then
        :
      else
        SAFE_LOCAL_CLEANUP_SKIPPED+=("$branch (current branch; switch away before deleting)")
      fi
      continue
    fi

    if [ "$phase" = "post-switch" ] && [ "${SAFE_LOCAL_IS_CURRENT[$branch]}" != true ]; then
      continue
    fi

    if repo_git branch -d "$branch" >/dev/null 2>&1; then
      SAFE_LOCAL_CLEANUP_PERFORMED+=("$branch")
    else
      SAFE_LOCAL_CLEANUP_FAILED+=("$branch")
    fi
  done
}

if [ "$APPLY_SAFE_LOCAL_CLEANUP" = true ]; then
  cleanup_safe_branches "pre-switch"
fi

REBASELINE_RESULT="not requested"

if [ "$REBASELINE_DEV" = true ]; then
  if [ "$BRANCHES_BLOCKING" = true ]; then
    REBASELINE_RESULT="blocked: non-lane branches not merged into origin/dev remain"
  elif [ "$WORKSPACE_DIRTY" = true ]; then
    REBASELINE_RESULT="blocked: workspace has uncommitted or untracked changes"
  elif [ "${#OPERATION_FLAGS[@]}" -gt 0 ]; then
    REBASELINE_RESULT="blocked: git operation already in progress"
  else
    ORIGINAL_BRANCH="$CURRENT_BRANCH"

    if repo_git show-ref --verify --quiet refs/heads/dev; then
      if [ "$CURRENT_BRANCH" != "dev" ]; then
        repo_git switch dev >/dev/null
      fi
    else
      repo_git switch --track -c dev origin/dev >/dev/null
    fi

    DEV_SHA="$(repo_git rev-parse dev)"
    ORIGIN_DEV_SHA="$(repo_git rev-parse origin/dev)"

    if [ "$DEV_SHA" = "$ORIGIN_DEV_SHA" ]; then
      REBASELINE_RESULT="success: local dev already aligned with origin/dev"
    elif repo_git merge-base --is-ancestor dev origin/dev; then
      repo_git merge --ff-only origin/dev >/dev/null
      REBASELINE_RESULT="success: local dev fast-forwarded to origin/dev"
    elif repo_git merge-base --is-ancestor origin/dev dev; then
      REBASELINE_RESULT="blocked: local dev is ahead of origin/dev"
    else
      REBASELINE_RESULT="blocked: local dev has diverged from origin/dev"
    fi

    if [ "$APPLY_SAFE_LOCAL_CLEANUP" = true ] && [[ "$REBASELINE_RESULT" == success:* ]]; then
      cleanup_safe_branches "post-switch"
    fi

    if [[ "$REBASELINE_RESULT" == success:* ]]; then
      REBASELINE_RESULT+="; repository ready on dev"
      if [ "$ORIGINAL_BRANCH" != "dev" ] && [ "$ORIGINAL_BRANCH" != "DETACHED" ]; then
        REBASELINE_RESULT+=" (started from $ORIGINAL_BRANCH)"
      fi
    fi
  fi
fi

OUTCOME="ready"
if [ "$BRANCHES_BLOCKING" = true ]; then
  OUTCOME="blocked"
fi
if [ "$REBASELINE_DEV" = true ] && [[ "$REBASELINE_RESULT" == blocked:* ]]; then
  OUTCOME="blocked"
fi
if [ "${#SAFE_LOCAL_CLEANUP_FAILED[@]}" -gt 0 ]; then
  OUTCOME="blocked"
fi

printf 'Branch Rebaseline Preflight\n'
printf 'Repository: %s\n' "$REPO_ROOT"
printf 'Authoritative merge target: origin/dev\n'
printf 'Requested safe local cleanup: %s\n' "$(format_yes_no "$APPLY_SAFE_LOCAL_CLEANUP")"
printf 'Requested dev rebaseline: %s\n' "$(format_yes_no "$REBASELINE_DEV")"
printf 'Current branch: %s\n' "$CURRENT_BRANCH"
printf 'Workspace clean: %s\n' "$(format_yes_no "$([ "$WORKSPACE_DIRTY" = false ] && echo true || echo false)")"
printf 'Git operation flags: '
if [ "${#OPERATION_FLAGS[@]}" -eq 0 ]; then
  printf 'none\n'
else
  printf '%s\n' "$(IFS=', '; echo "${OPERATION_FLAGS[*]}")"
fi
printf '\n'
printf 'Workspace status:\n'
while IFS= read -r line; do
  printf '  %s\n' "$line"
done <<< "$STATUS_BRANCH"
printf '\n'

format_list "Blocking branches:" "${BLOCKING_BRANCHES[@]}"
printf '\n'

format_list "Patch-equivalent false positives:" "${PATCH_EQUIVALENT_FALSE_POSITIVES[@]}"
printf '\n'

SAFE_LOCAL_DISPLAY=()
for branch in "${SAFE_LOCAL_CLEANUP_CANDIDATES[@]}"; do
  if [ "${SAFE_LOCAL_IS_CURRENT[$branch]}" = true ]; then
    SAFE_LOCAL_DISPLAY+=("$branch [current]")
  else
    SAFE_LOCAL_DISPLAY+=("$branch")
  fi
done
format_list "Safe local cleanup candidates:" "${SAFE_LOCAL_DISPLAY[@]}"
printf '\n'

format_list "Safe local cleanup performed:" "${SAFE_LOCAL_CLEANUP_PERFORMED[@]}"
printf '\n'

format_list "Safe local cleanup skipped:" "${SAFE_LOCAL_CLEANUP_SKIPPED[@]}"
printf '\n'

format_list "Safe local cleanup failures:" "${SAFE_LOCAL_CLEANUP_FAILED[@]}"
printf '\n'

format_list "Remote cleanup candidates:" "${REMOTE_CLEANUP_CANDIDATES[@]}"
printf '\n'

format_list "Local anomalies:" "${LOCAL_ANOMALIES[@]}"
printf '\n'

printf 'Dev rebaseline result: %s\n' "$REBASELINE_RESULT"
printf 'Outcome: %s\n' "$OUTCOME"

if [ "$OUTCOME" = "blocked" ]; then
  exit 2
fi
