#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: github_stage_promotion_preflight.sh --source <ref> [--repo <path>] [--base <ref>] [--require-diff-shape <any|submodule-only>]

Run the deterministic first-PR preflight for the GitHub Stage Promotion Orchestrator.
This helper is a TEACH runtime blocker: objective git checks trigger it, exit code `2`
enforces the stop, and the printed response is meant to become the next correction prompt.
The response carries:
- `rule_id`
- `violation`
- `resolution_prompt`
- `context`
- `Overall outcome`

Options:
  --source <ref>                       Source branch/ref that would be promoted first.
  --repo <path>                        Repository to inspect. Defaults to current directory.
  --base <ref>                         Authoritative base ref that the source must contain. Defaults to origin/dev.
  --require-diff-shape <shape>         Optional additional diff-shape gate. Supported: any, submodule-only.
  -h, --help                           Show this help text.

Exit codes:
  0  GO: source branch is promotion-ready for the requested base/diff-shape gate.
  2  NO-GO: deterministic TEACH blocker found; follow the emitted `resolution_prompt` before promoting.
  1  Operational error (not a git repo, missing refs, command failure, etc.).
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

REPO_INPUT="."
SOURCE_REF=""
BASE_REF="origin/dev"
REQUIRE_DIFF_SHAPE="any"

while [ $# -gt 0 ]; do
  case "$1" in
    --repo)
      [ $# -ge 2 ] || die "missing value for --repo"
      REPO_INPUT="$2"
      shift 2
      ;;
    --source)
      [ $# -ge 2 ] || die "missing value for --source"
      SOURCE_REF="$2"
      shift 2
      ;;
    --base)
      [ $# -ge 2 ] || die "missing value for --base"
      BASE_REF="$2"
      shift 2
      ;;
    --require-diff-shape)
      [ $# -ge 2 ] || die "missing value for --require-diff-shape"
      REQUIRE_DIFF_SHAPE="$2"
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

[ -n "$SOURCE_REF" ] || die "--source is required"

case "$REQUIRE_DIFF_SHAPE" in
  any|submodule-only) ;;
  *) die "unsupported --require-diff-shape value: $REQUIRE_DIFF_SHAPE" ;;
esac

REPO_ROOT="$(git -C "$REPO_INPUT" rev-parse --show-toplevel 2>/dev/null || true)"
[ -n "$REPO_ROOT" ] || die "path is not inside a git repository: $REPO_INPUT"

repo_git() {
  git -C "$REPO_ROOT" "$@"
}

resolve_commit() {
  repo_git rev-parse --verify "$1^{commit}" 2>/dev/null || true
}

short_ref_name() {
  local ref="$1"
  repo_git rev-parse --abbrev-ref "$ref" 2>/dev/null || printf '%s' "$ref"
}

print_commit_list() {
  local range="$1"
  local limit="$2"
  local lines

  lines="$(repo_git log --oneline --reverse "$range" 2>/dev/null | sed -n "1,${limit}p" || true)"
  if [ -z "$lines" ]; then
    printf '  - none\n'
    return
  fi

  while IFS= read -r line; do
    [ -n "$line" ] || continue
    printf '  - %s\n' "$line"
  done <<< "$lines"
}

print_response_list() {
  local indent="$1"
  shift
  local items=("$@")

  if [ "${#items[@]}" -eq 0 ]; then
    printf '%s- none\n' "$indent"
    return
  fi

  local item
  for item in "${items[@]}"; do
    printf '%s- %s\n' "$indent" "$item"
  done
}

print_context_commit_list() {
  local indent="$1"
  local range="$2"
  local limit="$3"
  local lines

  lines="$(repo_git log --oneline --reverse "$range" 2>/dev/null | sed -n "1,${limit}p" || true)"
  if [ -z "$lines" ]; then
    printf '%s- none\n' "$indent"
    return
  fi

  while IFS= read -r line; do
    [ -n "$line" ] || continue
    printf '%s- %s\n' "$indent" "$line"
  done <<< "$lines"
}

repo_git fetch origin --prune --quiet

SOURCE_SHA="$(resolve_commit "$SOURCE_REF")"
[ -n "$SOURCE_SHA" ] || die "unable to resolve source ref: $SOURCE_REF"

BASE_SHA="$(resolve_commit "$BASE_REF")"
[ -n "$BASE_SHA" ] || die "unable to resolve base ref: $BASE_REF"

CURRENT_BRANCH="$(repo_git symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
if [ -z "$CURRENT_BRANCH" ]; then
  CURRENT_BRANCH="DETACHED"
fi

SOURCE_SHORT="$(short_ref_name "$SOURCE_REF")"
BASE_SHORT="$(short_ref_name "$BASE_REF")"

