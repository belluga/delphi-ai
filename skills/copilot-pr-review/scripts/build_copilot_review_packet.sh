#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  build_copilot_review_packet.sh --repo-root <path> [--todo <todo_path>] [--base <base_branch>] [--output-dir <dir>] [--include-worktree]
EOF
}

REPO_ROOT=""
TODO_PATH=""
BASE_BRANCH=""
OUTPUT_DIR=""
INCLUDE_WORKTREE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo-root)
      REPO_ROOT="${2:-}"
      shift 2
      ;;
    --todo)
      TODO_PATH="${2:-}"
      shift 2
      ;;
    --base)
      BASE_BRANCH="${2:-}"
      shift 2
      ;;
    --output-dir)
      OUTPUT_DIR="${2:-}"
      shift 2
      ;;
    --include-worktree)
      INCLUDE_WORKTREE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "$REPO_ROOT" ]]; then
  echo "ERROR: --repo-root is required." >&2
  exit 1
fi

REPO_ROOT="$(cd "$REPO_ROOT" && pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

resolve_delphi_root() {
  local candidates=(
    "$REPO_ROOT/delphi-ai"
    "$(cd "$REPO_ROOT/.." 2>/dev/null && pwd)/delphi-ai"
    "$(cd "$SCRIPT_DIR/../../.." 2>/dev/null && pwd)"
  )

  local candidate=""
  for candidate in "${candidates[@]}"; do
    [[ -n "$candidate" ]] || continue
    if [[ -f "$candidate/tools/finding_carry_forward_extract.py" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  return 1
}

DELHI_ROOT="$(resolve_delphi_root)" || {
  echo "ERROR: unable to resolve Delphi root for finding_carry_forward_extract.py" >&2
  exit 1
}
CURRENT_BRANCH="$(git -C "$REPO_ROOT" branch --show-current)"

if [[ -z "$BASE_BRANCH" ]]; then
  case "$CURRENT_BRANCH" in
    reconcile/*|feature/*|bugfix/*)
      BASE_BRANCH="origin/dev"
      ;;
    dev)
      BASE_BRANCH="origin/stage"
      ;;
    stage)
      BASE_BRANCH="origin/main"
      ;;
    *)
      BASE_BRANCH="origin/dev"
      ;;
  esac
fi

if [[ -z "$OUTPUT_DIR" ]]; then
  OUTPUT_DIR="$(mktemp -d "/tmp/copilot-pr-review-XXXXXX")"
fi

mkdir -p "$OUTPUT_DIR"

MERGE_BASE="$(git -C "$REPO_ROOT" merge-base "$BASE_BRANCH" HEAD)"
ROOT_PACKET="$OUTPUT_DIR/review-packet.md"
ROOT_DIFFSTAT="$OUTPUT_DIR/root.diffstat.txt"
ROOT_NAMEONLY="$OUTPUT_DIR/root.changed-files.txt"
ROOT_DIFF="$OUTPUT_DIR/root.diff.txt"

if (( INCLUDE_WORKTREE != 0 )); then
  DIFF_LABEL="${BASE_BRANCH}..WORKTREE"
  git -C "$REPO_ROOT" diff --stat "$BASE_BRANCH" > "$ROOT_DIFFSTAT"
  git -C "$REPO_ROOT" diff --name-only "$BASE_BRANCH" > "$ROOT_NAMEONLY"
  git -C "$REPO_ROOT" diff --unified=3 "$BASE_BRANCH" > "$ROOT_DIFF"
else
  DIFF_LABEL="${MERGE_BASE}..HEAD"
  git -C "$REPO_ROOT" diff --stat "$MERGE_BASE..HEAD" > "$ROOT_DIFFSTAT"
  git -C "$REPO_ROOT" diff --name-only "$MERGE_BASE..HEAD" > "$ROOT_NAMEONLY"
  git -C "$REPO_ROOT" diff --unified=3 "$MERGE_BASE..HEAD" > "$ROOT_DIFF"
fi

instruction_path_exists() {
  local repo="$1"
  local rev="$2"
  local path="$3"
  git -C "$repo" cat-file -e "${rev}:${path}" 2>/dev/null
}

write_instructions_block() {
  local repo="$1"
  local rev="$2"
  local path="$3"
  local label="$4"
  if instruction_path_exists "$repo" "$rev" "$path"; then
    {
      echo "## ${label}"
      echo
      git -C "$repo" show "${rev}:${path}" | head -c 4000
      echo
      echo
    } >> "$ROOT_PACKET"
  fi
}

{
  echo "# Copilot PR Review Packet"
  echo
  echo "- Generated at: $(date -Iseconds)"
  echo "- Repo root: $REPO_ROOT"
  echo "- Current branch: $CURRENT_BRANCH"
  echo "- Review base: $BASE_BRANCH"
  echo "- Merge base: $MERGE_BASE"
  echo "- Diff selection: $DIFF_LABEL"
  if [[ -n "$TODO_PATH" ]]; then
    echo "- Governing TODO: $TODO_PATH"
  fi
  echo
  echo "## Root Diff Summary"
  echo
  cat "$ROOT_DIFFSTAT"
  echo
  echo "## Root Changed Files"
  echo
  sed 's/^/- /' "$ROOT_NAMEONLY"
  echo
  echo "## Copilot Excluded File Hints"
  echo
  if rg -n '(^|/)(package\.json|pnpm-lock\.yaml|package-lock\.json|yarn\.lock|Gemfile\.lock|.*\.log|.*\.svg)$' "$ROOT_NAMEONLY" >/dev/null 2>&1; then
    rg -n '(^|/)(package\.json|pnpm-lock\.yaml|package-lock\.json|yarn\.lock|Gemfile\.lock|.*\.log|.*\.svg)$' "$ROOT_NAMEONLY"
  else
    echo "- none detected"
  fi
  echo
  echo "## CI / Workflow Surface Hints"
  echo
  if rg -n '(^|/)\.github/workflows/|(^|/)tools/flutter/web_app_tests/|(^|/)scripts/|(^|/)integration_test/|(^|/)test/' "$ROOT_NAMEONLY" >/dev/null 2>&1; then
    rg -n '(^|/)\.github/workflows/|(^|/)tools/flutter/web_app_tests/|(^|/)scripts/|(^|/)integration_test/|(^|/)test/' "$ROOT_NAMEONLY"
  else
    echo "- none detected"
  fi
  echo
} > "$ROOT_PACKET"

write_instructions_block "$REPO_ROOT" "$BASE_BRANCH" ".github/copilot-instructions.md" "Base-Branch Copilot Instructions"

mapfile -t path_instruction_files < <(git -C "$REPO_ROOT" ls-tree -r --name-only "$BASE_BRANCH" | rg '^\.github/instructions/.*\.instructions\.md$' || true)
if [[ "${#path_instruction_files[@]}" -gt 0 ]]; then
  {
    echo "## Base-Branch Path Instructions"
    echo
    for path in "${path_instruction_files[@]}"; do
      echo "### $path"
      git -C "$REPO_ROOT" show "${BASE_BRANCH}:${path}" | head -c 4000
      echo
      echo
    done
  } >> "$ROOT_PACKET"
fi

mapfile -t changed_gitlinks < <(if (( INCLUDE_WORKTREE != 0 )); then
  git -C "$REPO_ROOT" diff --submodule=short --name-only "$BASE_BRANCH"
else
  git -C "$REPO_ROOT" diff --submodule=short --name-only "$MERGE_BASE..HEAD"
fi | while read -r path; do
  [[ -n "$path" ]] || continue
  if git -C "$REPO_ROOT" config -f .gitmodules --get-regexp path | awk '{print $2}' | grep -Fx "$path" >/dev/null 2>&1; then
    echo "$path"
  fi
done)

if [[ "${#changed_gitlinks[@]}" -gt 0 ]]; then
  {
    echo "## Submodule Producer Diffs"
    echo
    for submodule_path in "${changed_gitlinks[@]}"; do
      submodule_repo="$REPO_ROOT/$submodule_path"
      if [[ ! -d "$submodule_repo/.git" && ! -f "$submodule_repo/.git" ]]; then
        echo "### $submodule_path"
        echo "- submodule checkout not present locally"
        echo
        continue
      fi
      submodule_branch="$(git -C "$submodule_repo" branch --show-current)"
      submodule_base="$BASE_BRANCH"
      if ! git -C "$submodule_repo" rev-parse --verify "$submodule_base" >/dev/null 2>&1; then
        submodule_base="origin/dev"
      fi
      submodule_merge_base="$(git -C "$submodule_repo" merge-base "$submodule_base" HEAD)"
      echo "### $submodule_path"
      echo "- current branch: $submodule_branch"
      echo "- review base: $submodule_base"
      echo "- merge base: $submodule_merge_base"
      echo
      git -C "$submodule_repo" diff --stat "$submodule_merge_base..HEAD"
      echo
    done
  } >> "$ROOT_PACKET"
fi

if [[ -n "$TODO_PATH" ]]; then
  CARRY_FORWARD_MD="$OUTPUT_DIR/finding-carry-forward.md"
  CARRY_FORWARD_JSON="$OUTPUT_DIR/finding-carry-forward.json"
  python3 "$DELHI_ROOT/tools/finding_carry_forward_extract.py" \
    --todo "$TODO_PATH" \
    --json-output "$CARRY_FORWARD_JSON" \
    --markdown-output "$CARRY_FORWARD_MD" >/dev/null
  if [[ -s "$CARRY_FORWARD_MD" ]]; then
    cat "$CARRY_FORWARD_MD" >> "$ROOT_PACKET"
    echo >> "$ROOT_PACKET"
  fi
fi

echo "$ROOT_PACKET"
