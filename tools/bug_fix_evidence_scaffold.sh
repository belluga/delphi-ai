#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bug_fix_evidence_scaffold.sh --title <text> --symptom <text> [--repro-step <text> ...] [--output <path>]

Generate a markdown evidence scaffold for the Bug Fix Evidence Loop skill.
This is a deterministic helper for the repeatable evidence structure only; it does
not diagnose the bug or decide whether a rule candidate is warranted.
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

TITLE=""
SYMPTOM=""
OUTPUT_PATH=""
declare -a REPRO_STEPS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --title)
      [ $# -ge 2 ] || die "missing value for --title"
      TITLE="$2"
      shift 2
      ;;
    --symptom)
      [ $# -ge 2 ] || die "missing value for --symptom"
      SYMPTOM="$2"
      shift 2
      ;;
    --repro-step)
      [ $# -ge 2 ] || die "missing value for --repro-step"
      REPRO_STEPS+=("$2")
      shift 2
      ;;
    --output)
      [ $# -ge 2 ] || die "missing value for --output"
      OUTPUT_PATH="$2"
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

[ -n "$TITLE" ] || die "--title is required"
[ -n "$SYMPTOM" ] || die "--symptom is required"

render() {
  local now_utc
  now_utc="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"

  cat <<EOF
# Bug Fix Evidence Loop

- Title: $TITLE
- Symptom: $SYMPTOM
- Created At: $now_utc

## Reproduction Record (\`before\`)

### Expected
- TODO

### Actual
- TODO

### Deterministic Reproduction Steps
EOF

  if [ "${#REPRO_STEPS[@]}" -eq 0 ]; then
    cat <<'EOF'
1. TODO
2. TODO
3. TODO
EOF
  else
    local i
    for i in "${!REPRO_STEPS[@]}"; do
      printf '%s. %s\n' "$((i + 1))" "${REPRO_STEPS[$i]}"
    done
  fi

  cat <<'EOF'

### Runtime Evidence
- Logs:
- Payload snippet:
- UI trace / screenshot:

## Mandatory Questions
1. Do we already have tests that cover this behavior across all stages up to UI display?
   - Answer:
2. Did we inspect current real database/backend payloads to verify compatibility with current parsing and rendering assumptions?
   - Answer:
3. If existing tests should cover this bug, which exact test(s) failed? If none failed, why were they insufficient?
   - Answer:
4. If tests do not cover the failure, which new tests must be created before implementing the fix?
   - Answer:
5. Is the root cause also an architectural deviation pattern that could be prevented earlier by analyzer-enforced rule coverage? Why or why not?
   - Answer:

## Coverage Matrix
| Stage | Status (\`covered|missing|false-green\`) | Current Evidence | Required Action |
| --- | --- | --- | --- |
| API / backend contract | TODO | TODO | TODO |
| DTO decode / mapping | TODO | TODO | TODO |
| Repository translation / cache | TODO | TODO | TODO |
| Controller state transition | TODO | TODO | TODO |
| UI rendering / screen state | TODO | TODO | TODO |

## Real Payload Sample
```json
{}
```

## RED Tests
- Missing or false-green test to add:
- Exact assertion that should fail before the fix:

## Minimal Fix Scope
- Touched surfaces:
- Root cause stage:
- Minimal implementation hypothesis:

## Architecture Prevention Assessment
- Assessment: \`no-rule-needed|rule-candidate\`
- Prevented future failure mode:
- Likely detection boundary:
- Why current rules/analyzers did not block it:
- False-positive risk:

## Regression Hardening
- Negative path assertion:
- Edge timing / partial payload / empty payload case:
- Follow-up debt:

## Verification (\`after\`)
- Targeted suites rerun:
- Deterministic runtime replay:
- Residual risk:
EOF
}

if [ -n "$OUTPUT_PATH" ]; then
  mkdir -p "$(dirname "$OUTPUT_PATH")"
  render >"$OUTPUT_PATH"
  printf 'Wrote bug-fix evidence scaffold to %s\n' "$OUTPUT_PATH"
else
  render
fi
