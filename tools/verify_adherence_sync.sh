#!/usr/bin/env bash
set -euo pipefail

find_environment_root() {
  local start="$1"
  local current="$start"
  for _ in 1 2 3 4 5; do
    if [ -d "$current/delphi-ai" ] && [ -d "$current/flutter-app" ] && [ -d "$current/laravel-app" ]; then
      echo "$current"
      return 0
    fi
    current="$(cd "$current/.." && pwd 2>/dev/null || true)"
    [ -z "$current" ] && break
  done
  return 1
}

REPO_ROOT="$(git -C "$(pwd)" rev-parse --show-toplevel 2>/dev/null || pwd)"
if ENV_ROOT="$(find_environment_root "$REPO_ROOT" 2>/dev/null)"; then
  REPO_ROOT="$ENV_ROOT"
fi

errors=()

require_file() {
  local path="$1"
  if [ ! -f "$path" ]; then
    errors+=("Missing file: $path")
    return 1
  fi
  return 0
}

require_contains() {
  local path="$1"
  local pattern="$2"
  local label="$3"
  if ! grep -qE "$pattern" "$path"; then
    errors+=("$label missing pattern '$pattern' in $path")
  fi
}

compare_exact() {
  local left="$1"
  local right="$2"
  local label="$3"
  if ! cmp -s "$left" "$right"; then
    errors+=("$label mismatch: $left != $right")
  fi
}

extract_rule_body() {
  local path="$1"
  awk 'BEGIN{in_body=0} /^#{1,6}[[:space:]]/{in_body=1} {if (in_body) print}' "$path"
}

compare_rule_body() {
  local source="$1"
  local generated="$2"
  local label="$3"

  local src_body
  local gen_body
  src_body="$(extract_rule_body "$source")"
  gen_body="$(extract_rule_body "$generated")"

  if [ "$src_body" != "$gen_body" ]; then
    errors+=("$label body mismatch: $source != $generated")
  fi
}

