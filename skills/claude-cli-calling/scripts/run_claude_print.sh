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
  --tools "<spec>"         Restrict the Claude built-in tool set
  --model <model>          Claude model alias or identifier
  --effort <level>         Claude effort level
  --no-session-persistence Do not retain the print session
  --json-schema-file <path>
                            Require JSON output matching the supplied schema
  --structured-result-output <path>
                            Force stream-json and extract the terminal result to this path
  --output-format <fmt>    text|json|stream-json (default: text)
  --include-partial-messages
  --verbose
  --permission-mode <mode> bypassPermissions|default|acceptEdits|plan (default: bypassPermissions)
EOF
}

WORKDIR=""
PROMPT=""
PROMPT_FILE=""
USE_STDIN=0
OUTPUT_FORMAT="text"
INCLUDE_PARTIAL_MESSAGES=0
VERBOSE=0
PERMISSION_MODE="bypassPermissions"
ALLOWED_TOOLS=""
TOOLS=""
MODEL=""
EFFORT=""
NO_SESSION_PERSISTENCE=0
JSON_SCHEMA_FILE=""
STRUCTURED_RESULT_OUTPUT=""
ADD_DIRS=()
TEMP_FILES=()

cleanup() {
  if [[ "${#TEMP_FILES[@]}" -gt 0 ]]; then
    rm -f "${TEMP_FILES[@]}"
  fi
}

trap cleanup EXIT

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
    --tools)
      TOOLS="${2:-}"
      shift 2
      ;;
    --model)
      MODEL="${2:-}"
      shift 2
      ;;
    --effort)
      EFFORT="${2:-}"
      shift 2
      ;;
    --no-session-persistence)
      NO_SESSION_PERSISTENCE=1
      shift
      ;;
    --json-schema-file)
      JSON_SCHEMA_FILE="${2:-}"
      shift 2
      ;;
    --structured-result-output)
      STRUCTURED_RESULT_OUTPUT="${2:-}"
      shift 2
      ;;
    --output-format)
      OUTPUT_FORMAT="${2:-}"
      shift 2
      ;;
    --include-partial-messages)
      INCLUDE_PARTIAL_MESSAGES=1
      shift
      ;;
    --verbose)
      VERBOSE=1
      shift
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

if [[ -n "$JSON_SCHEMA_FILE" && ! -f "$JSON_SCHEMA_FILE" ]]; then
  echo "ERROR: --json-schema-file does not exist: $JSON_SCHEMA_FILE" >&2
  exit 1
fi

if [[ -n "$STRUCTURED_RESULT_OUTPUT" ]]; then
  mkdir -p "$(dirname "$STRUCTURED_RESULT_OUTPUT")"
  OUTPUT_FORMAT="stream-json"
  INCLUDE_PARTIAL_MESSAGES=1
  VERBOSE=1
fi

CLAUDE_ARGS=(
  -p
  --output-format "$OUTPUT_FORMAT"
  --permission-mode "$PERMISSION_MODE"
)

if [[ "$OUTPUT_FORMAT" == "stream-json" ]]; then
  VERBOSE=1
fi

if [[ "$INCLUDE_PARTIAL_MESSAGES" -eq 1 ]]; then
  CLAUDE_ARGS+=(--include-partial-messages)
fi

if [[ "$VERBOSE" -eq 1 ]]; then
  CLAUDE_ARGS+=(--verbose)
fi

if [[ -n "$ALLOWED_TOOLS" ]]; then
  CLAUDE_ARGS+=(--allowedTools "$ALLOWED_TOOLS")
fi

if [[ -n "$TOOLS" ]]; then
  CLAUDE_ARGS+=(--tools "$TOOLS")
fi

if [[ -n "$MODEL" ]]; then
  CLAUDE_ARGS+=(--model "$MODEL")
fi

if [[ -n "$EFFORT" ]]; then
  CLAUDE_ARGS+=(--effort "$EFFORT")
fi

if [[ "$NO_SESSION_PERSISTENCE" -eq 1 ]]; then
  CLAUDE_ARGS+=(--no-session-persistence)
fi

if [[ -n "$JSON_SCHEMA_FILE" ]]; then
  CLAUDE_ARGS+=(--json-schema "$(<"$JSON_SCHEMA_FILE")")
fi

for dir in "${ADD_DIRS[@]}"; do
  CLAUDE_ARGS+=(--add-dir "$dir")
done

run_with_stdin() {
  local tmpfile="$1"
  cat "$tmpfile" | claude "${CLAUDE_ARGS[@]}"
}

run_and_extract_result() {
  local prompt_file="$1"
  local raw_output
  local -a extract_args
  raw_output="$(mktemp "/tmp/claude-cli-stream-XXXXXX.jsonl")"
  TEMP_FILES+=("$raw_output")

  echo "Claude structured run started; capturing stream for result extraction." >&2
  if ! run_with_stdin "$prompt_file" >"$raw_output"; then
    mv "$raw_output" "${STRUCTURED_RESULT_OUTPUT}.stream.jsonl"
    echo "ERROR: Claude stream failed; preserved transcript at ${STRUCTURED_RESULT_OUTPUT}.stream.jsonl" >&2
    return 1
  fi

  extract_args=(--stream "$raw_output" --output "$STRUCTURED_RESULT_OUTPUT")
  if [[ -n "$JSON_SCHEMA_FILE" ]]; then
    extract_args+=(--json-schema "$JSON_SCHEMA_FILE")
  fi
  if ! python3 "$(dirname "$0")/extract_claude_stream_result.py" "${extract_args[@]}"; then
    mv "$raw_output" "${STRUCTURED_RESULT_OUTPUT}.stream.jsonl"
    echo "ERROR: Claude result extraction failed; preserved transcript at ${STRUCTURED_RESULT_OUTPUT}.stream.jsonl" >&2
    return 1
  fi

  echo "Claude structured result written to ${STRUCTURED_RESULT_OUTPUT}" >&2
}

if [[ -n "$PROMPT_FILE" ]]; then
  if [[ -n "$STRUCTURED_RESULT_OUTPUT" ]]; then
    run_and_extract_result "$PROMPT_FILE"
    exit 0
  fi
  run_with_stdin "$PROMPT_FILE"
  exit 0
fi

if [[ "$USE_STDIN" -eq 1 ]]; then
  if [[ -n "$STRUCTURED_RESULT_OUTPUT" ]]; then
    stdin_prompt="$(mktemp "/tmp/claude-cli-prompt-XXXXXX.txt")"
    TEMP_FILES+=("$stdin_prompt")
    cat >"$stdin_prompt"
    run_and_extract_result "$stdin_prompt"
    exit 0
  fi
  claude "${CLAUDE_ARGS[@]}"
  exit 0
fi

tmp_prompt="$(mktemp "/tmp/claude-cli-prompt-XXXXXX.txt")"
TEMP_FILES+=("$tmp_prompt")
printf '%s' "$PROMPT" > "$tmp_prompt"
if [[ -n "$STRUCTURED_RESULT_OUTPUT" ]]; then
  run_and_extract_result "$tmp_prompt"
  exit 0
fi
run_with_stdin "$tmp_prompt"
