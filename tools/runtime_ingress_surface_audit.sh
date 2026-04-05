#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: runtime_ingress_surface_audit.sh [--repo <path>]

Audit Docker/runtime/ingress surfaces in a repository and perform non-mutating checks
that are relevant before runtime or ingress changes. This is a deterministic surface
inventory helper only; runtime design and parity decisions remain human.
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

REPO_INPUT="."

while [ $# -gt 0 ]; do
  case "$1" in
    --repo)
      [ $# -ge 2 ] || die "missing value for --repo"
      REPO_INPUT="$2"
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

declare -a DOCKERFILES=()
declare -a COMPOSE_FILES=()
declare -a INGRESS_FILES=()
declare -a ROUTE_FILES=()
declare -a FINDINGS=()

while IFS= read -r file; do
  DOCKERFILES+=("$file")
done < <(find "$REPO_ROOT" -type f -iname 'Dockerfile*' 2>/dev/null | sort)

for compose_name in docker-compose.yml docker-compose.yaml compose.yml compose.yaml; do
  if [ -f "$REPO_ROOT/$compose_name" ]; then
    COMPOSE_FILES+=("$REPO_ROOT/$compose_name")
  fi
done

while IFS= read -r file; do
  INGRESS_FILES+=("$file")
done < <(
  find "$REPO_ROOT/docker" "$REPO_ROOT/nginx" "$REPO_ROOT/infra" "$REPO_ROOT/deploy" "$REPO_ROOT/k8s" \
    -type f \( -iname '*nginx*' -o -iname '*ingress*' -o -iname '*traefik*' -o -iname '*caddy*' -o -name '*.conf' -o -name '*.template' -o -name '*.yaml' -o -name '*.yml' \) \
    2>/dev/null | sort
)

while IFS= read -r file; do
  ROUTE_FILES+=("$file")
done < <(find "$REPO_ROOT/laravel-app/routes" -type f -name '*.php' 2>/dev/null | sort)

compose_status="skip"
compose_output="no compose file found"
if [ "${#COMPOSE_FILES[@]}" -gt 0 ]; then
  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    if compose_output="$(cd "$REPO_ROOT" && docker compose config 2>&1)"; then
      compose_status="pass"
      compose_output="docker compose config: ok"
    else
      compose_status="fail"
      FINDINGS+=("docker compose config failed")
    fi
  else
    compose_status="blocked"
    compose_output="docker compose v2 unavailable"
    FINDINGS+=("docker compose v2 is unavailable for compose verification")
  fi
fi

storage_alias_issue=false
for file in "${INGRESS_FILES[@]}"; do
  if rg -n '/storage|alias\s+.+storage' "$file" >/dev/null 2>&1 && ! rg -n 'try_files \$request_filename =404;' "$file" >/dev/null 2>&1; then
    storage_alias_issue=true
    FINDINGS+=("${file#$REPO_ROOT/} references storage without the try_files alias invariant")
  fi
done

overall_status="ready"
if [ "${#DOCKERFILES[@]}" -eq 0 ] && [ "${#COMPOSE_FILES[@]}" -eq 0 ] && [ "${#INGRESS_FILES[@]}" -eq 0 ]; then
  overall_status="blocked"
  FINDINGS+=("no Dockerfile, compose, or ingress surfaces were found")
fi
if [ "$compose_status" = "fail" ] || [ "$compose_status" = "blocked" ] || [ "$storage_alias_issue" = true ]; then
  overall_status="blocked"
fi

print_rel_list() {
  local title="$1"
  shift
  printf '%s\n' "$title"
  if [ "$#" -eq 0 ]; then
    printf '  - none\n'
  else
    local file
    for file in "$@"; do
      printf '  - %s\n' "${file#$REPO_ROOT/}"
    done
  fi
  printf '\n'
}

printf 'Runtime & Ingress Surface Audit\n'
printf 'Repository: %s\n' "$REPO_ROOT"
printf '\n'

print_rel_list "Dockerfiles" "${DOCKERFILES[@]}"
print_rel_list "Compose files" "${COMPOSE_FILES[@]}"
print_rel_list "Ingress/runtime config files" "${INGRESS_FILES[@]}"
print_rel_list "Laravel route files" "${ROUTE_FILES[@]}"

printf 'Compose verification\n'
printf '  - status: %s\n' "$compose_status"
printf '  - output: %s\n' "$compose_output"
printf '\n'

if [ "${#FINDINGS[@]}" -eq 0 ]; then
  printf 'Findings\n  - none\n\n'
else
  printf 'Findings\n'
  for finding in "${FINDINGS[@]}"; do
    printf '  - %s\n' "$finding"
  done
  printf '\n'
fi

printf 'Overall outcome: %s\n' "$overall_status"

if [ "$overall_status" = "ready" ]; then
  exit 0
fi

exit 2
