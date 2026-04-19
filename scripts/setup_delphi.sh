#!/usr/bin/env bash
set -euo pipefail

SCRIPT_ROOT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"

# Resolve repository root, normalizing submodule invocations back to the
# downstream environment root when this setup helper is called from inside
# flutter-app/ or laravel-app/.
GIT_ROOT_DETECTED=false
REPO_ROOT="$(git -C "$(pwd)" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -n "$REPO_ROOT" ]]; then
  GIT_ROOT_DETECTED=true
fi

if [[ -z "$REPO_ROOT" ]]; then
  echo "Run this script from inside the repository (git root not found)." >&2
  exit 1
fi

find_environment_root() {
  local start="$1"
  local current="$start"
  for _ in 1 2 3 4 5; do
    if [[ -d "$current/foundation_documentation" && -d "$current/delphi-ai" && -d "$current/flutter-app" && -d "$current/laravel-app" ]]; then
      echo "$current"
      return 0
    fi
    current="$(cd "$current/.." 2>/dev/null && pwd || true)"
    if [[ -z "$current" ]]; then
      break
    fi
  done
  return 1
}

SUPERPROJECT_ROOT=""
if [[ "$GIT_ROOT_DETECTED" == "true" ]]; then
  SUPERPROJECT_ROOT="$(git -C "$REPO_ROOT" rev-parse --show-superproject-working-tree 2>/dev/null || true)"
fi

if [[ -n "$SUPERPROJECT_ROOT" ]]; then
  if ENV_ROOT="$(find_environment_root "$SUPERPROJECT_ROOT" 2>/dev/null)"; then
    REPO_ROOT="$ENV_ROOT"
  fi
fi

cd "$REPO_ROOT"

info() { printf '\033[1;34m[setup]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[setup]\033[0m %s\n' "$*" >&2; }
error() { printf '\033[1;31m[setup]\033[0m %s\n' "$*" >&2; }
is_interactive() { [ -t 0 ] && [ -t 1 ]; }
declare -a setup_errors=()
declare -a setup_notes=()
CHECK_ONLY=false

usage() {
  cat <<'EOF'
Usage: bash delphi-ai/init.sh [--check]

Options:
  --check   Read-only preflight. Report blocking path conflicts without making changes.
  -h, --help  Show this help text.
EOF
}

for arg in "$@"; do
  case "$arg" in
    --check)
      CHECK_ONLY=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      error "Unknown argument: $arg"
      usage
      exit 1
      ;;
  esac
done

record_core_symlinks_issue() {
  local repo_path="$1"
  local label="$2"
  local current

  if ! git -C "$repo_path" rev-parse --show-toplevel >/dev/null 2>&1; then
    return 0
  fi

  current="$(git -C "$repo_path" config --get core.symlinks || true)"
  if [[ "$current" == "false" ]]; then
    setup_errors+=("${label} has git core.symlinks=false; tracked symlinks may materialize as plain files containing their target path (for example GEMINI.md). Set core.symlinks=true for this repo and re-checkout affected symlink paths before rerunning setup.")
    error "${label} has git core.symlinks=false. Tracked symlinks may materialize as plain files containing their target path (for example GEMINI.md). Set core.symlinks=true for this repo and re-checkout affected symlink paths before rerunning setup."
  fi
}

# --- Configure submodule URLs (interactive with defaults) ---
configure_submodule() {
  local name="$1" path="$2" override_var="$3"
  local current

  if ! git config -f .gitmodules --get "submodule.${path}.url" >/dev/null 2>&1; then
    warn "Submodule ${path} is not declared in .gitmodules; skipping."
    return
  fi

  current="$(git config -f .gitmodules --get "submodule.${path}.url" || true)"
  local prompt="Remote URL for ${name} submodule (${path})"
  local answer="${!override_var:-}"
  if [[ -z "$answer" ]]; then
    if is_interactive; then
      read -r -p "${prompt} [${current:-none}]: " answer
      if [[ -z "$answer" ]]; then
        answer="$current"
      fi
    else
      answer="$current"
    fi
  fi
  if [[ -z "$answer" ]]; then
    warn "No URL provided for ${path}; leaving existing configuration."
    return
  fi
  if [[ "$answer" != "$current" ]]; then
    info "Setting ${path} URL to ${answer}"
    git submodule set-url "$path" "$answer"
  else
    info "Keeping current ${path} URL (${current})"
  fi
  git submodule sync -- "$path"
  git submodule update --init -- "$path"
}

