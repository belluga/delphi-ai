#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tools/lib/submodule_workspace.sh
source "${SCRIPT_DIR}/lib/submodule_workspace.sh"

delphi_submodule_require_git_repo
delphi_submodule_ensure_present

lane="${1:-}"
if [[ -z "${lane}" ]]; then
  delphi_submodule_die "usage: $0 <dev|stage|main>"
fi
case "${lane}" in
  dev|stage|main) ;;
  *) delphi_submodule_die "invalid lane '${lane}' (expected: dev, stage, main)" ;;
esac

delphi_submodule_ensure_clean

root="$(delphi_submodule_repo_root)"

echo "Switching submodules to lane branches (safe; refuses if dirty)..."
echo "  lane: ${lane}"
echo

switch_to_remote_branch() {
  local sm="$1"
  local branch="$2"

  if ! git -C "${root}/${sm}" ls-remote --exit-code --heads origin "${branch}" >/dev/null 2>&1; then
    echo "SKIP: ${sm} has no origin/${branch}"
    return 0
  fi

  git -C "${root}/${sm}" fetch origin "${branch}" --quiet

  if git -C "${root}/${sm}" rev-parse --verify "${branch}" >/dev/null 2>&1; then
    git -C "${root}/${sm}" switch "${branch}" --quiet
  else
    git -C "${root}/${sm}" switch -c "${branch}" --track "origin/${branch}" --quiet
  fi

  echo "OK: ${sm} -> ${branch}"
}

while IFS= read -r sm; do
  [[ -n "${sm}" ]] || continue
  if [[ ! -d "${root}/${sm}/.git" && ! -f "${root}/${sm}/.git" ]]; then
    delphi_submodule_die "submodule '${sm}' is not initialized; run delphi-ai/tools/submodule_workspace_pin.sh first"
  fi

  target_branch="$(delphi_submodule_tracking_branch_for_path "${sm}" "${lane}")"
  switch_to_remote_branch "${sm}" "${target_branch}"
done < <(delphi_submodule_paths)

echo
echo "Result:"
delphi_submodule_print_state

echo
echo "NOTE: lane tracking is for convenience only. CI/deploy uses the superproject pins."
echo "To return to reproducible pins, run:"
echo "  delphi-ai/tools/submodule_workspace_pin.sh"
