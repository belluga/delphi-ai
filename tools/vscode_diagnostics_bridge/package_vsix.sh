#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
environment_root="$(cd "${script_dir}/../../.." && pwd)"
output_dir="${environment_root}/delphi-ai/artifacts/vsix"
output_file="${output_dir}/belluga.delphi-vscode-diagnostics-bridge-0.1.0.vsix"
mkdir -p "${output_dir}"

(
  cd "${script_dir}"
  npx --yes @vscode/vsce@latest package --out "${output_file}"
)

printf '%s\n' "${output_file}"
