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
EOF
}

find_environment_root() {
  local start="$1"
  local current="$start"

  for _ in 1 2 3 4 5 6 7; do
    if [[ -f "$current/docker-compose.yml" && -d "$current/laravel-app" && -d "$current/flutter-app" && -d "$current/delphi-ai" ]]; then
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

normalize_laravel_runtime_permissions() {
  docker compose exec -T -u 0 app sh -lc '
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

  "${report_cmd[@]}"
}

SCOPE="medium"
INTENT="principal-checkout reconcile validation"
STATUS_OUTPUT=""
RUN_FLUTTER_ANALYZE=0
NEEDS_LARAVEL_RUNTIME_NORMALIZE=0
declare -a LARAVEL_TESTS=()
declare -a FLUTTER_TESTS=()
declare -a REQUIRED_STAGES=()
declare -a PLATFORM_PARTS=()

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

if [[ "${#LARAVEL_TESTS[@]}" -eq 0 && "${#FLUTTER_TESTS[@]}" -eq 0 && "$RUN_FLUTTER_ANALYZE" -eq 0 ]]; then
  echo "ERROR: at least one validation stage must be requested." >&2
  usage >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(find_environment_root "$SCRIPT_DIR" || true)"

if [[ -z "$ROOT_DIR" ]]; then
  echo "ERROR: could not resolve environment root containing docker-compose.yml, laravel-app, flutter-app, and delphi-ai." >&2
  exit 1
fi

cd "$ROOT_DIR"

cleanup() {
  if [[ "$NEEDS_LARAVEL_RUNTIME_NORMALIZE" -eq 1 ]]; then
    normalize_laravel_runtime_permissions >/dev/null 2>&1 || true
  fi
}

trap cleanup EXIT

if [[ -z "$STATUS_OUTPUT" ]]; then
  mkdir -p "$ROOT_DIR/foundation_documentation/artifacts/tmp"
  STATUS_OUTPUT="$ROOT_DIR/foundation_documentation/artifacts/tmp/reconcile_validation_status_$(date +%Y%m%d_%H%M%S).md"
fi

LARAVEL_STAGE_STATUS=""
FLUTTER_TEST_STAGE_STATUS=""
FLUTTER_ANALYZE_STAGE_STATUS=""

if [[ "${#LARAVEL_TESTS[@]}" -gt 0 ]]; then
  NEEDS_LARAVEL_RUNTIME_NORMALIZE=1
  REQUIRED_STAGES+=("reconcile_laravel_tests")
  PLATFORM_PARTS+=("laravel-docker-sequential-targeted")

  if ! require_reconcile_branch "$ROOT_DIR/laravel-app" "Laravel"; then
    LARAVEL_STAGE_STATUS="blocked"
    PLATFORM_MATRIX="$(IFS=' + '; echo "${PLATFORM_PARTS[*]}")"
    emit_status_report
    exit 1
  fi

  if [[ ! -x "$ROOT_DIR/laravel-app/scripts/delphi/run_laravel_tests_safe.sh" ]]; then
    echo "ERROR: canonical Laravel safe runner is missing or not executable." >&2
    LARAVEL_STAGE_STATUS="blocked"
    PLATFORM_MATRIX="$(IFS=' + '; echo "${PLATFORM_PARTS[*]}")"
    emit_status_report
    exit 1
  fi

  normalize_laravel_runtime_permissions
fi

if [[ "${#FLUTTER_TESTS[@]}" -gt 0 || "$RUN_FLUTTER_ANALYZE" -eq 1 ]]; then
  if ! require_reconcile_branch "$ROOT_DIR/flutter-app" "Flutter"; then
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

PLATFORM_MATRIX="$(IFS=' + '; echo "${PLATFORM_PARTS[*]}")"

if [[ "${#LARAVEL_TESTS[@]}" -gt 0 ]]; then
  for test_path in "${LARAVEL_TESTS[@]}"; do
    echo "INFO: Laravel reconcile validation -> $test_path"
    if ! "$ROOT_DIR/laravel-app/scripts/delphi/run_laravel_tests_safe.sh" "$test_path"; then
      LARAVEL_STAGE_STATUS="failed"
      emit_status_report
      exit 1
    fi
  done

  LARAVEL_STAGE_STATUS="passed"
fi

if [[ "${#FLUTTER_TESTS[@]}" -gt 0 ]]; then
  echo "INFO: Flutter reconcile validation -> ${#FLUTTER_TESTS[@]} targeted test file(s)"
  if ! (cd "$ROOT_DIR/flutter-app" && fvm flutter test "${FLUTTER_TESTS[@]}"); then
    FLUTTER_TEST_STAGE_STATUS="failed"
    emit_status_report
    exit 1
  fi

  FLUTTER_TEST_STAGE_STATUS="passed"
fi

if [[ "$RUN_FLUTTER_ANALYZE" -eq 1 ]]; then
  echo "INFO: Flutter reconcile validation -> analyzer"
  if ! (cd "$ROOT_DIR/flutter-app" && fvm dart analyze --format machine); then
    FLUTTER_ANALYZE_STAGE_STATUS="failed"
    emit_status_report
    exit 1
  fi

  FLUTTER_ANALYZE_STAGE_STATUS="passed"
fi

emit_status_report
echo "INFO: reconcile validation report written to $STATUS_OUTPUT"
