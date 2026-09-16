#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GUARD="$ROOT_DIR/tools/assumption_code_coherence_guard.py"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

OUTPUT_FILE="$TMP_DIR/assumption-code-guard.out"
JSON_OUT="$TMP_DIR/assumption-code-guard.json"

assert_no_go() {
  local todo_file="$1"
  if python3 "$GUARD" --todo "$todo_file" --json-output "$JSON_OUT" > "$OUTPUT_FILE" 2>&1; then
    cat "$OUTPUT_FILE"
    printf 'expected no-go for %s\n' "$todo_file" >&2
    exit 1
  fi
  grep -q "Overall outcome: no-go" "$OUTPUT_FILE"
}

assert_go() {
  local todo_file="$1"
  python3 "$GUARD" --todo "$todo_file" --json-output "$JSON_OUT" > "$OUTPUT_FILE" 2>&1
  grep -q "Overall outcome: go" "$OUTPUT_FILE"
}

mkdir -p \
  "$TMP_DIR/project/flutter-app/lib" \
  "$TMP_DIR/project/foundation_documentation/modules" \
  "$TMP_DIR/project/foundation_documentation/todos/active/core"
: > "$TMP_DIR/project/foundation_documentation/.git"
cat > "$TMP_DIR/project/flutter-app/lib/example.dart" <<'DART'
void main() {}
DART
cat > "$TMP_DIR/project/foundation_documentation/modules/example.md" <<'MD'
# Example Module
MD

PASS_TODO="$TMP_DIR/project/foundation_documentation/todos/active/core/pass.md"
cat > "$PASS_TODO" <<'TODO'
# TODO: Assumption Guard Pass

## Assumptions Preview
| Assumption ID | Assumption | Evidence | If False | Confidence (`High|Medium|Low`) | Handling (`Keep as Assumption|Promote to Decision|Block`) |
| --- | --- | --- | --- | --- | --- |
| `A-01` | Example live assumption | `flutter-app/lib/example.dart` | Replan | `High` | `Keep as Assumption` |

## Gate: Assumption Code Coherence
- **Gate decision:** `required`
- **Why this decision:** live assumption still exists
- **Trigger stage:** `after critique convergence and before APROVADO`
- **Guard scope:** `A-01`
- **Guard command:** `python3 delphi-ai/tools/assumption_code_coherence_guard.py --todo <todo-path>`
- **Gate status:** `no_material_findings`
- **Findings summary:** `none`
- **Evidence / reference:** `local guard clean`
- **Waiver authority / reference (required if waived):** `n/a`
TODO

assert_go "$PASS_TODO"
python3 - "$JSON_OUT" <<'PY'
import json
import sys
from pathlib import Path

payload = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
assert payload["overall_outcome"] == "go"
assert payload["live_assumption_ids"] == ["A-01"]
print("assumption_code_coherence_guard_pass_case: OK")
PY

FAIL_TODO="$TMP_DIR/project/foundation_documentation/todos/active/core/fail.md"
cat > "$FAIL_TODO" <<'TODO'
# TODO: Assumption Guard Fail

## Assumptions Preview
| Assumption ID | Assumption | Evidence | If False | Confidence (`High|Medium|Low`) | Handling (`Keep as Assumption|Promote to Decision|Block`) |
| --- | --- | --- | --- | --- | --- |
| `A-01` | Example live assumption | `foundation_documentation/modules/example.md` | Replan | `Medium` | `Keep as Assumption` |

## Gate: Assumption Code Coherence
- **Gate decision:** `required`
- **Why this decision:** live assumption still exists
- **Trigger stage:** `after critique convergence and before APROVADO`
- **Guard scope:** `A-01`
- **Guard command:** `python3 delphi-ai/tools/assumption_code_coherence_guard.py --todo <todo-path>`
- **Gate status:** `running`
- **Findings summary:** `pending`
- **Evidence / reference:** `n/a`
- **Waiver authority / reference (required if waived):** `n/a`
TODO

assert_no_go "$FAIL_TODO"
grep -q "ASSUMPTION-CODE-NO-CODE-ANCHOR" "$OUTPUT_FILE"
grep -q "ASSUMPTION-CODE-GATE-UNRESOLVED" "$OUTPUT_FILE"

printf 'assumption_code_coherence_guard_test: OK\n'
