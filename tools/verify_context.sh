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

# Detect project-owned capability namespaces. `Namespaces` is the canonical
# composed form; singular `Namespace` remains a backwards-compatible input.
get_project_namespaces() {
  local constitution="$REPO_ROOT/foundation_documentation/project_constitution.md"
  if [ -f "$constitution" ]; then
    local line raw normalized ns
    local -A seen=()

    line="$(grep -iEm1 '^[[:space:]-]*(\*\*)?Namespaces:' "$constitution" || true)"
    if [ -z "$line" ]; then
      line="$(grep -iEm1 '^[[:space:]-]*(\*\*)?Namespace:' "$constitution" || true)"
    fi

    if [ -n "$line" ]; then
      raw="${line#*:}"
      normalized="$(printf '%s' "$raw" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]`*[]<>')"
      IFS=',' read -r -a declared_namespaces <<< "$normalized"
      for ns in "${declared_namespaces[@]}"; do
        [ -z "$ns" ] && continue
        if [[ ! "$ns" =~ ^[a-z0-9][a-z0-9_-]*$ ]]; then
          echo "ERROR: Invalid namespace [$ns] in $constitution. Use comma-separated registry keys." >&2
          return 2
        fi
        if [ -z "${seen[$ns]+x}" ]; then
          printf '%s\n' "$ns"
          seen[$ns]=1
        fi
      done
      if [ "${#seen[@]}" -gt 0 ]; then
        return 0
      fi
    fi
  fi
  echo "core"
}

clear_managed_stack_surface() {
  local link_path="$1"
  local source_root="$2"

  if [ -L "$link_path" ]; then
    # This reserved direct link is Delphi-managed in the legacy single-stack
    # layout. Remove it regardless of target so relocation cannot preserve an
    # obsolete capability when the project changes or clears its declaration.
    rm -f "$link_path"
    return
  fi

  if [ -d "$link_path" ] && [ -f "$link_path/.delphi-managed-stack-links" ]; then
    local entry
    while IFS= read -r -d '' entry; do
      # The marker establishes ownership of direct symlinks in this group.
      # Remove them regardless of their target so an installation relocation
      # cannot leave links to a previous Delphi root behind.
      rm -f "$entry"
    done < <(find "$link_path" -mindepth 1 -maxdepth 1 -type l -print0)
    rm -f "$link_path/.delphi-managed-stack-links"
    rmdir "$link_path" 2>/dev/null || true
  fi
}

ensure_stack_link_group() {
  local link_path="$1"
  local source_root="$2"
  local label="$3"
  shift 3
  local namespaces=("$@")

  if [ -L "$link_path" ]; then
    rm -f "$link_path"
  elif [ -e "$link_path" ] && [ ! -d "$link_path" ]; then
    echo "SAFE-CLOBBER: Moving real file $link_path to backup..."
    mv "$link_path" "${link_path}.bak_$(date +%s)"
  elif [ -d "$link_path" ] && [ ! -f "$link_path/.delphi-managed-stack-links" ]; then
    if find "$link_path" -mindepth 1 -maxdepth 1 -print -quit | grep -q .; then
      echo "SAFE-CLOBBER: Moving unmanaged directory $link_path to backup..."
      mv "$link_path" "${link_path}.bak_$(date +%s)"
    fi
  fi

  mkdir -p "$link_path"
  touch "$link_path/.delphi-managed-stack-links"

  local entry ns
  while IFS= read -r -d '' entry; do
    # Direct symlinks in a marker-owned group are Delphi-managed. Clearing all
    # of them repairs stale targets after Delphi itself moves on disk.
    rm -f "$entry"
  done < <(find "$link_path" -mindepth 1 -maxdepth 1 -type l -print0)

  for ns in "${namespaces[@]}"; do
    [ "$ns" = "core" ] && continue
    if [ -d "$source_root/$ns" ]; then
      ln -s "$source_root/$ns" "$link_path/$ns"
      echo "CREATED: $label [$ns] -> $source_root/$ns"
    else
      echo "INFO: $label package [$ns] is not installed; capability activation remains project-owned."
    fi
  done
}

