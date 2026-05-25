#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOL="$ROOT_DIR/tools/rule_spirit_anti_pattern_scan.sh"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

REPO="$TMP_DIR/project"
OUTPUT="$TMP_DIR/scan.out"
JSON_OUTPUT="$TMP_DIR/scan.json"
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
grep -q "Max active severity: warning" "$OUTPUT"
! grep -q "do-not-print" "$OUTPUT"

if bash "$TOOL" --repo "$REPO" --stack flutter --fail-on-findings >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected --fail-on-findings to exit non-zero\n' >&2
  exit 1
fi

bash "$TOOL" --repo "$REPO" --stack flutter --json-output "$JSON_OUTPUT" >"$OUTPUT"
NAVIGATOR_KEY="$(
  python3 - "$JSON_OUTPUT" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    data = json.load(handle)

assert data["schema_version"] == "rule-spirit-scan-v1"
assert data["finding_count"] >= 2
assert data["active_finding_count"] == data["finding_count"]
assert data["allowlisted_finding_count"] == 0
assert data["max_active_severity"] == "warning"
for finding in data["findings"]:
    if "imperative Navigator usage" in finding["lens"]:
        print(finding["key"])
        break
else:
    raise AssertionError("Navigator finding not found")
PY
)"

ALLOWLIST="$TMP_DIR/rule-spirit.allowlist.tsv"
cat > "$ALLOWLIST" <<EOF
finding_key	owner	expires_utc	reason
$NAVIGATOR_KEY	delphi-test	2099-12-31	temporary fixture exception
EOF

bash "$TOOL" --repo "$REPO" --stack flutter --allowlist "$ALLOWLIST" --json-output "$JSON_OUTPUT" >"$OUTPUT"
grep -q "Allowlisted findings: 1" "$OUTPUT"
grep -q "Allowlisted Findings" "$OUTPUT"
python3 - "$JSON_OUTPUT" "$NAVIGATOR_KEY" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    data = json.load(handle)

key = sys.argv[2]
assert data["finding_count"] >= 2
assert data["allowlisted_finding_count"] == 1
assert data["active_finding_count"] == data["finding_count"] - 1
match = next(item for item in data["findings"] if item["key"] == key)
assert match["allowed"] is True
assert match["allowlist"]["owner"] == "delphi-test"
assert match["allowlist"]["status"] == "active"
PY

EXPIRED_ALLOWLIST="$TMP_DIR/rule-spirit.expired.allowlist.tsv"
cat > "$EXPIRED_ALLOWLIST" <<EOF
finding_key	owner	expires_utc	reason
$NAVIGATOR_KEY	delphi-test	2000-01-01	expired fixture exception
EOF

bash "$TOOL" --repo "$REPO" --stack flutter --allowlist "$EXPIRED_ALLOWLIST" --json-output "$JSON_OUTPUT" >"$OUTPUT"
grep -q "Expired allowlist matches: 1" "$OUTPUT"
python3 - "$JSON_OUTPUT" "$NAVIGATOR_KEY" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    data = json.load(handle)

key = sys.argv[2]
assert data["allowlisted_finding_count"] == 0
assert data["active_finding_count"] == data["finding_count"]
match = next(item for item in data["findings"] if item["key"] == key)
assert match["allowed"] is False
assert match["allowlist"]["status"] == "expired"
PY

mkdir -p "$REPO/tools"
printf '%s%s %s %s %s\n' "for" "ce" "pass" "delivery" "gate" > "$REPO/tools/release.sh"
if bash "$TOOL" --repo "$REPO" --stack all --path tools --fail-on-severity blocker --json-output "$JSON_OUTPUT" >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected --fail-on-severity blocker to exit non-zero\n' >&2
  exit 1
fi

python3 - "$JSON_OUTPUT" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    data = json.load(handle)

assert data["max_active_severity"] == "blocker"
assert any(item["severity"] == "blocker" for item in data["findings"])
PY

printf 'rule_spirit_anti_pattern_scan_test: OK\n'
