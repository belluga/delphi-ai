#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ -f "$ROOT_DIR/delphi-ai/tools/lib/script_usage.sh" ]]; then
  # shellcheck source=/dev/null
  source "$ROOT_DIR/delphi-ai/tools/lib/script_usage.sh"
  delphi_script_usage_init \
    --delphi-root "$ROOT_DIR/delphi-ai" \
    --script-id "root.verify_environment" \
    --script-path "scripts/verify_environment.sh" \
    --surface "root-script"
  delphi_script_usage_install_exit_trap
fi

die() {
  echo "ERROR: $*" >&2
  exit 1
}

warn() {
  echo "WARN: $*" >&2
}

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

file_has() {
  local pattern="$1"
  local file="$2"
  if have_cmd rg; then
    rg -n "$pattern" "$file" >/dev/null
  else
    grep -Eq "$pattern" "$file"
  fi
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

COMPOSE_PROFILES_EFFECTIVE="${COMPOSE_PROFILES:-}"
if [[ -z "$COMPOSE_PROFILES_EFFECTIVE" ]]; then
  COMPOSE_PROFILES_EFFECTIVE="$(read_dotenv_value "COMPOSE_PROFILES" ".env" 2>/dev/null || true)"
fi
DELPHI_COMPOSE_CONFIG_PROFILES="${DELPHI_COMPOSE_CONFIG_PROFILES:-local-db}"
DELPHI_DERIVED_ARTIFACT_SUBMODULES="${DELPHI_DERIVED_ARTIFACT_SUBMODULES:-web-app}"
DELPHI_SCRIPT_LINK_SPECS="${DELPHI_SCRIPT_LINK_SPECS:-flutter-app/scripts:../delphi-ai/scripts/flutter}"
DELPHI_LOCAL_DB_ENV_FILE="${DELPHI_LOCAL_DB_ENV_FILE:-laravel-app/.env}"
DELPHI_LOCAL_DB_REQUIRED_PATTERN="${DELPHI_LOCAL_DB_REQUIRED_PATTERN:-^(DB_URI|DB_URI_LANDLORD|DB_URI_TENANTS)=}"
DELPHI_LOCAL_DB_HOST_PATTERN="${DELPHI_LOCAL_DB_HOST_PATTERN:-mongo:27017}"
DELPHI_NGINX_STORAGE_REQUIRED_PATTERN="${DELPHI_NGINX_STORAGE_REQUIRED_PATTERN:-alias[[:space:]]+/var/www/storage/app/public/;}"

if [[ "${DELPHI_SCRIPT_USAGE_ENABLED:-0}" == "1" ]]; then
  delphi_script_usage_add_metadata "compose_profiles" "${COMPOSE_PROFILES_EFFECTIVE:-unset}"
fi

is_configured_item() {
  local needle="$1"
  local item
  shift
  for item in "$@"; do
    [[ "$needle" == "$item" ]] && return 0
  done
  return 1
}

echo "== basic tooling =="
have_cmd git || die "git not found"
have_cmd docker || die "docker not found"
docker compose version >/dev/null 2>&1 || die "docker compose not available (need Docker Compose v2)"
echo "OK"

echo "== docker compose config (default) =="
docker compose config >/dev/null
echo "OK"

echo "== web shell runtime mount invariants =="
if ! file_has 'FLUTTER_WEB_SHELL_PATH: /opt/flutter-web-shell/index.html' docker-compose.yml; then
  die "docker-compose.yml must configure FLUTTER_WEB_SHELL_PATH at /opt/flutter-web-shell/index.html"
fi
for compose_mount in \
  '- ./web-app:/opt/flutter-web-shell:ro'; do
  if ! grep -Fq -- "${compose_mount}" docker-compose.yml; then
    die "docker-compose.yml missing required web shell mount '${compose_mount}'"
  fi
done
if grep -Fq -- './web-app:/var/www/flutter:ro' docker-compose.yml; then
  die "docker-compose.yml must not mount web-app into /var/www/flutter; use /opt/flutter-web-shell to avoid nested bind-mount drift"
fi
for nginx_template in docker/nginx/local.conf.template docker/nginx/prod.conf.template; do
  [[ -f "${nginx_template}" ]] || die "missing ${nginx_template}"
  if ! grep -Fq 'root /opt/flutter-web-shell;' "${nginx_template}"; then
    die "${nginx_template} must serve Flutter web assets from /opt/flutter-web-shell"
  fi
  if grep -Fq 'root /var/www/flutter;' "${nginx_template}"; then
    die "${nginx_template} must not serve Flutter web assets from /var/www/flutter"
  fi
done
echo "OK"

if [[ -n "$DELPHI_COMPOSE_CONFIG_PROFILES" ]]; then
  for compose_profile in $DELPHI_COMPOSE_CONFIG_PROFILES; do
    echo "== docker compose config (--profile ${compose_profile}) =="
    docker compose --profile "$compose_profile" config >/dev/null
    echo "OK"
  done
fi

echo "== submodule status =="
submodule_status="$(git submodule status --recursive || true)"
if [[ -z "$submodule_status" ]]; then
  warn "No submodules detected or git not initialized."
else
  if echo "$submodule_status" | rg -n '^-'; then
    warn "Uninitialized submodule(s) detected. Auto-initializing..."
    git submodule update --init --recursive
    submodule_status="$(git submodule status --recursive || true)"
    if echo "$submodule_status" | rg -n '^-'; then
      die "Uninitialized submodule(s) remain after auto-init."
    fi
  fi
  if echo "$submodule_status" | rg -n '^\\+'; then
    warn "Submodule(s) out of sync with recorded commit (+)."
  fi
fi

echo "== shared doc symlinks =="
submodule_paths="$(git config --file .gitmodules --get-regexp path | awk '{print $2}' || true)"
read -r -a derived_artifact_submodules <<< "$DELPHI_DERIVED_ARTIFACT_SUBMODULES"
for submodule_path in $submodule_paths; do
  if [[ ! -d "$submodule_path" ]]; then
    warn "Submodule path missing on disk: ${submodule_path}"
    continue
  fi

  if [[ "$submodule_path" == "foundation_documentation" ]] || is_configured_item "$submodule_path" "${derived_artifact_submodules[@]}"; then
    continue
  fi

  if [[ ! -e "${submodule_path}/foundation_documentation" ]]; then
    ln -s ../foundation_documentation "${submodule_path}/foundation_documentation"
    echo "FIXED: ${submodule_path}/foundation_documentation symlink created."
  elif [[ ! -L "${submodule_path}/foundation_documentation" ]]; then
    warn "${submodule_path}/foundation_documentation exists but is not a symlink."
  fi

  if [[ ! -e "${submodule_path}/delphi-ai" ]]; then
    ln -s ../delphi-ai "${submodule_path}/delphi-ai"
    echo "FIXED: ${submodule_path}/delphi-ai symlink created."
  elif [[ ! -L "${submodule_path}/delphi-ai" ]]; then
    warn "${submodule_path}/delphi-ai exists but is not a symlink."
  fi
done

echo "== script symlinks =="
for link_spec in $DELPHI_SCRIPT_LINK_SPECS; do
  IFS=':' read -r script_link expected_target extra <<< "$link_spec"
  if [[ -z "${script_link:-}" || -z "${expected_target:-}" || -n "${extra:-}" ]]; then
    warn "Invalid DELPHI_SCRIPT_LINK_SPECS entry: ${link_spec}"
    continue
  fi
  script_parent="$(dirname "$script_link")"
  if [[ ! -d "$script_parent" ]]; then
    warn "Script link parent missing; skipped: ${script_parent}"
    continue
  fi
  if [[ ! -L "$script_link" ]]; then
    ln -s "$expected_target" "$script_link"
    echo "FIXED: ${script_link} symlink created."
  else
    scripts_target="$(readlink "$script_link" || true)"
    if [[ "$scripts_target" != "$expected_target" ]]; then
      warn "${script_link} points to '${scripts_target}', expected ${expected_target}."
    fi
  fi
done

echo "== compose profile sanity =="
if [[ -z "${COMPOSE_PROFILES_EFFECTIVE:-}" ]]; then
  warn "COMPOSE_PROFILES not set; default profile (staging) will be used."
fi

echo "== submodule remotes =="
if [[ -f ".gitmodules" ]]; then
  if rg -n "boilerplate" .gitmodules >/dev/null; then
    warn "Submodule URLs still reference boilerplate repos; update them to your forks."
  fi
else
  warn ".gitmodules not found; submodule remotes not checked."
fi

echo "== derived artifact submodule invariants =="
derived_checked=0
for artifact_path in $DELPHI_DERIVED_ARTIFACT_SUBMODULES; do
  expected_artifact_url="$(git config -f .gitmodules --get "submodule.${artifact_path}.url" 2>/dev/null || true)"
  if [[ -z "$expected_artifact_url" ]]; then
    warn "${artifact_path} submodule URL missing in .gitmodules; skipping derived artifact invariant."
    continue
  fi
  derived_checked=1
  actual_artifact_url="$(git config --local --get "submodule.${artifact_path}.url" 2>/dev/null || true)"
  [[ -z "$actual_artifact_url" || "$actual_artifact_url" == "$expected_artifact_url" ]] || die "${artifact_path} submodule URL mismatch (expected: $expected_artifact_url, got: ${actual_artifact_url:-<missing>})"

  artifact_mode="$(git ls-files --stage "$artifact_path" 2>/dev/null | awk '{print $1}' || true)"
  [[ "$artifact_mode" == "160000" ]] || die "${artifact_path} is not tracked as a gitlink submodule (expected mode 160000)"

  [[ -d "$artifact_path" ]] || die "${artifact_path} directory missing (run: git submodule update --init ${artifact_path})"
  [[ -f "${artifact_path}/.git" || -d "${artifact_path}/.git" ]] || die "${artifact_path} is not initialized (missing ${artifact_path}/.git); run: git submodule update --init ${artifact_path}"
done
if [[ "$derived_checked" -eq 1 ]]; then
  echo "OK"
else
  warn "No configured derived artifact submodule invariants were checked."
fi

echo "== nginx storage alias invariants =="
if [[ -n "${DELPHI_NGINX_STORAGE_TEMPLATE_PATHS+x}" ]]; then
  nginx_storage_template_paths="$DELPHI_NGINX_STORAGE_TEMPLATE_PATHS"
elif [[ -d docker/nginx ]]; then
  nginx_storage_template_paths="docker/nginx/local.conf.template docker/nginx/prod.conf.template"
else
  nginx_storage_template_paths=""
fi
nginx_storage_checked=0
for tmpl in $nginx_storage_template_paths; do
  [[ -f "$tmpl" ]] || die "missing $tmpl"
  nginx_storage_checked=1
  if [[ -n "$DELPHI_NGINX_STORAGE_REQUIRED_PATTERN" ]] && ! file_has "$DELPHI_NGINX_STORAGE_REQUIRED_PATTERN" "$tmpl"; then
    die "$tmpl missing configured storage invariant pattern: $DELPHI_NGINX_STORAGE_REQUIRED_PATTERN"
  fi
done
if [[ "$nginx_storage_checked" -eq 1 ]]; then
  echo "OK"
else
  warn "No nginx storage template paths configured; skipping storage alias invariant."
fi

echo "== env hygiene =="
if git ls-files --error-unmatch .env >/dev/null 2>&1; then
  die ".env is tracked by git; it must be local-only and ignored"
fi
if git ls-files --error-unmatch .env.testing >/dev/null 2>&1; then
  die ".env.testing is tracked by git; it must be local-only and ignored"
fi

if [[ -f ".env" ]] && ! git check-ignore -q .env; then
  die ".env exists but is not ignored (ensure .env is in .gitignore)"
fi
if [[ -f ".env.testing" ]] && ! git check-ignore -q .env.testing; then
  die ".env.testing exists but is not ignored (ensure .env.testing is in .gitignore)"
fi
echo "OK"

if [[ "${COMPOSE_PROFILES_EFFECTIVE:-}" == *"staging"* ]]; then
  if [[ ! -f ".env" ]]; then
    warn "COMPOSE_PROFILES includes staging but .env is missing"
  else
    domain_val="$(read_dotenv_value "DOMAIN" ".env" 2>/dev/null || true)"
    tunnel_val="$(read_dotenv_value "CLOUDFLARE_TUNNEL_TOKEN" ".env" 2>/dev/null || true)"
    [[ -n "$domain_val" ]] || warn "COMPOSE_PROFILES includes staging but DOMAIN is missing in .env"
    [[ -n "$tunnel_val" ]] || warn "COMPOSE_PROFILES includes staging but CLOUDFLARE_TUNNEL_TOKEN is missing in .env"
  fi
fi

if [[ "${COMPOSE_PROFILES_EFFECTIVE:-}" == *"production"* ]]; then
  if [[ ! -f ".env" ]]; then
    warn "COMPOSE_PROFILES includes production but .env is missing"
  else
    domain_val="$(read_dotenv_value "DOMAIN" ".env" 2>/dev/null || true)"
    certbot_val="$(read_dotenv_value "CERTBOT_EMAIL" ".env" 2>/dev/null || true)"
    [[ -n "$domain_val" ]] || warn "COMPOSE_PROFILES includes production but DOMAIN is missing in .env"
    [[ -n "$certbot_val" ]] || warn "COMPOSE_PROFILES includes production but CERTBOT_EMAIL is missing in .env"
  fi
fi

if [[ "${COMPOSE_PROFILES_EFFECTIVE:-}" == *"local-db"* ]]; then
  echo "== local-db profile checks =="
  if [[ ! -f "$DELPHI_LOCAL_DB_ENV_FILE" ]]; then
    warn "${DELPHI_LOCAL_DB_ENV_FILE} not found; configure the project local DB env file for local Mongo."
    exit 0
  fi

  if ! file_has "$DELPHI_LOCAL_DB_REQUIRED_PATTERN" "$DELPHI_LOCAL_DB_ENV_FILE"; then
    warn "${DELPHI_LOCAL_DB_ENV_FILE} missing configured local DB variables; local Mongo may not connect."
    exit 0
  fi

  if ! file_has "$DELPHI_LOCAL_DB_HOST_PATTERN" "$DELPHI_LOCAL_DB_ENV_FILE"; then
    warn "${DELPHI_LOCAL_DB_ENV_FILE} local DB variables do not match ${DELPHI_LOCAL_DB_HOST_PATTERN}; local-db profile may not be used."
  fi
fi
