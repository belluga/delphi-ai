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
fi

echo "Environment Verified: PACED-Ready."
