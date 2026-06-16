#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: rule_spirit_anti_pattern_scan.sh [--repo <path>] [--stack <name>] [--path <path>] [--fail-on-findings]
                                       [--fail-on-severity <none|review|warning|blocker>]
                                       [--allowlist <path>] [--json-output <path>]

Heuristic support for the TODO delivery "Rule-Spirit Anti-Pattern Hunt" gate.
The scanner flags suspicious bypasses and stack-specific smells. It assigns
heuristic severities for triage, while human review still owns final P1/P2
judgment.

Allowlist format is tab-separated:
  finding_key<TAB>owner<TAB>expires_utc(YYYY-MM-DD)<TAB>reason

Allowlist entries are temporary: expired entries are reported as active findings.

Stacks: all, docker, flutter, laravel, go
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

command -v rg >/dev/null 2>&1 || die "ripgrep (rg) is required"
command -v sha256sum >/dev/null 2>&1 || die "sha256sum is required"

REPO_INPUT="."
FAIL_ON_SEVERITY="none"
ALLOWLIST_INPUT=""
ALLOWLIST_PATH=""
JSON_OUTPUT=""
declare -a STACKS=("all")
declare -a INPUT_PATHS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --repo)
      [ $# -ge 2 ] || die "missing value for --repo"
      REPO_INPUT="$2"
      shift 2
      ;;
    --stack)
      [ $# -ge 2 ] || die "missing value for --stack"
      if [ "${STACKS[0]}" = "all" ]; then
        STACKS=()
      fi
      STACKS+=("$2")
      shift 2
      ;;
    --path)
      [ $# -ge 2 ] || die "missing value for --path"
      INPUT_PATHS+=("$2")
      shift 2
      ;;
    --fail-on-findings)
      FAIL_ON_SEVERITY="review"
      shift
      ;;
    --fail-on-severity)
      [ $# -ge 2 ] || die "missing value for --fail-on-severity"
      case "$2" in
        none|review|warning|blocker) ;;
        *) die "unsupported severity threshold: $2" ;;
      esac
      FAIL_ON_SEVERITY="$2"
      shift 2
      ;;
    --allowlist)
      [ $# -ge 2 ] || die "missing value for --allowlist"
      ALLOWLIST_INPUT="$2"
      shift 2
      ;;
    --json-output)
      [ $# -ge 2 ] || die "missing value for --json-output"
      JSON_OUTPUT="$2"
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

REPO_ROOT="$(git -C "$REPO_INPUT" rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$REPO_ROOT" ]; then
  REPO_ROOT="$(cd "$REPO_INPUT" 2>/dev/null && pwd || true)"
fi
[ -n "$REPO_ROOT" ] || die "unable to resolve repository root from: $REPO_INPUT"

declare -a SCAN_PATHS=()
if [ "${#INPUT_PATHS[@]}" -eq 0 ]; then
  SCAN_PATHS=("$REPO_ROOT")
