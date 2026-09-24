#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  run_claude_review_pass.sh \
    --repo-root <path> \
    --packet <review-packet.md> \
    --repo-label <label> \
    --mode <low|medium|tooling> \
    --focus <focus text>
EOF
}

REPO_ROOT=""
PACKET=""
REPO_LABEL=""
MODE=""
FOCUS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo-root)
      REPO_ROOT="${2:-}"
      shift 2
      ;;
    --packet)
      PACKET="${2:-}"
      shift 2
      ;;
    --repo-label)
      REPO_LABEL="${2:-}"
      shift 2
      ;;
    --mode)
      MODE="${2:-}"
      shift 2
      ;;
    --focus)
      FOCUS="${2:-}"
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

if [[ -z "$REPO_ROOT" || -z "$PACKET" || -z "$REPO_LABEL" || -z "$MODE" || -z "$FOCUS" ]]; then
  echo "ERROR: missing required arguments." >&2
  usage >&2
  exit 1
fi

REPO_ROOT="$(cd "$REPO_ROOT" && pwd)"
PACKET="$(cd "$(dirname "$PACKET")" && pwd)/$(basename "$PACKET")"
PACKET_DIR="$(dirname "$PACKET")"

case "$MODE" in
  low)
    MODE_TEXT="This is the low-effort pass."
    ;;
  medium)
    MODE_TEXT="This is the medium-effort pass."
    ;;
  tooling)
    MODE_TEXT="This is the tooling/CI pass."
    ;;
  *)
    echo "ERROR: unsupported mode: $MODE" >&2
    exit 1
    ;;
esac

PROMPT="You are simulating GitHub Copilot pull request review comments for the ${REPO_LABEL} PR. Read ${PACKET} first, then inspect only the files implicated by likely issues. ${MODE_TEXT} Focus on ${FOCUS}. Return only likely review comments. For each item use exactly: severity | locus | finding | fix. If nothing likely, return NO_FINDINGS."

exec bash /home/elton/.codex/skills/claude-cli-calling/scripts/run_claude_print.sh \
  --workdir "$REPO_ROOT" \
  --add-dir "$REPO_ROOT" \
  --add-dir "$PACKET_DIR" \
  --allowed-tools "Bash(cat:*) Bash(sed:*) Bash(rg:*) Bash(git:*)" \
  --output-format text \
  --permission-mode bypassPermissions \
  --prompt "$PROMPT"
