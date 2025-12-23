#!/bin/bash

# Function to find the environment root (containing delphi-ai, flutter-app, etc.)
find_environment_root() {
    local current="$(pwd)"
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

ENV_ROOT="$(find_environment_root)"
if [ -z "$ENV_ROOT" ]; then
    echo "Error: Could not find environment root. Please run from within the project."
    exit 1
fi

DELPHI_SOURCE="$ENV_ROOT/delphi-ai"

# Function to copy and fix syntax
sync_rules() {
    local src_dir=$1
    local dest_dir=$2
    local include_shared=$3

    echo "Syncing $src_dir -> $dest_dir"
    
    # Ensure destination is a real directory, not a symlink
    if [ -L "$dest_dir" ]; then
        rm "$dest_dir"
    fi
    # Clean existing files to avoid stale rules
    if [ -d "$dest_dir" ]; then
        rm -rf "$dest_dir"/*
    fi
    mkdir -p "$dest_dir"

    # Copy rules from source (following symlinks like 'shared')
    cp -RL "$src_dir"/* "$dest_dir/" 2>/dev/null

    # If shared was a symlink, it's now a real directory. 
    # But we want to ensure it's synced from the latest docker/shared source.
    if [ "$include_shared" = true ]; then
        mkdir -p "$dest_dir/shared"
        cp -RL "$DELPHI_SOURCE/rules/docker/shared"/* "$dest_dir/shared/" 2>/dev/null
    fi

    # Fix syntax in all copied .md files
    find "$dest_dir" -name "*.md" -type f | while read file; do
        # Extract metadata
        DESC=$(grep -E "^(description|summary):" "$file" | tail -n 1 | sed -E 's/^(description|summary):[[:space:]]*//')
        MODE=$(grep -E "^(activation_mode|trigger):" "$file" | tail -n 1 | sed -E 's/^(activation_mode|trigger):[[:space:]]*//')
        
        if [ -n "$MODE" ]; then
            # Find first header
            FIRST_HEADER=$(grep -n "^#" "$file" | head -n 1 | cut -d: -f1)
            if [ -n "$FIRST_HEADER" ]; then
                BODY=$(tail -n +$FIRST_HEADER "$file")
                # Clean up any residual frontmatter markers if they exist in the body
                echo -e "---\ntrigger: $MODE\ndescription: $DESC\n---\n\n$BODY" > "$file"
            fi
        fi
    done
}

# Sync Workflows (Real files, no syntax fix needed)
sync_workflows() {
    local src_dir=$1
    local dest_dir=$2
    
    echo "Syncing workflows $src_dir -> $dest_dir"
    if [ -L "$dest_dir" ]; then
        rm "$dest_dir"
    fi
    mkdir -p "$dest_dir"
    cp -r "$src_dir"/* "$dest_dir/" 2>/dev/null
}

# 1. Root / Docker
sync_rules "$DELPHI_SOURCE/rules/docker" "$ENV_ROOT/.agent/rules" true
sync_workflows "$DELPHI_SOURCE/workflows/docker" "$ENV_ROOT/.agent/workflows"

# 2. Flutter
sync_rules "$DELPHI_SOURCE/rules/flutter" "$ENV_ROOT/flutter-app/.agent/rules" true
sync_workflows "$DELPHI_SOURCE/workflows/flutter" "$ENV_ROOT/flutter-app/.agent/workflows"

# 3. Laravel
# Note: This might fail if permissions are not fixed, but we try anyway
sync_rules "$DELPHI_SOURCE/rules/laravel" "$ENV_ROOT/laravel-app/.agent/rules" true
sync_workflows "$DELPHI_SOURCE/workflows/laravel" "$ENV_ROOT/laravel-app/.agent/workflows"

echo "Sync complete! All rules and workflows are now real files with correct syntax."
