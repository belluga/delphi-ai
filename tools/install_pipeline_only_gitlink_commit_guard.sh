#!/usr/bin/env bash
set -euo pipefail

TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/git_hook_stack.sh
source "${TOOLS_DIR}/lib/git_hook_stack.sh"

usage() {
  cat <<'EOF'
Usage:
  bash delphi-ai/tools/install_pipeline_only_gitlink_commit_guard.sh --repo <path>

Installs a local pre-commit hook in the shared Delphi hook stack that blocks manual
gitlink commits. In this model, submodule pointer movement is pipeline-owned only
and must not be committed by hand.
EOF
}

repo_path=""

while (($# > 0)); do
  case "$1" in
    --repo)
      repo_path="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: unknown argument: $1" >&2
      usage >&2
      exit 64
      ;;
  esac
done

if [[ -z "$repo_path" ]]; then
  echo "ERROR: --repo is required." >&2
  usage >&2
  exit 64
fi

if ! git -C "$repo_path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: '$repo_path' is not a Git working tree." >&2
  exit 65
fi

repo_abs="$(cd "$repo_path" && pwd -P)"
delphi_hook_stack_prepare "$repo_abs"

hook_file="$(mktemp)"
trap 'rm -f "$hook_file"' EXIT

cat >"$hook_file" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [[ "${DELPHI_PIPELINE_ONLY_GITLINK_INTERNAL_BYPASS:-0}" == "1" ]]; then
  exit 0
fi

collect_gitlink_paths() {
  local mode="$1"
  local -a git_args=()
  local -a paths=()
  local meta primary_path secondary_path
  local path
  local old_mode
  local new_mode
  local existing

  case "$mode" in
    staged)
      git_args=(diff --cached --raw --ignore-submodules=none --)
      ;;
    worktree)
      git_args=(diff --raw --ignore-submodules=none --)
      ;;
    *)
      echo "ERROR: unsupported mode '$mode'." >&2
      exit 98
      ;;
  esac

  while IFS=$'\t' read -r meta primary_path secondary_path; do
    path="$primary_path"
    [[ -n "${secondary_path:-}" ]] && path="$secondary_path"
    [[ -n "${path:-}" ]] || continue

    set -- $meta
    old_mode="${1#:}"
    new_mode="${2:-000000}"

    if [[ "$old_mode" == "160000" || "$new_mode" == "160000" ]]; then
      for existing in "${paths[@]}"; do
        [[ "$existing" == "$path" ]] && continue 2
      done
      paths+=("$path")
    fi
  done < <(git "${git_args[@]}")

  if [[ "${#paths[@]}" -gt 0 ]]; then
    printf '%s\n' "${paths[@]}"
  fi
}

mapfile -t staged_gitlinks < <(collect_gitlink_paths staged)
mapfile -t worktree_gitlinks < <(collect_gitlink_paths worktree)

if [[ "${#staged_gitlinks[@]}" -eq 0 && "${#worktree_gitlinks[@]}" -eq 0 ]]; then
  exit 0
fi

{
  echo "PACED Pipeline-Only Gitlink Commit Guard"
  echo
  echo "Problem:"
  echo "Manual commit attempted while the superproject contains gitlink movement."
  echo
  echo "Authority:"
  echo "In this repository, gitlink updates are pipeline-produced artifacts. Only the"
  echo "project-authorized automation may move submodule pointers; manual local commits"
  echo "must not do so."
  echo
  echo "Constraint:"
  echo "Any staged gitlink diff or worktree gitlink drift blocks 'git commit', including"
  echo "paths that 'git commit -a' would auto-stage."
  echo
  if [[ "${#staged_gitlinks[@]}" -gt 0 ]]; then
    echo "Staged gitlink paths:"
    printf ' - %s\n' "${staged_gitlinks[@]}"
  fi
  if [[ "${#worktree_gitlinks[@]}" -gt 0 ]]; then
    echo "Worktree gitlink paths:"
    printf ' - %s\n' "${worktree_gitlinks[@]}"
  fi
  echo
  echo "Expected Behavior:"
  echo "Revert or unstage the gitlink changes before committing normal files."
  echo "If the project needs a new submodule pin, wait for the project-authorized"
  echo "pipeline to create or refresh the automation branch that carries the gitlink"
  echo "update (for example a bot-produced lane branch)."
  echo
  echo "Decision:"
  echo "Commit blocked because gitlink movement was detected outside the project-authorized automation path."
} >&2

exit 42
EOF

delphi_hook_stack_install_managed_hook "pipeline-only-gitlink" "pre-commit" "$hook_file"
delphi_hook_stack_activate "$repo_abs"

printf 'Installed Delphi pipeline-only gitlink commit guard in %s\n' "$repo_abs"
printf 'Git hooks path: %s\n' "$DELPHI_HOOK_STACK_BIN_DIR"
