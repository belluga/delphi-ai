#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: environment_readiness_report.sh [--repo <path>] [--include-adherence-sync]

Read-only consolidated readiness report for downstream Delphi environments.

The report:
- detects zero-state Genesis environments and uses `delphi-ai/init.sh --check` instead of full downstream readiness;
- runs `delphi-ai/verify_context.sh` in read-only mode for mature downstream environments;
- optionally runs `delphi-ai/verify_adherence_sync.sh` after readiness passes;
- performs non-mutating project checks for compose config, submodule state, web-app gitlink invariants, and env hygiene.

Options:
  --repo <path>              Repository/environment root. Defaults to current directory.
  --include-adherence-sync   Run `delphi-ai/verify_adherence_sync.sh` after `verify_context.sh` succeeds.
  -h, --help                 Show this help text.

Exit codes:
  0  Report completed and the environment is ready, or zero-state Genesis preflight passed.
  2  Report completed and blockers remain.
  1  Operational error (paths missing, command failure outside the audited checks, etc.).
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

REPO_INPUT="."
INCLUDE_ADHERENCE_SYNC=false

while [ $# -gt 0 ]; do
  case "$1" in
    --repo)
      [ $# -ge 2 ] || die "missing value for --repo"
      REPO_INPUT="$2"
      shift 2
      ;;
    --include-adherence-sync)
      INCLUDE_ADHERENCE_SYNC=true
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

if [ -f "$REPO_ROOT/main_instructions.md" ] && [ -d "$REPO_ROOT/skills" ] && [ -d "$REPO_ROOT/rules" ] && [ -d "$REPO_ROOT/workflows" ] && [ ! -e "$REPO_ROOT/delphi-ai" ]; then
  die "environment_readiness_report.sh is for downstream environments, not the canonical delphi-ai repository"
fi

DEL_ROOT="$REPO_ROOT/delphi-ai"
[ -e "$DEL_ROOT" ] || die "missing delphi-ai at $DEL_ROOT"
[ -f "$DEL_ROOT/verify_context.sh" ] || die "missing $DEL_ROOT/verify_context.sh"
[ -f "$DEL_ROOT/init.sh" ] || die "missing $DEL_ROOT/init.sh"

declare -a WARNINGS=()
declare -a FAILURES=()

CURRENT_STEP_OUTPUT=""

run_and_capture() {
  local cmd=("$@")
  local output=""

  if output="$("${cmd[@]}" 2>&1)"; then
    CURRENT_STEP_OUTPUT="$output"
    return 0
  fi

  local code=$?
  CURRENT_STEP_OUTPUT="$output"
  return "$code"
}

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

read_dotenv_value() {
  local key="$1"
  local file="$2"
  [[ -f "$file" ]] || return 1
  local line
  line="$(grep -E "^${key}=" "$file" | tail -n 1 || true)"
  [[ -n "$line" ]] || return 1
  echo "${line#${key}=}"
}

file_has() {
  local pattern="$1"
  local file="$2"
  if have_cmd rg; then
    rg -n "$pattern" "$file" >/dev/null 2>&1
  else
    grep -Eq "$pattern" "$file"
  fi
}

print_step() {
  local title="$1"
  local status="$2"
  local output="$3"

  printf '%s: %s\n' "$title" "$status"
  if [ -n "$output" ]; then
    while IFS= read -r line; do
      [ -n "$line" ] || continue
      printf '  %s\n' "$line"
    done <<< "$output"
  else
    printf '  (no output)\n'
  fi
  printf '\n'
}

REPO_MODE="downstream"
if [ ! -d "$REPO_ROOT/foundation_documentation" ]; then
  REPO_MODE="zero-state"
fi

printf 'Environment Readiness Report\n'
printf 'Repository: %s\n' "$REPO_ROOT"
printf 'Mode: %s\n' "$REPO_MODE"
printf 'Include adherence sync: %s\n' "$([ "$INCLUDE_ADHERENCE_SYNC" = true ] && echo yes || echo no)"
printf '\n'

if [ "$REPO_MODE" = "zero-state" ]; then
  if run_and_capture bash "$DEL_ROOT/init.sh" --check; then
    print_step "Genesis install preflight" "PASS" "$CURRENT_STEP_OUTPUT"
    printf 'Overall outcome: zero-state-ready\n'
    exit 0
  fi

  print_step "Genesis install preflight" "FAIL" "$CURRENT_STEP_OUTPUT"
  printf 'Overall outcome: blocked\n'
  exit 2
fi

if run_and_capture bash "$DEL_ROOT/verify_context.sh"; then
  print_step "Delphi verify_context" "PASS" "$CURRENT_STEP_OUTPUT"
