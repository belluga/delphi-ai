#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOL="$ROOT_DIR/tools/review_finding_routing_scaffold.py"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

INPUT_JSON="$TMP_DIR/findings.json"
OUTPUT_MD="$TMP_DIR/ledger.md"

cat > "$INPUT_JSON" <<'JSON'
{
  "findings": [
    {
      "finding_id": "COPILOT-01",
      "severity": "P1",
      "classification": "release-blocker",
      "routing_decision": "same-todo-remediation",
      "rationale": "Current package is still broken.",
      "status": "open",
      "reference": "same TODO pending"
    },
    {
      "finding_id": "COPILOT-02",
      "severity": "P3",
      "classification": "follow-up-hardening",
      "routing_decision": "split-hardening",
      "rationale": "Real issue, but not a current release blocker.",
      "status": "routed",
      "reference": "foundation_documentation/todos/active/post_release_hardening/hardening/TODO-example.md"
    },
    {
      "finding_id": "COPILOT-03",
      "severity": "P2"
    }
  ]
}
JSON

python3 "$TOOL" --input "$INPUT_JSON" --section --output "$OUTPUT_MD"

grep -q '^## Promotion Finding Routing Ledger$' "$OUTPUT_MD"
grep -q '| `COPILOT-01` | `P1` | `release-blocker` | `same-todo-remediation` | Current package is still broken. | `open` | same TODO pending |' "$OUTPUT_MD"
grep -q '| `COPILOT-02` | `P3` | `follow-up-hardening` | `split-hardening` | Real issue, but not a current release blocker. | `routed` | foundation_documentation/todos/active/post_release_hardening/hardening/TODO-example.md |' "$OUTPUT_MD"
grep -q '<release-blocker|follow-up-fast-follow|follow-up-hardening|by-design/no-action>' "$OUTPUT_MD"
grep -q '<open|fixed|routed|accepted|blocked>' "$OUTPUT_MD"

cat > "$TMP_DIR/invalid.json" <<'JSON'
[
  {
    "finding_id": "BAD-01",
    "severity": "P1",
    "classification": "not-a-valid-classification"
  }
]
JSON

if python3 "$TOOL" --input "$TMP_DIR/invalid.json" >"$TMP_DIR/invalid.out" 2>&1; then
  cat "$TMP_DIR/invalid.out"
  printf 'expected invalid classification to fail\n' >&2
  exit 1
fi

grep -q 'invalid classification' "$TMP_DIR/invalid.out"

printf 'review_finding_routing_scaffold_test: OK\n'
