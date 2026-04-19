#!/usr/bin/env bash
# query_packages.sh — Deterministic CLI to query proprietary packages.
#
# The agent calls this script instead of reading files manually.
# It reads ecosystem_packages.yaml + local_packages.yaml, cross-references
# with READMEs, and returns structured output to stdout.
#
# Usage:
#   bash delphi-ai/tools/query_packages.sh [options] [project-root]
#
# Options:
#   --all                 List all proprietary packages (default if no mode is set)
#   --search <term>       Search packages by name or description (case-insensitive)
#   --tier <tier>         Filter by tier: local | ecosystem | all (default: all)
#   --stack <stack>       Filter by stack: flutter | laravel | all (default: all)
#   --unused              Show only local packages that exist but are not in use
#   --detail <name>       Show full detail for an exact package name match
#   --project-root <path> Project root directory
#   --help                Show usage
#
# Output: structured text blocks, one per package, parseable by agents.
#
# Authority: paced.core.package-first

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  bash delphi-ai/tools/query_packages.sh [options] [project-root]

Options:
  --all                 List all proprietary packages (default if no mode is set)
  --search <term>       Search packages by name or description (case-insensitive)
  --tier <tier>         Filter by tier: local | ecosystem | all (default: all)
  --stack <stack>       Filter by stack: flutter | laravel | all (default: all)
  --unused              Show only local packages that exist but are not in use
  --detail <name>       Show full detail for an exact package name match
  --project-root <path> Project root directory
  --help                Show this help text
EOF
}

die() {
  echo "Error: $*" >&2
  exit 1
}

require_value() {
  local option="$1"
  local value="${2-}"

  [[ -n "$value" ]] || die "$option requires a non-empty value."
}

set_mode() {
  local requested_mode="$1"
  local option="$2"

  if [[ -n "$MODE_SET_BY" ]] && [[ "$MODE" != "$requested_mode" ]]; then
    die "Cannot combine '$MODE_SET_BY' with '$option'. Choose a single mode."
  fi

  MODE="$requested_mode"
  MODE_SET_BY="$option"
}

canonicalize_dir() {
  local path="$1"
  (cd "$path" >/dev/null 2>&1 && pwd)
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

yaml_unquote() {
  local value
  value="$(trim "$1")"

  if [[ ${#value} -ge 2 ]] && [[ "${value:0:1}" == "'" ]] && [[ "${value: -1}" == "'" ]]; then
    value="${value:1:${#value}-2}"
    value="$(printf '%s' "$value" | sed "s/''/'/g")"
  elif [[ ${#value} -ge 2 ]] && [[ "${value:0:1}" == '"' ]] && [[ "${value: -1}" == '"' ]]; then
    value="${value:1:${#value}-2}"
    value="${value//\\\"/\"}"
    value="${value//\\\\/\\}"
  fi

  printf '%s' "$value"
}

validate_project_root() {
  [[ -d "$PROJECT_ROOT" ]] || die "Project root '$PROJECT_ROOT' does not exist or is not a directory."

  PROJECT_ROOT="$(canonicalize_dir "$PROJECT_ROOT")" || die "Unable to resolve project root '$PROJECT_ROOT'."

  [[ -d "$PROJECT_ROOT/delphi-ai" ]] || die "Invalid project root '$PROJECT_ROOT': missing delphi-ai/."
  [[ -d "$PROJECT_ROOT/foundation_documentation" ]] || die "Invalid project root '$PROJECT_ROOT': missing foundation_documentation/."
}

validate_filters() {
  case "$TIER_FILTER" in
    all|local|ecosystem) ;;
    *) die "Invalid --tier '$TIER_FILTER'. Expected one of: all, local, ecosystem." ;;
  esac

  case "$STACK_FILTER" in
    all|flutter|laravel) ;;
    *) die "Invalid --stack '$STACK_FILTER'. Expected one of: all, flutter, laravel." ;;
  esac

  if [[ "$MODE" == "search" ]]; then
    [[ -n "$SEARCH_TERM" ]] || die "--search requires a non-empty term."
  fi

  if [[ "$MODE" == "detail" ]]; then
    [[ -n "$DETAIL_NAME" ]] || die "--detail requires an exact package name."
  fi
}

# --- Defaults ---
PROJECT_ROOT="."
MODE="all"
MODE_SET_BY=""
SEARCH_TERM=""
TIER_FILTER="all"
STACK_FILTER="all"
DETAIL_NAME=""
POSITIONAL_ROOT=""

# --- Argument parsing ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h)
      usage
      exit 0
      ;;
    --all)
      set_mode "all" "--all"
      shift
      ;;
    --search)
      require_value "--search" "${2-}"
      set_mode "search" "--search"
      SEARCH_TERM="$2"
      shift 2
      ;;
    --tier)
      require_value "--tier" "${2-}"
      TIER_FILTER="$2"
      shift 2
      ;;
    --stack)
      require_value "--stack" "${2-}"
      STACK_FILTER="$2"
      shift 2
      ;;
    --unused)
      set_mode "unused" "--unused"
      shift
      ;;
    --detail)
      require_value "--detail" "${2-}"
      set_mode "detail" "--detail"
      DETAIL_NAME="$2"
      shift 2
      ;;
    --project-root)
      require_value "--project-root" "${2-}"
      PROJECT_ROOT="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    -*)
      die "Unknown option '$1'. Use --help for usage."
      ;;
    *)
      [[ -z "$POSITIONAL_ROOT" ]] || die "Multiple positional project roots provided. Use --project-root for clarity."
      POSITIONAL_ROOT="$1"
      shift
      ;;
  esac
