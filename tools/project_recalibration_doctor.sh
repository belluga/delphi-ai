#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: project_recalibration_doctor.sh [--repo <path>] [--lane <auto|bootstrap|recalibration>] [--include-adherence-sync] [--artifacts-dir <path>]

Run the PACED brownfield/recalibration automation in one pass for a downstream repository:
- produce the derived project setup report (text + JSON);
- derive the project normalization packet (JSON + Markdown);
- print the exact next step and artifact locations.

Options:
  --repo <path>                Downstream repository root. Defaults to current directory.
  --lane <value>               One of auto, bootstrap, recalibration. Defaults to auto.
  --include-adherence-sync     Include verify_adherence_sync during recalibration readiness checks.
  --artifacts-dir <path>       Output directory for derived artifacts.
                               Defaults to <repo>/foundation_documentation/artifacts/tmp
  -h, --help                   Show this help text.

Exit codes:
  0  Report/packet completed and the project is calibrated or bootstrap-preflight-ready.
  2  Report/packet completed and normalization/manual remediation is still required.
  1  Operational error.
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

REPO_INPUT="."
LANE="auto"
INCLUDE_ADHERENCE_SYNC=false
ARTIFACTS_DIR=""

while [ $# -gt 0 ]; do
  case "$1" in
    --repo)
      [ $# -ge 2 ] || die "missing value for --repo"
      REPO_INPUT="$2"
      shift 2
      ;;
    --lane)
      [ $# -ge 2 ] || die "missing value for --lane"
      LANE="$2"
      shift 2
      ;;
    --include-adherence-sync)
      INCLUDE_ADHERENCE_SYNC=true
      shift
      ;;
    --artifacts-dir)
      [ $# -ge 2 ] || die "missing value for --artifacts-dir"
      ARTIFACTS_DIR="$2"
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

case "$LANE" in
  auto|bootstrap|recalibration) ;;
  *) die "invalid --lane value: $LANE" ;;
esac

REPO_ROOT="$(git -C "$REPO_INPUT" rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$REPO_ROOT" ]; then
  REPO_ROOT="$(cd "$REPO_INPUT" 2>/dev/null && pwd || true)"
fi
[ -n "$REPO_ROOT" ] || die "unable to resolve repository root from: $REPO_INPUT"

DEL_ROOT="$REPO_ROOT/delphi-ai"
[ -f "$DEL_ROOT/tools/delphi_project_setup_report.sh" ] || die "missing $DEL_ROOT/tools/delphi_project_setup_report.sh"
[ -f "$DEL_ROOT/tools/project_setup_normalization_packet.py" ] || die "missing $DEL_ROOT/tools/project_setup_normalization_packet.py"

if [ -z "$ARTIFACTS_DIR" ]; then
  ARTIFACTS_DIR="$REPO_ROOT/foundation_documentation/artifacts/tmp"
fi
mkdir -p "$ARTIFACTS_DIR"

REPORT_TEXT_PATH="$ARTIFACTS_DIR/project-setup-report.txt"
REPORT_JSON_PATH="$ARTIFACTS_DIR/project-setup-report.json"
PACKET_JSON_PATH="$ARTIFACTS_DIR/project-normalization-packet.json"
PACKET_MD_PATH="$ARTIFACTS_DIR/project-normalization-packet.md"

report_cmd=(
  bash "$DEL_ROOT/tools/delphi_project_setup_report.sh"
  --repo "$REPO_ROOT"
  --lane "$LANE"
  --json-output "$REPORT_JSON_PATH"
)
if [ "$INCLUDE_ADHERENCE_SYNC" = true ]; then
  report_cmd+=(--include-adherence-sync)
fi

REPORT_STDOUT=""
REPORT_EXIT=0
if REPORT_STDOUT="$("${report_cmd[@]}" 2>&1)"; then
  REPORT_EXIT=0
else
  REPORT_EXIT=$?
  if [ "$REPORT_EXIT" -ne 2 ]; then
    printf '%s\n' "$REPORT_STDOUT" >&2
    exit "$REPORT_EXIT"
  fi
fi

printf '%s\n' "$REPORT_STDOUT" > "$REPORT_TEXT_PATH"
printf '%s\n' "$REPORT_STDOUT"

python3 "$DEL_ROOT/tools/project_setup_normalization_packet.py" \
  --report "$REPORT_JSON_PATH" \
  --json-output "$PACKET_JSON_PATH" \
  --markdown-output "$PACKET_MD_PATH"

python3 - "$PACKET_JSON_PATH" "$REPORT_TEXT_PATH" "$REPORT_JSON_PATH" "$PACKET_MD_PATH" <<'PY'
import json
import sys
from pathlib import Path

packet_path = Path(sys.argv[1])
report_text_path = Path(sys.argv[2])
report_json_path = Path(sys.argv[3])
packet_md_path = Path(sys.argv[4])

packet = json.loads(packet_path.read_text(encoding="utf-8"))
print("Derived artifacts:")
print(f"  - setup report (text): {report_text_path}")
print(f"  - setup report (json): {report_json_path}")
print(f"  - normalization packet (json): {packet_path}")
print(f"  - normalization packet (md): {packet_md_path}")
print(f"Exact next step: {packet['exact_next_step']}")
PY

exit "$REPORT_EXIT"
