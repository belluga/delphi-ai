#!/usr/bin/env bash

promotion_contract_load() {
  local contract_path="$1"

  if [ ! -f "$contract_path" ]; then
    printf 'Error: contract file not found: %s\n' "$contract_path" >&2
    return 1
  fi

  local contract_values
  contract_values="$(
    python3 - "$contract_path" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path, "r", encoding="utf-8") as fh:
    data = json.load(fh)

def b(value):
    return "true" if bool(value) else "false"

print("\t".join([
    str(data.get("schema_version", "")),
    str(data.get("scope", "")),
    str(data.get("max_lane", "")),
    str(data.get("gitlink_policy", "")),
    str(data.get("bot_next_version_policy", "")),
    str(data.get("docs_remote_promotion", "")),
    b(data.get("ci_behavior_change_authorized", False)),
    b(data.get("promotion_behavior_change_authorized", False)),
]))
PY
  )" || return 1

  IFS=$'\t' read -r \
    PROMOTION_CONTRACT_SCHEMA_VERSION \
    PROMOTION_CONTRACT_SCOPE \
    PROMOTION_CONTRACT_MAX_LANE \
    PROMOTION_CONTRACT_GITLINK_POLICY \
    PROMOTION_CONTRACT_BOT_NEXT_VERSION_POLICY \
    PROMOTION_CONTRACT_DOCS_REMOTE_PROMOTION \
    PROMOTION_CONTRACT_CI_BEHAVIOR_CHANGE_AUTHORIZED \
    PROMOTION_CONTRACT_PROMOTION_BEHAVIOR_CHANGE_AUTHORIZED \
    <<< "$contract_values"

  case "$PROMOTION_CONTRACT_SCHEMA_VERSION" in
    1) ;;
    *)
      printf 'Error: unsupported promotion contract schema_version: %s\n' "$PROMOTION_CONTRACT_SCHEMA_VERSION" >&2
      return 1
      ;;
  esac

  case "$PROMOTION_CONTRACT_SCOPE" in
    dev-only|through-stage) ;;
    *)
      printf 'Error: unsupported promotion contract scope: %s\n' "$PROMOTION_CONTRACT_SCOPE" >&2
      return 1
      ;;
  esac

  case "$PROMOTION_CONTRACT_MAX_LANE" in
    dev|stage) ;;
    *)
      printf 'Error: unsupported promotion contract max_lane: %s\n' "$PROMOTION_CONTRACT_MAX_LANE" >&2
      return 1
      ;;
  esac

  case "$PROMOTION_CONTRACT_GITLINK_POLICY" in
    forbidden|pipeline-only) ;;
    *)
      printf 'Error: unsupported promotion contract gitlink_policy: %s\n' "$PROMOTION_CONTRACT_GITLINK_POLICY" >&2
      return 1
      ;;
  esac

  case "$PROMOTION_CONTRACT_BOT_NEXT_VERSION_POLICY" in
    forbidden|pipeline-owned-only) ;;
    *)
      printf 'Error: unsupported promotion contract bot_next_version_policy: %s\n' "$PROMOTION_CONTRACT_BOT_NEXT_VERSION_POLICY" >&2
      return 1
      ;;
  esac

  case "$PROMOTION_CONTRACT_DOCS_REMOTE_PROMOTION" in
    forbidden|explicit-only) ;;
    *)
      printf 'Error: unsupported promotion contract docs_remote_promotion: %s\n' "$PROMOTION_CONTRACT_DOCS_REMOTE_PROMOTION" >&2
      return 1
      ;;
  esac
}
