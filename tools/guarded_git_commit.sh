#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Usage: guarded_git_commit.sh --contract <path> [--repo-kind <docker|flutter|laravel|docs|other>] -- [git commit args...]

Run git commit only after the promotion action guard and staged diff guard both return
`Overall outcome: go`.
EOF
}

CONTRACT_PATH=""
REPO_KIND="other"

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

current_branch="$(git rev-parse --abbrev-ref HEAD)"

"$SCRIPT_DIR/github_promotion_action_guard.sh" \
  --contract "$CONTRACT_PATH" \
  --action git-commit \
  --repo-kind "$REPO_KIND" \
  --branch "$current_branch"

"$SCRIPT_DIR/github_promotion_diff_guard.sh" \
  --contract "$CONTRACT_PATH" \
  --mode staged

git commit "$@"
