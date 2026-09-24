#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Usage: guarded_git_push.sh --contract <path> --base-ref <ref> [--repo-kind <docker|flutter|laravel|docs|other>] [--branch <name>] -- [git push args...]

Run git push only after the promotion action guard and range diff guard both return
`Overall outcome: go`.
EOF
}

CONTRACT_PATH=""
REPO_KIND="other"
BASE_REF=""
BRANCH_NAME=""

normalize_branch_name() {
  local branch_name="$1"
  branch_name="${branch_name#+}"
  branch_name="${branch_name#refs/heads/}"
  printf '%s' "$branch_name"
}

parse_refspec_target() {
  local refspec="$1"
  local target_branch

  refspec="${refspec#+}"
  if [[ "$refspec" == *:* ]]; then
    target_branch="${refspec#*:}"
  else
    target_branch="$refspec"
  fi

  target_branch="$(normalize_branch_name "$target_branch")"
  case "$target_branch" in
    ""|HEAD)
      return 1
      ;;
  esac

  printf '%s' "$target_branch"
}

extract_target_branch() {
  local args=("$@")
  local index token candidate

  for ((index = 0; index < ${#args[@]}; index++)); do
    token="${args[$index]}"
    case "$token" in
      --set-upstream|-u)
        if [ $((index + 2)) -lt ${#args[@]} ]; then
          candidate="$(parse_refspec_target "${args[$((index + 2))]}")" || true
          if [ -n "$candidate" ]; then
            printf '%s' "$candidate"
            return 0
          fi
        fi
        index=$((index + 2))
        ;;
      --delete)
        if [ $((index + 1)) -lt ${#args[@]} ]; then
          candidate="$(parse_refspec_target "${args[$((index + 1))]}")" || true
          if [ -n "$candidate" ]; then
            printf '%s' "$candidate"
            return 0
          fi
        fi
        index=$((index + 1))
        ;;
      -*)
        ;;
      origin|upstream)
        ;;
      https://*|ssh://*|git@*)
        ;;
      *)
        candidate="$(parse_refspec_target "$token")" || true
        if [ -n "$candidate" ]; then
          printf '%s' "$candidate"
          return 0
        fi
        ;;
    esac
  done

  return 1
}

while [ $# -gt 0 ]; do
  case "$1" in
    --contract)
      CONTRACT_PATH="$2"
      shift 2
      ;;
    --repo-kind)
      REPO_KIND="$2"
      shift 2
      ;;
    --base-ref)
      BASE_REF="$2"
      shift 2
      ;;
    --branch)
      BRANCH_NAME="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Error: unknown argument: %s\n' "$1" >&2
      exit 1
      ;;
  esac
done

[ -n "$CONTRACT_PATH" ] || { printf 'Error: --contract is required\n' >&2; exit 1; }
[ -n "$BASE_REF" ] || { printf 'Error: --base-ref is required\n' >&2; exit 1; }

if [ -z "$BRANCH_NAME" ]; then
  BRANCH_NAME="$(git rev-parse --abbrev-ref HEAD)"
fi

PUSH_ARGS=("$@")
TARGET_BRANCH="$(extract_target_branch "${PUSH_ARGS[@]}" || true)"
if [ -z "$TARGET_BRANCH" ]; then
  TARGET_BRANCH="$BRANCH_NAME"
fi

"$SCRIPT_DIR/github_promotion_action_guard.sh" \
  --contract "$CONTRACT_PATH" \
  --action git-push \
  --repo-kind "$REPO_KIND" \
  --branch "$BRANCH_NAME" \
  --target-branch "$TARGET_BRANCH"

"$SCRIPT_DIR/github_promotion_diff_guard.sh" \
  --contract "$CONTRACT_PATH" \
  --mode range \
  --base-ref "$BASE_REF" \
  --source-ref HEAD

git push "${PUSH_ARGS[@]}"
