#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: github_promotion_completion_guard.sh --lane <stage|main> --scenario <docker-only|flutter-only|laravel-only|flutter-laravel> --docker-repo <owner/name> [--flutter-repo <owner/name>] [--laravel-repo <owner/name>] [--web-repo <owner/name>] [--web-pr <number>] [--docker-flutter-path <path>] [--docker-laravel-path <path>]

Run the deterministic end-of-lane guard for GitHub stage/main promotions.
This helper validates whether the lane is truly complete before the operator claims
success. It is a TEACH runtime blocker:
- objective repo/branch/check/submodule evidence triggers it
- exit code `2` enforces the stop when the lane is still incomplete
- `resolution_prompt` tells the operator the exact next step required to finish

Scenario semantics:
  docker-only       Docker lane completion only.
  flutter-only      Flutter lane completion plus required Docker finalization.
  laravel-only      Laravel lane completion plus required Docker finalization.
  flutter-laravel   Flutter + Laravel lane completion plus required Docker finalization.

Lane semantics:
  stage  validates the final `dev -> stage` state.
  main   validates the final `stage -> main` state.

Flutter main note:
  When lane=main and Flutter participates, --web-repo is required because Flutter
  main completion includes downstream web follow-through. Pass --web-pr as well when
  the downstream mechanism is PR-based so the helper can validate that merge too.

Exit codes:
  0  GO: the lane is complete for the requested scenario.
  2  NO-GO: deterministic TEACH blocker found; follow `resolution_prompt`.
  1  Operational error (invalid arguments, missing gh CLI, etc.).
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
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

LANE=""
SCENARIO=""
DOCKER_REPO=""
FLUTTER_REPO=""
LARAVEL_REPO=""
WEB_REPO=""
WEB_PR=""
DOCKER_FLUTTER_PATH="flutter-app"
DOCKER_LARAVEL_PATH="laravel-app"

while [ $# -gt 0 ]; do
  case "$1" in
    --lane)
      [ $# -ge 2 ] || die "missing value for --lane"
      LANE="$2"
      shift 2
      ;;
    --scenario)
      [ $# -ge 2 ] || die "missing value for --scenario"
      SCENARIO="$2"
      shift 2
      ;;
    --docker-repo)
      [ $# -ge 2 ] || die "missing value for --docker-repo"
      DOCKER_REPO="$2"
      shift 2
      ;;
    --flutter-repo)
      [ $# -ge 2 ] || die "missing value for --flutter-repo"
      FLUTTER_REPO="$2"
      shift 2
      ;;
    --laravel-repo)
      [ $# -ge 2 ] || die "missing value for --laravel-repo"
      LARAVEL_REPO="$2"
      shift 2
      ;;
    --web-repo)
      [ $# -ge 2 ] || die "missing value for --web-repo"
      WEB_REPO="$2"
      shift 2
      ;;
    --web-pr)
      [ $# -ge 2 ] || die "missing value for --web-pr"
      WEB_PR="$2"
      shift 2
      ;;
    --docker-flutter-path)
      [ $# -ge 2 ] || die "missing value for --docker-flutter-path"
      DOCKER_FLUTTER_PATH="$2"
      shift 2
      ;;
    --docker-laravel-path)
      [ $# -ge 2 ] || die "missing value for --docker-laravel-path"
      DOCKER_LARAVEL_PATH="$2"
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

[ -n "$LANE" ] || die "--lane is required"
[ -n "$SCENARIO" ] || die "--scenario is required"

case "$LANE" in
  stage)
    SOURCE_BRANCH="dev"
    TARGET_BRANCH="stage"
    ;;
  main)
    SOURCE_BRANCH="stage"
    TARGET_BRANCH="main"
    ;;
  *)
    die "unsupported --lane value: $LANE"
    ;;
esac

EXPECT_FLUTTER=false
EXPECT_LARAVEL=false

case "$SCENARIO" in
  docker-only) ;;
  flutter-only)
    EXPECT_FLUTTER=true
    ;;
  laravel-only)
    EXPECT_LARAVEL=true
    ;;
  flutter-laravel)
    EXPECT_FLUTTER=true
    EXPECT_LARAVEL=true
    ;;
  *)
    die "unsupported --scenario value: $SCENARIO"
    ;;
esac

