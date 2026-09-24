#!/usr/bin/env bash
set -euo pipefail

TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/git_hook_stack.sh
source "${TOOLS_DIR}/lib/git_hook_stack.sh"

usage() {
  cat <<'EOF'
Usage:
  bash delphi-ai/tools/install_protected_path_commit_guard.sh \
    --repo <path> \
    --path <tracked-path> \
    [--path <tracked-path> ...] \
    [--guard-id <id>] \
    [--guard-title <title>] \
    [--authority <text>] \
    [--expected-behavior <text>] \
    [--resolution <text>]

Installs a local pre-commit hook in the shared Delphi hook stack that blocks
ordinary local commits whenever the protected tracked paths changed.

Example:
  bash delphi-ai/tools/install_protected_path_commit_guard.sh \
    --repo . \
    --path .gitmodules \
    --guard-id gitmodules-pipeline-owned \
    --guard-title "PACED .gitmodules Commit Guard" \
    --authority ".gitmodules is a pipeline-read topology contract in this repository. Local commits must not mutate it." \
    --expected-behavior "Revert or unstage .gitmodules and route approved topology changes through the owning workflow." \
    --resolution "Commit blocked because .gitmodules changed outside the owning workflow."
EOF
}

repo_path=""
guard_id="protected-path-commit-guard"
guard_title="PACED Protected Path Commit Guard"
authority_message=""
expected_behavior_message=""
resolution_message=""
declare -a protected_paths=()

while (($# > 0)); do
  case "$1" in
    --repo)
      repo_path="${2:-}"
      shift 2
      ;;
    --path)
      protected_paths+=("${2:-}")
      shift 2
      ;;
    --guard-id)
      guard_id="${2:-}"
      shift 2
      ;;
    --guard-title)
      guard_title="${2:-}"
      shift 2
      ;;
    --authority)
      authority_message="${2:-}"
      shift 2
      ;;
    --expected-behavior)
      expected_behavior_message="${2:-}"
      shift 2
      ;;
    --resolution)
      resolution_message="${2:-}"
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

if [[ "${#protected_paths[@]}" -eq 0 ]]; then
  echo "ERROR: at least one --path is required." >&2
  usage >&2
  exit 64
fi

if ! [[ "$guard_id" =~ ^[A-Za-z0-9._-]+$ ]]; then
  echo "ERROR: --guard-id must match [A-Za-z0-9._-]+." >&2
  exit 64
fi

if ! git -C "$repo_path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: '$repo_path' is not a Git working tree." >&2
  exit 65
fi

repo_abs="$(cd "$repo_path" && pwd -P)"
delphi_hook_stack_prepare "$repo_abs"

contains_gitmodules="false"
for protected_path in "${protected_paths[@]}"; do
  if [[ -z "$protected_path" ]]; then
    echo "ERROR: --path values must be non-empty." >&2
    exit 64
  fi
  if [[ "$protected_path" == ".gitmodules" ]]; then
    contains_gitmodules="true"
  fi
done

if [[ -z "$authority_message" ]]; then
  if [[ "$contains_gitmodules" == "true" ]]; then
    authority_message=".gitmodules is being treated as a protected topology contract in this repository. Local commits must not mutate it because CI, promotion, and submodule policy may read it as authority."
  else
    authority_message="These tracked paths are protected by project-authorized policy or workflow and are not available for ordinary local mutation."
  fi
fi

if [[ -z "$expected_behavior_message" ]]; then
  if [[ "$contains_gitmodules" == "true" ]]; then
    expected_behavior_message="Revert or unstage .gitmodules before committing. Route approved submodule-topology changes through the owning workflow or explicit policy update."
  else
    expected_behavior_message="Revert or unstage the protected path changes before committing. Route approved mutations through the owning workflow or explicit policy update."
  fi
fi

if [[ -z "$resolution_message" ]]; then
  if [[ "$contains_gitmodules" == "true" ]]; then
    resolution_message="Commit blocked because .gitmodules changed outside the owning workflow."
  else
    resolution_message="Commit blocked because protected tracked-path movement was detected outside the owning workflow."
  fi
fi

hook_file="$(mktemp)"
trap 'rm -f "$hook_file"' EXIT

{
  echo '#!/usr/bin/env bash'
  echo 'set -euo pipefail'
  echo
  echo 'if [[ "${DELPHI_PROTECTED_PATH_COMMIT_GUARD_INTERNAL_BYPASS:-0}" == "1" ]]; then'
  echo '  exit 0'
  echo 'fi'
  echo
  printf 'guard_title=%q\n' "$guard_title"
  printf 'authority_message=%q\n' "$authority_message"
  printf 'expected_behavior_message=%q\n' "$expected_behavior_message"
  printf 'resolution_message=%q\n' "$resolution_message"
  printf 'protected_paths=('
  for protected_path in "${protected_paths[@]}"; do
    printf ' %q' "$protected_path"
  done
  printf ' )\n'
  cat <<'EOF'

collect_changed_paths() {
  local mode="$1"
  local -a git_args=()

  case "$mode" in
    staged)
      git_args=(diff --cached --name-only --)
      ;;
    worktree)
      git_args=(diff --name-only --)
      ;;
    *)
      echo "ERROR: unsupported mode '$mode'." >&2
      exit 98
      ;;
  esac

  git "${git_args[@]}" "${protected_paths[@]}" \
    | sed '/^$/d' \
    | LC_ALL=C sort -u
}

mapfile -t staged_paths < <(collect_changed_paths staged)
mapfile -t worktree_paths < <(collect_changed_paths worktree)

if [[ "${#staged_paths[@]}" -eq 0 && "${#worktree_paths[@]}" -eq 0 ]]; then
  exit 0
fi

{
  echo "${guard_title}"
  echo
  echo "Problem:"
  echo "Manual commit attempted while protected tracked paths changed."
  echo
  echo "Authority:"
  echo "${authority_message}"
  echo
  echo "Constraint:"
  echo "Any staged diff or worktree drift under the protected path set blocks 'git commit', including"
  echo "paths that 'git commit -a' would auto-stage."
  echo
  echo "Protected path selectors:"
  printf ' - %s\n' "${protected_paths[@]}"
  echo
  if [[ "${#staged_paths[@]}" -gt 0 ]]; then
    echo "Staged protected paths:"
    printf ' - %s\n' "${staged_paths[@]}"
  fi
  if [[ "${#worktree_paths[@]}" -gt 0 ]]; then
    echo "Worktree protected paths:"
    printf ' - %s\n' "${worktree_paths[@]}"
  fi
  echo
  echo "Expected Behavior:"
  echo "${expected_behavior_message}"
  echo
  echo "Decision:"
  echo "${resolution_message}"
} >&2

exit 43
EOF
} >"$hook_file"

delphi_hook_stack_install_managed_hook "$guard_id" "pre-commit" "$hook_file"
delphi_hook_stack_activate "$repo_abs"

printf 'Installed Delphi protected-path commit guard in %s\n' "$repo_abs"
printf 'Git hooks path: %s\n' "$DELPHI_HOOK_STACK_BIN_DIR"
printf 'Guard id: %s\n' "$guard_id"
printf 'Protected paths:\n'
printf ' - %s\n' "${protected_paths[@]}"