if [[ "$CHECK_ONLY" != "true" ]]; then
  configure_submodule "Laravel" "laravel-app" "DELPHI_LARAVEL_URL"
  configure_submodule "Flutter" "flutter-app" "DELPHI_FLUTTER_URL"
  configure_submodule "Web bundle" "web-app" "DELPHI_WEB_URL"
fi

record_core_symlinks_issue "$REPO_ROOT" "Root repository"
if [[ -d "${REPO_ROOT}/flutter-app" ]]; then
  record_core_symlinks_issue "${REPO_ROOT}/flutter-app" "flutter-app"
fi
if [[ -d "${REPO_ROOT}/laravel-app" ]]; then
  record_core_symlinks_issue "${REPO_ROOT}/laravel-app" "laravel-app"
fi

# --- Ensure Delphi-AI repo is present locally (untracked) ---
DELPHI_DIR="${REPO_ROOT}/delphi-ai"
DEFAULT_DELPHI_REPO="${DELPHI_AI_REPO:-https://github.com/belluga/delphi-ai.git}"
if [[ -d "$DELPHI_DIR" ]]; then
  info "delphi-ai directory already present."
elif [[ "$CHECK_ONLY" != "true" ]]; then
  DELPHI_REPO="${DELPHI_AI_REPO:-}"
  if [[ -z "$DELPHI_REPO" ]]; then
    if is_interactive; then
      read -r -p "Delphi-AI repository URL [${DEFAULT_DELPHI_REPO}]: " DELPHI_REPO
      DELPHI_REPO="${DELPHI_REPO:-$DEFAULT_DELPHI_REPO}"
    else
      DELPHI_REPO="$DEFAULT_DELPHI_REPO"
    fi
  fi
  info "Cloning Delphi-AI from ${DELPHI_REPO}"
  git clone "$DELPHI_REPO" "$DELPHI_DIR"
fi

# --- Helper to create/replace symlinks ---
ensure_symlink() {
  local target="$1" link="$2"

  if [[ -L "$link" ]]; then
    if [[ "$(readlink "$link" 2>/dev/null)" == "$target" ]]; then
      return 0
    fi
    setup_errors+=("$link already points to $(readlink "$link" 2>/dev/null || echo '?'), expected $target")
    error "Path conflict: $link already points somewhere else. Expected symlink -> $target. Adjust it manually and rerun."
    return 0
  elif [[ -e "$link" ]]; then
    setup_errors+=("$link exists as a non-symlink, expected $target")
    error "Path conflict: $link already exists and is not the expected symlink -> $target. Adjust it manually and rerun."
    return 0
  fi

  if [[ "$CHECK_ONLY" == "true" ]]; then
    setup_notes+=("$link would be created -> $target")
    return 0
  fi

  mkdir -p "$(dirname "$link")"
  ln -s "$target" "$link"
}

setup_module_links() {
  local module="$1" agent_template="$2"
  if [[ ! -d "${REPO_ROOT}/${module}" ]]; then
    warn "Submodule ${module} not found; skipping symlinks."
    return
  fi
  ensure_symlink "../foundation_documentation" "${REPO_ROOT}/${module}/foundation_documentation"
  ensure_symlink "../delphi-ai" "${REPO_ROOT}/${module}/delphi-ai"
  ensure_symlink "../delphi-ai/templates/agents/${agent_template}" "${REPO_ROOT}/${module}/AGENTS.md"
}

setup_codex_artifacts() {
  local module="$1"
  local base_path="$REPO_ROOT"
  if [[ -n "$module" ]]; then
    base_path="${REPO_ROOT}/${module}"
    if [[ ! -d "$base_path" ]]; then
      warn "Submodule ${module} not found; skipping Codex symlinks."
      return
    fi
  fi

  if [[ "$CHECK_ONLY" == "true" ]]; then
    if [[ ! -d "${base_path}/.codex" ]]; then
      setup_notes+=("${base_path}/.codex would be created")
    fi
  else
    mkdir -p "${base_path}/.codex"
  fi
  ensure_symlink "../delphi-ai/skills" "${base_path}/.codex/skills"
}