compare_cline_skills() {
  local canonical_root="$REPO_ROOT/delphi-ai/skills"
  local cline_root="$REPO_ROOT/delphi-ai/.cline/skills"

  if [ ! -d "$cline_root" ]; then
    errors+=("Missing directory: $cline_root")
    return
  fi

  while IFS= read -r -d '' cline_skill_dir; do
    local name
    name="$(basename "$cline_skill_dir")"
    local canonical_skill="$canonical_root/$name/SKILL.md"
    local cline_skill="$cline_skill_dir/SKILL.md"

    if require_file "$canonical_skill" && require_file "$cline_skill"; then
      compare_exact "$canonical_skill" "$cline_skill" "Cline skill $name"
    fi
  done < <(find "$cline_root" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
}

compare_agent_ruleset() {
  local generated_dir="$1"
  local source_dir="$2"
  local label_prefix="$3"
  local include_shared="$4"

  if [ ! -d "$generated_dir" ]; then
    errors+=("Missing directory: $generated_dir")
    return
  fi

  # Generated -> Source mapping
  while IFS= read -r -d '' gen_file; do
    local rel
    rel="${gen_file#$generated_dir/}"

    local src
    if [[ "$rel" == shared/* ]]; then
      src="$REPO_ROOT/delphi-ai/rules/docker/shared/${rel#shared/}"
    else
      src="$source_dir/$rel"
    fi

    if require_file "$src" && require_file "$gen_file"; then
      compare_rule_body "$src" "$gen_file" "$label_prefix rule $rel"
    fi
  done < <(find "$generated_dir" -type f -name '*.md' -print0 | sort -z)

  # Source -> Generated coverage
  while IFS= read -r -d '' src_file; do
    local rel
    rel="$(basename "$src_file")"
    local gen="$generated_dir/$rel"
    if require_file "$src_file" && require_file "$gen"; then
      compare_rule_body "$src_file" "$gen" "$label_prefix source coverage $rel"
    fi
  done < <(find "$source_dir" -maxdepth 1 -type f -name '*.md' -print0 | sort -z)

  if [ "$include_shared" = "true" ]; then
    while IFS= read -r -d '' src_file; do
      local rel
      rel="$(basename "$src_file")"
      local gen="$generated_dir/shared/$rel"
      if require_file "$src_file" && require_file "$gen"; then
        compare_rule_body "$src_file" "$gen" "$label_prefix shared source coverage $rel"
      fi
    done < <(find "$REPO_ROOT/delphi-ai/rules/docker/shared" -maxdepth 1 -type f -name '*.md' -print0 | sort -z)
  fi
}

compare_agent_workflowset() {
  local generated_dir="$1"
  local source_dir="$2"
  local label_prefix="$3"

  if [ ! -d "$generated_dir" ]; then
    errors+=("Missing directory: $generated_dir")
    return
  fi

  # Source -> Generated coverage
  while IFS= read -r -d '' src_file; do
    local rel
    rel="$(basename "$src_file")"
    local gen="$generated_dir/$rel"
    if require_file "$src_file" && require_file "$gen"; then
      compare_exact "$src_file" "$gen" "$label_prefix workflow $rel"
    fi
  done < <(find "$source_dir" -maxdepth 1 -type f -name '*.md' -print0 | sort -z)

  # Generated -> Source mapping
  while IFS= read -r -d '' gen_file; do
    local rel
    rel="$(basename "$gen_file")"
    local src="$source_dir/$rel"
    if require_file "$src" && require_file "$gen_file"; then
      compare_exact "$src" "$gen_file" "$label_prefix generated workflow $rel"
    fi
  done < <(find "$generated_dir" -maxdepth 1 -type f -name '*.md' -print0 | sort -z)
}

verify_clinerules_controls() {
  local root="$REPO_ROOT/delphi-ai/.clinerules"
  local manifest="$REPO_ROOT/delphi-ai/.cline/MANIFEST.md"

  local required_files=(
    "$root/00-main-instructions.md"
    "$root/model-decision/shared-todo-driven-execution.md"
    "$root/workflows/docker-todo-driven-execution.md"
    "$manifest"
  )

  local f
  for f in "${required_files[@]}"; do
    require_file "$f"
  done

  if [ -f "$root/00-main-instructions.md" ]; then
    require_contains "$root/00-main-instructions.md" "APROVADO" "Cline core instructions"
    require_contains "$root/00-main-instructions.md" "Decision Adherence Gate|Decision Adherence" "Cline core instructions"
    require_contains "$root/00-main-instructions.md" "advisory" "Cline core instructions"
  fi

  if [ -f "$root/model-decision/shared-todo-driven-execution.md" ]; then
    require_contains "$root/model-decision/shared-todo-driven-execution.md" "APROVADO" "Cline TODO model-decision"
    require_contains "$root/model-decision/shared-todo-driven-execution.md" "Decision Adherence" "Cline TODO model-decision"
  fi

  if [ -f "$root/workflows/docker-todo-driven-execution.md" ]; then
    require_contains "$root/workflows/docker-todo-driven-execution.md" "Decision Adherence" "Cline TODO workflow"
    require_contains "$root/workflows/docker-todo-driven-execution.md" "APROVADO" "Cline TODO workflow"
  fi
}

compare_cline_skills

compare_agent_ruleset \
  "$REPO_ROOT/flutter-app/.agent/rules" \
  "$REPO_ROOT/delphi-ai/rules/flutter" \
  "flutter-app" \
  "true"

compare_agent_workflowset \
  "$REPO_ROOT/flutter-app/.agent/workflows" \
  "$REPO_ROOT/delphi-ai/workflows/flutter" \
  "flutter-app"

compare_agent_ruleset \
  "$REPO_ROOT/.agent/rules" \
  "$REPO_ROOT/delphi-ai/rules/docker" \
  "root" \
  "true"

compare_agent_workflowset \
  "$REPO_ROOT/.agent/workflows" \
  "$REPO_ROOT/delphi-ai/workflows/docker" \
  "root"

verify_clinerules_controls

if [ ${#errors[@]} -gt 0 ]; then
  printf 'Adherence sync verification FAILED:\n'
  for err in "${errors[@]}"; do
    printf ' - %s\n' "$err"
  done
  exit 1
fi

echo "Adherence sync verification passed."
