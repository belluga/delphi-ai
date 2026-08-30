#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GUARD="$ROOT_DIR/tools/todo_authority_guard.py"
CONTRACT="$ROOT_DIR/config/agent_role_routing.json"
ROUTINE_EXECUTOR_MODEL="$(
  python3 - "$CONTRACT" <<'PY'
import json
import sys
from pathlib import Path

contract = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
print(contract["clients"]["codex"]["preferred_models"]["routine_executor"][0])
PY
)"

TMP_DIR="$(mktemp -d)"
cleanup() {
  local status=$?
  rm -rf "$TMP_DIR"
  exit "$status"
}
trap cleanup EXIT

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
  if ! python3 "$GUARD" "$todo_file" "$@" > "$OUTPUT_FILE" 2>&1; then
    cat "$OUTPUT_FILE"
    return 1
  fi
  grep -q "Overall outcome: go" "$OUTPUT_FILE"
}

python3 - "$ROOT_DIR/tools" <<'PY'
import sys

sys.path.insert(0, sys.argv[1])
import todo_authority_guard as authority
import todo_completion_guard as completion

cases = (
    ("No P1; unresolved P2 remains", True),
    ("No P1/P2; P2 still open", True),
    ("No unresolved P1/P2 in A; P1 is pending in B", True),
    ("No unresolved P1/P2 in A; P2 needs remediation in B", True),
    ("No unresolved P1/P2 findings", False),
    ("no P1 or P2 findings", False),
    ("P1 finding", True),
    ("P1 fixed", False),
    ("P1 fixed; P2 pending", True),
    ("No P2 findings", False),
    ("P1 fixed; P2 finding", True),
    ("P1 finding; unrelated documentation fixed", True),
    ("P1 fixed; P2 needs review", True),
    ("P1 fixed; P2 resolved", False),
    ("No P1 and no P2 findings", False),
    ("No P1/P2 findings", False),
    ("No P1 or P2 anti-pattern findings", False),
    ("P1 is fixed; P2 has been resolved", False),
    ("P1 and P2 fixed", False),
    ("P1/P2 resolved", False),
    ("P1 fixed; reopened", True),
    ("P1 fixed; still open", True),
    ("P1 fixed; actually not", True),
    ("Not no P1/P2 findings", True),
)
for text, expected in cases:
    assert authority.row_has_unresolved_p1_p2(["package", "focus", "passed", "evidence", text, "resolution"]) is expected, text
    assert completion.row_has_unresolved_p1_p2(["surface", "focus", "passed", "evidence", text, "complete"]) is expected, text

cell_separated_cases = (
    ("P1 fixed", "P2 finding", True),
    ("P1 finding", "unrelated documentation fixed", True),
    ("P1 finding", "P1 fixed", False),
    ("P1 and P2 findings", "P1/P2 resolved", False),
    ("P1 fixed", "not fixed", True),
    ("P1 fixed", "P2 resolved", False),
    ("No P2 findings", "P1 resolved", False),
)
for findings, resolution, expected in cell_separated_cases:
    authority_row = ["package", "focus", "passed", "evidence", findings, resolution]
    completion_row = ["surface", "focus", "passed", "evidence", findings, resolution]
    assert authority.row_has_unresolved_p1_p2(authority_row) is expected, (findings, resolution)
    assert completion.row_has_unresolved_p1_p2(completion_row) is expected, (findings, resolution)

full_gate_sections = {authority.PIPELINE_PREFLIGHT_SECTION: [
    "| Reviewer Surface / Package | Review Focus | Status | Evidence Artifact / Command | Findings | Resolution / Notes |",
    "| --- | --- | --- | --- | --- | --- |",
    "| package | focus | passed | evidence | P1 fixed; P2 finding | complete |",
]}
violations, _ = authority.validate_delivery_gates(full_gate_sections, delivery_claim=True, allow_waivers=False)
assert any(item["code"] == "DELIVERY-GATE-UNRESOLVED-P1-P2" for item in violations)

