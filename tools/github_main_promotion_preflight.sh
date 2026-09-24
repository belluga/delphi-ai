#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# github_main_promotion_preflight.sh
#
# Deterministic first-PR preflight for the GitHub Main Promotion Orchestrator.
# This is the main-lane counterpart of github_stage_promotion_preflight.sh.
#
# While the stage preflight operates on a single local repository (git checks),
# this main preflight operates on multiple remote repositories via the GitHub
# API (gh CLI) because main promotion spans Docker + app repos.
#
# T.E.A.C.H. compliance:
#   Triggered  – called explicitly before opening the first stage→main PR
#   Enforced   – exit code 2 = NO-GO, exit code 0 = GO
#   Automated  – deterministic shell evaluation once invoked at the main-lane preflight gate
#   Contextual – emits per-repo SHAs, run status, submodule alignment evidence
#   Hinting    – resolution_prompt gives exact next steps to resolve blockers
# ─────────────────────────────────────────────────────────────────────────────

usage() {
  cat <<'EOF'
Usage: github_main_promotion_preflight.sh [--scenario <auto|docker-only|flutter-only|laravel-only|flutter-laravel>] --docker-repo <owner/name> [--flutter-repo <owner/name>] [--laravel-repo <owner/name>] [--web-repo <owner/name>]

Run the deterministic first-PR preflight for the GitHub Main Promotion Orchestrator.
This helper is a TEACH runtime blocker: objective remote-repo checks trigger it,
exit code `2` enforces the stop, and the printed response is meant to become the
next correction prompt.

The response carries:
- `rule_id`
- `violation`
- `resolution_prompt`
- `context`
- `Overall outcome`

Checks performed per pertinent repo:
  1. stage branch exists and resolves to a commit
  2. main branch exists and resolves to a commit
  3. stage-vs-dev drift is recorded for context; it is a hard blocker for Docker, and for app repos it is enforced through Docker gitlink alignment instead of requiring stage to contain the latest dev tip
  4. stage has a promotable diff beyond main
  5. Post-merge push runs on stage are green for the current head
  6. Docker submodule gitlinks on stage point to correct app-repo stage SHAs
  7. Scenario is inferred objectively from Docker stage gitlinks: an app repo is pertinent only when the Docker stage gitlink SHA is not already contained in that app's main history
  8. (Flutter main) --web-repo is provided when Flutter participates

Options:
  --scenario <scenario>          Optional. One of: auto, docker-only, flutter-only, laravel-only, flutter-laravel.
                                 Omit or pass auto to infer the scenario from Docker stage gitlinks.
                                 Any explicit scenario is treated as an assertion and must match the inferred scenario.
  --docker-repo <owner/name>     Required. Docker repository (always part of lane completion).
  --flutter-repo <owner/name>    Required when scenario includes Flutter.
  --laravel-repo <owner/name>    Required when scenario includes Laravel.
  --web-repo <owner/name>        Required when Flutter participates (web follow-through evidence).
  --docker-flutter-path <path>   Submodule path for Flutter inside Docker. Default: flutter-app.
  --docker-laravel-path <path>   Submodule path for Laravel inside Docker. Default: laravel-app.
  -h, --help                     Show this help text.

Exit codes:
  0  GO: all pertinent repos are ready for stage→main promotion.
  2  NO-GO: deterministic TEACH blocker found; follow the emitted `resolution_prompt`.
  1  Operational error (missing gh CLI, auth failure, invalid arguments, etc.).
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

# ── Argument parsing ─────────────────────────────────────────────────────────

SCENARIO=""
DOCKER_REPO=""
FLUTTER_REPO=""
LARAVEL_REPO=""
WEB_REPO=""
DOCKER_FLUTTER_PATH="flutter-app"
DOCKER_LARAVEL_PATH="laravel-app"
WORKSPACE_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

while [ $# -gt 0 ]; do
  case "$1" in
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

# ── Validation ───────────────────────────────────────────────────────────────

[ -n "$SCENARIO" ] || SCENARIO="auto"
[ -n "$DOCKER_REPO" ] || die "--docker-repo is required"

REQUESTED_SCENARIO="$SCENARIO"
INFERRED_SCENARIO=""
EXPECT_FLUTTER=false
EXPECT_LARAVEL=false
FLUTTER_REPO_EFFECTIVE="$FLUTTER_REPO"
LARAVEL_REPO_EFFECTIVE="$LARAVEL_REPO"

case "$SCENARIO" in
  auto) ;;
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

if ! gh auth status >/dev/null 2>&1; then
  die "gh auth status is not healthy; repair GitHub CLI authentication first"
fi

# ── State ────────────────────────────────────────────────────────────────────

declare -a VIOLATIONS=()
declare -a RESOLUTION_PROMPTS=()
declare -a CONTEXT_LINES=()

declare -A DEV_SHA_BY_ROLE=()
declare -A STAGE_SHA_BY_ROLE=()
declare -A MAIN_SHA_BY_ROLE=()
declare -A STAGE_CONTAINS_DEV_BY_ROLE=()
declare -A STAGE_HAS_DIFF_VS_MAIN_BY_ROLE=()
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

# ── Helper functions ─────────────────────────────────────────────────────────

repo_slug_from_url() {
  local url="$1"
  local slug=""

  case "$url" in
    git@github.com:*)
      slug="${url#git@github.com:}"
      ;;
    ssh://git@github.com/*)
      slug="${url#ssh://git@github.com/}"
      ;;
    https://github.com/*)
      slug="${url#https://github.com/}"
      ;;
    http://github.com/*)
      slug="${url#http://github.com/}"
      ;;
    *)
      return 0
      ;;
  esac

  slug="${slug%.git}"
  if [[ "$slug" =~ ^[^/]+/[^/]+$ ]]; then
    printf '%s' "$slug"
  fi
}

