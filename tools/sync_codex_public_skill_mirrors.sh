#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CANONICAL_ROOT="$REPO_ROOT/skills"
PUBLIC_ROOT="$HOME/.codex/skills/public"
LIST_TOOL="$SCRIPT_DIR/list_public_codex_skill_mirrors.sh"

declare -a skill_names=()
declare -a missing=()

is_valid_skill_name() {
  [[ "$1" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]]
}

add_skill_name() {
  local candidate="$1"
  local existing
  for existing in "${skill_names[@]}"; do
    if [ "$existing" = "$candidate" ]; then
      return
    fi
  done
  skill_names+=("$candidate")
}

if [ "$#" -gt 0 ]; then
  for skill in "$@"; do
    if ! is_valid_skill_name "$skill"; then
      printf 'Invalid skill name: %s\n' "$skill" >&2
      exit 1
    fi
    add_skill_name "$skill"
  done
else
  while IFS= read -r skill; do
    [ -n "$skill" ] || continue
    add_skill_name "$skill"
  done < <("$LIST_TOOL")
fi

if [ "${#skill_names[@]}" -eq 0 ]; then
  printf 'No public Codex skill mirrors selected; nothing to sync.\n'
  exit 0
fi

mkdir -p "$PUBLIC_ROOT"

synced=0
for skill in "${skill_names[@]}"; do
  canonical_skill="$CANONICAL_ROOT/$skill/SKILL.md"
  public_dir="$PUBLIC_ROOT/$skill"
  public_skill="$public_dir/SKILL.md"

  if [ ! -f "$canonical_skill" ]; then
    missing+=("$skill")
    continue
  fi

  mkdir -p "$public_dir"
  find "$public_dir" -mindepth 1 -maxdepth 1 ! -name 'SKILL.md' -exec rm -rf {} +

  if [ ! -f "$public_skill" ] || ! cmp -s "$canonical_skill" "$public_skill"; then
    cp "$canonical_skill" "$public_skill"
  fi

  synced=$((synced + 1))
done

if [ "${#missing[@]}" -gt 0 ]; then
  printf 'Missing canonical skills for public Codex mirror sync: %s\n' "${missing[*]}" >&2
  exit 1
fi

printf 'Synchronized %d public Codex skill mirror(s).\n' "$synced"
