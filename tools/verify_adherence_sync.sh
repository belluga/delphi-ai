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

wait_for_sync_agent_rules() {
  local lock_file="$REPO_ROOT/.agent/.sync_agent_rules.lock"

  if [ ! -f "$lock_file" ]; then
    return 0
  fi

  if ! command -v flock >/dev/null 2>&1; then
    return 0
  fi

  # Wait until any in-flight sync completes. If no sync is running,
  # shared lock acquisition/release is effectively immediate.
  exec 8>"$lock_file"
  if ! flock -s -w 5 8; then
    echo "Warning: timed out waiting for $lock_file; continuing with current .agent state." >&2
    exec 8>&-
    return 0
  fi
  flock -u 8
  exec 8>&-
}

wait_for_sync_agent_rules

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

map_workflow_skill_to_canonical_workflow() {
  local skill_name="$1"
  local slug="${skill_name#wf-}"

  case "$slug" in
    docker-*) echo "$REPO_ROOT/delphi-ai/workflows/docker/${slug#docker-}.md" ;;
    flutter-*) echo "$REPO_ROOT/delphi-ai/workflows/flutter/${slug#flutter-}.md" ;;
    laravel-*) echo "$REPO_ROOT/delphi-ai/workflows/laravel/${slug#laravel-}.md" ;;
    *) echo "$REPO_ROOT/delphi-ai/workflows/${slug}.md" ;;
  esac
}

map_workflow_skill_to_cline_workflow() {
  local skill_name="$1"
  local slug="${skill_name#wf-}"

  case "$slug" in
    docker-*) echo "$REPO_ROOT/delphi-ai/.clinerules/workflows/docker-${slug#docker-}.md" ;;
    flutter-*) echo "$REPO_ROOT/delphi-ai/.clinerules/workflows/${slug#flutter-}.md" ;;
    laravel-*) echo "$REPO_ROOT/delphi-ai/.clinerules/workflows/laravel-${slug#laravel-}.md" ;;
    *) echo "$REPO_ROOT/delphi-ai/.clinerules/workflows/${slug}.md" ;;
  esac
}

verify_workflow_skill_counterparts() {
  local canonical_root="$REPO_ROOT/delphi-ai/skills"
  local cline_root="$REPO_ROOT/delphi-ai/.cline/skills"

  while IFS= read -r -d '' skill_dir; do
    local skill_name
    skill_name="$(basename "$skill_dir")"
    local skill_file="$skill_dir/SKILL.md"
    local workflow_file
    workflow_file="$(map_workflow_skill_to_canonical_workflow "$skill_name")"

    if [ -f "$skill_file" ] && [ ! -f "$workflow_file" ]; then
      errors+=("Missing canonical workflow counterpart for $skill_name: $workflow_file")
    fi
  done < <(find "$canonical_root" -mindepth 1 -maxdepth 1 -type d -name 'wf-*' -print0 | sort -z)

  if [ -d "$cline_root" ]; then
    while IFS= read -r -d '' skill_dir; do
      local skill_name
      skill_name="$(basename "$skill_dir")"
      local skill_file="$skill_dir/SKILL.md"
      local workflow_file
      workflow_file="$(map_workflow_skill_to_cline_workflow "$skill_name")"

      if [ -f "$skill_file" ] && [ ! -f "$workflow_file" ]; then
        errors+=("Missing Cline workflow counterpart for $skill_name: $workflow_file")
      fi
    done < <(find "$cline_root" -mindepth 1 -maxdepth 1 -type d -name 'wf-*' -print0 | sort -z)
  fi
}

verify_public_skill_mirrors() {
  local public_root="$HOME/.codex/skills/public"
  local canonical_root="$REPO_ROOT/delphi-ai/skills"
  local mirrored_skills=(
    "test-quality-audit"
    "test-creation-standard"
    "test-orchestration-suite"
  )

  if [ ! -d "$public_root" ]; then
    return
  fi

  local skill
  for skill in "${mirrored_skills[@]}"; do
    local canonical_skill="$canonical_root/$skill/SKILL.md"
    local public_skill="$public_root/$skill/SKILL.md"

    if require_file "$canonical_skill" && require_file "$public_skill"; then
      compare_exact "$canonical_skill" "$public_skill" "Public Codex skill mirror $skill"
    fi
  done
}

