#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  bash delphi-ai/skills/laravel-suite-tail-recovery/scripts/replay_suite_tail.sh [options]

Options:
  --from <test-file>        First failing file to replay from. Accepts with or without .php.
  --inventory-only          Generate suite inventory only; do not replay files.
  --artifacts-dir <path>    Override artifact base directory.
  --project-root <path>     Override project root.
  --laravel-root <path>     Override laravel-app root.
  --run-id <id>             Override generated run id.
  -h, --help                Show help.
EOF
}

find_project_root() {
  local start="$1"
  local current="$start"
  for _ in 1 2 3 4 5 6 7 8; do
    if [ -d "$current/laravel-app" ] && [ -d "$current/foundation_documentation" ] && [ -d "$current/delphi-ai" ]; then
      printf '%s\n' "$current"
      return 0
    fi
    current="$(cd "$current/.." && pwd 2>/dev/null || true)"
    [ -n "$current" ] || break
  done
  return 1
}

normalize_test_path() {
  local value="$1"
  value="${value#./}"
  if [[ "$value" != tests/* ]]; then
    printf '%s\n' "$value"
    return 0
  fi
  if [[ "$value" != *.php ]]; then
    value="${value}.php"
  fi
  printf '%s\n' "$value"
}

resolve_listed_test_path() {
  local candidate="$1"
  local laravel_root="$2"
  local direct_path="$laravel_root/$candidate"

  if [ -f "$direct_path" ]; then
    printf '%s\n' "$candidate"
    return 0
  fi

  local basename
  basename="$(basename "$candidate")"
  mapfile -t matches < <(find "$laravel_root" -type f -path '*/tests/*.php' -name "$basename" | sort)

  if [ "${#matches[@]}" -eq 1 ]; then
    local resolved="${matches[0]#$laravel_root/}"
    printf '%s\n' "$resolved"
    return 0
  fi

  echo "ERROR: unable to resolve listed test path '$candidate' to a real file under '$laravel_root'." >&2
  if [ "${#matches[@]}" -gt 1 ]; then
    echo "Ambiguous basename matches:" >&2
    printf ' - %s\n' "${matches[@]}" >&2
  fi
  return 1
}

resolve_from_match() {
  local requested="$1"
  local suite_file="$2"
  local normalized
  normalized="$(normalize_test_path "$requested")"

  if grep -Fxq "$normalized" "$suite_file"; then
    printf '%s\n' "$normalized"
    return 0
  fi

  mapfile -t matches < <(grep -F "/$(basename "$normalized")" "$suite_file" || true)
  if [ "${#matches[@]}" -eq 1 ]; then
    printf '%s\n' "${matches[0]}"
    return 0
  fi

  echo "ERROR: unable to resolve --from '$requested' inside suite inventory '$suite_file'." >&2
  if [ "${#matches[@]}" -gt 1 ]; then
    echo "Ambiguous suffix matches:" >&2
    printf ' - %s\n' "${matches[@]}" >&2
  fi
  return 1
}

PROJECT_ROOT=""
LARAVEL_ROOT=""
ARTIFACTS_DIR=""
RUN_ID=""
FROM_FILE=""
INVENTORY_ONLY=0

while (($#)); do
  case "$1" in
    --from)
      FROM_FILE="${2:-}"
      shift 2
      ;;
    --inventory-only)
      INVENTORY_ONLY=1
      shift
      ;;
    --artifacts-dir)
      ARTIFACTS_DIR="${2:-}"
      shift 2
      ;;
    --project-root)
      PROJECT_ROOT="${2:-}"
      shift 2
      ;;
    --laravel-root)
      LARAVEL_ROOT="${2:-}"
      shift 2
      ;;
    --run-id)
      RUN_ID="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: unknown argument '$1'." >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [ -z "$PROJECT_ROOT" ]; then
  PROJECT_ROOT="$(find_project_root "$(pwd)" || true)"
fi

if [ -z "$PROJECT_ROOT" ]; then
  echo "ERROR: could not resolve project root." >&2
  exit 1
fi

if [ -z "$LARAVEL_ROOT" ]; then
  LARAVEL_ROOT="$PROJECT_ROOT/laravel-app"
fi

if [ -z "$ARTIFACTS_DIR" ]; then
  ARTIFACTS_DIR="$PROJECT_ROOT/foundation_documentation/artifacts/tmp/laravel-suite-tail-recovery"
fi

if [ -z "$RUN_ID" ]; then
  RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)"
fi

RUN_DIR="$ARTIFACTS_DIR/$RUN_ID"
LOG_DIR="$RUN_DIR/logs"
RAW_LIST="$RUN_DIR/phpunit-list-tests.out"
SUITE_FILES="$RUN_DIR/laravel-suite-files.txt"
STATUS_FILE="$RUN_DIR/run-status.tsv"

mkdir -p "$LOG_DIR"

SAFE_RUNNER="${LARAVEL_SAFE_RUNNER:-}"
if [ -z "$SAFE_RUNNER" ]; then
  if [ -x "$LARAVEL_ROOT/scripts/delphi/run_laravel_tests_safe.sh" ]; then
    SAFE_RUNNER="$LARAVEL_ROOT/scripts/delphi/run_laravel_tests_safe.sh"
  else
    SAFE_RUNNER="$PROJECT_ROOT/delphi-ai/scripts/laravel/run_laravel_tests_safe.sh"
  fi
fi

if [ ! -f "$SAFE_RUNNER" ]; then
  echo "ERROR: safe runner not found at '$SAFE_RUNNER'." >&2
  exit 1
fi

(
  cd "$LARAVEL_ROOT"
  bash "$SAFE_RUNNER" --list-tests
) | tee "$RAW_LIST" >/dev/null

RAW_SUITE_FILES="$RUN_DIR/laravel-suite-files.raw.txt"

awk '
  /^ - Tests\\/ {
    entry=$2
    sub(/::.*/, "", entry)
    gsub(/\\/, "/", entry)
    sub(/^Tests\//, "tests/", entry)
    print entry ".php"
  }
' "$RAW_LIST" > "$RAW_SUITE_FILES"

if [ ! -s "$RAW_SUITE_FILES" ]; then
  echo "ERROR: raw suite inventory is empty at '$RAW_SUITE_FILES'." >&2
  exit 1
fi

while IFS= read -r candidate; do
  [ -n "$candidate" ] || continue
  resolve_listed_test_path "$candidate" "$LARAVEL_ROOT"
done < "$RAW_SUITE_FILES" | awk '!seen[$0]++' > "$SUITE_FILES"

if [ ! -s "$SUITE_FILES" ]; then
  echo "ERROR: suite inventory is empty at '$SUITE_FILES'." >&2
  exit 1
fi

printf 'index\tfile\tstatus\tlog\n' > "$STATUS_FILE"

if [ "$INVENTORY_ONLY" -eq 1 ] || [ -z "$FROM_FILE" ]; then
  echo "Inventory written to: $RUN_DIR"
  echo "Suite file list: $SUITE_FILES"
  exit 0
fi

RESOLVED_FROM="$(resolve_from_match "$FROM_FILE" "$SUITE_FILES")"
START_LINE="$(grep -n -Fx "$RESOLVED_FROM" "$SUITE_FILES" | cut -d: -f1)"

if [ -z "$START_LINE" ]; then
  echo "ERROR: start line not found for '$RESOLVED_FROM'." >&2
  exit 1
fi

TOTAL_FILES="$(wc -l < "$SUITE_FILES" | tr -d ' ')"
echo "Replaying suite tail from line $START_LINE of $TOTAL_FILES: $RESOLVED_FROM"
echo "Artifacts: $RUN_DIR"

while IFS=$'\t' read -r index file; do
  safe_name="${file#tests/}"
  safe_name="${safe_name%.php}"
  safe_name="${safe_name//\//__}"
  log_file="$LOG_DIR/$(printf '%04d' "$index")-${safe_name}.log"

  echo
  echo "RUN [$index/$TOTAL_FILES] $file"

  if (
    cd "$LARAVEL_ROOT"
    bash "$SAFE_RUNNER" "$file" < /dev/null
  ) | tee "$log_file"; then
    printf '%s\t%s\tpassed\t%s\n' "$index" "$file" "$log_file" >> "$STATUS_FILE"
    continue
  fi

  printf '%s\t%s\tfailed\t%s\n' "$index" "$file" "$log_file" >> "$STATUS_FILE"
  echo "Stopped on failing file: $file"
  echo "Inspect log: $log_file"
  exit 1
done < <(tail -n +"$START_LINE" "$SUITE_FILES" | nl -ba -v "$START_LINE" -w 4 -s $'\t')

echo
echo "Suite tail replay completed clean."
echo "Artifacts: $RUN_DIR"
