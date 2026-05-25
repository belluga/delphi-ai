#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GUARD="$ROOT_DIR/tools/todo_authority_guard.py"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

OUTPUT_FILE="$TMP_DIR/todo-authority-guard.out"

assert_no_go() {
  local todo_file="$1"
  shift || true
  if python3 "$GUARD" "$todo_file" "$@" > "$OUTPUT_FILE" 2>&1; then
    cat "$OUTPUT_FILE"
    printf 'expected no-go for %s\n' "$todo_file" >&2
    exit 1
  fi
  grep -q "Overall outcome: no-go" "$OUTPUT_FILE"
}

assert_go() {
  local todo_file="$1"
  shift || true
  python3 "$GUARD" "$todo_file" "$@" > "$OUTPUT_FILE" 2>&1
  grep -q "Overall outcome: go" "$OUTPUT_FILE"
}

cat > "$TMP_DIR/missing-approval.md" <<'TODO'
# TODO: Missing Approval

## Delivery Status Canon
- **Current delivery stage:** `Pending`

## Rules Acknowledgement / Ingestion
| Source | Why It Applies Now | Must Preserve | Must Avoid | Execution Impact |
| --- | --- | --- | --- | --- |
| `rules/core/todo-driven-execution-model-decision.md` | TODO execution. | Approval gate. | Silent changes. | Check before execution. |
TODO

assert_no_go "$TMP_DIR/missing-approval.md"
grep -q "APPROVAL-SECTION-MISSING" "$OUTPUT_FILE"

cat > "$TMP_DIR/missing-rules.md" <<'TODO'
# TODO: Missing Rules

## Delivery Status Canon
- **Current delivery stage:** `Pending`

## Approval
- **Approved by:** user approved with "APROVADO" on 2026-05-25.
- **Approval scope:** implement the bounded guard.
TODO

assert_no_go "$TMP_DIR/missing-rules.md"
grep -q "RULE-INGESTION-MISSING" "$OUTPUT_FILE"

cat > "$TMP_DIR/approved-no-delivery-claim.md" <<'TODO'
# TODO: Approved No Delivery Claim

## Delivery Status Canon
- **Current delivery stage:** `Pending`

## Approval
- **Approved by:** user approved with "APROVADO" on 2026-05-25.
- **Approval scope:** implement the bounded guard.

## Rules Acknowledgement / Ingestion
| Source | Why It Applies Now | Must Preserve | Must Avoid | Execution Impact |
| --- | --- | --- | --- | --- |
| `rules/core/todo-driven-execution-model-decision.md` | TODO execution. | Approval gate. | Silent changes. | Check before execution. |
TODO

assert_go "$TMP_DIR/approved-no-delivery-claim.md"

cat > "$TMP_DIR/local-implemented-missing-gates.md" <<'TODO'
# TODO: Local Implemented Missing Gates

## Delivery Status Canon
- **Current delivery stage:** `Local-Implemented`

## Approval
- **Approved by:** user approved with "APROVADO" on 2026-05-25.
- **Approval scope:** implement the bounded guard.

## Rules Acknowledgement / Ingestion
| Source | Why It Applies Now | Must Preserve | Must Avoid | Execution Impact |
| --- | --- | --- | --- | --- |
| `rules/core/todo-driven-execution-model-decision.md` | TODO execution. | Approval gate. | Silent changes. | Check before execution. |
TODO

assert_no_go "$TMP_DIR/local-implemented-missing-gates.md"
grep -q "DELIVERY-GATE-MISSING" "$OUTPUT_FILE"

cat > "$TMP_DIR/local-implemented-complete.md" <<'TODO'
# TODO: Local Implemented Complete

## Delivery Status Canon
- **Current delivery stage:** `Local-Implemented`

## Approval
- **Approved by:** user approved with "APROVADO" on 2026-05-25.
- **Approval scope:** implement the bounded guard.

## Rules Acknowledgement / Ingestion
| Source | Why It Applies Now | Must Preserve | Must Avoid | Execution Impact |
| --- | --- | --- | --- | --- |
| `rules/core/todo-driven-execution-model-decision.md` | TODO execution. | Approval gate. | Silent changes. | Check before execution. |

## Local CI-Equivalent Suite Matrix
| Repository / CI Surface | Why In Scope | Local CI-Equivalent Command | Required Before | Status | Evidence Artifact / Command | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| delphi-ai / authority guard | Guard changed. | `bash tools/tests/todo_authority_guard_test.sh` | Local-Implemented | passed | `bash tools/tests/todo_authority_guard_test.sh` | passed |

