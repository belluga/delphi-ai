#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: github_promotion_contract_init.sh --output <path> --scope <dev-only|through-stage> [options]

Create a local-only promotion contract used by guarded commit/push/PR wrappers.
This helper does not perform promotion and does not modify CI.

Options:
  --output <path>                               Output JSON path.
  --scope <dev-only|through-stage>              Requested promotion scope.
  --gitlink-policy <forbidden|pipeline-only>    Default: forbidden.
  --bot-next-version-policy <forbidden|pipeline-owned-only>
                                                Default: forbidden for dev-only, pipeline-owned-only for through-stage.
  --docs-remote-promotion <forbidden|explicit-only>
                                                Default: forbidden.
  --ci-behavior-change-authorized <true|false>  Default: false.
  --ci-test-harness-change-authorized <true|false>
                                                Default: false.
  --promotion-behavior-change-authorized <true|false>
                                                Default: false.
  --required-dev-track <docker-bot-next-version|docker-source>=<ref>
                                                Optional, repeatable. Declares Docker `-> dev`
                                                tracks that must already be absorbed into
                                                `origin/dev` before any later `dev -> stage`
                                                action is allowed under this contract.
  -h, --help                                    Show this help text.
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

OUTPUT_PATH=""
SCOPE=""
GITLINK_POLICY="forbidden"
BOT_NEXT_VERSION_POLICY=""
DOCS_REMOTE_PROMOTION="forbidden"
CI_BEHAVIOR_CHANGE_AUTHORIZED="false"
CI_TEST_HARNESS_CHANGE_AUTHORIZED="false"
PROMOTION_BEHAVIOR_CHANGE_AUTHORIZED="false"
declare -a REQUIRED_DEV_TRACKS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --output)
      [ $# -ge 2 ] || die "missing value for --output"
      OUTPUT_PATH="$2"
      shift 2
      ;;
    --scope)
      [ $# -ge 2 ] || die "missing value for --scope"
      SCOPE="$2"
      shift 2
      ;;
    --gitlink-policy)
      [ $# -ge 2 ] || die "missing value for --gitlink-policy"
      GITLINK_POLICY="$2"
      shift 2
      ;;
    --bot-next-version-policy)
      [ $# -ge 2 ] || die "missing value for --bot-next-version-policy"
      BOT_NEXT_VERSION_POLICY="$2"
      shift 2
      ;;
    --docs-remote-promotion)
      [ $# -ge 2 ] || die "missing value for --docs-remote-promotion"
      DOCS_REMOTE_PROMOTION="$2"
      shift 2
      ;;
    --ci-behavior-change-authorized)
      [ $# -ge 2 ] || die "missing value for --ci-behavior-change-authorized"
      CI_BEHAVIOR_CHANGE_AUTHORIZED="$2"
      shift 2
      ;;
    --ci-test-harness-change-authorized)
      [ $# -ge 2 ] || die "missing value for --ci-test-harness-change-authorized"
      CI_TEST_HARNESS_CHANGE_AUTHORIZED="$2"
      shift 2
      ;;
    --promotion-behavior-change-authorized)
      [ $# -ge 2 ] || die "missing value for --promotion-behavior-change-authorized"
      PROMOTION_BEHAVIOR_CHANGE_AUTHORIZED="$2"
      shift 2
      ;;
    --required-dev-track)
      [ $# -ge 2 ] || die "missing value for --required-dev-track"
      REQUIRED_DEV_TRACKS+=("$2")
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

[ -n "$OUTPUT_PATH" ] || die "--output is required"
[ -n "$SCOPE" ] || die "--scope is required"

case "$SCOPE" in
  dev-only)
    MAX_LANE="dev"
    DEFAULT_BOT_POLICY="forbidden"
    ;;
  through-stage)
    MAX_LANE="stage"
    DEFAULT_BOT_POLICY="pipeline-owned-only"
    ;;
  *)
    die "unsupported --scope value: $SCOPE"
    ;;
esac

case "$GITLINK_POLICY" in
  forbidden|pipeline-only) ;;
  *) die "unsupported --gitlink-policy value: $GITLINK_POLICY" ;;
esac

if [ -z "$BOT_NEXT_VERSION_POLICY" ]; then
  BOT_NEXT_VERSION_POLICY="$DEFAULT_BOT_POLICY"
fi

case "$BOT_NEXT_VERSION_POLICY" in
  forbidden|pipeline-owned-only) ;;
  *) die "unsupported --bot-next-version-policy value: $BOT_NEXT_VERSION_POLICY" ;;
esac

case "$DOCS_REMOTE_PROMOTION" in
  forbidden|explicit-only) ;;
  *) die "unsupported --docs-remote-promotion value: $DOCS_REMOTE_PROMOTION" ;;
