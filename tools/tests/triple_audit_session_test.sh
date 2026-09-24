#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RUNNER="$ROOT_DIR/skills/audit-protocol-triple-review/scripts/triple_audit_session.py"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

PACKAGE_FILE="$TMP_DIR/package.md"
RUN_ROOT_BASE="$TMP_DIR/base-audit"
RUN_ROOT_CUTOVER="$TMP_DIR/cutover-audit"

cat > "$PACKAGE_FILE" <<'MD'
# Bounded Package

- Minimal package used to assert lane construction for the dedicated delivery-side multi-lane audit runner.
MD

python3 "$RUNNER" start --package "$PACKAGE_FILE" --run-root "$RUN_ROOT_BASE" >/dev/null
python3 "$RUNNER" start --package "$PACKAGE_FILE" --run-root "$RUN_ROOT_CUTOVER" --extra-lane cutover-integrity >/dev/null

python3 - "$RUN_ROOT_BASE/session.json" "$RUN_ROOT_BASE/progress.md" "$RUN_ROOT_CUTOVER/session.json" <<'PY'
import json
import sys
from pathlib import Path

base_session = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
progress = Path(sys.argv[2]).read_text(encoding="utf-8")
cutover_session = json.loads(Path(sys.argv[3]).read_text(encoding="utf-8"))

assert base_session["schema_version"] == "triple-audit-session-v2"
assert [lane["id"] for lane in base_session["rounds"][0]["lanes"]] == ["performance", "test-quality"]
assert "Dedicated Multi-Lane Audit Session Progress" in progress

assert [lane["id"] for lane in cutover_session["rounds"][0]["lanes"]] == [
    "performance",
    "test-quality",
    "cutover-integrity",
]

print("triple_audit_session_test: OK")
PY
