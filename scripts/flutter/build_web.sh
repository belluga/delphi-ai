#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  build_web.sh [output_dir] [lane] [--no-preserve] [--clean-output]

Args:
  output_dir     Destination folder to receive the Flutter web bundle.
  lane           dev|stage|main (maps to config/defines/<lane>.json).

Options:
  --no-preserve  Replace output_dir contents entirely (no protected files).
  --clean-output Attempt to remove common local test artifacts in output_dir
                 (node_modules/test-results/playwright-report) before rsync
                 --delete. Uses Docker fallback if files are root-owned.

Env:
  PRESERVE_OUTPUT=1|0   (default: 1)
  CLEAN_OUTPUT=1|0      (default: 0)
EOF
}

SCRIPT_SOURCE="${BASH_SOURCE[0]}"
if command -v readlink >/dev/null 2>&1; then
  SCRIPT_SOURCE="$(readlink -f "${SCRIPT_SOURCE}")"
fi
SCRIPT_DIR="$(cd -- "$(dirname -- "${SCRIPT_SOURCE}")" && pwd)"

cleanup_output_test_artifacts() {
  local output_dir="$1"

  local leftovers=(
    "${output_dir}/.last_build_id"
    "${output_dir}/node_modules"
    "${output_dir}/test-results"
    "${output_dir}/playwright-report"
  )

  local any_present=0
  for path in "${leftovers[@]}"; do
    if [[ -e "${path}" ]]; then
      any_present=1
      break
    fi
  done

  if [[ "${any_present}" -eq 0 ]]; then
    return 0
  fi

  echo "Cleaning output test artifacts (node_modules/test-results/playwright-report)..."

  local failed=0
  for path in "${leftovers[@]}"; do
    if [[ -e "${path}" ]]; then
      rm -rf "${path}" 2>/dev/null || failed=1
    fi
  done

  if [[ "${failed}" -eq 0 ]]; then
    return 0
  fi

  # Fallback for root-owned artifacts (commonly created by Docker-based tooling).
  if command -v docker >/dev/null 2>&1; then
    echo "Some artifacts were not removable (likely root-owned). Cleaning via Docker..."
    docker run --rm \
      -v "${output_dir}:/work" \
      alpine:3.20 \
      sh -lc 'rm -rf /work/.last_build_id /work/node_modules /work/test-results /work/playwright-report' || true
  fi
}

find_repo_root() {
  local dir="$1"
  while [ "$dir" != "/" ]; do
    if [ -f "${dir}/.gitmodules" ]; then
      echo "${dir}"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

CWD="$(pwd)"
if [ -f "${CWD}/pubspec.yaml" ] && [ -d "${CWD}/lib" ]; then
  FLUTTER_APP_DIR="${CWD}"
  REPO_ROOT="$(cd -- "${CWD}/.." && pwd)"
else
  REPO_ROOT="$(find_repo_root "${CWD}" || true)"
  if [ -n "${REPO_ROOT}" ]; then
    FLUTTER_APP_DIR="${REPO_ROOT}/flutter-app"
  else
    REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../../.." && pwd)"
    FLUTTER_APP_DIR="${REPO_ROOT}/flutter-app"
  fi
fi

if ! command -v fvm flutter >/dev/null 2>&1; then
  echo "flutter command not found. Install Flutter/FVM or run this script via a Docker image that provides it." >&2
  exit 1
fi

OUTPUT_DIR="${1:-${REPO_ROOT}/web-app}"
LANE="${2:-dev}"
PRESERVE_OUTPUT="${PRESERVE_OUTPUT:-1}"
CLEAN_OUTPUT="${CLEAN_OUTPUT:-0}"

if [[ "${3:-}" == "--help" || "${3:-}" == "-h" || "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

if [[ "${3:-}" == "--no-preserve" ]]; then
  PRESERVE_OUTPUT=0
elif [[ "${3:-}" == "--clean-output" ]]; then
  CLEAN_OUTPUT=1
elif [[ -n "${3:-}" ]]; then
  echo "Unknown option: ${3}" >&2
  usage >&2
  exit 1
fi

if [[ "${4:-}" == "--no-preserve" ]]; then
  PRESERVE_OUTPUT=0
elif [[ "${4:-}" == "--clean-output" ]]; then
  CLEAN_OUTPUT=1
elif [[ -n "${4:-}" ]]; then
  echo "Unknown option: ${4}" >&2
  usage >&2
  exit 1
fi

LANE_FILE="${FLUTTER_APP_DIR}/config/defines/${LANE}.json"
LOCAL_OVERRIDE_FILE="${FLUTTER_APP_DIR}/config/defines/local.override.json"

if [ ! -f "${LANE_FILE}" ]; then
  echo "Define file not found for lane '${LANE}': ${LANE_FILE}" >&2
  echo "Usage: scripts/build_web.sh [output_dir] [lane]" >&2
  exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

pushd "${FLUTTER_APP_DIR}" >/dev/null
fvm flutter pub get
build_cmd=(
  fvm flutter build web
  --release
  --no-tree-shake-icons
  --dart-define-from-file="${LANE_FILE}"
  -o "${TMP_DIR}"
)

if [ -f "${LOCAL_OVERRIDE_FILE}" ]; then
  build_cmd+=(--dart-define-from-file="${LOCAL_OVERRIDE_FILE}")
fi

"${build_cmd[@]}"
popd >/dev/null

rm -f "${TMP_DIR}/favicon.ico" "${TMP_DIR}/manifest.json"
rm -rf "${TMP_DIR}/icons"

mkdir -p "${OUTPUT_DIR}"

if [[ "${CLEAN_OUTPUT}" == "1" ]]; then
  cleanup_output_test_artifacts "${OUTPUT_DIR}"
fi

RSYNC_ARGS=(
  -a
  --delete
  --exclude '.git' --exclude '.git/' --exclude '.gitmodules' --exclude '.last_build_id'
)

if [[ "${PRESERVE_OUTPUT}" == "1" ]]; then
  # Protect common non-bundle files if they exist in the output directory.
  # This keeps deploy/governance assets intact while refreshing the generated web bundle.
  RSYNC_ARGS+=(
    --filter='P .github/'
    --filter='P .gitignore'
    --filter='P build_metadata.json'
    --filter='P package.json'
    --filter='P package-lock.json'
    --filter='P playwright.config.js'
    --filter='P tests/'
  )
fi

rsync "${RSYNC_ARGS[@]}" "${TMP_DIR}/" "${OUTPUT_DIR}/"

chmod -R a+rX "${OUTPUT_DIR}"

echo "Flutter web bundle available at: ${OUTPUT_DIR} (lane: ${LANE})"