esac

case "$CI_BEHAVIOR_CHANGE_AUTHORIZED" in
  true|false) ;;
  *) die "unsupported --ci-behavior-change-authorized value: $CI_BEHAVIOR_CHANGE_AUTHORIZED" ;;
esac

case "$CI_TEST_HARNESS_CHANGE_AUTHORIZED" in
  true|false) ;;
  *) die "unsupported --ci-test-harness-change-authorized value: $CI_TEST_HARNESS_CHANGE_AUTHORIZED" ;;
esac

case "$PROMOTION_BEHAVIOR_CHANGE_AUTHORIZED" in
  true|false) ;;
  *) die "unsupported --promotion-behavior-change-authorized value: $PROMOTION_BEHAVIOR_CHANGE_AUTHORIZED" ;;
esac

if [ "${#REQUIRED_DEV_TRACKS[@]}" -gt 0 ] && [ "$SCOPE" != "through-stage" ]; then
  die "--required-dev-track is only valid when --scope through-stage"
fi

for track in "${REQUIRED_DEV_TRACKS[@]}"; do
  case "$track" in
    docker-bot-next-version=*|docker-source=*)
      ref_part="${track#*=}"
      [ -n "$ref_part" ] || die "--required-dev-track ref cannot be empty: $track"
      ;;
    *)
      die "unsupported --required-dev-track value: $track"
      ;;
  esac
done

mkdir -p "$(dirname "$OUTPUT_PATH")"

python3 - "$OUTPUT_PATH" "$SCOPE" "$MAX_LANE" "$GITLINK_POLICY" "$BOT_NEXT_VERSION_POLICY" "$DOCS_REMOTE_PROMOTION" "$CI_BEHAVIOR_CHANGE_AUTHORIZED" "$CI_TEST_HARNESS_CHANGE_AUTHORIZED" "$PROMOTION_BEHAVIOR_CHANGE_AUTHORIZED" "${REQUIRED_DEV_TRACKS[@]}" <<'PY'
import json
import os
import sys
from datetime import datetime, timezone

(
    output_path,
    scope,
    max_lane,
    gitlink_policy,
    bot_next_version_policy,
    docs_remote_promotion,
    ci_behavior_change_authorized,
    ci_test_harness_change_authorized,
    promotion_behavior_change_authorized,
    *required_dev_tracks_raw,
) = sys.argv[1:]

required_dev_tracks = []
for raw in required_dev_tracks_raw:
    kind, ref = raw.split("=", 1)
    required_dev_tracks.append(
        {
            "kind": kind,
            "ref": ref,
        }
    )

payload = {
    "schema_version": 1,
    "created_at_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "created_by": "github_promotion_contract_init.sh",
    "scope": scope,
    "max_lane": max_lane,
    "gitlink_policy": gitlink_policy,
    "bot_next_version_policy": bot_next_version_policy,
    "docs_remote_promotion": docs_remote_promotion,
    "ci_behavior_change_authorized": ci_behavior_change_authorized == "true",
    "ci_test_harness_change_authorized": ci_test_harness_change_authorized == "true",
    "promotion_behavior_change_authorized": promotion_behavior_change_authorized == "true",
    "required_dev_tracks": required_dev_tracks,
}

with open(output_path, "w", encoding="utf-8") as fh:
    json.dump(payload, fh, indent=2, sort_keys=True)
    fh.write("\n")
PY

printf 'Promotion contract created\n'
printf '  path: %s\n' "$OUTPUT_PATH"
printf '  scope: %s\n' "$SCOPE"
printf '  max_lane: %s\n' "$MAX_LANE"
printf '  gitlink_policy: %s\n' "$GITLINK_POLICY"
printf '  bot_next_version_policy: %s\n' "$BOT_NEXT_VERSION_POLICY"
printf '  docs_remote_promotion: %s\n' "$DOCS_REMOTE_PROMOTION"
printf '  ci_behavior_change_authorized: %s\n' "$CI_BEHAVIOR_CHANGE_AUTHORIZED"
printf '  ci_test_harness_change_authorized: %s\n' "$CI_TEST_HARNESS_CHANGE_AUTHORIZED"
printf '  promotion_behavior_change_authorized: %s\n' "$PROMOTION_BEHAVIOR_CHANGE_AUTHORIZED"
if [ "${#REQUIRED_DEV_TRACKS[@]}" -eq 0 ]; then
  printf '  required_dev_tracks: none\n'
else
  printf '  required_dev_tracks:\n'
  for track in "${REQUIRED_DEV_TRACKS[@]}"; do
    printf '    - %s\n' "$track"
  done
fi
printf '\nOverall outcome: ready\n'