resolved_gate_sections = {authority.PIPELINE_PREFLIGHT_SECTION: [
    "| Reviewer Surface / Package | Review Focus | Status | Evidence Artifact / Command | Findings | Resolution / Notes |",
    "| --- | --- | --- | --- | --- | --- |",
    "| package | focus | passed | evidence | P1 and P2 findings | P1/P2 resolved |",
]}
violations, _ = authority.validate_delivery_gates(resolved_gate_sections, delivery_claim=True, allow_waivers=False)
assert not any(item["code"] == "DELIVERY-GATE-UNRESOLVED-P1-P2" for item in violations)

extra_cell_sections = {authority.PIPELINE_PREFLIGHT_SECTION: [
    "| Reviewer Surface / Package | Review Focus | Status | Evidence Artifact / Command | Findings | Resolution / Notes |",
    "| --- | --- | --- | --- | --- | --- |",
    "| package | focus | passed | evidence | No P1/P2 findings | complete | P2 pending |",
]}
violations, _ = authority.validate_delivery_gates(extra_cell_sections, delivery_claim=True, allow_waivers=False)
assert any(item["code"] == "DELIVERY-GATE-ROW-INCOMPLETE" for item in violations)
completion_violations = completion.validate_review_gate_matrix(
    extra_cell_sections,
    authority.PIPELINE_PREFLIGHT_SECTION,
    "PIPELINE-PREFLIGHT",
    "Use the canonical review row.",
    allow_waivers=False,
)
assert any(item["code"] == "PIPELINE-PREFLIGHT-ROW-INCOMPLETE" for item in completion_violations)

sections = {"Architecture Review Gates": [
    "- **Architecture decision review:** `required`",
    "- **Decision review status:** `no_material_findings`",
    "- **Architecture adherence review:** `required`",
    "- **Adherence review status:** `findings_integrated`",
]}
assert not authority.validate_architecture_review_gates(
    sections, architecture_required=True, delivery_claim=True, allow_waivers=False
)[0]

for invalid_status in ("passed", "n/a"):
    invalid = {"Architecture Review Gates": [
        "- **Architecture decision review:** `required`",
        f"- **Decision review status:** `{invalid_status}`",
        "- **Architecture adherence review:** `required`",
        f"- **Adherence review status:** `{invalid_status}`",
    ]}
    violations, _ = authority.validate_architecture_review_gates(
        invalid, architecture_required=True, delivery_claim=True, allow_waivers=False
    )
    assert any(item["code"] == "ARCHITECTURE-REVIEW-STATUS-NOT-PASSING" for item in violations), invalid_status

approved_waiver = {"Architecture Review Gates": [
    "- **Architecture decision review:** `required`",
    "- **Decision review status:** `waived`",
    "- **Architecture adherence review:** `required`",
    "- **Adherence review status:** `waived`",
    "- **Decision review waiver approver:** user-owner-01",
    "- **Decision review waiver approval reference:** APROVADO 2026-08-30",
    "- **Adherence review waiver approver:** user-owner-02",
    "- **Adherence review waiver approval reference:** approved https://example.test/reviews/42",
]}
assert not authority.validate_architecture_review_gates(
    approved_waiver, architecture_required=True, delivery_claim=True, allow_waivers=False
)[0]
unapproved_waiver = {"Architecture Review Gates": approved_waiver["Architecture Review Gates"][:4] + [
    "- **No-go handling:** approval-breaking divergence returns to review.",
]}
violations, _ = authority.validate_architecture_review_gates(
    unapproved_waiver, architecture_required=True, delivery_claim=True, allow_waivers=True
)
assert any(item["code"] == "ARCHITECTURE-REVIEW-WAIVER-UNAPPROVED" for item in violations)

