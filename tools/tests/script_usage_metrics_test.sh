#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RECORD_TOOL="$ROOT_DIR/tools/script_usage_record.py"
SUMMARY_TOOL="$ROOT_DIR/tools/script_usage_summary.py"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

REPO_DIR="$TMP_DIR/repo"
mkdir -p "$REPO_DIR/foundation_documentation/artifacts/metrics/events"
mkdir -p "$REPO_DIR/delphi-ai"

python3 "$RECORD_TOOL" \
  --repo-root "$REPO_DIR" \
  --script-id "root.verify_environment" \
  --script-path "scripts/verify_environment.sh" \
  --surface "root-script" \
  --scenario "default" \
  --exit-code 0 \
  --duration-ms 120 \
  --cwd "$REPO_DIR" \
  --metadata scope=default

python3 "$RECORD_TOOL" \
  --repo-root "$REPO_DIR" \
  --script-id "root.verify_environment" \
  --script-path "scripts/verify_environment.sh" \
  --surface "root-script" \
  --scenario "default" \
  --exit-code 1 \
  --duration-ms 80 \
  --cwd "$REPO_DIR" \
  --metadata scope=default

python3 "$RECORD_TOOL" \
  --repo-root "$REPO_DIR" \
  --script-id "delphi.verify_context" \
  --script-path "delphi-ai/tools/verify_context.sh" \
  --surface "delphi-tool" \
  --scenario "repair" \
  --exit-code 64 \
  --duration-ms 40 \
  --cwd "$REPO_DIR" \
  --metadata mode=repair

EVENTS_FILE="$REPO_DIR/foundation_documentation/artifacts/metrics/events/script-usage.jsonl"
SUMMARY_JSON="$REPO_DIR/foundation_documentation/artifacts/metrics/script-usage-summary.json"
SUMMARY_MD="$REPO_DIR/foundation_documentation/artifacts/metrics/script-usage-summary.md"

[[ "$(wc -l < "$EVENTS_FILE" | tr -d ' ')" == "3" ]]
grep -q '"script_id": "root.verify_environment"' "$EVENTS_FILE"
grep -q '"status": "usage_error"' "$EVENTS_FILE"

python3 "$SUMMARY_TOOL" \
  --repo "$REPO_DIR" \
  --summary-json "$SUMMARY_JSON" \
  --summary-markdown "$SUMMARY_MD"

grep -q '"event_count": 3' "$SUMMARY_JSON"
grep -q '"script_count": 2' "$SUMMARY_JSON"
grep -q '"usage_error": 1' "$SUMMARY_JSON"
grep -q '`root.verify_environment`' "$SUMMARY_MD"
grep -q 'repair:1' "$SUMMARY_MD"

NOOP_REPO="$TMP_DIR/noop"
mkdir -p "$NOOP_REPO"
python3 "$RECORD_TOOL" \
  --repo-root "$NOOP_REPO" \
  --script-id "noop" \
  --script-path "noop.sh" \
  --surface "root-script" \
  --scenario "default" \
  --exit-code 0 \
  --duration-ms 1 \
  --cwd "$NOOP_REPO" \
  --quiet

if [[ -e "$NOOP_REPO/foundation_documentation/artifacts/metrics/events/script-usage.jsonl" ]]; then
  echo "expected noop repo not to create metrics artifacts" >&2
  exit 1
fi

echo "script_usage_metrics_test: PASS"