repo_slug_from_gitmodules_path() {
  local path="$1"
  local key=""
  local name=""
  local url=""

  if [ ! -f "$WORKSPACE_ROOT/.gitmodules" ]; then
    return 0
  fi

  key="$(
    git -C "$WORKSPACE_ROOT" config -f "$WORKSPACE_ROOT/.gitmodules" --get-regexp '^submodule\..*\.path$' 2>/dev/null \
      | awk -v target="$path" '$2 == target { print $1; exit }'
  )"

  if [ -z "$key" ]; then
    return 0
  fi

  name="${key#submodule.}"
  name="${name%.path}"
  url="$(git -C "$WORKSPACE_ROOT" config -f "$WORKSPACE_ROOT/.gitmodules" --get "submodule.$name.url" 2>/dev/null || true)"
  repo_slug_from_url "$url"
}

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
  local base_sha="$2"
  local head_sha="$3"
  local output=""

  if output="$(gh api "repos/$repo/compare/$base_sha...$head_sha" --jq '[.status // "", (.behind_by | tostring), (.ahead_by | tostring)] | @tsv' 2>/dev/null)"; then
    printf '%s' "$output"
  fi
}

run_list_query() {
  local repo="$1"
  local branch="$2"
  local jq_expr="$3"
  local output=""

  # `gh run list --branch <branch> --event push` has returned false-empty
  # results for valid push runs in some CLI/API combinations. Query Actions
  # runs directly and keep the branch/event filtering in jq so the main
  # preflight still requires green stage push-run evidence.
  if output="$(gh api "repos/$repo/actions/runs?per_page=100" \
    --jq ".workflow_runs
      | map(
          select(.event == \"push\" and .head_branch == \"$branch\")
          | {
              databaseId: .id,
              headSha: .head_sha,
              status: .status,
              conclusion: .conclusion,
              url: .html_url,
              workflowName: .name,
              displayTitle: .display_title,
              createdAt: .created_at
            }
        )
      | $jq_expr" 2>/dev/null)"; then
    printf '%s' "$output"
  fi
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

configure_expectations_for_scenario() {
  local scenario="$1"

  EXPECT_FLUTTER=false
  EXPECT_LARAVEL=false

  case "$scenario" in
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
      die "unsupported effective scenario value: $scenario"
      ;;
  esac
}

role_main_containment_status() {
  local role="$1"
  local repo="$2"
  local docker_path="$3"
  local docker_stage_sha="$4"
  local actual_sha=""
  local main_sha=""
  local compare_line=""
  local compare_status=""
  local compare_behind=""
  local compare_ahead=""
  local human_label=""

  case "$role" in
    flutter) human_label="Flutter" ;;
    laravel) human_label="Laravel" ;;
    *) die "unsupported role for containment status: $role" ;;
  esac

  actual_sha="$(docker_submodule_sha "$DOCKER_REPO" "$docker_path" "$docker_stage_sha")"
  SUBMODULE_SHA_BY_ROLE["$role"]="${actual_sha:-missing}"

  if [ -z "$actual_sha" ]; then
    printf 'absent'
    return 0
  fi

  if [ -z "$repo" ]; then
    add_violation "Docker stage pins $human_label gitlink '$docker_path' at '$actual_sha', but no $human_label repository slug is available for objective stage→main scenario inference."
    add_resolution "Pass --${role}-repo <owner/name> or keep '.gitmodules' available with the canonical '$docker_path' URL so the preflight can infer whether $human_label is already promoted to main."
    add_context "scenario-$role | repo=missing | stage_gitlink_sha=$actual_sha | main_contains_stage_gitlink=unknown | pertinent=unknown"
    printf 'unknown'
    return 0
  fi

  main_sha="$(branch_head_sha "$repo" "main")"
  if [ -z "$main_sha" ]; then
    add_violation "Unable to resolve $human_label 'main' branch in '$repo' while inferring the stage→main repo set."
    add_resolution "Repair repository/branch access for '$repo:main', then rerun this preflight."
    add_context "scenario-$role | repo=$repo | stage_gitlink_sha=$actual_sha | app_main_sha=missing | main_contains_stage_gitlink=unknown | pertinent=unknown"
    printf 'unknown'
    return 0
  fi

  compare_line="$(compare_summary "$repo" "$actual_sha" "$main_sha")"
  if [ -z "$compare_line" ]; then
    add_violation "Unable to compare Docker stage gitlink '$actual_sha' against $human_label main head '$main_sha' in '$repo'."
    add_resolution "Repair GitHub compare access for '$repo', then rerun this preflight."
    add_context "scenario-$role | repo=$repo | stage_gitlink_sha=$actual_sha | app_main_sha=$main_sha | main_contains_stage_gitlink=unknown | pertinent=unknown"
    printf 'unknown'
    return 0
  fi

  IFS=$'\t' read -r compare_status compare_behind compare_ahead <<< "$compare_line"
  if [ "${compare_behind:-}" = "0" ]; then
    add_context "scenario-$role | repo=$repo | stage_gitlink_sha=$actual_sha | app_main_sha=$main_sha | main_contains_stage_gitlink=yes | pertinent=no"
    printf 'not-pertinent'
    return 0
  fi

  add_context "scenario-$role | repo=$repo | stage_gitlink_sha=$actual_sha | app_main_sha=$main_sha | main_contains_stage_gitlink=no | pertinent=yes"
  printf 'pertinent'
}

