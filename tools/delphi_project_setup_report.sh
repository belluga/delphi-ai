#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: delphi_project_setup_report.sh [--repo <path>] [--lane <auto|bootstrap|recalibration>] [--include-adherence-sync]

Produce a read-only Delphi project setup / recalibration inventory for a downstream repository.

The report:
- classifies the setup lane as bootstrap or recalibration;
- runs the lane-appropriate readiness preflight;
- inventories Delphi-governed and project-owned authority surfaces;
- classifies setup drift into structural, documentation, canonical coverage, and governance buckets.

Options:
  --repo <path>                Repository/environment root. Defaults to current directory.
  --lane <value>               One of auto, bootstrap, recalibration. Defaults to auto.
  --include-adherence-sync     Include `verify_adherence_sync.sh` during the readiness preflight when applicable.
  -h, --help                   Show this help text.

Exit codes:
  0  Report completed and the environment is calibrated or bootstrap preflight is ready.
  2  Report completed and normalization/manual remediation is still required.
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

if [ -f "$REPO_ROOT/main_instructions.md" ] && [ -d "$REPO_ROOT/skills" ] && [ -d "$REPO_ROOT/rules" ] && [ -d "$REPO_ROOT/workflows" ] && [ ! -e "$REPO_ROOT/delphi-ai" ]; then
  die "delphi_project_setup_report.sh is for downstream environments, not the canonical delphi-ai repository"
fi

DEL_ROOT="$REPO_ROOT/delphi-ai"
[ -e "$DEL_ROOT" ] || die "missing delphi-ai at $DEL_ROOT"
[ -f "$DEL_ROOT/tools/environment_readiness_report.sh" ] || die "missing $DEL_ROOT/tools/environment_readiness_report.sh"
[ -f "$DEL_ROOT/init.sh" ] || die "missing $DEL_ROOT/init.sh"

run_and_capture() {
  local output=""
  if output="$("$@" 2>&1)"; then
    CURRENT_STEP_OUTPUT="$output"
    return 0
  fi

  local code=$?
  CURRENT_STEP_OUTPUT="$output"
  return "$code"
}

print_section() {
  local title="$1"
  shift

  printf '%s\n' "$title"
  if [ "$#" -eq 0 ]; then
    printf '  (none)\n'
  else
    local line
    for line in "$@"; do
      [ -n "$line" ] || continue
      printf '  - %s\n' "$line"
    done
  fi
  printf '\n'
}

classify_bucket() {
  local major_count="$1"
  local minor_count="$2"

  if [ "$major_count" -gt 0 ]; then
    printf 'material'
  elif [ "$minor_count" -gt 0 ]; then
    printf 'minor'
  else
    printf 'none'
  fi
}

add_issue() {
  local bucket="$1"
  local severity="$2"
  local message="$3"

  case "$bucket" in
    structural)
      STRUCTURAL_ISSUES+=("$message")
      if [ "$severity" = "material" ]; then
        STRUCTURAL_MAJOR=$((STRUCTURAL_MAJOR + 1))
      else
        STRUCTURAL_MINOR=$((STRUCTURAL_MINOR + 1))
      fi
      ;;
    documentation)
      DOCUMENTATION_ISSUES+=("$message")
      if [ "$severity" = "material" ]; then
        DOCUMENTATION_MAJOR=$((DOCUMENTATION_MAJOR + 1))
      else
        DOCUMENTATION_MINOR=$((DOCUMENTATION_MINOR + 1))
      fi
      ;;
    coverage)
      COVERAGE_ISSUES+=("$message")
      if [ "$severity" = "material" ]; then
        COVERAGE_MAJOR=$((COVERAGE_MAJOR + 1))
      else
        COVERAGE_MINOR=$((COVERAGE_MINOR + 1))
      fi
      ;;
    governance)
      GOVERNANCE_ISSUES+=("$message")
      if [ "$severity" = "material" ]; then
        GOVERNANCE_MAJOR=$((GOVERNANCE_MAJOR + 1))
      else
        GOVERNANCE_MINOR=$((GOVERNANCE_MINOR + 1))
      fi
      ;;
    *)
      die "unknown bucket: $bucket"
      ;;
  esac
}

