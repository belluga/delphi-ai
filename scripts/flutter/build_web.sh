#!/usr/bin/env bash
set -euo pipefail

SCRIPT_SOURCE="${BASH_SOURCE[0]}"
if command -v readlink >/dev/null 2>&1; then
  SCRIPT_SOURCE="$(readlink -f "${SCRIPT_SOURCE}")"
fi
SCRIPT_DIR="$(cd -- "$(dirname -- "${SCRIPT_SOURCE}")" && pwd)"

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

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

pushd "${FLUTTER_APP_DIR}" >/dev/null
fvm flutter pub get
fvm flutter build web --release --no-tree-shake-icons -o "${TMP_DIR}"
popd >/dev/null

rm -f "${TMP_DIR}/favicon.ico" "${TMP_DIR}/manifest.json"
rm -rf "${TMP_DIR}/icons"

mkdir -p "${OUTPUT_DIR}"
rsync -a --delete --exclude '.git' --exclude '.git/' --exclude '.gitmodules' "${TMP_DIR}/" "${OUTPUT_DIR}/"

chmod -R a+rX "${OUTPUT_DIR}"

echo "Flutter web bundle available at: ${OUTPUT_DIR}"