verify_no_placeholder_artifacts() {
  local blocked_paths=(
    "$REPO_ROOT/delphi-ai/skills/wf-docker-asdsadasdas"
    "$REPO_ROOT/delphi-ai/workflows/docker/asdsadasdas.md"
  )

  local p
  for p in "${blocked_paths[@]}"; do
    if [ -e "$p" ]; then
      errors+=("Obsolete placeholder artifact must not exist: $p")
    fi
  done

  local hits
  hits="$(grep -RInE 'asdasd|asdsad' \
    "$REPO_ROOT/delphi-ai/skills" \
    "$REPO_ROOT/delphi-ai/rules" \
    "$REPO_ROOT/delphi-ai/workflows" \
    "$REPO_ROOT/delphi-ai/.clinerules" \
    "$REPO_ROOT/delphi-ai/.cline/skills" 2>/dev/null || true)"

  if [ -n "$hits" ]; then
    errors+=("Placeholder tokens detected in governance surfaces. Remove them before completion.")
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
  local shared_source_dir="$REPO_ROOT/delphi-ai/rules/docker/shared"

  if [ -d "$source_dir/shared" ]; then
    shared_source_dir="$source_dir/shared"
  fi

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
      src="$shared_source_dir/${rel#shared/}"
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
    done < <(find "$shared_source_dir" -maxdepth 1 -type f -name '*.md' -print0 | sort -z)
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
    "$root/workflows/docker-update-skill-method.md"
    "$root/workflows/laravel-create-package-method.md"
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

  if [ -f "$manifest" ]; then
    require_contains "$manifest" "docker-update-skill-method\\.md" "Cline manifest"
    require_contains "$manifest" "laravel-create-package-method\\.md" "Cline manifest"
    require_contains "$manifest" "test-quality-audit/SKILL\\.md" "Cline manifest"
    require_contains "$manifest" "test-creation-standard/SKILL\\.md" "Cline manifest"
    require_contains "$manifest" "test-orchestration-suite/SKILL\\.md" "Cline manifest"
  fi
}

verify_workflow_definition_controls() {
  local docker_rule="$REPO_ROOT/delphi-ai/rules/docker/shared/workflow-definition-model-decision.md"
  local laravel_rule="$REPO_ROOT/delphi-ai/rules/laravel/shared/workflow-definition-model-decision.md"
  local cline_rule="$REPO_ROOT/delphi-ai/.clinerules/model-decision/shared-workflow-definition.md"
  local docker_skill="$REPO_ROOT/delphi-ai/skills/rule-docker-shared-workflow-definition-model-decision/SKILL.md"
  local laravel_skill="$REPO_ROOT/delphi-ai/skills/rule-laravel-shared-workflow-definition-model-decision/SKILL.md"

  require_file "$docker_rule"
  require_file "$laravel_rule"
  require_file "$cline_rule"
  require_file "$docker_skill"
  require_file "$laravel_skill"

  if [ -f "$docker_rule" ]; then
    require_contains "$docker_rule" "workflow-template\\.md" "Docker workflow-definition rule"
    require_contains "$docker_rule" "APROVADO" "Docker workflow-definition rule"
    require_contains "$docker_rule" "Decision Adherence" "Docker workflow-definition rule"
  fi
  if [ -f "$laravel_rule" ]; then
    require_contains "$laravel_rule" "workflow-template\\.md" "Laravel workflow-definition rule"
    require_contains "$laravel_rule" "APROVADO" "Laravel workflow-definition rule"
    require_contains "$laravel_rule" "Decision Adherence" "Laravel workflow-definition rule"
  fi
  if [ -f "$cline_rule" ]; then
    require_contains "$cline_rule" "workflow-template\\.md" "Cline workflow-definition rule"
    require_contains "$cline_rule" "APROVADO" "Cline workflow-definition rule"
    require_contains "$cline_rule" "Decision Adherence" "Cline workflow-definition rule"
  fi
  if [ -f "$docker_skill" ]; then
    require_contains "$docker_skill" "workflow-template\\.md" "Docker workflow-definition skill"
  fi
  if [ -f "$laravel_skill" ]; then
    require_contains "$laravel_skill" "workflow-template\\.md" "Laravel workflow-definition skill"
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
  "$REPO_ROOT/laravel-app/.agent/rules" \
  "$REPO_ROOT/delphi-ai/rules/laravel" \
  "laravel-app" \
  "true"

compare_agent_workflowset \
  "$REPO_ROOT/laravel-app/.agent/workflows" \
  "$REPO_ROOT/delphi-ai/workflows/laravel" \
  "laravel-app"

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
verify_workflow_skill_counterparts
verify_workflow_definition_controls
verify_no_placeholder_artifacts
verify_public_skill_mirrors

if [ ${#errors[@]} -gt 0 ] && [ "${VERIFY_ADHERENCE_RETRY_ON_SYNC_RACE:-0}" = "0" ]; then
  if printf '%s\n' "${errors[@]}" | grep -qE 'Missing file: .*/\.agent/(rules|workflows)/'; then
    sleep 1
    exec env VERIFY_ADHERENCE_RETRY_ON_SYNC_RACE=1 bash "$0" "$@"
  fi
fi

if [ ${#errors[@]} -gt 0 ]; then
  printf 'Adherence sync verification FAILED:\n'
  for err in "${errors[@]}"; do
    printf ' - %s\n' "$err"
  done
  exit 1
fi

echo "Adherence sync verification passed."
