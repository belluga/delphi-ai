#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOL="$ROOT_DIR/tools/finding_carry_forward_extract.py"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

TODO_FILE="$TMP_DIR/carry-forward-todo.md"
JSON_OUT="$TMP_DIR/carry-forward.json"

cat > "$TODO_FILE" <<'TODO'
# TODO: Carry Forward

## Independent No-Context Critique Gate
- **Critique status:** `findings_integrated`
- **Findings summary:** recorded
- **Resolution ledger:** use the machine-checkable table below when findings exist
| Finding ID | Resolution (`Integrated|Challenged|Deferred`) | Usefulness (`useful|noise|mixed|unknown`) | Formalizable (`yes|partial|no|unknown`) | Candidate Rule Level (`paced|project|none|unknown`) | Candidate Rule ID | Rationale / Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| `CRT-1` | `Challenged` | `noise` | `no` | `paced` | `n/a` | Approved by design in the governing TODO. |

## Independent Cutover Integrity Audit Gate
- **Cutover audit status:** `findings_integrated`
- **Findings summary:** recorded
- **Resolution ledger:** use the machine-checkable table below when findings exist
| Finding ID | Resolution (`Integrated|Challenged|Deferred`) | Usefulness (`useful|noise|mixed|unknown`) | Formalizable (`yes|partial|no|unknown`) | Candidate Rule Level (`paced|project|none|unknown`) | Candidate Rule ID | Rationale / Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| `CUT-1` | `Deferred` | `mixed` | `partial` | `project` | `n/a` | Approved temporary compatibility bridge with explicit removal criteria. |

## Promotion Finding Routing Ledger
| Finding ID | Severity | Classification | Routing Decision | Same TODO / Split Rationale | Status | Approval / Follow-up Reference |
| --- | --- | --- | --- | --- | --- | --- |
| `PR-1` | `P1` | `by-design intent` | `same-todo-evidence-refresh` | Expected behavior; do not patch blindly. | `accepted` | `approval-123` |
| `PR-2` | `P2` | `confirmed defect` | `same-todo-remediation` | Still open. | `open` | `same TODO pending` |
| `PR-3` | `P3` | `follow-up-hardening` | `split-hardening` | Real issue, but not a current release blocker. | `deferred` | `foundation_documentation/todos/active/post_release_hardening/hardening/TODO-example.md` |
TODO

python3 "$TOOL" --todo "$TODO_FILE" --json-output "$JSON_OUT" >/dev/null

python3 - "$JSON_OUT" <<'PY'
import json
import sys
from pathlib import Path

payload = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
assert payload["artifact_kind"] == "finding_carry_forward"
assert len(payload["policy_lines"]) == 4
entries = {(entry["source_kind"], entry["finding_id"]): entry for entry in payload["entries"]}
assert entries[("critique", "CRT-1")]["carry_forward_class"] == "challenged"
assert entries[("cutover_integrity_audit", "CUT-1")]["carry_forward_class"] == "deferred"
assert entries[("promotion_routing", "PR-1")]["carry_forward_class"] == "challenged"
assert entries[("promotion_routing", "PR-2")]["carry_forward_class"] == "unresolved"
assert entries[("promotion_routing", "PR-3")]["carry_forward_class"] == "deferred"
print("finding_carry_forward_extract_test: OK")
PY
