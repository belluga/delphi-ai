#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOL="$SCRIPT_DIR/../review_scope_drift_guard.py"

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

## Definition of Done
- [ ] keep original scope stable during review

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

## Definition of Done
- [ ] keep original scope stable during review

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

echo "review_scope_drift_guard_test: PASS"
