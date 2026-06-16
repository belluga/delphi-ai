#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT_DIR/tools/orchestration_plan_completion_guard.py"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

PLAN_DIR="$TMP_DIR/foundation_documentation/artifacts/execution-plans"
TODO_DIR="$TMP_DIR/foundation_documentation/todos/active/v0"
PLAN="$PLAN_DIR/test-plan.md"
TODO_FILE="$TODO_DIR/test-orchestrated-slice.md"
OUTPUT="$TMP_DIR/guard.out"

mkdir -p "$PLAN_DIR" "$TODO_DIR"

cat > "$TODO_FILE" <<'EOF'
# Test Orchestrated Slice

## Definition of Done
- [ ] Aggregated status payload is returned from the reconciled service.

## Validation Steps
- [ ] Run the targeted aggregate verification command for the owned slice.
EOF

write_valid_plan() {
  local promotion_source="$1"
  cat > "$PLAN" <<EOF
# Test Plan

## Artifact Identity
- **Artifact type:** orchestration_execution_plan
- **Status:** Pending Approval
- **Created:** 2026-06-14
- **Governing workflow / skill:** delphi-ai/workflows/docker/subagent-worktree-reconciliation-method.md
- **Approval token required before execution:** APROVADO

## Authority Boundary
This plan covers only orchestrator reconciliation of approved worker-owned TODO slices.

## Governing TODO Set
| TODO Path | Worker | Start Eligibility |
| --- | --- | --- |
| foundation_documentation/todos/active/v0/test-orchestrated-slice.md | worker-alpha | Approved and ready for reconcile |

## Acceptance Traceability Matrix
| Requirement ID | Source TODO / Criterion | Implementation Owner | Required Artifact / UI Marker | Implementation Evidence | Test Evidence | Runtime / Web Evidence | Status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| DOD-1 | Aggregated status payload is returned from the reconciled service. | worker-alpha | reconciled aggregate payload | worker checkpoint notes | targeted aggregate verification command | n/a - backend-only reconcile slice | planned |
| VAL-1 | Run the targeted aggregate verification command for the owned slice. | worker-alpha | aggregate verification command | worker checkpoint notes | targeted aggregate verification command | n/a - backend-only reconcile slice | planned |

## Spec Deviation Ledger
| Source TODO / Criterion | Original Requirement | Proposed Deviation | Approval Evidence | Status |
| --- | --- | --- | --- | --- |
| None | No spec deviations approved | n/a | n/a | n/a |

## Dependency Graph
- worker-alpha must land its approved slice before the reconcile validation wave.

## Orchestration Topology
- **Reconciliation branch:** reconcile/v0.2.0+8/test-plan
- **Principal checkout validation policy:** Principal checkout runs the authoritative CI Equivalent and runtime validation against the reconciliation branch.
- **Authoritative return branch after reconcile:** release/v0.2.0+8
- **Reconcile failure routing rule:** CI Equivalent or runtime failures return to the owning worker/subagent or TODO owner by default; orchestrator code changes remain reconciliation-only and limited to merge-conflict or integration glue fixes.
- **Promotion source after reconcile:** $promotion_source

## Workstreams
| Workstream | Worker | Dependencies | Checkpoint | Worker-local validation |
| --- | --- | --- | --- | --- |
| Aggregate reconcile | worker-alpha | approved TODO slice | worker checkpoint recorded | targeted aggregate verification command |

## Execution Ownership Ledger
| Workstream | Implementation Owner | Orchestrator Code Scope | Worker Checkpoint Evidence | Reconciliation Evidence |
| --- | --- | --- | --- | --- |
| Aggregate reconcile | worker-alpha | reconciliation-only | worker checkpoint recorded | reconcile branch validation notes |

## Execution Waves
The orchestrator advances autonomously between waves. Wave boundaries are internal controls, not routine feedback gates. Stop only for mandatory user decision, scope change, conflict with a governing TODO, blocker, or validation waiver.

### Wave 0
- Validate worker checkpoints and merge order.

### Wave 1
- Merge the approved slice and execute authoritative reconcile validation.

## Consolidated Validation Matrix
| Validation Surface | Required Evidence | Runtime Target | Owner | Status |
| --- | --- | --- | --- | --- |
| Reconcile validation | CI Equivalent aggregate verification recorded on the reconciliation branch | principal checkout | orchestrator | planned |

## CI-Equivalent Local Suite Matrix
| Repository / CI Surface | Why In Scope | Local CI-Equivalent Command | Applies To | Status | Evidence Artifact / Command | Owner |
| --- | --- | --- | --- | --- | --- | --- |
| service-app / aggregate verification | Reconcile integrates the owned slice before promotion | ./tools/run-aggregate-verification.sh | reconcile branch | planned | command log | orchestrator |

## Risk / Conflict Controls
- Conflicts are resolved only to reconcile approved worker outputs and preserve TODO scope.

## Approval Request
- Request token: APROVADO
- Execution authorized by approval: merge approved worker outputs into the reconciliation branch, run authoritative CI Equivalent, and collect evidence.
- Execution not authorized by approval: implement new TODO scope, rewrite worker-owned behavior, or promote directly from reconcile.
EOF
}

assert_go() {
  python3 "$SCRIPT" --plan "$PLAN" >"$OUTPUT"
  grep -q "Overall outcome: go" "$OUTPUT"
}

assert_blocked() {
  local expected_code="$1"
  if python3 "$SCRIPT" --plan "$PLAN" >"$OUTPUT" 2>&1; then
    cat "$OUTPUT"
    printf 'expected guard to block with %s\n' "$expected_code" >&2
    exit 1
  fi
  grep -q "$expected_code" "$OUTPUT"
  grep -q "Overall outcome: no-go" "$OUTPUT"
}

write_valid_plan "release/v0.2.0+8"
assert_go

write_valid_plan "release/v0.2.0+8"
grep -v "Authoritative return branch after reconcile" "$PLAN" >"$TMP_DIR/plan.tmp"
mv "$TMP_DIR/plan.tmp" "$PLAN"
assert_blocked "RETURN-BRANCH-MISSING"

write_valid_plan "reconcile/v0.2.0+8/promotion"
assert_blocked "PROMOTION-SOURCE-INVALID"

printf 'orchestration_plan_completion_guard_test: OK\n'
