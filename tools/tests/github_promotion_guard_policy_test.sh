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

printf 'github_promotion_guard_policy_test: OK\n'
