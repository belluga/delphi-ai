#!/usr/bin/env bash

delphi_submodule_repo_root() {
  git rev-parse --show-toplevel
}

delphi_submodule_die() {
  echo "ERROR: $*" >&2
  exit 1
}

delphi_submodule_require_git_repo() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || delphi_submodule_die "not inside a git repository"
}

delphi_submodule_gitmodules_file() {
  local root
  root="$(delphi_submodule_repo_root)"
  [[ -f "${root}/.gitmodules" ]] || delphi_submodule_die ".gitmodules not found at ${root}"
  printf '%s\n' "${root}/.gitmodules"
}

delphi_submodule_paths() {
  local gitmodules raw_paths
  gitmodules="$(delphi_submodule_gitmodules_file)"
  raw_paths="$(git config -f "${gitmodules}" --get-regexp '^submodule\..*\.path$' 2>/dev/null || true)"
  if [[ -z "${raw_paths}" ]]; then
    return 0
  fi

  printf '%s\n' "${raw_paths}" | awk '{print $2}'
}

delphi_submodule_require_configured_paths() {
  local found=0 sm
  while IFS= read -r sm; do
    [[ -n "${sm}" ]] || continue
    found=1
    break
  done < <(delphi_submodule_paths)

  [[ "${found}" -eq 1 ]] || delphi_submodule_die "no submodule paths declared in .gitmodules"
}

delphi_submodule_ensure_present() {
  local root sm
  delphi_submodule_require_configured_paths
  root="$(delphi_submodule_repo_root)"

  while IFS= read -r sm; do
    [[ -n "${sm}" ]] || continue
    if [[ ! -e "${root}/${sm}" ]]; then
      delphi_submodule_die "missing submodule path '${sm}' (expected at '${root}/${sm}')"
    fi
  done < <(delphi_submodule_paths)
}

delphi_submodule_ensure_clean() {
  local root dirty sm
  root="$(delphi_submodule_repo_root)"
  dirty=0

  while IFS= read -r sm; do
    [[ -n "${sm}" ]] || continue
    if [[ ! -d "${root}/${sm}/.git" && ! -f "${root}/${sm}/.git" ]]; then
      continue
    fi

    if [[ -n "$(git -C "${root}/${sm}" status --porcelain=v1)" ]]; then
      echo "DIRTY: ${sm}" >&2
      git -C "${root}/${sm}" status --porcelain=v1 >&2
      dirty=1
    fi
  done < <(delphi_submodule_paths)

  if [[ "${dirty}" -ne 0 ]]; then
    delphi_submodule_die "refusing to proceed: there are dirty submodules (commit/stash/discard changes first)"
  fi
}

delphi_submodule_print_state() {
  local root sm
  root="$(delphi_submodule_repo_root)"

  echo "Superproject:"
  echo "  root:   ${root}"
  echo "  branch: $(git -C "${root}" branch --show-current || true)"
  echo "  commit: $(git -C "${root}" rev-parse --short HEAD)"
  echo

  echo "Submodule pins (from superproject):"
  git -C "${root}" submodule status || true
  echo

  echo "Submodule working state:"
  while IFS= read -r sm; do
    [[ -n "${sm}" ]] || continue
    if [[ ! -d "${root}/${sm}/.git" && ! -f "${root}/${sm}/.git" ]]; then
      echo "  - ${sm}: (not initialized)"
      continue
    fi

    local branch head_short dirty
    branch="$(git -C "${root}/${sm}" rev-parse --abbrev-ref HEAD 2>/dev/null || echo '(unknown)')"
    head_short="$(git -C "${root}/${sm}" rev-parse --short HEAD 2>/dev/null || echo '(unknown)')"
    if [[ -n "$(git -C "${root}/${sm}" status --porcelain=v1)" ]]; then
      dirty="dirty"
    else
      dirty="clean"
    fi

    echo "  - ${sm}: ${branch} @ ${head_short} (${dirty})"
  done < <(delphi_submodule_paths)
}

delphi_submodule_tracking_branch_for_path() {
  local submodule_path="$1"
  local requested_lane="$2"

  if [[ "${submodule_path}" == "foundation_documentation" ]]; then
    printf 'main\n'
    return 0
  fi

  printf '%s\n' "${requested_lane}"
}
