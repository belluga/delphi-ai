#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  reset_analyzer_state.sh [--with-flutter-clean] [--skip-pub-get] [--skip-analyze] [--analyze-timeout SECONDS] [--cleanup-only]

Options:
  --with-flutter-clean  Run `fvm flutter clean` before rebuilding local state.
  --skip-pub-get        Skip `fvm flutter pub get` after clearing caches.
  --skip-analyze        Skip the final analyzer warmup command.
  --analyze-timeout     Bound the final analyzer warmup (default: 180 seconds).
  --cleanup-only        Perform cleanup only; do not run `pub get` or warm the analyzer afterward.
  -h, --help            Show this help message.

Notes:
  - Run this from `flutter-app/` root or the environment root that contains `flutter-app/`.
  - This clears hidden analyzer/plugin caches under `~/.dartServer/`.
  - This also clears generated `build/` and `.dart_tool/` residue inside the Flutter workspace.
  - The Flutter app and all first-party product packages are a Pub Workspace. One
    root `fvm flutter pub get` rehydrates their shared `.dart_tool` state and
    keeps the Analysis Server in a single product analysis context.
  - The lint-matrix fixture remains deliberately independent because it contains
    expected-invalid analyzer cases. It is rehydrated separately after the
    workspace so its negative-test contract remains executable without adding
    intentional failures to the product analyzer gate.
  - The final CLI warmup is strictly bounded. A timeout is a failed warmup, not a clean analyzer
    result; use the IDE analyzer diagnostics and focused tests while the environment is recovered.
  - After creating or altering analyzer rules, do not start multiple `dart analyze`
    processes in parallel until one cold rebuild completes successfully.
EOF
}

log_info() {
  echo "[reset_analyzer_state] $*"
}

remove_dir_children() {
  local dir="$1"
  mkdir -p "${dir}"
  find "${dir}" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true
}

clear_repo_generated_state() {
  find . -type d \( -name '.dart_tool' -o -name 'build' \) -prune -exec rm -rf {} + 2>/dev/null || true
  find . -type f \( -name 'custom_lint.log' -o -name 'dart_tool.log' \) -delete 2>/dev/null || true
}

rehydrate_isolated_lint_fixture() {
  local fixture_dir="tool/belluga_analysis_plugin/test_fixtures/lint_matrix"
  if [[ ! -f "${fixture_dir}/pubspec.yaml" ]]; then
    echo "Expected lint-matrix fixture manifest is missing: ${fixture_dir}/pubspec.yaml" >&2
    return 1
  fi

  log_info "rehydrating isolated lint-matrix fixture: ${fixture_dir}"
  (
    cd "${fixture_dir}"
    fvm flutter pub get
  )
}

resolve_flutter_app_dir() {
  local cwd="$1"
  if [[ -f "${cwd}/pubspec.yaml" && -d "${cwd}/lib" ]]; then
    printf '%s\n' "${cwd}"
    return 0
  fi

  if [[ -f "${cwd}/flutter-app/pubspec.yaml" && -d "${cwd}/flutter-app/lib" ]]; then
    printf '%s\n' "${cwd}/flutter-app"
    return 0
  fi

  return 1
}

WITH_FLUTTER_CLEAN=0
SKIP_PUB_GET=0
SKIP_ANALYZE=0
CLEANUP_ONLY=0
ANALYZE_TIMEOUT_SECONDS="${ANALYZE_TIMEOUT_SECONDS:-180}"

while [[ "$#" -gt 0 ]]; do
  arg="$1"
  case "${arg}" in
    --with-flutter-clean)
      WITH_FLUTTER_CLEAN=1
      ;;
    --skip-pub-get)
      SKIP_PUB_GET=1
      ;;
    --skip-analyze)
      SKIP_ANALYZE=1
      ;;
    --analyze-timeout)
      shift
      if [[ "$#" -eq 0 || ! "$1" =~ ^[1-9][0-9]*$ ]]; then
        echo "--analyze-timeout requires a positive integer number of seconds." >&2
        exit 1
      fi
      ANALYZE_TIMEOUT_SECONDS="$1"
      ;;
    --analyze-timeout=*)
      ANALYZE_TIMEOUT_SECONDS="${arg#*=}"
      if [[ ! "${ANALYZE_TIMEOUT_SECONDS}" =~ ^[1-9][0-9]*$ ]]; then
        echo "--analyze-timeout requires a positive integer number of seconds." >&2
        exit 1
      fi
      ;;
    --cleanup-only)
      CLEANUP_ONLY=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: ${arg}" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if [[ "${CLEANUP_ONLY}" -eq 1 ]]; then
  SKIP_PUB_GET=1
  SKIP_ANALYZE=1
fi

if ! command -v fvm >/dev/null 2>&1; then
  echo "fvm command not found. Install FVM before running this script." >&2
  exit 1
fi

CWD="$(pwd)"
FLUTTER_APP_DIR="$(resolve_flutter_app_dir "${CWD}" || true)"
if [[ -z "${FLUTTER_APP_DIR}" ]]; then
  echo "Could not resolve flutter-app directory from: ${CWD}" >&2
  echo "Run this script from flutter-app root or the environment root that contains flutter-app/." >&2
  exit 1
fi

log_info "flutter-app directory: ${FLUTTER_APP_DIR}"

pushd "${FLUTTER_APP_DIR}" >/dev/null

if [[ "${WITH_FLUTTER_CLEAN}" -eq 1 ]]; then
  log_info "running fvm flutter clean..."
  fvm flutter clean
fi

log_info "clearing flutter-app local analyzer state and generated build residue..."
clear_repo_generated_state

log_info "clearing hidden global analyzer/plugin caches..."
remove_dir_children "${HOME}/.dartServer/.plugin_manager"
remove_dir_children "${HOME}/.dartServer/.analysis-driver"
remove_dir_children "${HOME}/.dartServer/.pub-package-details-cache"
remove_dir_children "${HOME}/.dartServer/.instrumentation"
remove_dir_children "${HOME}/.dartServer/.prompts"

if [[ "${CLEANUP_ONLY}" -eq 1 ]]; then
  log_info "cleanup-only mode requested; skipping pub get and analyzer warmup."
  popd >/dev/null
  log_info "done."
  exit 0
fi

if [[ "${SKIP_PUB_GET}" -eq 0 ]]; then
  log_info "rehydrating the root Pub Workspace with fvm flutter pub get..."
  fvm flutter pub get
  rehydrate_isolated_lint_fixture
fi

if [[ "${SKIP_ANALYZE}" -eq 0 ]]; then
  log_info "warming analyzer with the official root command (timeout: ${ANALYZE_TIMEOUT_SECONDS}s)..."
  if timeout --foreground "${ANALYZE_TIMEOUT_SECONDS}s" fvm dart analyze --format machine; then
    :
  else
    analyzer_status=$?
    if [[ "${analyzer_status}" -eq 124 ]]; then
      echo "Analyzer warmup timed out after ${ANALYZE_TIMEOUT_SECONDS}s; no clean result was produced." >&2
    fi
    exit "${analyzer_status}"
  fi
fi

popd >/dev/null

log_info "done."
