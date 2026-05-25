#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: rule_spirit_anti_pattern_scan.sh [--repo <path>] [--stack <name>] [--path <path>] [--fail-on-findings]

Heuristic support for the TODO delivery "Rule-Spirit Anti-Pattern Hunt" gate.
The scanner flags suspicious bypasses and stack-specific smells; human review
still owns severity, waivers, and final P1/P2 judgment.

Stacks: all, docker, flutter, laravel, go
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

command -v rg >/dev/null 2>&1 || die "ripgrep (rg) is required"

REPO_INPUT="."
FAIL_ON_FINDINGS=false
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
      FAIL_ON_FINDINGS=true
      shift
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

TMP_FINDINGS="$(mktemp)"
TMP_HELPER="$(mktemp)"
trap 'rm -f "$TMP_FINDINGS" "$TMP_HELPER"' EXIT

record() {
  local stack="$1"
  local severity="$2"
  local lens="$3"
  local location="$4"
  local evidence="$5"
  evidence="${evidence//|/\\|}"
  printf '| %s | %s | %s | `%s` | %s |\n' "$stack" "$severity" "$lens" "$location" "$evidence" >>"$TMP_FINDINGS"
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

scan_rg "shared" "review" "guard bypass or tactical workaround marker" '(TODO|FIXME|HACK).*(bypass|skip|ignore|disable|temporary|temporar|workaround|gambiarra)|((bypass|skip|ignore|disable).*(guard|rule|validation|test))' '*.dart' '*.php' '*.go' '*.js' '*.ts' '*.sh'
scan_rg "shared" "review" "hard-coded local/domain target in source/config" '(localhost|127\.0\.0\.1|host\.docker\.internal|[A-Za-z0-9.-]+\.test)' '*.dart' '*.php' '*.go' '*.js' '*.ts' '*.yaml' '*.yml'

if has_stack flutter; then
  scan_rg "flutter" "review" "presentation/application importing infrastructure or DTO surfaces" 'import .*(infrastructure|dto)' '*.dart'
  scan_rg "flutter" "review" "imperative Navigator usage; verify route/controller boundary" '\bNavigator\.' '*.dart'
  scan_rg "flutter" "review" "FutureBuilder/StreamBuilder in app code; verify no IO/build side-effect bypass" '\b(FutureBuilder|StreamBuilder)\b' '*.dart'
fi

if has_stack laravel; then
  scan_rg "laravel" "review" "post-fetch filtering exact lookup candidate" '->(get|paginate|cursorPaginate)\([^)]*\)\s*->\s*(firstWhere|where)\(' '*.php'
  scan_rg "laravel" "review" "route auth without visible tenant guard candidate" 'auth:sanctum' '*.php'
  if [ -d "$REPO_ROOT/laravel-app/routes" ] && [ -x "$REPO_ROOT/delphi-ai/tools/laravel_tenant_access_guardrails_audit.sh" ]; then
    scan_helper "laravel" "review" "tenant access guardrail helper reported findings" "$REPO_ROOT/delphi-ai/tools/laravel_tenant_access_guardrails_audit.sh" --repo "$REPO_ROOT"
  elif [ -d "$REPO_ROOT/laravel-app/routes" ] && [ -x "$(dirname "${BASH_SOURCE[0]}")/laravel_tenant_access_guardrails_audit.sh" ]; then
    scan_helper "laravel" "review" "tenant access guardrail helper reported findings" "$(dirname "${BASH_SOURCE[0]}")/laravel_tenant_access_guardrails_audit.sh" --repo "$REPO_ROOT"
  fi
fi

if has_stack docker; then
  scan_rg "docker" "review" "hard-coded runtime/domain target in Docker or compose surface" '(localhost|127\.0\.0\.1|host\.docker\.internal|[A-Za-z0-9.-]+\.test)' 'Dockerfile*' '*compose*.yml' '*compose*.yaml' 'docker-compose*.yml' 'docker-compose*.yaml'
fi

if has_stack go; then
  scan_rg "go" "review" "handler/service context shortcut candidate" '\bcontext\.Background\(\)' '*.go'
  scan_rg "go" "review" "panic/TODO in service code candidate" '\bpanic\(|TODO.*(tenant|auth|validation|guard)' '*.go'
fi

finding_count="$(wc -l <"$TMP_FINDINGS" | tr -d '[:space:]')"

printf 'Rule-Spirit Anti-Pattern Scan\n'
printf 'Repository: %s\n' "$REPO_ROOT"
printf 'Stacks: %s\n' "${STACKS[*]}"
printf 'Findings: %s\n' "$finding_count"
printf '\n'
printf '| Stack | Severity | Search Lens | Location | Evidence |\n'
printf '| --- | --- | --- | --- | --- |\n'
if [ "$finding_count" -eq 0 ]; then
  printf '| all | none | no heuristic findings | n/a | n/a |\n'
else
  cat "$TMP_FINDINGS"
fi
printf '\n'
printf 'Note: this scanner supports the Rule-Spirit Anti-Pattern Hunt gate; it does not replace rule-specific review or P1/P2 judgment.\n'

if [ "$FAIL_ON_FINDINGS" = true ] && [ "$finding_count" -gt 0 ]; then
  exit 2
fi
exit 0
