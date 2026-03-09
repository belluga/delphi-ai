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

DELPHI_SOURCE="$ENV_ROOT/delphi-ai"
SYNC_LOCK_FILE="$ENV_ROOT/.agent/.sync_agent_rules.lock"

declare -a sync_errors=()
declare -a sync_warnings=()

record_error() {
    sync_errors+=("$1")
}

record_warning() {
    sync_warnings+=("$1")
}

mkdir -p "$ENV_ROOT/.agent"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/sync-agent-rules.XXXXXX")"

cleanup() {
    if command -v flock >/dev/null 2>&1; then
        flock -u 9 2>/dev/null || true
    fi
    exec 9>&- || true
    rm -rf "$TMP_ROOT"
}

exec 9>"$SYNC_LOCK_FILE"
if command -v flock >/dev/null 2>&1; then
    flock 9
fi
trap cleanup EXIT

can_write_destination() {
    local dest_dir="$1"
    local parent_dir
    parent_dir="$(dirname "$dest_dir")"

    if [ -e "$dest_dir" ]; then
        [ -w "$dest_dir" ]
        return
    fi

    if [ ! -d "$parent_dir" ]; then
        if ! mkdir -p "$parent_dir" 2>/dev/null; then
            return 1
        fi
    fi

    [ -w "$parent_dir" ]
}

dirs_equal() {
    local expected_dir="$1"
    local actual_dir="$2"

    if [ ! -d "$actual_dir" ]; then
        return 1
    fi

    diff -qr "$expected_dir" "$actual_dir" >/dev/null 2>&1
}

normalize_rule_files() {
    local target_dir="$1"

    while IFS= read -r file; do
        local desc mode first_header body
        desc="$(grep -E "^(description|summary):" "$file" | tail -n 1 | sed -E 's/^(description|summary):[[:space:]]*//')"
        mode="$(grep -E "^(activation_mode|trigger):" "$file" | tail -n 1 | sed -E 's/^(activation_mode|trigger):[[:space:]]*//')"

        if [ -n "$mode" ]; then
            first_header="$(grep -n "^#" "$file" | head -n 1 | cut -d: -f1)"
            if [ -n "$first_header" ]; then
                body="$(tail -n +"$first_header" "$file")"
                printf -- "---\ntrigger: %s\ndescription: %s\n---\n\n%s\n" "$mode" "$desc" "$body" > "$file"
            fi
        fi
    done < <(find "$target_dir" -name "*.md" -type f | sort)
}

build_rules_staging() {
    local src_dir="$1"
    local include_shared="$2"
    local stage_dir="$3"
    local label="$4"

    mkdir -p "$stage_dir"
    if ! cp -RL "$src_dir"/. "$stage_dir"/ 2>/dev/null; then
        record_error "$label failed to copy rule files from $src_dir"
        return 1
    fi

    if [ "$include_shared" = true ]; then
        if ! mkdir -p "$stage_dir/shared" 2>/dev/null; then
            record_error "$label failed to create staging shared rules directory"
            return 1
        fi
        while IFS= read -r shared_file; do
            local shared_name
            shared_name="$(basename "$shared_file")"
            if [ ! -e "$stage_dir/shared/$shared_name" ]; then
                if ! cp -RL "$shared_file" "$stage_dir/shared/$shared_name" 2>/dev/null; then
                    record_error "$label failed to copy shared docker rule $shared_name into staging"
                    return 1
                fi
            fi
        done < <(find "$DELPHI_SOURCE/rules/docker/shared" -maxdepth 1 -type f -name '*.md' | sort)
    fi

    normalize_rule_files "$stage_dir"
}

build_workflows_staging() {
    local src_dir="$1"
    local stage_dir="$2"
    local label="$3"

    mkdir -p "$stage_dir"
    if ! cp -RL "$src_dir"/. "$stage_dir"/ 2>/dev/null; then
        record_error "$label failed to copy workflow files from $src_dir"
        return 1
    fi
}