WORKTREE_DIRTY=false
if [ -n "$(repo_git status --porcelain)" ]; then
  WORKTREE_DIRTY=true
fi

MERGE_BASE_SHA="$(repo_git merge-base "$SOURCE_SHA" "$BASE_SHA")"
read -r BASE_ONLY_COUNT SOURCE_ONLY_COUNT <<< "$(repo_git rev-list --left-right --count "$BASE_SHA...$SOURCE_SHA")"

LINEAGE_READY=true
if ! repo_git merge-base --is-ancestor "$BASE_SHA" "$SOURCE_SHA"; then
  LINEAGE_READY=false
fi

SOURCE_HAS_DIFF=true
if repo_git diff --quiet "$BASE_SHA..$SOURCE_SHA" --; then
  SOURCE_HAS_DIFF=false
fi

DIFF_SHAPE_READY=true
declare -a DIFF_SHAPE_BLOCKERS=()
if [ "$REQUIRE_DIFF_SHAPE" = "submodule-only" ] && [ "$SOURCE_HAS_DIFF" = true ]; then
  while IFS= read -r path; do
    [ -n "$path" ] || continue
    base_mode="$(repo_git ls-tree "$BASE_SHA" -- "$path" | awk '{print $1}' | head -n 1)"
    source_mode="$(repo_git ls-tree "$SOURCE_SHA" -- "$path" | awk '{print $1}' | head -n 1)"

    if [ "$base_mode" = "160000" ] || [ "$source_mode" = "160000" ]; then
      continue
    fi

    DIFF_SHAPE_READY=false
    DIFF_SHAPE_BLOCKERS+=("$path")
  done < <(repo_git diff --name-only "$BASE_SHA..$SOURCE_SHA" --)
fi

WORKTREE_READY=true
if [ "$CURRENT_BRANCH" = "$SOURCE_SHORT" ] && [ "$WORKTREE_DIRTY" = true ]; then
  WORKTREE_READY=false
fi

OVERALL_GO=true
if [ "$WORKTREE_READY" = false ] || [ "$LINEAGE_READY" = false ] || [ "$SOURCE_HAS_DIFF" = false ] || [ "$DIFF_SHAPE_READY" = false ]; then
  OVERALL_GO=false
fi

declare -a VIOLATIONS=()
declare -a RESOLUTION_PROMPTS=()
declare -a NEXT_PROMPTS=()

if [ "$WORKTREE_READY" = false ]; then
  VIOLATIONS+=("The checked-out source branch '$SOURCE_SHORT' has uncommitted local changes.")
  RESOLUTION_PROMPTS+=("Clean '$SOURCE_SHORT' first: commit, stash, or discard the local changes before promotion.")
fi

if [ "$LINEAGE_READY" = false ]; then
  VIOLATIONS+=("Source '$SOURCE_REF' does not contain the current base tip '$BASE_REF'.")
  RESOLUTION_PROMPTS+=("Update '$SOURCE_SHORT' so it contains '$BASE_REF' before opening the first promotion PR.")
  RESOLUTION_PROMPTS+=("Fast path: git fetch origin --prune && git checkout '$SOURCE_SHORT' && git rebase '$BASE_REF'.")
  RESOLUTION_PROMPTS+=("Fallback when rebase is not desirable: create a fresh branch from '$BASE_REF' and cherry-pick only the source-only commits listed in context.")
fi

if [ "$SOURCE_HAS_DIFF" = false ]; then
  VIOLATIONS+=("Source '$SOURCE_REF' has no promotable diff beyond '$BASE_REF'.")
  RESOLUTION_PROMPTS+=("Do not open a promotion PR from '$SOURCE_REF' until it contains a real diff beyond '$BASE_REF'.")
fi

if [ "$DIFF_SHAPE_READY" = false ]; then
  VIOLATIONS+=("Source '$SOURCE_REF' failed the diff-shape requirement '$REQUIRE_DIFF_SHAPE'.")
  RESOLUTION_PROMPTS+=("Recreate or repair the branch so the diff matches '$REQUIRE_DIFF_SHAPE' before promotion.")
fi

printf 'GitHub Stage Promotion Preflight\n'
printf 'Repository root: %s\n' "$REPO_ROOT"
printf 'Current branch: %s\n' "$CURRENT_BRANCH"
printf 'Source ref: %s\n' "$SOURCE_REF"
printf 'Source sha: %s\n' "$SOURCE_SHA"
printf 'Base ref: %s\n' "$BASE_REF"
printf 'Base sha: %s\n' "$BASE_SHA"
printf 'Merge base: %s\n' "$MERGE_BASE_SHA"
printf '\n'

