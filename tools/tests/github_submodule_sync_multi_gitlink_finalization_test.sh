#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

git config --global protocol.file.allow always >/dev/null 2>&1 || true

make_bare_repo() {
  local repo="$1"
  git init --bare -q "$repo"
}

make_work_repo() {
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

make_submodule_remote() {
  local name="$1"
  local bare="$TMP_DIR/${name}.git"
  local work="$TMP_DIR/${name}-work"
  make_bare_repo "$bare"
  make_work_repo "$work"
  git -C "$work" remote add origin "$bare"
  printf '%s-base\n' "$name" >"$work/README.md"
  commit_all "$work" "initial ${name}"
  git -C "$work" branch -M main
  git -C "$work" push -q origin main
  git -C "$bare" symbolic-ref HEAD refs/heads/main
}

advance_submodule() {
  local name="$1"
  local label="$2"
  local work="$TMP_DIR/${name}-work"
  printf '%s\n' "$label" >>"$work/README.md"
  commit_all "$work" "advance ${name} ${label}"
  git -C "$work" push -q origin main
}

submodule_head() {
  local name="$1"
  git -C "$TMP_DIR/${name}-work" rev-parse HEAD
}

setup_root_remote() {
  local remote="$TMP_DIR/root-origin.git"
  local work="$TMP_DIR/root-work"

  make_bare_repo "$remote"
  make_work_repo "$work"
  git -C "$work" remote add origin "$remote"
  printf 'base\n' >"$work/README.md"
  git -C "$work" add README.md
  git -C "$work" commit -q -m initial

  git -C "$work" -c protocol.file.allow=always submodule add "$TMP_DIR/flutter.git" flutter-app >/dev/null
  git -C "$work" -c protocol.file.allow=always submodule add "$TMP_DIR/laravel.git" laravel-app >/dev/null
  git -C "$work" add .gitmodules flutter-app laravel-app
  git -C "$work" commit -q -m "Add app submodules"
  git -C "$work" branch -M dev
  git -C "$work" push -q origin dev
}

gitlink_at_ref() {
  local repo="$1"
  local ref="$2"
  local submodule="$3"
  git -C "$repo" ls-tree "$ref" -- "$submodule" | awk '{print $3}' | head -n1
}

simulate_callback() {
  local repo="$1"
  local submodule="$2"
  local target_sha="$3"

  git -C "$repo" fetch origin dev bot/next-version >/dev/null 2>&1 || git -C "$repo" fetch origin dev >/dev/null 2>&1
  git -C "$repo" reset -q --hard origin/dev
  git -C "$repo" clean -fdq

  local output="$TMP_DIR/helper-output.txt"
  : >"$output"

  (
    cd "$repo"
    bash "$ROOT_DIR/.github/scripts/prepare_submodule_sync_candidate_branch.sh" \
      --base-branch dev \
      --bot-branch bot/next-version \
      --current-submodule "$submodule" \
      --current-sha "$target_sha" \
      --output-file "$output"
  )

  if ! git -C "$repo" diff --cached --ignore-submodules=none --quiet; then
    git -C "$repo" commit -q -m "sync ${submodule} ${target_sha:0:7}"
  fi
  git -C "$repo" push --force -q origin HEAD:bot/next-version
}

assert_gitlinks() {
  local repo="$1"
  local ref="$2"
  local expected_flutter="$3"
  local expected_laravel="$4"

  local actual_flutter actual_laravel
  actual_flutter="$(gitlink_at_ref "$repo" "$ref" flutter-app)"
  actual_laravel="$(gitlink_at_ref "$repo" "$ref" laravel-app)"

  [[ "$actual_flutter" == "$expected_flutter" ]] || {
    echo "expected flutter-app=$expected_flutter at $ref, got $actual_flutter" >&2
    exit 1
  }
  [[ "$actual_laravel" == "$expected_laravel" ]] || {
    echo "expected laravel-app=$expected_laravel at $ref, got $actual_laravel" >&2
    exit 1
  }
}

assert_file_from_ref() {
  local repo="$1"
  local ref="$2"
  local path="$3"
  local expected="$4"
  local actual
  actual="$(git -C "$repo" show "${ref}:${path}")"
  [[ "$actual" == "$expected" ]] || {
    echo "expected ${path} at ${ref} to equal '${expected}', got '${actual}'" >&2
    exit 1
  }
}

run_order_case() {
  local first_submodule="$1"
  local first_sha="$2"
  local second_submodule="$3"
  local second_sha="$4"

  local repo="$TMP_DIR/root-work"
  simulate_callback "$repo" "$first_submodule" "$first_sha"
  simulate_callback "$repo" "$second_submodule" "$second_sha"
}

make_submodule_remote flutter
make_submodule_remote laravel
setup_root_remote

ROOT_REPO="$TMP_DIR/root-work"
BASE_FLUTTER_SHA="$(submodule_head flutter)"
BASE_LARAVEL_SHA="$(submodule_head laravel)"

advance_submodule laravel "laravel-v2"
LARAVEL_V2_SHA="$(submodule_head laravel)"
advance_submodule flutter "flutter-v2"
FLUTTER_V2_SHA="$(submodule_head flutter)"

run_order_case laravel-app "$LARAVEL_V2_SHA" flutter-app "$FLUTTER_V2_SHA"
git -C "$ROOT_REPO" fetch origin bot/next-version >/dev/null 2>&1
assert_gitlinks "$ROOT_REPO" origin/bot/next-version "$FLUTTER_V2_SHA" "$LARAVEL_V2_SHA"

git -C "$ROOT_REPO" checkout -q dev
git -C "$ROOT_REPO" reset -q --hard origin/dev
git -C "$ROOT_REPO" push --force -q origin dev
git -C "$ROOT_REPO" push --force -q origin :bot/next-version || true

advance_submodule flutter "flutter-v3"
FLUTTER_V3_SHA="$(submodule_head flutter)"
advance_submodule laravel "laravel-v3"
LARAVEL_V3_SHA="$(submodule_head laravel)"

run_order_case flutter-app "$FLUTTER_V3_SHA" laravel-app "$LARAVEL_V3_SHA"
git -C "$ROOT_REPO" fetch origin bot/next-version >/dev/null 2>&1
assert_gitlinks "$ROOT_REPO" origin/bot/next-version "$FLUTTER_V3_SHA" "$LARAVEL_V3_SHA"

git -C "$ROOT_REPO" checkout -q dev
printf 'base-advanced\n' >"$ROOT_REPO/README.md"
commit_all "$ROOT_REPO" "advance dev base"
git -C "$ROOT_REPO" push -q origin dev

advance_submodule laravel "laravel-v4"
LARAVEL_V4_SHA="$(submodule_head laravel)"
advance_submodule flutter "flutter-v4"
FLUTTER_V4_SHA="$(submodule_head flutter)"

simulate_callback "$ROOT_REPO" laravel-app "$LARAVEL_V4_SHA"
simulate_callback "$ROOT_REPO" flutter-app "$FLUTTER_V4_SHA"
git -C "$ROOT_REPO" fetch origin dev bot/next-version >/dev/null 2>&1
assert_gitlinks "$ROOT_REPO" origin/bot/next-version "$FLUTTER_V4_SHA" "$LARAVEL_V4_SHA"
assert_file_from_ref "$ROOT_REPO" origin/bot/next-version README.md "base-advanced"

printf 'github_submodule_sync_multi_gitlink_finalization_test: OK\n'
