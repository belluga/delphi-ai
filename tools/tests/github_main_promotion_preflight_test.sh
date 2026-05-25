#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$TMP_DIR/bin"

cat > "$TMP_DIR/bin/gh" <<'GH'
#!/usr/bin/env bash
set -euo pipefail

DOCKER_DEV_SHA="1111111111111111111111111111111111111111"
DOCKER_STAGE_SHA="2222222222222222222222222222222222222222"
DOCKER_MAIN_SHA="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
FLUTTER_DEV_SHA="3333333333333333333333333333333333333333"
FLUTTER_STAGE_SHA="4444444444444444444444444444444444444444"
FLUTTER_MAIN_SHA="bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
DOCKER_TREE_SHA="5555555555555555555555555555555555555555"

extract_jq() {
  local previous=""
  local token
  for token in "$@"; do
    if [ "$previous" = "--jq" ]; then
      printf '%s' "$token"
      return 0
    fi
    previous="$token"
  done
}

actions_runs_output() {
  local repo="$1"
  local jq_expr="$2"
  local target_sha=""
  local sample_url=""

  case "$repo" in
    test/docker)
      target_sha="$DOCKER_STAGE_SHA"
      sample_url="https://example.test/docker-stage-run"
      ;;
    test/flutter)
      target_sha="$FLUTTER_STAGE_SHA"
      sample_url="https://example.test/flutter-stage-run"
      ;;
  esac

  if [[ "$jq_expr" != *"$target_sha"* ]]; then
    if [[ "$jq_expr" == *"| length"* ]]; then
      printf '0\n'
    fi
    return 0
  fi

  if [[ "$jq_expr" == *'.status != "completed"'* ]] || [[ "$jq_expr" == *'.conclusion != "success"'* ]]; then
    printf '0\n'
    return 0
  fi

  if [[ "$jq_expr" == *"| length"* ]]; then
    printf '1\n'
    return 0
  fi

  printf 'Orchestration CI/CD\tcompleted\tsuccess\t%s\n' "$sample_url"
}

if [ "${1:-}" = "auth" ] && [ "${2:-}" = "status" ]; then
  exit 0
fi

if [ "${1:-}" = "run" ] && [ "${2:-}" = "list" ]; then
  # Regression guard: the preflight must not rely on this path for
  # branch/event filtered push-run evidence. It is intentionally false-empty.
  jq_expr="$(extract_jq "$@")"
  if [[ "$jq_expr" == *"| length"* ]]; then
    printf '0\n'
  fi
  exit 0
fi

if [ "${1:-}" != "api" ]; then
  printf 'unexpected gh command: %s\n' "$*" >&2
  exit 1
fi

endpoint="${2:-}"
jq_expr="$(extract_jq "$@")"

case "$endpoint" in
  repos/test/docker/branches/dev)
    printf '%s\n' "$DOCKER_DEV_SHA"
    ;;
  repos/test/docker/branches/stage)
    printf '%s\n' "$DOCKER_STAGE_SHA"
    ;;
  repos/test/docker/branches/main)
    printf '%s\n' "$DOCKER_MAIN_SHA"
    ;;
  repos/test/flutter/branches/dev)
    printf '%s\n' "$FLUTTER_DEV_SHA"
    ;;
  repos/test/flutter/branches/stage)
    printf '%s\n' "$FLUTTER_STAGE_SHA"
    ;;
  repos/test/flutter/branches/main)
    printf '%s\n' "$FLUTTER_MAIN_SHA"
    ;;
  repos/test/docker/compare/*)
    printf 'ahead\t0\t1\n'
    ;;
  repos/test/flutter/compare/*)
    printf 'ahead\t0\t1\n'
    ;;
  repos/test/docker/commits/"$DOCKER_STAGE_SHA")
    printf '%s\n' "$DOCKER_TREE_SHA"
    ;;
  repos/test/docker/git/trees/"$DOCKER_TREE_SHA")
    printf '%s\n' "$FLUTTER_STAGE_SHA"
    ;;
  repos/test/docker/actions/runs?per_page=100)
    actions_runs_output "test/docker" "$jq_expr"
    ;;
  repos/test/flutter/actions/runs?per_page=100)
    actions_runs_output "test/flutter" "$jq_expr"
    ;;
  *)
    printf 'unexpected gh api endpoint: %s\n' "$endpoint" >&2
    exit 1
    ;;
esac
GH

chmod +x "$TMP_DIR/bin/gh"

OUTPUT_FILE="$TMP_DIR/main-preflight.out"
FLUTTER_STAGE_SHA="4444444444444444444444444444444444444444"

PATH="$TMP_DIR/bin:$PATH" bash "$ROOT_DIR/tools/github_main_promotion_preflight.sh" \
  --scenario flutter-only \
  --docker-repo test/docker \
  --flutter-repo test/flutter \
  --web-repo test/web \
  > "$OUTPUT_FILE"

grep -q "Overall outcome: go" "$OUTPUT_FILE"
grep -q "Docker | repo=test/docker .* push_runs=1 | push_runs_green=yes" "$OUTPUT_FILE"
grep -q "Flutter | repo=test/flutter .* push_runs=1 | push_runs_green=yes" "$OUTPUT_FILE"
grep -q "docker-gitlink-flutter .* actual_sha=$FLUTTER_STAGE_SHA .* aligned=yes" "$OUTPUT_FILE"

printf 'github_main_promotion_preflight_test: OK\n'