for field, invalid_value in (
    ("Decision review waiver approver", "human"),
    ("Decision review waiver approver", "human user"),
    ("Decision review waiver approver", "the user"),
    ("Decision review waiver approver", "human reviewer"),
    ("Decision review waiver approver", "user 01"),
    ("Decision review waiver approver", "reviewer"),
    ("Decision review waiver approver", "owner"),
    ("Decision review waiver approver", "developer"),
    ("Decision review waiver approver", "actual approver"),
    ("Decision review waiver approver", "anonymous"),
    ("Decision review waiver approver", "Decision review waiver approver"),
    ("Decision review waiver approval reference", "none"),
    ("Adherence review waiver approver", "n/a"),
    ("Adherence review waiver approver", "TBD"),
    ("Adherence review waiver approver", "Adherence review waiver approver"),
    ("Adherence review waiver approval reference", "required"),
    ("Adherence review waiver approval reference", "pending approval 2026-08-30"),
    ("Adherence review waiver approval reference", "approved 2026-99-99"),
    ("Adherence review waiver approval reference", "approved issue #0"),
    ("Adherence review waiver approval reference", "not approved 2026-08-30"),
    ("Adherence review waiver approval reference", "unapproved 2026-08-30"),
    ("Adherence review waiver approval reference", "disapproved 2026-08-30"),
    ("Adherence review waiver approval reference", "approval denied 2026-08-30"),
    ("Adherence review waiver approval reference", "rejected approval ref #42"),
    ("Adherence review waiver approval reference", "approval revoked 2026-08-30"),
    ("Adherence review waiver approval reference", "approval not granted 2026-08-30"),
    ("Adherence review waiver approval reference", "não aprovado 2026-08-30"),
    ("Adherence review waiver approval reference", "not an approval 2026-08-30"),
    ("Adherence review waiver approval reference", "approval refused 2026-08-30"),
    ("Adherence review waiver approval reference", "<placeholder>"),
):
    invalid_lines = [
        line if not line.startswith(f"- **{field}:**") else f"- **{field}:** {invalid_value}"
        for line in approved_waiver["Architecture Review Gates"]
    ] + ["- **No-go handling:** approval-breaking divergence returns to review."]
    for allow_waivers in (False, True):
        violations, _ = authority.validate_architecture_review_gates(
            {"Architecture Review Gates": invalid_lines},
            architecture_required=True,
            delivery_claim=True,
            allow_waivers=allow_waivers,
        )
        assert any(item["code"] == "ARCHITECTURE-REVIEW-WAIVER-UNAPPROVED" for item in violations), (field, allow_waivers)
PY

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

cat > "$TMP_DIR/missing-routing-preflight.md" <<'TODO'
# TODO: Missing Routing Preflight

## Delivery Status Canon
- **Current delivery stage:** `Pending`

## Approval
- **Approved by:** user approved with "APROVADO" on 2026-05-25.
- **Approval scope:** implement the bounded guard.

## Rules Acknowledgement / Ingestion
| Source | Why It Applies Now | Must Preserve | Must Avoid | Execution Impact |
| --- | --- | --- | --- | --- |
| `workflows/docker/effort-selection-method.md` | Governed routing is in scope. | executor/reviewer split | silent fallback | require explicit routing |
TODO

assert_no_go "$TMP_DIR/missing-routing-preflight.md"
grep -q "ROUTING-PREFLIGHT-MISSING" "$OUTPUT_FILE"

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

cat > "$TMP_DIR/approved-with-routing-preflight.md" <<'TODO'
# TODO: Approved With Routing Preflight

## Delivery Status Canon
- **Current delivery stage:** `Pending`

## Approval
- **Approved by:** user approved with "APROVADO" on 2026-05-25.
- **Approval scope:** implement the bounded guard.

## Rules Acknowledgement / Ingestion
| Source | Why It Applies Now | Must Preserve | Must Avoid | Execution Impact |
| --- | --- | --- | --- | --- |
| `workflows/docker/effort-selection-method.md` | Governed routing is in scope. | executor/reviewer split | silent fallback | require explicit routing |

## Agent Routing Preflight
- **Client surface:** `codex`
- **Current governed action:** `implementation`
- **Selected role:** `routine-executor`
- **Selected model:** `__ROUTINE_EXECUTOR_MODEL__`
- **Selected effort:** `medium`
- **Proof mode:** `declared`
- **Exception reason:** `n/a`
- **Guard outcome:** `go`
- **Waiver / exception reference:** `n/a`
TODO

