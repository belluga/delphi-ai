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
TODO

assert_go "$TMP_DIR/architecture-required-complete.md"

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

printf 'todo_authority_guard_test: OK\n'