## Pipeline/Copilot P1/P2 Preflight
| Reviewer Surface / Package | Review Focus | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| bounded diff | P1/P2 issues | passed | `bash tools/tests/todo_authority_guard_test.sh` | no P1 or P2 findings | complete |

## Rule-Spirit Anti-Pattern Hunt
| Rule / Principle Surface | Bypass or Anti-Pattern Search Lens | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| TODO process | process bypass | passed | `bash tools/tests/todo_authority_guard_test.sh` | no P1 or P2 findings | complete |

## Promotion Finding Routing Ledger
| Finding ID | Severity | Classification | Routing Decision | Same TODO / Split Rationale | Status | Approval / Follow-up Reference |
| --- | --- | --- | --- | --- | --- | --- |
| `PR-1` | `P1` | `confirmed defect` | `same-todo-remediation` | Preserves same approved promotion objective and scenario. | `fixed` | `same TODO evidence refreshed` |
TODO

assert_go "$TMP_DIR/local-implemented-complete.md"

cat > "$TMP_DIR/promotion-p1-open.md" <<'TODO'
# TODO: Promotion P1 Open

## Delivery Status Canon
- **Current delivery stage:** `Local-Implemented`

## Approval
- **Approved by:** user approved with "APROVADO" on 2026-05-25.
- **Approval scope:** implement the bounded guard.

## Rules Acknowledgement / Ingestion
| Source | Why It Applies Now | Must Preserve | Must Avoid | Execution Impact |
| --- | --- | --- | --- | --- |
| `skills/github-stage-promotion-orchestrator/SKILL.md` | Promotion flow. | P1 blocks completion. | P1 bypass. | Check routing. |

## Local CI-Equivalent Suite Matrix
| Repository / CI Surface | Why In Scope | Local CI-Equivalent Command | Required Before | Status | Evidence Artifact / Command | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| delphi-ai / authority guard | Guard changed. | `bash tools/tests/todo_authority_guard_test.sh` | Local-Implemented | passed | `bash tools/tests/todo_authority_guard_test.sh` | passed |

## Pipeline/Copilot P1/P2 Preflight
| Reviewer Surface / Package | Review Focus | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| bounded diff | P1/P2 issues | passed | `bash tools/tests/todo_authority_guard_test.sh` | no P1 or P2 findings | complete |

## Rule-Spirit Anti-Pattern Hunt
| Rule / Principle Surface | Bypass or Anti-Pattern Search Lens | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| TODO process | process bypass | passed | `bash tools/tests/todo_authority_guard_test.sh` | no P1 or P2 findings | complete |

## Promotion Finding Routing Ledger
| Finding ID | Severity | Classification | Routing Decision | Same TODO / Split Rationale | Status | Approval / Follow-up Reference |
| --- | --- | --- | --- | --- | --- | --- |
| `PR-1` | `P1` | `confirmed defect` | `same-todo-remediation` | Preserves same approved promotion objective and scenario. | `open` | `same TODO evidence pending` |
TODO

assert_no_go "$TMP_DIR/promotion-p1-open.md"
grep -q "PROMOTION-P1-P2-UNRESOLVED" "$OUTPUT_FILE"

cat > "$TMP_DIR/promotion-scope-change-no-ref.md" <<'TODO'
# TODO: Promotion Scope Change No Reference

## Delivery Status Canon
- **Current delivery stage:** `Pending`

## Approval
- **Approved by:** user approved with "APROVADO" on 2026-05-25.
- **Approval scope:** implement the bounded guard.

## Rules Acknowledgement / Ingestion
| Source | Why It Applies Now | Must Preserve | Must Avoid | Execution Impact |
| --- | --- | --- | --- | --- |
| `skills/github-stage-promotion-orchestrator/SKILL.md` | Promotion flow. | P1 blocks completion. | P1 bypass. | Check routing. |

## Promotion Finding Routing Ledger
| Finding ID | Severity | Classification | Routing Decision | Same TODO / Split Rationale | Status | Approval / Follow-up Reference |
| --- | --- | --- | --- | --- | --- | --- |
| `PR-2` | `P2` | `confirmed defect` | `renewed-approval-required` | Changes approved behavior. | `fixed` | `n/a` |
TODO

assert_no_go "$TMP_DIR/promotion-scope-change-no-ref.md"
grep -q "PROMOTION-SCOPE-CHANGE-MISSING-REFERENCE" "$OUTPUT_FILE"

printf 'todo_authority_guard_test: OK\n'