else
  print_step "Delphi verify_context" "FAIL" "$CURRENT_STEP_OUTPUT"
  FAILURES+=("verify_context.sh reported readiness blockers")
fi

if [ "$INCLUDE_ADHERENCE_SYNC" = true ] && [ "${#FAILURES[@]}" -eq 0 ]; then
  if run_and_capture bash "$DEL_ROOT/verify_adherence_sync.sh"; then
    print_step "Delphi verify_adherence_sync" "PASS" "$CURRENT_STEP_OUTPUT"
  else
    print_step "Delphi verify_adherence_sync" "FAIL" "$CURRENT_STEP_OUTPUT"
    FAILURES+=("verify_adherence_sync.sh reported mirror/sync blockers")
  fi
fi

tooling_output=()
tooling_status="PASS"
if have_cmd git; then
  tooling_output+=("git: ok")
else
  tooling_output+=("git: missing")
  tooling_status="FAIL"
  FAILURES+=("git not found")
fi
if have_cmd docker; then
  tooling_output+=("docker: ok")
  if docker compose version >/dev/null 2>&1; then
    tooling_output+=("docker compose v2: ok")
  else
    tooling_output+=("docker compose v2: missing")
    tooling_status="FAIL"
    FAILURES+=("docker compose v2 not available")
  fi
else
  tooling_output+=("docker: missing")
  tooling_output+=("docker compose v2: unavailable because docker is missing")
  tooling_status="FAIL"
  FAILURES+=("docker not found")
fi
print_step "Basic tooling" "$tooling_status" "$(printf '%s\n' "${tooling_output[@]}")"

COMPOSE_FILE_PRESENT=false
for compose_file in docker-compose.yml compose.yml compose.yaml; do
  if [ -f "$REPO_ROOT/$compose_file" ]; then
    COMPOSE_FILE_PRESENT=true
    break
  fi
done

if [ "$COMPOSE_FILE_PRESENT" = true ] && have_cmd docker && docker compose version >/dev/null 2>&1; then
  compose_default_status="PASS"
  compose_default_output=""
  if run_and_capture bash -lc "cd \"$REPO_ROOT\" && docker compose config"; then
    compose_default_output="docker compose config: ok"
  else
    compose_default_status="FAIL"
    compose_default_output="$CURRENT_STEP_OUTPUT"
    FAILURES+=("docker compose config failed")
  fi

  compose_local_db_status="PASS"
  compose_local_db_output=""
  if run_and_capture bash -lc "cd \"$REPO_ROOT\" && docker compose --profile local-db config"; then
    compose_local_db_output="docker compose --profile local-db config: ok"
  else
    compose_local_db_status="FAIL"
    compose_local_db_output="$CURRENT_STEP_OUTPUT"
    FAILURES+=("docker compose --profile local-db config failed")
  fi

  print_step "Compose config (default)" "$compose_default_status" "$compose_default_output"
  print_step "Compose config (local-db)" "$compose_local_db_status" "$compose_local_db_output"
else
  print_step "Compose config" "SKIP" "docker compose file not present or docker compose unavailable"
fi

