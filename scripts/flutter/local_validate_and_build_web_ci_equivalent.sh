#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${1:-/tmp/flutter-web-ci-build}"

cd "$ROOT_DIR"

fvm install
fvm flutter --version
fvm flutter pub get
fvm dart pub get --directory tool/belluga_analysis_plugin/test_fixtures/lint_matrix
bash tool/belluga_analysis_plugin/bin/validate_rule_matrix.sh
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