if ! command -v gh >/dev/null 2>&1; then
  die "gh CLI is required"
fi

declare -a VIOLATIONS=()
declare -a RESOLUTION_PROMPTS=()
declare -a CONTEXT_LINES=()
declare -a READY_PROMPTS=()

declare -A SOURCE_SHA_BY_ROLE=()
declare -A TARGET_SHA_BY_ROLE=()
declare -A CONTAINS_SOURCE_BY_ROLE=()
declare -A COMPARE_STATUS_BY_ROLE=()
declare -A PUSH_RUN_COUNT_BY_ROLE=()
declare -A PUSH_RUNS_GREEN_BY_ROLE=()
declare -A PUSH_RUN_SAMPLE_BY_ROLE=()
declare -A SUBMODULE_SHA_BY_ROLE=()

add_violation() {
  VIOLATIONS+=("$1")
}

add_resolution() {
  RESOLUTION_PROMPTS+=("$1")
}

add_context() {
  CONTEXT_LINES+=("$1")
}

require_argument_teach() {
  local condition="$1"
  local violation="$2"
  local resolution="$3"

  if [ "$condition" != true ]; then
    add_violation "$violation"
    add_resolution "$resolution"
  fi
}

require_argument_teach "$( [ -n "$DOCKER_REPO" ] && printf true || printf false )" \
  "Scenario '$SCENARIO' cannot be claimed complete without --docker-repo because Docker finalization is part of lane completion." \
  "Rerun with --docker-repo <owner/name> and require the Docker target branch to be green before claiming completion."

if [ "$EXPECT_FLUTTER" = true ]; then
  require_argument_teach "$( [ -n "$FLUTTER_REPO" ] && printf true || printf false )" \
    "Scenario '$SCENARIO' requires --flutter-repo so the Flutter lane state can be validated before Docker finalization." \
    "Rerun with --flutter-repo <owner/name> and require the Flutter target branch to contain '$SOURCE_BRANCH' plus green post-merge push runs."
fi

if [ "$EXPECT_LARAVEL" = true ]; then
  require_argument_teach "$( [ -n "$LARAVEL_REPO" ] && printf true || printf false )" \
    "Scenario '$SCENARIO' requires --laravel-repo so the Laravel lane state can be validated before Docker finalization." \
    "Rerun with --laravel-repo <owner/name> and require the Laravel target branch to contain '$SOURCE_BRANCH' plus green post-merge push runs."
fi

if [ "$LANE" = "main" ] && [ "$EXPECT_FLUTTER" = true ]; then
  require_argument_teach "$( [ -n "$WEB_REPO" ] && printf true || printf false )" \
    "Flutter main completion requires downstream web follow-through evidence, but --web-repo was not provided." \
    "Rerun with --web-repo <owner/name>; if the downstream path is PR-based, also pass --web-pr <number> so the merge can be validated deterministically."
fi

if ! gh auth status >/dev/null 2>&1; then
  add_violation "gh auth status is not healthy, so the promotion lane cannot be validated deterministically."
  add_resolution "Repair GitHub CLI authentication first, then rerun this guard."
fi

branch_head_sha() {
  local repo="$1"
  local branch="$2"
  local output=""

  if output="$(gh api "repos/$repo/branches/$branch" --jq '.commit.sha' 2>/dev/null)"; then
    printf '%s' "$output"
  fi
}

compare_summary() {
  local repo="$1"
  local source_sha="$2"
  local target_sha="$3"
  local output=""

  if output="$(gh api "repos/$repo/compare/$source_sha...$target_sha" --jq '[.status // "", (.behind_by | tostring), (.ahead_by | tostring)] | @tsv' 2>/dev/null)"; then
    printf '%s' "$output"
  fi
}

run_list_query() {
  local repo="$1"
  local branch="$2"
  local jq_expr="$3"
  local output=""

  if output="$(gh run list \
    -R "$repo" \
    --branch "$branch" \
    --event push \
    --limit 100 \
    --json databaseId,headSha,status,conclusion,url,workflowName,displayTitle,createdAt \
    --jq "$jq_expr" 2>/dev/null)"; then
    printf '%s' "$output"
  fi
}

