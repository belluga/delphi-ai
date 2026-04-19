#!/usr/bin/env bash
# verify_package_registry.sh — Validates that the Package & Library Registry
# exists and is consistent with the actual codebase.
#
# Usage: bash delphi-ai/tools/verify_package_registry.sh [--project-root <path>]
#
# Authority: paced.core.package-first

set -euo pipefail

PROJECT_ROOT="${1:-.}"
REGISTRY="$PROJECT_ROOT/foundation_documentation/package_registry.md"
TEMPLATE_DIR="$PROJECT_ROOT/delphi-ai/templates"
ERRORS=0
WARNINGS=0

echo "=== Package Registry Verification ==="
echo "Project root: $PROJECT_ROOT"
echo ""

# --- 1. Registry existence ---
if [[ ! -f "$REGISTRY" ]]; then
  echo "[ERROR] Package registry not found at: $REGISTRY"
  echo "  → Copy from template: cp $TEMPLATE_DIR/package_registry_template.md $REGISTRY"
  ERRORS=$((ERRORS + 1))
else
  echo "[OK] Registry found: $REGISTRY"

  # --- 2. Check Laravel packages ---
  LARAVEL_PKG_DIR="$PROJECT_ROOT/packages"
  if [[ -d "$LARAVEL_PKG_DIR" ]]; then
    echo ""
    echo "--- Laravel Packages ---"
    for vendor_dir in "$LARAVEL_PKG_DIR"/*/; do
      [[ -d "$vendor_dir" ]] || continue
      vendor=$(basename "$vendor_dir")
      for pkg_dir in "$vendor_dir"*/; do
        [[ -d "$pkg_dir" ]] || continue
        pkg=$(basename "$pkg_dir")
        # Check if package is in registry
        if grep -q "$pkg" "$REGISTRY" 2>/dev/null; then
          echo "[OK] $vendor/$pkg — registered"
        else
          echo "[WARNING] $vendor/$pkg — NOT in registry"
          WARNINGS=$((WARNINGS + 1))
        fi
        # Check if package has README
        if [[ ! -f "$pkg_dir/README.md" ]]; then
          echo "  [ERROR] $vendor/$pkg — missing README.md"
          ERRORS=$((ERRORS + 1))
        fi
      done
    done
  fi

  # --- 3. Check Flutter packages ---
  FLUTTER_PKG_DIR="$PROJECT_ROOT/packages"
  FLUTTER_PUBSPEC="$PROJECT_ROOT/pubspec.yaml"
  if [[ -f "$FLUTTER_PUBSPEC" && -d "$FLUTTER_PKG_DIR" ]]; then
    echo ""
    echo "--- Flutter Packages ---"
    for pkg_dir in "$FLUTTER_PKG_DIR"/*/; do
      [[ -d "$pkg_dir" ]] || continue
      pkg=$(basename "$pkg_dir")
      if [[ -f "$pkg_dir/pubspec.yaml" ]]; then
        if grep -q "$pkg" "$REGISTRY" 2>/dev/null; then
          echo "[OK] $pkg — registered"
        else
          echo "[WARNING] $pkg — NOT in registry"
          WARNINGS=$((WARNINGS + 1))
        fi
        if [[ ! -f "$pkg_dir/README.md" ]]; then
          echo "  [ERROR] $pkg — missing README.md"
          ERRORS=$((ERRORS + 1))
        fi
      fi
    done
  fi

  # --- 4. Check for host-level anti-patterns ---
  echo ""
  echo "--- Anti-Pattern Scan ---"

  # Laravel: check for Services/Helpers in app/ that might duplicate packages
  if [[ -d "$PROJECT_ROOT/app/Services" ]]; then
    svc_count=$(find "$PROJECT_ROOT/app/Services" -name "*.php" 2>/dev/null | wc -l)
    if [[ "$svc_count" -gt 0 ]]; then
      echo "[INFO] Found $svc_count service(s) in app/Services/ — verify none duplicate package capabilities"
    fi
  fi
  if [[ -d "$PROJECT_ROOT/app/Helpers" ]]; then
    helper_count=$(find "$PROJECT_ROOT/app/Helpers" -name "*.php" 2>/dev/null | wc -l)
    if [[ "$helper_count" -gt 0 ]]; then
      echo "[WARNING] Found $helper_count helper(s) in app/Helpers/ — helpers often indicate missing package extraction"
      WARNINGS=$((WARNINGS + 1))
    fi
  fi

  # Flutter: check for utils/ in lib/
  if [[ -d "$PROJECT_ROOT/lib/utils" ]]; then
    util_count=$(find "$PROJECT_ROOT/lib/utils" -name "*.dart" 2>/dev/null | wc -l)
    if [[ "$util_count" -gt 0 ]]; then
      echo "[WARNING] Found $util_count util(s) in lib/utils/ — utils often indicate missing library extraction"
      WARNINGS=$((WARNINGS + 1))
    fi
  fi
fi

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
