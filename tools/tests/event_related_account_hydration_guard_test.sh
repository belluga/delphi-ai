#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOL="$ROOT_DIR/tools/event_related_account_hydration_guard.py"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

OUTPUT_FILE="$TMP_DIR/event-related-account-hydration-guard.out"
JSON_OUT="$TMP_DIR/event-related-account-hydration-guard.json"

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
  "laravel-app/packages/belluga/belluga_events/src/Application/Events/EventQueryService.php" "<?php

final class EventQueryService
{
    public function formatEventDetail(object \$event): array
    {
        return [
            'event_id' => 'evt-1',
            'profile_tabs' => [
                ['tab_id' => 'music', 'label' => 'Music'],
            ],
        ];
    }

    private function formatPublicDetailPayload(object \$event): array
    {
        return [
            'event_id' => 'evt-1',
            'profile_tabs' => [
                ['tab_id' => 'music', 'label' => 'Music'],
            ],
        ];
    }

    public function formatManagementEvent(object \$event): array
    {
        \$linked = \$this->resolveLinkedAccountProfiles([]);

        return [
            'linked_account_profiles' => \$linked,
        ];
    }
}
" \
  "laravel-app/app/Application/AccountProfiles/AccountProfileFormatterService.php" "<?php

final class AccountProfileFormatterService
{
    public function format(object \$profile, bool \$includeAgendaOccurrences = false): array
    {
        return [
            'id' => 'acc-1',
            'nested_profile_groups' => [
                [
                    'id' => 'partners',
                    'label' => 'Partners',
                    'order' => 0,
                    'members_path' => '/api/v1/account_profiles/acc-1/nested_profile_groups/partners/members',
                ],
            ],
        ];
    }
}
" \
  "laravel-app/app/Application/AccountProfiles/AccountProfileNestedPublicMembersProjectionService.php" "<?php

final class AccountProfileNestedPublicMembersProjectionService
{
    public function publicDetailGroups(object \$profile): array
    {
        return [
            [
                'id' => 'partners',
                'label' => 'Partners',
                'order' => 0,
                'members_path' => '/api/v1/account_profiles/acc-1/nested_profile_groups/partners/members',
            ],
        ];
    }
}
" \
  "laravel-app/app/Application/AccountProfiles/AccountProfileNestedGroupService.php" "<?php

final class AccountProfileNestedGroupService
{
    public function formatForRead(array \$groups): array
    {
        return \$groups;
    }
}
"

assert_go "$PASS_REPO"
grep -q "metadata-only" "$OUTPUT_FILE"
python3 - "$JSON_OUT" <<'PY'
import json
import sys
from pathlib import Path

payload = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
assert payload["blocked"] is False
assert payload["violations"] == []
print("event_related_account_hydration_guard_pass_case: OK")
PY

FAIL_REPO="$TMP_DIR/fail-repo"
make_repo "$FAIL_REPO" \
  "laravel-app/packages/belluga/belluga_events/src/Application/Events/EventQueryService.php" "<?php

final class EventQueryService
{
    public function formatEventDetail(object \$event): array
    {
        \$linked = \$this->resolveLinkedAccountProfiles([]);

        return [
            'event_id' => 'evt-1',
            'linked_account_profiles' => \$linked,
        ];
    }
}
"

assert_no_go "$FAIL_REPO"
grep -q "EVENT-DETAIL-HYDRATION-ROWS" "$OUTPUT_FILE"
grep -q "Hydrate nested-account rows only after the user opens a tab/group" "$OUTPUT_FILE"

FAIL_GROUP_REPO="$TMP_DIR/fail-group-repo"
make_repo "$FAIL_GROUP_REPO" \
  "laravel-app/packages/belluga/belluga_events/src/Application/Events/EventQueryService.php" "<?php

