#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

make_repo() {
  local repo="$1"
  mkdir -p "$repo"
  git -C "$repo" init -q
  git -C "$repo" config user.email test@example.test
  git -C "$repo" config user.name "Test User"
}

commit_all() {
  local repo="$1"
  local message="$2"
  git -C "$repo" add -A
  git -C "$repo" commit -q -m "$message"
}

classify_expect() {
  local repo="$1"
  local source="$2"
  local expected="$3"
  local expected_surface="${4:-}"
  local expected_docker_diff_shape="${5:-}"
  local output="$TMP_DIR/out.txt"

  python3 "$ROOT_DIR/tools/github_stage_promotion_scenario_classifier.py" \
    --repo "$repo" \
    --base dev \
    --source "$source" \
    --expected-scenario "$expected" \
    >"$output"
  grep -q "Overall outcome: go" "$output"
  grep -q "scenario: $expected" "$output"
  if [ -n "$expected_surface" ]; then
    grep -q "primary_surface: $expected_surface" "$output"
  fi
  if [ -n "$expected_docker_diff_shape" ]; then
    grep -q "docker_diff_shape: $expected_docker_diff_shape" "$output"
  fi
}

DOCKER_NORMAL="$TMP_DIR/docker-normal"
make_repo "$DOCKER_NORMAL"
cat >"$DOCKER_NORMAL/docker-compose.yml" <<'YAML'
services:
  app:
    image: example/app
YAML
commit_all "$DOCKER_NORMAL" initial
git -C "$DOCKER_NORMAL" branch dev
git -C "$DOCKER_NORMAL" checkout -q -b feature/docker-normal dev
cat >"$DOCKER_NORMAL/Dockerfile" <<'EOF_DOCKER'
FROM alpine:3.20
EOF_DOCKER
commit_all "$DOCKER_NORMAL" "Add Dockerfile"
classify_expect "$DOCKER_NORMAL" feature/docker-normal docker-normal docker source-only

DOCKER_BOT="$TMP_DIR/docker-bot"
make_repo "$DOCKER_BOT"
touch "$DOCKER_BOT/docker-compose.yml"
commit_all "$DOCKER_BOT" initial
git -C "$DOCKER_BOT" branch dev
git -C "$DOCKER_BOT" checkout -q -b bot/next-version dev
git -C "$DOCKER_BOT" update-index --add --cacheinfo 160000 1111111111111111111111111111111111111111 flutter-app
git -C "$DOCKER_BOT" commit -q -m "Update flutter gitlink"
classify_expect "$DOCKER_BOT" bot/next-version docker-bot-next-version docker gitlink-only

DOCKER_MIXED="$TMP_DIR/docker-mixed"
make_repo "$DOCKER_MIXED"
touch "$DOCKER_MIXED/docker-compose.yml"
commit_all "$DOCKER_MIXED" initial
git -C "$DOCKER_MIXED" branch dev
git -C "$DOCKER_MIXED" checkout -q -b feature/docker-mixed dev
git -C "$DOCKER_MIXED" update-index --add --cacheinfo 160000 2222222222222222222222222222222222222222 laravel-app
printf 'runtime note\n' >"$DOCKER_MIXED/README.md"
git -C "$DOCKER_MIXED" add README.md
git -C "$DOCKER_MIXED" commit -q -m "Update docker and laravel gitlink"
classify_expect "$DOCKER_MIXED" feature/docker-mixed docker-mixed docker source+gitlinks

FLUTTER_REPO="$TMP_DIR/flutter"
make_repo "$FLUTTER_REPO"
cat >"$FLUTTER_REPO/pubspec.yaml" <<'YAML'
name: sample_flutter
environment:
  sdk: ">=3.0.0 <4.0.0"
YAML
commit_all "$FLUTTER_REPO" initial
git -C "$FLUTTER_REPO" branch dev
git -C "$FLUTTER_REPO" checkout -q -b feature/flutter dev
mkdir -p "$FLUTTER_REPO/lib"
printf 'void main() {}\n' >"$FLUTTER_REPO/lib/main.dart"
commit_all "$FLUTTER_REPO" "Add Flutter entrypoint"
classify_expect "$FLUTTER_REPO" feature/flutter flutter-only flutter n/a

LARAVEL_REPO="$TMP_DIR/laravel"
make_repo "$LARAVEL_REPO"
cat >"$LARAVEL_REPO/composer.json" <<'JSON'
{"require":{"laravel/framework":"^11.0"}}
JSON
touch "$LARAVEL_REPO/artisan"
commit_all "$LARAVEL_REPO" initial
git -C "$LARAVEL_REPO" branch dev
git -C "$LARAVEL_REPO" checkout -q -b feature/laravel dev
mkdir -p "$LARAVEL_REPO/routes"
printf '<?php\n' >"$LARAVEL_REPO/routes/api.php"
commit_all "$LARAVEL_REPO" "Add Laravel route"
classify_expect "$LARAVEL_REPO" feature/laravel laravel-only laravel n/a

FLUTTER_LARAVEL="$TMP_DIR/flutter-laravel"
make_repo "$FLUTTER_LARAVEL"
mkdir -p "$FLUTTER_LARAVEL/flutter-app" "$FLUTTER_LARAVEL/laravel-app"
cat >"$FLUTTER_LARAVEL/flutter-app/pubspec.yaml" <<'YAML'
name: sample_flutter
environment:
  sdk: ">=3.0.0 <4.0.0"
YAML
cat >"$FLUTTER_LARAVEL/laravel-app/composer.json" <<'JSON'
{"require":{"laravel/framework":"^11.0"}}
JSON
touch "$FLUTTER_LARAVEL/laravel-app/artisan"
commit_all "$FLUTTER_LARAVEL" initial
git -C "$FLUTTER_LARAVEL" branch dev
git -C "$FLUTTER_LARAVEL" checkout -q -b feature/flutter-laravel dev
mkdir -p "$FLUTTER_LARAVEL/flutter-app/lib" "$FLUTTER_LARAVEL/laravel-app/routes"
printf 'void main() {}\n' >"$FLUTTER_LARAVEL/flutter-app/lib/main.dart"
printf '<?php\n' >"$FLUTTER_LARAVEL/laravel-app/routes/api.php"
commit_all "$FLUTTER_LARAVEL" "Update Flutter and Laravel"
classify_expect "$FLUTTER_LARAVEL" feature/flutter-laravel flutter-laravel flutter+laravel n/a

if python3 "$ROOT_DIR/tools/github_stage_promotion_scenario_classifier.py" \
  --repo "$FLUTTER_REPO" \
  --base dev \
  --source feature/flutter \
  --expected-scenario laravel-only \
  >"$TMP_DIR/mismatch.txt" 2>&1; then
  cat "$TMP_DIR/mismatch.txt"
  printf 'expected scenario mismatch to be blocked\n' >&2
  exit 1
fi
grep -q "Expected scenario" "$TMP_DIR/mismatch.txt"

printf 'github_stage_promotion_scenario_classifier_test: OK\n'
