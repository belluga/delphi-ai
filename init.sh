#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -L)"
exec bash "$SCRIPT_DIR/scripts/setup_delphi.sh" "$@"
