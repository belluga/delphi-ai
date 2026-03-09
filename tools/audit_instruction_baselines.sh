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

if [ -d "$REPO_ROOT/delphi-ai" ]; then
  DEL_ROOT="$REPO_ROOT/delphi-ai"
elif [ -f "$REPO_ROOT/main_instructions.md" ] && [ -d "$REPO_ROOT/skills" ] && [ -d "$REPO_ROOT/rules" ] && [ -d "$REPO_ROOT/workflows" ]; then
  DEL_ROOT="$REPO_ROOT"
else
  echo "delphi-ai directory not found from $REPO_ROOT" >&2
  exit 1
fi

OUTPUT_PATH=""
if [ "${1:-}" = "--output" ]; then
  OUTPUT_PATH="${2:-}"
  if [ -z "$OUTPUT_PATH" ]; then
    echo "Missing output path for --output" >&2
    exit 1
  fi
fi

emit() {
  local line="$1"
  if [ -n "$OUTPUT_PATH" ]; then
    printf '%s\n' "$line" >>"$OUTPUT_PATH"
  else
    printf '%s\n' "$line"
  fi
}

contains() {
  local file="$1"
  local pattern="$2"
  grep -Eq "$pattern" "$file"
}

status_for_file() {
  local file="$1"
  local rel="${file#$REPO_ROOT/}"
  local type="$2"
  local status="PASS"
  local notes=()

  if [ ! -s "$file" ]; then
    status="FAIL"
    notes+=("empty file")
  fi

  if contains "$file" "asdasd|asdsad"; then
    status="FAIL"
    notes+=("placeholder token")
  fi

  if [[ "$rel" == delphi-ai/workflows/* || "$rel" == workflows/* ]]; then
    if ! contains "$file" "^description:"; then
      status="FAIL"
      notes+=("missing description frontmatter")
    fi
  fi

  if [ "$type" = "Skill" ]; then
    local word_count
    word_count="$(wc -w < "$file" | tr -d '[:space:]')"
    if [ "${word_count:-0}" -gt 5000 ]; then
      status="FAIL"
      notes+=("skill exceeds 5000 words (${word_count})")
    elif [ "${word_count:-0}" -gt 1800 ]; then
      notes+=("large skill body (${word_count} words); consider splitting details into docs/")
    fi
  fi

  if [[ "$rel" == *workflow-definition* ]]; then
    if ! contains "$file" "workflow-template\\.md"; then
      status="FAIL"
      notes+=("missing workflow-template.md reference")
    fi
    if ! contains "$file" "APROVADO"; then
      status="FAIL"
      notes+=("missing APROVADO reference")
    fi
    if ! contains "$file" "Decision Adherence"; then
      status="FAIL"
      notes+=("missing Decision Adherence reference")
    fi
  fi

  if [[ "$rel" == *todo-driven-execution* ]]; then
    if ! contains "$file" "small\\|medium\\|big"; then
      status="FAIL"
      notes+=("missing complexity policy")
    fi
    if ! contains "$file" "Plan Review Gate"; then
      status="FAIL"
      notes+=("missing Plan Review Gate")
    fi
    if ! contains "$file" "Decision Baseline"; then
      status="FAIL"
      notes+=("missing Decision Baseline")
    fi
    if ! contains "$file" "APROVADO"; then
      status="FAIL"
      notes+=("missing APROVADO")
    fi
    if ! contains "$file" "Decision Adherence"; then
      status="FAIL"
      notes+=("missing Decision Adherence")
    fi
  fi

  local note_text="ok"
  if [ ${#notes[@]} -gt 0 ]; then
    note_text="$(IFS='; '; echo "${notes[*]}")"
  fi

  emit "| $type | $rel | $status | $note_text |"
  if [ "$status" = "FAIL" ]; then
    return 1
  fi
  return 0
}

if [ -n "$OUTPUT_PATH" ]; then
  : >"$OUTPUT_PATH"
fi

emit "# Delphi Baseline Audit"
emit ""
emit "## Individual Checks"
emit ""
emit "| Type | File | Status | Notes |"
emit "| --- | --- | --- | --- |"

total=0
failed=0

while IFS= read -r file; do
  total=$((total + 1))
  if ! status_for_file "$file" "Skill"; then
    failed=$((failed + 1))
  fi
done < <(find "$DEL_ROOT/skills" -type f -name 'SKILL.md' | sort)

while IFS= read -r file; do
  total=$((total + 1))
  if ! status_for_file "$file" "Rule"; then
    failed=$((failed + 1))
  fi
done < <(find "$DEL_ROOT/rules" -type f -name '*.md' | sort)

while IFS= read -r file; do
  total=$((total + 1))
  if ! status_for_file "$file" "Workflow"; then
    failed=$((failed + 1))
  fi
done < <(find "$DEL_ROOT/workflows" -type f -name '*.md' | sort)

emit ""
emit "## Coherence Checks"
emit ""
emit "| Check | Status | Notes |"
emit "| --- | --- | --- |"

coherence_failed=0

check_workflow_counterparts() {
  local status="PASS"
  local notes=()
  local skill_dir

  while IFS= read -r skill_dir; do
    local skill_name
    local slug
    local expected

    skill_name="$(basename "$skill_dir")"
    slug="${skill_name#wf-}"

    case "$slug" in
      docker-*) expected="$DEL_ROOT/workflows/docker/${slug#docker-}.md" ;;
      flutter-*) expected="$DEL_ROOT/workflows/flutter/${slug#flutter-}.md" ;;
      laravel-*) expected="$DEL_ROOT/workflows/laravel/${slug#laravel-}.md" ;;
      *) expected="$DEL_ROOT/workflows/${slug}.md" ;;
    esac

    if [ ! -f "$expected" ]; then
      status="FAIL"
      notes+=("${skill_name} -> missing ${expected#$REPO_ROOT/}")
    fi
  done < <(find "$DEL_ROOT/skills" -mindepth 1 -maxdepth 1 -type d -name 'wf-*' | sort)

  local note_text="all canonical wf-skill counterparts exist"
  if [ ${#notes[@]} -gt 0 ]; then
    note_text="$(IFS='; '; echo "${notes[*]}")"
  fi
  emit "| Canonical wf-skill counterparts | $status | $note_text |"
  [ "$status" = "PASS" ]
}

check_cline_counterparts() {
  local status="PASS"
  local notes=()
  local skill_dir

  while IFS= read -r skill_dir; do
    local skill_name
    local slug
    local expected

    skill_name="$(basename "$skill_dir")"
    slug="${skill_name#wf-}"

    case "$slug" in
      docker-*) expected="$DEL_ROOT/.clinerules/workflows/docker-${slug#docker-}.md" ;;
      flutter-*) expected="$DEL_ROOT/.clinerules/workflows/${slug#flutter-}.md" ;;
      laravel-*) expected="$DEL_ROOT/.clinerules/workflows/laravel-${slug#laravel-}.md" ;;
      *) expected="$DEL_ROOT/.clinerules/workflows/${slug}.md" ;;
    esac

    if [ ! -f "$expected" ]; then
      status="FAIL"
      notes+=("${skill_name} -> missing ${expected#$REPO_ROOT/}")
    fi
  done < <(find "$DEL_ROOT/.cline/skills" -mindepth 1 -maxdepth 1 -type d -name 'wf-*' | sort)

  local note_text="all Cline wf-skill counterparts exist"
  if [ ${#notes[@]} -gt 0 ]; then
    note_text="$(IFS='; '; echo "${notes[*]}")"
  fi
  emit "| Cline wf-skill counterparts | $status | $note_text |"
  [ "$status" = "PASS" ]
}

check_skill_mirrors() {
  local status="PASS"
  local notes=()
  local skill_dir

  while IFS= read -r skill_dir; do
    local skill_name
    local canonical
    local cline

    skill_name="$(basename "$skill_dir")"
    canonical="$DEL_ROOT/skills/$skill_name/SKILL.md"
    cline="$skill_dir/SKILL.md"

    if [ ! -f "$canonical" ]; then
      status="FAIL"
      notes+=("${skill_name} missing canonical skill")
      continue
    fi
    if ! cmp -s "$canonical" "$cline"; then
      status="FAIL"
      notes+=("${skill_name} differs from canonical")
    fi
  done < <(find "$DEL_ROOT/.cline/skills" -mindepth 1 -maxdepth 1 -type d | sort)

  local note_text="all .cline skills mirror canonical"
  if [ ${#notes[@]} -gt 0 ]; then
    note_text="$(IFS='; '; echo "${notes[*]}")"
  fi
  emit "| Canonical vs .cline skill mirror | $status | $note_text |"
  [ "$status" = "PASS" ]
}

check_public_mirrors() {
  local status="PASS"
  local notes=()
  local public_root="$HOME/.codex/skills/public"
  local mirrored=(
    "test-quality-audit"
    "test-creation-standard"
    "test-orchestration-suite"
  )

  if [ ! -d "$public_root" ]; then
    emit "| Canonical vs public Codex mirrors | SKIP | \$HOME/.codex/skills/public not present |"
    return 0
  fi

  local skill
  for skill in "${mirrored[@]}"; do
    local canonical="$DEL_ROOT/skills/$skill/SKILL.md"
    local public="$public_root/$skill/SKILL.md"

    if [ ! -f "$canonical" ] || [ ! -f "$public" ]; then
      status="FAIL"
      notes+=("${skill} missing canonical/public file")
      continue
    fi
    if ! cmp -s "$canonical" "$public"; then
      status="FAIL"
      notes+=("${skill} public copy differs from canonical")
    fi
  done

  local note_text="all tracked public mirrors match canonical"
  if [ ${#notes[@]} -gt 0 ]; then
    note_text="$(IFS='; '; echo "${notes[*]}")"
  fi
  emit "| Canonical vs public Codex mirrors | $status | $note_text |"
  [ "$status" = "PASS" ]
}

check_workflow_counterparts || coherence_failed=$((coherence_failed + 1))
check_cline_counterparts || coherence_failed=$((coherence_failed + 1))
check_skill_mirrors || coherence_failed=$((coherence_failed + 1))
check_public_mirrors || coherence_failed=$((coherence_failed + 1))

emit ""
emit "## Summary"
emit ""
emit "- Individual files checked: $total"
emit "- Individual failures: $failed"
emit "- Coherence failures: $coherence_failed"

if [ "$failed" -gt 0 ] || [ "$coherence_failed" -gt 0 ]; then
  exit 1
fi
