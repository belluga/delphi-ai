#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: verification_debt_audit.sh --todo <path> [--repo <path>] [--path <path> ...] [--scan-git-modified]

Deterministic support tool for verification-debt audits. It scans:
- the target TODO for waiver, blocker/provisional, and unchecked-item signals;
- selected code paths for inline debt markers such as TODO/FIXME/HACK/TBD/XXX.

Options:
  --todo <path>          Target TODO file to audit. Required.
  --repo <path>          Repository root. Defaults to current directory.
  --path <path>          Additional file or directory to scan for inline debt. Repeat as needed.
  --scan-git-modified    Include modified/untracked paths from `git status --porcelain` in the inline scan.
  -h, --help             Show this help text.

Exit codes:
  0  Audit completed with outcome `none` or `low`.
  2  Audit completed with outcome `medium` or `high`.
  1  Operational error (missing TODO, invalid repo/path, rg unavailable, etc.).
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

command -v rg >/dev/null 2>&1 || die "ripgrep (rg) is required"

REPO_INPUT="."
TODO_INPUT=""
SCAN_GIT_MODIFIED=false
declare -a SCAN_PATH_INPUTS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --repo)
      [ $# -ge 2 ] || die "missing value for --repo"
      REPO_INPUT="$2"
      shift 2
      ;;
    --todo)
      [ $# -ge 2 ] || die "missing value for --todo"
      TODO_INPUT="$2"
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

[ -n "$TODO_INPUT" ] || die "--todo is required"

REPO_ROOT="$(git -C "$REPO_INPUT" rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$REPO_ROOT" ]; then
  REPO_ROOT="$(cd "$REPO_INPUT" 2>/dev/null && pwd || true)"
fi
[ -n "$REPO_ROOT" ] || die "unable to resolve repository root from: $REPO_INPUT"

if [[ "$TODO_INPUT" = /* ]]; then
  TODO_PATH="$TODO_INPUT"
else
  TODO_PATH="$REPO_ROOT/$TODO_INPUT"
fi
[ -f "$TODO_PATH" ] || die "TODO file not found: $TODO_PATH"

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

WAIVER_PATTERN='\b(waiver|waived|skip|skipped|not run|not needed|n/?a|defer|deferred)\b'
BLOCKER_PATTERN='\b(blocked|provisional|pending|follow-up|follow up|incomplete)\b'
UNCHECKED_PATTERN='^\s*[-*]?\s*\[ \]'
INLINE_PATTERN='\b(TODO|FIXME|HACK|TBD|XXX)\b'

waiver_hits="$(rg -n -i "$WAIVER_PATTERN" "$TODO_PATH" || true)"
blocker_hits="$(rg -n -i "$BLOCKER_PATTERN" "$TODO_PATH" || true)"
unchecked_hits="$(rg -n "$UNCHECKED_PATTERN" "$TODO_PATH" || true)"

declare -a INLINE_ALL_HITS=()
declare -a INLINE_ACCEPTED=()
declare -a INLINE_CLEANUP_REQUIRED=()
declare -a INLINE_CANONICAL_LINK_MISSING=()

classify_inline_hit() {
  local entry="$1"
  local line_text="${entry#*:*:}"
  local lowered
  lowered="$(printf '%s' "$line_text" | tr '[:upper:]' '[:lower:]')"

  if [[ "$lowered" == *"foundation_documentation/"* ]] || \
     [[ "$lowered" == *"todo-"* ]] || \
     [[ "$lowered" == *"owner:"* ]] || \
     [[ "$lowered" == *"next:"* ]] || \
     [[ "$line_text" == *"@"* ]]; then
    INLINE_ACCEPTED+=("$entry")
    return
  fi

  if [[ "$lowered" == *"roadmap"* ]] || \
     [[ "$lowered" == *"constitution"* ]] || \
     [[ "$lowered" == *"module"* ]] || \
     [[ "$lowered" == *"doc"* ]]; then
    INLINE_CANONICAL_LINK_MISSING+=("$entry")
    return
  fi

  INLINE_CLEANUP_REQUIRED+=("$entry")
}

if [ "${#SCAN_PATHS[@]}" -gt 0 ]; then
  while IFS= read -r hit; do
    [ -n "$hit" ] || continue
    INLINE_ALL_HITS+=("$hit")
    classify_inline_hit "$hit"
  done < <(rg -n -I "$INLINE_PATTERN" "${SCAN_PATHS[@]}" || true)
fi

waiver_count=0
[ -n "$waiver_hits" ] && waiver_count="$(printf '%s\n' "$waiver_hits" | sed '/^$/d' | wc -l | tr -d '[:space:]')"
blocker_count=0
[ -n "$blocker_hits" ] && blocker_count="$(printf '%s\n' "$blocker_hits" | sed '/^$/d' | wc -l | tr -d '[:space:]')"
unchecked_count=0
[ -n "$unchecked_hits" ] && unchecked_count="$(printf '%s\n' "$unchecked_hits" | sed '/^$/d' | wc -l | tr -d '[:space:]')"

accepted_count="${#INLINE_ACCEPTED[@]}"
cleanup_required_count="${#INLINE_CLEANUP_REQUIRED[@]}"
canonical_link_missing_count="${#INLINE_CANONICAL_LINK_MISSING[@]}"

inline_classification="none"
if [ "$cleanup_required_count" -gt 0 ] || [ "$canonical_link_missing_count" -gt 0 ]; then
  inline_classification="cleanup-required"
elif [ "$accepted_count" -gt 0 ]; then
  inline_classification="accepted"
fi

outcome="none"
if [ "$blocker_count" -gt 0 ] || [ "$cleanup_required_count" -gt 2 ] || { [ "$waiver_count" -gt 0 ] && [ "$unchecked_count" -gt 0 ]; }; then
  outcome="high"
elif [ "$waiver_count" -gt 0 ] || [ "$unchecked_count" -gt 0 ] || [ "$cleanup_required_count" -gt 0 ] || [ "$canonical_link_missing_count" -gt 0 ]; then
  outcome="medium"
elif [ "$accepted_count" -gt 0 ]; then
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

printf 'Verification Debt Audit\n'
printf 'Repository: %s\n' "$REPO_ROOT"
printf 'TODO: %s\n' "$TODO_PATH"
printf 'Outcome heuristic: %s\n' "$outcome"
printf 'Inline code TODO debt classification: %s\n' "$inline_classification"
printf '\n'

print_block "Waiver / skip signals:" "$waiver_hits"
printf '\n'
print_block "Blocker / provisional / closure drift signals:" "$blocker_hits"
printf '\n'
print_block "Unchecked checklist items:" "$unchecked_hits"
printf '\n'
print_array_block "Inline debt scan paths:" "${SCAN_PATHS[@]}"
printf '\n'
print_array_block "Inline debt accepted:" "${INLINE_ACCEPTED[@]}"
printf '\n'
print_array_block "Inline debt canonical-link-missing:" "${INLINE_CANONICAL_LINK_MISSING[@]}"
printf '\n'
print_array_block "Inline debt cleanup-required:" "${INLINE_CLEANUP_REQUIRED[@]}"
printf '\n'
printf 'Counts: waiver=%s blocker=%s unchecked=%s accepted_inline=%s canonical_link_missing=%s cleanup_required=%s\n' \
  "$waiver_count" \
  "$blocker_count" \
  "$unchecked_count" \
  "$accepted_count" \
  "$canonical_link_missing_count" \
  "$cleanup_required_count"

if [ "$outcome" = "medium" ] || [ "$outcome" = "high" ]; then
  exit 2
fi