ensure_stack_surface() {
  local link_path="$1"
  local source_root="$2"
  local label="$3"
  shift 3
  local namespaces=("$@")
  local active_namespaces=()
  local ns

  for ns in "${namespaces[@]}"; do
    [ "$ns" = "core" ] || active_namespaces+=("$ns")
  done

  if [ "${#active_namespaces[@]}" -eq 0 ]; then
    clear_managed_stack_surface "$link_path" "$source_root"
  elif [ "${#active_namespaces[@]}" -eq 1 ]; then
    ns="${active_namespaces[0]}"
    clear_managed_stack_surface "$link_path" "$source_root"
    if [ -d "$source_root/$ns" ]; then
      ensure_safe_link "$link_path" "$source_root/$ns" "$label [$ns]"
    else
      echo "INFO: $label package [$ns] is not installed; capability activation remains project-owned."
    fi
  else
    ensure_stack_link_group "$link_path" "$source_root" "$label" "${active_namespaces[@]}"
  fi
}

# Repair Logic
REPAIR_MODE=false
for arg in "$@"; do
  if [ "$arg" == "--repair" ]; then REPAIR_MODE=true; fi
done

if [ "$REPAIR_MODE" = true ]; then
  NAMESPACE_OUTPUT="$(get_project_namespaces)"
  mapfile -t NAMESPACES <<< "$NAMESPACE_OUTPUT"
  NAMESPACE_LABEL="$(IFS=', '; echo "${NAMESPACES[*]}")"
  echo "PACED Authority: Applying rules for namespaces [$NAMESPACE_LABEL]"

  # Instruction Layer
  ensure_safe_link "$REPO_ROOT/.agents/rules/core" "$SCRIPT_ROOT/rules/core" "Core Rules"
  ensure_stack_surface "$REPO_ROOT/.agents/rules/stack" "$SCRIPT_ROOT/rules/stacks" "Stack Rules" "${NAMESPACES[@]}"
  ensure_safe_link "$REPO_ROOT/.agents/rules/local" "$REPO_ROOT/foundation_documentation" "Local Rules"

  # Deterministic Layer
  ensure_safe_link "$REPO_ROOT/.agents/deterministic/core" "$SCRIPT_ROOT/deterministic/core" "Core Deterministic"
  ensure_stack_surface "$REPO_ROOT/.agents/deterministic/stack" "$SCRIPT_ROOT/deterministic/stacks" "Stack Deterministic" "${NAMESPACES[@]}"
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
VERIFY_ISSUES=0
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
  else
    VERIFY_ISSUES=$((VERIFY_ISSUES + CLAUDE_ISSUES))
  fi
fi

# Package Registry Verification
# Ecosystem YAML lives in delphi-ai (PACED governance)
if [ -f "$SCRIPT_ROOT/config/ecosystem_packages.yaml" ]; then
  echo "Ecosystem packages YAML: OK"
else
  echo "WARN: Ecosystem packages YAML not found at $SCRIPT_ROOT/config/ecosystem_packages.yaml"
  VERIFY_ISSUES=$((VERIFY_ISSUES + 1))
fi

# Local YAML lives in foundation_documentation (project data)
if [ -n "$REPO_ROOT" ] && [ -d "$REPO_ROOT/foundation_documentation" ]; then
  if [ ! -f "$REPO_ROOT/foundation_documentation/local_packages.yaml" ]; then
    if [ "$REPAIR_MODE" = true ]; then
      echo "WARN: Local packages YAML not found. Repairing..."
      if [ -f "$SCRIPT_ROOT/tools/verify_package_registry.sh" ]; then
        bash "$SCRIPT_ROOT/tools/verify_package_registry.sh" --project-root "$REPO_ROOT"
        if [ -f "$REPO_ROOT/foundation_documentation/local_packages.yaml" ]; then
          echo "Local packages YAML generated at foundation_documentation/local_packages.yaml"
        else
          echo "ERROR: verify_package_registry.sh completed without producing foundation_documentation/local_packages.yaml"
          VERIFY_ISSUES=$((VERIFY_ISSUES + 1))
        fi
      else
        echo "ERROR: verify_package_registry.sh not found — cannot repair local_packages.yaml"
        VERIFY_ISSUES=$((VERIFY_ISSUES + 1))
      fi
    else
      echo "WARN: Local packages YAML not found at $REPO_ROOT/foundation_documentation/local_packages.yaml"
      echo "Remediation: run 'bash delphi-ai/verify_context.sh --repair' or 'bash delphi-ai/tools/verify_package_registry.sh --project-root $REPO_ROOT'"
      VERIFY_ISSUES=$((VERIFY_ISSUES + 1))
    fi
  else
    echo "Local packages YAML: OK"
  fi
fi

if [ "$VERIFY_ISSUES" -gt 0 ]; then
  echo "Environment Verification: FAILED ($VERIFY_ISSUES issue(s))"
  exit 1
fi

echo "Environment Verified: PACED-Ready."
