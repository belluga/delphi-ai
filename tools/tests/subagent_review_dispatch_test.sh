#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DISPATCH="$ROOT_DIR/tools/subagent_review_dispatch.py"
RESULT_SCHEMA="$ROOT_DIR/schemas/subagent_review_result.schema.json"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

printf 'bounded package\n' > "$TMP_DIR/package.md"
python3 "$DISPATCH" \
  --review-kind architecture_opinion \
  --package "$TMP_DIR/package.md" \
  --json-output "$TMP_DIR/dispatch.json" \
  --markdown-output "$TMP_DIR/dispatch.md"

python3 - "$ROOT_DIR" "$RESULT_SCHEMA" "$TMP_DIR/dispatch.md" "$TMP_DIR" <<'PY'
import copy
import importlib
import json
import sys
from pathlib import Path

root_dir = Path(sys.argv[1])
schema = json.loads(Path(sys.argv[2]).read_text(encoding="utf-8"))
markdown = Path(sys.argv[3]).read_text(encoding="utf-8")

for field in schema["required"]:
    assert f"`{field}`" in markdown, field

for value in schema["$defs"]["position"]["enum"]:
    assert f"`{value}`" in markdown, value

finding = schema["$defs"]["finding"]
for property_schema in finding["properties"].values():
    for value in property_schema.get("enum", []):
        assert f"`{value}`" in markdown, value

for field in finding["properties"]:
    assert f"`{field}`" in markdown, field

assert "No top-level fields other than the following are allowed:" in markdown
assert "Return exactly one JSON object and no Markdown fence or prose." in markdown

sys.path.insert(0, str(root_dir / "tools"))
dispatcher = importlib.import_module("subagent_review_dispatch")
synthetic_schema = copy.deepcopy(schema)
synthetic_schema["properties"]["synthetic_required"] = {"type": "string"}
synthetic_schema["required"].append("synthetic_required")
synthetic_path = Path(sys.argv[4]) / "synthetic-result-schema.json"
synthetic_path.write_text(json.dumps(synthetic_schema), encoding="utf-8")
dispatcher.RESULT_SCHEMA_PATH = synthetic_path
synthetic_contract = "\n".join(dispatcher.result_contract_lines({"review_kind": "architecture_opinion"}))
assert "`synthetic_required`" in synthetic_contract
PY

printf 'subagent_review_dispatch_test: OK\n'
