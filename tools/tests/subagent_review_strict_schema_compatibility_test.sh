#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RESULT_SCHEMA="$ROOT_DIR/schemas/subagent_review_result.schema.json"
RUNNER="$ROOT_DIR/tools/subagent_review_run.py"

python3 - "$RESULT_SCHEMA" "$RUNNER" <<'PY'
import json
import sys
from pathlib import Path

schema = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
finding = schema["$defs"]["finding"]
optional = set(finding["properties"]) - set(finding["required"])

# Codex strict response formats require every declared object property to be
# required. The canonical schema deliberately keeps finding metadata optional.
assert optional == {
    "finding_id",
    "category",
    "formalizable_hint",
    "candidate_rule_level",
    "candidate_rule_id",
    "affected_paths",
}

runner_source = Path(sys.argv[2]).read_text(encoding="utf-8")
assert '"--output-schema"' not in runner_source
assert '"--json"' in runner_source
PY

printf 'subagent_review_strict_schema_compatibility_test: OK\n'
