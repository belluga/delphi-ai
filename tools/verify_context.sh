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
  local ignore_recorded_commit_mismatch="${3:-false}"
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
      if [ "$ignore_recorded_commit_mismatch" != "true" ]; then
        warnings+=("$label submodule is not at recorded commit at $path (run: git submodule update --init --recursive)")
      fi
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

ensure_link_in_directory() {
  local parent_dir="$1"
  local link_name="$2"
  local target="$3"
  local label="$4"
  local link_path="$parent_dir/$link_name"

  mkdir -p "$parent_dir"
  if [ -L "$link_path" ]; then
    local actual
    actual="$(readlink "$link_path")"
    if [ "$actual" != "$target" ]; then
      rm -f "$link_path"
      ln -s "$target" "$link_path"
      warnings+=("$label updated to $target")
    fi
  elif [ -e "$link_path" ]; then
    rm -f "$link_path"
    ln -s "$target" "$link_path"
    warnings+=("$label replaced with symlink to $target")
  else
    ln -s "$target" "$link_path"
    warnings+=("$label created -> $target")
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

# Ensure Cline artifacts are properly symlinked
# Per Cline documentation:
# - Skills: .cline/skills/ (directories with SKILL.md)
# - Workflows: .clinerules/workflows/ (markdown files)
# - Hooks: .clinerules/hooks/ (executable scripts)
# - Rules: .clinerules/ (markdown files, auto-loaded)
ensure_cline_artifacts() {
  local module_path="$1"
  local label="$2"
  local delphi_path="$module_path/delphi-ai"
  local cline_dir="$module_path/.cline"

  # Determine relative path based on whether this is root or a submodule.
  # Root repo can use a real delphi-ai directory; submodules should expose a symlink.
  local rel_prefix
  if [ "$module_path" = "$REPO_ROOT" ]; then
    rel_prefix="delphi-ai"
  else
    if [ -L "$delphi_path" ]; then
      local delphi_actual
      delphi_actual="$(readlink "$delphi_path")"
      if [ "$delphi_actual" != "../delphi-ai" ]; then
        warnings+=("$label delphi-ai symlink points to $delphi_actual but expected ../delphi-ai")
      fi
    elif [ -d "$delphi_path" ]; then
      warnings+=("$label has local delphi-ai directory; expected symlink to ../delphi-ai for shared updates")
    else
      warnings+=("$label delphi-ai link missing; Cline artifacts require delphi-ai path")
      return
    fi
    rel_prefix="../delphi-ai"
  fi

  # Create .cline directory for skills
  mkdir -p "$cline_dir"

  # Symlink .cline/skills/ (skills are directories with SKILL.md)
  local skills_path="$cline_dir/skills"
  local skills_target
  if [ "$module_path" = "$REPO_ROOT" ]; then
    skills_target="../$rel_prefix/.cline/skills"
  else
    skills_target="$rel_prefix/.cline/skills"
  fi
  if [ -L "$skills_path" ]; then
    local actual
    actual="$(readlink "$skills_path")"
    if [ "$actual" != "$skills_target" ]; then
      rm -f "$skills_path"
      ln -s "$skills_target" "$skills_path"
      warnings+=("$label .cline/skills updated to $skills_target")
    fi
  elif [ -e "$skills_path" ]; then
    rm -f "$skills_path"
    ln -s "$skills_target" "$skills_path"
    warnings+=("$label .cline/skills replaced with symlink to $skills_target")
  else
    ln -s "$skills_target" "$skills_path"
    warnings+=("$label .cline/skills created -> $skills_target")
  fi

  # Symlink .clinerules directory (contains rules, workflows, and hooks)
  # This includes: rules (*.md), workflows/, hooks/, glob/, manual/, model-decision/
  local clinerules_path="$module_path/.clinerules"
  local clinerules_target="$rel_prefix/.clinerules"
  if [ -L "$clinerules_path" ]; then
    local actual
    actual="$(readlink "$clinerules_path")"
    if [ "$actual" != "$clinerules_target" ]; then
      rm -f "$clinerules_path"
      ln -s "$clinerules_target" "$clinerules_path"
      warnings+=("$label .clinerules updated to $clinerules_target")
    fi
  elif [ -e "$clinerules_path" ]; then
    rm -f "$clinerules_path"
    ln -s "$clinerules_target" "$clinerules_path"
    warnings+=("$label .clinerules replaced with symlink to $clinerules_target")
  else
    ln -s "$clinerules_target" "$clinerules_path"
    warnings+=("$label .clinerules created -> $clinerules_target")
  fi

  # Also create CLINE.md symlink at root if it doesn't exist
  local cline_md="$module_path/CLINE.md"
  local cline_md_target="$rel_prefix/CLINE.md"
  if [ ! -e "$cline_md" ]; then
    ln -s "$cline_md_target" "$cline_md"
    warnings+=("$label CLINE.md created -> $cline_md_target")
  fi
}

validate_cline_skills_catalog() {
  local module_path="$1"
  local label="$2"
  local skills_dir="$module_path/.cline/skills"
  local found=0

  if [ ! -d "$skills_dir" ]; then
    errors+=("$label .cline/skills directory missing at $skills_dir")
    return
  fi

  while IFS= read -r -d '' skill_dir; do
    found=1
    local skill_name skill_file first_line close_line fm_name fm_description
    skill_name="$(basename "$skill_dir")"
    skill_file="$skill_dir/SKILL.md"

    if [ ! -f "$skill_file" ]; then
      errors+=("$label skill '$skill_name' missing SKILL.md at $skill_file")
      continue
    fi

    first_line="$(head -n 1 "$skill_file" || true)"
    if [ "$first_line" != "---" ]; then
      errors+=("$label skill '$skill_name' missing frontmatter opening delimiter in $skill_file")
      continue
    fi

    close_line="$(awk 'NR>1 && /^---$/ { print NR; exit }' "$skill_file")"
    if [ -z "$close_line" ]; then
      errors+=("$label skill '$skill_name' missing frontmatter closing delimiter in $skill_file")
      continue
    fi

    fm_name="$(awk '
      NR > 1 && /^---$/ { exit }
      NR > 1 && /^name:[[:space:]]*/ {
        sub(/^name:[[:space:]]*/, "")
        gsub(/^["'"'"']|["'"'"']$/, "")
        print
        exit
      }
    ' "$skill_file")"
    fm_description="$(awk '
      NR > 1 && /^---$/ { exit }
      NR > 1 && /^description:[[:space:]]*/ {
        sub(/^description:[[:space:]]*/, "")
        gsub(/^["'"'"']|["'"'"']$/, "")
        print
        exit
      }
    ' "$skill_file")"

    if [ -z "$fm_name" ]; then
      errors+=("$label skill '$skill_name' missing frontmatter field 'name' in $skill_file")
    elif [ "$fm_name" != "$skill_name" ]; then
      errors+=("$label skill '$skill_name' has frontmatter name '$fm_name' (must match directory name)")
    elif [[ ! "$fm_name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
      errors+=("$label skill '$skill_name' name '$fm_name' is not kebab-case")
    fi

    if [ -z "$fm_description" ]; then
      errors+=("$label skill '$skill_name' missing frontmatter field 'description' in $skill_file")
    elif [ "${#fm_description}" -gt 1024 ]; then
      errors+=("$label skill '$skill_name' description exceeds 1024 characters in $skill_file")
    fi
  done < <(find -L "$skills_dir" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

  if [ "$found" -eq 0 ]; then
    warnings+=("$label .cline/skills has no skill directories at $skills_dir")
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
  if ! bash "$REPO_ROOT/delphi-ai/tools/sync_agent_rules.sh"; then
    errors+=("Failed to sync .agent rules/workflows via delphi-ai/tools/sync_agent_rules.sh. Check write permissions for $REPO_ROOT/{.agent,flutter-app/.agent,laravel-app/.agent}.")
  fi
fi

check_path_exists "$REPO_ROOT/foundation_documentation" "Root foundation documentation directory"
# foundation_documentation may intentionally track a floating/docs-working commit in local flows.
# Keep existence/initialization checks, but suppress recorded-commit mismatch warning.
check_submodule_initialized "$REPO_ROOT/foundation_documentation" "foundation_documentation" "true"
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

# Canonical scripts links
ensure_link_in_directory "$REPO_ROOT/laravel-app/scripts" "delphi" "../../delphi-ai/scripts/laravel" "laravel-app/scripts/delphi"
ensure_link_in_directory "$REPO_ROOT/flutter-app" "scripts" "../delphi-ai/scripts/flutter" "flutter-app/scripts"

# Cline artifacts (symlinks to delphi-ai/.cline/*)
ensure_cline_artifacts "$REPO_ROOT" "root"
ensure_cline_artifacts "$REPO_ROOT/flutter-app" "flutter-app"
ensure_cline_artifacts "$REPO_ROOT/laravel-app" "laravel-app"
validate_cline_skills_catalog "$REPO_ROOT" "root"
validate_cline_skills_catalog "$REPO_ROOT/flutter-app" "flutter-app"
validate_cline_skills_catalog "$REPO_ROOT/laravel-app" "laravel-app"

if [ -f "$REPO_ROOT/delphi-ai/tools/verify_adherence_sync.sh" ]; then
  if ! bash "$REPO_ROOT/delphi-ai/tools/verify_adherence_sync.sh"; then
    errors+=("Adherence sync verification failed (delphi-ai/tools/verify_adherence_sync.sh)")
  fi
fi

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
