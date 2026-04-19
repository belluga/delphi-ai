#!/usr/bin/env bash
# query_packages.sh — Deterministic CLI to query proprietary packages.
#
# The agent calls this script instead of reading files manually.
# It reads ecosystem_packages.yaml + local_packages.yaml, cross-references
# with READMEs, and returns structured output to stdout.
#
# Usage:
#   bash delphi-ai/tools/query_packages.sh [options] [--project-root <path>]
#
# Options:
#   --all                 List all proprietary packages (default if no options)
#   --search <term>       Search packages by name or description (case-insensitive)
#   --tier <tier>         Filter by tier: local | ecosystem | all (default: all)
#   --stack <stack>       Filter by stack: flutter | laravel | all (default: all)
#   --unused              Show only local packages that exist but are not in use
#   --detail <name>       Show full detail for a specific package (includes README content)
#   --project-root <path> Project root directory (default: .)
#
# Output: structured text blocks, one per package, parseable by agents.
#
# Authority: paced.core.package-first

set -euo pipefail

# --- Defaults ---
PROJECT_ROOT="."
MODE="all"
SEARCH_TERM=""
TIER_FILTER="all"
STACK_FILTER="all"
DETAIL_NAME=""

# --- Argument parsing ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)            MODE="all"; shift ;;
    --search)         MODE="search"; SEARCH_TERM="$2"; shift 2 ;;
    --tier)           TIER_FILTER="$2"; shift 2 ;;
    --stack)          STACK_FILTER="$2"; shift 2 ;;
    --unused)         MODE="unused"; shift ;;
    --detail)         MODE="detail"; DETAIL_NAME="$2"; shift 2 ;;
    --project-root)   PROJECT_ROOT="$2"; shift 2 ;;
    *)                PROJECT_ROOT="$1"; shift ;;
  esac
done

DELPHI_DIR="$PROJECT_ROOT/delphi-ai"
ECOSYSTEM_YAML="$DELPHI_DIR/config/ecosystem_packages.yaml"
LOCAL_YAML="$PROJECT_ROOT/foundation_documentation/local_packages.yaml"

# --- Detect stack roots ---
FLUTTER_ROOT="$PROJECT_ROOT"
LARAVEL_ROOT="$PROJECT_ROOT"
[[ -d "$PROJECT_ROOT/flutter-app" ]] && FLUTTER_ROOT="$PROJECT_ROOT/flutter-app"
[[ -d "$PROJECT_ROOT/laravel-app" ]] && LARAVEL_ROOT="$PROJECT_ROOT/laravel-app"

# --- Ensure local YAML exists ---
if [[ ! -f "$LOCAL_YAML" ]]; then
  if [[ -f "$DELPHI_DIR/tools/verify_package_registry.sh" ]]; then
    bash "$DELPHI_DIR/tools/verify_package_registry.sh" --project-root "$PROJECT_ROOT" > /dev/null 2>&1
  fi
fi

