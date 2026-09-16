#!/usr/bin/env bash

delphi_script_usage_default_delphi_root() {
  local helper_dir=""
  helper_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd 2>/dev/null || true)"
  [[ -n "$helper_dir" ]] || return 1
  cd "$helper_dir/../.." 2>/dev/null && pwd 2>/dev/null || return 1
}

delphi_script_usage_is_delphi_root() {
  local candidate="${1:-}"
  [[ -n "$candidate" ]] || return 1
  [[ -f "$candidate/tools/script_usage_record.py" ]] || return 1
  [[ -f "$candidate/tools/script_usage_summary.py" ]] || return 1
}

delphi_script_usage_find_delphi_root() {
  local start="${1:-$PWD}"
  local current="$start"

  while [[ -n "$current" && "$current" != "/" ]]; do
    if delphi_script_usage_is_delphi_root "$current"; then
      printf '%s\n' "$current"
      return 0
    fi
    current="$(cd "$current/.." 2>/dev/null && pwd 2>/dev/null || true)"
  done

  return 1
}

delphi_script_usage_now_ms() {
  if date +%s%3N >/dev/null 2>&1; then
    date +%s%3N
  else
    python3 - <<'PY'
import time
print(int(time.time() * 1000))
PY
  fi
}

delphi_script_usage_init() {
  local delphi_root=""
  local repo_root=""
  local script_id=""
  local script_path=""
  local surface=""
  local scenario="default"
  local start_dir="$PWD"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --delphi-root)
        delphi_root="${2:-}"
        shift 2
        ;;
      --repo-root)
        repo_root="${2:-}"
        shift 2
        ;;
      --script-id)
        script_id="${2:-}"
        shift 2
        ;;
      --script-path)
        script_path="${2:-}"
        shift 2
        ;;
      --surface)
        surface="${2:-}"
        shift 2
        ;;
      --scenario)
        scenario="${2:-}"
        shift 2
        ;;
      --start-dir)
        start_dir="${2:-}"
        shift 2
        ;;
      *)
        return 0
        ;;
    esac
  done

  local resolved_root=""
  if delphi_script_usage_is_delphi_root "$delphi_root"; then
    resolved_root="$(cd "$delphi_root" && pwd)"
  elif delphi_script_usage_is_delphi_root "$repo_root"; then
    resolved_root="$(cd "$repo_root" && pwd)"
  else
    resolved_root="$(delphi_script_usage_default_delphi_root || true)"
    if ! delphi_script_usage_is_delphi_root "$resolved_root"; then
      resolved_root="$(delphi_script_usage_find_delphi_root "$start_dir" || true)"
    fi
  fi

  if ! delphi_script_usage_is_delphi_root "$resolved_root"; then
    DELPHI_SCRIPT_USAGE_ENABLED=0
    return 0
  fi

  local metrics_root="${DELPHI_SCRIPT_USAGE_STATE_DIR:-artifacts/local/metrics}"

  DELPHI_SCRIPT_USAGE_ENABLED=1
  DELPHI_SCRIPT_USAGE_REPO_ROOT="$resolved_root"
  DELPHI_SCRIPT_USAGE_SCRIPT_ID="$script_id"
  DELPHI_SCRIPT_USAGE_SCRIPT_PATH="$script_path"
  DELPHI_SCRIPT_USAGE_SURFACE="$surface"
  DELPHI_SCRIPT_USAGE_SCENARIO="$scenario"
  DELPHI_SCRIPT_USAGE_START_MS="$(delphi_script_usage_now_ms)"
  DELPHI_SCRIPT_USAGE_EVENTS_PATH="${DELPHI_SCRIPT_USAGE_EVENTS_PATH:-$metrics_root/events/script-usage.jsonl}"
  DELPHI_SCRIPT_USAGE_SUMMARY_JSON_PATH="${DELPHI_SCRIPT_USAGE_SUMMARY_JSON_PATH:-$metrics_root/script-usage-summary.json}"
  DELPHI_SCRIPT_USAGE_SUMMARY_MARKDOWN_PATH="${DELPHI_SCRIPT_USAGE_SUMMARY_MARKDOWN_PATH:-$metrics_root/script-usage-summary.md}"
  declare -ag DELPHI_SCRIPT_USAGE_METADATA=()
}

delphi_script_usage_set_scenario() {
  if [[ "${DELPHI_SCRIPT_USAGE_ENABLED:-0}" != "1" ]]; then
    return 0
  fi
  DELPHI_SCRIPT_USAGE_SCENARIO="${1:-default}"
}

delphi_script_usage_add_metadata() {
  if [[ "${DELPHI_SCRIPT_USAGE_ENABLED:-0}" != "1" ]]; then
    return 0
  fi
  local key="${1:-}"
  local value="${2:-}"
  [[ -n "$key" ]] || return 0
  DELPHI_SCRIPT_USAGE_METADATA+=("${key}=${value}")
}

delphi_script_usage_capture_exit() {
  local exit_code="${1:-0}"
  if [[ "${DELPHI_SCRIPT_USAGE_ENABLED:-0}" != "1" ]]; then
    return 0
  fi

  local end_ms duration_ms
  end_ms="$(delphi_script_usage_now_ms)"
  duration_ms="$((end_ms - DELPHI_SCRIPT_USAGE_START_MS))"
  local cmd=(
    python3
    "${DELPHI_SCRIPT_USAGE_REPO_ROOT}/tools/script_usage_record.py"
    --repo-root "${DELPHI_SCRIPT_USAGE_REPO_ROOT}"
    --events-jsonl "${DELPHI_SCRIPT_USAGE_EVENTS_PATH}"
    --script-id "${DELPHI_SCRIPT_USAGE_SCRIPT_ID}"
    --script-path "${DELPHI_SCRIPT_USAGE_SCRIPT_PATH}"
    --surface "${DELPHI_SCRIPT_USAGE_SURFACE}"
    --scenario "${DELPHI_SCRIPT_USAGE_SCENARIO:-default}"
    --exit-code "${exit_code}"
    --duration-ms "${duration_ms}"
    --cwd "$PWD"
    --quiet
  )
  local item
  for item in "${DELPHI_SCRIPT_USAGE_METADATA[@]:-}"; do
    [[ -n "$item" ]] || continue
    cmd+=(--metadata "$item")
  done
  "${cmd[@]}" >/dev/null 2>&1 || true
  python3 \
    "${DELPHI_SCRIPT_USAGE_REPO_ROOT}/tools/script_usage_summary.py" \
    --repo "${DELPHI_SCRIPT_USAGE_REPO_ROOT}" \
    --events-jsonl "${DELPHI_SCRIPT_USAGE_EVENTS_PATH}" \
    --summary-json "${DELPHI_SCRIPT_USAGE_SUMMARY_JSON_PATH}" \
    --summary-markdown "${DELPHI_SCRIPT_USAGE_SUMMARY_MARKDOWN_PATH}" \
    >/dev/null 2>&1 || true
}

delphi_script_usage_install_exit_trap() {
  if [[ "${DELPHI_SCRIPT_USAGE_ENABLED:-0}" != "1" ]]; then
    return 0
  fi

  delphi_script_usage__exit_handler() {
    local status=$?
    delphi_script_usage_capture_exit "$status"
  }

  trap delphi_script_usage__exit_handler EXIT
}
