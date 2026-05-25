#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${1:-/tmp/flutter-web-ci-build}"
GLOBAL_ANALYZER_PLUGIN_DIR="${PACED_GLOBAL_ANALYZER_PLUGIN_DIR:-tool/belluga_analysis_plugin}"
RULE_MATRIX_FIXTURE_DIR="${PACED_ANALYZER_RULE_MATRIX_FIXTURE_DIR:-${GLOBAL_ANALYZER_PLUGIN_DIR}/test_fixtures/lint_matrix}"
RULE_MATRIX_COMMAND="${PACED_ANALYZER_RULE_MATRIX_COMMAND:-${GLOBAL_ANALYZER_PLUGIN_DIR}/bin/validate_rule_matrix.sh}"
RULE_MATRIX_REQUIRED="${PACED_ANALYZER_RULE_MATRIX_REQUIRED:-1}"

cd "$ROOT_DIR"

fvm install
fvm flutter --version
fvm flutter pub get
if [[ -d "$RULE_MATRIX_FIXTURE_DIR" && -f "$RULE_MATRIX_COMMAND" ]]; then
  fvm dart pub get --directory "$RULE_MATRIX_FIXTURE_DIR"
  bash "$RULE_MATRIX_COMMAND"
elif [[ "$RULE_MATRIX_REQUIRED" == "1" ]]; then
  echo "ERROR: PACED analyzer rule-matrix validation is required but the configured plugin surfaces were not found." >&2
  echo "Expected fixture dir: $RULE_MATRIX_FIXTURE_DIR" >&2
  echo "Expected command: $RULE_MATRIX_COMMAND" >&2
  echo "Resolution: install the ecosystem-global analyzer plugin at tool/belluga_analysis_plugin, set PACED_GLOBAL_ANALYZER_PLUGIN_DIR, or document and explicitly waive rule-matrix validation for this project lane." >&2
  exit 1
else
  echo "INFO: PACED analyzer rule-matrix validation skipped; configured plugin surfaces were not found and PACED_ANALYZER_RULE_MATRIX_REQUIRED=$RULE_MATRIX_REQUIRED."
fi
fvm dart analyze --format machine
fvm flutter test --no-pub \
  --exclude-tags=stage-compatibility \
  --dart-define-from-file=config/defines/dev.json

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

fvm flutter build web \
  --release \
  --no-tree-shake-icons \
  --dart-define-from-file=config/defines/dev.json \
  -o "$OUTPUT_DIR"
