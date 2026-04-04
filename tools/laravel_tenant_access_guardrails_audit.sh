#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: laravel_tenant_access_guardrails_audit.sh [--repo <path>] [--path <path> ...]

Static tenant-route guardrail audit for Laravel route files. The tool checks:
- whether tenant route files with `auth:sanctum` also reference `CheckTenantAccess`;
- whether account middleware appears in the scan scope;
- whether `Route::domain('{...}')` placeholders exist and therefore need controller-signature review.

Options:
  --repo <path>          Repository root. Defaults to current directory.
  --path <path>          Route file or directory to scan. Repeat as needed.
  -h, --help             Show this help text.

If no explicit path is provided, the tool scans:
  laravel-app/routes/api/*tenant*.php

Exit codes:
  0  No static guardrail blockers were found.
  2  One or more files contain `auth:sanctum` without `CheckTenantAccess`.
  1  Operational error (invalid repo/path, no route files found, missing rg, etc.).
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

command -v rg >/dev/null 2>&1 || die "ripgrep (rg) is required"

REPO_INPUT="."
declare -a SCAN_PATH_INPUTS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --repo)
      [ $# -ge 2 ] || die "missing value for --repo"
      REPO_INPUT="$2"
      shift 2
      ;;
    --path)
      [ $# -ge 2 ] || die "missing value for --path"
      SCAN_PATH_INPUTS+=("$2")
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

REPO_ROOT="$(git -C "$REPO_INPUT" rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$REPO_ROOT" ]; then
  REPO_ROOT="$(cd "$REPO_INPUT" 2>/dev/null && pwd || true)"
fi
[ -n "$REPO_ROOT" ] || die "unable to resolve repository root from: $REPO_INPUT"

declare -a ROUTE_FILES=()
if [ "${#SCAN_PATH_INPUTS[@]}" -gt 0 ]; then
  for path in "${SCAN_PATH_INPUTS[@]}"; do
    if [[ "$path" = /* ]]; then
      resolved="$path"
    else
      resolved="$REPO_ROOT/$path"
    fi
    if [ -d "$resolved" ]; then
      while IFS= read -r file; do
        [ -n "$file" ] || continue
        ROUTE_FILES+=("$file")
      done < <(find "$resolved" -type f -name '*.php' | sort)
    elif [ -f "$resolved" ]; then
      ROUTE_FILES+=("$resolved")
    fi
  done
else
  while IFS= read -r file; do
    [ -n "$file" ] || continue
    ROUTE_FILES+=("$file")
  done < <(find "$REPO_ROOT/laravel-app/routes/api" -maxdepth 1 -type f -name '*tenant*.php' 2>/dev/null | sort)
fi

[ "${#ROUTE_FILES[@]}" -gt 0 ] || die "no route files found in scan scope"

declare -a BLOCKING_FILES=()
declare -a ACCOUNT_HINTS=()
declare -a DOMAIN_PLACEHOLDER_HINTS=()
declare -a CLEAN_FILES=()

line_has_nearby_guard() {
  local auth_line="$1"
  shift
  local guard_lines=("$@")
  local guard_line

  for guard_line in "${guard_lines[@]}"; do
    if [ "$guard_line" -ge $((auth_line - 2)) ] && [ "$guard_line" -le $((auth_line + 2)) ]; then
      return 0
    fi
  done

  return 1
}

for file in "${ROUTE_FILES[@]}"; do
  auth_hits="$(rg -n 'auth:sanctum' "$file" || true)"
  guard_hits="$(rg -n 'CheckTenantAccess' "$file" || true)"
  account_hits="$(rg -n '\baccount\b' "$file" || true)"
  domain_hits="$(rg -n 'Route::domain\(\s*['"'"'"]\{' "$file" || true)"

  if [ -n "$account_hits" ]; then
    ACCOUNT_HINTS+=("$file")
  fi
  if [ -n "$domain_hits" ]; then
    DOMAIN_PLACEHOLDER_HINTS+=("$file")
  fi

  declare -a auth_line_numbers=()
  declare -a guard_line_numbers=()

  if [ -n "$auth_hits" ]; then
    while IFS= read -r hit; do
      [ -n "$hit" ] || continue
      auth_line_numbers+=("${hit%%:*}")
    done <<< "$auth_hits"
  fi

  if [ -n "$guard_hits" ]; then
    while IFS= read -r hit; do
      [ -n "$hit" ] || continue
      guard_line_numbers+=("${hit%%:*}")
    done <<< "$guard_hits"
  fi

  unguarded_auth=false
  if [ "${#auth_line_numbers[@]}" -gt 0 ]; then
    for auth_line in "${auth_line_numbers[@]}"; do
      if ! line_has_nearby_guard "$auth_line" "${guard_line_numbers[@]}"; then
        unguarded_auth=true
        break
      fi
    done
  fi

  if [ "$unguarded_auth" = true ]; then
    BLOCKING_FILES+=("$file")
  else
    CLEAN_FILES+=("$file")
  fi
done

print_array_block() {
  local title="$1"
  shift
  local items=("$@")
  printf '%s\n' "$title"
  if [ "${#items[@]}" -eq 0 ]; then
    printf '  - none\n'
    return
  fi
  local item
  for item in "${items[@]}"; do
    printf '  - %s\n' "$item"
  done
}

printf 'Laravel Tenant Access Guardrails Audit\n'
printf 'Repository: %s\n' "$REPO_ROOT"
printf '\n'

print_array_block "Route files scanned:" "${ROUTE_FILES[@]}"
printf '\n'
print_array_block "Blocking files (auth:sanctum without CheckTenantAccess):" "${BLOCKING_FILES[@]}"
printf '\n'
print_array_block "Files with account-middleware hints:" "${ACCOUNT_HINTS[@]}"
printf '\n'
print_array_block "Files with Route::domain('{...}') placeholders:" "${DOMAIN_PLACEHOLDER_HINTS[@]}"
printf '\n'
print_array_block "Files without static guardrail blocker:" "${CLEAN_FILES[@]}"
printf '\n'

if [ "${#BLOCKING_FILES[@]}" -gt 0 ]; then
  printf 'Action: add CheckTenantAccess coverage before treating tenant-auth routes as compliant.\n'
  exit 2
fi

printf 'Action: if Route::domain placeholders exist, manually verify controller signatures place domain params before path params.\n'