python3 - "$TMP_DIR/approved-with-routing-preflight.md" "$ROUTINE_EXECUTOR_MODEL" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
path.write_text(
    path.read_text(encoding="utf-8").replace("__ROUTINE_EXECUTOR_MODEL__", sys.argv[2]),
    encoding="utf-8",
)
PY

assert_go "$TMP_DIR/approved-with-routing-preflight.md"

cat > "$TMP_DIR/architecture-supersede-missing-governance.md" <<'TODO'
# TODO: Architecture Supersede Missing Governance

## Delivery Status Canon
- **Current delivery stage:** `Pending`

## Approval
- **Approved by:** user approved with "APROVADO" on 2026-05-25.
- **Approval scope:** standardize the shared API envelope.

## Rules Acknowledgement / Ingestion
| Source | Why It Applies Now | Must Preserve | Must Avoid | Execution Impact |
| --- | --- | --- | --- | --- |
| `workflows/docker/todo-driven-execution-method.md` | TODO execution. | Explicit architectural cutover. | Silent regressions. | Guard the architecture package. |

## Module Decision Baseline Snapshot
| Module Decision Ref | Current Module Decision | Planned Handling (`Preserve|Supersede (Intentional)|Out of Scope`) | Evidence |
| --- | --- | --- | --- |
| `accounts#D-03` | Legacy mixed envelopes remain tolerated. | `Supersede (Intentional)` | `foundation_documentation/modules/accounts.md#decision-d03` |
TODO

assert_no_go "$TMP_DIR/architecture-supersede-missing-governance.md"
grep -q "ARCHITECTURE-GOVERNANCE-MISSING" "$OUTPUT_FILE"

cat > "$TMP_DIR/architecture-required-incomplete.md" <<'TODO'
# TODO: Architecture Required Incomplete

## Delivery Status Canon
- **Current delivery stage:** `Pending`

## Approval
- **Approved by:** user approved with "APROVADO" on 2026-05-25.
- **Approval scope:** standardize the shared API envelope.

## Rules Acknowledgement / Ingestion
| Source | Why It Applies Now | Must Preserve | Must Avoid | Execution Impact |
| --- | --- | --- | --- | --- |
| `workflows/docker/todo-driven-execution-method.md` | TODO execution. | Explicit architectural cutover. | Silent regressions. | Guard the architecture package. |

## Module Decision Baseline Snapshot
| Module Decision Ref | Current Module Decision | Planned Handling (`Preserve|Supersede (Intentional)|Out of Scope`) | Evidence |
| --- | --- | --- | --- |
| `accounts#D-03` | Legacy mixed envelopes remain tolerated. | `Supersede (Intentional)` | `foundation_documentation/modules/accounts.md#decision-d03` |

## Architecture Change Governance
- **Applicability (`required|not_needed`):** `required`
- **Why this applies:** replace the mixed envelope family with one canonical contract
- **Deviation / debt being retired:** exposing multiple envelope shapes for the same paginated discovery use case
- **Target steady-state after closeout:** every paginated collection uses the same response envelope
- **Temporary exceptions allowed:** `none`
- **Cutover / removal condition:** all targeted consumers and producers use the canonical envelope

### Patterns To Enforce
| Pattern / Decision | Source / ID | Scope | Why It Must Hold After Cutover |
| --- | --- | --- | --- |
| `canonical paginated envelope` | `accounts#D-07` | `account discovery surfaces` | `all consumers must decode one stable contract` |
TODO

assert_no_go "$TMP_DIR/architecture-required-incomplete.md"
grep -q "ARCHITECTURE-ANTI-PATTERNS-MISSING" "$OUTPUT_FILE"
grep -q "ARCHITECTURE-HARNESS-MISSING" "$OUTPUT_FILE"

cat > "$TMP_DIR/architecture-required-complete.md" <<'TODO'
# TODO: Architecture Required Complete

## Delivery Status Canon
- **Current delivery stage:** `Pending`

