#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOL="$ROOT_DIR/tools/test_quality_audit.sh"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

REPO="$TMP_DIR/repo"
mkdir -p "$REPO/tools/flutter/web_app_tests" "$REPO/tests"

cat > "$REPO/tools/flutter/web_app_tests/clean.spec.js" <<'EOF'
async function choose(page) {
  await page.getByRole('option', { name: 'Deterministic Host' }).click();
}
EOF

OUTPUT="$TMP_DIR/clean.out"
bash "$TOOL" --repo "$REPO" --path tools/flutter/web_app_tests >"$OUTPUT"
grep -q "Outcome heuristic: none" "$OUTPUT"
grep -q "Ambient subject fallback hints:" "$OUTPUT"
grep -q "ambient_subject_fallback=0" "$OUTPUT"

cat > "$REPO/tools/flutter/web_app_tests/ambient.spec.js" <<'EOF'
async function choose(rows, hostCandidates, minimum) {
  const profile = rows[0];
  const host = hostCandidates[0];
  return {
    profile,
    host,
    candidates: candidates.slice(0, minimum),
  };
}
EOF

if bash "$TOOL" --repo "$REPO" --path tools/flutter/web_app_tests >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected ambient subject fallback hints to raise medium severity\n' >&2
  exit 1
fi

grep -q "Outcome heuristic: medium" "$OUTPUT"
grep -q "Ambient subject fallback hints:" "$OUTPUT"
grep -q "2:  const profile = rows\\[0\\];" "$OUTPUT"
grep -q "3:  const host = hostCandidates\\[0\\];" "$OUTPUT"
grep -q "7:    candidates: candidates.slice(0, minimum)," "$OUTPUT"
grep -q "ambient_subject_fallback=3" "$OUTPUT"

printf 'test_quality_audit_test: OK\n'