# --- Parse ecosystem YAML ---
# Format: ECOSYSTEM|<stack>|<name>|<description>|<pub_dev_or_packagist>
parse_ecosystem() {
  if [[ ! -f "$ECOSYSTEM_YAML" ]]; then return; fi

  local current_stack=""
  local name="" description="" pub_url=""

  while IFS= read -r line; do
    # Skip comments and blank lines
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// }" ]] && continue

    # Detect stack sections (top-level keys ending with :)
    if [[ "$line" =~ ^flutter:[[:space:]]*$ ]]; then
      # Emit previous if exists
      if [[ -n "$name" ]]; then
        echo "ECOSYSTEM|$current_stack|$name|$description|$pub_url"
      fi
      current_stack="flutter"; name=""; description=""; pub_url=""
      continue
    elif [[ "$line" =~ ^laravel:[[:space:]]*$ ]]; then
      if [[ -n "$name" ]]; then
        echo "ECOSYSTEM|$current_stack|$name|$description|$pub_url"
      fi
      current_stack="laravel"; name=""; description=""; pub_url=""
      continue
    fi

    # Skip non-stack top-level keys
    if [[ "$line" =~ ^[a-z_]+: ]] && [[ ! "$line" =~ ^[[:space:]] ]]; then
      continue
    fi

    if [[ -n "$current_stack" ]]; then
      # New entry: "  - name: ..."
      if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*name:[[:space:]]*(.+) ]]; then
        # Emit previous
        if [[ -n "$name" ]]; then
          echo "ECOSYSTEM|$current_stack|$name|$description|$pub_url"
        fi
        name="${BASH_REMATCH[1]}"
        name="${name//\"/}"  # strip quotes
        name="${name# }"     # strip leading space
        description=""; pub_url=""
      elif [[ "$line" =~ ^[[:space:]]*description:[[:space:]]*(.+) ]]; then
        description="${BASH_REMATCH[1]}"
        description="${description//\"/}"
      elif [[ "$line" =~ ^[[:space:]]*pub_dev:[[:space:]]*(.+) ]]; then
        pub_url="${BASH_REMATCH[1]}"
        pub_url="${pub_url//\"/}"
      elif [[ "$line" =~ ^[[:space:]]*packagist:[[:space:]]*(.+) ]]; then
        pub_url="${BASH_REMATCH[1]}"
        pub_url="${pub_url//\"/}"
      fi
    fi
  done < "$ECOSYSTEM_YAML"

  # Emit last
  if [[ -n "$name" ]]; then
    echo "ECOSYSTEM|$current_stack|$name|$description|$pub_url"
  fi
}

