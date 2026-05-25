#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOL="$ROOT_DIR/tools/environment_topology_contract_scaffold.py"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

REPO="$TMP_DIR/project"
OUTPUT="$REPO/foundation_documentation/artifacts/environment-topology.md"

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

python3 "$TOOL" --repo "$REPO" --output "$OUTPUT"

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
grep -q "Activation Evidence State" "$OUTPUT"
grep -q "candidate" "$OUTPUT"
grep -q "laravel-app/artisan" "$OUTPUT"
! grep -q "tools/php-package/composer.json" "$OUTPUT"
! grep -q "node_modules/pkg/tools/flutter/run_bad.sh" "$OUTPUT"
! grep -q "vendor/pkg/scripts/delphi/run_bad.sh" "$OUTPUT"
! grep -q "build/scripts/delphi/run_bad.sh" "$OUTPUT"
grep -q "User Validation Checklist" "$OUTPUT"

printf 'environment_topology_contract_scaffold_test: OK\n'
