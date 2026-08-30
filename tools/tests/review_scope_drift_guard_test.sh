#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOL="$SCRIPT_DIR/../review_scope_drift_guard.py"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DELIVERY_WORKFLOW="$REPO_ROOT/workflows/docker/todo-delivery-gates-method.md"
DELIVERY_SKILL="$REPO_ROOT/skills/wf-docker-todo-delivery-gates-method/SKILL.md"

grep -Fq 'immediately before dispatch, run `python3 delphi-ai/tools/review_scope_drift_guard.py --todo <todo-path>`; rerun it after remediation touching protected sections;' "$DELIVERY_WORKFLOW"
grep -Fq 'approved baseline SHA and the exact fresh scope-drift guard output' "$DELIVERY_WORKFLOW"
grep -Fq 'Immediately before final-review dispatch, rerun the same scope-drift guard and repeat it after protected-section remediation.' "$DELIVERY_WORKFLOW"
grep -Fq 'Immediately before each architecture-adherence or final-review dispatch, rerun `review_scope_drift_guard.py` against the approved baseline; rerun it after protected-section remediation.' "$DELIVERY_SKILL"
grep -Fq 'approved baseline SHA and the exact fresh guard output; protected remediation requires a new binding from the rerun.' "$DELIVERY_SKILL"

python3 - <<'PY' "$TOOL"
import importlib.util
import sys
from pathlib import Path

tool_path = Path(sys.argv[1])
sys.path.insert(0, str(tool_path.parent))
spec = importlib.util.spec_from_file_location("review_scope_drift_guard", tool_path)
module = importlib.util.module_from_spec(spec)
assert spec.loader is not None
spec.loader.exec_module(module)
assert not module.heading_matches(
    "## Implementation Horizon & Extensibility Intentional Notes",
    "## Implementation Horizon & Extensibility Intent",
)
title = "Implementation Horizon & Extensibility Intent"
accepted_horizon_headings = [
    *(f"{'#' * level} {title}" for level in range(1, 7)),
    f"## **{title}**",
    f"### `{title}`",
    f"#### _{title.lower()}_ (Required)",
    f"##### > {title}",
]
for index, heading in enumerate(accepted_horizon_headings):
    baseline = [
        heading,
        "- **Mode:** `current-scope-only`",
        "- **Rationale:** baseline contract",
    ]
    current = baseline.copy()
    current[1 if index % 2 == 0 else 2] = (
        "- **Mode:** `bounded-anticipatory-extensibility`"
        if index % 2 == 0
        else "- **Rationale:** decorated heading drift"
    )
    assert module.heading_matches(heading, f"## {title}"), heading
    assert title in module.material_changes(baseline, current), heading
    assert len(module.find_section_bounds_all(baseline + current, f"## {title}")) == 2, heading

governance_baseline = [
    "## Architecture Change Governance",
    "### Patterns To Enforce",
    "- canonical envelope remains required",
    "## Questions To Close",
]
governance_current = governance_baseline.copy()
governance_current[2] = "- legacy envelope is permitted again"
assert "### Patterns To Enforce" in module.section_body(
    governance_baseline, "## Architecture Change Governance"
)
assert "Architecture Change Governance" in module.material_changes(
    governance_baseline, governance_current
)

non_h2_horizon = [
    f"### {title}",
    "- **Mode:** `current-scope-only`",
    "#### Nested Horizon Detail",
    "- retained nested detail",
    "### Next Peer Section",
    "- outside the horizon",
]
assert module.find_section_bounds_all(non_h2_horizon, f"## {title}") == [(1, 4)]
assert "#### Nested Horizon Detail" in module.section_body(non_h2_horizon, f"## {title}")
PY

tmpdir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmpdir"
}
trap cleanup EXIT

repo="$tmpdir/foundation_documentation"
mkdir -p "$repo"
cd "$repo"

git init -q
git config user.name "Delphi Test"
git config user.email "delphi-test@example.com"
git branch -M main

mkdir -p todos/active/test
todo="todos/active/test/TODO-review-scope-drift.md"

cat >"$todo" <<'EOF'
# TODO: Review Scope Drift Guard Test

## Context
Baseline context.

## Scope
- [ ] original scope

## Implementation Horizon & Extensibility Intent
- **Mode:** `current-scope-only`
- **Current delivery:** keep the original bounded slice
- **Explicit future cases informing the design:** `none`
- **Anticipatory implementation authorized now:** `none`
- **Not authorized now:** speculative expansion
- **Rationale:** baseline contract

## Definition of Done
- [ ] keep original scope stable during review

## Completion Evidence Matrix
| Scope / Criterion | Evidence | Status | Notes |
| --- | --- | --- | --- |
| `baseline` | `initial proof` | `pending` | `operational row` |

