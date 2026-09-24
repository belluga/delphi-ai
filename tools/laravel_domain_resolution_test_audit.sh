#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: laravel_domain_resolution_test_audit.sh [--repo <path>] [--path <path> ...] [--scan-git-modified]

Classify Laravel tenant-resolution test files as:
- web-context
- mobile-context
- mixed-context
- unclassified

Options:
  --repo <path>          Repository root. Defaults to current directory.
  --path <path>          File or directory to scan. Repeat as needed.
  --scan-git-modified    Include modified/untracked paths from `git status --porcelain`.
  -h, --help             Show this help text.

If no scan path is provided, the tool scans `laravel-app/tests` when it exists.

Exit codes:
  0  All candidate files were classified as web-context or mobile-context.
  2  One or more candidate files were classified as mixed-context or unclassified.
  1  Operational error (invalid repo/path, no test files found, missing rg, etc.).
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

command -v rg >/dev/null 2>&1 || die "ripgrep (rg) is required"

REPO_INPUT="."
SCAN_GIT_MODIFIED=false
declare -a SCAN_PATH_INPUTS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --repo)
      [ $# -ge 2 ] || die "missing value for --repo"
      REPO_INPUT="$2"
      shift 2
      ;;
    --path)
      [ $# -ge 2 ] || die "missing value for --path"
      SCAN_PATH_INPUTS+=("$2")
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

declare -A SCAN_PATH_SET=()
declare -a SCAN_PATHS=()

add_scan_path() {
  local candidate="$1"
  local resolved=""
  if [[ "$candidate" = /* ]]; then
    resolved="$candidate"
  else
    resolved="$REPO_ROOT/$candidate"
  fi
  [ -e "$resolved" ] || return 0
  if [ -n "${SCAN_PATH_SET[$resolved]:-}" ]; then
    return 0
  fi
  SCAN_PATH_SET["$resolved"]=1
  SCAN_PATHS+=("$resolved")
}

for path in "${SCAN_PATH_INPUTS[@]}"; do
  add_scan_path "$path"
done

if [ "$SCAN_GIT_MODIFIED" = true ] && git -C "$REPO_ROOT" rev-parse --show-toplevel >/dev/null 2>&1; then
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    if [[ "$line" =~ ^\?\?[[:space:]]+(.+)$ ]]; then
      add_scan_path "${BASH_REMATCH[1]}"
      continue
    fi
    if [ "${#line}" -ge 4 ]; then
      add_scan_path "${line:3}"
    fi
  done < <(git -C "$REPO_ROOT" status --porcelain)
fi

if [ "${#SCAN_PATHS[@]}" -eq 0 ]; then
  add_scan_path "laravel-app/tests"
fi
[ "${#SCAN_PATHS[@]}" -gt 0 ] || die "no scan targets found"

declare -a CANDIDATE_FILES=()
while IFS= read -r file; do
  [ -n "$file" ] || continue
  CANDIDATE_FILES+=("$file")
done < <(rg -l -g '*.php' 'X-App-Domain|app_domains|HTTP_HOST|withServerVariables|\bdomains\b|domain resolution|tenant resolution|branding|registration' "${SCAN_PATHS[@]}" || true)

[ "${#CANDIDATE_FILES[@]}" -gt 0 ] || die "no candidate Laravel test files found in scan scope"

declare -a WEB_CONTEXT=()
declare -a MOBILE_CONTEXT=()
declare -a MIXED_CONTEXT=()
declare -a UNCLASSIFIED=()

for file in "${CANDIDATE_FILES[@]}"; do
  mobile_markers="$(rg -n 'X-App-Domain|app_domains' "$file" || true)"
  web_markers="$(rg -n 'HTTP_HOST|withServerVariables|\bdomains\b' "$file" || true)"

  if [ -n "$mobile_markers" ] && [ -n "$web_markers" ]; then
    MIXED_CONTEXT+=("$file")
  elif [ -n "$mobile_markers" ]; then
    MOBILE_CONTEXT+=("$file")
  elif [ -n "$web_markers" ]; then
    WEB_CONTEXT+=("$file")
  else
    UNCLASSIFIED+=("$file")
  fi
done

print_array_block() {
  local title="$1"
  shift
  local items=("$@")
  printf '%s\n' "$title"
  if [ "${#items[@]}" -eq 0 ]; then
    printf '  - none\n'
    return
  fi
  local item
  for item in "${items[@]}"; do
    printf '  - %s\n' "$item"
  done
}

printf 'Laravel Domain Resolution Test Audit\n'
printf 'Repository: %s\n' "$REPO_ROOT"
printf '\n'

print_array_block "Scan paths:" "${SCAN_PATHS[@]}"
printf '\n'
print_array_block "Candidate files:" "${CANDIDATE_FILES[@]}"
printf '\n'
print_array_block "Web-context files:" "${WEB_CONTEXT[@]}"
printf '\n'
print_array_block "Mobile-context files:" "${MOBILE_CONTEXT[@]}"
printf '\n'
print_array_block "Mixed-context files:" "${MIXED_CONTEXT[@]}"
printf '\n'
print_array_block "Unclassified files:" "${UNCLASSIFIED[@]}"
printf '\n'

if [ "${#MIXED_CONTEXT[@]}" -gt 0 ] || [ "${#UNCLASSIFIED[@]}" -gt 0 ]; then
  printf 'Action: split or annotate mixed/unclassified files before claiming domain-resolution coverage.\n'
  exit 2
fi

printf 'Action: keep web-context tests host/domain-only and mobile-context tests X-App-Domain/app_domains-only.\n'
