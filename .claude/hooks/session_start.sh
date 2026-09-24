#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=.claude/hooks/_delphi_hook_common.sh
source "$SCRIPT_DIR/_delphi_hook_common.sh"

run_delphi_hook_guard "SessionStart"