CURRENT_STEP_OUTPUT=""

declare -a DELPHI_SURFACES=()
declare -a PROJECT_SURFACES=()
declare -a UNSAFE_SURFACES=()

declare -a STRUCTURAL_ISSUES=()
declare -a DOCUMENTATION_ISSUES=()
declare -a COVERAGE_ISSUES=()
declare -a GOVERNANCE_ISSUES=()

STRUCTURAL_MAJOR=0
STRUCTURAL_MINOR=0
DOCUMENTATION_MAJOR=0
DOCUMENTATION_MINOR=0
COVERAGE_MAJOR=0
COVERAGE_MINOR=0
GOVERNANCE_MAJOR=0
GOVERNANCE_MINOR=0

FOUNDATION_ROOT="$REPO_ROOT/foundation_documentation"
MODULES_DIR="$FOUNDATION_ROOT/modules"
POLICIES_DIR="$FOUNDATION_ROOT/policies"
ARTIFACTS_DIR="$FOUNDATION_ROOT/artifacts"

if [ "$LANE" = "auto" ]; then
  if [ ! -d "$FOUNDATION_ROOT" ]; then
    EFFECTIVE_LANE="bootstrap"
  else
    EFFECTIVE_LANE="recalibration"
  fi
else
  EFFECTIVE_LANE="$LANE"
fi

READINESS_STATUS=""
READINESS_CODE=0

if [ "$EFFECTIVE_LANE" = "bootstrap" ]; then
  if run_and_capture bash "$DEL_ROOT/init.sh" --check; then
    READINESS_STATUS="bootstrap-preflight-pass"
  else
    READINESS_STATUS="bootstrap-preflight-blocked"
    READINESS_CODE=2
    add_issue structural material "delphi install preflight is blocked"
    UNSAFE_SURFACES+=("bootstrap install must not proceed until init.sh --check blockers are cleared")
  fi
else
  readiness_cmd=(bash "$DEL_ROOT/tools/environment_readiness_report.sh" --repo "$REPO_ROOT")
  if [ "$INCLUDE_ADHERENCE_SYNC" = true ]; then
    readiness_cmd+=(--include-adherence-sync)
  fi
  if run_and_capture "${readiness_cmd[@]}"; then
    if printf '%s\n' "$CURRENT_STEP_OUTPUT" | grep -Eq 'Context verification FAILED:|Delphi verify_context: FAIL|Overall outcome: blocked'; then
      READINESS_STATUS="recalibration-readiness-blocked"
      READINESS_CODE=2
      add_issue structural material "environment readiness output contains verification blockers"
      UNSAFE_SURFACES+=("readiness report still shows verify_context or downstream blockers")
    else
      READINESS_STATUS="recalibration-readiness-pass"
    fi
  else
    READINESS_STATUS="recalibration-readiness-blocked"
    READINESS_CODE=2
    add_issue structural material "environment readiness report still has blockers"
    UNSAFE_SURFACES+=("do not declare the project calibrated while readiness blockers remain")
  fi
fi

for bootloader in AGENTS.md CLINE.md GEMINI.md CLAUDE.md; do
  if [ -f "$REPO_ROOT/$bootloader" ]; then
    DELPHI_SURFACES+=("bootloader present: $bootloader")
  fi
done

for managed_path in \
  ".codex/skills" \
  ".agents/rules" \
  ".agents/workflows" \
  ".agents/skills" \
  ".clinerules" \
  ".cline/skills"; do
  if [ -e "$REPO_ROOT/$managed_path" ]; then
    DELPHI_SURFACES+=("managed surface present: $managed_path")
  fi
done

for helper in init.sh verify_context.sh tools/environment_readiness_report.sh tools/manifest.md; do
  if [ -e "$DEL_ROOT/$helper" ]; then
    DELPHI_SURFACES+=("delphi helper present: delphi-ai/$helper")
  else
    add_issue structural material "missing Delphi helper: delphi-ai/$helper"
    UNSAFE_SURFACES+=("repair missing Delphi helper: delphi-ai/$helper")
  fi
