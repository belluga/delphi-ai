#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/delphi/run_navigation_reconcile_validation.sh <readonly|mutation>

Runs the canonical local web navigation runner only after reconcile-branch,
runtime bind-mount, and navigation-env preflight succeeds on the principal
checkout.
EOF
}

find_environment_root() {
  local start="$1"
  local current="$start"

  for _ in 1 2 3 4 5 6 7; do
    if [[ -f "$current/docker-compose.yml" && -d "$current/laravel-app" && -d "$current/flutter-app" && -d "$current/delphi-ai" ]]; then
      printf '%s\n' "$current"
      return 0
    fi
    current="$(cd "$current/.." && pwd 2>/dev/null || true)"
    if [[ -z "$current" ]]; then
      break
    fi
  done

  return 1
}

require_reconcile_branch() {
  local repo_path="$1"
  local label="$2"
  local branch

  branch="$(git -C "$repo_path" branch --show-current)"
  if [[ -z "$branch" ]]; then
    echo "ERROR: could not resolve current branch for $label checkout at $repo_path." >&2
    return 1
  fi

  if [[ ! "$branch" =~ ^reconcile/ ]]; then
    echo "ERROR: $label principal checkout must be on a reconcile/* branch for authoritative navigation validation. Current branch: $branch" >&2
    return 1
  fi
}

require_compose_service_container() {
  local service="$1"
  local container_id

  container_id="$(docker compose ps -q "$service" 2>/dev/null || true)"
  if [[ -z "$container_id" ]]; then
    echo "ERROR: docker compose service '$service' is not running in the principal checkout." >&2
    return 1
  fi

  printf '%s\n' "$container_id"
}

require_mount_source() {
  local container_id="$1"
  local label="$2"
  local host_path="$3"
  local target_path="$4"
  local root_dir="$5"
  local bind_mounts
  local project_working_dir
  local project_config_files

  bind_mounts="$(docker inspect --format '{{range .Mounts}}{{if eq .Type "bind"}}{{printf "%s|%s\n" .Source .Destination}}{{end}}{{end}}' "$container_id")"
  if grep -Fx -- "${host_path}|${target_path}" <<<"$bind_mounts" >/dev/null; then
    return 0
  fi

  # Docker Desktop on WSL can replace bind mount sources with internal proxy paths.
  # In that case, trust the compose project metadata only when the container comes
  # from this principal checkout and the expected bind target is still present.
  if grep -Eq "^[^|]+\\|${target_path}$" <<<"$bind_mounts"; then
    project_working_dir="$(docker inspect --format '{{index .Config.Labels "com.docker.compose.project.working_dir"}}' "$container_id")"
    project_config_files="$(docker inspect --format '{{index .Config.Labels "com.docker.compose.project.config_files"}}' "$container_id")"

    if [[ "$project_working_dir" == "$root_dir" && "$project_config_files" == *"$root_dir/docker-compose.yml"* ]]; then
      return 0
    fi
  fi

  echo "ERROR: $label is not mounted from the principal checkout path: $host_path" >&2
  return 1
}

source_navigation_env_if_needed() {
  local env_file="$ROOT_DIR/.env.local.navigation"
  local needs_env=0

  for var_name in "${REQUIRED_ENV_VARS[@]}"; do
    if [[ -z "${!var_name:-}" ]]; then
      needs_env=1
      break
    fi
  done

  if [[ "$needs_env" -eq 0 ]]; then
    NAV_ENV_SOURCE="current shell"
    return 0
  fi

  if [[ -f "$env_file" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "$env_file"
    set +a
    NAV_ENV_SOURCE="$env_file"
    return 0
  fi

  NAV_ENV_SOURCE="missing"
  return 0
}

verify_required_env() {
  local missing=()
  local var_name

  for var_name in "${REQUIRED_ENV_VARS[@]}"; do
    if [[ -z "${!var_name:-}" ]]; then
      missing+=("$var_name")
    fi
  done

  if [[ "${#missing[@]}" -gt 0 ]]; then
    echo "ERROR: missing required navigation env: ${missing[*]}" >&2
    echo "Resolution: export them in the current shell or provide $ROOT_DIR/.env.local.navigation before rerunning." >&2
    return 1
  fi
}

if [[ $# -ne 1 ]]; then
  usage >&2
  exit 1
fi

SUITE="$1"
case "$SUITE" in
  readonly|mutation) ;;
  *)
    echo "ERROR: unsupported suite '$SUITE'. Expected readonly or mutation." >&2
    usage >&2
    exit 1
    ;;
esac

declare -a REQUIRED_ENV_VARS=("NAV_LANDLORD_URL" "NAV_TENANT_URL")
if [[ "$SUITE" == "mutation" ]]; then
  REQUIRED_ENV_VARS+=("NAV_ADMIN_EMAIL" "NAV_ADMIN_PASSWORD")
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(find_environment_root "$SCRIPT_DIR" || true)"

if [[ -z "$ROOT_DIR" ]]; then
  echo "ERROR: could not resolve environment root containing docker-compose.yml, laravel-app, flutter-app, and delphi-ai." >&2
  exit 1
fi

cd "$ROOT_DIR"

require_reconcile_branch "$ROOT_DIR" "Environment root"
require_reconcile_branch "$ROOT_DIR/laravel-app" "Laravel"
require_reconcile_branch "$ROOT_DIR/flutter-app" "Flutter"

RUNNER="$ROOT_DIR/tools/flutter/run_web_navigation_smoke.sh"
if [[ ! -x "$RUNNER" ]]; then
  echo "ERROR: canonical web navigation runner is missing or not executable: $RUNNER" >&2
  exit 1
fi

APP_CONTAINER_ID="$(require_compose_service_container app)"
NGINX_CONTAINER_ID="$(require_compose_service_container nginx)"

require_mount_source "$APP_CONTAINER_ID" "app service" "$ROOT_DIR/laravel-app" "/var/www" "$ROOT_DIR"
require_mount_source "$APP_CONTAINER_ID" "app service" "$ROOT_DIR/web-app" "/opt/flutter-web-shell" "$ROOT_DIR"
require_mount_source "$NGINX_CONTAINER_ID" "nginx service" "$ROOT_DIR/laravel-app" "/var/www" "$ROOT_DIR"
require_mount_source "$NGINX_CONTAINER_ID" "nginx service" "$ROOT_DIR/web-app" "/var/www/flutter" "$ROOT_DIR"

NAV_ENV_SOURCE=""
source_navigation_env_if_needed
verify_required_env

echo "INFO: authoritative navigation validation -> suite=$SUITE"
echo "INFO: navigation env source -> $NAV_ENV_SOURCE"
echo "INFO: runtime bind mounts -> principal checkout confirmed for app/nginx"

export NAV_DEPLOY_LANE="${NAV_DEPLOY_LANE:-local}"
"$RUNNER" "$SUITE"