## Local CI-Equivalent Suite Matrix
| Repository / CI Surface | Why In Scope | Local CI-Equivalent Command | Required Before | Status | Evidence Artifact / Command | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| `sample-surface` | baseline proof row | `run-sample` | `before closeout` | `pending` | `none yet` | `operational row` |

## Decision Baseline (Frozen Before Implementation)
- [x] `D-01` Scope remains the original bounded slice.

## Architecture Change Governance
- **Applicability (`required|not_needed`):** `required`
- **Why this applies:** canonicalize one pagination envelope
- **Deviation / debt being retired:** mixed list contracts
- **Target steady-state after closeout:** one collection envelope for every targeted surface
- **Temporary exceptions allowed:** `none`
- **Cutover / removal condition:** all targeted consumers migrate

## Gate: Review Baseline Freeze
- **Gate decision:** `required`
- **Why this decision:** baseline must be pushed before review
- **Trigger stage:** `before the first planning-side review or guard run`
- **Baseline branch:** `main`
- **Baseline commit:** `<pending>`
- **Baseline push reference:** `origin/main`
- **Gate status:** `not_run`
- **Findings summary:** `pending`
- **Evidence / reference:** `<pending>`
- **Waiver authority / reference (required if waived):** `n/a`

## Gate: Review Scope Drift
- **Gate decision:** `required`
- **Why this decision:** scope-governing sections must not drift silently
- **Trigger stage:** `after the planning-side review/guard cycle converges and before APROVADO`
- **Baseline source:** `Review Baseline Freeze -> Baseline commit`
- **Material sections compared:** `canonical default`
- **Guard command:** `python3 delphi-ai/tools/review_scope_drift_guard.py --todo <todo-path>`
- **Gate status:** `not_run`
- **Findings summary:** `pending`
- **Evidence / reference:** `<pending>`
- **Waiver authority / reference (required if waived):** `n/a`
EOF

git add "$todo"
git commit -q -m "baseline"
baseline_sha="$(git rev-parse HEAD)"
git update-ref "refs/remotes/origin/main" "$baseline_sha"

cat >"$todo" <<EOF
# TODO: Review Scope Drift Guard Test

## Context
Baseline context.

## Scope
- [ ] original scope

