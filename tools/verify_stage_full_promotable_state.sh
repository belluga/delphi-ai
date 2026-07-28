#!/usr/bin/env bash
set -euo pipefail

SOURCE_PATH="${BASH_SOURCE[0]}"
SCRIPT_DIR="$(cd "$(dirname "${SOURCE_PATH}")" && pwd -L)"
case "${SOURCE_PATH}" in
  */tools/ci/*)
    ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
    ;;
  */delphi-ai/tools/*)
    ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd -P)"
    ;;
  *)
    ROOT_DIR="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"
    ;;
esac
source "${ROOT_DIR}/delphi-ai/tools/lib/teach_runtime.sh"
DEFAULT_BASE_REF="${STAGE_FULL_PROMOTION_BASE_REF:-origin/dev}"
RELEASE_PACKAGE_OPENING_TRACK=""
RULE_ID="paced.ci-equivalent.promotable-stage-full-branch-authority"

ensure_principal_checkout() {
  local git_dir=""
  local git_common_dir=""
  local principal_checkout=""

  git_dir="$(
    cd "${ROOT_DIR}" &&
      cd "$(git rev-parse --git-dir)" &&
      pwd
  )"
  git_common_dir="$(
    cd "${ROOT_DIR}" &&
      cd "$(git rev-parse --git-common-dir)" &&
      pwd
  )"

  if [[ "${git_dir}" == "${git_common_dir}" ]]; then
    return 0
  fi

  principal_checkout="$(cd "${git_common_dir}/.." && pwd)"

  echo "ERROR: promotable stage-full must run from the principal checkout." >&2
  echo "ERROR: current checkout: ${ROOT_DIR}" >&2
  echo "ERROR: principal checkout: ${principal_checkout}" >&2
  echo "ERROR: linked worktrees are not allowed for this promotion flow because they can miss principal-only artifacts." >&2
  echo "ERROR: gitlinks are promotion-lane artifacts; do not inspect, realign, or update them manually from a worktree." >&2
  echo "ERROR: recovery action: rerun stage-full from the principal checkout and let the promotion lane own any later gitlink movement." >&2
  exit 1
}

detect_governing_todo() {
  local root_branch="$1"
  local package_version=""
  local candidate_version=""
  local todo_path=""
  local candidates=()
  local todo_roots=()
  local todo_root=""
  if [[ ! "${root_branch}" =~ ^v.+-rc$ ]]; then
    return 1
  fi

  package_version="${root_branch%-rc}"
  candidates=("${package_version}")
  todo_roots=(
    "${ROOT_DIR}/foundation_documentation/todos/promotion_lane"
    "${ROOT_DIR}/foundation_documentation/todos/active"
  )
  if [[ "${package_version}" == *+* ]]; then
    candidate_version="${package_version%%+*}"
    if [[ -n "${candidate_version}" && "${candidate_version}" != "${package_version}" ]]; then
      candidates+=("${candidate_version}")
    fi
  fi

  for todo_root in "${todo_roots[@]}"; do
    for candidate_version in "${candidates[@]}"; do
      todo_path="${todo_root}/${candidate_version}/TODO-${candidate_version}-release-package.md"
      if [[ -f "${todo_path}" ]]; then
        printf '%s\n' "${todo_path}"
        return 0
      fi
    done
  done

  return 1
}

detect_related_governing_todo_for_non_authoritative_branch() {
  local root_branch="$1"
  local package_version=""
  local candidate_version=""
  local todo_path=""
  local candidates=()
  local todo_roots=()
  local todo_root=""

  if [[ "${root_branch}" =~ ^(v.+)-root-harness-replay$ ]]; then
    package_version="${BASH_REMATCH[1]}"
  else
    return 1
  fi

  candidates=("${package_version}")
  todo_roots=(
    "${ROOT_DIR}/foundation_documentation/todos/promotion_lane"
    "${ROOT_DIR}/foundation_documentation/todos/active"
  )
  if [[ "${package_version}" == *+* ]]; then
    candidate_version="${package_version%%+*}"
    if [[ -n "${candidate_version}" && "${candidate_version}" != "${package_version}" ]]; then
      candidates+=("${candidate_version}")
    fi
  fi

  for todo_root in "${todo_roots[@]}"; do
    for candidate_version in "${candidates[@]}"; do
      todo_path="${todo_root}/${candidate_version}/TODO-${candidate_version}-release-package.md"
      if [[ -f "${todo_path}" ]]; then
        printf '%s\n' "${todo_path}"
        return 0
      fi
    done
  done

  return 1
}

emit_non_authoritative_branch_teach() {
  local root_branch="$1"
  local related_governing_todo="$2"

  teach_runtime_begin "$RULE_ID" "stop_before_stage_full" "blocked" "no-go"
  teach_add_violation "Current root branch ${root_branch} maps to a governed release package but is not the authoritative *-rc promotion source."
  teach_add_resolution "Replay or switch to the canonical package authority before rerunning bash tools/ci/run_promotable_stage_full.sh."
  teach_add_resolution "Run stage-full only from the authoritative *-rc package state; replay, review, and harness branches are diagnostic only."
  teach_add_context "root_branch: ${root_branch}"
  teach_add_context "governing_todo: ${related_governing_todo#${ROOT_DIR}/}"
  teach_add_context "expected_authoritative_pattern: v*-rc"
  teach_add_context "disallowed_branch_role: replay-only root branch"
  teach_emit_blocked
}

ensure_clean_repo() {
  local repo_path="$1"
  local repo_label="$2"
  local status_output=""
  status_output="$(git -C "${repo_path}" status --short)"
  if [[ -n "${status_output}" ]]; then
    echo "ERROR: stage-full promotable-state validation requires a clean worktree for ${repo_label}." >&2
    printf '%s\n' "${status_output}" >&2
    exit 1
  fi
}

run_source_authority() {
  local repo_selector="$1"
  local repo_key="$2"
  local source_branch="$3"
  local governing_todo="$4"

  python3 "${ROOT_DIR}/delphi-ai/tools/github_promotion_source_authority_guard.py" \
    --repo "${repo_selector}" \
    --source-ref "${source_branch}" \
    --governing-todo "${governing_todo}" \
    --repo-key "${repo_key}"
}

run_source_preflight() {
  local repo_workdir="$1"
  local repo_key="$2"
  local source_branch="$3"
  local governing_todo="$4"

  (
    cd "${repo_workdir}"
    bash "${ROOT_DIR}/delphi-ai/tools/github_stage_promotion_preflight.sh" \
      --source "${source_branch}" \
      --base "${DEFAULT_BASE_REF}" \
      --governing-todo "${governing_todo}" \
      --repo-key "${repo_key}"
  )
}

capture_release_package_opening_track() {
  local governing_todo="$1"
  local output_file=""

  output_file="$(mktemp)"
  python3 "${ROOT_DIR}/delphi-ai/tools/github_release_package_rollup_guard.py" \
    --governing-todo "${governing_todo}" \
    --base-ref "${DEFAULT_BASE_REF}" >"${output_file}"
  cat "${output_file}"
  RELEASE_PACKAGE_OPENING_TRACK="$(sed -n 's/^  - recommended opening track: //p' "${output_file}" | head -n 1)"
  rm -f "${output_file}"
}

root_gitlink_matches_base() {
  local submodule_path="$1"
  local head_gitlink_sha=""
  local base_gitlink_sha=""

  head_gitlink_sha="$(git -C "${ROOT_DIR}" rev-parse "HEAD:${submodule_path}" 2>/dev/null | tr -d '[:space:]' || true)"
  base_gitlink_sha="$(git -C "${ROOT_DIR}" rev-parse "${DEFAULT_BASE_REF}:${submodule_path}" 2>/dev/null | tr -d '[:space:]' || true)"

  [[ -n "${head_gitlink_sha}" ]] \
    && [[ -n "${base_gitlink_sha}" ]] \
    && [[ "${head_gitlink_sha}" == "${base_gitlink_sha}" ]]
}

repo_requires_source_preflight() {
  local repo_key="$1"

  case "${repo_key}" in
    root)
      case "${RELEASE_PACKAGE_OPENING_TRACK}" in
        flutter-only|laravel-only|flutter-laravel)
          return 1
          ;;
      esac
      return 0
      ;;
    flutter-app|laravel-app)
      if root_gitlink_matches_base "${repo_key}"; then
        return 1
      fi
      return 0
      ;;
  esac

  return 0
}

repo_requires_promotion_validation() {
  local repo_key="$1"

  case "${repo_key}:${RELEASE_PACKAGE_OPENING_TRACK}" in
    root:flutter-only|root:laravel-only|root:flutter-laravel)
      return 1
      ;;
  esac

  return 0
}

main() {
  local root_branch=""
  ensure_principal_checkout
  root_branch="$(git -C "${ROOT_DIR}" branch --show-current)"

  echo "INFO: stage-full promotable-state validation starting."
  echo "INFO: root branch under evaluation: ${root_branch:-<detached>}."

  local governing_todo=""
  local related_governing_todo=""
  governing_todo="$(detect_governing_todo "${root_branch}" || true)"
  if [[ -z "${governing_todo}" ]]; then
    related_governing_todo="$(detect_related_governing_todo_for_non_authoritative_branch "${root_branch}" || true)"
    if [[ -n "${related_governing_todo}" ]]; then
      emit_non_authoritative_branch_teach "${root_branch}" "${related_governing_todo}"
      exit 1
    fi
    echo "INFO: no package-governed *-rc promotion packet matched the current branch; skipping promotable-state guard for stage-full."
    exit 0
  fi

  echo "INFO: using governing package TODO: ${governing_todo#${ROOT_DIR}/}"
  capture_release_package_opening_track "${governing_todo}"
  if [[ -n "${RELEASE_PACKAGE_OPENING_TRACK}" ]]; then
    echo "INFO: release-package opening track under promotable-state validation: ${RELEASE_PACKAGE_OPENING_TRACK}."
  fi

  local repo_path=""
  local repo_selector=""
  local repo_key=""
  local repo_label=""
  local source_branch=""

  for repo_key in root flutter-app laravel-app; do
    case "${repo_key}" in
      root)
        repo_path="${ROOT_DIR}"
        repo_selector="."
        repo_label="root"
        ;;
      flutter-app|laravel-app)
        repo_path="${ROOT_DIR}/${repo_key}"
        repo_selector="${repo_key}"
        repo_label="${repo_key}"
        ;;
    esac

    source_branch="$(git -C "${repo_path}" branch --show-current)"
    echo "INFO: promotable-state validating ${repo_label} on branch ${source_branch:-<detached>}."
    if ! repo_requires_promotion_validation "${repo_key}"; then
      echo "INFO: skipping promotable-state promotion validation for ${repo_label} because the release-package opening track is app-first (${RELEASE_PACKAGE_OPENING_TRACK}); root is not an authorized first promotion source."
      continue
    fi
    ensure_clean_repo "${repo_path}" "${repo_label}"
    run_source_authority "${repo_selector}" "${repo_key}" "${source_branch}" "${governing_todo}"
    if repo_requires_source_preflight "${repo_key}"; then
      run_source_preflight "${repo_path}" "${repo_key}" "${source_branch}" "${governing_todo}"
      continue
    fi
    echo "INFO: skipping promotable-state source preflight for ${repo_label} because root gitlink matches ${DEFAULT_BASE_REF}; this stage-full rerun is root-only for that repo."
  done

  echo "OK: stage-full promotable-state validation passed."
}

if [[ "${SCRIPT_UNDER_TEST:-0}" != "1" ]]; then
  main "$@"
fi
