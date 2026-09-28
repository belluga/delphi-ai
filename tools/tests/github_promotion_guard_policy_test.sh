#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

CONTRACT="$TMP_DIR/promotion-contract.json"
OUTPUT="$TMP_DIR/out.txt"
REPO="$TMP_DIR/repo"

bash "$ROOT_DIR/tools/github_promotion_contract_init.sh" \
  --output "$CONTRACT" \
  --scope through-stage \
  --gitlink-policy pipeline-only \
  >/dev/null

bash "$ROOT_DIR/tools/github_promotion_action_guard.sh" \
  --contract "$CONTRACT" \
  --action pr-create \
  --repo-kind docker \
  --repo-slug test/docker \
  --head bot/next-version \
  --base dev \
  >"$OUTPUT"
grep -q "Overall outcome: go" "$OUTPUT"

if bash "$ROOT_DIR/tools/github_promotion_action_guard.sh" \
  --contract "$CONTRACT" \
  --action pr-create \
  --repo-kind docker \
  --repo-slug test/docker \
  --head bot/next-version \
  --base stage \
  >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected bot/next-version -> stage to be blocked\n' >&2
  exit 1
fi
grep -q "bot/next-version -> dev" "$OUTPUT"

if bash "$ROOT_DIR/tools/github_promotion_action_guard.sh" \
  --contract "$CONTRACT" \
  --action pr-create \
  --repo-kind other \
  --repo-slug test/web-app \
  --head feature \
  --base dev \
  >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected web-app PR mutation to be blocked\n' >&2
  exit 1
fi
grep -q "derived artifact" "$OUTPUT"

