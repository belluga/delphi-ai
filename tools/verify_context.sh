#!/usr/bin/env bash
set -euo pipefail

SCRIPT_ROOT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"

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

if [[ "$(pwd)" == "$SCRIPT_ROOT" || "$(pwd)" == "$SCRIPT_ROOT/"* ]] \
  && [ ! -d "$SCRIPT_ROOT/foundation_documentation" ] \
  && [ -f "$SCRIPT_ROOT/main_instructions.md" ] \
  && [ -d "$SCRIPT_ROOT/skills" ] \
  && [ -d "$SCRIPT_ROOT/rules" ] \
  && [ -d "$SCRIPT_ROOT/workflows" ]; then
  cat <<'EOF' >&2
verify_context.sh is for downstream project environments, not the canonical delphi-ai repository.
For Delphi self-maintenance, use:
  bash self_check.sh
EOF
  exit 1
fi

declare -a errors=()
declare -a warnings=()
declare -A validated_skill_dirs=()

REPAIR_MODE=false
FIX_TODOS=false
RUN_ADHERENCE_SYNC=false

usage() {
  cat <<'EOF'
Usage: bash delphi-ai/verify_context.sh [--repair] [--fix-todos] [--with-adherence-sync]

Options:
  --repair               Repair known Delphi-managed links/artifacts, then rerun verification in the same pass.
  --fix-todos            Create foundation_documentation/todos/{active,completed}; implies --repair.
  --with-adherence-sync  Also run delphi-ai/verify_adherence_sync.sh after readiness verification.
  -h, --help             Show this help text.
EOF
}

for arg in "$@"; do
  case "$arg" in
    --repair)
      REPAIR_MODE=true
      ;;
    --fix-todos)
      FIX_TODOS=true
      REPAIR_MODE=true
      ;;
    --with-adherence-sync)
      RUN_ADHERENCE_SYNC=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$arg" >&2
      usage
      exit 1
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
  local relative_path="$path"
  local status

  if [[ "$relative_path" == "$REPO_ROOT/"* ]]; then
    relative_path="${relative_path#"$REPO_ROOT"/}"
  fi

  status="$(git -C "$REPO_ROOT" submodule status -- "$relative_path" 2>/dev/null || true)"
  if [ -z "$status" ]; then
    errors+=("$label submodule missing from .gitmodules at $relative_path")
    return
  fi
  case "${status:0:1}" in
    -)
      errors+=("$label submodule not initialized at $relative_path (run: git submodule update --init --recursive)")
      ;;
    +)
      if [ "$ignore_recorded_commit_mismatch" != "true" ]; then
        warnings+=("$label submodule is not at recorded commit at $relative_path (run: git submodule update --init --recursive)")
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

ensure_symlink_path() {
  local link_path="$1"
  local target="$2"
  local label="$3"
  local parent_dir
  parent_dir="$(dirname "$link_path")"

  if [ ! -d "$parent_dir" ]; then
    if [ "$REPAIR_MODE" = true ]; then
      if ! mkdir -p "$parent_dir"; then
        errors+=("$label failed to create parent directory at $parent_dir")
        return
      fi
    else
      errors+=("$label parent directory missing at $parent_dir")
      return
    fi
  fi

  if [ -L "$link_path" ]; then
    local actual
    actual="$(readlink "$link_path")"
    if [ "$actual" != "$target" ]; then
      if [ "$REPAIR_MODE" = true ]; then
        if rm -f "$link_path" && ln -s "$target" "$link_path"; then
          warnings+=("$label updated to $target")
        else
          errors+=("$label failed to update symlink at $link_path (expected -> $target)")
        fi
      else
        errors+=("$label points to $actual but expected $target")
      fi
    fi
  elif [ -e "$link_path" ]; then
    errors+=("$label exists as a non-symlink at $link_path (expected -> $target)")
  else
    if [ "$REPAIR_MODE" = true ]; then
      if ln -s "$target" "$link_path"; then
        warnings+=("$label created -> $target")
      else
        errors+=("$label failed to create symlink at $link_path (expected -> $target)")
      fi
    else
      errors+=("$label missing at $link_path (expected symlink -> $target)")
    fi
  fi
}

