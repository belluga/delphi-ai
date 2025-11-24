#!/usr/bin/env bash
set -euo pipefail

# Resolve repository root
if ! REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  echo "Run this script from inside the repository (git root not found)." >&2
  exit 1
fi

cd "$REPO_ROOT"

info() { printf '\033[1;34m[setup]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[setup]\033[0m %s\n' "$*" >&2; }

# --- Configure submodule URLs (interactive with defaults) ---
configure_submodule() {
  local name="$1" path="$2"
  local current
  current="$(git config -f .gitmodules --get "submodule.${path}.url" || true)"
  local prompt="Remote URL for ${name} submodule (${path})"
  local answer
  read -r -p "${prompt} [${current:-none}]: " answer
  if [[ -z "$answer" ]]; then
    answer="$current"
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

configure_submodule "Laravel" "laravel-app"
configure_submodule "Flutter" "flutter-app"
configure_submodule "Web bundle" "web-app"

# --- Ensure Delphi-AI repo is present locally (untracked) ---
DELPHI_DIR="${REPO_ROOT}/delphi-ai"
DEFAULT_DELPHI_REPO="${DELPHI_AI_REPO:-https://github.com/belluga/delphi-ai.git}"
if [[ -d "$DELPHI_DIR" ]]; then
  info "delphi-ai directory already present."
else
  read -r -p "Delphi-AI repository URL [${DEFAULT_DELPHI_REPO}]: " DELPHI_REPO
  DELPHI_REPO="${DELPHI_REPO:-$DEFAULT_DELPHI_REPO}"
  info "Cloning Delphi-AI from ${DELPHI_REPO}"
  git clone "$DELPHI_REPO" "$DELPHI_DIR"
fi

# --- Helper to create/replace symlinks ---
ensure_symlink() {
  local target="$1" link="$2"
  if [[ -e "$link" || -L "$link" ]]; then
    if [[ "$(readlink "$link" 2>/dev/null)" == "$target" ]]; then
      return
    fi
    rm -rf "$link"
  fi
  ln -s "$target" "$link"
}

# Root AGENTS.md
ensure_symlink "delphi-ai/templates/agents/root.md" "${REPO_ROOT}/AGENTS.md"

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

setup_module_links "laravel-app" "laravel.md"
setup_module_links "flutter-app" "flutter.md"

info "Delphi setup complete. Review 'git status' and commit the updated submodule references if needed."
