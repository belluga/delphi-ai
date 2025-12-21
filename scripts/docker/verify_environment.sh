#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

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

echo "== basic tooling =="
have_cmd git || die "git not found"
have_cmd docker || die "docker not found"
docker compose version >/dev/null 2>&1 || die "docker compose not available (need Docker Compose v2)"
echo "OK"

echo "== docker compose config (default) =="
docker compose config >/dev/null
echo "OK"

echo "== docker compose config (--profile local-db) =="
docker compose --profile local-db config >/dev/null
echo "OK"

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
for submodule_path in $submodule_paths; do
  if [[ ! -d "$submodule_path" ]]; then
    warn "Submodule path missing on disk: ${submodule_path}"
    continue
  fi

  if [[ "$submodule_path" == "web-app" ]]; then
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

echo "== flutter scripts symlink =="
if [[ ! -L "flutter-app/scripts" ]]; then
  ln -s ../delphi-ai/scripts/flutter flutter-app/scripts
  echo "FIXED: flutter-app/scripts symlink created."
else
  scripts_target="$(readlink "flutter-app/scripts" || true)"
  if [[ "$scripts_target" != "../delphi-ai/scripts/flutter" ]]; then
    warn "flutter-app/scripts points to '${scripts_target}', expected ../delphi-ai/scripts/flutter."
  fi
fi

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

echo "== submodule invariants (web-app) =="
expected_web_url="$(git config -f .gitmodules --get submodule.web-app.url 2>/dev/null || true)"
[[ -n "$expected_web_url" ]] || die "web-app submodule URL missing in .gitmodules"
actual_web_url="$(git config --local --get submodule.web-app.url 2>/dev/null || true)"
[[ -z "$actual_web_url" || "$actual_web_url" == "$expected_web_url" ]] || die "web-app submodule URL mismatch (expected: $expected_web_url, got: ${actual_web_url:-<missing>})"

web_mode="$(git ls-files --stage web-app 2>/dev/null | awk '{print $1}' || true)"
[[ "$web_mode" == "160000" ]] || die "web-app is not tracked as a gitlink submodule (expected mode 160000)"

[[ -d "web-app" ]] || die "web-app directory missing (run: git submodule update --init web-app)"
[[ -f "web-app/.git" || -d "web-app/.git" ]] || die "web-app is not initialized (missing web-app/.git); run: git submodule update --init web-app"
echo "OK"

echo "== nginx storage alias invariants =="
for tmpl in docker/nginx/local.conf.template docker/nginx/prod.conf.template; do
  [[ -f "$tmpl" ]] || die "missing $tmpl"
  if ! file_has 'try_files \$request_filename =404;' "$tmpl"; then
    die "$tmpl missing 'try_files \\$request_filename =404;' (required for /storage alias correctness)"
  fi
done
echo "OK"

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
  if [[ ! -f "laravel-app/.env" ]]; then
    warn "laravel-app/.env not found; configure DB_URI/DB_URI_LANDLORD/DB_URI_TENANTS for local Mongo."
    exit 0
  fi

  if ! file_has '^(DB_URI|DB_URI_LANDLORD|DB_URI_TENANTS)=' laravel-app/.env; then
    warn "laravel-app/.env missing DB_URI* variables; local Mongo may not connect."
    exit 0
  fi

  if ! file_has 'mongo:27017' laravel-app/.env; then
    warn "laravel-app/.env DB_URI* do not reference mongo:27017; local-db profile may not be used."
  fi
fi
