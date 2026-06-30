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
delphi_hook_stack_prepare "$repo_abs"

reference_hook="$(mktemp)"
post_checkout_hook="$(mktemp)"
trap 'rm -f "$reference_hook" "$post_checkout_hook"' EXIT

cat >"$reference_hook" <<EOF
#!/usr/bin/env bash
set -euo pipefail

state="\${1:-}"
[[ "\$state" == "prepared" ]] || exit 0

zero_oid="0000000000000000000000000000000000000000"

emit_guard_message() {
  cat >&2 <<'MSG'
PACED Foundation Documentation Main-Only Guard

Problem:
This foundation_documentation repository is a canonical authority surface. Side branches
and off-main writes create split authority and documentation drift.

Authority:
Canonical foundation_documentation repositories in Delphi are single-branch authorities.
The only approved local branch is '${canonical_branch}'.

Constraint:
Git operations that create, rename, delete, update, or move work onto any branch other
than '${canonical_branch}' are rejected in this clone.

Expected Behavior:
Stay on '${canonical_branch}'.
If needed, run:
  git checkout ${canonical_branch}
  git pull --ff-only origin ${canonical_branch}
Then make the documentation change directly on '${canonical_branch}' and push
'${canonical_branch}'.

Decision:
This operation was blocked because it attempted to leave the canonical
'${canonical_branch}' branch model.
MSG
}

while read -r old_oid new_oid ref_name; do
  case "\$ref_name" in
    refs/heads/${canonical_branch})
      if [[ "\$new_oid" == "\$zero_oid" ]]; then
        emit_guard_message
        exit 41
      fi
      ;;
    refs/heads/*)
      emit_guard_message
      exit 40
      ;;
  esac
done
EOF

cat >"$post_checkout_hook" <<EOF
#!/usr/bin/env bash
set -euo pipefail

checkout_flag="\${3:-0}"
[[ "\$checkout_flag" == "1" ]] || exit 0

if [[ "\${DELPHI_FOUNDATION_MAIN_ONLY_INTERNAL_BYPASS:-0}" == "1" ]]; then
  exit 0
fi

emit_guard_message() {
  cat >&2 <<'MSG'
PACED Foundation Documentation Main-Only Guard

Problem:
This foundation_documentation repository is a canonical authority surface. Side branches
and off-main worktrees create split authority and documentation drift.

Authority:
Canonical foundation_documentation repositories in Delphi are single-branch authorities.
The only approved local branch is '${canonical_branch}'.

Constraint:
Leaving '${canonical_branch}' in this clone is prohibited, including checkout/switch to
another branch or detached HEAD.

Expected Behavior:
Stay on '${canonical_branch}'.
If needed, run:
  git checkout ${canonical_branch}
  git pull --ff-only origin ${canonical_branch}
Then make the documentation change directly on '${canonical_branch}' and push
'${canonical_branch}'.

Decision:
This checkout was rejected because it attempted to leave the canonical
'${canonical_branch}' branch model. The repository will be restored to '${canonical_branch}'.
MSG
}

current_branch="\$(git symbolic-ref --quiet --short HEAD || true)"
if [[ "\$current_branch" == "${canonical_branch}" ]]; then
  exit 0
fi

emit_guard_message

if ! DELPHI_FOUNDATION_MAIN_ONLY_INTERNAL_BYPASS=1 git checkout -q "${canonical_branch}" >/dev/null 2>&1; then
  echo "Secondary failure: automatic recovery to '${canonical_branch}' failed. Restore it manually." >&2
  exit 97
fi

exit 96
EOF

delphi_hook_stack_install_managed_hook "foundation-main-only" "reference-transaction" "$reference_hook"
delphi_hook_stack_install_managed_hook "foundation-main-only" "post-checkout" "$post_checkout_hook"
delphi_hook_stack_activate "$repo_abs"

printf 'Installed Delphi foundation main-only guard in %s\n' "$repo_abs"
printf 'Git hooks path: %s\n' "$DELPHI_HOOK_STACK_BIN_DIR"
printf 'Approved branch: %s\n' "$canonical_branch"