if [ -f "$REPO_ROOT/.gitmodules" ]; then
  submodule_output="$(git -C "$REPO_ROOT" submodule status --recursive 2>&1 || true)"
  submodule_status="PASS"
  if printf '%s\n' "$submodule_output" | grep -q '^-'; then
    submodule_status="FAIL"
    FAILURES+=("uninitialized submodule entries remain")
  elif printf '%s\n' "$submodule_output" | grep -q '^U'; then
    submodule_status="FAIL"
    FAILURES+=("submodule gitlink conflict detected")
  elif printf '%s\n' "$submodule_output" | grep -q '^+'; then
    submodule_status="REVIEW"
    WARNINGS+=("submodule entries out of sync with recorded commits")
  fi
  print_step "Submodule status" "$submodule_status" "${submodule_output:-No submodules detected.}"

  if grep -n "boilerplate" "$REPO_ROOT/.gitmodules" >/dev/null 2>&1; then
    WARNINGS+=(".gitmodules still references boilerplate repos")
    print_step "Submodule remotes" "REVIEW" "boilerplate references detected in .gitmodules"
  else
    print_step "Submodule remotes" "PASS" "no boilerplate references detected in .gitmodules"
  fi

  expected_web_url="$(git -C "$REPO_ROOT" config -f .gitmodules --get submodule.web-app.url 2>/dev/null || true)"
  if [ -n "$expected_web_url" ]; then
    web_invariant_output=()
    web_invariant_status="PASS"
    actual_web_url="$(git -C "$REPO_ROOT" config --local --get submodule.web-app.url 2>/dev/null || true)"
    if [ -n "$actual_web_url" ] && [ "$actual_web_url" != "$expected_web_url" ]; then
      web_invariant_status="FAIL"
      FAILURES+=("web-app submodule URL mismatch")
      web_invariant_output+=("URL mismatch: expected $expected_web_url got $actual_web_url")
    else
      web_invariant_output+=("URL matches .gitmodules")
    fi

    web_mode="$(git -C "$REPO_ROOT" ls-files --stage web-app 2>/dev/null | awk '{print $1}' || true)"
    if [ "$web_mode" != "160000" ]; then
      web_invariant_status="FAIL"
      FAILURES+=("web-app is not tracked as a gitlink submodule")
      web_invariant_output+=("git mode is ${web_mode:-<missing>} (expected 160000)")
    else
      web_invariant_output+=("gitlink mode is 160000")
    fi

    if [ ! -d "$REPO_ROOT/web-app" ] || { [ ! -f "$REPO_ROOT/web-app/.git" ] && [ ! -d "$REPO_ROOT/web-app/.git" ]; }; then
      web_invariant_status="FAIL"
      FAILURES+=("web-app is missing or uninitialized")
      web_invariant_output+=("web-app directory or .git is missing")
    else
      web_invariant_output+=("web-app directory initialized")
    fi

    print_step "web-app submodule invariants" "$web_invariant_status" "$(printf '%s\n' "${web_invariant_output[@]}")"
  fi
else
  print_step "Submodule status" "SKIP" ".gitmodules not present"
fi

nginx_templates=(
  "$REPO_ROOT/docker/nginx/local.conf.template"
  "$REPO_ROOT/docker/nginx/prod.conf.template"
)
nginx_output=()
nginx_status="PASS"
nginx_checked=false
for tmpl in "${nginx_templates[@]}"; do
  if [ -f "$tmpl" ]; then
    nginx_checked=true
    if file_has 'try_files \$request_filename =404;' "$tmpl"; then
      nginx_output+=("$(basename "$tmpl"): ok")
    else
      nginx_status="FAIL"
      FAILURES+=("missing storage alias invariant in $(basename "$tmpl")")
      nginx_output+=("$(basename "$tmpl"): missing try_files \$request_filename =404;")
    fi
  fi
done
if [ "$nginx_checked" = true ]; then
  print_step "Nginx storage alias invariants" "$nginx_status" "$(printf '%s\n' "${nginx_output[@]}")"
else
  print_step "Nginx storage alias invariants" "SKIP" "no nginx template files found"
fi

env_output=()
env_status="PASS"
if git -C "$REPO_ROOT" ls-files --error-unmatch .env >/dev/null 2>&1; then
  env_status="FAIL"
  FAILURES+=(".env is tracked by git")
  env_output+=(".env is tracked by git")
else
  env_output+=(".env is not tracked")
fi
if git -C "$REPO_ROOT" ls-files --error-unmatch .env.testing >/dev/null 2>&1; then
  env_status="FAIL"
  FAILURES+=(".env.testing is tracked by git")
  env_output+=(".env.testing is tracked by git")
else
  env_output+=(".env.testing is not tracked")
fi
if [ -f "$REPO_ROOT/.env" ] && ! git -C "$REPO_ROOT" check-ignore -q .env; then
  env_status="FAIL"
  FAILURES+=(".env exists but is not ignored")
  env_output+=(".env exists but is not ignored")
fi
if [ -f "$REPO_ROOT/.env.testing" ] && ! git -C "$REPO_ROOT" check-ignore -q .env.testing; then
  env_status="FAIL"
  FAILURES+=(".env.testing exists but is not ignored")
  env_output+=(".env.testing exists but is not ignored")
fi
print_step "Env hygiene" "$env_status" "$(printf '%s\n' "${env_output[@]}")"

