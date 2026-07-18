#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RUNNER="$ROOT_DIR/tools/subagent_review_run.py"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

cat > "$TMP_DIR/dispatch.md" <<'MD'
# Dispatch
Return one JSON object.
MD
cat > "$TMP_DIR/package.md" <<'MD'
# Package
Bounded review material.
MD
cat > "$TMP_DIR/fake-codex" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

output_file=""
while (($#)); do
  case "$1" in
    --output-last-message)
      output_file="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

input="$(cat)"
[[ "$input" == *"# Dispatch"* ]]
[[ "$input" == *"# Package"* ]]
if [[ "${FAKE_CODEX_SKIP_OUTPUT:-0}" != "1" ]]; then
  printf '%s' '{"review":"result"}' > "$output_file"
fi
printf '%s\n' '{"type":"item.completed","item":{"type":"agent_message","text":"{\"review\":\"result\"}"}}'
if [[ "${FAKE_CODEX_WITH_TURN_COMPLETED:-1}" == "1" ]]; then
  printf '%s\n' '{"type":"turn.completed"}'
fi
SH
chmod +x "$TMP_DIR/fake-codex"

python3 "$RUNNER" \
  --codex-bin "$TMP_DIR/fake-codex" \
  --dispatch "$TMP_DIR/dispatch.md" \
  --package "$TMP_DIR/package.md" \
  --raw-output "$TMP_DIR/result.raw.json" \
  --events-output "$TMP_DIR/events.jsonl" \
  --stderr-output "$TMP_DIR/stderr.log" \
  --workdir "$TMP_DIR"

grep -q '"review":"result"' "$TMP_DIR/result.raw.json"
grep -q '"type":"turn.completed"' "$TMP_DIR/events.jsonl"

FAKE_CODEX_SKIP_OUTPUT=1 python3 "$RUNNER" \
  --codex-bin "$TMP_DIR/fake-codex" \
  --dispatch "$TMP_DIR/dispatch.md" \
  --package "$TMP_DIR/package.md" \
  --raw-output "$TMP_DIR/fallback.raw.json" \
  --events-output "$TMP_DIR/fallback.events.jsonl" \
  --stderr-output "$TMP_DIR/fallback.stderr.log" \
  --workdir "$TMP_DIR"
grep -q '"review":"result"' "$TMP_DIR/fallback.raw.json"

if FAKE_CODEX_WITH_TURN_COMPLETED=0 python3 "$RUNNER" \
  --codex-bin "$TMP_DIR/fake-codex" \
  --dispatch "$TMP_DIR/dispatch.md" \
  --package "$TMP_DIR/package.md" \
  --raw-output "$TMP_DIR/missing-turn.raw.json" \
  --events-output "$TMP_DIR/missing-turn.events.jsonl" \
  --stderr-output "$TMP_DIR/missing-turn.stderr.log" \
  --workdir "$TMP_DIR" > "$TMP_DIR/missing-turn.out" 2>&1; then
  printf 'expected missing turn.completed to be rejected\n' >&2
  exit 1
fi
grep -q 'turn.completed' "$TMP_DIR/missing-turn.out"

printf 'subagent_review_run_test: OK\n'
