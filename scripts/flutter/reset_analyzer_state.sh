#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  reset_analyzer_state.sh [--with-flutter-clean] [--skip-pub-get] [--skip-analyze] [--cleanup-only]

Options:
  --with-flutter-clean  Run `fvm flutter clean` before rebuilding local state.
  --skip-pub-get        Skip `fvm flutter pub get` after clearing caches.
  --skip-analyze        Skip the final analyzer warmup command.
  --cleanup-only        Perform cleanup only; do not run `pub get` or warm the analyzer afterward.
  -h, --help            Show this help message.

Notes:
  - Run this from `flutter-app/` root or the environment root that contains `flutter-app/`.
  - This clears hidden analyzer/plugin caches under `~/.dartServer/`.
  - This also clears generated `build/` and `.dart_tool/` residue inside the Flutter workspace.
  - The first analyzer run after reset can be slower while plugin AOT artifacts rebuild.
  - After a reset, allow the first analyzer run a long silent warmup window before interrupting it.
    In this workspace, wait at least 10 minutes or until the process clearly exits before treating
    the post-reset analyzer as hung.
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

for arg in "$@"; do
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
  log_info "running fvm flutter pub get..."
  fvm flutter pub get
fi

if [[ "${SKIP_ANALYZE}" -eq 0 ]]; then
  log_info "warming analyzer with the official root command..."
  log_info "note: the first post-reset analyzer run may stay silent for several minutes; allow at least 10 minutes before interrupting it."
  fvm dart analyze --format machine
fi

popd >/dev/null

log_info "done."
