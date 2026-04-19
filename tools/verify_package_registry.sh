#!/usr/bin/env bash
# verify_package_registry.sh — Scans proprietary packages in packages/ directories,
# cross-references with stack manifests (pubspec.yaml / composer.json), and generates
# or updates the checklist at foundation_documentation/package_registry.md.
#
# Usage: bash delphi-ai/tools/verify_package_registry.sh [--project-root <path>]
#
# Authority: paced.core.package-first

set -euo pipefail

# --- Argument parsing ---
PROJECT_ROOT="."
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-root) PROJECT_ROOT="$2"; shift 2 ;;
    *) PROJECT_ROOT="$1"; shift ;;
  esac
done

REGISTRY="$PROJECT_ROOT/foundation_documentation/package_registry.md"
DELPHI_DIR="$PROJECT_ROOT/delphi-ai"
TEMPLATE="$DELPHI_DIR/templates/package_registry_template.md"
ERRORS=0
WARNINGS=0

echo "=== Proprietary Package Registry Verification ==="
echo "Project root: $PROJECT_ROOT"
echo ""

# --- Detect stack type ---
HAS_FLUTTER=false
HAS_LARAVEL=false
[[ -f "$PROJECT_ROOT/pubspec.yaml" ]] && HAS_FLUTTER=true
[[ -f "$PROJECT_ROOT/composer.json" ]] && HAS_LARAVEL=true

# --- Helper: extract first line of description from README ---
readme_oneliner() {
  local readme="$1"
  if [[ -f "$readme" ]]; then
    # Grab first non-empty, non-heading line after the title
    sed -n '/^[^#]/p' "$readme" | head -1 | sed 's/^[[:space:]]*//' | cut -c1-80
  else
    echo "(no README)"
  fi
}