printf 'Preflight summary\n'
printf '  - worktree clean for source branch: %s\n' "$([ "$WORKTREE_READY" = true ] && printf yes || printf no)"
printf '  - source contains base tip: %s\n' "$([ "$LINEAGE_READY" = true ] && printf yes || printf no)"
printf '  - source has promotable diff beyond base: %s\n' "$([ "$SOURCE_HAS_DIFF" = true ] && printf yes || printf no)"
printf '  - diff shape requirement (%s): %s\n' "$REQUIRE_DIFF_SHAPE" "$([ "$DIFF_SHAPE_READY" = true ] && printf pass || printf fail)"
printf '  - base-only commits missing from source: %s\n' "$BASE_ONLY_COUNT"
printf '  - source-only commits beyond base: %s\n' "$SOURCE_ONLY_COUNT"
printf '\n'

if [ "$OVERALL_GO" = true ]; then
  NEXT_PROMPTS+=("Continue with the promotion skill and capture the live PR/check evidence snapshot next.")
  NEXT_PROMPTS+=("Optional follow-up: bash delphi-ai/tools/github_stage_promotion_snapshot.sh --branch $SOURCE_SHORT")

  printf 'TEACH runtime response\n'
  printf 'status: ready\n'
  printf 'enforcement: allow_first_pr\n'
  printf 'rule_id: paced.github-stage-promotion.preflight\n'
  printf 'violation:\n'
  printf '  - none\n'
  printf 'resolution_prompt:\n'
  print_response_list '  ' "${NEXT_PROMPTS[@]}"
  printf 'context:\n'
  printf '  source_ref: %s\n' "$SOURCE_REF"
  printf '  source_sha: %s\n' "$SOURCE_SHA"
  printf '  base_ref: %s\n' "$BASE_REF"
  printf '  base_sha: %s\n' "$BASE_SHA"
  printf '  merge_base: %s\n' "$MERGE_BASE_SHA"
  printf '  source_contains_base_tip: yes\n'
  printf '  source_has_promotable_diff: yes\n'
  printf '  diff_shape_requirement: %s\n' "$REQUIRE_DIFF_SHAPE"
  printf '  diff_shape_ready: yes\n'
  printf '  worktree_clean_for_source: %s\n' "$([ "$WORKTREE_READY" = true ] && printf yes || printf no)"
  printf '\nOverall outcome: go\n'
  exit 0
fi

RESOLUTION_PROMPTS+=("Rerun the preflight and require 'Overall outcome: go' before the first promotion PR: bash delphi-ai/tools/github_stage_promotion_preflight.sh --source $SOURCE_REF --base $BASE_REF --require-diff-shape $REQUIRE_DIFF_SHAPE")

printf 'TEACH runtime response\n'
printf 'status: blocked\n'
printf 'enforcement: stop_before_first_pr\n'
printf 'rule_id: paced.github-stage-promotion.preflight\n'
printf 'violation:\n'
print_response_list '  ' "${VIOLATIONS[@]}"
printf 'resolution_prompt:\n'
print_response_list '  ' "${RESOLUTION_PROMPTS[@]}"
printf 'context:\n'
printf '  source_ref: %s\n' "$SOURCE_REF"
printf '  source_sha: %s\n' "$SOURCE_SHA"
printf '  base_ref: %s\n' "$BASE_REF"
printf '  base_sha: %s\n' "$BASE_SHA"
printf '  merge_base: %s\n' "$MERGE_BASE_SHA"
printf '  source_contains_base_tip: %s\n' "$([ "$LINEAGE_READY" = true ] && printf yes || printf no)"
printf '  source_has_promotable_diff: %s\n' "$([ "$SOURCE_HAS_DIFF" = true ] && printf yes || printf no)"
printf '  diff_shape_requirement: %s\n' "$REQUIRE_DIFF_SHAPE"
printf '  diff_shape_ready: %s\n' "$([ "$DIFF_SHAPE_READY" = true ] && printf yes || printf no)"
printf '  worktree_clean_for_source: %s\n' "$([ "$WORKTREE_READY" = true ] && printf yes || printf no)"
printf '  base_only_commits_missing_from_source_count: %s\n' "$BASE_ONLY_COUNT"
printf '  source_only_commits_beyond_base_count: %s\n' "$SOURCE_ONLY_COUNT"
printf '  base_only_commits_missing_from_source:\n'
print_context_commit_list '    ' "$SOURCE_SHA..$BASE_SHA" 20
printf '  source_only_commits_beyond_base:\n'
print_context_commit_list '    ' "$BASE_SHA..$SOURCE_SHA" 20
if [ "$DIFF_SHAPE_READY" = false ]; then
  printf '  diff_shape_blockers:\n'
  print_response_list '    ' "${DIFF_SHAPE_BLOCKERS[@]}"
fi

printf '\nOverall outcome: no-go\n'
exit 2
