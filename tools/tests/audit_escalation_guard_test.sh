#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOL="$ROOT_DIR/tools/audit_escalation_guard.py"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

TODO_FILE="$TMP_DIR/audit-todo.md"
JSON_OUT="$TMP_DIR/audit-floor.json"

cat > "$TODO_FILE" <<'TODO'
# TODO: Audit Escalation Guard Heading Compatibility

## Complexity
- **Level (`small|medium|big`):** `medium`

## Plan Review Gate
- **Issue ID:** `ARCH-01`
  - **Severity:** `high`

## Audit Trigger Matrix (Required Before Audit Decisions Are Trusted)
| Trigger | Value | Notes |
| --- | --- | --- |
| `complexity` | `medium` | Matches the Complexity section. |
| `blast_radius` | `cross-stack` | Cross-stack bugfix. |
| `behavioral_change_or_bugfix` | `yes` | Regression/hardening slice. |
| `changes_public_contract` | `yes` | Public contract changes. |
| `touches_auth_or_tenant` | `yes` | Tenant scope touched. |
| `touches_runtime_or_infra` | `no` | No infra scope. |
| `touches_tests` | `yes` | Tests touched. |
| `critical_user_journey` | `yes` | Critical journey. |
| `release_or_promotion_critical` | `yes` | Release-sensitive. |
| `high_severity_plan_review_issue` | `yes` | Matches the high-severity issue. |
| `explicit_three_lane_request` | `no` | No explicit three-lane request. |
TODO

python3 "$TOOL" --todo "$TODO_FILE" --json-output "$JSON_OUT" >/dev/null

python3 - "$JSON_OUT" <<'PY'
import json
import sys
from pathlib import Path

payload = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
assert payload["artifact_kind"] == "audit_escalation_decision"
assert payload["outcome"] == "go"
assert payload["trigger_matrix"]["complexity"] == "medium"
assert payload["decisions"]["critique"]["decision"] == "required"
assert payload["decisions"]["triple_review"]["decision"] == "required"
print("audit_escalation_guard_test: OK")
PY
