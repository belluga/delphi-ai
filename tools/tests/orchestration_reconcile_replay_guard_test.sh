#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT_DIR/tools/orchestration_reconcile_replay_guard.py"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

REPO="$TMP_DIR/repo"
PLAN_DIR="$REPO/foundation_documentation/artifacts/execution-plans"
TODO_DIR="$REPO/foundation_documentation/todos/active/v0"
PLAN="$PLAN_DIR/test-plan.md"
TODO_FILE="$TODO_DIR/test-orchestrated-slice.md"
OUTPUT="$TMP_DIR/guard.out"

mkdir -p "$PLAN_DIR" "$TODO_DIR"

git -C "$TMP_DIR" init -q "$REPO"
git -C "$REPO" config user.email test@example.test
git -C "$REPO" config user.name "Test User"

printf 'base\n' > "$REPO/app.txt"
git -C "$REPO" add app.txt
git -C "$REPO" commit -q -m "base"
git -C "$REPO" checkout -q -b release/v0.2.0+8
git -C "$REPO" checkout -q -b reconcile/v0.2.0+8/test-plan
printf 'reconcile\n' >> "$REPO/app.txt"
git -C "$REPO" add app.txt
git -C "$REPO" commit -q -m "reconcile accepted state"
RECONCILE_SHA="$(git -C "$REPO" rev-parse HEAD)"
git -C "$REPO" checkout -q release/v0.2.0+8
git -C "$REPO" merge -q --ff-only "$RECONCILE_SHA"
RETURN_SHA="$(git -C "$REPO" rev-parse HEAD)"

cat > "$TODO_FILE" <<'EOF'
# Test Orchestrated Slice

## Definition of Done
- [ ] Aggregated status payload is returned from the reconciled service.

## Validation Steps
- [ ] Run the targeted aggregate verification command for the owned slice.
EOF

write_valid_plan() {
  local replay_status="$1"
  local replay_mode="$2"
  local promotion_source="$3"
  local post_replay_ci_status="$4"

  cat > "$PLAN" <<EOF
# Test Plan

## Artifact Identity
- **Artifact type:** orchestration_execution_plan
- **Status:** Approved
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
| DOD-1 | Aggregated status payload is returned from the reconciled service. | worker-alpha | reconciled aggregate payload | worker checkpoint commit $RECONCILE_SHA | ./tools/run-aggregate-verification.sh | n/a - backend-only reconcile slice | passed |
| VAL-1 | Run the targeted aggregate verification command for the owned slice. | worker-alpha | aggregate verification command | worker checkpoint commit $RECONCILE_SHA | ./tools/run-aggregate-verification.sh | n/a - backend-only reconcile slice | passed |

## Spec Deviation Ledger
| Source TODO / Criterion | Original Requirement | Proposed Deviation | Approval Evidence | Status |
| --- | --- | --- | --- | --- |
| None | No spec deviations approved | n/a | n/a | n/a |

## Dependency Graph
- worker-alpha must land its approved slice before the reconcile validation wave.

## Orchestration Topology
- **Base branch / commit:** release/v0.2.0+8~1
- **Orchestrator reconciliation branch:** reconcile/v0.2.0+8/test-plan
- **Principal checkout policy:** Principal checkout runs the authoritative CI Equivalent and runtime validation against the reconciliation branch.
- **Runtime-facing source checkouts:** service-app
- **Authoritative return branch after reconcile:** release/v0.2.0+8
- **Reconcile failure routing rule:** CI Equivalent or runtime failures return to the owning worker/subagent or TODO owner by default; orchestrator code changes remain reconciliation-only and limited to merge-conflict or integration glue fixes.
- **Promotion source after reconcile:** $promotion_source
- **Worker branches / worktrees:** worker-alpha
- **Derived artifact repos:** none

## Workstreams
| Workstream | Worker | Dependencies | Checkpoint | Worker-local validation |
| --- | --- | --- | --- | --- |
| Aggregate reconcile | worker-alpha | approved TODO slice | worker checkpoint recorded | ./tools/run-aggregate-verification.sh |

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
| service-app / aggregate verification | Reconcile integrates the owned slice before promotion | ./tools/run-aggregate-verification.sh | reconcile branch | passed | command log for $RECONCILE_SHA | orchestrator |

## Consolidated Delivery Evidence
| Area | Required Evidence | Status | Evidence Artifact / Command | Owner |
| --- | --- | --- | --- | --- |
| Reconcile validation | CI Equivalent aggregate verification recorded on the reconciliation branch | passed | ./tools/run-aggregate-verification.sh (release replay anchored at $RETURN_SHA) | orchestrator |

## Post-Reconcile Replay Evidence
- **Replay required?:** yes
- **Replay status:** $replay_status
- **Accepted reconcile branch:** reconcile/v0.2.0+8/test-plan
- **Accepted reconcile commit:** $RECONCILE_SHA
- **Replay mode:** $replay_mode
- **Authoritative return branch verified:** release/v0.2.0+8
- **Authoritative return branch head after replay:** $RETURN_SHA
- **Promotion source branch verified:** $promotion_source
- **Replay commit(s) on authoritative branch:** same-as-reconcile
- **Replay proof summary:** Fast-forward replay from reconcile/v0.2.0+8/test-plan onto release/v0.2.0+8; approval recorded and branch head verified at $RETURN_SHA.
- **Post-replay authoritative CI-equivalent status:** $post_replay_ci_status

## Risk / Conflict Controls
- Conflicts are resolved only to reconcile approved worker outputs and preserve TODO scope.

## Approval Request
- Request token: APROVADO
- Execution authorized by approval: merge approved worker outputs into the reconciliation branch, run authoritative CI Equivalent, collect evidence, and replay accepted net effect onto the canonical branch before promotion resumes.
- Execution not authorized by approval: implement new TODO scope, rewrite worker-owned behavior, or promote directly from reconcile.
EOF
}

assert_go() {
  python3 "$SCRIPT" --plan "$PLAN" --repo "$REPO" >"$OUTPUT"
  grep -q "Overall outcome: go" "$OUTPUT"
}

assert_blocked() {
  local expected_code="$1"
  if python3 "$SCRIPT" --plan "$PLAN" --repo "$REPO" >"$OUTPUT" 2>&1; then
    cat "$OUTPUT"
    printf 'expected guard to block with %s\n' "$expected_code" >&2
    exit 1
  fi
  grep -q "$expected_code" "$OUTPUT"
  grep -q "Overall outcome: no-go" "$OUTPUT"
}

write_valid_plan "passed" "fast-forward" "release/v0.2.0+8" "not-needed"
assert_go

write_valid_plan "passed" "fast-forward" "release/v0.2.0+8" "not-needed"
awk 'BEGIN{skip=0} /^## Post-Reconcile Replay Evidence$/{skip=1; next} skip && /^## /{skip=0} !skip{print}' "$PLAN" > "$TMP_DIR/plan.tmp"
mv "$TMP_DIR/plan.tmp" "$PLAN"
assert_blocked "REPLAY-SECTION-MISSING"

write_valid_plan "passed" "fast-forward" "reconcile/v0.2.0+8/test-plan" "not-needed"
assert_blocked "DELIVERY-PLAN-PROMOTION-SOURCE-INVALID"

write_valid_plan "passed" "curated-replay" "release/v0.2.0+8" "not-needed"
assert_blocked "POST-REPLAY-CI-RERUN-MISSING"

printf 'orchestration_reconcile_replay_guard_test: OK\n'