if [ -f "$REPO_ROOT/.env" ]; then
  compose_profiles_effective="${COMPOSE_PROFILES:-}"
  if [ -z "$compose_profiles_effective" ]; then
    compose_profiles_effective="$(read_dotenv_value "COMPOSE_PROFILES" "$REPO_ROOT/.env" 2>/dev/null || true)"
  fi
  profile_output=()
  if [[ "$compose_profiles_effective" == *"staging"* ]]; then
    domain_val="$(read_dotenv_value "DOMAIN" "$REPO_ROOT/.env" 2>/dev/null || true)"
    tunnel_val="$(read_dotenv_value "CLOUDFLARE_TUNNEL_TOKEN" "$REPO_ROOT/.env" 2>/dev/null || true)"
    [ -n "$domain_val" ] || WARNINGS+=("staging profile active but DOMAIN is missing")
    [ -n "$tunnel_val" ] || WARNINGS+=("staging profile active but CLOUDFLARE_TUNNEL_TOKEN is missing")
    profile_output+=("staging profile detected")
  fi
  if [[ "$compose_profiles_effective" == *"production"* ]]; then
    domain_val="$(read_dotenv_value "DOMAIN" "$REPO_ROOT/.env" 2>/dev/null || true)"
    certbot_val="$(read_dotenv_value "CERTBOT_EMAIL" "$REPO_ROOT/.env" 2>/dev/null || true)"
    [ -n "$domain_val" ] || WARNINGS+=("production profile active but DOMAIN is missing")
    [ -n "$certbot_val" ] || WARNINGS+=("production profile active but CERTBOT_EMAIL is missing")
    profile_output+=("production profile detected")
  fi
  if [[ "$compose_profiles_effective" == *"local-db"* ]] && [ -f "$REPO_ROOT/laravel-app/.env" ]; then
    if ! file_has 'mongo:27017' "$REPO_ROOT/laravel-app/.env"; then
      WARNINGS+=("local-db profile active but laravel-app/.env does not reference mongo:27017")
    fi
    profile_output+=("local-db profile detected")
  fi

  if [ "${#profile_output[@]}" -gt 0 ]; then
    print_step "Profile-specific env hints" "REVIEW" "$(printf '%s\n' "${profile_output[@]}")"
  fi
fi

validation_output=()
validation_status="REVIEW"
dependency_readiness_file="$REPO_ROOT/foundation_documentation/artifacts/dependency-readiness.md"
if [ -f "$dependency_readiness_file" ]; then
  validation_output+=("dependency-readiness artifact present: foundation_documentation/artifacts/dependency-readiness.md")
  if have_cmd rg; then
    while IFS= read -r line; do
      validation_output+=("$line")
    done < <(rg -n 'https?://|build_web\.sh|run_laravel_tests_safe\.sh|web-app|tenant|subdomain|cloudflare|cloudflared' "$dependency_readiness_file" || true)
  else
    while IFS= read -r line; do
      validation_output+=("$line")
    done < <(grep -En 'https?://|build_web\.sh|run_laravel_tests_safe\.sh|web-app|tenant|subdomain|cloudflare|cloudflared' "$dependency_readiness_file" || true)
  fi
else
  validation_output+=("dependency-readiness artifact not present")
fi

if [ -e "$REPO_ROOT/laravel-app/scripts/delphi/run_laravel_tests_safe.sh" ] || [ -e "$DEL_ROOT/scripts/laravel/run_laravel_tests_safe.sh" ]; then
  validation_output+=("Laravel local-safe runner available: ./laravel-app/scripts/delphi/run_laravel_tests_safe.sh")
fi

if [ -e "$REPO_ROOT/flutter-app/scripts/build_web.sh" ]; then
  validation_output+=("Flutter publish wrapper available: ./flutter-app/scripts/build_web.sh")
fi

if [ -f "$REPO_ROOT/.env" ]; then
  domain_hint="$(read_dotenv_value "DOMAIN" "$REPO_ROOT/.env" 2>/dev/null || true)"
  if [ -n "$domain_hint" ]; then
    validation_output+=("Landlord host hint from .env DOMAIN: https://$domain_hint")
  fi
  tunnel_hint="$(read_dotenv_value "CLOUDFLARE_TUNNEL_TOKEN" "$REPO_ROOT/.env" 2>/dev/null || true)"
  if [ -n "$tunnel_hint" ]; then
    validation_output+=("Cloudflare tunnel token configured in .env")
  fi
fi

if [ "${#validation_output[@]}" -gt 0 ]; then
  print_step "Validation topology hints" "$validation_status" "$(printf '%s\n' "${validation_output[@]}")"
fi

printf 'Warnings:\n'
if [ "${#WARNINGS[@]}" -eq 0 ]; then
  printf '  - none\n'
else
  for warning in "${WARNINGS[@]}"; do
    printf '  - %s\n' "$warning"
  done
fi
printf '\n'

printf 'Failures:\n'
if [ "${#FAILURES[@]}" -eq 0 ]; then
  printf '  - none\n'
else
  for failure in "${FAILURES[@]}"; do
    printf '  - %s\n' "$failure"
  done
fi
printf '\n'

if [ "${#FAILURES[@]}" -gt 0 ]; then
  printf 'Overall outcome: blocked\n'
  exit 2
fi

printf 'Overall outcome: ready\n'