setup_gemini_artifacts_for_scope() {
  local module="$1"
  local base_path="$REPO_ROOT"

  if [[ -n "$module" ]]; then
    base_path="${REPO_ROOT}/${module}"
    if [[ ! -d "$base_path" ]]; then
      warn "Submodule ${module} not found; skipping Gemini skills symlink."
      return
    fi
  fi

  ensure_symlink "../delphi-ai/skills" "${base_path}/.agents/skills"
}

setup_gemini_artifacts() {
  ensure_symlink "delphi-ai/GEMINI.md" "${REPO_ROOT}/GEMINI.md"
  setup_gemini_artifacts_for_scope ""
  setup_gemini_artifacts_for_scope "laravel-app"
  setup_gemini_artifacts_for_scope "flutter-app"
}

setup_script_links() {
  if [[ -d "${REPO_ROOT}/laravel-app" ]]; then
    if [[ "$CHECK_ONLY" == "true" ]]; then
      if [[ ! -d "${REPO_ROOT}/laravel-app/scripts" ]]; then
        setup_notes+=("${REPO_ROOT}/laravel-app/scripts would be created")
      fi
    else
      mkdir -p "${REPO_ROOT}/laravel-app/scripts"
    fi
    ensure_symlink "../../delphi-ai/scripts/laravel" "${REPO_ROOT}/laravel-app/scripts/delphi"
  else
    warn "Submodule laravel-app not found; skipping Delphi Laravel script link."
  fi

  if [[ -d "${REPO_ROOT}/flutter-app" ]]; then
    ensure_symlink "../delphi-ai/scripts/flutter" "${REPO_ROOT}/flutter-app/scripts"
  else
    warn "Submodule flutter-app not found; skipping Delphi Flutter script link."
  fi
}

# --- Setup Claude Code artifacts ---
# Per Claude Code documentation:
# - Rules: .claude/rules/ (markdown files with YAML frontmatter, auto-loaded)
# - Skills: .claude/skills/ (directories with SKILL.md)
# - Settings: .claude/settings.json (permissions configuration)
# - Bootloader: CLAUDE.md (entry point in project root)
setup_claude_code_artifacts() {
  local module="$1"
  local base_path="${REPO_ROOT}/${module}"

  if [[ -n "$module" && ! -d "$base_path" ]]; then
    warn "Submodule ${module} not found; skipping Claude Code symlinks."
    return
  fi

  if [[ -z "$module" ]]; then
    base_path="$REPO_ROOT"
  fi

  # Determine relative path based on whether this is root or a submodule
  local rel_prefix
  if [[ -z "$module" ]]; then
    rel_prefix="delphi-ai"
  else
    rel_prefix="../delphi-ai"
  fi

  # Create .claude directory
  if [[ "$CHECK_ONLY" == "true" ]]; then
    if [[ ! -d "${base_path}/.claude" ]]; then
      setup_notes+=("${base_path}/.claude would be created")
    fi
  else
    mkdir -p "${base_path}/.claude"
  fi

  # Symlink .claude/rules/ (rules with YAML frontmatter)
  local rules_target
  if [[ -z "$module" ]]; then
    rules_target="../delphi-ai/.claude/rules"
  else
    rules_target="${rel_prefix}/.claude/rules"
  fi
  ensure_symlink "$rules_target" "${base_path}/.claude/rules"

  # Symlink .claude/skills/ (skill directories with SKILL.md)
  local skills_target
  if [[ -z "$module" ]]; then
    skills_target="../delphi-ai/.claude/skills"
  else
    skills_target="${rel_prefix}/.claude/skills"
  fi
  ensure_symlink "$skills_target" "${base_path}/.claude/skills"

  # Symlink .claude/settings.json
  local settings_target
  if [[ -z "$module" ]]; then
    settings_target="../delphi-ai/.claude/settings.json"
  else
    settings_target="${rel_prefix}/.claude/settings.json"
  fi
  ensure_symlink "$settings_target" "${base_path}/.claude/settings.json"

  # Symlink CLAUDE.md bootloader
  ensure_symlink "${rel_prefix}/CLAUDE.md" "${base_path}/CLAUDE.md"
}