else
  for input in "${INPUT_PATHS[@]}"; do
    if [[ "$input" = /* ]]; then
      SCAN_PATHS+=("$input")
    else
      SCAN_PATHS+=("$REPO_ROOT/$input")
    fi
  done
fi

if [ -n "$ALLOWLIST_INPUT" ]; then
  if [[ "$ALLOWLIST_INPUT" = /* ]]; then
    ALLOWLIST_PATH="$ALLOWLIST_INPUT"
  else
    ALLOWLIST_PATH="$REPO_ROOT/$ALLOWLIST_INPUT"
  fi
  [ -f "$ALLOWLIST_PATH" ] || die "allowlist not found: $ALLOWLIST_PATH"
fi

if [ -n "$JSON_OUTPUT" ]; then
  command -v python3 >/dev/null 2>&1 || die "python3 is required for --json-output"
fi

for stack in "${STACKS[@]}"; do
  case "$stack" in
    all|docker|flutter|laravel|go) ;;
    *) die "unsupported stack: $stack" ;;
  esac
done

has_stack() {
  local wanted="$1"
  local stack
  for stack in "${STACKS[@]}"; do
    [ "$stack" = "all" ] && return 0
    [ "$stack" = "$wanted" ] && return 0
  done
  return 1
}

severity_rank() {
  case "$1" in
    none) printf '0\n' ;;
    review) printf '1\n' ;;
    warning) printf '2\n' ;;
    blocker) printf '3\n' ;;
    *) printf '0\n' ;;
  esac
}

validate_severity() {
  case "$1" in
    review|warning|blocker) ;;
    *) die "unsupported finding severity: $1" ;;
  esac
}

sanitize_field() {
  local value="$1"
  value="${value//$'\t'/ }"
  value="${value//$'\r'/ }"
  value="${value//$'\n'/ }"
  printf '%s' "$value"
}

markdown_escape() {
  local value="$1"
  value="${value//|/\\|}"
  printf '%s' "$value"
}

finding_key() {
  local stack="$1"
  local severity="$2"
  local lens="$3"
  local location="$4"
  local evidence="$5"
  printf '%s\t%s\t%s\t%s\t%s' "$stack" "$severity" "$lens" "$location" "$evidence" \
    | sha256sum \
    | awk '{print substr($1, 1, 16)}'
}

declare -A ALLOW_OWNER=()
declare -A ALLOW_EXPIRES=()
declare -A ALLOW_REASON=()
TODAY_UTC="$(date -u +%Y-%m-%d)"

load_allowlist() {
  [ -n "$ALLOWLIST_PATH" ] || return 0

  local line_no=0
  local key owner expires reason extra
  while IFS=$'\t' read -r key owner expires reason extra || [ -n "${key:-}" ]; do
    line_no=$((line_no + 1))
    key="${key%$'\r'}"
    owner="${owner:-}"
    expires="${expires:-}"
    reason="${reason:-}"
    extra="${extra:-}"

    [ -z "$key" ] && continue
    [[ "$key" =~ ^# ]] && continue
    [ "$key" = "finding_key" ] && continue

    [[ "$key" =~ ^[A-Fa-f0-9]{16,64}$ ]] || die "invalid allowlist key at $ALLOWLIST_PATH:$line_no"
    [ -n "$owner" ] || die "missing allowlist owner at $ALLOWLIST_PATH:$line_no"
    [[ "$expires" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || die "invalid allowlist expiration at $ALLOWLIST_PATH:$line_no"
    [ -n "$reason" ] || die "missing allowlist reason at $ALLOWLIST_PATH:$line_no"
    [ -z "$extra" ] || die "too many allowlist fields at $ALLOWLIST_PATH:$line_no"

    ALLOW_OWNER["$key"]="$owner"
    ALLOW_EXPIRES["$key"]="$expires"
    ALLOW_REASON["$key"]="$reason"
  done <"$ALLOWLIST_PATH"
}

TMP_FINDINGS="$(mktemp)"
TMP_HELPER="$(mktemp)"
trap 'rm -f "$TMP_FINDINGS" "$TMP_HELPER"' EXIT

load_allowlist

record() {
  local stack="$1"
  local severity="$2"
  local lens="$3"
  local location="$4"
  local evidence="$5"
  local key allowed="false" owner="" expires="" reason="" status="none"

  validate_severity "$severity"
  stack="$(sanitize_field "$stack")"
  severity="$(sanitize_field "$severity")"
  lens="$(sanitize_field "$lens")"
  location="$(sanitize_field "$location")"
  evidence="$(sanitize_field "${evidence:0:180}")"
  key="$(finding_key "$stack" "$severity" "$lens" "$location" "$evidence")"

  if [ -n "${ALLOW_OWNER[$key]+set}" ]; then
    owner="${ALLOW_OWNER[$key]}"
    expires="${ALLOW_EXPIRES[$key]}"
    reason="${ALLOW_REASON[$key]}"
    if [[ "$expires" < "$TODAY_UTC" ]]; then
      status="expired"
    else
      allowed="true"
      status="active"
    fi
  fi

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$key" "$stack" "$severity" "$lens" "$location" "$evidence" \
    "$allowed" "$owner" "$expires" "$reason" "$status" >>"$TMP_FINDINGS"
}

scan_rg() {
  local stack="$1"
  local severity="$2"
  local lens="$3"
  local pattern="$4"
  shift 4
  local -a globs=("$@")
  local -a rg_args=(
    --no-heading
    --line-number
    --color never
    --hidden
    --glob '!.git/**'
    --glob '!node_modules/**'
    --glob '!vendor/**'
    --glob '!build/**'
    --glob '!.dart_tool/**'
    --glob '!storage/**'
    --glob '!foundation_documentation/**'
    --glob '!delphi-ai/.git/**'
  )
  local glob
  for glob in "${globs[@]}"; do
    rg_args+=(--glob "$glob")
  done

  while IFS=: read -r file line text; do
    [ -n "${file:-}" ] || continue
    local rel="${file#$REPO_ROOT/}"
    record "$stack" "$severity" "$lens" "$rel:$line" "${text:0:180}"
  done < <(rg "${rg_args[@]}" "$pattern" "${SCAN_PATHS[@]}" 2>/dev/null || true)
}

scan_helper() {
  local stack="$1"
  local severity="$2"
  local lens="$3"
  shift 3
  if "$@" >"$TMP_HELPER" 2>&1; then
    return 0
  fi
  local first_line
  first_line="$(sed -n '1p' "$TMP_HELPER")"
  record "$stack" "$severity" "$lens" "$*" "${first_line:-helper reported findings}"
}

scan_rg "shared" "blocker" "explicit delivery gate bypass marker" 'force[-_ ]+(pass|green)[-_ ]+(delivery|todo)[-_ ]+(gate|guard)|merge[-_ ]+despite[-_ ]+(p1|p2)|todo_(completion|authority)_guard[-_ ]+(bypass|disable)[-_ ]+(mode|flag|override)' '*.dart' '*.php' '*.go' '*.js' '*.ts' '*.sh' '*.md'
scan_rg "shared" "review" "guard bypass or tactical workaround marker" '(TODO|FIXME|HACK).*(bypass|skip|ignore|disable|temporary|temporar|workaround|gambiarra)|((bypass|skip|ignore|disable).*(guard|rule|validation|test))' '*.dart' '*.php' '*.go' '*.js' '*.ts' '*.sh'
scan_rg "shared" "review" "hard-coded local/domain target in source/config" '(localhost|127\.0\.0\.1|host\.docker\.internal|[A-Za-z0-9.-]+\.test)' '*.dart' '*.php' '*.go' '*.js' '*.ts' '*.yaml' '*.yml'

if has_stack flutter; then
  scan_rg "flutter" "warning" "presentation/application importing infrastructure or DTO surfaces" 'import .*(infrastructure|dto)' '*.dart'
  scan_rg "flutter" "review" "imperative Navigator usage; verify route/controller boundary" '\bNavigator\.' '*.dart'
  scan_rg "flutter" "review" "FutureBuilder/StreamBuilder in app code; verify no IO/build side-effect bypass" '\b(FutureBuilder|StreamBuilder)\b' '*.dart'
fi

if has_stack laravel; then
  scan_rg "laravel" "warning" "post-fetch filtering exact lookup candidate" '->(get|paginate|cursorPaginate)\([^)]*\)\s*->\s*(firstWhere|where)\(' '*.php'
  scan_rg "laravel" "warning" "route auth without visible tenant guard candidate" 'auth:sanctum' '*.php'
  if [ -d "$REPO_ROOT/laravel-app/routes" ] && [ -x "$REPO_ROOT/delphi-ai/tools/laravel_tenant_access_guardrails_audit.sh" ]; then
    scan_helper "laravel" "warning" "tenant access guardrail helper reported findings" "$REPO_ROOT/delphi-ai/tools/laravel_tenant_access_guardrails_audit.sh" --repo "$REPO_ROOT"
  elif [ -d "$REPO_ROOT/laravel-app/routes" ] && [ -x "$(dirname "${BASH_SOURCE[0]}")/laravel_tenant_access_guardrails_audit.sh" ]; then
    scan_helper "laravel" "warning" "tenant access guardrail helper reported findings" "$(dirname "${BASH_SOURCE[0]}")/laravel_tenant_access_guardrails_audit.sh" --repo "$REPO_ROOT"
  fi
fi

if has_stack docker; then
  scan_rg "docker" "warning" "hard-coded runtime/domain target in Docker or compose surface" '(localhost|127\.0\.0\.1|host\.docker\.internal|[A-Za-z0-9.-]+\.test)' 'Dockerfile*' '*compose*.yml' '*compose*.yaml' 'docker-compose*.yml' 'docker-compose*.yaml'
fi

if has_stack go; then
  scan_rg "go" "review" "handler/service context shortcut candidate" '\bcontext\.Background\(\)' '*.go'
  scan_rg "go" "warning" "panic/TODO in service code candidate" '\bpanic\(|TODO.*(tenant|auth|validation|guard)' '*.go'
fi

count_findings() {
  local mode="$1"
  local count=0
  local key stack severity lens location evidence allowed owner expires reason status
  while IFS=$'\t' read -r key stack severity lens location evidence allowed owner expires reason status; do
    case "$mode" in
      all)
        count=$((count + 1))
        ;;
      active)
        [ "$allowed" = "true" ] || count=$((count + 1))
        ;;
      allowlisted)
        [ "$allowed" = "true" ] && count=$((count + 1))
        ;;
      expired)
        [ "$status" = "expired" ] && count=$((count + 1))
        ;;
      *)
        die "unsupported count mode: $mode"
        ;;
    esac
  done <"$TMP_FINDINGS"
  printf '%s\n' "$count"
}

max_active_severity() {
  local max_rank=0
  local max_severity="none"
  local key stack severity lens location evidence allowed owner expires reason status rank
  while IFS=$'\t' read -r key stack severity lens location evidence allowed owner expires reason status; do
    [ "$allowed" = "true" ] && continue
    rank="$(severity_rank "$severity")"
    if [ "$rank" -gt "$max_rank" ]; then
      max_rank="$rank"
      max_severity="$severity"
    fi
  done <"$TMP_FINDINGS"
  printf '%s\n' "$max_severity"
}

print_table_rows() {
  local mode="$1"
  local empty_lens="$2"
  local printed=0
  local key stack severity lens location evidence allowed owner expires reason status
  while IFS=$'\t' read -r key stack severity lens location evidence allowed owner expires reason status; do
    case "$mode" in
      active)
        [ "$allowed" = "true" ] && continue
        ;;
      allowlisted)
        [ "$allowed" = "true" ] || continue
        ;;
      all) ;;
      *) die "unsupported table mode: $mode" ;;
    esac
    printf '| %s | %s | %s | `%s` | %s |\n' \
      "$(markdown_escape "$stack")" \
      "$(markdown_escape "$severity")" \
      "$(markdown_escape "$lens")" \
      "$(markdown_escape "$location")" \
      "$(markdown_escape "$evidence")"
    printed=1
  done <"$TMP_FINDINGS"

  if [ "$printed" -eq 0 ]; then
    printf '| all | none | %s | n/a | n/a |\n' "$empty_lens"
  fi
}

write_json_output() {
  export RULE_SPIRIT_REPO_ROOT="$REPO_ROOT"
  export RULE_SPIRIT_STACKS
  export RULE_SPIRIT_SCAN_PATHS
  export RULE_SPIRIT_ALLOWLIST_PATH="${ALLOWLIST_PATH:-}"
  export RULE_SPIRIT_FINDING_COUNT="$finding_count"
  export RULE_SPIRIT_ACTIVE_FINDING_COUNT="$active_finding_count"
  export RULE_SPIRIT_ALLOWLISTED_FINDING_COUNT="$allowlisted_finding_count"
  export RULE_SPIRIT_EXPIRED_ALLOWLIST_COUNT="$expired_allowlist_count"
  export RULE_SPIRIT_MAX_ACTIVE_SEVERITY="$max_active_severity_value"
  RULE_SPIRIT_STACKS="$(printf '%s\n' "${STACKS[@]}")"
  RULE_SPIRIT_SCAN_PATHS="$(printf '%s\n' "${SCAN_PATHS[@]}")"

  python3 - "$TMP_FINDINGS" "$JSON_OUTPUT" <<'PY'
import csv
import json
import os
import sys
from datetime import datetime, timezone

tsv_path, output_path = sys.argv[1:3]
findings = []
with open(tsv_path, newline="", encoding="utf-8") as handle:
    reader = csv.reader(handle, delimiter="\t")
    for row in reader:
        if not row:
            continue
        key, stack, severity, lens, location, evidence, allowed, owner, expires, reason, status = row
        allowlist = None
        if status != "none" or owner or expires or reason:
            allowlist = {
                "owner": owner,
                "expires_utc": expires,
                "reason": reason,
                "status": status,
            }
        findings.append({
            "key": key,
            "stack": stack,
            "severity": severity,
            "lens": lens,
            "location": location,
            "evidence": evidence,
            "allowed": allowed == "true",
            "allowlist": allowlist,
        })

data = {
    "schema_version": "rule-spirit-scan-v1",
    "generated_at_utc": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
    "repository": os.environ["RULE_SPIRIT_REPO_ROOT"],
    "stacks": [item for item in os.environ["RULE_SPIRIT_STACKS"].splitlines() if item],
    "paths": [item for item in os.environ["RULE_SPIRIT_SCAN_PATHS"].splitlines() if item],
    "allowlist_path": os.environ.get("RULE_SPIRIT_ALLOWLIST_PATH") or None,
    "severity_taxonomy": ["review", "warning", "blocker"],
    "finding_count": int(os.environ["RULE_SPIRIT_FINDING_COUNT"]),
    "active_finding_count": int(os.environ["RULE_SPIRIT_ACTIVE_FINDING_COUNT"]),
    "allowlisted_finding_count": int(os.environ["RULE_SPIRIT_ALLOWLISTED_FINDING_COUNT"]),
    "expired_allowlist_count": int(os.environ["RULE_SPIRIT_EXPIRED_ALLOWLIST_COUNT"]),
    "max_active_severity": os.environ["RULE_SPIRIT_MAX_ACTIVE_SEVERITY"],
    "findings": findings,
}

with open(output_path, "w", encoding="utf-8") as handle:
    json.dump(data, handle, indent=2, sort_keys=True)
    handle.write("\n")
PY
}

finding_count="$(count_findings all)"
active_finding_count="$(count_findings active)"
allowlisted_finding_count="$(count_findings allowlisted)"
expired_allowlist_count="$(count_findings expired)"
max_active_severity_value="$(max_active_severity)"

printf 'Rule-Spirit Anti-Pattern Scan\n'
printf 'Repository: %s\n' "$REPO_ROOT"
printf 'Stacks: %s\n' "${STACKS[*]}"
printf 'Findings: %s\n' "$finding_count"
if [ -n "$ALLOWLIST_PATH" ]; then
  printf 'Active findings: %s\n' "$active_finding_count"
  printf 'Allowlisted findings: %s\n' "$allowlisted_finding_count"
  printf 'Expired allowlist matches: %s\n' "$expired_allowlist_count"
fi
printf 'Max active severity: %s\n' "$max_active_severity_value"
printf '\n'
printf '| Stack | Severity | Search Lens | Location | Evidence |\n'
printf '| --- | --- | --- | --- | --- |\n'
if [ "$active_finding_count" -eq 0 ] && [ -n "$ALLOWLIST_PATH" ]; then
  print_table_rows active "no active heuristic findings"
elif [ "$active_finding_count" -eq 0 ]; then
  print_table_rows active "no heuristic findings"
else
  print_table_rows active "no heuristic findings"
fi

if [ -n "$ALLOWLIST_PATH" ] && [ "$allowlisted_finding_count" -gt 0 ]; then
  printf '\n'
  printf 'Allowlisted Findings\n'
  printf '\n'
  printf '| Stack | Severity | Search Lens | Location | Evidence |\n'
  printf '| --- | --- | --- | --- | --- |\n'
  print_table_rows allowlisted "no allowlisted heuristic findings"
fi
printf '\n'
printf 'Note: this scanner supports the Rule-Spirit Anti-Pattern Hunt gate; it does not replace rule-specific review or P1/P2 judgment.\n'

if [ -n "$JSON_OUTPUT" ]; then
  write_json_output
fi

threshold_rank="$(severity_rank "$FAIL_ON_SEVERITY")"
max_rank="$(severity_rank "$max_active_severity_value")"
if [ "$threshold_rank" -gt 0 ] && [ "$max_rank" -ge "$threshold_rank" ] && [ "$active_finding_count" -gt 0 ]; then
  exit 2
fi
exit 0