done

if [ "$EFFECTIVE_LANE" = "recalibration" ]; then
  if [ "${#DELPHI_SURFACES[@]}" -eq 0 ]; then
    add_issue structural material "no recognizable Delphi-governed downstream surfaces were found"
    UNSAFE_SURFACES+=("bootloader and managed Delphi surfaces need reinstallation or repair")
  fi
elif [ "${#DELPHI_SURFACES[@]}" -eq 0 ]; then
  add_issue structural minor "bootstrap lane has not installed downstream Delphi surfaces yet"
fi

if [ -d "$FOUNDATION_ROOT" ]; then
  PROJECT_SURFACES+=("foundation_documentation directory present")
else
  if [ "$EFFECTIVE_LANE" = "bootstrap" ]; then
    DOCUMENTATION_ISSUES+=("project authority docs are not instantiated yet (expected bootstrap output)")
    DOCUMENTATION_MINOR=$((DOCUMENTATION_MINOR + 1))
    COVERAGE_ISSUES+=("module and roadmap docs are not instantiated yet (expected bootstrap output)")
    COVERAGE_MINOR=$((COVERAGE_MINOR + 1))
    GOVERNANCE_ISSUES+=("project governance docs are not instantiated yet (expected bootstrap output)")
    GOVERNANCE_MINOR=$((GOVERNANCE_MINOR + 1))
    UNSAFE_SURFACES+=("project-owned authority does not exist yet; bootstrap must instantiate canonical docs before normal feature work")
  else
    add_issue documentation material "foundation_documentation directory is missing"
    add_issue coverage material "module and roadmap surfaces cannot be assessed because foundation_documentation is missing"
    add_issue governance material "project-owned governance cannot be assessed because foundation_documentation is missing"
    UNSAFE_SURFACES+=("project-owned authority is missing entirely")
  fi
fi

check_project_surface() {
  local rel="$1"
  local label="$2"
  local bucket="$3"
  local severity="$4"

  if [ -f "$FOUNDATION_ROOT/$rel" ]; then
    PROJECT_SURFACES+=("$label present: foundation_documentation/$rel")
  else
    add_issue "$bucket" "$severity" "$label missing: foundation_documentation/$rel"
    UNSAFE_SURFACES+=("$label must be authored locally before relying on implicit assumptions")
  fi
}

if [ -d "$FOUNDATION_ROOT" ]; then
  check_project_surface "project_mandate.md" "project mandate" documentation material
  check_project_surface "domain_entities.md" "domain entities" documentation material
  check_project_surface "project_constitution.md" "project constitution" governance material
  check_project_surface "policies/scope_subscope_governance.md" "scope/subscope governance" governance material

  if [ -f "$FOUNDATION_ROOT/system_roadmap.md" ]; then
    PROJECT_SURFACES+=("system roadmap present: foundation_documentation/system_roadmap.md")
  else
    add_issue coverage minor "system roadmap missing: foundation_documentation/system_roadmap.md"
  fi

  module_count=0
  if [ -d "$MODULES_DIR" ]; then
    module_count="$(find "$MODULES_DIR" -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' ')"
  fi
  if [ "${module_count:-0}" -gt 0 ]; then
    PROJECT_SURFACES+=("module docs present: $module_count markdown file(s)")
  else
    add_issue coverage material "module docs missing or empty: foundation_documentation/modules/"
  fi

  if [ -d "$FOUNDATION_ROOT/todos/active" ] && [ -d "$FOUNDATION_ROOT/todos/completed" ]; then
    PROJECT_SURFACES+=("TODO directories present: foundation_documentation/todos/{active,completed}")
  else
    add_issue governance minor "TODO directories missing: foundation_documentation/todos/{active,completed}"
  fi

  if [ -f "$ARTIFACTS_DIR/dependency-readiness.md" ]; then
    PROJECT_SURFACES+=("dependency readiness artifact present")
  fi
  if [ -f "$ARTIFACTS_DIR/session-memory.md" ]; then
    PROJECT_SURFACES+=("session memory artifact present")
  fi