# --- Parse local YAML ---
# Format: LOCAL|<stack>|<name>|<path>|<in_use>|<has_readme>|<description>
parse_local() {
  if [[ ! -f "$LOCAL_YAML" ]]; then return; fi

  local current_stack=""
  local name="" path="" in_use="" has_readme="" description=""

  while IFS= read -r line; do
    # Skip comments
    [[ "$line" =~ ^[[:space:]]*# ]] && continue

    # Detect stack section
    if [[ "$line" =~ ^laravel: ]]; then
      if [[ -n "$name" ]]; then
        echo "LOCAL|$current_stack|$name|$path|$in_use|$has_readme|$description"
      fi
      current_stack="laravel"; name=""; continue
    elif [[ "$line" =~ ^flutter: ]]; then
      if [[ -n "$name" ]]; then
        echo "LOCAL|$current_stack|$name|$path|$in_use|$has_readme|$description"
      fi
      current_stack="flutter"; name=""; continue
    elif [[ "$line" =~ ^anti_patterns: ]]; then
      break
    fi

    if [[ -n "$current_stack" ]]; then
      if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*name:[[:space:]]*\"([^\"]+)\" ]]; then
        # Emit previous
        if [[ -n "$name" ]]; then
          echo "LOCAL|$current_stack|$name|$path|$in_use|$has_readme|$description"
        fi
        name="${BASH_REMATCH[1]}"
        path="" in_use="" has_readme="" description=""
      elif [[ "$line" =~ ^[[:space:]]*path:[[:space:]]*\"([^\"]+)\" ]]; then
        path="${BASH_REMATCH[1]}"
      elif [[ "$line" =~ ^[[:space:]]*in_use:[[:space:]]*(true|false) ]]; then
        in_use="${BASH_REMATCH[1]}"
      elif [[ "$line" =~ ^[[:space:]]*has_readme:[[:space:]]*(true|false) ]]; then
        has_readme="${BASH_REMATCH[1]}"
      elif [[ "$line" =~ ^[[:space:]]*description:[[:space:]]*\"([^\"]*)\" ]]; then
        description="${BASH_REMATCH[1]}"
      fi
    fi
  done < "$LOCAL_YAML"

  # Emit last
  if [[ -n "$name" ]]; then
    echo "LOCAL|$current_stack|$name|$path|$in_use|$has_readme|$description"
  fi
}

# --- Resolve README path ---
resolve_readme() {
  local tier="$1" stack="$2" name="$3" pkg_path="$4"

  if [[ "$tier" == "LOCAL" ]]; then
    local root="$PROJECT_ROOT"
    [[ "$stack" == "flutter" ]] && root="$FLUTTER_ROOT"
    [[ "$stack" == "laravel" ]] && root="$LARAVEL_ROOT"
    local readme="$root/$pkg_path/README.md"
    [[ -f "$readme" ]] && echo "$readme" || echo ""
  fi
}

# --- Format output ---
format_package() {
  local tier="$1" stack="$2" name="$3" status="$4" description="$5" readme_path="$6"

  echo "---"
  echo "TIER:        $tier"
  echo "STACK:       $stack"
  echo "NAME:        $name"
  echo "STATUS:      $status"
  if [[ -n "$description" ]]; then
    echo "DESCRIPTION: $description"
  fi
  if [[ -n "$readme_path" ]]; then
    echo "README:      $readme_path"
  fi
}

format_detail() {
  local tier="$1" stack="$2" name="$3" status="$4" description="$5" readme_path="$6"

  format_package "$tier" "$stack" "$name" "$status" "$description" "$readme_path"
  echo ""
  if [[ -n "$readme_path" ]] && [[ -f "$readme_path" ]]; then
    echo "=== README CONTENT ==="
    cat "$readme_path"
    echo "=== END README ==="
  fi
}

# --- Collect all packages ---
collect_all() {
  parse_ecosystem
  parse_local
}

# --- Apply filters and output ---
process() {
  local count=0
  local all_packages
  all_packages="$(collect_all)"

  if [[ -z "$all_packages" ]]; then
    echo "=== 0 package(s) found ==="
    return
  fi

  while IFS='|' read -r tier stack name f4 f5 f6 f7; do
    [[ -z "$tier" ]] && continue

    # Stack filter
    if [[ "$STACK_FILTER" != "all" ]] && [[ "$stack" != "$STACK_FILTER" ]]; then continue; fi

    # Tier filter
    if [[ "$TIER_FILTER" != "all" ]]; then
      local tier_lower="${tier,,}"
      if [[ "$tier_lower" != "$TIER_FILTER" ]]; then continue; fi
    fi

    local description="" status="" readme_path=""

    if [[ "$tier" == "ECOSYSTEM" ]]; then
      # f4=description, f5=pub_url
      description="$f4"
      status="ecosystem (published)"
      if [[ -n "$f5" ]] && [[ "$f5" != "null" ]]; then
        status="ecosystem ($f5)"
      fi
      readme_path=""
    else
      # f4=path, f5=in_use, f6=has_readme, f7=description
      description="${f7:-}"
      if [[ "$f5" == "true" ]]; then
        status="in_use"
      else
        status="available (not in use)"
      fi
      readme_path=$(resolve_readme "$tier" "$stack" "$name" "$f4")
    fi

    # Mode filters
    case "$MODE" in
      unused)
        if [[ "$tier" == "ECOSYSTEM" ]]; then continue; fi
        if [[ "$f5" == "true" ]]; then continue; fi
        ;;
      search)
        local search_lower="${SEARCH_TERM,,}"
        local name_lower="${name,,}"
        local desc_lower="${description,,}"
        if [[ "$name_lower" != *"$search_lower"* ]] && [[ "$desc_lower" != *"$search_lower"* ]]; then
          continue
        fi
        ;;
      detail)
        local detail_lower="${DETAIL_NAME,,}"
        local name_lower="${name,,}"
        if [[ "$name_lower" != *"$detail_lower"* ]]; then continue; fi
        format_detail "$tier" "$stack" "$name" "$status" "$description" "$readme_path"
        count=$((count + 1))
        continue
        ;;
    esac

    format_package "$tier" "$stack" "$name" "$status" "$description" "$readme_path"
    count=$((count + 1))

  done <<< "$all_packages"

  echo ""
  echo "=== $count package(s) found ==="
}

# --- Run ---
process
