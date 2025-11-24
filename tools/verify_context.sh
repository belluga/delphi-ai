#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

resolve_repo_root() {
  local dir="$1"
  while [ "$dir" != "/" ]; do
    if [ -d "$dir/foundation_documentation" ] && [ -d "$dir/flutter-app" ] && [ -d "$dir/laravel-app" ]; then
      printf '%s\n' "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

if ! REPO_ROOT="$(resolve_repo_root "$(pwd -P)")"; then
  if ! REPO_ROOT="$(resolve_repo_root "$SCRIPT_DIR")"; then
    echo "Unable to determine repository root. Run this script from within the monorepo checkout." >&2
    exit 1
  fi
fi

declare -a errors=()

check_path_exists() {
  local path="$1"
  local label="$2"
  if [ ! -e "$path" ]; then
    errors+=("$label missing at $path")
  fi
}

check_symlink_target() {
  local link_path="$1"
  local expected_target="$2"
  local label="$3"
  if [ ! -L "$link_path" ]; then
    errors+=("$label is not a symlink: $link_path")
    return
  fi
  local actual
  actual="$(readlink "$link_path")"
  if [ "$actual" != "$expected_target" ]; then
    errors+=("$label points to $actual but expected $expected_target")
  fi
}

check_module_links() {
  local module_path="$1"
  local module_name="$2"
  check_symlink_target "$module_path/foundation_documentation" "../foundation_documentation" "$module_name foundation_documentation link"
  check_symlink_target "$module_path/delphi-ai" "../delphi-ai" "$module_name delphi-ai link"

  local agent_target
  case "$module_name" in
    flutter-app)
      agent_target="../delphi-ai/templates/agents/flutter.md"
      check_symlink_target "$module_path/scripts" "../delphi-ai/scripts/flutter" "$module_name scripts link"
      ;;
    laravel-app)
      agent_target="../delphi-ai/templates/agents/laravel.md"
      ;;
  esac
  check_symlink_target "$module_path/AGENTS.md" "$agent_target" "$module_name AGENTS.md link"
}

echo "Running Delphi context verification..."

check_path_exists "$REPO_ROOT/foundation_documentation" "Root foundation documentation directory"
check_module_links "$REPO_ROOT/flutter-app" "flutter-app"
check_module_links "$REPO_ROOT/laravel-app" "laravel-app"

# Validate Laravel env connection names are distinct
check_env_connection_uniqueness() {
  local env_file="$REPO_ROOT/laravel-app/.env"
  if [ ! -f "$env_file" ]; then
    return
  fi

  local get_env_value
  get_env_value() {
    local key="$1"
    local file="$2"
    # Take last occurrence, strip surrounding quotes if present
    local line
    line="$(grep -E "^${key}=" "$file" | tail -n 1)"
    line="${line#${key}=}"
    line="${line%\"}"
    line="${line#\"}"
    printf '%s' "$line"
  }

  local db_conn db_conn_landlord db_conn_tenants
  db_conn="$(get_env_value "DB_CONNECTION" "$env_file")"
  db_conn_landlord="$(get_env_value "DB_CONNECTION_LANDLORD" "$env_file")"
  db_conn_tenants="$(get_env_value "DB_CONNECTION_TENANTS" "$env_file")"

  if [ -n "$db_conn" ] && [ -n "$db_conn_landlord" ] && [ -n "$db_conn_tenants" ]; then
    if [ "$db_conn" = "$db_conn_landlord" ] || [ "$db_conn" = "$db_conn_tenants" ] || [ "$db_conn_landlord" = "$db_conn_tenants" ]; then
      errors+=("DB connection names must be distinct (DB_CONNECTION, DB_CONNECTION_LANDLORD, DB_CONNECTION_TENANTS). Current values: \"$db_conn\", \"$db_conn_landlord\", \"$db_conn_tenants\"")
    fi
  fi
}

check_env_connection_uniqueness

if [ ${#errors[@]} -gt 0 ]; then
  printf 'Context verification FAILED:\n'
  for err in "${errors[@]}"; do
    printf ' - %s\n' "$err"
  done
  exit 1
fi

echo "All required context links and directories are in place."
