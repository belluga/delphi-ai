#!/usr/bin/env bash
set -euo pipefail

# Derive repo root based on git (preferred) or the symlink path used to invoke this script.
REPO_ROOT="$(git -C "$(pwd)" rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$REPO_ROOT" ]; then
  SYMLINK_PATH="$(dirname "${BASH_SOURCE[0]}")"
  if ROOT_DIR="$(cd "$SYMLINK_PATH/.." && pwd 2>/dev/null)"; then
    :
  else
    ROOT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"
  fi
  REPO_ROOT="$ROOT_DIR/.."
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

check_foundation_link() {
  local module_path="$1"
  local module_name="$2"
  local link="$module_path/foundation_documentation"
  check_symlink_target "$link" "../foundation_documentation" "$module_name foundation_documentation link"
}

check_agent_workflows() {
  local module_path="$1"
  local expected_target="$2"
  local label="$3"
  local agent_dir="$module_path/.agent"
  check_path_exists "$agent_dir" "$label directory"
  check_symlink_target "$agent_dir/workflows" "$expected_target" "$label workflows link"
}

check_agent_rules() {
  local module_path="$1"
  local expected_target="$2"
  local label="$3"
  local agent_dir="$module_path/.agent"
  check_path_exists "$agent_dir" "$label directory"
  check_symlink_target "$agent_dir/rules" "$expected_target" "$label rules link"
}

get_env_value() {
  local key="$1"
  local file="$2"
  # shellcheck disable=SC2046
  local line
  line="$(grep -E "^${key}=" "$file" | tail -n 1 || true)"
  if [ -n "$line" ]; then
    echo "${line#${key}=}"
  fi
}

echo "Running Delphi context verification..."

check_path_exists "$REPO_ROOT/foundation_documentation" "Root foundation documentation directory"
check_foundation_link "$REPO_ROOT/flutter-app" "flutter-app"
check_foundation_link "$REPO_ROOT/laravel-app" "laravel-app"
check_agent_workflows "$REPO_ROOT" "../delphi-ai/workflows/docker" "root .agent"
check_agent_workflows "$REPO_ROOT/flutter-app" "../../delphi-ai/workflows/flutter" "flutter-app .agent"
check_agent_workflows "$REPO_ROOT/laravel-app" "../../delphi-ai/workflows/laravel" "laravel-app .agent"
check_agent_rules "$REPO_ROOT" "../delphi-ai/rules/docker" "root .agent"
check_agent_rules "$REPO_ROOT/flutter-app" "../../delphi-ai/rules/flutter" "flutter-app .agent"
check_agent_rules "$REPO_ROOT/laravel-app" "../../delphi-ai/rules/laravel" "laravel-app .agent"

ROOT_ENV="$REPO_ROOT/.env"
if [ -f "$ROOT_ENV" ]; then
  project_name_val="$(get_env_value "PROJECT_NAME" "$ROOT_ENV")"
  project_prefix_val="$(get_env_value "PROJECT_PREFIX" "$ROOT_ENV")"
  certbot_email_val="$(get_env_value "CERTBOT_EMAIL" "$ROOT_ENV")"

  if [ "$project_name_val" = "project_name" ] || [ -z "${project_name_val:-}" ]; then
    errors+=(".env PROJECT_NAME is unset or still 'project_name' placeholder")
  fi
  if [ "$project_prefix_val" = "project_prefix" ] || [ -z "${project_prefix_val:-}" ]; then
    errors+=(".env PROJECT_PREFIX is unset or still 'project_prefix' placeholder")
  fi
  if [ "$certbot_email_val" = "email" ] || [ -z "${certbot_email_val:-}" ]; then
    errors+=(".env CERTBOT_EMAIL is unset or still 'email' placeholder")
  fi
else
  errors+=("Root .env missing at $ROOT_ENV (required for readiness)")
fi

if [ ${#errors[@]} -gt 0 ]; then
  printf 'Context verification FAILED:\n'
  for err in "${errors[@]}"; do
    printf ' - %s\n' "$err"
  done
  exit 1
fi

echo "All required context links and directories are in place."