infer_main_scenario() {
  local docker_stage_sha=""
  local flutter_status=""
  local laravel_status=""
  local pertinent_count=0

  docker_stage_sha="$(branch_head_sha "$DOCKER_REPO" "stage")"
  STAGE_SHA_BY_ROLE["docker"]="${docker_stage_sha:-missing}"

  if [ -z "$docker_stage_sha" ]; then
    add_violation "Unable to resolve Docker 'stage' branch in '$DOCKER_REPO', so the stage→main scenario cannot be inferred objectively."
    add_resolution "Repair repository/branch access for '$DOCKER_REPO:stage', then rerun this preflight."
    add_context "scenario-inference | docker_repo=$DOCKER_REPO | docker_stage_sha=missing | inferred_scenario=unknown"
    return 1
  fi

  flutter_status="$(role_main_containment_status "flutter" "$FLUTTER_REPO_EFFECTIVE" "$DOCKER_FLUTTER_PATH" "$docker_stage_sha")"
  laravel_status="$(role_main_containment_status "laravel" "$LARAVEL_REPO_EFFECTIVE" "$DOCKER_LARAVEL_PATH" "$docker_stage_sha")"

  case "$flutter_status" in
    unknown) return 1 ;;
    pertinent) pertinent_count=$((pertinent_count + 1)) ;;
  esac

  case "$laravel_status" in
    unknown) return 1 ;;
    pertinent) pertinent_count=$((pertinent_count + 1)) ;;
  esac

  if [ "$flutter_status" = "pertinent" ] && [ "$laravel_status" = "pertinent" ]; then
    INFERRED_SCENARIO="flutter-laravel"
  elif [ "$flutter_status" = "pertinent" ]; then
    INFERRED_SCENARIO="flutter-only"
  elif [ "$laravel_status" = "pertinent" ]; then
    INFERRED_SCENARIO="laravel-only"
  else
    INFERRED_SCENARIO="docker-only"
  fi

  add_context "scenario-inference | docker_repo=$DOCKER_REPO | docker_stage_sha=$docker_stage_sha | flutter=$flutter_status | laravel=$laravel_status | inferred_scenario=$INFERRED_SCENARIO"
  return 0
}

