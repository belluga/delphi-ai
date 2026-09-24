#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT_DIR/scripts/docker/delphi/run_navigation_reconcile_validation.sh"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

FAKE_ROOT="$TMP_DIR/project"
FAKE_SCRIPT="$FAKE_ROOT/scripts/docker/delphi/run_navigation_reconcile_validation.sh"
mkdir -p "$FAKE_ROOT/delphi-ai" "$FAKE_ROOT/laravel-app" "$FAKE_ROOT/flutter-app" "$FAKE_ROOT/bin" "$(dirname "$FAKE_SCRIPT")"
touch "$FAKE_ROOT/docker-compose.yml"
OUTPUT_FILE="$TMP_DIR/navigation-wrapper.out"
cp "$SCRIPT" "$FAKE_SCRIPT"
chmod +x "$FAKE_SCRIPT"
export FAKE_ROOT

cat > "$FAKE_ROOT/runner.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf 'suite=%s\n' "$1"
printf 'lane=%s\n' "${NAV_DEPLOY_LANE-unset}"
printf 'db_mutation=%s\n' "${NAV_RUNTIME_DB_MUTATION_ALLOWED-unset}"
EOF
chmod +x "$FAKE_ROOT/runner.sh"

cat > "$FAKE_ROOT/bin/git" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" == "-C" ]]; then
  shift 2
fi
if [[ "${1:-}" == "branch" && "${2:-}" == "--show-current" ]]; then
  printf 'reconcile/test\n'
  exit 0
fi
echo "unexpected git invocation: $*" >&2
exit 1
EOF
chmod +x "$FAKE_ROOT/bin/git"

cat > "$FAKE_ROOT/bin/docker" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" == "compose" && "${2:-}" == "ps" && "${3:-}" == "-q" ]]; then
  printf 'container-%s\n' "${4:-service}"
  exit 0
fi
if [[ "${1:-}" == "inspect" ]]; then
  if [[ "${2:-}" == "--format" ]]; then
    format="${3:-}"
    container="${4:-}"
    if [[ "$format" == *".Mounts"* ]]; then
      case "$container" in
        container-app)
          printf '%s|%s\n' "$FAKE_ROOT/laravel-app" "/var/www"
          ;;
        container-nginx)
          printf '%s|%s\n' "$FAKE_ROOT/flutter-app" "/var/www/flutter"
          ;;
        *)
          ;;
      esac
      exit 0
    fi
    if [[ "$format" == *"project.working_dir"* ]]; then
      printf '%s\n' "$FAKE_ROOT"
      exit 0
    fi
    if [[ "$format" == *"project.config_files"* ]]; then
      printf '%s/docker-compose.yml\n' "$FAKE_ROOT"
      exit 0
    fi
  fi
fi
echo "unexpected docker invocation: $*" >&2
exit 1
EOF
chmod +x "$FAKE_ROOT/bin/docker"

export PATH="$FAKE_ROOT/bin:$PATH"
export NAV_RECONCILE_SOURCE_REPOS="laravel-app flutter-app"
export NAV_RECONCILE_MOUNT_CHECKS="app:laravel-app:/var/www;nginx:flutter-app:/var/www/flutter"
export NAV_RECONCILE_READONLY_REQUIRED_ENV="NAV_LANDLORD_URL NAV_TENANT_URL"
export NAV_RECONCILE_MUTATION_REQUIRED_ENV="NAV_ADMIN_EMAIL NAV_ADMIN_PASSWORD"
export NAV_RUNNER="$FAKE_ROOT/runner.sh"
export NAV_LANDLORD_URL="http://localhost:8080"
export NAV_TENANT_URL="http://localhost:8081"
export NAV_ADMIN_EMAIL="admin@example.com"
export NAV_ADMIN_PASSWORD="secret"

bash "$FAKE_SCRIPT" diagnostic > "$OUTPUT_FILE"
grep -q '^suite=diagnostic$' "$OUTPUT_FILE"
grep -q '^lane=unset$' "$OUTPUT_FILE"
grep -q '^db_mutation=unset$' "$OUTPUT_FILE"

printf 'run_navigation_reconcile_validation_test: OK\n'
