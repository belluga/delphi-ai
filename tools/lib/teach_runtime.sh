#!/usr/bin/env bash

# Shared TEACH runtime envelope helpers for deterministic guard tools.

teach_runtime_reset() {
  TEACH_RULE_ID=""
  TEACH_ENFORCEMENT=""
  TEACH_STATUS="blocked"
  TEACH_OVERALL_OUTCOME="no-go"
  TEACH_CONTEXT_NONE_LABEL="none: n/a"
  declare -ga TEACH_VIOLATIONS=()
  declare -ga TEACH_RESOLUTION_PROMPTS=()
  declare -ga TEACH_CONTEXT_LINES=()
}

teach_runtime_begin() {
  local rule_id="$1"
  local enforcement="$2"
  local status="${3:-blocked}"
  local overall_outcome="${4:-no-go}"

  teach_runtime_reset
  TEACH_RULE_ID="$rule_id"
  TEACH_ENFORCEMENT="$enforcement"
  TEACH_STATUS="$status"
  TEACH_OVERALL_OUTCOME="$overall_outcome"
}

teach_add_violation() {
  TEACH_VIOLATIONS+=("$1")
}

teach_add_resolution() {
  TEACH_RESOLUTION_PROMPTS+=("$1")
}

teach_add_context() {
  TEACH_CONTEXT_LINES+=("$1")
}

teach_set_context_none_label() {
  TEACH_CONTEXT_NONE_LABEL="$1"
}

teach_print_bullet_list() {
  local indent="$1"
  shift
  local items=("$@")

  if [ "${#items[@]}" -eq 0 ]; then
    printf '%s- none\n' "$indent"
    return
  fi

  local item
  for item in "${items[@]}"; do
    printf '%s- %s\n' "$indent" "$item"
  done
}

teach_print_context_lines() {
  if [ "${#TEACH_CONTEXT_LINES[@]}" -eq 0 ]; then
    printf '  %s\n' "$TEACH_CONTEXT_NONE_LABEL"
    return
  fi

  local line
  for line in "${TEACH_CONTEXT_LINES[@]}"; do
    printf '  %s\n' "$line"
  done
}

teach_emit() {
  printf 'TEACH runtime response\n'
  printf 'status: %s\n' "$TEACH_STATUS"
  printf 'enforcement: %s\n' "$TEACH_ENFORCEMENT"
  printf 'rule_id: %s\n' "$TEACH_RULE_ID"
  printf 'violation:\n'
  teach_print_bullet_list '  ' "${TEACH_VIOLATIONS[@]}"
  printf 'resolution_prompt:\n'
  teach_print_bullet_list '  ' "${TEACH_RESOLUTION_PROMPTS[@]}"
  printf 'context:\n'
  teach_print_context_lines
  printf '\nOverall outcome: %s\n' "$TEACH_OVERALL_OUTCOME"
}

teach_emit_ready() {
  TEACH_STATUS="ready"
  TEACH_OVERALL_OUTCOME="go"
  teach_emit
}

teach_emit_blocked() {
  TEACH_STATUS="blocked"
  TEACH_OVERALL_OUTCOME="no-go"
  teach_emit
}
