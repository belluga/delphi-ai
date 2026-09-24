#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: github_stage_promotion_snapshot.sh [--repo <owner/name>] [--pr <number>] [--branch <name>]

Collect a deterministic local/remote snapshot for the GitHub Stage Promotion Orchestrator skill.
This helper does not perform promotion; it only inventories the current branch, candidate PR, and check state.
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

REPO_SLUG=""
PR_NUMBER=""
BRANCH_NAME=""

while [ $# -gt 0 ]; do
  case "$1" in
    --repo)
      [ $# -ge 2 ] || die "missing value for --repo"
      REPO_SLUG="$2"
      shift 2
      ;;
    --pr)
      [ $# -ge 2 ] || die "missing value for --pr"
      PR_NUMBER="$2"
      shift 2
      ;;
    --branch)
      [ $# -ge 2 ] || die "missing value for --branch"
      BRANCH_NAME="$2"
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

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  LOCAL_REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  LOCAL_REPO_ROOT=""
fi

if [ -z "$BRANCH_NAME" ] && [ -n "$LOCAL_REPO_ROOT" ]; then
  BRANCH_NAME="$(git -C "$LOCAL_REPO_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
fi

if [ -z "$REPO_SLUG" ] && [ -n "$LOCAL_REPO_ROOT" ]; then
  remote_url="$(git -C "$LOCAL_REPO_ROOT" remote get-url origin 2>/dev/null || true)"
  if [ -n "$remote_url" ]; then
    REPO_SLUG="$(printf '%s\n' "$remote_url" | sed -E 's#(git@github.com:|https://github.com/)##; s#\.git$##')"
  fi
fi

printf 'GitHub Stage Promotion Snapshot\n'
printf 'Local repo root: %s\n' "${LOCAL_REPO_ROOT:-not-detected}"
printf 'Repository slug: %s\n' "${REPO_SLUG:-not-detected}"
printf 'Branch: %s\n' "${BRANCH_NAME:-not-detected}"
printf '\n'

if [ -n "$LOCAL_REPO_ROOT" ]; then
  printf 'Local git status\n'
  git -C "$LOCAL_REPO_ROOT" status --short || true
  printf '\n'
fi

if ! command -v gh >/dev/null 2>&1; then
  printf 'Overall outcome: blocked\n'
  printf 'Reason: gh CLI is not available.\n'
  exit 2
fi

if ! gh auth status >/dev/null 2>&1; then
  printf 'Overall outcome: blocked\n'
  printf 'Reason: gh auth status is not healthy.\n'
  exit 2
fi

[ -n "$REPO_SLUG" ] || die "unable to resolve repository slug; pass --repo <owner/name>"

if [ -z "$PR_NUMBER" ] && [ -n "$BRANCH_NAME" ]; then
  PR_NUMBER="$(gh pr list --repo "$REPO_SLUG" --head "$BRANCH_NAME" --state open --json number --template '{{range .}}{{.number}}{{"\n"}}{{end}}' | head -n 1 || true)"
fi

if [ -z "$PR_NUMBER" ]; then
  printf 'PR snapshot\n'
  printf '  - no open PR detected for the current inputs\n\n'
  printf 'Overall outcome: blocked\n'
  printf 'Reason: no candidate PR is currently open.\n'
  exit 2
fi

printf 'PR snapshot\n'
gh pr view "$PR_NUMBER" --repo "$REPO_SLUG" --json number,title,state,isDraft,reviewDecision,headRefName,baseRefName,url --template \
'  - #{{.number}} {{.title}}
  - state: {{.state}}
  - draft: {{.isDraft}}
  - review decision: {{.reviewDecision}}
  - head: {{.headRefName}}
  - base: {{.baseRefName}}
  - url: {{.url}}
' || true
printf '\n'

printf 'Check snapshot\n'
check_output=""
if check_output="$(gh pr checks "$PR_NUMBER" --repo "$REPO_SLUG" 2>&1)"; then
  printf '%s\n' "$check_output"
  printf '\nOverall outcome: ready-for-manual-promotion\n'
  exit 0
fi

printf '%s\n' "$check_output"
printf '\nOverall outcome: review-needed\n'
exit 2
