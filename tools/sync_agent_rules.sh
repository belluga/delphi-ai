#!/bin/bash
set -euo pipefail

find_environment_root() {
    local current
    current="$(pwd)"
    for _ in 1 2 3 4 5; do
        if [ -d "$current/delphi-ai" ] && [ -d "$current/flutter-app" ] && [ -d "$current/laravel-app" ]; then
            echo "$current"
            return 0
        fi
        current="$(cd "$current/.." && pwd 2>/dev/null || echo "")"
        [ -z "$current" ] && break
    done
    return 1
}

ENV_ROOT="$(find_environment_root || true)"
if [ -z "$ENV_ROOT" ]; then
    echo "Error: Could not find environment root. Please run from within the project."
    exit 1
fi

SYNC_LOCK_FILE="$ENV_ROOT/.agents/.sync_agent_links.lock"
declare -a sync_errors=()
declare -a sync_warnings=()

record_error() {
    sync_errors+=("$1")
}

record_warning() {
    sync_warnings+=("$1")
}

cleanup() {
    if command -v flock >/dev/null 2>&1; then
        flock -u 9 2>/dev/null || true
    fi
    exec 9>&- || true
}

mkdir -p "$ENV_ROOT/.agents"
exec 9>"$SYNC_LOCK_FILE"
if command -v flock >/dev/null 2>&1; then
    flock 9
fi
trap cleanup EXIT

ensure_link() {
    local link_path="$1"
    local target="$2"
    local label="$3"

    mkdir -p "$(dirname "$link_path")"

    if [ -L "$link_path" ]; then
        local actual
        actual="$(readlink "$link_path")"
        if [ "$actual" = "$target" ]; then
            return 0
        fi

        if rm -f "$link_path" 2>/dev/null && ln -s "$target" "$link_path" 2>/dev/null; then
            record_warning "$label target updated from $actual to $target"
            return 0
        fi

        record_error "$label could not update symlink target at $link_path"
        return 1
    fi

    if [ -e "$link_path" ]; then
        record_error "$label exists as non-symlink at $link_path"
        return 1
    fi

    if ! ln -s "$target" "$link_path" 2>/dev/null; then
        record_error "$label could not create symlink at $link_path"
        return 1
    fi

    return 0
}

ensure_link "$ENV_ROOT/.agents/skills" "../delphi-ai/skills" "root .agents/skills" || true
ensure_link "$ENV_ROOT/.agents/rules" "../delphi-ai/rules/docker" "root .agents/rules" || true
ensure_link "$ENV_ROOT/.agents/workflows" "../delphi-ai/workflows/docker" "root .agents/workflows" || true

ensure_link "$ENV_ROOT/flutter-app/.agents/skills" "../delphi-ai/skills" "flutter-app .agents/skills" || true
ensure_link "$ENV_ROOT/flutter-app/.agents/rules" "../delphi-ai/rules/flutter" "flutter-app .agents/rules" || true
ensure_link "$ENV_ROOT/flutter-app/.agents/workflows" "../delphi-ai/workflows/flutter" "flutter-app .agents/workflows" || true

ensure_link "$ENV_ROOT/laravel-app/.agents/skills" "../delphi-ai/skills" "laravel-app .agents/skills" || true
ensure_link "$ENV_ROOT/laravel-app/.agents/rules" "../delphi-ai/rules/laravel" "laravel-app .agents/rules" || true
ensure_link "$ENV_ROOT/laravel-app/.agents/workflows" "../delphi-ai/workflows/laravel" "laravel-app .agents/workflows" || true

# Claude Code artifacts (root + submodules)
if [ -d "$ENV_ROOT/delphi-ai/.claude" ]; then
  mkdir -p "$ENV_ROOT/.claude"
  ensure_link "$ENV_ROOT/.claude/rules" "../delphi-ai/.claude/rules" "root .claude/rules" || true
  ensure_link "$ENV_ROOT/.claude/skills" "../delphi-ai/.claude/skills" "root .claude/skills" || true
  ensure_link "$ENV_ROOT/.claude/settings.json" "../delphi-ai/.claude/settings.json" "root .claude/settings.json" || true
  ensure_link "$ENV_ROOT/CLAUDE.md" "delphi-ai/CLAUDE.md" "root CLAUDE.md" || true

  if [ -d "$ENV_ROOT/flutter-app" ]; then
    mkdir -p "$ENV_ROOT/flutter-app/.claude"
    ensure_link "$ENV_ROOT/flutter-app/.claude/rules" "../delphi-ai/.claude/rules" "flutter-app .claude/rules" || true
    ensure_link "$ENV_ROOT/flutter-app/.claude/skills" "../delphi-ai/.claude/skills" "flutter-app .claude/skills" || true
    ensure_link "$ENV_ROOT/flutter-app/.claude/settings.json" "../delphi-ai/.claude/settings.json" "flutter-app .claude/settings.json" || true
    ensure_link "$ENV_ROOT/flutter-app/CLAUDE.md" "../delphi-ai/CLAUDE.md" "flutter-app CLAUDE.md" || true
  fi

  if [ -d "$ENV_ROOT/laravel-app" ]; then
    mkdir -p "$ENV_ROOT/laravel-app/.claude"
    ensure_link "$ENV_ROOT/laravel-app/.claude/rules" "../delphi-ai/.claude/rules" "laravel-app .claude/rules" || true
    ensure_link "$ENV_ROOT/laravel-app/.claude/skills" "../delphi-ai/.claude/skills" "laravel-app .claude/skills" || true
    ensure_link "$ENV_ROOT/laravel-app/.claude/settings.json" "../delphi-ai/.claude/settings.json" "laravel-app .claude/settings.json" || true
    ensure_link "$ENV_ROOT/laravel-app/CLAUDE.md" "../delphi-ai/CLAUDE.md" "laravel-app CLAUDE.md" || true
  fi
fi

if [ ${#sync_warnings[@]} -gt 0 ]; then
    echo "Link sync warnings:"
    for warn in "${sync_warnings[@]}"; do
        echo " - $warn"
    done
fi

if [ ${#sync_errors[@]} -gt 0 ]; then
    echo "Link sync completed with errors:"
    for err in "${sync_errors[@]}"; do
        echo " - $err"
    done
    echo "Remediation: fix path conflicts/permissions and rerun bash delphi-ai/tools/sync_agent_rules.sh"
    exit 1
fi

echo "Link sync complete! .agents/{skills,rules,workflows} and .claude/{rules,skills,settings.json} are aligned."
