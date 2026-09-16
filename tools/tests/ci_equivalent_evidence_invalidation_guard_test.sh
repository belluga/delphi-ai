#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOL="$ROOT_DIR/tools/ci_equivalent_evidence_invalidation_guard.py"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

init_repo() {
  local path="$1"
  mkdir -p "$path"
  git -C "$path" init -q
  git -C "$path" config user.name "Delphi Test"
  git -C "$path" config user.email "delphi-test@example.com"
  git -C "$path" branch -M v0.0.0-rc
}

commit_file() {
  local repo="$1"
  local file="$2"
  local content="$3"
  mkdir -p "$(dirname "$repo/$file")"
  printf '%s\n' "$content" > "$repo/$file"
  git -C "$repo" add "$file"
  git -C "$repo" commit -q -m "update $file"
}

ROOT_REPO="$TMP_DIR/root"
FLUTTER_REPO="$ROOT_REPO/flutter-app"
LARAVEL_REPO="$ROOT_REPO/laravel-app"
TODO_FILE="$TMP_DIR/TODO-v0.0.0+0-release-package.md"
POLICY_FILE="$TMP_DIR/stage-full-evidence-reuse-policy.json"
REPORT_FILE="$TMP_DIR/stage-full-report.json"

init_repo "$ROOT_REPO"
mkdir -p "$ROOT_REPO"
printf 'flutter-app/\nlaravel-app/\n' > "$ROOT_REPO/.gitignore"
git -C "$ROOT_REPO" add .gitignore
git -C "$ROOT_REPO" commit -q -m "ignore nested repos"
init_repo "$FLUTTER_REPO"
init_repo "$LARAVEL_REPO"

commit_file "$ROOT_REPO" "README.md" "root baseline"
commit_file "$FLUTTER_REPO" "lib.dart" "flutter baseline"
commit_file "$LARAVEL_REPO" "app.php" "laravel baseline"

ROOT_SHA="$(git -C "$ROOT_REPO" rev-parse HEAD)"
FLUTTER_SHA="$(git -C "$FLUTTER_REPO" rev-parse HEAD)"
LARAVEL_SHA="$(git -C "$LARAVEL_REPO" rev-parse HEAD)"

mkdir -p "$(dirname "$TODO_FILE")" "$(dirname "$POLICY_FILE")" "$(dirname "$REPORT_FILE")"

cat > "$TODO_FILE" <<EOF
# TODO: Synthetic CI Equivalent Guard

## Current Branch Authority

- Root canonical branch: \`v0.0.0-rc\`
- \`flutter-app\` canonical branch: \`v0.0.0-rc\`
- \`laravel-app\` canonical branch: \`v0.0.0-rc\`
- Canonical post-replay source baselines currently under promotion consideration:
  - root \`v0.0.0-rc@${ROOT_SHA}\`
  - flutter-app \`v0.0.0-rc@${FLUTTER_SHA}\`
  - laravel-app \`v0.0.0-rc@${LARAVEL_SHA}\`
EOF

cat > "$POLICY_FILE" <<EOF
{
  "schema_version": "ci-evidence-reuse-policy-v1",
  "policy_id": "synthetic-stage-full",
  "contract_id": "stage-full",
  "repos": [
    {
      "repo_key": "root",
      "repo_path": ".",
      "safe_reuse_globs": [
        "foundation_documentation/**"
      ],
      "invalidating_globs": [
        "tools/ci/**"
      ]
    },
    {
      "repo_key": "flutter-app",
      "repo_path": "flutter-app",
      "safe_reuse_globs": [],
      "invalidating_globs": []
    },
    {
      "repo_key": "laravel-app",
      "repo_path": "laravel-app",
      "safe_reuse_globs": [],
      "invalidating_globs": []
    }
  ]
}
EOF

cat > "$REPORT_FILE" <<EOF
{
  "schema_version": "ci-contract-run-v1",
  "artifact_kind": "ci_contract_run",
  "contract_id": "stage-full",
  "overall_status": "passed",
  "repo_states": {
    "root": {
      "repo_root": "${ROOT_REPO}",
      "branch": "v0.0.0-rc",
      "head_sha": "${ROOT_SHA}"
    },
    "flutter-app": {
      "repo_root": "${FLUTTER_REPO}",
      "branch": "v0.0.0-rc",
      "head_sha": "${FLUTTER_SHA}"
    },
    "laravel-app": {
      "repo_root": "${LARAVEL_REPO}",
      "branch": "v0.0.0-rc",
      "head_sha": "${LARAVEL_SHA}"
    }
  },
  "entries": []
}
EOF

cd "$ROOT_REPO"

commit_file "$ROOT_REPO" "foundation_documentation/notes.md" "docs only"

if ! python3 "$TOOL" --governing-todo "$TODO_FILE" --policy "$POLICY_FILE" --report "$REPORT_FILE" > "$TMP_DIR/reusable.txt"; then
  echo "Expected reusable outcome for allowlisted documentation-only drift." >&2
  cat "$TMP_DIR/reusable.txt" >&2 || true
  exit 1
fi

grep -q "Overall outcome: reusable" "$TMP_DIR/reusable.txt"
grep -q "foundation_documentation/notes.md" "$TMP_DIR/reusable.txt"

printf 'dirty flutter change\n' >> "$FLUTTER_REPO/lib.dart"
set +e
python3 "$TOOL" --governing-todo "$TODO_FILE" --policy "$POLICY_FILE" --report "$REPORT_FILE" > "$TMP_DIR/manual.txt"
status="$?"
set -e
if [ "$status" -eq 0 ]; then
  echo "Expected manual-admission-required outcome for dirty worktree." >&2
  cat "$TMP_DIR/manual.txt" >&2 || true
  exit 1
fi

if [ "$status" -ne 11 ]; then
  echo "Expected exit code 11 for manual-admission-required." >&2
  cat "$TMP_DIR/manual.txt" >&2 || true
  exit 1
fi

grep -q "Overall outcome: manual-admission-required" "$TMP_DIR/manual.txt"
git -C "$FLUTTER_REPO" checkout -- lib.dart

commit_file "$ROOT_REPO" "tools/ci/run_contract.py" "runner drift"

set +e
python3 "$TOOL" --governing-todo "$TODO_FILE" --policy "$POLICY_FILE" --report "$REPORT_FILE" > "$TMP_DIR/rerun.txt"
status="$?"
set -e
if [ "$status" -eq 0 ]; then
  echo "Expected rerun-required outcome for invalidating surface drift." >&2
  cat "$TMP_DIR/rerun.txt" >&2 || true
  exit 1
fi

if [ "$status" -ne 10 ]; then
  echo "Expected exit code 10 for rerun-required." >&2
  cat "$TMP_DIR/rerun.txt" >&2 || true
  exit 1
fi

grep -q "Overall outcome: rerun-required" "$TMP_DIR/rerun.txt"
grep -q "tools/ci/run_contract.py" "$TMP_DIR/rerun.txt"

echo "ci_equivalent_evidence_invalidation_guard_test: PASS"