# --- Build Laravel checklist ---
build_laravel_checklist() {
  local pkg_base="$PROJECT_ROOT/packages"
  local composer="$PROJECT_ROOT/composer.json"
  local lines=()

  if [[ ! -d "$pkg_base" ]]; then
    echo "_No packages/ directory found._"
    return
  fi

  for vendor_dir in "$pkg_base"/*/; do
    [[ -d "$vendor_dir" ]] || continue
    local vendor
    vendor=$(basename "$vendor_dir")

    for pkg_dir in "$vendor_dir"*/; do
      [[ -d "$pkg_dir" ]] || continue
      local pkg
      pkg=$(basename "$pkg_dir")
      local rel_path="packages/$vendor/$pkg"
      local readme="$pkg_dir/README.md"
      local desc
      desc=$(readme_oneliner "$readme")

      # Check if declared in composer.json
      local in_use=false
      if [[ -f "$composer" ]] && grep -q "\"$vendor/$pkg\"" "$composer" 2>/dev/null; then
        in_use=true
      fi

      # Check README exists
      if [[ ! -f "$readme" ]]; then
        WARNINGS=$((WARNINGS + 1))
        desc="**WARNING: missing README.md**"
      fi

      if $in_use; then
        lines+=("- [x] \`$vendor/$pkg\` — \`$rel_path\` — $desc")
      else
        lines+=("- [ ] \`$vendor/$pkg\` — \`$rel_path\` — $desc")
      fi
    done
  done

  if [[ ${#lines[@]} -eq 0 ]]; then
    echo "_No proprietary packages found in packages/._"
  else
    printf '%s\n' "${lines[@]}"
  fi
}

# --- Build Flutter checklist ---
build_flutter_checklist() {
  local pkg_base="$PROJECT_ROOT/packages"
  local pubspec="$PROJECT_ROOT/pubspec.yaml"
  local lines=()

  if [[ ! -d "$pkg_base" ]]; then
    echo "_No packages/ directory found._"
    return
  fi

  for pkg_dir in "$pkg_base"/*/; do
    [[ -d "$pkg_dir" ]] || continue
    # Only consider Flutter packages (those with pubspec.yaml)
    [[ -f "$pkg_dir/pubspec.yaml" ]] || continue

    local pkg
    pkg=$(basename "$pkg_dir")
    local rel_path="packages/$pkg"
    local readme="$pkg_dir/README.md"
    local desc
    desc=$(readme_oneliner "$readme")

    # Check if declared in root pubspec.yaml
    local in_use=false
    if [[ -f "$pubspec" ]] && grep -q "$pkg" "$pubspec" 2>/dev/null; then
      in_use=true
    fi

    # Check README exists
    if [[ ! -f "$readme" ]]; then
      WARNINGS=$((WARNINGS + 1))
      desc="**WARNING: missing README.md**"
    fi

    if $in_use; then
      lines+=("- [x] \`$pkg\` — \`$rel_path\` — $desc")
    else
      lines+=("- [ ] \`$pkg\` — \`$rel_path\` — $desc")
    fi
  done

  if [[ ${#lines[@]} -eq 0 ]]; then
    echo "_No proprietary Flutter packages found in packages/._"
  else
    printf '%s\n' "${lines[@]}"
  fi
}

# --- Anti-pattern scan ---
build_antipattern_warnings() {
  local warnings=()

  # Laravel: app/Helpers
  if [[ -d "$PROJECT_ROOT/app/Helpers" ]]; then
    local count
    count=$(find "$PROJECT_ROOT/app/Helpers" -name "*.php" 2>/dev/null | wc -l)
    if [[ "$count" -gt 0 ]]; then
      warnings+=("- **$count helper(s)** in \`app/Helpers/\` — candidates for package extraction")
      WARNINGS=$((WARNINGS + count))
    fi
  fi

  # Flutter: lib/utils
  if [[ -d "$PROJECT_ROOT/lib/utils" ]]; then
    local count
    count=$(find "$PROJECT_ROOT/lib/utils" -name "*.dart" 2>/dev/null | wc -l)
    if [[ "$count" -gt 0 ]]; then
      warnings+=("- **$count util(s)** in \`lib/utils/\` — candidates for library extraction")
      WARNINGS=$((WARNINGS + count))
    fi
  fi

  if [[ ${#warnings[@]} -eq 0 ]]; then
    echo "_No anti-patterns detected._"
  else
    printf '%s\n' "${warnings[@]}"
  fi
}

# --- Generate the registry file ---
generate_registry() {
  local laravel_section flutter_section antipattern_section
  local timestamp
  timestamp=$(date -u +"%Y-%m-%d %H:%M UTC")

  cat > "$REGISTRY" << 'HEADER'
# Proprietary Packages & Libraries

> **Authority:** `paced.core.package-first`
>
> Auto-generated checklist of proprietary packages and libraries.
> Maintained by `delphi-ai/tools/verify_package_registry.sh`.
> Agents MUST consult this list before implementing new functionality.
> If a proprietary package covers the need, extend it — do not create alternatives in the host app.
>
> - `[x]` = in use (declared dependency) — **use directly**
> - `[ ]` = available but not in use — **recommend adoption**

HEADER

  if $HAS_LARAVEL; then
    {
      echo "## Laravel Packages"
      echo ""
      echo "<!-- AUTO-GENERATED — do not edit manually -->"
      echo ""
      build_laravel_checklist
      echo ""
      echo "---"
      echo ""
    } >> "$REGISTRY"
  fi

  if $HAS_FLUTTER; then
    {
      echo "## Flutter Packages"
      echo ""
      echo "<!-- AUTO-GENERATED — do not edit manually -->"
      echo ""
      build_flutter_checklist
      echo ""
      echo "---"
      echo ""
    } >> "$REGISTRY"
  fi

  if ! $HAS_LARAVEL && ! $HAS_FLUTTER; then
    {
      echo "## Packages"
      echo ""
      echo "_No stack detected (no pubspec.yaml or composer.json found). Run this script from the project root._"
      echo ""
      echo "---"
      echo ""
    } >> "$REGISTRY"
  fi

  {
    echo "## Anti-Pattern Watchlist"
    echo ""
    build_antipattern_warnings
    echo ""
    echo "---"
    echo ""
    echo "_Last updated: $timestamp by verify_package_registry.sh_"
    echo ""
  } >> "$REGISTRY"

  echo "Registry written to: $REGISTRY"
}

# --- Ensure foundation_documentation exists ---
mkdir -p "$PROJECT_ROOT/foundation_documentation"

# --- Generate ---
generate_registry

# --- Summary ---
echo ""
echo "=== Summary ==="
echo "Errors:   $ERRORS"
echo "Warnings: $WARNINGS"

if [[ "$ERRORS" -gt 0 ]]; then
  echo "STATUS: FAIL"
  exit 1
elif [[ "$WARNINGS" -gt 0 ]]; then
  echo "STATUS: PASS WITH WARNINGS"
  exit 0
else
  echo "STATUS: PASS"
  exit 0
fi
