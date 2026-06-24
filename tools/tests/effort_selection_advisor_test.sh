#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOL="$ROOT_DIR/tools/effort_selection_advisor.py"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

EXECUTOR_JSON="$TMP_DIR/executor.json"
REVIEW_JSON="$TMP_DIR/review.json"
AMBIGUITY_JSON="$TMP_DIR/ambiguity.json"

python3 "$TOOL" \
  --surface executor-subagent \
  --goals-supported \
  --json-output "$EXECUTOR_JSON" >/dev/null

python3 "$TOOL" \
  --surface review-subagent \
  --json-output "$REVIEW_JSON" >/dev/null

python3 "$TOOL" \
  --surface exploratory-review \
  --material-strategic-ambiguity \
  --json-output "$AMBIGUITY_JSON" >/dev/null

python3 - "$EXECUTOR_JSON" "$REVIEW_JSON" "$AMBIGUITY_JSON" <<'PY'
import json
import sys
from pathlib import Path

executor = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
review = json.loads(Path(sys.argv[2]).read_text(encoding="utf-8"))
ambiguity = json.loads(Path(sys.argv[3]).read_text(encoding="utf-8"))

assert executor["recommended_effort"] == "medium"
assert executor["goal_policy"] == "required"
assert review["recommended_effort"] == "ExtraRight-or-closest-equivalent"
assert review["goal_policy"] == "stateless-default"
assert ambiguity["recommended_effort"] == "ExtraRight-or-closest-equivalent"
assert ambiguity["material_strategic_ambiguity"] is True
print("effort_selection_advisor_test: OK")
PY
