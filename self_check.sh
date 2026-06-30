#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "$SCRIPT_DIR/tools/lib/script_usage.sh" ]]; then
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/tools/lib/script_usage.sh"
  delphi_script_usage_init \
    --script-id "delphi.self_check" \
    --script-path "delphi-ai/self_check.sh" \
    --surface "delphi-tool" \
    --start-dir "$PWD"
  delphi_script_usage_install_exit_trap
fi

bash "$SCRIPT_DIR/tools/self_check.sh" "$@"
