#!/usr/bin/env bash
set -euo pipefail

find_environment_root() {
  local start="$1"
  local current="$start"
  for _ in 1 2 3 4 5 6 7; do
    if [ -f "$current/docker-compose.yml" ] && [ -d "$current/laravel-app" ] && [ -d "$current/delphi-ai" ]; then
      echo "$current"
      return 0
    fi
    current="$(cd "$current/.." && pwd 2>/dev/null || echo "")"
    if [ -z "$current" ]; then
      break
    fi
  done
  return 1
}

ROOT_DIR="$(git -C "$(pwd)" rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$ROOT_DIR" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  ROOT_DIR="$(find_environment_root "$SCRIPT_DIR" || true)"
fi

if [ -z "$ROOT_DIR" ]; then
  echo "ERROR: could not resolve environment root containing docker-compose.yml + laravel-app + delphi-ai." >&2
  exit 1
fi

cd "$ROOT_DIR"

APP_CONTAINER="${APP_CONTAINER:-app}"

LOCAL_APP_URL="${LOCAL_APP_URL:-http://nginx}"
LOCAL_APP_HOST="${LOCAL_APP_HOST:-nginx}"
LOCAL_DB_URI="${LOCAL_DB_URI:-mongodb://mongo:27017/belluga_tests}"
LOCAL_DB_URI_LANDLORD="${LOCAL_DB_URI_LANDLORD:-mongodb://mongo:27017/belluga_tests_landlord}"
LOCAL_DB_URI_TENANTS="${LOCAL_DB_URI_TENANTS:-mongodb://mongo:27017/belluga_tests_tenant}"

ALLOWED_HTTP_HOSTS=("nginx" "localhost" "127.0.0.1" "::1")
ALLOWED_MONGO_HOSTS=("mongo" "localhost" "127.0.0.1" "::1")

contains_host() {
  local target="$1"
  shift
  for candidate in "$@"; do
    if [[ "$target" == "$candidate" ]]; then
      return 0
    fi
  done
  return 1
}

normalize_host() {
  local raw="$1"
  local host="${raw#*://}"
  host="${host%%/*}"
  host="${host%%:*}"
  host="${host#[}"
  host="${host%]}"
  printf '%s' "${host,,}"
}

validate_http_host() {
  local value="$1"
  local host
  host="$(normalize_host "$value")"
  if [[ -z "$host" ]] || ! contains_host "$host" "${ALLOWED_HTTP_HOSTS[@]}"; then
    echo "ERROR: non-local APP host '$value' (resolved host='$host')." >&2
    exit 1
  fi
}

validate_mongo_uri() {
  local key="$1"
  local uri="$2"

  if [[ "${uri,,}" == mongodb+srv://* ]]; then
    echo "ERROR: $key cannot use mongodb+srv for local-safe test execution." >&2
    exit 1
  fi
  if [[ "${uri,,}" != mongodb://* ]]; then
    echo "ERROR: $key must be mongodb:// for local-safe test execution." >&2
    exit 1
  fi

  local authority="${uri#mongodb://}"
  authority="${authority%%/*}"
  authority="${authority##*@}"

  IFS=',' read -r -a nodes <<< "$authority"
  if [[ "${#nodes[@]}" -eq 0 ]]; then
    echo "ERROR: $key has no hosts." >&2
    exit 1
  fi

  for node in "${nodes[@]}"; do
    local trimmed="${node//[[:space:]]/}"
    local host
    if [[ "$trimmed" == \[* ]]; then
      host="${trimmed%%]*}]"
      host="${host#[}"
      host="${host%]}"
    else
      host="${trimmed%%:*}"
    fi
    host="${host,,}"

    if [[ -z "$host" ]] || ! contains_host "$host" "${ALLOWED_MONGO_HOSTS[@]}"; then
      echo "ERROR: $key contains non-local mongo host '$host' from URI '$uri'." >&2
      exit 1
    fi
  done
}

validate_http_host "$LOCAL_APP_URL"
validate_http_host "$LOCAL_APP_HOST"
validate_mongo_uri "LOCAL_DB_URI" "$LOCAL_DB_URI"
validate_mongo_uri "LOCAL_DB_URI_LANDLORD" "$LOCAL_DB_URI_LANDLORD"
validate_mongo_uri "LOCAL_DB_URI_TENANTS" "$LOCAL_DB_URI_TENANTS"

if ! docker compose ps "$APP_CONTAINER" >/dev/null 2>&1; then
  echo "ERROR: docker compose service '$APP_CONTAINER' is not available." >&2
  exit 1
fi

echo "INFO: running Laravel tests with forced local-safe environment."
docker compose exec -T \
  -e APP_URL="$LOCAL_APP_URL" \
  -e APP_HOST="$LOCAL_APP_HOST" \
  -e DB_URI="$LOCAL_DB_URI" \
  -e DB_URI_LANDLORD="$LOCAL_DB_URI_LANDLORD" \
  -e DB_URI_TENANTS="$LOCAL_DB_URI_TENANTS" \
  "$APP_CONTAINER" \
  php artisan test "$@"
