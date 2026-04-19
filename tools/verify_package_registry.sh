#!/usr/bin/env bash
# verify_package_registry.sh — Scans proprietary packages in packages/ directories,
# detects ecosystem (global) packages from manifests, cross-references usage status,
# and generates the checklist at foundation_documentation/package_registry.md.
#
# Two categories:
#   - Ecosystem (Global): non-path dependencies matching the proprietary vendor prefix.
#   - Local (Project-Bound): packages under packages/ integrated via path.
#
# Usage: bash delphi-ai/tools/verify_package_registry.sh [--project-root <path>] [--vendor-prefix <prefix>]
#
# Authority: paced.core.package-first

set -euo pipefail

# --- Known ecosystem packages (published on pub.dev / Packagist by the org) ---
# These are detected by exact name match, regardless of vendor prefix.
# Add new ecosystem packages here as they are published.
KNOWN_ECOSYSTEM_PACKAGES=(
  # Flutter (pub.dev)
  "event_tracker_handler"   # Multi-provider event tracking (Firebase Analytics, Mixpanel, webhooks)
  "stream_value"            # Lightweight state management wrapping StreamController/StreamBuilder
  "value_object_pattern"    # Value Objects pattern implementation
  "push_handler"            # Firebase Messaging push UI handler with layouts and action routing
  "belluga_admin_ui"        # Reusable admin UI primitives for Belluga apps
  # Laravel (Packagist / VCS) — add as needed
  # "belluga/belluga-core"
)

# --- Argument parsing ---
PROJECT_ROOT="."
VENDOR_PREFIX="belluga"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-root) PROJECT_ROOT="$2"; shift 2 ;;
    --vendor-prefix) VENDOR_PREFIX="$2"; shift 2 ;;
    *) PROJECT_ROOT="$1"; shift ;;
  esac
done

REGISTRY="$PROJECT_ROOT/foundation_documentation/package_registry.md"
DELPHI_DIR="$PROJECT_ROOT/delphi-ai"
TEMPLATE="$DELPHI_DIR/templates/package_registry_template.md"
ERRORS=0
WARNINGS=0

echo "=== Proprietary Package Registry Verification ==="
echo "Project root:    $PROJECT_ROOT"
echo "Vendor prefix:   $VENDOR_PREFIX"
echo ""

# --- Detect stack type ---
HAS_FLUTTER=false
HAS_LARAVEL=false
[[ -f "$PROJECT_ROOT/pubspec.yaml" ]] && HAS_FLUTTER=true
[[ -f "$PROJECT_ROOT/composer.json" ]] && HAS_LARAVEL=true

# Also check submodule paths (docker monorepo pattern)
FLUTTER_ROOT="$PROJECT_ROOT"
LARAVEL_ROOT="$PROJECT_ROOT"
if [[ -d "$PROJECT_ROOT/flutter-app" ]] && [[ -f "$PROJECT_ROOT/flutter-app/pubspec.yaml" ]]; then
  HAS_FLUTTER=true
  FLUTTER_ROOT="$PROJECT_ROOT/flutter-app"
fi
if [[ -d "$PROJECT_ROOT/laravel-app" ]] && [[ -f "$PROJECT_ROOT/laravel-app/composer.json" ]]; then
  HAS_LARAVEL=true
  LARAVEL_ROOT="$PROJECT_ROOT/laravel-app"
fi

# --- Helper: extract first line of description from README ---
readme_oneliner() {
  local readme="$1"
  if [[ -f "$readme" ]]; then
    sed -n '/^[^#]/p' "$readme" | head -1 | sed 's/^[[:space:]]*//' | cut -c1-80
  else
    echo "(no README)"
  fi
}

# --- Collect local path packages from composer.json ---
get_laravel_path_packages() {
  local composer="$1"
  if [[ -f "$composer" ]]; then
    python3 -c "
import json, sys
with open('$composer') as f:
    data = json.load(f)
paths = set()
for repo in data.get('repositories', []):
    if repo.get('type') == 'path':
        url = repo.get('url', '')
        paths.add(url)
for p in sorted(paths):
    print(p)
" 2>/dev/null || true
  fi
}

