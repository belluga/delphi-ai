#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
NORMALIZER="$ROOT_DIR/tools/subagent_review_normalize.py"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

cat > "$TMP_DIR/input.json" <<'JSON'
{"schema_version":"subagent-review-result-v1","artifact_kind":"subagent_review_result","dispatch_path":"/tmp/dispatch.json","review_kind":"architecture_opinion","reviewer_label":"test","overall_assessment":"test","recommended_path":"test","performance_position":"acceptable","elegance_position":"acceptable","structural_soundness_position":"acceptable","operational_fit_position":"acceptable","findings":[{"severity":"medium","title":"test","rationale":"test","suggested_action":"test","category":"correctness"},{"severity":"medium","title":"test2","rationale":"test","suggested_action":"test","category":"scope_boundary"}]}
JSON

python3 "$NORMALIZER" --input "$TMP_DIR/input.json" --output "$TMP_DIR/output.json" > "$TMP_DIR/mapped.out"
grep -q "review alias map v1" "$TMP_DIR/mapped.out"
python3 -c 'import json,sys; data=json.load(open(sys.argv[1])); assert [item["category"] for item in data["findings"]] == ["architecture", "adherence"]' "$TMP_DIR/output.json"

cat > "$TMP_DIR/unknown-category.json" <<'JSON'
{"schema_version":"subagent-review-result-v1","artifact_kind":"subagent_review_result","dispatch_path":"/tmp/dispatch.json","review_kind":"architecture_opinion","reviewer_label":"test","overall_assessment":"test","recommended_path":"test","performance_position":"acceptable","elegance_position":"acceptable","structural_soundness_position":"acceptable","operational_fit_position":"acceptable","findings":[{"severity":"medium","title":"test","rationale":"test","suggested_action":"test","category":"invented_category"}]}
JSON

if python3 "$NORMALIZER" --input "$TMP_DIR/unknown-category.json" --output "$TMP_DIR/unknown-category-output.json" > "$TMP_DIR/unknown-category.out" 2>&1; then
  printf 'expected unknown category to remain rejected\n' >&2
  exit 1
fi
grep -q "failed schema validation" "$TMP_DIR/unknown-category.out"

cat > "$TMP_DIR/unexpected-field.json" <<'JSON'
{"schema_version":"subagent-review-result-v1","artifact_kind":"subagent_review_result","dispatch_path":"/tmp/dispatch.json","review_kind":"architecture_opinion","reviewer_label":"test","overall_assessment":"test","recommended_path":"test","performance_position":"acceptable","elegance_position":"acceptable","structural_soundness_position":"acceptable","operational_fit_position":"acceptable","adherence_position":"acceptable","findings":[]}
JSON

if python3 "$NORMALIZER" --input "$TMP_DIR/unexpected-field.json" --output "$TMP_DIR/unexpected-field-output.json" > "$TMP_DIR/unexpected-field.out" 2>&1; then
  printf 'expected unexpected top-level field to remain rejected\n' >&2
  exit 1
fi
grep -q "failed schema validation" "$TMP_DIR/unexpected-field.out"

cat > "$TMP_DIR/duplicate-category.json" <<'JSON'
{"schema_version":"subagent-review-result-v1","artifact_kind":"subagent_review_result","dispatch_path":"/tmp/dispatch.json","review_kind":"architecture_opinion","reviewer_label":"test","overall_assessment":"test","recommended_path":"test","performance_position":"acceptable","elegance_position":"acceptable","structural_soundness_position":"acceptable","operational_fit_position":"acceptable","findings":[{"severity":"medium","title":"test","rationale":"test","suggested_action":"test","category":"correctness","category":"architecture"}]}
JSON

if python3 "$NORMALIZER" --input "$TMP_DIR/duplicate-category.json" --output "$TMP_DIR/duplicate-category-output.json" > "$TMP_DIR/duplicate-category.out" 2>&1; then
  printf 'expected duplicate JSON key to remain rejected\n' >&2
  exit 1
fi
grep -q "duplicate JSON key" "$TMP_DIR/duplicate-category.out"

printf 'subagent_review_normalize_test: OK\n'