ensure_link_without_clobber() {
  local parent_dir="$1"
  local link_name="$2"
  local target="$3"
  local label="$4"
  ensure_symlink_path "$parent_dir/$link_name" "$target" "$label"
}

ensure_link_in_directory() {
  local parent_dir="$1"
  local link_name="$2"
  local target="$3"
  local label="$4"
  ensure_symlink_path "$parent_dir/$link_name" "$target" "$label"
}

ensure_codex_skills_link() {
  local module_path="$1"
  local label="$2"
  ensure_symlink_path "$module_path/.codex/skills" "../delphi-ai/skills" "$label .codex/skills"
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
  local rel_prefix
  if [ "$module_path" = "$REPO_ROOT" ]; then
    rel_prefix="delphi-ai"
  else
    rel_prefix="../delphi-ai"
  fi

  # Symlink .cline/skills/ (skills are directories with SKILL.md)
  local skills_target
  if [ "$module_path" = "$REPO_ROOT" ]; then
    skills_target="../$rel_prefix/.cline/skills"
  else
    skills_target="$rel_prefix/.cline/skills"
  fi
  ensure_symlink_path "$module_path/.cline/skills" "$skills_target" "$label .cline/skills"

  # Symlink .clinerules directory (contains rules, workflows, and hooks)
  # This includes: rules (*.md), workflows/, hooks/, glob/, manual/, model-decision/
  local clinerules_target="$rel_prefix/.clinerules"
  ensure_symlink_path "$module_path/.clinerules" "$clinerules_target" "$label .clinerules"

  # Also create CLINE.md symlink at root if it doesn't exist
  local cline_md_target="$rel_prefix/CLINE.md"
  ensure_symlink_path "$module_path/CLINE.md" "$cline_md_target" "$label CLINE.md"
}