## Approval
- **Approved by:** user approved with "APROVADO" on 2026-05-25.
- **Approval scope:** standardize the shared API envelope.

## Rules Acknowledgement / Ingestion
| Source | Why It Applies Now | Must Preserve | Must Avoid | Execution Impact |
| --- | --- | --- | --- | --- |
| `workflows/docker/todo-driven-execution-method.md` | TODO execution. | Explicit architectural cutover. | Silent regressions. | Guard the architecture package. |

## Module Decision Baseline Snapshot
| Module Decision Ref | Current Module Decision | Planned Handling (`Preserve|Supersede (Intentional)|Out of Scope`) | Evidence |
| --- | --- | --- | --- |
| `accounts#D-03` | Legacy mixed envelopes remain tolerated. | `Supersede (Intentional)` | `foundation_documentation/modules/accounts.md#decision-d03` |

## Architecture Change Governance
- **Applicability (`required|not_needed`):** `required`
- **Why this applies:** replace the mixed envelope family with one canonical contract
- **Deviation / debt being retired:** exposing multiple envelope shapes for the same paginated discovery use case
- **Target steady-state after closeout:** every paginated collection uses the same response envelope
- **Temporary exceptions allowed:** `none`
- **Cutover / removal condition:** all targeted consumers and producers use the canonical envelope

### Patterns To Enforce
| Pattern / Decision | Source / ID | Scope | Why It Must Hold After Cutover |
| --- | --- | --- | --- |
| `canonical paginated envelope` | `accounts#D-07` | `account discovery surfaces` | `all consumers must decode one stable contract` |

### Prohibited Anti-Patterns
| Anti-Pattern / Wrong Path | Detection Signal | Why It Is Forbidden After Cutover | Exception Policy |
| --- | --- | --- | --- |
| `raw paginator shape exposed at the API boundary` | `guard + contract review` | `reintroduces multi-envelope drift` | `none` |

### Architecture Protection Harness
| Harness Type | Surface | Command / Rule / Artifact | Regression It Must Catch | Adoption Timing (`already-enforced|implement-in-this-todo|follow-up-approved|manual-only-with-rationale`) | Evidence Plan / Follow-up |
| --- | --- | --- | --- | --- | --- |
| `guard` | `shared TODO architecture contract` | `python3 delphi-ai/tools/todo_authority_guard.py foundation_documentation/todos/active/v0.2.5/TODO-canonical-envelope.md` | `missing architecture governance on future supersede TODOs` | `already-enforced` | `guard output` |
| `test` | `API contract suite` | `php artisan test --filter CanonicalEnvelopeContractTest` | `legacy envelope emitted again` | `implement-in-this-todo` | `DOD + validation rows in the governing TODO` |

## Architecture Review Gates
- **Architecture decision review:** `required`
- **Decision review status:** `no_material_findings`
- **Architecture adherence review:** `required`
- **Adherence review status:** `n/a`
TODO

assert_go "$TMP_DIR/architecture-required-complete.md"

cat > "$TMP_DIR/architecture-not-needed.md" <<'TODO'
# TODO: Architecture Not Needed

## Delivery Status Canon
- **Current delivery stage:** `Pending`

## Approval
- **Approved by:** user approved with "APROVADO" on 2026-05-25.
- **Approval scope:** correct a bounded screen layout regression.

## Rules Acknowledgement / Ingestion
| Source | Why It Applies Now | Must Preserve | Must Avoid | Execution Impact |
| --- | --- | --- | --- | --- |
| `workflows/docker/todo-driven-execution-method.md` | TODO execution. | Explicit authority gate. | Silent scope expansion. | Guard the bounded correction. |

## Architecture Change Governance
- **Applicability:** `not_needed`
- **Why this applies:** no architecture is established or superseded.
- **Deviation / debt being retired:** `n/a`
- **Target steady-state after closeout:** `n/a`
- **Temporary exceptions allowed:** `none`
- **Cutover / removal condition:** `n/a`
TODO

