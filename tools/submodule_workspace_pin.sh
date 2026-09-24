#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tools/lib/submodule_workspace.sh
source "${SCRIPT_DIR}/lib/submodule_workspace.sh"

delphi_submodule_require_git_repo
delphi_submodule_ensure_present
delphi_submodule_ensure_clean

root="$(delphi_submodule_repo_root)"

echo "Pinning submodules to the exact SHAs recorded by the superproject (non-destructive)..."
echo "NOTE: This does NOT use --force and will refuse to proceed if any submodule is dirty."
echo

git -C "${root}" submodule sync --recursive
git -C "${root}" submodule update --init --recursive

echo
echo "Result:"
git -C "${root}" submodule status

echo
echo "OK: submodules pinned. If you now want convenience lane tracking, run:"
echo "  delphi-ai/tools/submodule_workspace_track_lanes.sh <dev|stage|main>"
