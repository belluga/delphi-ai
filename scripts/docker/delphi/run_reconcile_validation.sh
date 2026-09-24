#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/delphi/run_reconcile_validation.sh \
    [--scope <small|medium|big>] \
    [--intent <text>] \
    [--laravel-test <path>]... \
    [--flutter-test <path>]... \
    [--flutter-analyze] \
    [--repo-command <stage> <repo-path> <command>]... \
    [--status-output <path>]

Authoritative local orchestration validation requires the principal checkout(s)
to already be on dedicated reconcile branches. Worker worktrees are not accepted
as the authoritative validation surface.

Examples:
  ./scripts/delphi/run_reconcile_validation.sh \
    --intent "store-release reconcile validation" \
    --laravel-test tests/Feature/Profile/ProfileProximityPreferencesControllerTest.php \
    --flutter-test test/infrastructure/dal/dto/app_data_dto_test.dart \
    --flutter-analyze

  ./scripts/delphi/run_reconcile_validation.sh \
    --intent "go service reconcile validation" \
    --repo-command reconcile_go_tests go-app 'go test ./...'
EOF
}

find_environment_root() {
  local start="$1"
  local current="$start"

  for _ in 1 2 3 4 5 6 7; do
    if [[ -f "$current/docker-compose.yml" && -d "$current/delphi-ai" ]]; then
      printf '%s\n' "$current"
      return 0
    fi
    current="$(cd "$current/.." && pwd 2>/dev/null || true)"
    if [[ -z "$current" ]]; then
      break
    fi
  done

  return 1
}

require_reconcile_branch() {
  local repo_path="$1"
  local label="$2"
  local branch

  branch="$(git -C "$repo_path" branch --show-current)"
  if [[ -z "$branch" ]]; then
    echo "ERROR: could not resolve current branch for $label checkout at $repo_path." >&2
    return 1
  fi

  if [[ ! "$branch" =~ ^reconcile/ ]]; then
    echo "ERROR: $label principal checkout must be on a reconcile/* branch for authoritative orchestration validation. Current branch: $branch" >&2
    return 1
  fi
}