resolve_effective_repo_inputs() {
  if [ -z "$FLUTTER_REPO_EFFECTIVE" ]; then
    FLUTTER_REPO_EFFECTIVE="$(repo_slug_from_gitmodules_path "$DOCKER_FLUTTER_PATH")"
  fi

  if [ -z "$LARAVEL_REPO_EFFECTIVE" ]; then
    LARAVEL_REPO_EFFECTIVE="$(repo_slug_from_gitmodules_path "$DOCKER_LARAVEL_PATH")"
  fi
}

# ── Scenario inference and argument checks (TEACH-style) ────────────────────

resolve_effective_repo_inputs
infer_main_scenario || true

if [ -z "$INFERRED_SCENARIO" ]; then
  INFERRED_SCENARIO="unknown"
elif [ "$REQUESTED_SCENARIO" != "auto" ] && [ "$REQUESTED_SCENARIO" != "$INFERRED_SCENARIO" ]; then
  add_violation "Explicit scenario '$REQUESTED_SCENARIO' does not match the objectively inferred stage→main scenario '$INFERRED_SCENARIO'."
  add_resolution "Rerun with '--scenario auto' or '--scenario $INFERRED_SCENARIO'. The main-lane repo set must be derived from Docker stage gitlinks rather than TODO narrative."
fi

if [ "$INFERRED_SCENARIO" != "unknown" ]; then
  SCENARIO="$INFERRED_SCENARIO"
  configure_expectations_for_scenario "$SCENARIO"
fi

if [ "$EXPECT_FLUTTER" = true ] && [ -z "$FLUTTER_REPO_EFFECTIVE" ]; then
  add_violation "Scenario '$SCENARIO' requires Flutter repo evidence, but no Flutter repository slug is available."
  add_resolution "Pass --flutter-repo <owner/name> or keep '.gitmodules' available with the canonical '$DOCKER_FLUTTER_PATH' URL."
fi

if [ "$EXPECT_LARAVEL" = true ] && [ -z "$LARAVEL_REPO_EFFECTIVE" ]; then
  add_violation "Scenario '$SCENARIO' requires Laravel repo evidence, but no Laravel repository slug is available."
  add_resolution "Pass --laravel-repo <owner/name> or keep '.gitmodules' available with the canonical '$DOCKER_LARAVEL_PATH' URL."
