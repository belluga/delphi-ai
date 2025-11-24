#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"
FLUTTER_APP_DIR="${REPO_ROOT}/flutter-app"

if ! command -v fvm flutter >/dev/null 2>&1; then
  echo "flutter command not found. Install Flutter/FVM or run this script via a Docker image that provides it." >&2
  exit 1
fi

OUTPUT_DIR="${1:-${REPO_ROOT}/web-app}"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

pushd "${FLUTTER_APP_DIR}" >/dev/null
fvm flutter pub get
fvm flutter build web --release -o "${TMP_DIR}"
popd >/dev/null

rm -f "${TMP_DIR}/favicon.ico" "${TMP_DIR}/manifest.json"
rm -rf "${TMP_DIR}/icons"

mkdir -p "${OUTPUT_DIR}"
rsync -a --delete --exclude '.git/' --exclude '.gitmodules' "${TMP_DIR}/" "${OUTPUT_DIR}/"

chmod -R a+rX "${OUTPUT_DIR}"

echo "Flutter web bundle available at: ${OUTPUT_DIR}"
