#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/delphi/run_navigation_reconcile_validation.sh <readonly|mutation|diagnostic>

Runs the canonical local web navigation runner only after reconcile-branch,
runtime bind-mount, and navigation-env preflight succeeds on the principal
checkout.

Project topology is configuration-owned. Defaults match the current PACED
Docker shape, but downstream projects may override:
  NAV_RECONCILE_SOURCE_REPOS="laravel-app flutter-app"
  NAV_RECONCILE_MOUNT_CHECKS="app:laravel-app:/var/www;nginx:web-app:/opt/flutter-web-shell"
  NAV_RECONCILE_READONLY_REQUIRED_ENV="NAV_LANDLORD_URL NAV_TENANT_URL"
  NAV_RECONCILE_MUTATION_REQUIRED_ENV="NAV_ADMIN_EMAIL NAV_ADMIN_PASSWORD"
  NAV_RUNNER="tools/flutter/run_web_navigation_smoke.sh"
  NAV_LOCAL_ENV_FILE=".env.local.navigation"
EOF
}

find_environment_root() {
  local start="$1"
  local current="$start"

  for _ in 1 2 3 4 5 6 7; do
    if [[ -f "$current/docker-compose.yml" && -d "$current/delphi-ai" ]]; then
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

append_words() {
  local raw="$1"
  local -n target_ref="$2"
  local item

  # shellcheck disable=SC2206
  local parts=($raw)
  for item in "${parts[@]}"; do
    [[ -n "$item" ]] || continue
    target_ref+=("$item")
  done
}

resolve_root_path() {
  local raw_path="$1"
  if [[ "$raw_path" == /* ]]; then
    printf '%s\n' "$raw_path"
  else
    printf '%s\n' "$ROOT_DIR/$raw_path"
  fi
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
  local env_file="${NAV_LOCAL_ENV_FILE:-$ROOT_DIR/.env.local.navigation}"
  local needs_env=0

  if [[ "$env_file" != /* ]]; then
    env_file="$ROOT_DIR/$env_file"
  fi
  NAV_RESOLVED_ENV_FILE="$env_file"

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
  NAV_RESOLVED_ENV_FILE="$env_file"
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
    echo "Resolution: export them in the current shell or provide ${NAV_RESOLVED_ENV_FILE:-$ROOT_DIR/.env.local.navigation} before rerunning." >&2
    echo "Project topology should be documented in foundation_documentation and mapped into NAV_* configuration for this runner." >&2
    return 1
  fi
}

if [[ $# -ne 1 ]]; then
  usage >&2
  exit 1
fi

SUITE="$1"
case "$SUITE" in
  readonly|mutation|diagnostic) ;;
  *)
    echo "ERROR: unsupported suite '$SUITE'. Expected readonly, mutation, or diagnostic." >&2
    usage >&2
    exit 1
    ;;
esac

declare -a READONLY_ENV_VARS=()
declare -a MUTATION_ENV_VARS=()
append_words "${NAV_RECONCILE_READONLY_REQUIRED_ENV:-${NAV_REQUIRED_READONLY_ENV:-NAV_LANDLORD_URL NAV_TENANT_URL}}" READONLY_ENV_VARS
append_words "${NAV_RECONCILE_MUTATION_REQUIRED_ENV:-${NAV_REQUIRED_MUTATION_ENV:-NAV_ADMIN_EMAIL NAV_ADMIN_PASSWORD}}" MUTATION_ENV_VARS

REQUIRED_ENV_VARS=("${READONLY_ENV_VARS[@]}")
if [[ "$SUITE" == "mutation" || "$SUITE" == "diagnostic" ]]; then
  REQUIRED_ENV_VARS+=("${MUTATION_ENV_VARS[@]}")
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(find_environment_root "$SCRIPT_DIR" || true)"

if [[ -z "$ROOT_DIR" ]]; then
  echo "ERROR: could not resolve environment root containing docker-compose.yml and delphi-ai." >&2
  exit 1
fi

cd "$ROOT_DIR"

if [[ -f "$ROOT_DIR/delphi-ai/tools/lib/script_usage.sh" ]]; then
  # shellcheck source=/dev/null
  source "$ROOT_DIR/delphi-ai/tools/lib/script_usage.sh"
  delphi_script_usage_init \
    --delphi-root "$ROOT_DIR/delphi-ai" \
    --script-id "root.run_navigation_reconcile_validation" \
    --script-path "scripts/delphi/run_navigation_reconcile_validation.sh" \
    --surface "root-script"
  delphi_script_usage_set_scenario "$SUITE"
  delphi_script_usage_install_exit_trap
fi

require_reconcile_branch "$ROOT_DIR" "Environment root"

declare -a SOURCE_REPOS=()
append_words "${NAV_RECONCILE_SOURCE_REPOS:-laravel-app flutter-app}" SOURCE_REPOS
for source_repo in "${SOURCE_REPOS[@]}"; do
  source_repo_path="$(resolve_root_path "$source_repo")"
  if [[ ! -d "$source_repo_path" ]]; then
    echo "ERROR: configured runtime-facing source checkout is missing: $source_repo" >&2
    echo "Resolution: update NAV_RECONCILE_SOURCE_REPOS or the project foundation documentation/runtime topology." >&2
    exit 1
  fi
  require_reconcile_branch "$source_repo_path" "$source_repo"
done

RUNNER="${NAV_RUNNER:-$ROOT_DIR/tools/flutter/run_web_navigation_smoke.sh}"
if [[ "$RUNNER" != /* ]]; then
  RUNNER="$ROOT_DIR/$RUNNER"
fi
if [[ ! -x "$RUNNER" ]]; then
  echo "ERROR: canonical web navigation runner is missing or not executable: $RUNNER" >&2
  echo "Resolution: set NAV_RUNNER or document the project-owned browser runner in foundation_documentation." >&2
  exit 1
fi

if [[ -z "${NAV_RECONCILE_MOUNT_CHECKS:-}" ]]; then
  NAV_RECONCILE_MOUNT_CHECKS=""
  if [[ -d "$ROOT_DIR/laravel-app" && -d "$ROOT_DIR/web-app" ]]; then
    NAV_RECONCILE_MOUNT_CHECKS="app:laravel-app:/var/www;app:web-app:/opt/flutter-web-shell;nginx:laravel-app:/var/www;nginx:web-app:/opt/flutter-web-shell"
  fi
fi

declare -A CONTAINER_BY_SERVICE=()
IFS=';' read -ra MOUNT_CHECK_ROWS <<< "$NAV_RECONCILE_MOUNT_CHECKS"
for mount_row in "${MOUNT_CHECK_ROWS[@]}"; do
  [[ -n "$mount_row" ]] || continue
  IFS=':' read -r service_name host_source container_target extra <<< "$mount_row"
  if [[ -z "${service_name:-}" || -z "${host_source:-}" || -z "${container_target:-}" || -n "${extra:-}" ]]; then
    echo "ERROR: invalid NAV_RECONCILE_MOUNT_CHECKS row: $mount_row" >&2
    echo "Expected format: service:host-relative-or-absolute-path:container-target-path;..." >&2
    exit 1
  fi
  if [[ -z "${CONTAINER_BY_SERVICE[$service_name]:-}" ]]; then
    CONTAINER_BY_SERVICE[$service_name]="$(require_compose_service_container "$service_name")"
  fi
  require_mount_source \
    "${CONTAINER_BY_SERVICE[$service_name]}" \
    "$service_name service" \
    "$(resolve_root_path "$host_source")" \
    "$container_target" \
    "$ROOT_DIR"
done

NAV_ENV_SOURCE=""
source_navigation_env_if_needed
verify_required_env

list_mutation_shards() {
  local manifest_path="${NAV_WEB_SHARD_MANIFEST:-$ROOT_DIR/tools/flutter/web_app_tests/navigation_mutation_shards.json}"
  node -e '
    const fs = require("fs");
    const manifest = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
    const shards = Object.keys((manifest.mutation && manifest.mutation.shards) || {});
    if (shards.length === 0) {
      process.exit(1);
    }
    for (const shard of shards) {
      console.log(shard);
    }
  ' "$manifest_path"
}

echo "INFO: authoritative navigation validation -> suite=$SUITE"
echo "INFO: navigation env source -> $NAV_ENV_SOURCE"
if [[ -n "$NAV_RECONCILE_MOUNT_CHECKS" ]]; then
  echo "INFO: runtime bind mounts -> principal checkout confirmed from NAV_RECONCILE_MOUNT_CHECKS"
else
  echo "INFO: runtime bind mounts -> no mount checks configured; branch/env preflight only"
fi

if [[ "$SUITE" == "mutation" && -z "${NAV_WEB_SHARD:-}" ]]; then
  mapfile -t MUTATION_SHARDS < <(list_mutation_shards)
  if [[ "${#MUTATION_SHARDS[@]}" -eq 0 ]]; then
    echo "ERROR: could not resolve mutation shard manifest for authoritative navigation validation." >&2
    exit 1
  fi

  for mutation_shard in "${MUTATION_SHARDS[@]}"; do
    [[ -n "$mutation_shard" ]] || continue
    echo "INFO: authoritative navigation validation -> mutation shard=$mutation_shard"
    NAV_WEB_SHARD="$mutation_shard" "$RUNNER" "$SUITE"
  done
  exit 0
fi

"$RUNNER" "$SUITE"