fi

if [ "$EXPECT_FLUTTER" = true ] && [ -z "$WEB_REPO" ]; then
  add_violation "Flutter main promotion requires downstream web follow-through evidence, but --web-repo was not provided."
  add_resolution "Rerun with --web-repo <owner/name> so the preflight can confirm web-app readiness for Flutter main completion."
fi

# ── Per-repo validation ─────────────────────────────────────────────────────

validate_repo_stage_health() {
  local role="$1"
  local repo="$2"
  local human_label="$3"

  local dev_sha stage_sha main_sha
  local compare_line compare_status compare_behind compare_ahead

  # Resolve branch SHAs
  dev_sha="$(branch_head_sha "$repo" "dev")"
  stage_sha="$(branch_head_sha "$repo" "stage")"
  main_sha="$(branch_head_sha "$repo" "main")"

  DEV_SHA_BY_ROLE["$role"]="${dev_sha:-missing}"
  STAGE_SHA_BY_ROLE["$role"]="${stage_sha:-missing}"
  MAIN_SHA_BY_ROLE["$role"]="${main_sha:-missing}"

  if [ -z "$stage_sha" ]; then
    add_violation "Unable to resolve $human_label 'stage' branch in '$repo'."
    add_resolution "Repair repository/branch access for '$repo:stage', then rerun this preflight."
    add_context "$human_label | repo=$repo | stage_sha=missing"
    STAGE_CONTAINS_DEV_BY_ROLE["$role"]="unknown"
    STAGE_HAS_DIFF_VS_MAIN_BY_ROLE["$role"]="unknown"
    PUSH_RUN_COUNT_BY_ROLE["$role"]="0"
    PUSH_RUNS_GREEN_BY_ROLE["$role"]="unknown"
    return
  fi

  if [ -z "$main_sha" ]; then
    add_violation "Unable to resolve $human_label 'main' branch in '$repo'."
    add_resolution "Repair repository/branch access for '$repo:main', then rerun this preflight."
    add_context "$human_label | repo=$repo | stage_sha=$stage_sha | main_sha=missing"
    STAGE_CONTAINS_DEV_BY_ROLE["$role"]="unknown"
    STAGE_HAS_DIFF_VS_MAIN_BY_ROLE["$role"]="unknown"
    PUSH_RUN_COUNT_BY_ROLE["$role"]="0"
    PUSH_RUNS_GREEN_BY_ROLE["$role"]="unknown"
    return
  fi

  # Check 1: capture stage-vs-dev drift.
  # Docker keeps the hard upstream-health requirement because it is the final
  # replay/finalization lane. App repos may still be promotable to main when
  # Docker stage already pins their exact stage SHA for the package, even if
  # dev has moved ahead with unrelated later work.
  if [ -n "$dev_sha" ]; then
    compare_line="$(compare_summary "$repo" "$dev_sha" "$stage_sha")"
    if [ -n "$compare_line" ]; then
      IFS=$'\t' read -r compare_status compare_behind compare_ahead <<< "$compare_line"
      if [ "${compare_behind:-}" = "0" ]; then
        STAGE_CONTAINS_DEV_BY_ROLE["$role"]="yes"
      else
        STAGE_CONTAINS_DEV_BY_ROLE["$role"]="no"
        if [ "$role" = "docker" ]; then
          add_violation "$human_label 'stage' in '$repo' does not contain the current 'dev' tip (behind by ${compare_behind} commits)."
          add_resolution "Complete the pending dev→stage promotion for '$repo' before attempting stage→main. Use github-stage-promotion-orchestrator."
        fi
      fi
    else
      STAGE_CONTAINS_DEV_BY_ROLE["$role"]="unknown"
      add_violation "Unable to compare $human_label 'dev' vs 'stage' in '$repo'."
      add_resolution "Repair GitHub compare access for '$repo', then rerun this preflight."
    fi
  else
    STAGE_CONTAINS_DEV_BY_ROLE["$role"]="unknown"
    add_violation "Unable to resolve $human_label 'dev' branch in '$repo' to verify upstream health."
    add_resolution "Repair repository/branch access for '$repo:dev', then rerun this preflight."
  fi

  # Check 2: stage has promotable diff beyond main
  compare_line="$(compare_summary "$repo" "$main_sha" "$stage_sha")"
  if [ -n "$compare_line" ]; then
    IFS=$'\t' read -r compare_status compare_behind compare_ahead <<< "$compare_line"
    if [ "${compare_ahead:-0}" != "0" ]; then
      STAGE_HAS_DIFF_VS_MAIN_BY_ROLE["$role"]="yes"
    else
      STAGE_HAS_DIFF_VS_MAIN_BY_ROLE["$role"]="no"
      add_violation "$human_label 'stage' in '$repo' has no promotable diff beyond 'main'."
      add_resolution "Do not open a stage→main PR for '$repo' until stage contains commits beyond main."
    fi
  else
    STAGE_HAS_DIFF_VS_MAIN_BY_ROLE["$role"]="unknown"
    add_violation "Unable to compare $human_label 'main' vs 'stage' in '$repo'."
    add_resolution "Repair GitHub compare access for '$repo', then rerun this preflight."
  fi

  # Check 3: post-merge push runs on stage are green
  local count pending non_success sample
  count="$(run_list_query "$repo" "stage" "map(select(.headSha == \"$stage_sha\")) | length")"
  pending="$(run_list_query "$repo" "stage" "map(select(.headSha == \"$stage_sha\" and .status != \"completed\")) | length")"
  non_success="$(run_list_query "$repo" "stage" "map(select(.headSha == \"$stage_sha\" and (.status != \"completed\" or .conclusion != \"success\"))) | length")"
  sample="$(run_list_query "$repo" "stage" "map(select(.headSha == \"$stage_sha\")) | .[0] | [(.workflowName // .displayTitle // \"unknown\"), (.status // \"unknown\"), (.conclusion // \"none\"), (.url // \"\")] | @tsv")"

  [ -n "$count" ] || count="0"
  [ -n "$pending" ] || pending="0"
  [ -n "$non_success" ] || non_success="0"
  [ -n "$sample" ] || sample="none\tunknown\tunknown\t"

  PUSH_RUN_COUNT_BY_ROLE["$role"]="$count"
  PUSH_RUN_SAMPLE_BY_ROLE["$role"]="$sample"

  if [ "$count" = "0" ]; then
    PUSH_RUNS_GREEN_BY_ROLE["$role"]="no"
    add_violation "$human_label 'stage' in '$repo' has no push workflow evidence for head '$stage_sha'."
    add_resolution "Wait for post-merge push workflows on '$repo:stage' to start and finish green before attempting stage→main."
  elif [ "$pending" = "0" ] && [ "$non_success" = "0" ]; then
    PUSH_RUNS_GREEN_BY_ROLE["$role"]="yes"
  else
    PUSH_RUNS_GREEN_BY_ROLE["$role"]="no"
    add_violation "$human_label 'stage' in '$repo' does not have fully green post-merge push runs for head '$stage_sha'."
    add_resolution "Wait for every push workflow on '$repo:stage' for head '$stage_sha' to complete with conclusion=success before attempting stage→main."
  fi

  add_context "$human_label | repo=$repo | dev_sha=${dev_sha:-missing} | stage_sha=$stage_sha | main_sha=$main_sha | stage_contains_dev=${STAGE_CONTAINS_DEV_BY_ROLE[$role]} | stage_has_diff_vs_main=${STAGE_HAS_DIFF_VS_MAIN_BY_ROLE[$role]} | push_runs=$count | push_runs_green=${PUSH_RUNS_GREEN_BY_ROLE[$role]} | sample=${PUSH_RUN_SAMPLE_BY_ROLE[$role]:-none}"
}

validate_submodule_alignment() {
  local role="$1"
  local human_label="$2"
  local docker_path="$3"

  local expected_sha="${STAGE_SHA_BY_ROLE[$role]:-}"
  local docker_stage_sha="${STAGE_SHA_BY_ROLE[docker]:-}"
  local actual_sha

  if [ -z "$expected_sha" ] || [ "$expected_sha" = "missing" ]; then
    add_violation "Cannot validate Docker gitlink for $human_label because the app stage SHA is unavailable."
    add_resolution "Repair the $human_label stage-branch evidence first, then rerun this preflight."
    return
  fi

  if [ -z "$docker_stage_sha" ] || [ "$docker_stage_sha" = "missing" ]; then
    add_violation "Cannot validate Docker gitlink for $human_label because the Docker stage SHA is unavailable."
    add_resolution "Repair Docker stage-branch evidence first, then rerun this preflight."
    return
  fi

  actual_sha="$(docker_submodule_sha "$DOCKER_REPO" "$docker_path" "$docker_stage_sha")"
  SUBMODULE_SHA_BY_ROLE["$role"]="${actual_sha:-missing}"

  if [ -z "$actual_sha" ]; then
    add_violation "Unable to resolve Docker path '$docker_path' on '$DOCKER_REPO:stage'."
    add_resolution "Repair the Docker repository access or path configuration, then rerun this preflight with the correct submodule path."
    add_context "docker-gitlink-$role | repo=$DOCKER_REPO | branch=stage | path=$docker_path | actual_sha=missing | expected_sha=$expected_sha"
    return
  fi

  if [ "$actual_sha" != "$expected_sha" ]; then
    add_violation "Docker 'stage' is not aligned for $human_label: path '$docker_path' points to '$actual_sha' instead of expected '$expected_sha'."
    add_resolution "Complete Docker submodule promotion so '$docker_path' on '$DOCKER_REPO:stage' points to the $human_label stage SHA '$expected_sha' before opening stage→main PRs."
  fi

  add_context "docker-gitlink-$role | repo=$DOCKER_REPO | branch=stage | path=$docker_path | actual_sha=$actual_sha | expected_sha=$expected_sha | aligned=$([ "$actual_sha" = "$expected_sha" ] && printf yes || printf no)"
}

# ── Header ───────────────────────────────────────────────────────────────────

printf 'GitHub Main Promotion Preflight\n'
printf 'Requested scenario: %s\n' "$REQUESTED_SCENARIO"
printf 'Effective scenario: %s\n' "$SCENARIO"
printf 'Source branch: stage\n'
printf 'Target branch: main\n'
printf '\n'

printf 'Requested repos\n'
printf '  - docker: %s\n' "${DOCKER_REPO:-not-provided}"
printf '  - flutter: %s\n' "${FLUTTER_REPO_EFFECTIVE:-not-required}"
printf '  - laravel: %s\n' "${LARAVEL_REPO_EFFECTIVE:-not-required}"
printf '  - web: %s\n' "${WEB_REPO:-not-required}"
printf '\n'

# ── Run validations (only if no argument-level violations) ───────────────────

if [ "${#VIOLATIONS[@]}" -eq 0 ]; then
  # Always validate Docker
  validate_repo_stage_health "docker" "$DOCKER_REPO" "Docker"

  # Validate app repos when pertinent
  if [ "$EXPECT_FLUTTER" = true ] && [ -n "$FLUTTER_REPO_EFFECTIVE" ]; then
    validate_repo_stage_health "flutter" "$FLUTTER_REPO_EFFECTIVE" "Flutter"
  fi

  if [ "$EXPECT_LARAVEL" = true ] && [ -n "$LARAVEL_REPO_EFFECTIVE" ]; then
    validate_repo_stage_health "laravel" "$LARAVEL_REPO_EFFECTIVE" "Laravel"
  fi

  # Validate Docker submodule alignment when app repos participate
  if [ "$EXPECT_FLUTTER" = true ] && [ -n "$FLUTTER_REPO" ]; then
    validate_submodule_alignment "flutter" "Flutter" "$DOCKER_FLUTTER_PATH"
  fi

  if [ "$EXPECT_LARAVEL" = true ] && [ -n "$LARAVEL_REPO" ]; then
    validate_submodule_alignment "laravel" "Laravel" "$DOCKER_LARAVEL_PATH"
  fi
fi

# ── Output ───────────────────────────────────────────────────────────────────

printf 'Preflight summary\n'
print_response_list '  ' "${CONTEXT_LINES[@]}"
printf '\n'

if [ "${#VIOLATIONS[@]}" -eq 0 ]; then
  declare -a READY_PROMPTS=()
  READY_PROMPTS+=("All pertinent repos are ready for stage→main promotion under scenario '$SCENARIO'.")
  READY_PROMPTS+=("Continue with the main-promotion skill: open the first stage→main PR for the pertinent app repo(s), then Docker last.")
  READY_PROMPTS+=("Optional follow-up: bash delphi-ai/tools/github_stage_promotion_snapshot.sh to capture live PR/check evidence.")

  printf 'TEACH runtime response\n'
  printf 'status: ready\n'
  printf 'enforcement: allow_first_main_pr\n'
  printf 'rule_id: paced.github-main-promotion.preflight\n'
  printf 'violation:\n'
  printf '  - none\n'
  printf 'resolution_prompt:\n'
  print_response_list '  ' "${READY_PROMPTS[@]}"
  printf 'context:\n'
  printf '  requested_scenario: %s\n' "$REQUESTED_SCENARIO"
  printf '  scenario: %s\n' "$SCENARIO"
  printf '  source_branch: stage\n'
  printf '  target_branch: main\n'
  printf '  repo_health:\n'
  print_response_list '    ' "${CONTEXT_LINES[@]}"
  printf '\nOverall outcome: go\n'
  exit 0
fi

# ── NO-GO path ───────────────────────────────────────────────────────────────

RERUN_COMMAND="bash delphi-ai/tools/github_main_promotion_preflight.sh --scenario auto --docker-repo $DOCKER_REPO"
if [ -n "$FLUTTER_REPO_EFFECTIVE" ]; then
  RERUN_COMMAND="$RERUN_COMMAND --flutter-repo $FLUTTER_REPO_EFFECTIVE"
fi
if [ -n "$LARAVEL_REPO_EFFECTIVE" ]; then
  RERUN_COMMAND="$RERUN_COMMAND --laravel-repo $LARAVEL_REPO_EFFECTIVE"
fi
if [ -n "$WEB_REPO" ]; then
  RERUN_COMMAND="$RERUN_COMMAND --web-repo $WEB_REPO"
fi

RESOLUTION_PROMPTS+=("Rerun the preflight and require 'Overall outcome: go' before opening the first stage→main PR: $RERUN_COMMAND")

printf 'TEACH runtime response\n'
printf 'status: blocked\n'
printf 'enforcement: stop_before_first_main_pr\n'
printf 'rule_id: paced.github-main-promotion.preflight\n'
printf 'violation:\n'
print_response_list '  ' "${VIOLATIONS[@]}"
printf 'resolution_prompt:\n'
print_response_list '  ' "${RESOLUTION_PROMPTS[@]}"
printf 'context:\n'
printf '  requested_scenario: %s\n' "$REQUESTED_SCENARIO"
printf '  scenario: %s\n' "$SCENARIO"
printf '  source_branch: stage\n'
printf '  target_branch: main\n'
printf '  repo_health:\n'
print_response_list '    ' "${CONTEXT_LINES[@]}"
printf '\nOverall outcome: no-go\n'
exit 2
