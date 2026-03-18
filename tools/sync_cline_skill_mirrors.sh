#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CANONICAL_ROOT="$REPO_ROOT/skills"
CLINE_ROOT="$REPO_ROOT/.cline/skills"

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
  if [ -d "$CLINE_ROOT" ]; then
    while IFS= read -r -d '' skill_dir; do
      add_skill_name "$(basename "$skill_dir")"
    done < <(find "$CLINE_ROOT" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
  fi
fi

mkdir -p "$CLINE_ROOT"

if [ "${#skill_names[@]}" -eq 0 ]; then
  printf 'No Cline skill mirrors selected; nothing to sync.\n'
  exit 0
fi

synced=0
for skill in "${skill_names[@]}"; do
  canonical_skill="$CANONICAL_ROOT/$skill/SKILL.md"
  cline_dir="$CLINE_ROOT/$skill"
  cline_skill="$cline_dir/SKILL.md"

  if [ ! -f "$canonical_skill" ]; then
    missing+=("$skill")
    continue
  fi

  mkdir -p "$cline_dir"
  find "$cline_dir" -mindepth 1 -maxdepth 1 ! -name 'SKILL.md' -exec rm -rf {} +

  if [ ! -f "$cline_skill" ] || ! cmp -s "$canonical_skill" "$cline_skill"; then
    cp "$canonical_skill" "$cline_skill"
  fi

  synced=$((synced + 1))
done

if [ "${#missing[@]}" -gt 0 ]; then
  printf 'Missing canonical skills for Cline mirror sync: %s\n' "${missing[*]}" >&2
  exit 1
fi

printf 'Synchronized %d curated Cline skill mirror(s).\n' "$synced"
