#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  run_claude_print.sh --workdir <dir> [options]

Prompt source (choose exactly one):
  --prompt "<text>"
  --prompt-file <file>
  --stdin

Options:
  --add-dir <dir>          May be repeated
  --allowed-tools "<spec>"
  --output-format <fmt>    text|json|stream-json (default: text)
  --permission-mode <mode> bypassPermissions|default|acceptEdits|plan (default: bypassPermissions)
EOF
}

WORKDIR=""
PROMPT=""
PROMPT_FILE=""
USE_STDIN=0
OUTPUT_FORMAT="text"
PERMISSION_MODE="bypassPermissions"
ALLOWED_TOOLS=""
ADD_DIRS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --workdir)
      WORKDIR="${2:-}"
      shift 2
      ;;
    --prompt)
      PROMPT="${2:-}"
      shift 2
      ;;
    --prompt-file)
      PROMPT_FILE="${2:-}"
      shift 2
      ;;
    --stdin)
      USE_STDIN=1
      shift
      ;;
    --add-dir)
      ADD_DIRS+=("${2:-}")
      shift 2
      ;;
    --allowed-tools)
      ALLOWED_TOOLS="${2:-}"
      shift 2
      ;;
    --output-format)
      OUTPUT_FORMAT="${2:-}"
      shift 2
      ;;
    --permission-mode)
      PERMISSION_MODE="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "$WORKDIR" ]]; then
  echo "ERROR: --workdir is required." >&2
  exit 1
fi

PROMPT_SOURCE_COUNT=0
[[ -n "$PROMPT" ]] && PROMPT_SOURCE_COUNT=$((PROMPT_SOURCE_COUNT + 1))
[[ -n "$PROMPT_FILE" ]] && PROMPT_SOURCE_COUNT=$((PROMPT_SOURCE_COUNT + 1))
[[ "$USE_STDIN" -eq 1 ]] && PROMPT_SOURCE_COUNT=$((PROMPT_SOURCE_COUNT + 1))

if [[ "$PROMPT_SOURCE_COUNT" -ne 1 ]]; then
  echo "ERROR: choose exactly one prompt source: --prompt, --prompt-file, or --stdin." >&2
  exit 1
fi

WORKDIR="$(cd "$WORKDIR" && pwd)"

CLAUDE_ARGS=(
  -p
  --output-format "$OUTPUT_FORMAT"
  --permission-mode "$PERMISSION_MODE"
)

if [[ -n "$ALLOWED_TOOLS" ]]; then
  CLAUDE_ARGS+=(--allowedTools "$ALLOWED_TOOLS")
fi

for dir in "${ADD_DIRS[@]}"; do
  CLAUDE_ARGS+=(--add-dir "$dir")
done

run_with_stdin() {
  local tmpfile="$1"
  cat "$tmpfile" | claude "${CLAUDE_ARGS[@]}"
}

if [[ -n "$PROMPT_FILE" ]]; then
  run_with_stdin "$PROMPT_FILE"
  exit 0
fi

if [[ "$USE_STDIN" -eq 1 ]]; then
  claude "${CLAUDE_ARGS[@]}"
  exit 0
fi

tmp_prompt="$(mktemp "/tmp/claude-cli-prompt-XXXXXX.txt")"
trap 'rm -f "$tmp_prompt"' EXIT
printf '%s' "$PROMPT" > "$tmp_prompt"
run_with_stdin "$tmp_prompt"