done

if [[ $# -gt 0 ]]; then
  die "Unexpected extra arguments: $*"
fi

if [[ -n "$POSITIONAL_ROOT" ]]; then
  if [[ "$PROJECT_ROOT" != "." ]] && [[ "$PROJECT_ROOT" != "$POSITIONAL_ROOT" ]]; then
    die "Conflicting project roots: positional '$POSITIONAL_ROOT' and --project-root '$PROJECT_ROOT'."
  fi
  PROJECT_ROOT="$POSITIONAL_ROOT"
fi

validate_filters
validate_project_root

DELPHI_DIR="$PROJECT_ROOT/delphi-ai"
ECOSYSTEM_YAML="$DELPHI_DIR/config/ecosystem_packages.yaml"
LOCAL_YAML="$PROJECT_ROOT/foundation_documentation/local_packages.yaml"
VERIFY_SCRIPT="$DELPHI_DIR/tools/verify_package_registry.sh"

[[ -f "$ECOSYSTEM_YAML" ]] || die "Missing ecosystem registry at '$ECOSYSTEM_YAML'."

# --- Detect stack roots ---
FLUTTER_ROOT="$PROJECT_ROOT"
LARAVEL_ROOT="$PROJECT_ROOT"
[[ -d "$PROJECT_ROOT/flutter-app" ]] && FLUTTER_ROOT="$PROJECT_ROOT/flutter-app"
[[ -d "$PROJECT_ROOT/laravel-app" ]] && LARAVEL_ROOT="$PROJECT_ROOT/laravel-app"

# --- Ensure local YAML exists ---
if [[ ! -f "$LOCAL_YAML" ]]; then
  [[ -f "$VERIFY_SCRIPT" ]] || die "Missing local registry '$LOCAL_YAML' and generator '$VERIFY_SCRIPT'."

  bash "$VERIFY_SCRIPT" --project-root "$PROJECT_ROOT"
  [[ -f "$LOCAL_YAML" ]] || die "Local registry generation did not produce '$LOCAL_YAML'."
fi

# --- Parse ecosystem YAML ---
# Format: ECOSYSTEM|<stack>|<name>|<description>|<pub_dev_or_packagist>
parse_ecosystem() {
  local current_stack=""
  local name="" description="" pub_url=""

  while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// }" ]] && continue

    if [[ "$line" =~ ^flutter:[[:space:]]*$ ]]; then
      if [[ -n "$name" ]]; then
        echo "ECOSYSTEM|$current_stack|$name|$description|$pub_url"
      fi
      current_stack="flutter"
      name=""
      description=""
      pub_url=""
      continue
    elif [[ "$line" =~ ^laravel:[[:space:]]*$ ]]; then
      if [[ -n "$name" ]]; then
        echo "ECOSYSTEM|$current_stack|$name|$description|$pub_url"
      fi
      current_stack="laravel"
      name=""
      description=""
      pub_url=""
      continue
    fi

    if [[ "$line" =~ ^[a-z_]+: ]] && [[ ! "$line" =~ ^[[:space:]] ]]; then
      continue
    fi

    if [[ -n "$current_stack" ]]; then
      if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*name:[[:space:]]*(.+) ]]; then
        if [[ -n "$name" ]]; then
          echo "ECOSYSTEM|$current_stack|$name|$description|$pub_url"
        fi
        name="$(yaml_unquote "${BASH_REMATCH[1]}")"
        description=""
        pub_url=""
      elif [[ "$line" =~ ^[[:space:]]*description:[[:space:]]*(.+) ]]; then
        description="$(yaml_unquote "${BASH_REMATCH[1]}")"
      elif [[ "$line" =~ ^[[:space:]]*pub_dev:[[:space:]]*(.+) ]]; then
        pub_url="$(yaml_unquote "${BASH_REMATCH[1]}")"
      elif [[ "$line" =~ ^[[:space:]]*packagist:[[:space:]]*(.+) ]]; then
        pub_url="$(yaml_unquote "${BASH_REMATCH[1]}")"
      fi
    fi
  done < "$ECOSYSTEM_YAML"

  if [[ -n "$name" ]]; then
    echo "ECOSYSTEM|$current_stack|$name|$description|$pub_url"
  fi
}

