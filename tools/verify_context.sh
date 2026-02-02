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

find_environment_root() {
  local start="$1"
  local current="$start"
  for _ in 1 2 3 4 5; do
    if [ -d "$current/foundation_documentation" ] && [ -d "$current/delphi-ai" ] && [ -d "$current/flutter-app" ] && [ -d "$current/laravel-app" ]; then
      echo "$current"
      return 0
    fi
    current="$(cd "$current/.." && pwd 2>/dev/null || echo "")"
    if [ -z "$current" ]; then
      break
    fi
  done
  return 1
}

# If invoked from inside a submodule (flutter-app/laravel-app) or a nested folder, normalize to the environment root.
if ENV_ROOT="$(find_environment_root "$REPO_ROOT" 2>/dev/null)"; then
  if [ -n "$ENV_ROOT" ]; then
    REPO_ROOT="$ENV_ROOT"
  fi
fi

declare -a errors=()
declare -a warnings=()

FIX_TODOS=false
for arg in "$@"; do
  case "$arg" in
    --fix-todos)
      FIX_TODOS=true
      ;;
  esac
done

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

check_submodule_initialized() {
  local path="$1"
  local label="$2"
  local status
  status="$(git -C "$REPO_ROOT" submodule status -- "$path" 2>/dev/null || true)"
  if [ -z "$status" ]; then
    errors+=("$label submodule missing from .gitmodules at $path")
    return
  fi
  case "${status:0:1}" in
    -)
      errors+=("$label submodule not initialized at $path (run: git submodule update --init --recursive)")
      ;;
    +)
      warnings+=("$label submodule is not at recorded commit at $path (run: git submodule update --init --recursive)")
      ;;
  esac
}

check_foundation_link() {
  local module_path="$1"
  local module_name="$2"
  local link="$module_path/foundation_documentation"
  check_symlink_target "$link" "../foundation_documentation" "$module_name foundation_documentation link"
}

check_agent_workflows() {
  local module_path="$1"
  local label="$2"
  local agent_dir="$module_path/.agent"
  check_path_exists "$agent_dir" "$label directory"
  if [ ! -d "$agent_dir/workflows" ]; then
    errors+=("$label workflows directory missing at $agent_dir/workflows")
  fi
}

check_agent_rules() {
  local module_path="$1"
  local label="$2"
  local agent_dir="$module_path/.agent"
  check_path_exists "$agent_dir" "$label directory"
  if [ ! -d "$agent_dir/rules" ]; then
    errors+=("$label rules directory missing at $agent_dir/rules")
  fi
}

ensure_codex_skills_link() {
  local module_path="$1"
  local label="$2"
  local codex_dir="$module_path/.codex"
  local link_path="$codex_dir/skills"
  local target="../delphi-ai/skills"

  mkdir -p "$codex_dir"
  if [ -L "$link_path" ]; then
    local actual
    actual="$(readlink "$link_path")"
    if [ "$actual" != "$target" ]; then
      rm -f "$link_path"
      ln -s "$target" "$link_path"
      warnings+=("$label .codex/skills updated to $target")
    fi
  elif [ -e "$link_path" ]; then
    rm -f "$link_path"
    ln -s "$target" "$link_path"
    warnings+=("$label .codex/skills replaced with symlink to $target")
  else
    ln -s "$target" "$link_path"
    warnings+=("$label .codex/skills created -> $target")
  fi
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

# Sync agent rules and workflows (ensures real files for IDE visibility)
if [ -f "$REPO_ROOT/delphi-ai/tools/sync_agent_rules.sh" ]; then
  bash "$REPO_ROOT/delphi-ai/tools/sync_agent_rules.sh"
fi

check_path_exists "$REPO_ROOT/foundation_documentation" "Root foundation documentation directory"
check_submodule_initialized "$REPO_ROOT/foundation_documentation" "foundation_documentation"
check_foundation_link "$REPO_ROOT/flutter-app" "flutter-app"
check_foundation_link "$REPO_ROOT/laravel-app" "laravel-app"
check_agent_workflows "$REPO_ROOT" "root .agent"
check_agent_workflows "$REPO_ROOT/flutter-app" "flutter-app .agent"
check_agent_workflows "$REPO_ROOT/laravel-app" "laravel-app .agent"
check_agent_rules "$REPO_ROOT" "root .agent"
check_agent_rules "$REPO_ROOT/flutter-app" "flutter-app .agent"
check_agent_rules "$REPO_ROOT/laravel-app" "laravel-app .agent"
ensure_codex_skills_link "$REPO_ROOT" "root"
ensure_codex_skills_link "$REPO_ROOT/flutter-app" "flutter-app"
ensure_codex_skills_link "$REPO_ROOT/laravel-app" "laravel-app"

TODOS_ACTIVE_DIR="$REPO_ROOT/foundation_documentation/todos/active"
TODOS_COMPLETED_DIR="$REPO_ROOT/foundation_documentation/todos/completed"
ensure_todos_structure() {
  mkdir -p "$TODOS_ACTIVE_DIR" "$TODOS_COMPLETED_DIR"
  touch "$TODOS_ACTIVE_DIR/.gitkeep" "$TODOS_COMPLETED_DIR/.gitkeep"
}

TODOS_MISSING=false
if [ ! -d "$TODOS_ACTIVE_DIR" ] || [ ! -d "$TODOS_COMPLETED_DIR" ]; then
  TODOS_MISSING=true
fi

if [ "$FIX_TODOS" = true ]; then
  ensure_todos_structure
elif [ "$TODOS_MISSING" = true ]; then
  if [ -t 0 ] && [ -t 1 ]; then
    printf 'Optional TODO structure missing at foundation_documentation/todos/.\n'
    read -r -p "Create it now? [y/N] " reply || true
    reply="${reply:-}"
    if [[ "$reply" =~ ^[Yy]$ ]]; then
      ensure_todos_structure
      printf 'Created foundation_documentation/todos/{active,completed} with .gitkeep files.\n'
    else
      warnings+=("Optional TODO structure missing at foundation_documentation/todos/. If you want Delphi to create it, rerun with: bash delphi-ai/tools/verify_context.sh --fix-todos")
    fi
  else
    warnings+=("Optional TODO structure missing at foundation_documentation/todos/. If you want Delphi to create it, rerun with: bash delphi-ai/tools/verify_context.sh --fix-todos")
  fi
fi

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

if [ ${#warnings[@]} -gt 0 ]; then
  printf 'Context verification WARNINGS:\n'
  for warn in "${warnings[@]}"; do
    printf ' - %s\n' "$warn"
  done
fi

echo "All required context links and directories are in place."