# --- Setup Cline artifacts ---
# Per Cline documentation:
# - Skills: .cline/skills/ (directories with SKILL.md)
# - Workflows: .clinerules/workflows/ (markdown files)
# - Hooks: .clinerules/hooks/ (executable scripts)
# - Rules: .clinerules/ (markdown files, auto-loaded)
setup_cline_artifacts() {
  local module="$1"
  local base_path="${REPO_ROOT}/${module}"
  
  if [[ ! -d "$base_path" ]]; then
    warn "Submodule ${module} not found; skipping Cline symlinks."
    return
  fi
  
  # Determine relative path based on whether this is root or a submodule
  local rel_prefix
  if [[ -z "$module" ]]; then
    # Root level - no ../ prefix needed
    rel_prefix="delphi-ai"
  else
    # Submodule - need ../ prefix
    rel_prefix="../delphi-ai"
  fi
  
  # Create .cline directory for skills
  if [[ "$CHECK_ONLY" == "true" ]]; then
    if [[ ! -d "${base_path}/.cline" ]]; then
      setup_notes+=("${base_path}/.cline would be created")
    fi
  else
    mkdir -p "${base_path}/.cline"
  fi
  
  # Symlink .cline/skills/ (skills are directories with SKILL.md)
  local skills_target
  if [[ -z "$module" ]]; then
    skills_target="../delphi-ai/.cline/skills"
  else
    skills_target="${rel_prefix}/.cline/skills"
  fi
  ensure_symlink "$skills_target" "${base_path}/.cline/skills"
  
  # Symlink CLINE.md bootloader
  ensure_symlink "${rel_prefix}/CLINE.md" "${base_path}/CLINE.md"
  
  # Symlink .clinerules directory (contains rules, workflows, and hooks)
  # This includes: rules (*.md), workflows/, hooks/, glob/, manual/, model-decision/
  ensure_symlink "${rel_prefix}/.clinerules" "${base_path}/.clinerules"
}

# Root bootloaders
ensure_symlink "delphi-ai/templates/agents/root.md" "${REPO_ROOT}/AGENTS.md"

setup_module_links "laravel-app" "laravel.md"
setup_module_links "flutter-app" "flutter.md"

# Setup Cline artifacts for root and submodules
setup_cline_artifacts ""
setup_cline_artifacts "laravel-app"
setup_cline_artifacts "flutter-app"

setup_codex_artifacts ""
setup_codex_artifacts "laravel-app"
setup_codex_artifacts "flutter-app"
# Setup Claude Code artifacts for root and submodules
setup_claude_code_artifacts ""
setup_claude_code_artifacts "laravel-app"
setup_claude_code_artifacts "flutter-app"

setup_gemini_artifacts
setup_script_links

if [[ "$CHECK_ONLY" == "true" ]]; then
  if [[ ${#setup_errors[@]} -gt 0 ]]; then
    error "Delphi setup preflight failed. Resolve the conflicting paths manually, then rerun: bash delphi-ai/init.sh"
    printf '[setup] Summary of blocking issues:\n' >&2
    for item in "${setup_errors[@]}"; do
      printf ' - %s\n' "$item" >&2
    done
    exit 1
  fi

  info "Delphi setup preflight OK. No blocking Delphi-managed path conflicts detected."
  if [[ ${#setup_notes[@]} -gt 0 ]]; then
    info "${#setup_notes[@]} Delphi-managed path(s) would be created during setup."
  fi
  exit 0
fi

if [[ ${#setup_errors[@]} -eq 0 && -f "${DELPHI_DIR}/tools/sync_agent_rules.sh" ]]; then
  if (cd "$REPO_ROOT" && bash "${DELPHI_DIR}/tools/sync_agent_rules.sh"); then
    info "Linked .agents rules/workflows for root and app submodules."
  else
    setup_errors+=(".agents link sync failed via bash delphi-ai/tools/sync_agent_rules.sh")
    error "Could not link .agents rules/workflows automatically. Fix the repo layout or permissions, then rerun."
  fi
fi

if [[ ${#setup_errors[@]} -gt 0 ]]; then
  error "Delphi setup failed. Resolve the conflicting paths manually, then rerun: bash delphi-ai/init.sh"
  printf '[setup] Summary of blocking issues:\n' >&2
  for item in "${setup_errors[@]}"; do
    printf ' - %s\n' "$item" >&2
  done
  exit 1
fi

info "Delphi setup complete. Review 'git status' and commit the updated submodule references if needed."
info "Configured agent surfaces: AGENTS.md, CLINE.md/.clinerules/.cline, CLAUDE.md/.claude/{rules,skills,settings.json}, .codex/skills, GEMINI.md + .agents/skills, and .agents/{rules,workflows} where possible."
info "Next step: run 'bash delphi-ai/verify_context.sh' to validate downstream wiring."
