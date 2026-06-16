#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT_DIR/tools/github_status_wait.py"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$TMP_DIR/bin"

cat > "$TMP_DIR/bin/gh" <<'GH'
#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" = "auth" ] && [ "${2:-}" = "status" ]; then
  exit 0
fi

if [ "${1:-}" = "api" ] && [ "${2:-}" = "repos/test/repo/actions/runs?per_page=100" ]; then
  cat <<'JSON'
{"workflow_runs":[{"id":42,"databaseId":42,"name":"Laravel CI","event":"push","head_branch":"stage","head_sha":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","status":"completed","conclusion":"success","html_url":"https://example.test/runs/42","created_at":"2026-06-14T16:48:13Z"}]}
JSON
  exit 0
fi

if [ "${1:-}" = "run" ] && [ "${2:-}" = "view" ] && [ "${3:-}" = "42" ]; then
  cat <<'JSON'
{"databaseId":42,"status":"completed","conclusion":"success","workflowName":"Laravel CI","url":"https://example.test/runs/42","headSha":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","event":"push","jobs":[{"name":"Lane Promotion Policy","status":"completed","conclusion":"success"},{"name":"test","status":"completed","conclusion":"success"}]}
JSON
  exit 0
fi

if [ "${1:-}" = "run" ] && [ "${2:-}" = "view" ] && [ "${3:-}" = "43" ]; then
  cat <<'JSON'
{"databaseId":43,"status":"completed","conclusion":"failure","workflowName":"Laravel CI","url":"https://example.test/runs/43","headSha":"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb","event":"pull_request","jobs":[{"name":"Lane Promotion Policy","status":"completed","conclusion":"success"},{"name":"test","status":"completed","conclusion":"failure"}]}
JSON
  exit 0
fi

if [ "${1:-}" = "api" ] && [ "${2:-}" = "repos/test/repo/branches/bot%2Fnext-version" ]; then
  cat <<'JSON'
{"name":"bot/next-version","protected":false,"commit":{"sha":"cccccccccccccccccccccccccccccccccccccccc"}}
JSON
  exit 0
fi

if [ "${1:-}" = "api" ] && [ "${2:-}" = "repos/test/repo/branches/missing" ]; then
  echo "gh: Not Found (HTTP 404)" >&2
  exit 1
fi

printf 'unexpected gh command: %s\n' "$*" >&2
exit 1
GH

chmod +x "$TMP_DIR/bin/gh"

SUCCESS_OUT="$TMP_DIR/run-success.out"
PATH="$TMP_DIR/bin:$PATH" python3 "$SCRIPT" run \
  --repo test/repo \
  --branch stage \
  --event push \
  --workflow "Laravel CI" \
  --poll-seconds 1 \
  --timeout-seconds 1 \
  > "$SUCCESS_OUT"

grep -q "Overall outcome: go" "$SUCCESS_OUT"
grep -q "run_id: 42" "$SUCCESS_OUT"
grep -q "conclusion: success" "$SUCCESS_OUT"

FAIL_OUT="$TMP_DIR/run-fail.out"
if PATH="$TMP_DIR/bin:$PATH" python3 "$SCRIPT" run \
  --repo test/repo \
  --run-id 43 \
  --poll-seconds 1 \
  --timeout-seconds 1 \
  > "$FAIL_OUT"; then
  cat "$FAIL_OUT"
  printf 'expected failing run wait to block\n' >&2
  exit 1
fi

grep -q "Overall outcome: no-go" "$FAIL_OUT"
grep -q "GitHub Actions run concluded with 'failure'" "$FAIL_OUT"
grep -q "failing_jobs: test (failure)" "$FAIL_OUT"

BRANCH_OUT="$TMP_DIR/branch.out"
PATH="$TMP_DIR/bin:$PATH" python3 "$SCRIPT" branch \
  --repo test/repo \
  --branch bot/next-version \
  --poll-seconds 1 \
  --timeout-seconds 1 \
  > "$BRANCH_OUT"

grep -q "Overall outcome: go" "$BRANCH_OUT"
grep -q "branch: bot/next-version" "$BRANCH_OUT"
grep -q "commit_sha: cccccccccccccccccccccccccccccccccccccccc" "$BRANCH_OUT"

TIMEOUT_OUT="$TMP_DIR/branch-timeout.out"
if PATH="$TMP_DIR/bin:$PATH" python3 "$SCRIPT" branch \
  --repo test/repo \
  --branch missing \
  --poll-seconds 1 \
  --timeout-seconds 0 \
  > "$TIMEOUT_OUT"; then
  cat "$TIMEOUT_OUT"
  printf 'expected missing branch wait to block\n' >&2
  exit 1
fi

grep -q "Overall outcome: no-go" "$TIMEOUT_OUT"
grep -q "did not appear before the timeout expired" "$TIMEOUT_OUT"

printf 'github_status_wait_test: OK\n'