# --- Parse local YAML ---
# Format: LOCAL|<stack>|<name>|<path>|<in_use>|<has_readme>|<description>
parse_local() {
  local current_stack=""
  local name="" path="" in_use="" has_readme="" description=""

  while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue

    if [[ "$line" =~ ^laravel: ]]; then
      if [[ -n "$name" ]]; then
        echo "LOCAL|$current_stack|$name|$path|$in_use|$has_readme|$description"
      fi
      current_stack="laravel"
      name=""
      continue
    elif [[ "$line" =~ ^flutter: ]]; then
      if [[ -n "$name" ]]; then
        echo "LOCAL|$current_stack|$name|$path|$in_use|$has_readme|$description"
      fi
      current_stack="flutter"
      name=""
      continue
    elif [[ "$line" =~ ^anti_patterns: ]]; then
      break
    fi

    if [[ -n "$current_stack" ]]; then
      if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*name:[[:space:]]*(.+)$ ]]; then
        if [[ -n "$name" ]]; then
          echo "LOCAL|$current_stack|$name|$path|$in_use|$has_readme|$description"
        fi
        name="$(yaml_unquote "${BASH_REMATCH[1]}")"
        path=""
        in_use=""
        has_readme=""
        description=""
      elif [[ "$line" =~ ^[[:space:]]*path:[[:space:]]*(.+)$ ]]; then
        path="$(yaml_unquote "${BASH_REMATCH[1]}")"
      elif [[ "$line" =~ ^[[:space:]]*in_use:[[:space:]]*(true|false) ]]; then
        in_use="${BASH_REMATCH[1]}"
      elif [[ "$line" =~ ^[[:space:]]*has_readme:[[:space:]]*(true|false) ]]; then
        has_readme="${BASH_REMATCH[1]}"
      elif [[ "$line" =~ ^[[:space:]]*description:[[:space:]]*(.*)$ ]]; then
        description="$(yaml_unquote "${BASH_REMATCH[1]}")"
      fi
    fi
  done < "$LOCAL_YAML"

  if [[ -n "$name" ]]; then
    echo "LOCAL|$current_stack|$name|$path|$in_use|$has_readme|$description"
  fi
}

resolve_readme() {
  local tier="$1"
  local stack="$2"
  local pkg_path="$3"

  if [[ "$tier" == "LOCAL" ]]; then
    local root="$PROJECT_ROOT"
    [[ "$stack" == "flutter" ]] && root="$FLUTTER_ROOT"
    [[ "$stack" == "laravel" ]] && root="$LARAVEL_ROOT"

    local readme="$root/$pkg_path/README.md"
    [[ -f "$readme" ]] && echo "$readme" || echo ""
  fi
}

format_package() {
  local tier="$1"
  local stack="$2"
  local name="$3"
  local status="$4"
  local description="$5"
  local readme_path="$6"

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
  local tier="$1"
  local stack="$2"
  local name="$3"
  local status="$4"
  local description="$5"
  local readme_path="$6"

  format_package "$tier" "$stack" "$name" "$status" "$description" "$readme_path"
  echo ""

  if [[ -n "$readme_path" ]] && [[ -f "$readme_path" ]]; then
    echo "=== README CONTENT ==="
    cat "$readme_path"
    echo "=== END README ==="
  fi
}

collect_all() {
  parse_ecosystem
  parse_local
}

process() {
  local count=0
  local all_packages=""

  all_packages="$(collect_all)"

  if [[ -z "$all_packages" ]]; then
    echo "=== 0 package(s) found ==="
    return
  fi

  while IFS='|' read -r tier stack name f4 f5 f6 f7; do
    [[ -z "$tier" ]] && continue

    if [[ "$STACK_FILTER" != "all" ]] && [[ "$stack" != "$STACK_FILTER" ]]; then
      continue
    fi

    if [[ "$TIER_FILTER" != "all" ]]; then
      local tier_lower="${tier,,}"
      if [[ "$tier_lower" != "$TIER_FILTER" ]]; then
        continue
      fi
    fi

    local description=""
    local status=""
    local readme_path=""

    if [[ "$tier" == "ECOSYSTEM" ]]; then
      description="$f4"
      status="ecosystem (published)"
      if [[ -n "$f5" ]] && [[ "$f5" != "null" ]]; then
        status="ecosystem ($f5)"
      fi
    else
      description="${f7:-}"
      if [[ "$f5" == "true" ]]; then
        status="in_use"
      else
        status="available (not in use)"
      fi
      readme_path="$(resolve_readme "$tier" "$stack" "$f4")"
    fi

    case "$MODE" in
      unused)
        [[ "$tier" == "LOCAL" ]] || continue
        [[ "$f5" == "false" ]] || continue
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
        if [[ "$name_lower" != "$detail_lower" ]]; then
          continue
        fi
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

process
