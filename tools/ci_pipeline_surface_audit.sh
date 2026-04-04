#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ci_pipeline_surface_audit.sh [--repo <path>] [--expect <flutter|laravel|docker>] [--expect <...> ...]

Audit CI/pipeline workflow surfaces in a repository and summarize whether the expected
stack coverage appears to exist. This is a deterministic inventory/report helper only;
pipeline design tradeoffs remain human.
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

REPO_INPUT="."
declare -a EXPECTED_STACKS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --repo)
      [ $# -ge 2 ] || die "missing value for --repo"
      REPO_INPUT="$2"
      shift 2
      ;;
    --expect)
      [ $# -ge 2 ] || die "missing value for --expect"
      case "$2" in
        flutter|laravel|docker) ;;
        *) die "invalid --expect value: $2" ;;
      esac
      EXPECTED_STACKS+=("$2")
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

declare -a PIPELINE_FILES=()
while IFS= read -r file; do
  PIPELINE_FILES+=("$file")
done < <(
  find "$REPO_ROOT/.github/workflows" -maxdepth 1 -type f \( -name '*.yml' -o -name '*.yaml' \) 2>/dev/null
  find "$REPO_ROOT/.gitlab-ci.d" -maxdepth 1 -type f \( -name '*.yml' -o -name '*.yaml' \) 2>/dev/null
  find "$REPO_ROOT" -maxdepth 1 -type f \( -name '.gitlab-ci.yml' -o -name '.gitlab-ci.yaml' \) 2>/dev/null
)

flutter_global=false
laravel_global=false
docker_global=false
cache_global=false
permission_global=false

declare -a FINDINGS=()
declare -a FILE_SUMMARY_LINES=()

for file in "${PIPELINE_FILES[@]}"; do
  rel="${file#$REPO_ROOT/}"
  file_output=()

  if rg -n '\b(fvm\s+)?flutter\s+analyze\b|\b(fvm\s+)?flutter\s+test\b|\bdart\s+test\b|\bflutter\s+drive\b' "$file" >/dev/null 2>&1; then
    flutter_global=true
    file_output+=("flutter hints: yes")
  else
    file_output+=("flutter hints: no")
  fi

  if rg -n '\bphp artisan test\b|\bcomposer test\b|\bpest\b|run_laravel_tests_safe\.sh' "$file" >/dev/null 2>&1; then
    laravel_global=true
    file_output+=("laravel hints: yes")
  else
    file_output+=("laravel hints: no")
  fi

  if rg -n '\bdocker (compose )?build\b|\bdocker buildx\b|\bdocker push\b|\bdocker compose up\b' "$file" >/dev/null 2>&1; then
    docker_global=true
    file_output+=("docker hints: yes")
  else
    file_output+=("docker hints: no")
  fi

  if rg -n 'actions/cache|cache:' "$file" >/dev/null 2>&1; then
    cache_global=true
    file_output+=("cache hints: yes")
  else
    file_output+=("cache hints: no")
  fi

  if rg -n 'permissions:|secrets\.|env:' "$file" >/dev/null 2>&1; then
    permission_global=true
    file_output+=("permissions/secrets hints: yes")
  else
    file_output+=("permissions/secrets hints: no")
  fi

  if [[ "$rel" == .github/workflows/* ]] && ! rg -n '^\s*jobs:' "$file" >/dev/null 2>&1; then
    FINDINGS+=("$rel looks unlike a normal GitHub Actions workflow (missing top-level jobs:)")
  fi

  FILE_SUMMARY_LINES+=("$rel")
  for line in "${file_output[@]}"; do
    FILE_SUMMARY_LINES+=("  - $line")
  done
  FILE_SUMMARY_LINES+=("")
done

overall_status="ready"

if [ "${#PIPELINE_FILES[@]}" -eq 0 ]; then
  overall_status="blocked"
  FINDINGS+=("no pipeline files were found under .github/workflows or .gitlab-ci*")
fi

for stack in "${EXPECTED_STACKS[@]}"; do
  case "$stack" in
    flutter)
      if [ "$flutter_global" != true ]; then
        overall_status="blocked"
        FINDINGS+=("expected Flutter coverage but no Flutter analyzer/test hints were found")
      fi
      ;;
    laravel)
      if [ "$laravel_global" != true ]; then
        overall_status="blocked"
        FINDINGS+=("expected Laravel coverage but no Laravel test hints were found")
      fi
      ;;
    docker)
      if [ "$docker_global" != true ]; then
        overall_status="blocked"
        FINDINGS+=("expected Docker coverage but no Docker build/publish hints were found")
      fi
      ;;
  esac
done

printf 'CI Pipeline Surface Audit\n'
printf 'Repository: %s\n' "$REPO_ROOT"
printf 'Expected stacks: %s\n' "${EXPECTED_STACKS[*]:-none recorded}"
printf '\n'

printf 'Workflow files\n'
if [ "${#FILE_SUMMARY_LINES[@]}" -eq 0 ]; then
  printf '  - none found\n'
else
  for line in "${FILE_SUMMARY_LINES[@]}"; do
    [ -n "$line" ] && printf '%s\n' "$line" || printf '\n'
  done
fi
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

printf 'Capability summary\n'
printf '  - flutter hints found: %s\n' "$flutter_global"
printf '  - laravel hints found: %s\n' "$laravel_global"
printf '  - docker hints found: %s\n' "$docker_global"
printf '  - cache hints found: %s\n' "$cache_global"
printf '  - permissions/secrets hints found: %s\n' "$permission_global"
printf '\n'

printf 'Overall outcome: %s\n' "$overall_status"

if [ "$overall_status" = "ready" ]; then
  exit 0
fi

exit 2
