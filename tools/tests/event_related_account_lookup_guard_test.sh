#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOL="$ROOT_DIR/tools/event_related_account_lookup_guard.py"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

OUTPUT_FILE="$TMP_DIR/event-related-account-lookup-guard.out"
JSON_OUT="$TMP_DIR/event-related-account-lookup-guard.json"

assert_go() {
  local repo_root="$1"
  python3 "$TOOL" --repo "$repo_root" --json-output "$JSON_OUT" > "$OUTPUT_FILE" 2>&1
  grep -q "Overall outcome: go" "$OUTPUT_FILE"
}

assert_no_go() {
  local repo_root="$1"
  if python3 "$TOOL" --repo "$repo_root" --json-output "$JSON_OUT" > "$OUTPUT_FILE" 2>&1; then
    cat "$OUTPUT_FILE"
    printf 'expected no-go for %s\n' "$repo_root" >&2
    exit 1
  fi
  grep -q "Overall outcome: no-go" "$OUTPUT_FILE"
}

make_repo() {
  local root="$1"
  shift
  while [ "$#" -gt 1 ]; do
    local relative_path="$1"
    local contents="$2"
    shift 2
    local absolute_path="$root/$relative_path"
    mkdir -p "$(dirname "$absolute_path")"
    printf '%s' "$contents" > "$absolute_path"
  done
}

PASS_REPO="$TMP_DIR/pass-repo"
make_repo "$PASS_REPO" \
  "laravel-app/packages/belluga/belluga_events/src/Application/Events/AllowedLookup.php" "<?php

use Belluga\\Events\\Models\\Tenants\\Event;
use Belluga\\Events\\Models\\Tenants\\EventOccurrence;

final class AllowedLookup
{
    public function loadOccurrenceOwnedRows(string \$eventId): array
    {
        \$event = Event::query()->where('_id', \$eventId)->first();

        return EventOccurrence::query()
            ->where('event_id', \$eventId)
            ->get()
            ->all();
    }
}
" \
  "laravel-app/app/Application/Accounts/AllowedNestedLookup.php" "<?php

final class AllowedNestedLookup
{
    public function loadRows(): array
    {
        return [['parent_type' => 'event_occurrence']];
    }
}
"

assert_go "$PASS_REPO"
grep -q "Event context may originate related-account lookup" "$OUTPUT_FILE"
python3 - "$JSON_OUT" <<'PY'
import json
import sys
from pathlib import Path

payload = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
assert payload["blocked"] is False
assert payload["violations"] == []
print("event_related_account_lookup_guard_pass_case: OK")
PY

EVENT_TARGET_REPO="$TMP_DIR/event-target-repo"
make_repo "$EVENT_TARGET_REPO" \
  "laravel-app/packages/belluga/belluga_events/src/Application/Events/BrokenEventLookup.php" "<?php

use Belluga\\Events\\Models\\Tenants\\Event;

final class BrokenEventLookup
{
    public function findByRelatedProfile(string \$profileId): array
    {
        return Event::query()
            ->whereRaw([
                'event_parties' => [
                    '\$elemMatch' => [
                        'party_ref_id' => ['\$in' => [\$profileId]],
                    ],
                ],
            ])
            ->get()
            ->all();
    }
}
"

assert_no_go "$EVENT_TARGET_REPO"
grep -q "EVENT-TARGET-RELATED-LOOKUP" "$OUTPUT_FILE"
grep -q "Event-primary query code targets Event relation ownership" "$OUTPUT_FILE"

PARENT_TYPE_REPO="$TMP_DIR/parent-type-repo"
make_repo "$PARENT_TYPE_REPO" \
  "laravel-app/app/Application/Accounts/BrokenNestedLookup.php" "<?php

final class BrokenNestedLookup
{
    public function loadRows(): array
    {
        return \\App\\Models\\Tenants\\AccountsNested::query()
            ->where('parent_type', 'event')
            ->get()
            ->all();
    }
}
"

assert_no_go "$PARENT_TYPE_REPO"
grep -q "NESTED-PARENT-TYPE-EVENT" "$OUTPUT_FILE"
grep -q "parent_type=event" "$OUTPUT_FILE"

printf 'event_related_account_lookup_guard_test: OK\n'
