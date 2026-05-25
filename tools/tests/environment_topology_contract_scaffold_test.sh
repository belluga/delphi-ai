#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOL="$ROOT_DIR/tools/environment_topology_contract_scaffold.py"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

REPO="$TMP_DIR/project"
OUTPUT="$REPO/foundation_documentation/artifacts/environment-topology.md"
REGISTRY="$TMP_DIR/stack_capabilities.yaml"

mkdir -p "$REPO/flutter-app" "$REPO/laravel-app/scripts/delphi" "$REPO/foundation_documentation"
mkdir -p "$REPO/tools/php-package" "$REPO/node_modules/pkg/tools/flutter" "$REPO/vendor/pkg/scripts/delphi" "$REPO/build/scripts/delphi"

cat > "$REPO/.gitmodules" <<'EOF'
[submodule "flutter-app"]
	path = flutter-app
	url = git@github.com:example/flutter-app.git
[submodule "laravel-app"]
	path = laravel-app
	url = git@github.com:example/laravel-app.git
EOF

cat > "$REPO/docker-compose.yml" <<'EOF'
services:
  app:
    image: example/app
EOF

cat > "$REPO/Gemfile" <<'EOF'
source "https://rubygems.org"
gem "rails"
EOF

cat > "$REPO/.env.example" <<'EOF'
DOMAIN=example.test
APP_URL=https://example.test
SECRET_TOKEN=abc
JWT_KEY=super-secret
EOF

cat > "$REPO/flutter-app/pubspec.yaml" <<'EOF'
name: fixture_app
EOF

cat > "$REPO/laravel-app/composer.json" <<'EOF'
{"name":"fixture/app","require":{"laravel/framework":"^11.0"}}
EOF

touch "$REPO/laravel-app/artisan"

cat > "$REPO/tools/php-package/composer.json" <<'EOF'
{"name":"fixture/generic-php-package"}
EOF

cat > "$REPO/laravel-app/scripts/delphi/run_laravel_tests_safe.sh" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF

cat > "$REPO/node_modules/pkg/tools/flutter/run_bad.sh" <<'EOF'
#!/usr/bin/env bash
echo bad
EOF

cat > "$REPO/vendor/pkg/scripts/delphi/run_bad.sh" <<'EOF'
#!/usr/bin/env bash
echo bad
EOF

cat > "$REPO/build/scripts/delphi/run_bad.sh" <<'EOF'
#!/usr/bin/env bash
echo bad
EOF

cat > "$REGISTRY" <<'EOF'
schema_version: 1
ecosystem: belluga
activation_contract:
  authority_order:
    - foundation_documentation
capabilities:
  docker:
    lifecycle: available
    purpose: Runtime orchestration.
    activation_markers:
      - compose files
    detection_markers:
      root_files:
        - docker-compose.yml
        - Dockerfile
    execution_policy: Use project-declared topology.
  flutter:
    lifecycle: available
    purpose: Client app.
    activation_markers:
      - pubspec.yaml
    detection_markers:
      nested_files:
        - pubspec.yaml
    execution_policy: Use only when project declares Flutter active.
  laravel:
    lifecycle: available
    purpose: Backend/API.
    activation_markers:
      - composer.json
    detection_markers:
      nested_files:
        - artisan
        - composer.json
      composer_requires:
        - laravel/framework
      companion_files:
        - artisan
    execution_policy: Use project-owned safe runners.
  go:
    lifecycle: future
    purpose: Future backend/service capability.
    activation_markers:
      - go.mod
    detection_markers:
      nested_files:
        - go.mod
    execution_policy: Reserved until project declares Go active.
  ruby:
    lifecycle: experimental
    purpose: Registry-driven fixture stack.
    activation_markers:
      - Gemfile
    detection_markers:
      root_files:
        - Gemfile
    execution_policy: Fixture only.
EOF

python3 "$TOOL" --repo "$REPO" --registry "$REGISTRY" --output "$OUTPUT"

test -s "$OUTPUT"
grep -q "Draft / User Validation Required" "$OUTPUT"
grep -q "example.test" "$OUTPUT"
grep -q "SECRET_TOKEN" "$OUTPUT"
grep -q "JWT_KEY" "$OUTPUT"
grep -q "<redacted>" "$OUTPUT"
! grep -q "abc" "$OUTPUT"
! grep -q "super-secret" "$OUTPUT"
grep -q "docker" "$OUTPUT"
grep -q "flutter" "$OUTPUT"
grep -q "laravel" "$OUTPUT"
grep -q "ruby" "$OUTPUT"
grep -q "Gemfile" "$OUTPUT"
grep -q "Activation Evidence State" "$OUTPUT"
grep -q "candidate" "$OUTPUT"
grep -q "laravel-app/artisan" "$OUTPUT"
! grep -q "tools/php-package/composer.json" "$OUTPUT"
! grep -q "node_modules/pkg/tools/flutter/run_bad.sh" "$OUTPUT"
! grep -q "vendor/pkg/scripts/delphi/run_bad.sh" "$OUTPUT"
! grep -q "build/scripts/delphi/run_bad.sh" "$OUTPUT"
grep -q "User Validation Checklist" "$OUTPUT"

printf 'environment_topology_contract_scaffold_test: OK\n'