validate_cline_skills_catalog() {
  local module_path="$1"
  local label="$2"
  local skills_dir="$module_path/.cline/skills"
  local found=0
  local canonical_skills_dir="$skills_dir"

  if [ ! -d "$skills_dir" ]; then
    errors+=("$label .cline/skills directory missing at $skills_dir")
    return
  fi

  canonical_skills_dir="$(readlink -f "$skills_dir" 2>/dev/null || printf '%s' "$skills_dir")"
  if [ -n "${validated_skill_dirs[$canonical_skills_dir]:-}" ]; then
    return
  fi
  validated_skill_dirs["$canonical_skills_dir"]=1

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

if [ "$REPAIR_MODE" = true ]; then
  echo "Running Delphi context verification with repair mode..."
else
  echo "Running Delphi context verification (read-only)..."
fi

# Ensure agent rule/workflow links are present
if [ "$REPAIR_MODE" = true ] && [ -f "$REPO_ROOT/delphi-ai/tools/sync_agent_rules.sh" ]; then
  if ! bash "$REPO_ROOT/delphi-ai/tools/sync_agent_rules.sh"; then
    errors+=("Failed to align .agents/{skills,rules,workflows} via delphi-ai/tools/sync_agent_rules.sh. Check write permissions for $REPO_ROOT/{.agents,flutter-app/.agents,laravel-app/.agents}.")
  fi
fi

check_path_exists "$REPO_ROOT/foundation_documentation" "Root foundation documentation directory"
# foundation_documentation may intentionally track a floating/docs-working commit in local flows.
# Keep existence/initialization checks, but suppress recorded-commit mismatch warning.
check_submodule_initialized "$REPO_ROOT/foundation_documentation" "foundation_documentation" "true"
ensure_link_without_clobber "$REPO_ROOT" "AGENTS.md" "delphi-ai/templates/agents/root.md" "root AGENTS.md"
ensure_link_without_clobber "$REPO_ROOT" "CLINE.md" "delphi-ai/CLINE.md" "root CLINE.md"
ensure_link_without_clobber "$REPO_ROOT" "GEMINI.md" "delphi-ai/GEMINI.md" "root GEMINI.md"
ensure_link_without_clobber "$REPO_ROOT/.agents" "skills" "../delphi-ai/skills" "root Gemini skills link (.agents/skills)"
ensure_link_without_clobber "$REPO_ROOT/flutter-app" "foundation_documentation" "../foundation_documentation" "flutter-app foundation_documentation link"
ensure_link_without_clobber "$REPO_ROOT/laravel-app" "foundation_documentation" "../foundation_documentation" "laravel-app foundation_documentation link"
ensure_link_without_clobber "$REPO_ROOT/flutter-app" "delphi-ai" "../delphi-ai" "flutter-app delphi-ai link"
ensure_link_without_clobber "$REPO_ROOT/laravel-app" "delphi-ai" "../delphi-ai" "laravel-app delphi-ai link"
ensure_link_without_clobber "$REPO_ROOT/flutter-app" "AGENTS.md" "../delphi-ai/templates/agents/flutter.md" "flutter-app AGENTS.md"
ensure_link_without_clobber "$REPO_ROOT/laravel-app" "AGENTS.md" "../delphi-ai/templates/agents/laravel.md" "laravel-app AGENTS.md"
ensure_link_without_clobber "$REPO_ROOT/flutter-app" "GEMINI.md" "../delphi-ai/GEMINI.md" "flutter-app GEMINI.md"
ensure_link_without_clobber "$REPO_ROOT/laravel-app" "GEMINI.md" "../delphi-ai/GEMINI.md" "laravel-app GEMINI.md"
check_foundation_link "$REPO_ROOT/flutter-app" "flutter-app"
check_foundation_link "$REPO_ROOT/laravel-app" "laravel-app"
ensure_link_without_clobber "$REPO_ROOT/.agents" "rules" "../delphi-ai/rules/docker" "root .agents/rules"
ensure_link_without_clobber "$REPO_ROOT/.agents" "workflows" "../delphi-ai/workflows/docker" "root .agents/workflows"
ensure_link_without_clobber "$REPO_ROOT/flutter-app/.agents" "skills" "../delphi-ai/skills" "flutter-app .agents/skills"
ensure_link_without_clobber "$REPO_ROOT/flutter-app/.agents" "rules" "../delphi-ai/rules/flutter" "flutter-app .agents/rules"
ensure_link_without_clobber "$REPO_ROOT/flutter-app/.agents" "workflows" "../delphi-ai/workflows/flutter" "flutter-app .agents/workflows"
ensure_link_without_clobber "$REPO_ROOT/laravel-app/.agents" "skills" "../delphi-ai/skills" "laravel-app .agents/skills"
ensure_link_without_clobber "$REPO_ROOT/laravel-app/.agents" "rules" "../delphi-ai/rules/laravel" "laravel-app .agents/rules"
ensure_link_without_clobber "$REPO_ROOT/laravel-app/.agents" "workflows" "../delphi-ai/workflows/laravel" "laravel-app .agents/workflows"
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

if [ "$REPAIR_MODE" = true ] && [ -f "$REPO_ROOT/delphi-ai/tools/sync_cline_skill_mirrors.sh" ]; then
  if ! bash "$REPO_ROOT/delphi-ai/tools/sync_cline_skill_mirrors.sh"; then
    errors+=("Failed to synchronize curated Cline skill mirrors via delphi-ai/tools/sync_cline_skill_mirrors.sh")
  fi
fi

validate_cline_skills_catalog "$REPO_ROOT" "root"
validate_cline_skills_catalog "$REPO_ROOT/flutter-app" "flutter-app"
validate_cline_skills_catalog "$REPO_ROOT/laravel-app" "laravel-app"

if [ "$RUN_ADHERENCE_SYNC" = true ] && [ -f "$REPO_ROOT/delphi-ai/verify_adherence_sync.sh" ]; then
  if ! bash "$REPO_ROOT/delphi-ai/verify_adherence_sync.sh"; then
    errors+=("Adherence sync verification failed (delphi-ai/verify_adherence_sync.sh)")
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
  warnings+=("Optional TODO structure missing at foundation_documentation/todos/. If you want Delphi to create it, rerun with: bash delphi-ai/verify_context.sh --repair --fix-todos")
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
if [ "$RUN_ADHERENCE_SYNC" = false ] && [ -f "$REPO_ROOT/delphi-ai/verify_adherence_sync.sh" ]; then
  echo "For governance mirror validation, run: bash delphi-ai/verify_adherence_sync.sh"
fi