final class EventQueryService
{
    private function formatPublicDetailPayload(object \$event): array
    {
        \$payload = [
            'event_id' => 'evt-1',
            'profile_groups' => [],
        ];

        \$payload['profile_groups'] = \$this->hydratePublicProfileGroupsFromLinkedProfiles(
            \$payload['profile_groups'],
            []
        );

        return \$payload;
    }
}
"

assert_no_go "$FAIL_GROUP_REPO"
grep -q "groups-from-linked-profiles" "$OUTPUT_FILE"
grep -q "tab/group open -> paginated canonical \`accounts_nested\` read" "$OUTPUT_FILE"

FAIL_ACCOUNT_FORMATTER_REPO="$TMP_DIR/fail-account-formatter-repo"
make_repo "$FAIL_ACCOUNT_FORMATTER_REPO" \
  "laravel-app/app/Application/AccountProfiles/AccountProfileFormatterService.php" "<?php

final class AccountProfileFormatterService
{
    public function format(object \$profile, bool \$includeAgendaOccurrences = false): array
    {
        \$groups = \$this->nestedGroupMemberStore->metadataGroups(\$profile);
        \$groups = array_map(
            fn (array \$group): array => [
                ...\$group,
                'account_profile_ids' => \$this->nestedGroupMemberStore->groupMemberIds(\$profile, (string) (\$group['id'] ?? '')),
            ],
            \$groups,
        );
        \$summaries = \$this->candidateDiscoveryService->selectedSummariesByIds(['acc-1']);

        return [
            'nested_profile_groups' => \$this->nestedGroupService->withSelectedSummaries(\$groups, \$summaries),
        ];
    }
}
"

assert_no_go "$FAIL_ACCOUNT_FORMATTER_REPO"
grep -q "ACCOUNT-DETAIL-HYDRATION-ROWS" "$OUTPUT_FILE"
grep -q "Initial Account Detail hydration resolves nested member ids" "$OUTPUT_FILE"

FAIL_ACCOUNT_PROJECTION_REPO="$TMP_DIR/fail-account-projection-repo"
make_repo "$FAIL_ACCOUNT_PROJECTION_REPO" \
  "laravel-app/app/Application/AccountProfiles/AccountProfileNestedPublicMembersProjectionService.php" "<?php

final class AccountProfileNestedPublicMembersProjectionService
{
    public function publicDetailGroups(object \$profile): array
    {
        return [
            [
                'id' => 'partners',
                'label' => 'Partners',
                'order' => 0,
                'profiles' => \$this->groupProfiles('tenant-1', 'acc-1', 'partners'),
            ],
        ];
    }
}
"

assert_no_go "$FAIL_ACCOUNT_PROJECTION_REPO"
grep -q "ACCOUNT-DETAIL-HYDRATION-ROWS" "$OUTPUT_FILE"
grep -q "embeds nested member rows in the initial detail payload" "$OUTPUT_FILE"

FAIL_ACCOUNT_GROUP_SERVICE_REPO="$TMP_DIR/fail-account-group-service-repo"
make_repo "$FAIL_ACCOUNT_GROUP_SERVICE_REPO" \
  "laravel-app/app/Application/AccountProfiles/AccountProfileNestedGroupService.php" "<?php

final class AccountProfileNestedGroupService
{
    public function formatForPublicDetail(object \$profile, string \$baseUrl, object \$policy): array
    {
        \$profiles = [
            \$this->formatLinkedProfile(\$profile, \$baseUrl, \$policy),
        ];

        return [
            [
                'id' => 'partners',
                'label' => 'Partners',
                'profiles' => \$profiles,
            ],
        ];
    }
}
"

assert_no_go "$FAIL_ACCOUNT_GROUP_SERVICE_REPO"
grep -q "ACCOUNT-DETAIL-HYDRATION-ROWS" "$OUTPUT_FILE"
grep -q "metadata-only" "$OUTPUT_FILE"

printf 'event_related_account_hydration_guard_test: OK\n'
