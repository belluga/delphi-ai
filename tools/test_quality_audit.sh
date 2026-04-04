#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: test_quality_audit.sh [--repo <path>] [--path <path> ...] [--scan-git-modified]

Deterministic support tool for test-quality audits. It scans selected test paths for:
- hard bypass markers (`skip`, `.only`, `markTestSkipped`, etc.);
- test-only support route usage;
- auth shortcut hints (`Sanctum::actingAs`);
- weak-assertion hints (status-only / no-exception-only);
- DI override and mock/fallback hints that deserve manual review.

Options:
  --repo <path>          Repository root. Defaults to current directory.
  --path <path>          File or directory to scan. Repeat as needed.
  --scan-git-modified    Include modified/untracked paths from `git status --porcelain`.
  -h, --help             Show this help text.

If no explicit scan path is provided, the tool scans common test roots when they exist:
  tests/, test/, integration_test/, tools/flutter/web_app_tests/

Exit codes:
  0  Audit completed with outcome `none` or `low`.
  2  Audit completed with outcome `medium` or `high`.
  1  Operational error (invalid repo/path, no scan targets, missing rg, etc.).
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
  add_scan_path "tests"
  add_scan_path "test"
  add_scan_path "integration_test"
  add_scan_path "tools/flutter/web_app_tests"
fi

[ "${#SCAN_PATHS[@]}" -gt 0 ] || die "no scan targets found"

HARD_BYPASS_PATTERN='\b(test|describe|it)\.(only|skip)\s*\(|\bskip:\s*|->skip\s*\(|markTestSkipped'
TEST_ONLY_ROUTE_PATTERN='/test-support\b|\btest-support\b'
AUTH_SHORTCUT_PATTERN='\bSanctum::actingAs\b'
STATUS_ONLY_PATTERN='assertStatus\((200|201|202|204)\)|assertOk\s*\(|assertCreated\s*\(|assertNoContent\s*\(|statusCode\s*==\s*(200|201|202|204)|\.toBe\((200|201|202|204)\)'
NO_EXCEPTION_PATTERN='assertDoesNotThrow|doesNotThrow|not\.toThrow'
DI_OVERRIDE_PATTERN='GetIt\.(I|instance)\.register|registerSingleton|registerLazySingleton|registerFactory|app\(\)->instance\s*\('
MOCK_HINT_PATTERN='\bMock[A-Z][A-Za-z0-9_]*\b|\bFake[A-Z][A-Za-z0-9_]*\b|when\s*\(|thenReturn\s*\(|thenAnswer\s*\(|spyOn\s*\('

hard_bypass_hits="$(rg -n -I "$HARD_BYPASS_PATTERN" "${SCAN_PATHS[@]}" || true)"
test_support_hits="$(rg -n -I "$TEST_ONLY_ROUTE_PATTERN" "${SCAN_PATHS[@]}" || true)"
auth_shortcut_hits="$(rg -n -I "$AUTH_SHORTCUT_PATTERN" "${SCAN_PATHS[@]}" || true)"
status_only_hits="$(rg -n -I "$STATUS_ONLY_PATTERN" "${SCAN_PATHS[@]}" || true)"
no_exception_hits="$(rg -n -I "$NO_EXCEPTION_PATTERN" "${SCAN_PATHS[@]}" || true)"
di_override_hits="$(rg -n -I "$DI_OVERRIDE_PATTERN" "${SCAN_PATHS[@]}" || true)"
mock_hint_hits="$(rg -n -I "$MOCK_HINT_PATTERN" "${SCAN_PATHS[@]}" || true)"

count_hits() {
  local content="$1"
  if [ -z "$content" ]; then
    printf '0'
  else
    printf '%s\n' "$content" | sed '/^$/d' | wc -l | tr -d '[:space:]'
  fi
}

hard_bypass_count="$(count_hits "$hard_bypass_hits")"
test_support_count="$(count_hits "$test_support_hits")"
auth_shortcut_count="$(count_hits "$auth_shortcut_hits")"
status_only_count="$(count_hits "$status_only_hits")"
no_exception_count="$(count_hits "$no_exception_hits")"
di_override_count="$(count_hits "$di_override_hits")"
mock_hint_count="$(count_hits "$mock_hint_hits")"

outcome="none"
if [ "$hard_bypass_count" -gt 0 ] || [ "$test_support_count" -gt 0 ]; then
  outcome="high"
elif [ "$auth_shortcut_count" -gt 0 ] || [ "$status_only_count" -gt 0 ] || [ "$no_exception_count" -gt 0 ]; then
  outcome="medium"
elif [ "$di_override_count" -gt 0 ] || [ "$mock_hint_count" -gt 0 ]; then
  outcome="low"
fi

print_block() {
  local title="$1"
  local body="$2"
  printf '%s\n' "$title"
  if [ -z "$body" ]; then
    printf '  - none\n'
    return
  fi
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    printf '  - %s\n' "$line"
  done <<< "$body"
}

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

printf 'Test Quality Audit\n'
printf 'Repository: %s\n' "$REPO_ROOT"
printf 'Outcome heuristic: %s\n' "$outcome"
printf '\n'

print_array_block "Scan paths:" "${SCAN_PATHS[@]}"
printf '\n'
print_block "Hard bypass markers:" "$hard_bypass_hits"
printf '\n'
print_block "Test-only support route usage:" "$test_support_hits"
printf '\n'
print_block "Auth shortcut hints:" "$auth_shortcut_hits"
printf '\n'
print_block "Status-only assertion hints:" "$status_only_hits"
printf '\n'
print_block "No-exception-only assertion hints:" "$no_exception_hits"
printf '\n'
print_block "DI override hints:" "$di_override_hits"
printf '\n'
print_block "Mock / fallback hints:" "$mock_hint_hits"
printf '\n'
printf 'Counts: hard_bypass=%s test_support=%s auth_shortcut=%s status_only=%s no_exception_only=%s di_override=%s mock_hint=%s\n' \
  "$hard_bypass_count" \
  "$test_support_count" \
  "$auth_shortcut_count" \
  "$status_only_count" \
  "$no_exception_count" \
  "$di_override_count" \
  "$mock_hint_count"

if [ "$outcome" = "medium" ] || [ "$outcome" = "high" ]; then
  exit 2
fi