assert_go "$TMP_DIR/architecture-not-needed.md"

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
| Repository / CI Surface | Why In Scope | Behavior / Scenario Covered | Fixture / Seed / Runtime Preconditions | Local CI-Equivalent Command | Required Before | Status | Evidence Artifact / Command | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| delphi-ai / authority guard | Guard changed. | Canonical CI status column. | Repository checkout only. | `bash tools/tests/todo_authority_guard_test.sh` | Local-Implemented | passed | `bash tools/tests/todo_authority_guard_test.sh` | passed |

## Pipeline/Copilot P1/P2 Preflight
| Reviewer Surface / Package | Review Focus | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| bounded diff | high-priority findings | passed | `bash tools/tests/todo_authority_guard_test.sh` | No unresolved P1/P2 findings | complete |

## Rule-Spirit Anti-Pattern Hunt
| Rule / Principle Surface | Bypass or Anti-Pattern Search Lens | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| TODO process | process bypass | passed | `bash tools/tests/todo_authority_guard_test.sh` | No unresolved P1/P2 findings | complete |

## Promotion Finding Routing Ledger
| Finding ID | Severity | Classification | Routing Decision | Same TODO / Split Rationale | Status | Approval / Follow-up Reference |
| --- | --- | --- | --- | --- | --- | --- |
| `PR-1` | `P1` | `confirmed defect` | `same-todo-remediation` | Preserves same approved promotion objective and scenario. | `fixed` | `same TODO evidence refreshed` |
TODO

assert_go "$TMP_DIR/local-implemented-complete.md"

cp "$TMP_DIR/local-implemented-complete.md" "$TMP_DIR/local-implemented-ci-status-failing.md"
python3 - "$TMP_DIR/local-implemented-ci-status-failing.md" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
path.write_text(path.read_text(encoding="utf-8").replace("| Local-Implemented | passed |", "| Local-Implemented | blocked |", 1), encoding="utf-8")
PY
assert_no_go "$TMP_DIR/local-implemented-ci-status-failing.md"
grep -q "DELIVERY-GATE-STATUS-NOT-PASSING" "$OUTPUT_FILE"

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
| Repository / CI Surface | Why In Scope | Behavior / Scenario Covered | Fixture / Seed / Runtime Preconditions | Local CI-Equivalent Command | Required Before | Status | Evidence Artifact / Command | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| delphi-ai / authority guard | Guard changed. | Canonical CI status column. | Repository checkout only. | `bash tools/tests/todo_authority_guard_test.sh` | Local-Implemented | passed | `bash tools/tests/todo_authority_guard_test.sh` | passed |

## Pipeline/Copilot P1/P2 Preflight
| Reviewer Surface / Package | Review Focus | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| bounded diff | high-priority findings | passed | `bash tools/tests/todo_authority_guard_test.sh` | No unresolved P1/P2 findings | complete |

## Rule-Spirit Anti-Pattern Hunt
| Rule / Principle Surface | Bypass or Anti-Pattern Search Lens | Status | Evidence Artifact / Command | Findings | Resolution / Notes |
| --- | --- | --- | --- | --- | --- |
| TODO process | process bypass | passed | `bash tools/tests/todo_authority_guard_test.sh` | No unresolved P1/P2 findings | complete |

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

cat > "$TMP_DIR/promotion-followup-no-ref.md" <<'TODO'
# TODO: Promotion Followup No Reference

## Delivery Status Canon
- **Current delivery stage:** `Pending`

## Approval
- **Approved by:** user approved with "APROVADO" on 2026-05-25.
- **Approval scope:** implement the bounded guard.

## Rules Acknowledgement / Ingestion
| Source | Why It Applies Now | Must Preserve | Must Avoid | Execution Impact |
| --- | --- | --- | --- | --- |
| `skills/github-stage-promotion-orchestrator/SKILL.md` | Promotion flow. | Explicit follow-up routing. | Silent deferral. | Check routing. |

## Promotion Finding Routing Ledger
| Finding ID | Severity | Classification | Routing Decision | Same TODO / Split Rationale | Status | Approval / Follow-up Reference |
| --- | --- | --- | --- | --- | --- | --- |
| `PR-3` | `P3` | `follow-up-hardening` | `same-todo-note-only` | Non-blocking but real. | `deferred` | `n/a` |
TODO