# --- Collect ecosystem (non-path) vendor dependencies from composer.json ---
get_laravel_ecosystem_packages() {
  local composer="$1"
  local prefix="$2"
  if [[ -f "$composer" ]]; then
    python3 -c "
import json, sys
with open('$composer') as f:
    data = json.load(f)
# Collect all path URLs to exclude
path_urls = set()
for repo in data.get('repositories', []):
    if repo.get('type') == 'path':
        path_urls.add(repo.get('url', ''))
# Collect VCS URLs for vendor packages
vcs_repos = {}
for repo in data.get('repositories', []):
    if repo.get('type') in ('vcs', 'git') and '$prefix' in repo.get('url', ''):
        # Extract package name from URL
        url = repo.get('url', '')
        name = url.rstrip('/').rstrip('.git').split('/')[-1]
        vcs_repos[name] = url
# Find require entries matching vendor prefix that are NOT path packages
require = data.get('require', {})
require_dev = data.get('require-dev', {})
all_deps = {**require, **require_dev}
for dep, ver in sorted(all_deps.items()):
    if '$prefix' in dep.lower():
        # Check if this is a path package
        is_path = False
        for p in path_urls:
            if dep.replace('/', '_') in p or dep.split('/')[-1] in p:
                is_path = True
                break
        if not is_path:
            print(f'{dep}|{ver}')
" 2>/dev/null || true
  fi
}

# --- Collect ecosystem (non-path) vendor dependencies from pubspec.yaml ---
get_flutter_ecosystem_packages() {
  local pubspec="$1"
  local prefix="$2"
  # Build known packages list as comma-separated for Python
  local known_list=""
  for kp in "${KNOWN_ECOSYSTEM_PACKAGES[@]}"; do
    known_list+="'$kp',"
  done
  if [[ -f "$pubspec" ]]; then
    python3 -c "
import sys
known = {${known_list}}
# Simple YAML parser for pubspec dependencies
in_deps = False
in_dep_block = False
dep_name = ''
deps = {}
with open('$pubspec') as f:
    for line in f:
        stripped = line.strip()
        indent = len(line) - len(line.lstrip())
        if stripped in ('dependencies:', 'dev_dependencies:'):
            in_deps = True
            continue
        if in_deps and indent == 0 and stripped and not stripped.startswith('#'):
            in_deps = False
            in_dep_block = False
        if in_deps:
            if indent == 2 and ':' in stripped:
                dep_name = stripped.split(':')[0].strip()
                rest = stripped.split(':', 1)[1].strip()
                # Match by vendor prefix OR by known ecosystem package name
                if '$prefix' in dep_name or dep_name in known:
                    if rest and not rest.startswith('{'):
                        # Simple version constraint — ecosystem package
                        deps[dep_name] = ('ecosystem', rest)
                    elif not rest:
                        # Block follows
                        in_dep_block = True
                        deps[dep_name] = ('unknown', '')
            elif in_dep_block and indent == 4:
                if 'path:' in stripped:
                    deps[dep_name] = ('local', stripped.split('path:')[1].strip())
                    in_dep_block = False
                elif 'git:' in stripped or 'url:' in stripped:
                    deps[dep_name] = ('ecosystem', stripped)
                    in_dep_block = False
                elif 'hosted:' in stripped:
                    deps[dep_name] = ('ecosystem', stripped)
                    in_dep_block = False
                elif stripped.startswith('^') or stripped.startswith('>') or stripped.startswith('='):
                    deps[dep_name] = ('ecosystem', stripped)
                    in_dep_block = False
            elif in_dep_block and indent <= 2:
                in_dep_block = False
# Print only ecosystem packages
for name, (kind, ver) in sorted(deps.items()):
    if kind == 'ecosystem':
        print(f'{name}|{ver}')
" 2>/dev/null || true
  fi
}

