#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$TMP_DIR/bin"

write_preflight_gh() {
  cat > "$TMP_DIR/bin/gh" <<'GH'
#!/usr/bin/env bash
set -euo pipefail

DOCKER_DEV_SHA="1111111111111111111111111111111111111111"
DOCKER_STAGE_SHA="2222222222222222222222222222222222222222"
DOCKER_MAIN_SHA="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
FLUTTER_DEV_SHA="3333333333333333333333333333333333333333"
FLUTTER_STAGE_SHA="4444444444444444444444444444444444444444"
FLUTTER_MAIN_SHA="bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
LARAVEL_DEV_SHA="5555555555555555555555555555555555555555"
LARAVEL_STAGE_SHA="6666666666666666666666666666666666666666"
LARAVEL_MAIN_SHA="cccccccccccccccccccccccccccccccccccccccc"
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
    test/laravel)
      target_sha="$LARAVEL_STAGE_SHA"
      sample_url="https://example.test/laravel-stage-run"
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
  repos/test/laravel/branches/dev)
    printf '%s\n' "$LARAVEL_DEV_SHA"
    ;;
  repos/test/laravel/branches/stage)
    printf '%s\n' "$LARAVEL_STAGE_SHA"
    ;;
  repos/test/laravel/branches/main)
    printf '%s\n' "$LARAVEL_MAIN_SHA"
    ;;
  repos/test/docker/compare/*)
    printf 'ahead\t0\t1\n'
    ;;
  repos/test/flutter/compare/"$FLUTTER_DEV_SHA"..."$FLUTTER_STAGE_SHA")
    printf 'behind\t11\t0\n'
    ;;
  repos/test/flutter/compare/"$FLUTTER_MAIN_SHA"..."$FLUTTER_STAGE_SHA")
    printf 'ahead\t0\t1\n'
    ;;
  repos/test/flutter/compare/"$FLUTTER_STAGE_SHA"..."$FLUTTER_MAIN_SHA")
    printf 'behind\t11\t0\n'
    ;;
  repos/test/laravel/compare/"$LARAVEL_DEV_SHA"..."$LARAVEL_STAGE_SHA")
    printf 'behind\t8\t0\n'
    ;;
  repos/test/laravel/compare/"$LARAVEL_MAIN_SHA"..."$LARAVEL_STAGE_SHA")
    printf 'ahead\t0\t1\n'
    ;;
  repos/test/laravel/compare/"$LARAVEL_STAGE_SHA"..."$LARAVEL_MAIN_SHA")
    printf 'behind\t8\t0\n'
    ;;
  repos/test/docker/commits/"$DOCKER_STAGE_SHA")
    printf '%s\n' "$DOCKER_TREE_SHA"
    ;;
  repos/test/docker/git/trees/"$DOCKER_TREE_SHA")
    if [[ "$jq_expr" == *"flutter-app"* ]]; then
      printf '%s\n' "$FLUTTER_STAGE_SHA"
    elif [[ "$jq_expr" == *"laravel-app"* ]]; then
      printf '%s\n' "$LARAVEL_STAGE_SHA"
    fi
    ;;
  repos/test/docker/actions/runs?per_page=100)
    actions_runs_output "test/docker" "$jq_expr"
    ;;
  repos/test/flutter/actions/runs?per_page=100)
    actions_runs_output "test/flutter" "$jq_expr"
    ;;
  repos/test/laravel/actions/runs?per_page=100)
    actions_runs_output "test/laravel" "$jq_expr"
    ;;
  *)
    printf 'unexpected gh api endpoint: %s\n' "$endpoint" >&2
    exit 1
    ;;
esac
GH
}

write_preflight_gh
chmod +x "$TMP_DIR/bin/gh"

AUTO_OUTPUT="$TMP_DIR/main-preflight-auto.out"

PATH="$TMP_DIR/bin:$PATH" bash "$ROOT_DIR/tools/github_main_promotion_preflight.sh" \
  --scenario auto \
  --docker-repo test/docker \
  --flutter-repo test/flutter \
  --laravel-repo test/laravel \
  --web-repo test/web \
  > "$AUTO_OUTPUT"

grep -q "Overall outcome: go" "$AUTO_OUTPUT"
grep -q "Requested scenario: auto" "$AUTO_OUTPUT"
grep -q "Effective scenario: flutter-laravel" "$AUTO_OUTPUT"
grep -q "scenario-inference | docker_repo=test/docker .* inferred_scenario=flutter-laravel" "$AUTO_OUTPUT"
grep -q "Docker | repo=test/docker .* push_runs=1 | push_runs_green=yes" "$AUTO_OUTPUT"
grep -q "Flutter | repo=test/flutter .* push_runs=1 | push_runs_green=yes" "$AUTO_OUTPUT"
grep -q "Laravel | repo=test/laravel .* push_runs=1 | push_runs_green=yes" "$AUTO_OUTPUT"
grep -q "docker-gitlink-flutter .* aligned=yes" "$AUTO_OUTPUT"
grep -q "docker-gitlink-laravel .* aligned=yes" "$AUTO_OUTPUT"

MISMATCH_OUTPUT="$TMP_DIR/main-preflight-mismatch.out"
set +e
PATH="$TMP_DIR/bin:$PATH" bash "$ROOT_DIR/tools/github_main_promotion_preflight.sh" \
  --scenario flutter-only \
  --docker-repo test/docker \
  --flutter-repo test/flutter \
  --laravel-repo test/laravel \
  --web-repo test/web \
  > "$MISMATCH_OUTPUT" 2>&1
status=$?
set -e

[ "$status" -eq 2 ]
grep -q "Overall outcome: no-go" "$MISMATCH_OUTPUT"
grep -q "Explicit scenario 'flutter-only' does not match the objectively inferred stage→main scenario 'flutter-laravel'" "$MISMATCH_OUTPUT"
grep -q "Rerun with '--scenario auto' or '--scenario flutter-laravel'" "$MISMATCH_OUTPUT"

printf 'github_main_promotion_preflight_test: OK\n'
