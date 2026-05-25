#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOL="$ROOT_DIR/tools/rule_spirit_anti_pattern_scan.sh"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

REPO="$TMP_DIR/project"
OUTPUT="$TMP_DIR/scan.out"
mkdir -p "$REPO/flutter-app/lib/presentation" "$REPO/laravel-app/routes/api"

cat > "$REPO/flutter-app/lib/presentation/example_screen.dart" <<'EOF'
import 'package:app/infrastructure/dto/example_dto.dart';

void open(context) {
  Navigator.of(context).pushNamed('/example');
}
EOF

cat > "$REPO/.env" <<'EOF'
SECRET_TOKEN=do-not-print
EOF

bash "$TOOL" --repo "$REPO" --stack flutter >"$OUTPUT"
grep -q "presentation/application importing infrastructure or DTO surfaces" "$OUTPUT"
grep -q "imperative Navigator usage" "$OUTPUT"
! grep -q "do-not-print" "$OUTPUT"

if bash "$TOOL" --repo "$REPO" --stack flutter --fail-on-findings >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected --fail-on-findings to exit non-zero\n' >&2
  exit 1
fi

printf 'rule_spirit_anti_pattern_scan_test: OK\n'
