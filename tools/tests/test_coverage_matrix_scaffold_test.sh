#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOL="$ROOT_DIR/tools/test_coverage_matrix_scaffold.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

DEFAULT_OUTPUT="$TMP_DIR/default.md"
bash "$TOOL" \
  --intent unit-regression \
  --strategy test-first \
  --platform-matrix server \
  --behavior "change a provider contract" \
  --output "$DEFAULT_OUTPUT"

grep -q '| Unit / provider / component |' "$DEFAULT_OUTPUT"
grep -q '| Integration / module / adapter |' "$DEFAULT_OUTPUT"
grep -q '| Broad project CI-equivalent closeout |' "$DEFAULT_OUTPUT"
if grep -Eq 'Laravel|Flutter|Mongo|Web bundle|Mobile device' "$DEFAULT_OUTPUT"; then
  printf 'default scaffold leaked a stack-specific gate\n' >&2
  exit 1
fi

CUSTOM_OUTPUT="$TMP_DIR/custom.md"
bash "$TOOL" \
  --intent compatibility \
  --strategy test-after \
  --platform-matrix api \
  --behavior "change a module boundary" \
  --layer "Nest provider unit" \
  --layer "Nest testing-module integration" \
  --prerequisite "Owning API package manifest" \
  --stage "API package test script" \
  --output "$CUSTOM_OUTPUT"

grep -q '| Nest provider unit |' "$CUSTOM_OUTPUT"
grep -q '| Nest testing-module integration |' "$CUSTOM_OUTPUT"
grep -q -- '- Owning API package manifest: TODO' "$CUSTOM_OUTPUT"
grep -q '| API package test script |' "$CUSTOM_OUTPUT"
if grep -q '| Static / contract |' "$CUSTOM_OUTPUT"; then
  printf 'custom layers did not replace defaults\n' >&2
  exit 1
fi

printf 'test_coverage_matrix_scaffold_test: OK\n'
