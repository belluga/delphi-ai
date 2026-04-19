#!/usr/bin/env bash
set -euo pipefail

# Deterministic Root Detection
SCRIPT_ROOT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"
GIT_ROOT_DETECTED=false
REPO_ROOT="$(git -C "$(pwd)" rev-parse --show-toplevel 2>/dev/null || true)"

if [ -n "$REPO_ROOT" ]; then
  GIT_ROOT_DETECTED=true
else
  CURRENT_DIR="$(pwd)"
  while [[ "$CURRENT_DIR" != "/" ]]; do
    if [[ -d "$CURRENT_DIR/delphi-ai" || -d "$CURRENT_DIR/foundation_documentation" ]]; then
      REPO_ROOT="$CURRENT_DIR"
      break
    fi
    CURRENT_DIR="$(dirname "$CURRENT_DIR")"
  done
fi

if [ -z "$REPO_ROOT" ]; then
  REPO_ROOT="$(cd "$SCRIPT_ROOT/.." && pwd)"
fi

# Utility: Safe Link (with Backup)
ensure_safe_link() {
  local link_path="$1"
  local target="$2"
  local label="$3"
  local parent_dir
  parent_dir="$(dirname "$link_path")"

  mkdir -p "$parent_dir"

  if [ -e "$link_path" ] && [ ! -L "$link_path" ]; then
    echo "SAFE-CLOBBER: Moving real directory/file $link_path to backup..."
    mv "$link_path" "${link_path}.bak_$(date +%s)"
  fi

  if [ -L "$link_path" ]; then
    local actual
    actual="$(readlink "$link_path")"
    if [ "$actual" != "$target" ]; then
      rm -f "$link_path"
      ln -s "$target" "$link_path"
      echo "REPAIRED: $label -> $target"
    fi
  else
    ln -s "$target" "$link_path"
    echo "CREATED: $label -> $target"
  fi
}

# Detect Namespace
get_project_namespace() {
  local constitution="$REPO_ROOT/foundation_documentation/project_constitution.md"
  if [ -f "$constitution" ]; then
    local ns
    ns=$(grep -i "Namespace:" "$constitution" | awk -F'[:[]' '{print $2}' | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
    if [ -n "$ns" ]; then
      echo "$ns"
      return 0
    fi
  fi
  echo "core"
}

# Repair Logic
REPAIR_MODE=false
for arg in "$@"; do
  if [ "$arg" == "--repair" ]; then REPAIR_MODE=true; fi
done

if [ "$REPAIR_MODE" = true ]; then
  NAMESPACE=$(get_project_namespace)
  echo "PACED Authority: Applying rules for namespace [$NAMESPACE]"

  # Instruction Layer
  ensure_safe_link "$REPO_ROOT/.agents/rules/core" "$SCRIPT_ROOT/rules/core" "Core Rules"
  if [ -d "$SCRIPT_ROOT/rules/stacks/$NAMESPACE" ]; then
    ensure_safe_link "$REPO_ROOT/.agents/rules/stack" "$SCRIPT_ROOT/rules/stacks/$NAMESPACE" "Stack Rules"
  fi
  ensure_safe_link "$REPO_ROOT/.agents/rules/local" "$REPO_ROOT/foundation_documentation" "Local Rules"

  # Deterministic Layer
  ensure_safe_link "$REPO_ROOT/.agents/deterministic/core" "$SCRIPT_ROOT/deterministic/core" "Core Deterministic"
  if [ -d "$SCRIPT_ROOT/deterministic/stacks/$NAMESPACE" ]; then
    ensure_safe_link "$REPO_ROOT/.agents/deterministic/stack" "$SCRIPT_ROOT/deterministic/stacks/$NAMESPACE" "Stack Deterministic"
  fi
  ensure_safe_link "$REPO_ROOT/.agents/deterministic/local" "$REPO_ROOT/foundation_documentation/deterministic" "Local Deterministic"

  # Claude Code Layer
  if [ -d "$SCRIPT_ROOT/.claude" ]; then
    mkdir -p "$REPO_ROOT/.claude"
    ensure_safe_link "$REPO_ROOT/.claude/rules" "$SCRIPT_ROOT/.claude/rules" "Claude Code Rules"
    ensure_safe_link "$REPO_ROOT/.claude/skills" "$SCRIPT_ROOT/.claude/skills" "Claude Code Skills"
    ensure_safe_link "$REPO_ROOT/.claude/settings.json" "$SCRIPT_ROOT/.claude/settings.json" "Claude Code Settings"
    ensure_safe_link "$REPO_ROOT/CLAUDE.md" "$SCRIPT_ROOT/CLAUDE.md" "Claude Code Bootloader"
  fi
fi

# Validate Claude Code artifacts exist (read-only check)
CLAUDE_ISSUES=0
if [ -d "$SCRIPT_ROOT/.claude" ]; then
  if [ ! -d "$SCRIPT_ROOT/.claude/rules" ]; then
    echo "WARN: .claude/rules/ directory missing in delphi-ai"
    CLAUDE_ISSUES=$((CLAUDE_ISSUES + 1))
  fi
  if [ ! -d "$SCRIPT_ROOT/.claude/skills" ]; then
    echo "WARN: .claude/skills/ directory missing in delphi-ai"
    CLAUDE_ISSUES=$((CLAUDE_ISSUES + 1))
  fi
  if [ ! -f "$SCRIPT_ROOT/.claude/settings.json" ]; then
    echo "WARN: .claude/settings.json missing in delphi-ai"
    CLAUDE_ISSUES=$((CLAUDE_ISSUES + 1))
  fi
  if [ ! -f "$SCRIPT_ROOT/CLAUDE.md" ]; then
    echo "WARN: CLAUDE.md bootloader missing in delphi-ai"
    CLAUDE_ISSUES=$((CLAUDE_ISSUES + 1))
  fi
  if [ $CLAUDE_ISSUES -eq 0 ]; then
    echo "Claude Code artifacts: OK"
  fi
fi

# Package Registry Verification
# Ecosystem YAML lives in delphi-ai (PACED governance)
if [ -f "$SCRIPT_ROOT/config/ecosystem_packages.yaml" ]; then
  echo "Ecosystem packages YAML: OK"
else
  echo "WARN: Ecosystem packages YAML not found at $SCRIPT_ROOT/config/ecosystem_packages.yaml"
fi

# Local YAML lives in foundation_documentation (project data)
if [ -n "$REPO_ROOT" ] && [ -d "$REPO_ROOT/foundation_documentation" ]; then
  if [ ! -f "$REPO_ROOT/foundation_documentation/local_packages.yaml" ]; then
    echo "WARN: Local packages YAML not found. Generating..."
    if [ -f "$SCRIPT_ROOT/tools/verify_package_registry.sh" ]; then
      bash "$SCRIPT_ROOT/tools/verify_package_registry.sh" --project-root "$REPO_ROOT" 2>/dev/null || true
      echo "Local packages YAML generated at foundation_documentation/local_packages.yaml"
    else
      echo "WARN: verify_package_registry.sh not found — cannot generate local_packages.yaml"
    fi
  else
    echo "Local packages YAML: OK"
  fi
fi
echo "Environment Verified: PACED-Ready."
