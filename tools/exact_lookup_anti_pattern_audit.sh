#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: exact_lookup_anti_pattern_audit.sh [--repo <path>] [--path <path> ... | --scan-git-modified]

Heuristic audit for exact-lookup anti-patterns such as broad fetch + in-memory filtering
or page-walk exact lookup in Flutter/Laravel code.
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

REPO_INPUT="."
SCAN_GIT_MODIFIED=false
declare -a INPUT_PATHS=()
declare -a FILES=()

while [ $# -gt 0 ]; do
  case "$1" in
    --repo)
      [ $# -ge 2 ] || die "missing value for --repo"
      REPO_INPUT="$2"
      shift 2
      ;;
    --path)
      [ $# -ge 2 ] || die "missing value for --path"
      INPUT_PATHS+=("$2")
      shift 2
      ;;
    --scan-git-modified)
      SCAN_GIT_MODIFIED=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

REPO_ROOT="$(git -C "$REPO_INPUT" rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$REPO_ROOT" ]; then
  REPO_ROOT="$(cd "$REPO_INPUT" 2>/dev/null && pwd || true)"
fi
[ -n "$REPO_ROOT" ] || die "unable to resolve repository root from: $REPO_INPUT"

collect_files_from_path() {
  local path="$1"
  local abs_path=""

  if [ -d "$path" ] || [ -f "$path" ]; then
    abs_path="$(cd "$(dirname "$path")" 2>/dev/null && pwd)/$(basename "$path")"
  elif [ -d "$REPO_ROOT/$path" ] || [ -f "$REPO_ROOT/$path" ]; then
    abs_path="$REPO_ROOT/$path"
  else
    return 0
  fi

  if [ -f "$abs_path" ]; then
    FILES+=("$abs_path")
  else
    while IFS= read -r file; do
      FILES+=("$file")
    done < <(find "$abs_path" -type f \( -name '*.php' -o -name '*.dart' \) 2>/dev/null)
  fi
}

if [ "${#INPUT_PATHS[@]}" -gt 0 ]; then
  for input_path in "${INPUT_PATHS[@]}"; do
    collect_files_from_path "$input_path"
  done
elif [ "$SCAN_GIT_MODIFIED" = true ]; then
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    case "$rel" in
      *.php|*.dart)
        FILES+=("$REPO_ROOT/$rel")
        ;;
    esac
  done < <(git -C "$REPO_ROOT" status --short | awk '{print $2}')
else
  collect_files_from_path "$REPO_ROOT/flutter-app/lib"
  collect_files_from_path "$REPO_ROOT/laravel-app/app"
  collect_files_from_path "$REPO_ROOT/laravel-app/routes"
  collect_files_from_path "$REPO_ROOT/laravel-app/tests"
fi

declare -A SEEN_FILES=()
declare -a UNIQUE_FILES=()
for file in "${FILES[@]}"; do
  [ -f "$file" ] || continue
  if [ -z "${SEEN_FILES[$file]:-}" ]; then
    SEEN_FILES["$file"]=1
    UNIQUE_FILES+=("$file")
  fi
done

declare -a HIGH_FINDINGS=()
declare -a MEDIUM_FINDINGS=()

record_matches() {
  local severity="$1"
  local label="$2"
  local file="$3"
  local pattern="$4"
  local matches

  matches="$(rg -n "$pattern" "$file" 2>/dev/null || true)"
  [ -n "$matches" ] || return 0

  while IFS= read -r line; do
    [ -n "$line" ] || continue
    case "$severity" in
      HIGH) HIGH_FINDINGS+=("${file#$REPO_ROOT/}: $label :: $line") ;;
      MEDIUM) MEDIUM_FINDINGS+=("${file#$REPO_ROOT/}: $label :: $line") ;;
    esac
  done <<< "$matches"
}

for file in "${UNIQUE_FILES[@]}"; do
  case "$file" in
    *.php)
      record_matches MEDIUM "post-fetch exact-key filtering" "$file" '->(get|paginate|cursorPaginate)\([^)]*\)\s*->\s*(firstWhere|where)\(\s*["\x27](slug|id|uuid|code|handle|key|external_id|account_slug|tenant_slug)["\x27]'
      record_matches MEDIUM "collection exact-key filtering" "$file" 'collect\([^)]*\)\s*->\s*(firstWhere|where)\(\s*["\x27](slug|id|uuid|code|handle|key|external_id|account_slug|tenant_slug)["\x27]'
      if rg -n '(page\s*\+\+|for\s*\(.*page|while\s*\(.*page|nextPage)' "$file" >/dev/null 2>&1 && rg -n '(slug|id|uuid|code|handle|key|external_id|account_slug|tenant_slug)' "$file" >/dev/null 2>&1; then
        record_matches HIGH "possible page-walk exact lookup" "$file" '(page\s*\+\+|for\s*\(.*page|while\s*\(.*page|nextPage)'
      fi
      ;;
    *.dart)
      record_matches MEDIUM "in-memory exact-key firstWhere" "$file" 'firstWhere\(\s*\([^)]+\)\s*=>\s*[^)]*\.(slug|id|uuid|code|handle|key|accountSlug|tenantSlug)\s*=='
      record_matches MEDIUM "in-memory exact-key where+first" "$file" '\.where\(\s*\([^)]+\)\s*=>\s*[^)]*\.(slug|id|uuid|code|handle|key|accountSlug|tenantSlug)\s*=='
      if rg -n '(page\+\+|while\s*\(.*hasNext|for\s*\(.*page|nextPage|loadMore|fetchPage)' "$file" >/dev/null 2>&1 && rg -n '(slug|id|uuid|code|handle|key|accountSlug|tenantSlug)\s*==' "$file" >/dev/null 2>&1; then
        record_matches HIGH "possible page-walk exact lookup" "$file" '(page\+\+|while\s*\(.*hasNext|for\s*\(.*page|nextPage|loadMore|fetchPage)'
      fi
      ;;
  esac
done

printf 'Exact Lookup Anti-Pattern Audit\n'
printf 'Repository: %s\n' "$REPO_ROOT"
printf 'Files scanned: %s\n' "${#UNIQUE_FILES[@]}"
printf '\n'

if [ "${#HIGH_FINDINGS[@]}" -eq 0 ]; then
  printf 'High findings\n  - none\n\n'
else
  printf 'High findings\n'
  for finding in "${HIGH_FINDINGS[@]}"; do
    printf '  - %s\n' "$finding"
  done
  printf '\n'
fi

if [ "${#MEDIUM_FINDINGS[@]}" -eq 0 ]; then
  printf 'Medium findings\n  - none\n\n'
else
  printf 'Medium findings\n'
  for finding in "${MEDIUM_FINDINGS[@]}"; do
    printf '  - %s\n' "$finding"
  done
  printf '\n'
fi

printf 'Note: this audit is heuristic and only flags suspicious list-scan/page-walk exact-lookup patterns.\n'

if [ "${#HIGH_FINDINGS[@]}" -gt 0 ] || [ "${#MEDIUM_FINDINGS[@]}" -gt 0 ]; then
  exit 2
fi

exit 0