validate_push_runs_for_target() {
  local role="$1"
  local repo="$2"
  local branch="$3"
  local sha="$4"
  local human_label="$5"

  local count
  local pending
  local non_success
  local sample

  count="$(run_list_query "$repo" "$branch" "map(select(.headSha == \"$sha\")) | length")"
  pending="$(run_list_query "$repo" "$branch" "map(select(.headSha == \"$sha\" and .status != \"completed\")) | length")"
  non_success="$(run_list_query "$repo" "$branch" "map(select(.headSha == \"$sha\" and (.status != \"completed\" or .conclusion != \"success\"))) | length")"
  sample="$(run_list_query "$repo" "$branch" "map(select(.headSha == \"$sha\")) | .[0] | [(.workflowName // .displayTitle // \"unknown\"), (.status // \"unknown\"), (.conclusion // \"none\"), (.url // \"\")] | @tsv")"

  [ -n "$count" ] || count="0"
  [ -n "$pending" ] || pending="0"
  [ -n "$non_success" ] || non_success="0"
  [ -n "$sample" ] || sample="none\tunknown\tunknown\t"

  if [ "$count" = "0" ]; then
    PUSH_RUN_COUNT_BY_ROLE["$role"]="0"
    PUSH_RUNS_GREEN_BY_ROLE["$role"]="no"
    PUSH_RUN_SAMPLE_BY_ROLE["$role"]="none"
    add_violation "$human_label target branch '$branch' has no push workflow evidence for head '$sha'."
    add_resolution "Wait for the post-merge push workflows on '$repo:$branch' to start and finish green before claiming lane completion."
    return
  fi

  PUSH_RUN_COUNT_BY_ROLE["$role"]="$count"
  PUSH_RUN_SAMPLE_BY_ROLE["$role"]="$sample"

  if [ "$pending" = "0" ] && [ "$non_success" = "0" ]; then
    PUSH_RUNS_GREEN_BY_ROLE["$role"]="yes"
    return
  fi

  PUSH_RUNS_GREEN_BY_ROLE["$role"]="no"
  add_violation "$human_label target branch '$branch' does not have fully green post-merge push workflow runs for head '$sha'."
  add_resolution "Wait for every push workflow on '$repo:$branch' for head '$sha' to complete with conclusion=success before claiming lane completion."
}

validate_lane_repo() {
  local role="$1"
  local repo="$2"
  local human_label="$3"

  local source_sha
  local target_sha
  local compare_line
  local compare_status=""
  local compare_behind=""
  local compare_ahead=""

  source_sha="$(branch_head_sha "$repo" "$SOURCE_BRANCH")"
  target_sha="$(branch_head_sha "$repo" "$TARGET_BRANCH")"

  SOURCE_SHA_BY_ROLE["$role"]="${source_sha:-missing}"
  TARGET_SHA_BY_ROLE["$role"]="${target_sha:-missing}"

  if [ -z "$source_sha" ]; then
    CONTAINS_SOURCE_BY_ROLE["$role"]="unknown"
    PUSH_RUN_COUNT_BY_ROLE["$role"]="0"
    PUSH_RUNS_GREEN_BY_ROLE["$role"]="unknown"
    PUSH_RUN_SAMPLE_BY_ROLE["$role"]="unavailable"
    add_violation "Unable to resolve $human_label source branch '$SOURCE_BRANCH' in '$repo'."
    add_resolution "Repair repository/branch access for '$repo:$SOURCE_BRANCH', then rerun this guard."
    add_context "$human_label | repo=$repo | source_branch=$SOURCE_BRANCH | source_sha=missing | target_branch=$TARGET_BRANCH | target_sha=${target_sha:-missing}"
    return
  fi

  if [ -z "$target_sha" ]; then
    CONTAINS_SOURCE_BY_ROLE["$role"]="unknown"
    PUSH_RUN_COUNT_BY_ROLE["$role"]="0"
    PUSH_RUNS_GREEN_BY_ROLE["$role"]="unknown"
    PUSH_RUN_SAMPLE_BY_ROLE["$role"]="unavailable"
    add_violation "Unable to resolve $human_label target branch '$TARGET_BRANCH' in '$repo'."
    add_resolution "Repair repository/branch access for '$repo:$TARGET_BRANCH', then rerun this guard."
    add_context "$human_label | repo=$repo | source_branch=$SOURCE_BRANCH | source_sha=$source_sha | target_branch=$TARGET_BRANCH | target_sha=missing"
    return
  fi

  compare_line="$(compare_summary "$repo" "$source_sha" "$target_sha")"
  if [ -n "$compare_line" ]; then
    IFS=$'\t' read -r compare_status compare_behind compare_ahead <<< "$compare_line"
  fi

  if [ -z "$compare_status" ] || [ -z "$compare_behind" ]; then
    CONTAINS_SOURCE_BY_ROLE["$role"]="unknown"
    COMPARE_STATUS_BY_ROLE["$role"]="unknown"
    add_violation "Unable to compare '$repo:$TARGET_BRANCH' against '$SOURCE_BRANCH' for $human_label."
    add_resolution "Repair GitHub compare access for '$repo', then rerun this guard."
    add_context "$human_label | repo=$repo | source_branch=$SOURCE_BRANCH | source_sha=$source_sha | target_branch=$TARGET_BRANCH | target_sha=$target_sha | compare_status=missing"
    return
  fi

  COMPARE_STATUS_BY_ROLE["$role"]="$compare_status"
  if [ "$compare_behind" = "0" ]; then
    CONTAINS_SOURCE_BY_ROLE["$role"]="yes"
  else
    CONTAINS_SOURCE_BY_ROLE["$role"]="no"
    add_violation "$human_label target branch '$TARGET_BRANCH' in '$repo' does not yet contain the current '$SOURCE_BRANCH' tip."
    add_resolution "Resume the pending '$SOURCE_BRANCH -> $TARGET_BRANCH' promotion for '$repo' and wait for the post-merge push workflows before claiming lane completion."
  fi

  validate_push_runs_for_target "$role" "$repo" "$TARGET_BRANCH" "$target_sha" "$human_label"

  add_context "$human_label | repo=$repo | source_branch=$SOURCE_BRANCH | source_sha=$source_sha | target_branch=$TARGET_BRANCH | target_sha=$target_sha | target_contains_source=${CONTAINS_SOURCE_BY_ROLE[$role]} | compare_status=$compare_status | push_runs=${PUSH_RUN_COUNT_BY_ROLE[$role]:-0} | push_runs_green=${PUSH_RUNS_GREEN_BY_ROLE[$role]:-unknown} | sample=${PUSH_RUN_SAMPLE_BY_ROLE[$role]:-none}"
}

docker_submodule_sha() {
  local repo="$1"
  local path="$2"
  local commit_sha="$3"
  local tree_sha=""
  local output=""

  if ! tree_sha="$(gh api "repos/$repo/commits/$commit_sha" --jq '.commit.tree.sha' 2>/dev/null)"; then
    return 0
  fi

  if output="$(gh api "repos/$repo/git/trees/$tree_sha" -X GET -f recursive=1 --jq ".tree[] | select(.path == \"$path\") | .sha" 2>/dev/null | head -n 1)"; then
    printf '%s' "$output"
  fi
}

validate_submodule_alignment() {
  local role="$1"
  local human_label="$2"
  local docker_path="$3"

  local expected_sha="${TARGET_SHA_BY_ROLE[$role]:-}"
  local actual_sha

  if [ -z "$expected_sha" ] || [ "$expected_sha" = "missing" ]; then
    add_violation "Cannot validate Docker gitlink for $human_label because the app target SHA is unavailable."
    add_resolution "Repair the $human_label target-branch evidence first, then rerun this guard."
    return
  fi

  actual_sha="$(docker_submodule_sha "$DOCKER_REPO" "$docker_path" "${TARGET_SHA_BY_ROLE[docker]:-}")"
  SUBMODULE_SHA_BY_ROLE["$role"]="${actual_sha:-missing}"

  if [ -z "$actual_sha" ]; then
    add_violation "Unable to resolve Docker path '$docker_path' on '$DOCKER_REPO:$TARGET_BRANCH'."
    add_resolution "Repair the Docker repository access or path configuration, then rerun this guard with the correct submodule path."
    add_context "docker-gitlink-$role | repo=$DOCKER_REPO | branch=$TARGET_BRANCH | path=$docker_path | actual_sha=missing | expected_sha=$expected_sha"
    return
  fi

  if [ "$actual_sha" != "$expected_sha" ]; then
    add_violation "Docker target branch '$TARGET_BRANCH' is not finalized for $human_label: path '$docker_path' points to '$actual_sha' instead of '$expected_sha'."
    add_resolution "Finish the Docker promotion for '$DOCKER_REPO' so '$docker_path' on '$TARGET_BRANCH' points to the $human_label target SHA '$expected_sha', then wait for Docker post-merge push runs to finish green."
  fi

  add_context "docker-gitlink-$role | repo=$DOCKER_REPO | branch=$TARGET_BRANCH | path=$docker_path | actual_sha=$actual_sha | expected_sha=$expected_sha | aligned=$([ "$actual_sha" = "$expected_sha" ] && printf yes || printf no)"
}

validate_green_branch_only() {
  local role="$1"
  local repo="$2"
  local branch="$3"
  local human_label="$4"

  local sha
  sha="$(branch_head_sha "$repo" "$branch")"

  TARGET_SHA_BY_ROLE["$role"]="${sha:-missing}"

  if [ -z "$sha" ]; then
    PUSH_RUN_COUNT_BY_ROLE["$role"]="0"
    PUSH_RUNS_GREEN_BY_ROLE["$role"]="unknown"
    PUSH_RUN_SAMPLE_BY_ROLE["$role"]="unavailable"
    add_violation "Unable to resolve $human_label branch '$branch' in '$repo'."
    add_resolution "Repair repository/branch access for '$repo:$branch', then rerun this guard."
    add_context "$human_label | repo=$repo | branch=$branch | sha=missing"
    return
  fi

  validate_push_runs_for_target "$role" "$repo" "$branch" "$sha" "$human_label"
  add_context "$human_label | repo=$repo | branch=$branch | sha=$sha | push_runs=${PUSH_RUN_COUNT_BY_ROLE[$role]:-0} | push_runs_green=${PUSH_RUNS_GREEN_BY_ROLE[$role]:-unknown} | sample=${PUSH_RUN_SAMPLE_BY_ROLE[$role]:-none}"
}

validate_web_followthrough() {
  validate_green_branch_only "web" "$WEB_REPO" "main" "Web follow-through"

  if [ -z "$WEB_PR" ]; then
    add_context "web-pr | repo=$WEB_REPO | pr=not-provided | validation=main-branch-green-only"
    return
  fi

  local pr_line
  local pr_state=""
  local pr_merged_at=""
  local pr_base=""
  local pr_url=""

  pr_line="$(gh pr view "$WEB_PR" -R "$WEB_REPO" --json state,mergedAt,baseRefName,url --jq '[.state // "", .mergedAt // "", .baseRefName // "", .url // ""] | @tsv' 2>/dev/null || true)"

  if [ -z "$pr_line" ]; then
    add_violation "Unable to inspect web follow-through PR #$WEB_PR in '$WEB_REPO'."
    add_resolution "Repair access to '$WEB_REPO' or pass the correct --web-pr, then rerun this guard."
    add_context "web-pr | repo=$WEB_REPO | pr=$WEB_PR | state=unavailable"
    return
  fi

  IFS=$'\t' read -r pr_state pr_merged_at pr_base pr_url <<< "$pr_line"

  if [ "$pr_base" != "main" ] || [ -z "$pr_merged_at" ]; then
    add_violation "Web follow-through PR #$WEB_PR in '$WEB_REPO' is not merged into 'main'."
    add_resolution "Wait for the downstream web PR to merge into 'main' and for 'main' push workflows to finish green before claiming Flutter main completion."
  fi

  add_context "web-pr | repo=$WEB_REPO | pr=$WEB_PR | state=${pr_state:-unknown} | merged_at=${pr_merged_at:-missing} | base=${pr_base:-missing} | url=${pr_url:-missing}"
}

printf 'GitHub Promotion Completion Guard\n'
printf 'Lane: %s\n' "$LANE"
printf 'Scenario: %s\n' "$SCENARIO"
printf 'Source branch: %s\n' "$SOURCE_BRANCH"
printf 'Target branch: %s\n' "$TARGET_BRANCH"
printf '\n'

printf 'Requested repos\n'
printf '  - docker: %s\n' "${DOCKER_REPO:-not-provided}"
printf '  - flutter: %s\n' "${FLUTTER_REPO:-not-required}"
printf '  - laravel: %s\n' "${LARAVEL_REPO:-not-required}"
printf '  - web: %s\n' "${WEB_REPO:-not-required}"
if [ -n "$WEB_PR" ]; then
  printf '  - web PR: %s\n' "$WEB_PR"
fi
printf '\n'

if [ "${#VIOLATIONS[@]}" -eq 0 ]; then
  validate_lane_repo "docker" "$DOCKER_REPO" "Docker"

  if [ "$EXPECT_FLUTTER" = true ]; then
    validate_lane_repo "flutter" "$FLUTTER_REPO" "Flutter"
  fi

  if [ "$EXPECT_LARAVEL" = true ]; then
    validate_lane_repo "laravel" "$LARAVEL_REPO" "Laravel"
  fi

  if [ "$EXPECT_FLUTTER" = true ]; then
    validate_submodule_alignment "flutter" "Flutter" "$DOCKER_FLUTTER_PATH"
  fi

  if [ "$EXPECT_LARAVEL" = true ]; then
    validate_submodule_alignment "laravel" "Laravel" "$DOCKER_LARAVEL_PATH"
  fi

  if [ "$LANE" = "main" ] && [ "$EXPECT_FLUTTER" = true ]; then
    validate_web_followthrough
  fi
fi

printf 'Validation summary\n'
print_response_list '  ' "${CONTEXT_LINES[@]}"
printf '\n'

if [ "${#VIOLATIONS[@]}" -eq 0 ]; then
  READY_PROMPTS+=("Lane '$LANE' is complete for scenario '$SCENARIO'.")
  READY_PROMPTS+=("You may record completion evidence and continue with the next explicitly approved workflow step.")

  printf 'TEACH runtime response\n'
  printf 'status: ready\n'
  printf 'enforcement: allow_completion_claim\n'
  printf 'rule_id: paced.github-promotion.completion\n'
  printf 'violation:\n'
  printf '  - none\n'
  printf 'resolution_prompt:\n'
  print_response_list '  ' "${READY_PROMPTS[@]}"
  printf 'context:\n'
  printf '  lane: %s\n' "$LANE"
  printf '  scenario: %s\n' "$SCENARIO"
  printf '  source_branch: %s\n' "$SOURCE_BRANCH"
  printf '  target_branch: %s\n' "$TARGET_BRANCH"
  printf '  repo_health:\n'
  print_response_list '    ' "${CONTEXT_LINES[@]}"
  printf '\nOverall outcome: go\n'
  exit 0
fi

RERUN_COMMAND="bash delphi-ai/tools/github_promotion_completion_guard.sh --lane $LANE --scenario $SCENARIO --docker-repo $DOCKER_REPO"
if [ -n "$FLUTTER_REPO" ]; then
  RERUN_COMMAND="$RERUN_COMMAND --flutter-repo $FLUTTER_REPO"
fi
if [ -n "$LARAVEL_REPO" ]; then
  RERUN_COMMAND="$RERUN_COMMAND --laravel-repo $LARAVEL_REPO"
fi
if [ -n "$WEB_REPO" ]; then
  RERUN_COMMAND="$RERUN_COMMAND --web-repo $WEB_REPO"
fi
if [ -n "$WEB_PR" ]; then
  RERUN_COMMAND="$RERUN_COMMAND --web-pr $WEB_PR"
fi

RESOLUTION_PROMPTS+=("Rerun the completion guard and require 'Overall outcome: go' before claiming the promotion lane is finished: $RERUN_COMMAND")

printf 'TEACH runtime response\n'
printf 'status: blocked\n'
printf 'enforcement: stop_before_completion_claim\n'
printf 'rule_id: paced.github-promotion.completion\n'
printf 'violation:\n'
print_response_list '  ' "${VIOLATIONS[@]}"
printf 'resolution_prompt:\n'
print_response_list '  ' "${RESOLUTION_PROMPTS[@]}"
printf 'context:\n'
printf '  lane: %s\n' "$LANE"
printf '  scenario: %s\n' "$SCENARIO"
printf '  source_branch: %s\n' "$SOURCE_BRANCH"
printf '  target_branch: %s\n' "$TARGET_BRANCH"
printf '  repo_health:\n'
print_response_list '    ' "${CONTEXT_LINES[@]}"
printf '\nOverall outcome: no-go\n'
exit 2
