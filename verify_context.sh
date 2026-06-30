#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -L)"

if [[ -f "$SCRIPT_DIR/tools/lib/script_usage.sh" ]]; then
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/tools/lib/script_usage.sh"
  delphi_script_usage_init \
    --script-id "delphi.verify_context" \
    --script-path "delphi-ai/verify_context.sh" \
    --surface "delphi-tool" \
    --start-dir "$PWD"
  delphi_script_usage_set_scenario "verify"
  for arg in "$@"; do
    if [[ "$arg" == "--repair" ]]; then
      delphi_script_usage_set_scenario "repair"
      break
    fi
  done
  delphi_script_usage_install_exit_trap
fi

bash "$SCRIPT_DIR/tools/verify_context.sh" "$@"
