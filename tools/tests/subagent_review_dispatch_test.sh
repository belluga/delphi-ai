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

for review_kind in architecture_opinion architecture_adherence test_quality_audit final_review cutover_integrity_audit; do
  python3 "$DISPATCH" --review-kind "$review_kind" --package "$TMP_DIR/package.md" --markdown-output "$TMP_DIR/$review_kind.md" >/dev/null
  grep -q "Do not silently invent, rewrite, or erase explicit TODO intent" "$TMP_DIR/$review_kind.md"
  if [[ "$review_kind" == architecture_opinion ]]; then
    [[ "$(grep -Fc "Planning review may challenge proposed horizon intent" "$TMP_DIR/$review_kind.md")" -eq 1 ]]
    ! grep -q "Treat approved implementation horizon and seam as binding" "$TMP_DIR/$review_kind.md"
  else
    [[ "$(grep -Fc "Treat approved implementation horizon and seam as binding" "$TMP_DIR/$review_kind.md")" -eq 1 ]]
    ! grep -q "Planning review may challenge proposed horizon intent" "$TMP_DIR/$review_kind.md"
  fi
done

if python3 "$DISPATCH" --review-kind critique --package "$TMP_DIR/package.md" >"$TMP_DIR/missing-lifecycle.txt" 2>&1; then
  exit 1
fi
grep -q "critique requires explicit --lifecycle planning|delivery" "$TMP_DIR/missing-lifecycle.txt"

if python3 "$DISPATCH" --review-kind architecture_opinion --lifecycle delivery --package "$TMP_DIR/package.md" >"$TMP_DIR/mismatched-lifecycle.txt" 2>&1; then
  exit 1
fi
grep -q "architecture_opinion has fixed lifecycle planning" "$TMP_DIR/mismatched-lifecycle.txt"

for lifecycle in planning delivery; do
  python3 "$DISPATCH" --review-kind critique --lifecycle "$lifecycle" --package "$TMP_DIR/package.md" --markdown-output "$TMP_DIR/critique-$lifecycle.md" >/dev/null
done
[[ "$(grep -Fc "Planning review may challenge proposed horizon intent" "$TMP_DIR/critique-planning.md")" -eq 1 ]]
! grep -q "Treat approved implementation horizon and seam as binding" "$TMP_DIR/critique-planning.md"
[[ "$(grep -Fc "Treat approved implementation horizon and seam as binding" "$TMP_DIR/critique-delivery.md")" -eq 1 ]]
! grep -q "Planning review may challenge proposed horizon intent" "$TMP_DIR/critique-delivery.md"

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
assert "Do not silently invent, rewrite, or erase explicit TODO intent" in markdown

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

sys.path.insert(0, str(root_dir / "skills" / "audit-protocol-triple-review" / "scripts"))
triple_session = importlib.import_module("triple_audit_session")
triple_dispatch_json = Path(sys.argv[4]) / "triple-dispatch.json"
triple_dispatch_markdown = Path(sys.argv[4]) / "triple-dispatch.md"
triple_session.run_dispatch(
    package_path=Path(sys.argv[4]) / "package.md",
    todo_path=None,
    lane={"review_kind": "critique", "lifecycle": "delivery", "goal": "Delivery audit."},
    dispatch_json_path=triple_dispatch_json,
    dispatch_markdown_path=triple_dispatch_markdown,
)
triple_markdown = triple_dispatch_markdown.read_text(encoding="utf-8")
assert triple_markdown.count("Treat approved implementation horizon and seam as binding") == 1
assert "Planning review may challenge proposed horizon intent" not in triple_markdown
PY

printf 'subagent_review_dispatch_test: OK\n'