assert_no_go "$TMP_DIR/promotion-followup-no-ref.md"
grep -q "PROMOTION-FOLLOWUP-MISSING-REFERENCE" "$OUTPUT_FILE"

python3 - "$ROOT_DIR" <<'PY'
import sys
sys.path.insert(0, sys.argv[1] + "/tools")
from todo_authority_guard import extract_sections, validate_implementation_horizon

def check(text, expected):
    violations, _ = validate_implementation_horizon(extract_sections(text.splitlines()))
    codes = {item["code"] for item in violations}
    assert expected <= codes, (expected, codes)

valid_current = '''## Implementation Horizon & Extensibility Intent
- **Mode:** `current-scope-only`
- **Current delivery:** deliver one bounded change
- **Explicit future cases informing the design:** `none`
- **Anticipatory implementation authorized now:** `none`
- **Not authorized now:** unrelated speculation
- **Rationale:** bounded delivery
'''
assert not validate_implementation_horizon(extract_sections(valid_current.splitlines()))[0]
valid_current_cases = valid_current.replace('`none`', 'future reports are informational', 1)
assert not validate_implementation_horizon(extract_sections(valid_current_cases.splitlines()))[0]
check(valid_current.replace('current-scope-only', 'unsupported-mode'), {"HORIZON-MODE-INVALID"})
check(valid_current.replace('current-scope-only', 'CURRENT-SCOPE-ONLY'), {"HORIZON-MODE-INVALID"})
check(valid_current.replace('**Rationale:** bounded delivery', '**Rationale:** `<required>`'), {"HORIZON-FIELD-MISSING"})
check(valid_current.replace('**Current delivery:** deliver one bounded change', '**Current delivery:** `none`'), {"HORIZON-FIELD-MISSING"})
check(valid_current.replace('**Anticipatory implementation authorized now:** `none`', '**Anticipatory implementation authorized now:** `adapter seam`'), {"HORIZON-ANTICIPATORY-MUST-BE-NONE"})
check(valid_current.replace('**Anticipatory implementation authorized now:** `none`', '**Anticipatory implementation authorized now:** `None`'), {"HORIZON-ANTICIPATORY-MUST-BE-NONE"})
check(valid_current.replace('**Explicit future cases informing the design:** `none`', '**Explicit future cases informing the design:** `n/a`'), {"HORIZON-FUTURE-CASES-MISSING"})
check(valid_current.replace('**Explicit future cases informing the design:** `none`', '**Explicit future cases informing the design:** `not applicable`'), {"HORIZON-FUTURE-CASES-MISSING"})
valid_bounded = valid_current.replace('current-scope-only', 'bounded-anticipatory-extensibility').replace('`none`', 'future channels', 1).replace('`none`', 'channel adapter seam', 1)
assert not validate_implementation_horizon(extract_sections(valid_bounded.splitlines()))[0]
check(valid_bounded.replace('future channels', 'none'), {"HORIZON-FUTURE-CASES-MISSING"})
check(valid_bounded.replace('channel adapter seam', 'none'), {"HORIZON-ANTICIPATORY-SEAM-MISSING"})
assert not validate_implementation_horizon(extract_sections([]))[0]  # legacy absence

lowercase_heading = valid_current.replace(
    '## Implementation Horizon & Extensibility Intent',
    '## implementation horizon & extensibility intent',
).replace('`current-scope-only`', '`invalid-mode`')
violations, context = validate_implementation_horizon(extract_sections(lowercase_heading.splitlines()))
assert context["implementation_horizon_present"]
assert {"HORIZON-MODE-INVALID"} <= {item["code"] for item in violations}

required_heading = valid_current.replace(
    '## Implementation Horizon & Extensibility Intent',
    '## Implementation Horizon & Extensibility Intent (Required)',
).replace('`current-scope-only`', '`invalid-mode`')
violations, context = validate_implementation_horizon(extract_sections(required_heading.splitlines()))
assert context["implementation_horizon_present"]
assert {"HORIZON-MODE-INVALID"} <= {item["code"] for item in violations}

