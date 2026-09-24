#!/usr/bin/env bash
set -euo pipefail

TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/git_hook_stack.sh
source "${TOOLS_DIR}/lib/git_hook_stack.sh"

usage() {
  cat <<'EOF'
Usage:
  bash delphi-ai/tools/install_foundation_main_only_guard.sh --repo <path> [--branch main]

Installs local Git hooks in the shared Delphi hook stack that enforce a canonical
foundation_documentation repository to remain on a single writable branch. The
default approved branch is `main`.
EOF
}

repo_path=""
canonical_branch="main"

while (($# > 0)); do
  case "$1" in
    --repo)
      repo_path="${2:-}"
      shift 2
      ;;
    --branch)
      canonical_branch="${2:-}"
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

if ! git -C "$repo_path" rev-parse --verify "refs/heads/$canonical_branch^{commit}" >/dev/null 2>&1; then
  echo "ERROR: canonical branch '$canonical_branch' does not exist in '$repo_path'." >&2
  exit 66
fi

repo_abs="$(cd "$repo_path" && pwd -P)"
git_dir_raw="$(git -C "$repo_abs" rev-parse --git-dir)"
git_common_dir_raw="$(git -C "$repo_abs" rev-parse --git-common-dir)"

if [[ "$git_dir_raw" = /* ]]; then
  git_dir_abs="$git_dir_raw"
else
  git_dir_abs="$(cd "$repo_abs/$git_dir_raw" && pwd -P)"
fi

if [[ "$git_common_dir_raw" = /* ]]; then
  git_common_dir_abs="$git_common_dir_raw"
else
  git_common_dir_abs="$(cd "$repo_abs/$git_common_dir_raw" && pwd -P)"
fi

if [[ "$git_dir_abs" == *"/worktrees/"* ]]; then
  cat >&2 <<EOF
ERROR: '$repo_abs' is a linked Git worktree for foundation_documentation.

Canonical foundation_documentation repositories are single-branch single-checkout
authorities. Install this guard only in the canonical checkout on '${canonical_branch}',
not in a linked worktree, copied writable mirror, or other auxiliary folder.

Canonical checkout hint:
  git common dir: $git_common_dir_abs
EOF
  exit 67
fi

delphi_hook_stack_prepare "$repo_abs"

guard_lib="$(mktemp)"
reference_hook="$(mktemp)"
post_checkout_hook="$(mktemp)"
pre_commit_hook="$(mktemp)"
pre_push_hook="$(mktemp)"
trap 'rm -f "$guard_lib" "$reference_hook" "$post_checkout_hook" "$pre_commit_hook" "$pre_push_hook"' EXIT

cat >"$guard_lib" <<EOF
#!/usr/bin/env bash
set -euo pipefail

source "${TOOLS_DIR}/lib/teach_runtime.sh"

canonical_repo_abs="${repo_abs}"
canonical_branch="${canonical_branch}"

resolve_git_dir() {
  local git_dir_raw=""

  git_dir_raw="\$(git rev-parse --git-dir)"
  if [[ "\$git_dir_raw" = /* ]]; then
    printf '%s\n' "\$git_dir_raw"
  else
    printf '%s\n' "\$(cd "\$git_dir_raw" && pwd -P)"
  fi
}

resolve_git_common_dir() {
  local git_common_dir_raw=""

  git_common_dir_raw="\$(git rev-parse --git-common-dir)"
  if [[ "\$git_common_dir_raw" = /* ]]; then
    printf '%s\n' "\$git_common_dir_raw"
  else
    printf '%s\n' "\$(cd "\$git_common_dir_raw" && pwd -P)"
  fi
}

resolve_repo_root() {
  local repo_root_raw=""

  repo_root_raw="\$(git rev-parse --show-toplevel)"
  printf '%s\n' "\$(cd "\$repo_root_raw" && pwd -P)"
}

list_linked_worktree_admins() {
  local common_dir="\$1"
  local worktrees_dir="\$common_dir/worktrees"

  [[ -d "\$worktrees_dir" ]] || return 0
  find "\$worktrees_dir" -mindepth 1 -maxdepth 1 -type d -print | LC_ALL=C sort
}

emit_branch_ref_teach() {
  local attempted_ref="\$1"
  local exit_code="\$2"
  local repo_root=""
  local git_dir=""
  local current_branch=""

  repo_root="\$(resolve_repo_root)"
  git_dir="\$(resolve_git_dir)"
  current_branch="\$(git symbolic-ref --quiet --short HEAD || true)"

  teach_runtime_begin "paced.foundation-documentation.main-only" "stop_before_split_authority"
  teach_add_violation "foundation_documentation is a canonical single-checkout authority; branch ref '\${attempted_ref}' is outside the only approved writable branch '\${canonical_branch}'."
  teach_add_violation "Do not create or switch to feature branches, reconcile branches, detached HEADs, linked worktrees, alternate folders, copied writable mirrors, second writable clones, or any other local authority artifact for foundation_documentation."
  teach_add_resolution "Use only the canonical checkout at '\${canonical_repo_abs}' on branch '\${canonical_branch}'."
  teach_add_resolution "If needed, run: git checkout \${canonical_branch} && git pull --ff-only origin \${canonical_branch}"
  teach_add_resolution "Make the documentation change directly on '\${canonical_branch}' and push '\${canonical_branch}'."
  teach_add_context "repo: \${repo_root}"
  teach_add_context "git_dir: \${git_dir}"
  teach_add_context "current_branch: \${current_branch:-detached}"
  teach_add_context "attempted_ref: \${attempted_ref}"
  teach_emit_blocked >&2

  exit "\$exit_code"
}

emit_current_branch_teach() {
  local operation="\$1"
  local current_branch="\$2"
  local exit_code="\$3"
  local repo_root=""
  local git_dir=""

  repo_root="\$(resolve_repo_root)"
  git_dir="\$(resolve_git_dir)"

  teach_runtime_begin "paced.foundation-documentation.main-only" "stop_before_split_authority"
  teach_add_violation "foundation_documentation \${operation} was attempted while checked out on '\${current_branch:-detached}', outside the only approved writable branch '\${canonical_branch}'."
  teach_add_violation "Do not create or switch to feature branches, reconcile branches, detached HEADs, linked worktrees, alternate folders, copied writable mirrors, second writable clones, or any other local authority artifact for foundation_documentation."
  teach_add_resolution "Return to '\${canonical_branch}' in the canonical checkout at '\${canonical_repo_abs}'."
  teach_add_resolution "Run: git checkout \${canonical_branch} && git pull --ff-only origin \${canonical_branch}"
  teach_add_context "repo: \${repo_root}"
  teach_add_context "git_dir: \${git_dir}"
  teach_add_context "current_branch: \${current_branch:-detached}"
  teach_emit_blocked >&2

  exit "\$exit_code"
}

emit_parallel_authority_teach() {
  local operation="\$1"
  local exit_code="\$2"
  local repo_root=""
  local git_dir=""
  local common_dir=""
  local current_branch=""
  local linked_admins=""
  local linked_admins_compact=""

  repo_root="\$(resolve_repo_root)"
  git_dir="\$(resolve_git_dir)"
  common_dir="\$(resolve_git_common_dir)"
  current_branch="\$(git symbolic-ref --quiet --short HEAD || true)"
  linked_admins="\$(list_linked_worktree_admins "\$common_dir")"
  linked_admins_compact="\${linked_admins//\$'\\n'/ | }"

  teach_runtime_begin "paced.foundation-documentation.main-only" "stop_before_split_authority"

  if [[ "\$repo_root" != "\$canonical_repo_abs" ]]; then
    teach_add_violation "foundation_documentation \${operation} was attempted from '\${repo_root}', not from the only approved canonical checkout '\${canonical_repo_abs}'."
  fi

  if [[ "\$git_dir" == *"/worktrees/"* ]]; then
    teach_add_violation "foundation_documentation is running from a linked Git worktree gitdir, which creates a second writable authority surface."
  fi

  if [[ -n "\$linked_admins" ]]; then
    teach_add_violation "foundation_documentation detected linked worktree admin entries under '\${common_dir}/worktrees'; writable operations are fail-closed until those artifacts are removed."
  fi

  teach_add_violation "Do not create linked worktrees, alternate folders, copied writable mirrors, second writable clones, or any other parallel local authority artifact for canonical foundation_documentation."
  teach_add_resolution "Use only the canonical checkout at '\${canonical_repo_abs}' on branch '\${canonical_branch}'."

  if [[ "\$git_dir" == *"/worktrees/"* || -n "\$linked_admins" ]]; then
    teach_add_resolution "Remove the linked worktree artifact(s). From the canonical checkout, run: git worktree prune"
  fi

  if [[ "\$repo_root" != "\$canonical_repo_abs" ]]; then
    teach_add_resolution "Delete the alternate folder or writable mirror '\${repo_root}' and continue only from '\${canonical_repo_abs}'."
  fi

  teach_add_context "repo: \${repo_root}"
  teach_add_context "git_dir: \${git_dir}"
  teach_add_context "git_common_dir: \${common_dir}"
  teach_add_context "current_branch: \${current_branch:-detached}"

  if [[ -n "\$linked_admins_compact" ]]; then
    teach_add_context "linked_worktree_admins: \${linked_admins_compact}"
    teach_add_context "note: Git exposes no pre-worktree-add hook; writable operations are blocked until the linked-worktree artifact is removed."
  fi

  teach_emit_blocked >&2
  exit "\$exit_code"
}

guard_single_authority() {
  local operation="\$1"
  local exit_code="\$2"
  local repo_root=""
  local git_dir=""
  local common_dir=""
  local linked_admins=""

  repo_root="\$(resolve_repo_root)"
  git_dir="\$(resolve_git_dir)"
  common_dir="\$(resolve_git_common_dir)"
  linked_admins="\$(list_linked_worktree_admins "\$common_dir")"

  if [[ "\$repo_root" != "\$canonical_repo_abs" || "\$git_dir" == *"/worktrees/"* || -n "\$linked_admins" ]]; then
    emit_parallel_authority_teach "\$operation" "\$exit_code"
  fi
}

guard_canonical_branch() {
  local operation="\$1"
  local exit_code="\$2"
  local current_branch=""

  current_branch="\$(git symbolic-ref --quiet --short HEAD || true)"
  if [[ "\$current_branch" != "\$canonical_branch" ]]; then
    emit_current_branch_teach "\$operation" "\$current_branch" "\$exit_code"
  fi
}
EOF

cat >"$reference_hook" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

state="${1:-}"
[[ "$state" == "prepared" ]] || exit 0

zero_oid="0000000000000000000000000000000000000000"

guard_single_authority "ref update" 43

while read -r _old_oid new_oid ref_name; do
  case "$ref_name" in
    "refs/heads/${canonical_branch}")
      if [[ "$new_oid" == "$zero_oid" ]]; then
        emit_branch_ref_teach "$ref_name" 40
      fi
      ;;
    refs/heads/*)
      emit_branch_ref_teach "$ref_name" 40
      ;;
  esac
done
EOF

cat >"$post_checkout_hook" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

checkout_flag="${3:-0}"
[[ "$checkout_flag" == "1" ]] || exit 0

if [[ "${DELPHI_FOUNDATION_MAIN_ONLY_INTERNAL_BYPASS:-0}" == "1" ]]; then
  exit 0
fi

guard_single_authority "checkout" 95

current_branch="$(git symbolic-ref --quiet --short HEAD || true)"
if [[ "$current_branch" == "$canonical_branch" ]]; then
  exit 0
fi

if ! DELPHI_FOUNDATION_MAIN_ONLY_INTERNAL_BYPASS=1 git checkout -q "$canonical_branch" >/dev/null 2>&1; then
  emit_current_branch_teach "checkout" "$current_branch" 97
fi

emit_current_branch_teach "checkout" "$current_branch" 96
EOF

cat >"$pre_commit_hook" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

guard_single_authority "commit" 94
guard_canonical_branch "commit" 92
EOF

cat >"$pre_push_hook" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/lib.sh"

guard_single_authority "push" 93
guard_canonical_branch "push" 91
EOF

guard_id="foundation-main-only"
guard_dir="$DELPHI_HOOK_STACK_MANAGED_DIR/$guard_id"
mkdir -p "$guard_dir"
cp "$guard_lib" "$guard_dir/lib.sh"
chmod +x "$guard_dir/lib.sh"

delphi_hook_stack_install_managed_hook "$guard_id" "reference-transaction" "$reference_hook"
delphi_hook_stack_install_managed_hook "$guard_id" "post-checkout" "$post_checkout_hook"
delphi_hook_stack_install_managed_hook "$guard_id" "pre-commit" "$pre_commit_hook"
delphi_hook_stack_install_managed_hook "$guard_id" "pre-push" "$pre_push_hook"
delphi_hook_stack_activate "$repo_abs"

printf 'Installed Delphi foundation main-only guard in %s\n' "$repo_abs"
printf 'Git hooks path: %s\n' "$DELPHI_HOOK_STACK_BIN_DIR"
printf 'Approved branch: %s\n' "$canonical_branch"
