#!/usr/bin/env bash
set -euo pipefail
export PATH="/usr/local/bin:/usr/bin:/bin:${PATH:-}"

usage() {
  cat <<'EOF'
Usage:
  device_single_test_resilient.sh start <flutter_app_root> <device> <app_id> <flavor> <define_file> <integration_test_file> [timeout_seconds]
  device_single_test_resilient.sh status <flutter_app_root>
  device_single_test_resilient.sh wait <flutter_app_root>
  device_single_test_resilient.sh stop <flutter_app_root>
EOF
}

require_cmds() {
  local missing=0
  for cmd in adb rg timeout nohup bash fvm stdbuf; do
    if ! command -v "${cmd}" >/dev/null 2>&1; then
      echo "Missing command: ${cmd}"
      missing=1
    fi
  done
  if [[ "${missing}" -ne 0 ]]; then
    exit 1
  fi
}

abs_path() {
  local input="$1"
  (
    cd "${input}" >/dev/null 2>&1
    pwd
  )
}

run_root_for_app() {
  local app_root="$1"
  if [[ -d "${app_root}/../foundation_documentation/artifacts/tmp" ]]; then
    echo "${app_root}/../foundation_documentation/artifacts/tmp/flutter-device-runner"
    return
  fi
  echo "${app_root}/build/runner_artifacts/flutter-device-runner"
}

reset_test_cache_if_present() {
  local app_root="$1"
  local run_root
  run_root="$(run_root_for_app "${app_root}")"
  local reset_marker_file="${run_root}/test_cache_reset.marker"
  local cache_dir="${app_root}/build/test_cache"

  if [[ -f "${reset_marker_file}" ]]; then
    echo "Flutter test cache was already rotated for the current checklist session."
    return 0
  fi

  if [[ ! -d "${cache_dir}" ]]; then
    echo "No Flutter test cache found at ${cache_dir}"
    mkdir -p "${run_root}"
    touch "${reset_marker_file}"
    return 0
  fi

  local cache_archive_root="${run_root}/cache_snapshots"
  local archived_cache_dir="${cache_archive_root}/test_cache_$(date +%Y%m%d_%H%M%S)"
  mkdir -p "${cache_archive_root}"
  if mv "${cache_dir}" "${archived_cache_dir}"; then
    echo "Moved stale Flutter test cache to ${archived_cache_dir}"
  else
    echo "Warning: failed to move ${cache_dir}; continuing without cache reset."
  fi
  touch "${reset_marker_file}"
}

state_file_for_app() {
  local app_root="$1"
  local run_root
  run_root="$(run_root_for_app "${app_root}")"
  mkdir -p "${run_root}"
  echo "${run_root}/current_run.env"
}

load_state() {
  local app_root="$1"
  local state_file
  state_file="$(state_file_for_app "${app_root}")"
  if [[ ! -f "${state_file}" ]]; then
    echo "No active state file: ${state_file}"
    return 1
  fi
  # shellcheck disable=SC1090
  source "${state_file}"
  return 0
}

save_state() {
  local app_root="$1"
  local state_file
  state_file="$(state_file_for_app "${app_root}")"
  cat >"${state_file}" <<EOF
PID=${PID}
DEVICE=${DEVICE}
APP_ID=${APP_ID}
FLAVOR=${FLAVOR}
DEFINE_FILE=${DEFINE_FILE}
TEST_FILE=${TEST_FILE}
TIMEOUT_S=${TIMEOUT_S}
STARTED_AT=${STARTED_AT}
LOG_FILE=${LOG_FILE}
EOF
}

grant_permissions_if_installed() {
  local device="$1"
  local app_id="$2"

  if adb -s "${device}" shell pm list packages | tr -d '\r' | rg -q "^package:${app_id}$"; then
    adb -s "${device}" shell pm grant "${app_id}" android.permission.ACCESS_FINE_LOCATION || true
    adb -s "${device}" shell pm grant "${app_id}" android.permission.ACCESS_COARSE_LOCATION || true
    adb -s "${device}" shell pm grant "${app_id}" android.permission.POST_NOTIFICATIONS || true
    adb -s "${device}" shell appops set "${app_id}" POST_NOTIFICATION allow || true
  else
    echo "Package ${app_id} not installed yet on ${device}; skipping pre-grants for this cycle."
  fi
}

