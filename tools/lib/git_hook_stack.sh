#!/usr/bin/env bash

# Shared installer helpers for Delphi-managed Git hook stacks.

delphi_hook_stack_prepare() {
  local repo_abs="$1"
  local git_dir_raw=""
  local git_dir=""

  git_dir_raw="$(git -C "$repo_abs" rev-parse --git-dir)"
  if [[ "$git_dir_raw" = /* ]]; then
    git_dir="$git_dir_raw"
  else
    git_dir="$(cd "$repo_abs/$git_dir_raw" && pwd -P)"
  fi

  DELPHI_HOOK_STACK_GIT_DIR="$git_dir"
  DELPHI_HOOK_STACK_ROOT="$git_dir/delphi-hooks"
  DELPHI_HOOK_STACK_MANAGED_DIR="$DELPHI_HOOK_STACK_ROOT/managed"
  DELPHI_HOOK_STACK_BIN_DIR="$DELPHI_HOOK_STACK_ROOT/bin"

  mkdir -p "$DELPHI_HOOK_STACK_MANAGED_DIR" "$DELPHI_HOOK_STACK_BIN_DIR"
}

delphi_hook_stack_activate() {
  local repo_abs="$1"
  git -C "$repo_abs" config core.hooksPath "$DELPHI_HOOK_STACK_BIN_DIR"
}

delphi_hook_stack_managed_hook_path() {
  local guard_id="$1"
  local hook_name="$2"

  printf '%s/%s/%s\n' "$DELPHI_HOOK_STACK_MANAGED_DIR" "$guard_id" "$hook_name"
}

delphi_hook_stack_install_launcher() {
  local hook_name="$1"
  local launcher_path="$DELPHI_HOOK_STACK_BIN_DIR/$hook_name"

  cat >"$launcher_path" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

hook_name="$(basename "$0")"
hooks_root="$(cd "$(dirname "$0")/.." && pwd -P)"
managed_root="${hooks_root}/managed"

if [[ ! -d "${managed_root}" ]]; then
  exit 0
fi

shopt -s nullglob
scripts=("${managed_root}"/*/"${hook_name}")
if [[ "${#scripts[@]}" -eq 0 ]]; then
  exit 0
fi

mapfile -t sorted_scripts < <(printf '%s\n' "${scripts[@]}" | LC_ALL=C sort)

stdin_file=""
cleanup() {
  if [[ -n "${stdin_file}" && -f "${stdin_file}" ]]; then
    rm -f "${stdin_file}"
  fi
}
trap cleanup EXIT

case "${hook_name}" in
  pre-push|post-rewrite|reference-transaction)
    stdin_file="$(mktemp)"
    cat >"${stdin_file}"
    ;;
esac

for script in "${sorted_scripts[@]}"; do
  [[ -x "${script}" ]] || continue
  if [[ -n "${stdin_file}" ]]; then
    "${script}" "$@" <"${stdin_file}"
  else
    "${script}" "$@"
  fi
done
EOF

  chmod +x "$launcher_path"
}

delphi_hook_stack_install_managed_hook() {
  local guard_id="$1"
  local hook_name="$2"
  local source_path="$3"
  local target_path=""

  target_path="$(delphi_hook_stack_managed_hook_path "$guard_id" "$hook_name")"
  mkdir -p "$(dirname "$target_path")"
  cp "$source_path" "$target_path"
  chmod +x "$target_path"
  delphi_hook_stack_install_launcher "$hook_name"
}
