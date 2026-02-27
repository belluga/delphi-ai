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
  # Preserve governance/deploy repo files while refreshing only the generated bundle.
  # Use --exclude patterns (recursive) so rsync --delete never wipes .github/workflows, tests, etc.
  RSYNC_ARGS+=(
    --exclude '.github/***'
    --exclude '.gitignore'
    --exclude 'build_metadata.json'
    --exclude 'package.json'
    --exclude 'package-lock.json'
    --exclude 'playwright.config.js'
    --exclude 'tests/***'
  )
fi

rsync "${RSYNC_ARGS[@]}" "${TMP_DIR}/" "${OUTPUT_DIR}/"

chmod -R a+rX "${OUTPUT_DIR}"

echo "Flutter web bundle available at: ${OUTPUT_DIR} (lane: ${LANE})"

resolve_landlord_domain() {
  local lane_file="$1"
  local override_file="$2"

  # Avoid relying on jq for local builds; resolve via Python (available in CI and dev machines).
  # Returns empty string when missing/unreadable.
  local read_json_key
  read_json_key() {
    local file="$1"
    local key="$2"
    python3 - "$file" "$key" <<'PY' 2>/dev/null || true
import json, sys
path = sys.argv[1]
key = sys.argv[2]
try:
  with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)
except Exception:
  raise SystemExit(0)
value = data.get(key)
if value is None:
  raise SystemExit(0)
if isinstance(value, str):
  v = value.strip()
  if v:
    print(v)
PY
  }

  local from_override=""
  if [[ -f "${override_file}" ]]; then
    from_override="$(read_json_key "${override_file}" "LANDLORD_DOMAIN")"
  fi
  if [[ -n "${from_override}" && "${from_override}" != "null" ]]; then
    printf '%s' "${from_override}"
    return 0
  fi

  local from_lane=""
  from_lane="$(read_json_key "${lane_file}" "LANDLORD_DOMAIN")"
  if [[ -n "${from_lane}" && "${from_lane}" != "null" ]]; then
    printf '%s' "${from_lane}"
    return 0
  fi

  return 1
}

inject_landlord_host() {
  local index_html="$1"
  local landlord_domain="$2"
  local build_sha="$3"

  if [[ ! -f "${index_html}" ]]; then
    echo "ERROR: index.html not found for landlord host injection: ${index_html}" >&2
    exit 1
  fi

  local landlord_host=""
  landlord_host="$(
    python3 - "${landlord_domain}" <<'PY'
import sys
from urllib.parse import urlparse
u = sys.argv[1]
p = urlparse(u)
if not p.scheme or not p.netloc:
  raise SystemExit(1)
if not p.hostname:
  raise SystemExit(1)
print(p.hostname.lower())
PY
  )"

  if [[ ! "${landlord_host}" =~ ^[a-z0-9.-]+$ ]]; then
    echo "ERROR: invalid landlord host parsed from LANDLORD_DOMAIN (${landlord_domain}): ${landlord_host}" >&2
    exit 1
  fi

  python3 - "${index_html}" "${landlord_host}" "${build_sha}" <<'PY'
import sys, re
path = sys.argv[1]
host = sys.argv[2]
sha = sys.argv[3]
marker = "<!-- DELPHI_INJECT__LANDLORD_HOST__ -->"
inject = f'<script>window.__LANDLORD_HOST__ = "{host}"; window.__WEB_BUILD_SHA__ = "{sha}";</script>'
with open(path, "r", encoding="utf-8") as f:
  s = f.read()
if marker in s:
  s = s.replace(marker, inject, 1)
else:
  s = re.sub(r"(<head[^>]*>)", r"\\1\\n  " + inject, s, count=1, flags=re.I)
with open(path, "w", encoding="utf-8") as f:
  f.write(s)
PY
}

landlord_domain="$(resolve_landlord_domain "${LANE_FILE}" "${LOCAL_OVERRIDE_FILE}" || true)"
if [[ -z "${landlord_domain}" ]]; then
  echo "ERROR: LANDLORD_DOMAIN is required (set it in ${LANE_FILE} or ${LOCAL_OVERRIDE_FILE})." >&2
  exit 1
fi

build_sha="$(git -C "${FLUTTER_APP_DIR}" rev-parse --short HEAD 2>/dev/null || true)"
if [[ -z "${build_sha}" ]]; then
  build_sha="local"
fi

inject_landlord_host "${OUTPUT_DIR}/index.html" "${landlord_domain}" "${build_sha}"