print_summary() {
  local log_file="$1"
  if [[ ! -f "${log_file}" ]]; then
    echo "Log file not found: ${log_file}"
    return 0
  fi

  echo "Recent log lines:"
  tail -n 30 "${log_file}" || true
}

is_test_process_running() {
  local test_file="$1"
  if pgrep -f "run_integration_test_wsl\\.sh .*${test_file}" >/dev/null 2>&1; then
    return 0
  fi
  if pgrep -f "fvm flutter test .*${test_file}" >/dev/null 2>&1; then
    return 0
  fi
  if pgrep -f "flutter_tools\\.snapshot test .*${test_file}" >/dev/null 2>&1; then
    return 0
  fi
  if pgrep -f "fvm flutter drive .*${test_file}" >/dev/null 2>&1; then
    return 0
  fi
  if pgrep -f "flutter_tools\\.snapshot drive .*${test_file}" >/dev/null 2>&1; then
    return 0
  fi
  return 1
}

is_run_active() {
  local pid="$1"
  local test_file="$2"
  if kill -0 "${pid}" >/dev/null 2>&1; then
    return 0
  fi
  if is_test_process_running "${test_file}"; then
    return 0
  fi
  return 1
}

start_run() {
  if [[ $# -lt 6 ]]; then
    usage
    exit 1
  fi

  local app_root
  app_root="$(abs_path "$1")"
  local device="$2"
  local app_id="$3"
  local flavor="$4"
  local define_file="$5"
  local test_file="$6"
  local timeout_s="${7:-1200}"

  require_cmds

  if [[ ! -f "${app_root}/${test_file}" ]]; then
    echo "Test file not found: ${app_root}/${test_file}"
    exit 1
  fi
  if [[ ! -f "${app_root}/${define_file}" ]]; then
    echo "Define file not found: ${app_root}/${define_file}"
    exit 1
  fi

  if load_state "${app_root}" >/dev/null 2>&1; then
    if kill -0 "${PID}" >/dev/null 2>&1; then
      echo "A run is already active (PID=${PID}). Use status/wait/stop first."
      exit 1
    fi
  fi

  reset_test_cache_if_present "${app_root}"

  local run_root
  run_root="$(run_root_for_app "${app_root}")"
  mkdir -p "${run_root}"
  local test_slug
  test_slug="$(basename "${test_file}" .dart)"
  local log_file="${run_root}/${test_slug}_$(date +%Y%m%d_%H%M%S).expanded.log"
  local started_at
  started_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  nohup stdbuf -oL -eL bash "$0" _run "${app_root}" "${device}" "${app_id}" "${flavor}" "${define_file}" "${test_file}" "${timeout_s}" >"${log_file}" 2>&1 &
  local pid=$!

  PID="${pid}"
  DEVICE="${device}"
  APP_ID="${app_id}"
  FLAVOR="${flavor}"
  DEFINE_FILE="${define_file}"
  TEST_FILE="${test_file}"
  TIMEOUT_S="${timeout_s}"
  STARTED_AT="${started_at}"
  LOG_FILE="${log_file}"
  save_state "${app_root}"

  echo "Started integration test run."
  echo "PID: ${pid}"
  echo "Test: ${test_file}"
  echo "Device: ${device}"
  echo "Log: ${log_file}"
}

contains_streamlisten_harness_error() {
  local output_file="$1"
  rg -q "streamListen: \(-32602\)|VmServiceProxyGoldenFileComparator|invalid 'streamId' parameter" "${output_file}"
}

run_drive_lane() {
  local app_root="$1"
  local device="$2"
  local flavor="$3"
  local define_file="$4"
  local test_file="$5"
  local timeout_s="$6"
  local flutter_device_timeout="$7"

  local driver_file="${app_root}/test_driver/integration_test.dart"
  local created_driver=0

  if [[ ! -f "${driver_file}" ]]; then
    mkdir -p "${app_root}/test_driver"
    cat >"${driver_file}" <<'EOF'
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
EOF
    created_driver=1
  fi

  local drive_rc=0
  if timeout "${timeout_s}s" \
      fvm flutter drive --no-pub \
      --driver=test_driver/integration_test.dart \
      --target="${test_file}" \
      -d "${device}" \
      --flavor "${flavor}" \
      --dart-define-from-file="${define_file}" \
      --dart-define=DISABLE_PUSH=true \
      --no-dds \
      --device-timeout "${flutter_device_timeout}"; then
    drive_rc=0
  else
    drive_rc=$?
  fi

  if [[ "${created_driver}" -eq 1 ]]; then
    rm -f "${driver_file}" || true
    rmdir "${app_root}/test_driver" >/dev/null 2>&1 || true
  fi

  return "${drive_rc}"
}

run_test() {
  local app_root="$1"
  local device="$2"
  local app_id="$3"
  local flavor="$4"
  local define_file="$5"
  local test_file="$6"
  local timeout_s="$7"
  local skip_app_reset="${DEVICE_RUNNER_SKIP_APP_RESET:-true}"
  local integration_reporter="${DEVICE_RUNNER_REPORTER:-expanded}"
  local inner_runner_timeout_s="${DEVICE_RUNNER_INNER_TIMEOUT_SECONDS:-0}"
  local runner_mode="${DEVICE_RUNNER_MODE:-auto}"
  local flutter_device_timeout="${DEVICE_RUNNER_FLUTTER_DEVICE_TIMEOUT:-60}"

  require_cmds

  cd "${app_root}"
  echo "Started at $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "Device: ${device}"
  echo "App ID: ${app_id}"
  echo "Test: ${test_file}"
  echo "Timeout: ${timeout_s}s"
  echo "Profile: skip_app_reset=${skip_app_reset}, reporter=${integration_reporter}, inner_runner_timeout_s=${inner_runner_timeout_s}, mode=${runner_mode}, flutter_device_timeout=${flutter_device_timeout}"

  case "${runner_mode}" in
    auto|test|drive)
      ;;
    *)
      echo "FAIL ${test_file} rc=2 reason=invalid_runner_mode mode=${runner_mode}"
      return 2
      ;;
  esac

  if [[ ! -f "./tool/run_integration_test_wsl.sh" ]]; then
    echo "FAIL ${test_file} rc=2 reason=missing_runner_script"
    return 2
  fi

  adb connect "${device}" >/dev/null 2>&1 || true
  adb -s "${device}" wait-for-device >/dev/null 2>&1 || true
  adb -s "${device}" shell am force-stop "${app_id}" || true
  grant_permissions_if_installed "${device}" "${app_id}"

  local start_epoch
  start_epoch="$(date +%s)"

  if [[ "${runner_mode}" == "drive" ]]; then
    if run_drive_lane "${app_root}" "${device}" "${flavor}" "${define_file}" "${test_file}" "${timeout_s}" "${flutter_device_timeout}"; then
      local end_epoch
      end_epoch="$(date +%s)"
      echo "PASS ${test_file} lane=drive duration=$((end_epoch-start_epoch))s"
      return 0
    fi
    local drive_only_rc=$?
    local end_epoch
    end_epoch="$(date +%s)"
    echo "FAIL ${test_file} lane=drive rc=${drive_only_rc} duration=$((end_epoch-start_epoch))s"
    return "${drive_only_rc}"
  fi

  local run_capture_file
  run_capture_file="$(mktemp)"
  local test_lane_rc=0
  if timeout "${timeout_s}s" env \
      ADB_DEVICE="${device}" \
      ADB_APP_ID="${app_id}" \
      FLUTTER_INTEGRATION_FLAVOR="${flavor}" \
      INTEGRATION_DEFINE_FILE="${define_file}" \
      FLUTTER_INTEGRATION_SKIP_APP_RESET="${skip_app_reset}" \
      FLUTTER_INTEGRATION_REPORTER="${integration_reporter}" \
      FLUTTER_INTEGRATION_RUN_TIMEOUT_SECONDS="${inner_runner_timeout_s}" \
      bash ./tool/run_integration_test_wsl.sh "${test_file}" 2>&1 | tee "${run_capture_file}"; then
    local end_epoch
    end_epoch="$(date +%s)"
    rm -f "${run_capture_file}" || true
    echo "PASS ${test_file} lane=test duration=$((end_epoch-start_epoch))s"
    return 0
  fi

  test_lane_rc=$?

  if [[ "${runner_mode}" == "auto" ]] && contains_streamlisten_harness_error "${run_capture_file}"; then
    echo "Detected streamListen harness defect for ${test_file}; retrying with flutter drive lane."
    if run_drive_lane "${app_root}" "${device}" "${flavor}" "${define_file}" "${test_file}" "${timeout_s}" "${flutter_device_timeout}"; then
      local end_epoch
      end_epoch="$(date +%s)"
      rm -f "${run_capture_file}" || true
      echo "PASS ${test_file} lane=drive-fallback duration=$((end_epoch-start_epoch))s"
      return 0
    fi
    local fallback_rc=$?
    local end_epoch
    end_epoch="$(date +%s)"
    rm -f "${run_capture_file}" || true
    echo "FAIL ${test_file} lane=drive-fallback rc=${fallback_rc} duration=$((end_epoch-start_epoch))s"
    return "${fallback_rc}"
  fi

  local end_epoch
  end_epoch="$(date +%s)"
  rm -f "${run_capture_file}" || true
  echo "FAIL ${test_file} lane=test rc=${test_lane_rc} duration=$((end_epoch-start_epoch))s"
  return "${test_lane_rc}"
}

