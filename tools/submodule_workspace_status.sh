#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tools/lib/submodule_workspace.sh
source "${SCRIPT_DIR}/lib/submodule_workspace.sh"

delphi_submodule_require_git_repo
delphi_submodule_ensure_present
delphi_submodule_print_state