resolve_root_path() {
  local raw_path="$1"
  if [[ "$raw_path" == /* ]]; then
    printf '%s\n' "$raw_path"
  else
    printf '%s\n' "$ROOT_DIR/$raw_path"
  fi
}

resolve_child_path() {
  local parent_path="$1"
  local raw_path="$2"
  if [[ "$raw_path" == /* ]]; then
    printf '%s\n' "$raw_path"
  else
    printf '%s\n' "$parent_path/$raw_path"
  fi
}

normalize_laravel_runtime_permissions() {
  docker compose exec -T -u 0 "$RECONCILE_LARAVEL_COMPOSE_SERVICE" sh -lc '
    mkdir -p \
      /var/www/bootstrap/cache \
      /var/www/storage/app/public \
      /var/www/storage/app/public/tenants \
      /var/www/storage/framework/cache \
      /var/www/storage/framework/sessions \
      /var/www/storage/framework/testing \
      /var/www/storage/framework/views \
      /var/www/storage/logs &&
    chown -R www-data:www-data \
      /var/www/bootstrap/cache \
      /var/www/storage/app/public \
      /var/www/storage/framework \
      /var/www/storage/logs &&
    chmod -R ug+rwX \
      /var/www/bootstrap/cache \
      /var/www/storage/app/public \
      /var/www/storage/framework \
      /var/www/storage/logs
  '
}

emit_status_report() {
  local report_cmd=(
    bash "$ROOT_DIR/delphi-ai/tools/test_orchestration_status_report.sh"
    --scope "$SCOPE"
    --intent "$INTENT"
    --platform-matrix "$PLATFORM_MATRIX"
    --output "$STATUS_OUTPUT"
    --decision D-RUN-RECONCILE=adherent
  )

  local stage
  for stage in "${REQUIRED_STAGES[@]}"; do
    report_cmd+=(--require-stage "$stage")
  done

  [[ -n "$LARAVEL_STAGE_STATUS" ]] && report_cmd+=(--stage "reconcile_laravel_tests=$LARAVEL_STAGE_STATUS")
  [[ -n "$FLUTTER_TEST_STAGE_STATUS" ]] && report_cmd+=(--stage "reconcile_flutter_tests=$FLUTTER_TEST_STAGE_STATUS")
  [[ -n "$FLUTTER_ANALYZE_STAGE_STATUS" ]] && report_cmd+=(--stage "reconcile_flutter_analyze=$FLUTTER_ANALYZE_STAGE_STATUS")
  local idx
  for idx in "${!GENERIC_STAGE_NAMES[@]}"; do
    [[ -n "${GENERIC_STAGE_STATUSES[$idx]:-}" ]] && report_cmd+=(--stage "${GENERIC_STAGE_NAMES[$idx]}=${GENERIC_STAGE_STATUSES[$idx]}")
  done

  "${report_cmd[@]}"
}

SCOPE="medium"
INTENT="principal-checkout reconcile validation"
STATUS_OUTPUT=""
RUN_FLUTTER_ANALYZE=0
NEEDS_LARAVEL_RUNTIME_NORMALIZE=0
RECONCILE_LARAVEL_REPO="${RECONCILE_LARAVEL_REPO:-laravel-app}"
RECONCILE_FLUTTER_REPO="${RECONCILE_FLUTTER_REPO:-flutter-app}"
RECONCILE_LARAVEL_RUNNER="${RECONCILE_LARAVEL_RUNNER:-scripts/delphi/run_laravel_tests_safe.sh}"
RECONCILE_LARAVEL_COMPOSE_SERVICE="${RECONCILE_LARAVEL_COMPOSE_SERVICE:-app}"
declare -a LARAVEL_TESTS=()
declare -a FLUTTER_TESTS=()
declare -a REQUIRED_STAGES=()
declare -a PLATFORM_PARTS=()
declare -a GENERIC_STAGE_NAMES=()
declare -a GENERIC_STAGE_REPOS=()
declare -a GENERIC_STAGE_COMMANDS=()
declare -a GENERIC_STAGE_STATUSES=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --scope)
      SCOPE="${2:-}"
      shift 2
      ;;
    --intent)
      INTENT="${2:-}"
      shift 2
      ;;
    --laravel-test)
      LARAVEL_TESTS+=("${2:-}")
      shift 2
      ;;
    --flutter-test)
      FLUTTER_TESTS+=("${2:-}")
      shift 2
      ;;
    --flutter-analyze)
      RUN_FLUTTER_ANALYZE=1
      shift
      ;;
    --repo-command)
      if [[ $# -lt 4 ]]; then
        echo "ERROR: --repo-command requires <stage> <repo-path> <command>." >&2
        exit 1
      fi
      GENERIC_STAGE_NAMES+=("$2")
      GENERIC_STAGE_REPOS+=("$3")
      GENERIC_STAGE_COMMANDS+=("$4")
      GENERIC_STAGE_STATUSES+=("")
      shift 4
      ;;
    --status-output)
      STATUS_OUTPUT="${2:-}"
      shift 2
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

case "$SCOPE" in
  small|medium|big) ;;
  *)
    echo "ERROR: --scope must be one of: small, medium, big." >&2
    exit 1
    ;;
esac

if [[ "${#LARAVEL_TESTS[@]}" -eq 0 && "${#FLUTTER_TESTS[@]}" -eq 0 && "$RUN_FLUTTER_ANALYZE" -eq 0 && "${#GENERIC_STAGE_NAMES[@]}" -eq 0 ]]; then
  echo "ERROR: at least one validation stage must be requested." >&2
  usage >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(find_environment_root "$SCRIPT_DIR" || true)"

if [[ -z "$ROOT_DIR" ]]; then
  echo "ERROR: could not resolve environment root containing docker-compose.yml and delphi-ai." >&2
  exit 1
fi

cd "$ROOT_DIR"

if [[ -f "$ROOT_DIR/delphi-ai/tools/lib/script_usage.sh" ]]; then
  # shellcheck source=/dev/null
  source "$ROOT_DIR/delphi-ai/tools/lib/script_usage.sh"
  delphi_script_usage_init \
    --delphi-root "$ROOT_DIR/delphi-ai" \
    --script-id "root.run_reconcile_validation" \
    --script-path "scripts/delphi/run_reconcile_validation.sh" \
    --surface "root-script"
  delphi_script_usage_set_scenario "scope-${SCOPE}"
  delphi_script_usage_add_metadata "laravel_tests" "${#LARAVEL_TESTS[@]}"
  delphi_script_usage_add_metadata "flutter_tests" "${#FLUTTER_TESTS[@]}"
  delphi_script_usage_add_metadata "repo_commands" "${#GENERIC_STAGE_NAMES[@]}"
fi

if ! require_reconcile_branch "$ROOT_DIR" "Environment root"; then
  exit 1
fi

cleanup() {
  if [[ "$NEEDS_LARAVEL_RUNTIME_NORMALIZE" -eq 1 ]]; then
    normalize_laravel_runtime_permissions >/dev/null 2>&1 || true
  fi
}

cleanup_and_record() {
  local status=$?
  cleanup
  delphi_script_usage_capture_exit "$status"
}

if [[ "${DELPHI_SCRIPT_USAGE_ENABLED:-0}" == "1" ]]; then
  trap cleanup_and_record EXIT
else
  trap cleanup EXIT
fi

if [[ -z "$STATUS_OUTPUT" ]]; then
  STATUS_DIR="${RECONCILE_STATUS_DIR:-foundation_documentation/artifacts/tmp}"
  if [[ "$STATUS_DIR" != /* ]]; then
    STATUS_DIR="$ROOT_DIR/$STATUS_DIR"
  fi
  mkdir -p "$STATUS_DIR"
  STATUS_OUTPUT="$STATUS_DIR/reconcile_validation_status_$(date +%Y%m%d_%H%M%S).md"
fi

LARAVEL_STAGE_STATUS=""
FLUTTER_TEST_STAGE_STATUS=""
FLUTTER_ANALYZE_STAGE_STATUS=""

if [[ "${#LARAVEL_TESTS[@]}" -gt 0 ]]; then
  NEEDS_LARAVEL_RUNTIME_NORMALIZE=1
  REQUIRED_STAGES+=("reconcile_laravel_tests")
  PLATFORM_PARTS+=("laravel-docker-sequential-targeted")
  LARAVEL_REPO_PATH="$(resolve_root_path "$RECONCILE_LARAVEL_REPO")"
  LARAVEL_RUNNER_PATH="$(resolve_child_path "$LARAVEL_REPO_PATH" "$RECONCILE_LARAVEL_RUNNER")"

  if ! require_reconcile_branch "$LARAVEL_REPO_PATH" "Laravel"; then
    LARAVEL_STAGE_STATUS="blocked"
    PLATFORM_MATRIX="$(IFS=' + '; echo "${PLATFORM_PARTS[*]}")"
    emit_status_report
    exit 1
  fi

  if [[ ! -x "$LARAVEL_RUNNER_PATH" ]]; then
    echo "ERROR: canonical Laravel safe runner is missing or not executable." >&2
    echo "Resolution: set RECONCILE_LARAVEL_REPO and RECONCILE_LARAVEL_RUNNER for this project topology." >&2
    LARAVEL_STAGE_STATUS="blocked"
    PLATFORM_MATRIX="$(IFS=' + '; echo "${PLATFORM_PARTS[*]}")"
    emit_status_report
    exit 1
  fi

  normalize_laravel_runtime_permissions
fi

if [[ "${#FLUTTER_TESTS[@]}" -gt 0 || "$RUN_FLUTTER_ANALYZE" -eq 1 ]]; then
  FLUTTER_REPO_PATH="$(resolve_root_path "$RECONCILE_FLUTTER_REPO")"
  if ! require_reconcile_branch "$FLUTTER_REPO_PATH" "Flutter"; then
    [[ "${#FLUTTER_TESTS[@]}" -gt 0 ]] && FLUTTER_TEST_STAGE_STATUS="blocked"
    [[ "$RUN_FLUTTER_ANALYZE" -eq 1 ]] && FLUTTER_ANALYZE_STAGE_STATUS="blocked"
    PLATFORM_PARTS+=("flutter-principal-checkout")
    PLATFORM_MATRIX="$(IFS=' + '; echo "${PLATFORM_PARTS[*]}")"
    emit_status_report
    exit 1
  fi
fi

if [[ "${#FLUTTER_TESTS[@]}" -gt 0 ]]; then
  REQUIRED_STAGES+=("reconcile_flutter_tests")
  PLATFORM_PARTS+=("flutter-targeted-tests")
fi

if [[ "$RUN_FLUTTER_ANALYZE" -eq 1 ]]; then
  REQUIRED_STAGES+=("reconcile_flutter_analyze")
  PLATFORM_PARTS+=("flutter-analyze")
fi

for idx in "${!GENERIC_STAGE_NAMES[@]}"; do
  REQUIRED_STAGES+=("${GENERIC_STAGE_NAMES[$idx]}")
  PLATFORM_PARTS+=("${GENERIC_STAGE_NAMES[$idx]}")
done

PLATFORM_MATRIX="$(IFS=' + '; echo "${PLATFORM_PARTS[*]}")"

if [[ "${#LARAVEL_TESTS[@]}" -gt 0 ]]; then
  for test_path in "${LARAVEL_TESTS[@]}"; do
    echo "INFO: Laravel reconcile validation -> $test_path"
    if ! "$LARAVEL_RUNNER_PATH" "$test_path"; then
      LARAVEL_STAGE_STATUS="failed"
      emit_status_report
      exit 1
    fi
  done

  LARAVEL_STAGE_STATUS="passed"
fi

if [[ "${#FLUTTER_TESTS[@]}" -gt 0 ]]; then
  echo "INFO: Flutter reconcile validation -> ${#FLUTTER_TESTS[@]} targeted test file(s)"
  if ! (cd "$FLUTTER_REPO_PATH" && fvm flutter test "${FLUTTER_TESTS[@]}"); then
    FLUTTER_TEST_STAGE_STATUS="failed"
    emit_status_report
    exit 1
  fi

  FLUTTER_TEST_STAGE_STATUS="passed"
fi

if [[ "$RUN_FLUTTER_ANALYZE" -eq 1 ]]; then
  echo "INFO: Flutter reconcile validation -> analyzer"
  if ! (cd "$FLUTTER_REPO_PATH" && fvm dart analyze --format machine); then
    FLUTTER_ANALYZE_STAGE_STATUS="failed"
    emit_status_report
    exit 1
  fi

  FLUTTER_ANALYZE_STAGE_STATUS="passed"
fi

for idx in "${!GENERIC_STAGE_NAMES[@]}"; do
  stage_name="${GENERIC_STAGE_NAMES[$idx]}"
  repo_path="${GENERIC_STAGE_REPOS[$idx]}"
  command_text="${GENERIC_STAGE_COMMANDS[$idx]}"
  if [[ "$repo_path" != /* ]]; then
    repo_path="$ROOT_DIR/$repo_path"
  fi

  echo "INFO: Generic reconcile validation -> $stage_name"
  if [[ ! -d "$repo_path" ]]; then
    echo "ERROR: generic stage repo path is missing: $repo_path" >&2
    GENERIC_STAGE_STATUSES[$idx]="blocked"
    emit_status_report
    exit 1
  fi
  if ! require_reconcile_branch "$repo_path" "$stage_name"; then
    GENERIC_STAGE_STATUSES[$idx]="blocked"
    emit_status_report
    exit 1
  fi
  if ! (cd "$repo_path" && bash -lc "$command_text"); then
    GENERIC_STAGE_STATUSES[$idx]="failed"
    emit_status_report
    exit 1
  fi
  GENERIC_STAGE_STATUSES[$idx]="passed"
done

emit_status_report
echo "INFO: reconcile validation report written to $STATUS_OUTPUT"
