#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Usage: guarded_pr_create.sh --contract <path> --repo-slug <owner/name> --base <branch> --head <branch> --base-ref <ref> [--repo-kind <docker|flutter|laravel|docs|other>] -- [additional gh pr create args...]

Run gh pr create only after the promotion action guard and range diff guard both return
`Overall outcome: go`.
EOF
}

CONTRACT_PATH=""
REPO_KIND="other"
REPO_SLUG=""
BASE_BRANCH=""
HEAD_BRANCH=""
BASE_REF=""

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
    --repo-slug)
      REPO_SLUG="$2"
      shift 2
      ;;
    --base)
      BASE_BRANCH="$2"
      shift 2
      ;;
    --head)
      HEAD_BRANCH="$2"
      shift 2
      ;;
    --base-ref)
      BASE_REF="$2"
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
[ -n "$REPO_SLUG" ] || { printf 'Error: --repo-slug is required\n' >&2; exit 1; }
[ -n "$BASE_BRANCH" ] || { printf 'Error: --base is required\n' >&2; exit 1; }
[ -n "$HEAD_BRANCH" ] || { printf 'Error: --head is required\n' >&2; exit 1; }
[ -n "$BASE_REF" ] || { printf 'Error: --base-ref is required\n' >&2; exit 1; }

"$SCRIPT_DIR/github_promotion_action_guard.sh" \
  --contract "$CONTRACT_PATH" \
  --action pr-create \
  --repo-kind "$REPO_KIND" \
  --repo-slug "$REPO_SLUG" \
  --head "$HEAD_BRANCH" \
  --base "$BASE_BRANCH"

"$SCRIPT_DIR/github_promotion_diff_guard.sh" \
  --contract "$CONTRACT_PATH" \
  --mode range \
  --base-ref "$BASE_REF" \
  --source-ref "$HEAD_BRANCH"

gh pr create --repo "$REPO_SLUG" --base "$BASE_BRANCH" --head "$HEAD_BRANCH" "$@"