# --- Build ecosystem packages section ---
build_ecosystem_checklist() {
  local lines=()

  # Laravel ecosystem packages
  if $HAS_LARAVEL; then
    while IFS='|' read -r pkg ver; do
      [[ -z "$pkg" ]] && continue
      lines+=("- [x] \`$pkg\` — $ver (Laravel, ecosystem)")
    done < <(get_laravel_ecosystem_packages "$LARAVEL_ROOT/composer.json" "$VENDOR_PREFIX")
  fi

  # Flutter ecosystem packages
  if $HAS_FLUTTER; then
    while IFS='|' read -r pkg ver; do
      [[ -z "$pkg" ]] && continue
      lines+=("- [x] \`$pkg\` — $ver (Flutter, ecosystem)")
    done < <(get_flutter_ecosystem_packages "$FLUTTER_ROOT/pubspec.yaml" "$VENDOR_PREFIX")
  fi

  if [[ ${#lines[@]} -eq 0 ]]; then
    echo "_No ecosystem packages detected. All proprietary packages are local._"
  else
    printf '%s\n' "${lines[@]}"
  fi
}

# --- Build Laravel local checklist ---
build_laravel_local_checklist() {
  local pkg_base="$LARAVEL_ROOT/packages"
  local composer="$LARAVEL_ROOT/composer.json"
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

      # Check if declared in composer.json (as path repo or require)
      local in_use=false
      if [[ -f "$composer" ]] && grep -q "$vendor/$pkg\|${vendor}_${pkg}" "$composer" 2>/dev/null; then
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
    echo "_No local proprietary packages found in packages/._"
  else
    printf '%s\n' "${lines[@]}"
  fi
}

# --- Build Flutter local checklist ---
build_flutter_local_checklist() {
  local pkg_base="$FLUTTER_ROOT/packages"
  local pubspec="$FLUTTER_ROOT/pubspec.yaml"
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
    echo "_No local proprietary Flutter packages found in packages/._"
  else
    printf '%s\n' "${lines[@]}"
  fi
}

# --- Anti-pattern scan ---
build_antipattern_warnings() {
  local warnings=()

  # Laravel: app/Helpers
  local laravel_helpers="$LARAVEL_ROOT/app/Helpers"
  if [[ -d "$laravel_helpers" ]]; then
    local count
    count=$(find "$laravel_helpers" -name "*.php" 2>/dev/null | wc -l)
    if [[ "$count" -gt 0 ]]; then
      warnings+=("- **$count helper(s)** in \`app/Helpers/\` — candidates for package extraction")
      WARNINGS=$((WARNINGS + count))
    fi
  fi

  # Flutter: lib/utils
  local flutter_utils="$FLUTTER_ROOT/lib/utils"
  if [[ -d "$flutter_utils" ]]; then
    local count
    count=$(find "$flutter_utils" -name "*.dart" 2>/dev/null | wc -l)
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

  # Ecosystem (Global) section
  {
    echo "## Ecosystem Packages (Global)"
    echo ""
    echo "Mature, domain-agnostic packages published as independent repositories for cross-project reuse."
    echo "Integrated via VCS repositories or private registries — NOT via local path."
    echo ""
    echo "<!-- AUTO-GENERATED — do not edit manually -->"
    echo ""
    build_ecosystem_checklist
    echo ""
    echo "---"
    echo ""
  } >> "$REGISTRY"

  # Local Laravel section
  if $HAS_LARAVEL; then
    {
      echo "## Local Proprietary Packages — Laravel"
      echo ""
      echo "Project-bound packages under \`packages/<vendor>/<package>/\` in the Laravel app."
      echo "Integrated via path repositories in \`composer.json\`."
      echo ""
      echo "<!-- AUTO-GENERATED — do not edit manually -->"
      echo ""
      build_laravel_local_checklist
      echo ""
      echo "---"
      echo ""
    } >> "$REGISTRY"
  fi

  # Local Flutter section
  if $HAS_FLUTTER; then
    {
      echo "## Local Proprietary Packages — Flutter"
      echo ""
      echo "Project-bound packages under \`packages/<package>/\` in the Flutter app."
      echo "Integrated via path dependencies in \`pubspec.yaml\`."
      echo ""
      echo "<!-- AUTO-GENERATED — do not edit manually -->"
      echo ""
      build_flutter_local_checklist
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
    echo "## Promotion Path (Local → Global)"
    echo ""
    echo "When a local package matures and becomes domain-agnostic, it can be promoted to ecosystem."
    echo "See \`paced.core.package-first\` rule for criteria and procedure."
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
