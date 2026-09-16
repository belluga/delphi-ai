#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$TMP_DIR/bin"

write_stage_completion_gh() {
  cat > "$TMP_DIR/bin/gh" <<'GH'
#!/usr/bin/env bash
set -euo pipefail

DOCKER_DEV_SHA="1111111111111111111111111111111111111111"
DOCKER_STAGE_SHA="2222222222222222222222222222222222222222"
FLUTTER_DEV_SHA="3333333333333333333333333333333333333333"
FLUTTER_STAGE_SHA="4444444444444444444444444444444444444444"
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
  # Regression guard: the completion helper must not rely on this path for
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
  repos/test/flutter/branches/dev)
    printf '%s\n' "$FLUTTER_DEV_SHA"
    ;;
  repos/test/flutter/branches/stage)
    printf '%s\n' "$FLUTTER_STAGE_SHA"
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
}

write_main_completion_gh() {
  cat > "$TMP_DIR/bin/gh" <<'GH'
#!/usr/bin/env bash
set -euo pipefail

DOCKER_STAGE_SHA="1111111111111111111111111111111111111111"
DOCKER_MAIN_SHA="2222222222222222222222222222222222222222"
FLUTTER_STAGE_SHA="3333333333333333333333333333333333333333"
FLUTTER_MAIN_SHA="4444444444444444444444444444444444444444"
LARAVEL_STAGE_SHA="5555555555555555555555555555555555555555"
LARAVEL_MAIN_SHA="6666666666666666666666666666666666666666"
WEB_MAIN_SHA="7777777777777777777777777777777777777777"
DOCKER_MAIN_TREE_SHA="8888888888888888888888888888888888888888"

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
      target_sha="$DOCKER_MAIN_SHA"
      sample_url="https://example.test/docker-main-run"
      ;;
    test/flutter)
      target_sha="$FLUTTER_MAIN_SHA"
      sample_url="https://example.test/flutter-main-run"
      ;;
    test/laravel)
      target_sha="$LARAVEL_MAIN_SHA"
      sample_url="https://example.test/laravel-main-run"
      ;;
    test/web)
      target_sha="$WEB_MAIN_SHA"
      sample_url="https://example.test/web-main-run"
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

  printf 'Main CI\tcompleted\tsuccess\t%s\n' "$sample_url"
}

if [ "${1:-}" = "auth" ] && [ "${2:-}" = "status" ]; then
  exit 0
fi

if [ "${1:-}" = "run" ] && [ "${2:-}" = "list" ]; then
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
  repos/test/docker/branches/stage)
    printf '%s\n' "$DOCKER_STAGE_SHA"
    ;;
  repos/test/docker/branches/main)
    printf '%s\n' "$DOCKER_MAIN_SHA"
    ;;
  repos/test/flutter/branches/stage)
    printf '%s\n' "$FLUTTER_STAGE_SHA"
    ;;
  repos/test/flutter/branches/main)
    printf '%s\n' "$FLUTTER_MAIN_SHA"
    ;;
  repos/test/laravel/branches/stage)
    printf '%s\n' "$LARAVEL_STAGE_SHA"
    ;;
  repos/test/laravel/branches/main)
    printf '%s\n' "$LARAVEL_MAIN_SHA"
    ;;
  repos/test/web/branches/main)
    printf '%s\n' "$WEB_MAIN_SHA"
    ;;
  repos/test/docker/compare/"$DOCKER_STAGE_SHA"..."$DOCKER_MAIN_SHA")
    printf 'ahead\t0\t1\n'
    ;;
  repos/test/flutter/compare/"$FLUTTER_STAGE_SHA"..."$FLUTTER_MAIN_SHA")
    printf 'ahead\t0\t1\n'
    ;;
  repos/test/laravel/compare/"$LARAVEL_STAGE_SHA"..."$LARAVEL_MAIN_SHA")
    printf 'ahead\t0\t1\n'
    ;;
  repos/test/docker/commits/"$DOCKER_MAIN_SHA")
    printf '%s\n' "$DOCKER_MAIN_TREE_SHA"
    ;;
  repos/test/docker/git/trees/"$DOCKER_MAIN_TREE_SHA")
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
  repos/test/web/actions/runs?per_page=100)
    actions_runs_output "test/web" "$jq_expr"
    ;;
  *)
    printf 'unexpected gh api endpoint: %s\n' "$endpoint" >&2
    exit 1
    ;;
esac
GH
}

write_stage_completion_gh
chmod +x "$TMP_DIR/bin/gh"

OUTPUT_FILE="$TMP_DIR/completion-guard.out"
FLUTTER_STAGE_SHA="4444444444444444444444444444444444444444"

PATH="$TMP_DIR/bin:$PATH" bash "$ROOT_DIR/tools/github_promotion_completion_guard.sh" \
  --lane stage \
  --scenario flutter-only \
  --docker-repo test/docker \
  --flutter-repo test/flutter \
  > "$OUTPUT_FILE"

grep -q "Overall outcome: go" "$OUTPUT_FILE"
grep -q "Docker | repo=test/docker .* push_runs=1 | push_runs_green=yes" "$OUTPUT_FILE"
grep -q "Flutter | repo=test/flutter .* push_runs=1 | push_runs_green=yes" "$OUTPUT_FILE"
grep -q "docker-gitlink-flutter .* actual_sha=$FLUTTER_STAGE_SHA .* aligned_by=exact" "$OUTPUT_FILE"

AUTO_ERROR_OUTPUT="$TMP_DIR/completion-guard-auto-error.out"
set +e
PATH="$TMP_DIR/bin:$PATH" bash "$ROOT_DIR/tools/github_promotion_completion_guard.sh" \
  --lane main \
  --scenario auto \
  --docker-repo test/docker \
  --flutter-repo test/flutter \
  --laravel-repo test/laravel \
  --web-repo test/web \
  > "$AUTO_ERROR_OUTPUT" 2>&1
status=$?
set -e

[ "$status" -eq 1 ]
grep -q "unsupported --scenario value: auto" "$AUTO_ERROR_OUTPUT"

write_main_completion_gh
chmod +x "$TMP_DIR/bin/gh"

MAIN_OUTPUT="$TMP_DIR/completion-guard-main.out"

PATH="$TMP_DIR/bin:$PATH" bash "$ROOT_DIR/tools/github_promotion_completion_guard.sh" \
  --lane main \
  --scenario flutter-laravel \
  --docker-repo test/docker \
  --flutter-repo test/flutter \
  --laravel-repo test/laravel \
  --web-repo test/web \
  > "$MAIN_OUTPUT"

grep -q "Overall outcome: go" "$MAIN_OUTPUT"
grep -q "Scenario: flutter-laravel" "$MAIN_OUTPUT"
grep -q "Docker | repo=test/docker .* push_runs=1 | push_runs_green=yes" "$MAIN_OUTPUT"
grep -q "Flutter | repo=test/flutter .* push_runs=1 | push_runs_green=yes" "$MAIN_OUTPUT"
grep -q "Laravel | repo=test/laravel .* push_runs=1 | push_runs_green=yes" "$MAIN_OUTPUT"
grep -q "Web follow-through | repo=test/web .* push_runs=1 | push_runs_green=yes" "$MAIN_OUTPUT"
grep -q "docker-gitlink-flutter .* aligned_by=ancestry" "$MAIN_OUTPUT"
grep -q "docker-gitlink-laravel .* aligned_by=ancestry" "$MAIN_OUTPUT"

printf 'github_promotion_completion_guard_test: OK\n'
