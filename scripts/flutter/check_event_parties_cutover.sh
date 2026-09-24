#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

status=0

scan() {
  local label="$1"
  local pattern="$2"
  shift 2
  local output
  output="$(rg -n "$pattern" "$@" || true)"
  if [[ -n "$output" ]]; then
    status=1
    echo "[FAIL] $label"
    echo "$output"
    echo
  else
    echo "[OK] $label"
  fi
}

scan_filtered() {
  local label="$1"
  local include_pattern="$2"
  local exclude_pattern="$3"
  shift 3
  local output
  output="$(rg -n "$include_pattern" "$@" | rg -v "$exclude_pattern" || true)"
  if [[ -n "$output" ]]; then
    status=1
    echo "[FAIL] $label"
    echo "$output"
    echo
  else
    echo "[OK] $label"
  fi
}

echo "Flutter event-parties cutover scan"
echo

scan "immersive event detail still references legacy event.artists" \
  'event\.artists\b' \
  lib/presentation/tenant_public/schedule/screens/immersive_event_detail

scan "tenant-admin transport still emits or reads artist_ids payload" \
  '\bartist_ids\b' \
  lib/infrastructure/dal/dao/tenant_admin

scan "event DTO still merges linked profiles from artists or venue fallback" \
  'venueRaw:|artistsRaw:|linkedAccountProfiles.*venue|linkedAccountProfiles.*artists' \
  lib/infrastructure/dal/dto/schedule/event_dto.dart

exit "$status"