if bash "$ROOT_DIR/tools/github_promotion_action_guard.sh" \
  --contract "$CONTRACT" \
  --action pr-create \
  --repo-kind docker \
  --repo-slug test/docker \
  --head reconcile/v0.2.0+8/package \
  --base dev \
  >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected reconcile/* PR head to be blocked\n' >&2
  exit 1
fi
grep -q "reconciliation branch" "$OUTPUT"
grep -q "Replay the accepted reconcile state onto the canonical version/source branch first" "$OUTPUT"

if bash "$ROOT_DIR/tools/github_promotion_action_guard.sh" \
  --contract "$CONTRACT" \
  --action pr-create \
  --repo-kind docker \
  --repo-slug test/docker \
  --head sequence/v0.2.0+8/package \
  --base dev \
  >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected sequence/* PR head to be blocked\n' >&2
  exit 1
fi
grep -q "sequencing branch" "$OUTPUT"
grep -q "Validate the accepted sequence state with the user" "$OUTPUT"

STAGE_ADMISSION_REMOTE="$TMP_DIR/stage-admission-origin.git"
STAGE_ADMISSION_REPO="$TMP_DIR/stage-admission-repo"
git init --bare -q "$STAGE_ADMISSION_REMOTE"
mkdir -p "$STAGE_ADMISSION_REPO"
git -C "$STAGE_ADMISSION_REPO" init -q
git -C "$STAGE_ADMISSION_REPO" config user.email test@example.test
git -C "$STAGE_ADMISSION_REPO" config user.name "Test User"
git -C "$STAGE_ADMISSION_REPO" remote add origin "$STAGE_ADMISSION_REMOTE"
printf 'base\n' >"$STAGE_ADMISSION_REPO/README.md"
git -C "$STAGE_ADMISSION_REPO" add README.md
git -C "$STAGE_ADMISSION_REPO" commit -q -m initial
git -C "$STAGE_ADMISSION_REPO" branch -M dev
git -C "$STAGE_ADMISSION_REPO" push -q origin dev
git -C "$STAGE_ADMISSION_REPO" checkout -q -b bot/next-version
git -C "$STAGE_ADMISSION_REPO" update-index --add --cacheinfo 160000 3333333333333333333333333333333333333333 flutter-app
git -C "$STAGE_ADMISSION_REPO" commit -q -m "Update flutter gitlink"
BOT_COMMIT="$(git -C "$STAGE_ADMISSION_REPO" rev-parse HEAD)"
git -C "$STAGE_ADMISSION_REPO" checkout -q dev
git -C "$STAGE_ADMISSION_REPO" checkout -q -b feature/docker-source
printf 'pipeline tweak\n' >"$STAGE_ADMISSION_REPO/docker-compose.yml"
git -C "$STAGE_ADMISSION_REPO" add docker-compose.yml
git -C "$STAGE_ADMISSION_REPO" commit -q -m "Docker source change"
SOURCE_COMMIT="$(git -C "$STAGE_ADMISSION_REPO" rev-parse HEAD)"
git -C "$STAGE_ADMISSION_REPO" checkout -q dev

STAGE_CONTRACT="$TMP_DIR/stage-admission-contract.json"
bash "$ROOT_DIR/tools/github_promotion_contract_init.sh" \
  --output "$STAGE_CONTRACT" \
  --scope through-stage \
  --gitlink-policy pipeline-only \
  --required-dev-track docker-bot-next-version=bot/next-version \
  --required-dev-track docker-source=feature/docker-source \
  >/dev/null

if (
  cd "$STAGE_ADMISSION_REPO"
  bash "$ROOT_DIR/tools/github_promotion_action_guard.sh" \
    --contract "$STAGE_CONTRACT" \
    --action pr-create \
    --repo-kind docker \
    --repo-slug test/docker \
    --head dev \
    --base stage
) >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected stage admission to block while required dev tracks are pending\n' >&2
  exit 1
fi
grep -q "docker-bot-next-version=bot/next-version" "$OUTPUT"
grep -q "First complete the lane-owned 'bot/next-version -> dev' movement" "$OUTPUT"

git -C "$STAGE_ADMISSION_REPO" checkout -q dev
git -C "$STAGE_ADMISSION_REPO" cherry-pick "$BOT_COMMIT" >/dev/null
git -C "$STAGE_ADMISSION_REPO" push -q origin dev

if (
  cd "$STAGE_ADMISSION_REPO"
  bash "$ROOT_DIR/tools/github_promotion_action_guard.sh" \
    --contract "$STAGE_CONTRACT" \
    --action pr-create \
    --repo-kind docker \
    --repo-slug test/docker \
    --head dev \
    --base stage
) >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected stage admission to stay blocked until docker source is absorbed into dev\n' >&2
  exit 1
fi
grep -q "docker-source=feature/docker-source" "$OUTPUT"
grep -q "Merge the authoritative Docker source branch 'feature/docker-source' into 'dev' first" "$OUTPUT"

git -C "$STAGE_ADMISSION_REPO" checkout -q dev
git -C "$STAGE_ADMISSION_REPO" cherry-pick "$SOURCE_COMMIT" >/dev/null
git -C "$STAGE_ADMISSION_REPO" push -q origin dev

(
  cd "$STAGE_ADMISSION_REPO"
  bash "$ROOT_DIR/tools/github_promotion_action_guard.sh" \
    --contract "$STAGE_CONTRACT" \
    --action pr-create \
    --repo-kind docker \
    --repo-slug test/docker \
    --head dev \
    --base stage
) >"$OUTPUT"
grep -q "Overall outcome: go" "$OUTPUT"

bash "$ROOT_DIR/tools/github_promotion_action_guard.sh" \
  --contract "$CONTRACT" \
  --action pr-create \
  --repo-kind docker \
  --repo-slug test/docker \
  --head reconcile/dev-contains-stage-docker-20260518 \
  --base dev \
  >"$OUTPUT"
grep -q "Overall outcome: go" "$OUTPUT"

bash "$ROOT_DIR/tools/github_promotion_action_guard.sh" \
  --contract "$CONTRACT" \
  --action git-push \
  --repo-kind docker \
  --branch reconcile/dev-contains-stage-docker-20260518 \
  --target-branch reconcile/dev-contains-stage-docker-20260518 \
  >"$OUTPUT"
grep -q "Overall outcome: go" "$OUTPUT"

mkdir -p "$REPO"
git -C "$REPO" init -q
git -C "$REPO" config user.email test@example.test
git -C "$REPO" config user.name "Test User"
touch "$REPO/README.md"
git -C "$REPO" add README.md
git -C "$REPO" commit -q -m initial
git -C "$REPO" branch dev
git -C "$REPO" branch stage
git -C "$REPO" checkout -q -b bot/next-version dev
git -C "$REPO" update-index --add --cacheinfo 160000 1111111111111111111111111111111111111111 flutter-app
git -C "$REPO" commit -q -m "Update flutter gitlink"

bash "$ROOT_DIR/tools/github_promotion_diff_guard.sh" \
  --contract "$CONTRACT" \
  --repo "$REPO" \
  --mode range \
  --base-ref dev \
  --source-ref bot/next-version \
  >"$OUTPUT"
grep -q "Overall outcome: go" "$OUTPUT"

if bash "$ROOT_DIR/tools/github_promotion_diff_guard.sh" \
  --contract "$CONTRACT" \
  --repo "$REPO" \
  --mode range \
  --base-ref stage \
  --source-ref bot/next-version \
  >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected bot/next-version gitlink range against stage to be blocked\n' >&2
  exit 1
fi
grep -q "bot/next-version -> dev" "$OUTPUT"

HARNESS_CONTRACT="$TMP_DIR/harness-contract.json"
bash "$ROOT_DIR/tools/github_promotion_contract_init.sh" \
  --output "$HARNESS_CONTRACT" \
  --scope through-stage \
  --gitlink-policy pipeline-only \
  --ci-test-harness-change-authorized true \
  >/dev/null

WORKFLOW_REPO="$TMP_DIR/workflow-repo"
mkdir -p "$WORKFLOW_REPO/.github/workflows"
git -C "$WORKFLOW_REPO" init -q
git -C "$WORKFLOW_REPO" config user.email test@example.test
git -C "$WORKFLOW_REPO" config user.name "Test User"
cat >"$WORKFLOW_REPO/.github/workflows/test.yml" <<'YAML'
jobs:
  browser-tests:
    runs-on: ubuntu-latest
    steps:
      - name: Run navigation mutation
        env:
          NAV_TEST_RUN_ID: stage-1
          NAV_WEB_TEST_TYPE: mutation
        run: echo ok
YAML
git -C "$WORKFLOW_REPO" add .github/workflows/test.yml
git -C "$WORKFLOW_REPO" commit -q -m initial
git -C "$WORKFLOW_REPO" branch dev

git -C "$WORKFLOW_REPO" checkout -q -b feature/harness dev
python3 - "$WORKFLOW_REPO/.github/workflows/test.yml" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
needle = "          NAV_TEST_RUN_ID: stage-1\n"
replacement = needle + "          NAV_PUBLIC_TAXONOMY_MANAGED_FIXTURE: '1'\n"
path.write_text(text.replace(needle, replacement), encoding="utf-8")
PY
git -C "$WORKFLOW_REPO" add .github/workflows/test.yml
git -C "$WORKFLOW_REPO" commit -q -m "Narrow test harness tweak"

if bash "$ROOT_DIR/tools/github_promotion_diff_guard.sh" \
  --contract "$CONTRACT" \
  --repo "$WORKFLOW_REPO" \
  --mode range \
  --base-ref dev \
  --source-ref feature/harness \
  >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected workflow test-harness change without narrow authorization to be blocked\n' >&2
  exit 1
fi
grep -q "ci_test_harness_change_authorized=true" "$OUTPUT"

bash "$ROOT_DIR/tools/github_promotion_diff_guard.sh" \
  --contract "$HARNESS_CONTRACT" \
  --repo "$WORKFLOW_REPO" \
  --mode range \
  --base-ref dev \
  --source-ref feature/harness \
  >"$OUTPUT"
grep -q "Overall outcome: go" "$OUTPUT"

git -C "$WORKFLOW_REPO" checkout -q -b feature/control dev
python3 - "$WORKFLOW_REPO/.github/workflows/test.yml" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
path.write_text(text.replace("    runs-on: ubuntu-latest\n", "    runs-on: ubuntu-24.04\n"), encoding="utf-8")
PY
git -C "$WORKFLOW_REPO" add .github/workflows/test.yml
git -C "$WORKFLOW_REPO" commit -q -m "Control plane tweak"

if bash "$ROOT_DIR/tools/github_promotion_diff_guard.sh" \
  --contract "$HARNESS_CONTRACT" \
  --repo "$WORKFLOW_REPO" \
  --mode range \
  --base-ref dev \
  --source-ref feature/control \
  >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected workflow control-plane change to stay blocked under narrow test-harness authorization\n' >&2
  exit 1
fi
grep -q "ci_behavior_change_authorized=true" "$OUTPUT"

WORKTREE_CONTRACT="$TMP_DIR/worktree-contract.json"
bash "$ROOT_DIR/tools/github_promotion_contract_init.sh" \
  --output "$WORKTREE_CONTRACT" \
  --scope through-stage \
  --gitlink-policy pipeline-only \
  >/dev/null

CHILD_REPO="$TMP_DIR/child-repo"
mkdir -p "$CHILD_REPO"
git -C "$CHILD_REPO" init -q
git -C "$CHILD_REPO" config user.email test@example.test
git -C "$CHILD_REPO" config user.name "Test User"
printf 'first\n' >"$CHILD_REPO/version.txt"
git -C "$CHILD_REPO" add version.txt
git -C "$CHILD_REPO" commit -q -m "Child commit A"
CHILD_SHA_A="$(git -C "$CHILD_REPO" rev-parse HEAD)"
printf 'second\n' >"$CHILD_REPO/version.txt"
git -C "$CHILD_REPO" commit -q -am "Child commit B"
CHILD_SHA_B="$(git -C "$CHILD_REPO" rev-parse HEAD)"

WORKTREE_REPO="$TMP_DIR/worktree-repo"
mkdir -p "$WORKTREE_REPO"
git -C "$WORKTREE_REPO" init -q
git -C "$WORKTREE_REPO" config user.email test@example.test
git -C "$WORKTREE_REPO" config user.name "Test User"
touch "$WORKTREE_REPO/README.md"
git -C "$WORKTREE_REPO" add README.md
git -C "$WORKTREE_REPO" commit -q -m initial
git -c protocol.file.allow=always -C "$WORKTREE_REPO" submodule add -q "$CHILD_REPO" flutter-app
git -C "$WORKTREE_REPO/flutter-app" checkout -q "$CHILD_SHA_A"
git -C "$WORKTREE_REPO" add .gitmodules flutter-app
git -C "$WORKTREE_REPO" commit -q -m "Pin flutter-app gitlink"
git -C "$WORKTREE_REPO/flutter-app" checkout -q "$CHILD_SHA_B"

if ! bash "$ROOT_DIR/tools/github_promotion_diff_guard.sh" \
  --contract "$WORKTREE_CONTRACT" \
  --repo "$WORKTREE_REPO" \
  --mode worktree \
  >"$OUTPUT" 2>&1; then
  cat "$OUTPUT"
  printf 'expected worktree gitlink checkout drift to remain advisory\n' >&2
  exit 1
fi
grep -q "gitlink_checkout_drift_advisory: present" "$OUTPUT"
grep -q "Do not treat the root gitlink as source authority for app repos." "$OUTPUT"
grep -q "Do not create a manual root gitlink commit to 'realign' this state." "$OUTPUT"
grep -q "gitlink_checkout_drift_paths: flutter-app => root_recorded_sha=$CHILD_SHA_A; child_head_sha=$CHILD_SHA_B" "$OUTPUT"

printf 'github_promotion_guard_policy_test: OK\n'