fi

STRUCTURAL_BUCKET="$(classify_bucket "$STRUCTURAL_MAJOR" "$STRUCTURAL_MINOR")"
DOCUMENTATION_BUCKET="$(classify_bucket "$DOCUMENTATION_MAJOR" "$DOCUMENTATION_MINOR")"
COVERAGE_BUCKET="$(classify_bucket "$COVERAGE_MAJOR" "$COVERAGE_MINOR")"
GOVERNANCE_BUCKET="$(classify_bucket "$GOVERNANCE_MAJOR" "$GOVERNANCE_MINOR")"

OVERALL_STATUS="calibrated"
EXIT_CODE=0

if [ "$EFFECTIVE_LANE" = "bootstrap" ]; then
  if [ "$READINESS_CODE" -eq 0 ] && [ "$STRUCTURAL_BUCKET" != "material" ]; then
    OVERALL_STATUS="bootstrap-preflight-ready"
  else
    OVERALL_STATUS="manual-remediation-required"
    EXIT_CODE=2
  fi
else
  if [ "$STRUCTURAL_BUCKET" = "material" ] || [ "$GOVERNANCE_BUCKET" = "material" ]; then
    OVERALL_STATUS="manual-remediation-required"
    EXIT_CODE=2
  elif [ "$DOCUMENTATION_BUCKET" = "material" ] || [ "$COVERAGE_BUCKET" = "material" ] || [ "$DOCUMENTATION_BUCKET" = "minor" ] || [ "$COVERAGE_BUCKET" = "minor" ] || [ "$GOVERNANCE_BUCKET" = "minor" ]; then
    OVERALL_STATUS="needs-normalization"
    EXIT_CODE=2
  fi
fi

printf 'Delphi Project Setup Report\n'
printf 'Repository: %s\n' "$REPO_ROOT"
printf 'Lane: %s\n' "$EFFECTIVE_LANE"
printf 'Readiness: %s\n' "$READINESS_STATUS"
printf 'Include adherence sync: %s\n' "$([ "$INCLUDE_ADHERENCE_SYNC" = true ] && printf yes || printf no)"
printf '\n'

print_section "Readiness preflight output" "${CURRENT_STEP_OUTPUT:-}"
print_section "Inherited from Delphi" "${DELPHI_SURFACES[@]}"
print_section "Project-owned specialization" "${PROJECT_SURFACES[@]}"
print_section "Unsafe / unresolved" "${UNSAFE_SURFACES[@]}"

printf 'Drift buckets\n'
printf '  - structural: %s\n' "$STRUCTURAL_BUCKET"
printf '  - documentation: %s\n' "$DOCUMENTATION_BUCKET"
printf '  - canonical coverage: %s\n' "$COVERAGE_BUCKET"
printf '  - governance: %s\n' "$GOVERNANCE_BUCKET"
printf '\n'

print_section "Structural issues" "${STRUCTURAL_ISSUES[@]}"
print_section "Documentation issues" "${DOCUMENTATION_ISSUES[@]}"
print_section "Canonical coverage issues" "${COVERAGE_ISSUES[@]}"
print_section "Governance issues" "${GOVERNANCE_ISSUES[@]}"

printf 'Overall status: %s\n' "$OVERALL_STATUS"

if [ "$OVERALL_STATUS" = "bootstrap-preflight-ready" ]; then
  printf 'Recommended next step: run Genesis/installation setup before normal feature work.\n'
elif [ "$OVERALL_STATUS" = "calibrated" ]; then
  printf 'Recommended next step: ready for normal work.\n'
elif [ "$OVERALL_STATUS" = "needs-normalization" ]; then
  printf 'Recommended next step: normalization TODO required.\n'
else
  printf 'Recommended next step: manual remediation required.\n'
fi

exit "$EXIT_CODE"