replace_destination_with_staging() {
    local stage_dir="$1"
    local dest_dir="$2"
    local label="$3"

    if ! can_write_destination "$dest_dir"; then
        if dirs_equal "$stage_dir" "$dest_dir"; then
            record_warning "$label destination is not writable, but existing files are already aligned"
            return 0
        fi

        if [ -e "$dest_dir" ]; then
            record_error "$label destination is not writable and differs from source: $dest_dir"
        else
            record_error "$label parent directory is not writable: $(dirname "$dest_dir")"
        fi
        return 1
    fi

    if [ -L "$dest_dir" ] || { [ -e "$dest_dir" ] && [ ! -d "$dest_dir" ]; }; then
        if ! rm -rf "$dest_dir" 2>/dev/null; then
            record_error "$label failed to remove destination path: $dest_dir"
            return 1
        fi
    fi

    if [ -d "$dest_dir" ]; then
        if ! find "$dest_dir" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null; then
            record_error "$label failed to clean destination directory: $dest_dir"
            return 1
        fi
    else
        if ! mkdir -p "$dest_dir" 2>/dev/null; then
            record_error "$label failed to create destination directory: $dest_dir"
            return 1
        fi
    fi

    if ! cp -RL "$stage_dir"/. "$dest_dir"/ 2>/dev/null; then
        record_error "$label failed to populate destination directory: $dest_dir"
        return 1
    fi

    return 0
}

sync_rules() {
    local src_dir="$1"
    local dest_dir="$2"
    local include_shared="$3"
    local label="$4"
    local stage_dir
    stage_dir="$(mktemp -d "$TMP_ROOT/rules.XXXXXX")"

    echo "Syncing $src_dir -> $dest_dir"

    if ! build_rules_staging "$src_dir" "$include_shared" "$stage_dir" "$label"; then
        return 1
    fi

    replace_destination_with_staging "$stage_dir" "$dest_dir" "$label"
}

sync_workflows() {
    local src_dir="$1"
    local dest_dir="$2"
    local label="$3"
    local stage_dir
    stage_dir="$(mktemp -d "$TMP_ROOT/workflows.XXXXXX")"

    echo "Syncing workflows $src_dir -> $dest_dir"

    if ! build_workflows_staging "$src_dir" "$stage_dir" "$label"; then
        return 1
    fi

    replace_destination_with_staging "$stage_dir" "$dest_dir" "$label"
}

sync_rules "$DELPHI_SOURCE/rules/docker" "$ENV_ROOT/.agent/rules" true "root .agent rules" || true
sync_workflows "$DELPHI_SOURCE/workflows/docker" "$ENV_ROOT/.agent/workflows" "root .agent workflows" || true

sync_rules "$DELPHI_SOURCE/rules/flutter" "$ENV_ROOT/flutter-app/.agent/rules" true "flutter-app .agent rules" || true
sync_workflows "$DELPHI_SOURCE/workflows/flutter" "$ENV_ROOT/flutter-app/.agent/workflows" "flutter-app .agent workflows" || true

sync_rules "$DELPHI_SOURCE/rules/laravel" "$ENV_ROOT/laravel-app/.agent/rules" true "laravel-app .agent rules" || true
sync_workflows "$DELPHI_SOURCE/workflows/laravel" "$ENV_ROOT/laravel-app/.agent/workflows" "laravel-app .agent workflows" || true

if [ ${#sync_warnings[@]} -gt 0 ]; then
    echo "Sync warnings:"
    for warn in "${sync_warnings[@]}"; do
        echo " - $warn"
    done
fi

if [ ${#sync_errors[@]} -gt 0 ]; then
    echo "Sync completed with errors:"
    for err in "${sync_errors[@]}"; do
        echo " - $err"
    done
    echo "Remediation: ensure your user can write to .agent directories (e.g. chown/chmod on affected paths) and rerun."
    exit 1
fi

echo "Sync complete! All rules and workflows are now real files with correct syntax."