status_run() {
  if [[ $# -lt 1 ]]; then
    usage
    exit 1
  fi
  local app_root
  app_root="$(abs_path "$1")"
  if ! load_state "${app_root}"; then
    exit 1
  fi

  echo "Test: ${TEST_FILE}"
  echo "Device: ${DEVICE}"
  echo "Started: ${STARTED_AT}"
  echo "Timeout: ${TIMEOUT_S}s"
  echo "PID: ${PID}"
  echo "Log: ${LOG_FILE}"

  if is_run_active "${PID}" "${TEST_FILE}"; then
    echo "Process: running"
  else
    echo "Process: finished"
  fi

  print_summary "${LOG_FILE}"
}

wait_run() {
  if [[ $# -lt 1 ]]; then
    usage
    exit 1
  fi
  local app_root
  app_root="$(abs_path "$1")"
  if ! load_state "${app_root}"; then
    exit 1
  fi

  echo "Waiting for PID ${PID} (${TEST_FILE})..."
  while is_run_active "${PID}" "${TEST_FILE}"; do
    sleep 5
  done
  echo "Process finished."
  status_run "${app_root}"
}

stop_run() {
  if [[ $# -lt 1 ]]; then
    usage
    exit 1
  fi
  local app_root
  app_root="$(abs_path "$1")"
  if ! load_state "${app_root}"; then
    exit 1
  fi

  if is_run_active "${PID}" "${TEST_FILE}"; then
    kill "${PID}" >/dev/null 2>&1 || true
    sleep 1
    if kill -0 "${PID}" >/dev/null 2>&1; then
      kill -9 "${PID}" >/dev/null 2>&1 || true
    fi
    pkill -f "fvm flutter test .*${TEST_FILE}" >/dev/null 2>&1 || true
    pkill -f "flutter_tools\\.snapshot test .*${TEST_FILE}" >/dev/null 2>&1 || true
    pkill -f "fvm flutter drive .*${TEST_FILE}" >/dev/null 2>&1 || true
    pkill -f "flutter_tools\\.snapshot drive .*${TEST_FILE}" >/dev/null 2>&1 || true
    echo "Stopped PID ${PID}."
  else
    echo "Process already finished."
  fi
  status_run "${app_root}"
}

case "${1:-}" in
  start)
    shift
    start_run "$@"
    ;;
  status)
    shift
    status_run "$@"
    ;;
  wait)
    shift
    wait_run "$@"
    ;;
  stop)
    shift
    stop_run "$@"
    ;;
  _run)
    shift
    run_test "$@"
    ;;
  *)
    usage
    exit 1
    ;;
esac