accepted_horizon_headings = [
    *(f"{'#' * level} Implementation Horizon & Extensibility Intent" for level in range(1, 7)),
    "## **Implementation Horizon & Extensibility Intent**",
    "### `Implementation Horizon & Extensibility Intent`",
    "#### _implementation horizon & extensibility intent_ (Required)",
    "##### > Implementation Horizon & Extensibility Intent",
]
for heading in accepted_horizon_headings:
    adopted = valid_current.replace('## Implementation Horizon & Extensibility Intent', heading, 1)
    violations, context = validate_implementation_horizon(extract_sections(adopted.splitlines()))
    assert context["implementation_horizon_present"], heading
    assert not violations, (heading, violations)

for indent in range(4):
    heading = f"{' ' * indent}## Implementation Horizon & Extensibility Intent"
    adopted = valid_current.replace('## Implementation Horizon & Extensibility Intent', heading, 1)
    violations, context = validate_implementation_horizon(extract_sections(adopted.splitlines()))
    assert context["implementation_horizon_present"], heading
    assert not violations, (heading, violations)

code_block_horizon = valid_current.replace(
    '## Implementation Horizon & Extensibility Intent',
    '    ## Implementation Horizon & Extensibility Intent',
    1,
)
violations, context = validate_implementation_horizon(extract_sections(code_block_horizon.splitlines()))
assert not context["implementation_horizon_present"]
assert not violations  # Four-space code text remains unrelated legacy content.

near_collision = valid_current.replace(
    '## Implementation Horizon & Extensibility Intent',
    '## Implementation Horizon & Extensibility Intentional Notes',
)
violations, context = validate_implementation_horizon(extract_sections(near_collision.splitlines()))
assert not context["implementation_horizon_present"]
assert not violations  # A near-collision heading remains unrelated legacy content.

duplicate_horizon = valid_current + '''
## implementation horizon & extensibility intent (Required)
- **Mode:** `current-scope-only`
- **Current delivery:** deliver one bounded change
- **Explicit future cases informing the design:** `none`
- **Anticipatory implementation authorized now:** `none`
- **Not authorized now:** unrelated speculation
- **Rationale:** duplicate authority
'''
violations, context = validate_implementation_horizon(extract_sections(duplicate_horizon.splitlines()))
assert context["implementation_horizon_section_count"] == 2
assert {"HORIZON-SECTION-DUPLICATE"} <= {item["code"] for item in violations}

exact_duplicate_horizon = valid_current + "\n" + valid_current
violations, context = validate_implementation_horizon(extract_sections(exact_duplicate_horizon.splitlines()))
assert context["implementation_horizon_section_count"] == 2
assert {"HORIZON-SECTION-DUPLICATE"} <= {item["code"] for item in violations}

indented_duplicate_horizon = valid_current.replace(
    '## Implementation Horizon & Extensibility Intent',
    '   ## Implementation Horizon & Extensibility Intent',
    1,
)
indented_duplicate_horizon += "\n" + indented_duplicate_horizon
violations, context = validate_implementation_horizon(extract_sections(indented_duplicate_horizon.splitlines()))
assert context["implementation_horizon_section_count"] == 2
assert {"HORIZON-SECTION-DUPLICATE"} <= {item["code"] for item in violations}

empty_at_eof = extract_sections(['## Implementation Horizon & Extensibility Intent'])
violations, context = validate_implementation_horizon(empty_at_eof)
assert context["implementation_horizon_present"]
assert {"HORIZON-MODE-INVALID"} <= {item["code"] for item in violations}

empty_before_next_h2 = extract_sections([
    '## Implementation Horizon & Extensibility Intent',
    '## Unrelated Section',
])
violations, context = validate_implementation_horizon(empty_before_next_h2)
assert context["implementation_horizon_present"]
assert {"HORIZON-MODE-INVALID"} <= {item["code"] for item in violations}
PY

printf 'todo_authority_guard_test: OK\n'