## Implementation Horizon & Extensibility Intent
- **Mode:** \`current-scope-only\`
- **Current delivery:** keep the original bounded slice
- **Explicit future cases informing the design:** \`none\`
- **Anticipatory implementation authorized now:** \`none\`
- **Not authorized now:** speculative expansion
- **Rationale:** baseline contract

## Definition of Done
- [ ] keep original scope stable during review

## Completion Evidence Matrix
| Scope / Criterion | Evidence | Status | Notes |
| --- | --- | --- | --- |
| \`baseline\` | \`initial proof\` | \`passed\` | \`operational row updated\` |

## Local CI-Equivalent Suite Matrix
| Repository / CI Surface | Why In Scope | Local CI-Equivalent Command | Required Before | Status | Evidence Artifact / Command | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| \`sample-surface\` | baseline proof row | \`run-sample --refreshed\` | \`before closeout\` | \`passed\` | \`captured sample run\` | \`operational row updated\` |

## Decision Baseline (Frozen Before Implementation)
- [x] \`D-01\` Scope remains the original bounded slice.

## Architecture Change Governance
- **Applicability (\`required|not_needed\`):** \`required\`
- **Why this applies:** canonicalize one pagination envelope
- **Deviation / debt being retired:** mixed list contracts
- **Target steady-state after closeout:** one collection envelope for every targeted surface
- **Temporary exceptions allowed:** \`none\`
- **Cutover / removal condition:** all targeted consumers migrate

## Gate: Review Baseline Freeze
- **Gate decision:** \`required\`
- **Why this decision:** baseline must be pushed before review
- **Trigger stage:** \`before the first planning-side review or guard run\`
- **Baseline branch:** \`main\`
- **Baseline commit:** \`$baseline_sha\`
- **Baseline push reference:** \`origin/main\`
- **Gate status:** \`no_material_findings\`
- **Findings summary:** \`baseline pushed before review\`
- **Evidence / reference:** \`main@$baseline_sha pushed to origin/main\`
- **Waiver authority / reference (required if waived):** \`n/a\`

## Gate: Review Scope Drift
- **Gate decision:** \`required\`
- **Why this decision:** scope-governing sections must not drift silently
- **Trigger stage:** \`after the planning-side review/guard cycle converges and before APROVADO\`
- **Baseline source:** \`Review Baseline Freeze -> Baseline commit\`
- **Material sections compared:** \`canonical default\`
- **Guard command:** \`python3 delphi-ai/tools/review_scope_drift_guard.py --todo <todo-path>\`
- **Gate status:** \`running\`
- **Findings summary:** \`review bookkeeping changed only\`
- **Evidence / reference:** \`pending current run\`
- **Waiver authority / reference (required if waived):** \`n/a\`
EOF

if ! python3 "$TOOL" --todo "$todo" >"$tmpdir/go.txt"; then
  echo "Expected go outcome for non-material review bookkeeping changes." >&2
  cat "$tmpdir/go.txt" >&2 || true
  exit 1
fi

grep -q "Overall outcome: go" "$tmpdir/go.txt"

python3 - <<'PY' "$todo"
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
text = text.replace(
    "one collection envelope for every targeted surface",
    "several envelope families may still coexist",
    1,
)
path.write_text(text, encoding="utf-8")
PY

if python3 "$TOOL" --todo "$todo" >"$tmpdir/no_go.txt"; then
  echo "Expected no-go outcome when a material section drifts." >&2
  cat "$tmpdir/no_go.txt" >&2 || true
  exit 1
fi

grep -q "REVIEW-SCOPE-DRIFT-MATERIAL-CHANGE" "$tmpdir/no_go.txt"
grep -q "Architecture Change Governance" "$tmpdir/no_go.txt"
grep -q "not a hard rejection" "$tmpdir/no_go.txt"
grep -q "revalidate the evolved scope with the user" "$tmpdir/no_go.txt"

python3 - <<'PY' "$todo"
from pathlib import Path
import sys
path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
text = text.replace("several envelope families may still coexist", "one collection envelope for every targeted surface", 1)
text = text.replace("**Mode:** `current-scope-only`", "**Mode:** `bounded-anticipatory-extensibility`", 1)
path.write_text(text, encoding="utf-8")
PY
if python3 "$TOOL" --todo "$todo" >"$tmpdir/horizon_no_go.txt"; then
  echo "Expected no-go outcome when only the implementation horizon drifts." >&2
  exit 1
fi
grep -q "Implementation Horizon & Extensibility Intent" "$tmpdir/horizon_no_go.txt"

python3 - <<'PY' "$todo"
from pathlib import Path
import sys
path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
text = text.replace("**Mode:** `bounded-anticipatory-extensibility`", "**Mode:** `current-scope-only`", 1)
text = text.replace("## Implementation Horizon & Extensibility Intent", "## implementation horizon & extensibility intent", 1)
text = text.replace("**Rationale:** baseline contract", "**Rationale:** lowercase heading drift", 1)
path.write_text(text, encoding="utf-8")
PY
if python3 "$TOOL" --todo "$todo" >"$tmpdir/lowercase_horizon_no_go.txt"; then
  echo "Expected no-go outcome for lowercase implementation-horizon drift." >&2
  exit 1
fi
grep -q "Implementation Horizon & Extensibility Intent" "$tmpdir/lowercase_horizon_no_go.txt"

python3 - <<'PY' "$todo"
from pathlib import Path
import sys
path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
text = text.replace("## implementation horizon & extensibility intent", "## Implementation Horizon & Extensibility Intent (Required)", 1)
text = text.replace("**Rationale:** lowercase heading drift", "**Rationale:** suffixed heading drift", 1)
path.write_text(text, encoding="utf-8")
PY
if python3 "$TOOL" --todo "$todo" >"$tmpdir/suffixed_horizon_no_go.txt"; then
  echo "Expected no-go outcome for suffixed implementation-horizon drift." >&2
  exit 1
fi
grep -q "Implementation Horizon & Extensibility Intent" "$tmpdir/suffixed_horizon_no_go.txt"

python3 - <<'PY' "$todo"
from pathlib import Path
import sys
path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
text = text.replace("## Implementation Horizon & Extensibility Intent (Required)", "## Implementation Horizon & Extensibility Intent", 1)
text = text.replace("**Rationale:** suffixed heading drift", "**Rationale:** baseline contract", 1)
text += '''\n### **Implementation Horizon & Extensibility Intent** (Required)
- **Mode:** `current-scope-only`
- **Current delivery:** keep the original bounded slice
- **Explicit future cases informing the design:** `none`
- **Anticipatory implementation authorized now:** `none`
- **Not authorized now:** speculative expansion
- **Rationale:** duplicate authority
'''
path.write_text(text, encoding="utf-8")
PY
if python3 "$TOOL" --todo "$todo" >"$tmpdir/duplicate_horizon_no_go.txt"; then
  echo "Expected no-go outcome for duplicate normalized implementation horizons." >&2
  exit 1
fi
grep -q "REVIEW-SCOPE-DRIFT-HORIZON-DUPLICATE" "$tmpdir/duplicate_horizon_no_go.txt"

echo "review_scope_drift_guard_test: PASS"
