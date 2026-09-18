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

mkdir -p "$REPO/nest-app" "$REPO/react-app" "$REPO/vite-app" "$REPO/generic-node"
printf '%s\n' '{"dependencies":{"@nestjs/core":"^11"}}' > "$REPO/nest-app/package.json"
printf '%s\n' '{"devDependencies":{"react-dom":"^19"}}' > "$REPO/react-app/package.json"
printf '%s\n' '{"devDependencies":{"vite":"^7"}}' > "$REPO/vite-app/package.json"
printf '%s\n' '{"dependencies":{"typescript":"^5"}}' > "$REPO/generic-node/package.json"

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
  project_contract_surfaces:
    - foundation_documentation/
  non_activation_signals:
    - registry presence
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
if grep -q "abc\|super-secret" "$OUTPUT"; then exit 1; fi
grep -q "docker" "$OUTPUT"
grep -q "flutter" "$OUTPUT"
grep -q "laravel" "$OUTPUT"
grep -q "ruby" "$OUTPUT"
grep -q "Gemfile" "$OUTPUT"
grep -q "Candidate Evidence State" "$OUTPUT"
grep -q "candidate" "$OUTPUT"
grep -q "laravel-app/artisan" "$OUTPUT"
if grep -q "tools/php-package/composer.json\|node_modules/pkg/tools/flutter/run_bad.sh\|vendor/pkg/scripts/delphi/run_bad.sh\|build/scripts/delphi/run_bad.sh" "$OUTPUT"; then exit 1; fi
grep -q "User Validation Checklist" "$OUTPUT"

OUTPUT_NODE="$REPO/foundation_documentation/artifacts/environment-topology-node.md"
python3 "$TOOL" --repo "$REPO" --output "$OUTPUT_NODE"
grep -q "nestjs.*candidate.*nest-app/package.json \[dependencies:@nestjs/core\]" "$OUTPUT_NODE"
grep -q "react.*candidate.*react-app/package.json \[devDependencies:react-dom\]" "$OUTPUT_NODE"
grep -q "vite.*candidate.*vite-app/package.json \[devDependencies:vite\]" "$OUTPUT_NODE"
grep -q "postgresql.*unknown" "$OUTPUT_NODE"

MATRIX="$TMP_DIR/matrix"
mkdir -p "$MATRIX/nest" "$MATRIX/react" "$MATRIX/vite" "$MATRIX/vite-plugin-only" "$MATRIX/generic" "$MATRIX/react-native" "$MATRIX/types-only" "$MATRIX/nest-cli" "$MATRIX/malformed" "$MATRIX/oversized" "$MATRIX/root-array" "$MATRIX/wrong-section" "$MATRIX/split-nest" "$MATRIX/split-react" "$MATRIX/symlink" "$MATRIX/prisma/schema" "$MATRIX/prisma-client" "$MATRIX/railway" "$MATRIX/railway-near"
printf '%s\n' '{"dependencies":{"@nestjs/core":"^11"}}' > "$MATRIX/nest/package.json"
printf '%s\n' '{"optionalDependencies":{"react-dom":"^19"}}' > "$MATRIX/react/package.json"
printf '%s\n' '{"devDependencies":{"vite":"^7"}}' > "$MATRIX/vite/package.json"
printf '%s\n' '{"devDependencies":{"@vitejs/plugin-react":"^5"}}' > "$MATRIX/vite-plugin-only/package.json"
printf '%s\n' '{"dependencies":{"typescript":"^5"}}' > "$MATRIX/generic/package.json"
printf '%s\n' '{"dependencies":{"react-native":"^1"}}' > "$MATRIX/react-native/package.json"
printf '%s\n' '{"devDependencies":{"@types/react":"^1"}}' > "$MATRIX/types-only/package.json"
printf '%s\n' '{"dependencies":{"@nestjs/cli":"^11"}}' > "$MATRIX/nest-cli/package.json"
printf '%s\n' '{invalid json' > "$MATRIX/malformed/package.json"
head -c 1048577 /dev/zero > "$MATRIX/oversized/package.json"
printf '%s\n' '[]' > "$MATRIX/root-array/package.json"
printf '%s\n' '{"dependencies":"not-an-object"}' > "$MATRIX/wrong-section/package.json"
printf '%s\n' '{"dependencies":{"@nestjs/core":"^11"}}' > "$MATRIX/split-nest/package.json"
printf '%s\n' '{"peerDependencies":{"react-dom":"^19"}}' > "$MATRIX/split-react/package.json"
touch "$MATRIX/prisma/schema/schema.prisma"
printf '%s\n' '{"dependencies":{"@prisma/client":"^6"}}' > "$MATRIX/prisma-client/package.json"
touch "$MATRIX/railway/railway.toml"
touch "$MATRIX/railway-near/railway.yaml"
ln -s /etc/passwd "$MATRIX/symlink/package.json" || true

PYTHONPATH="$ROOT_DIR/tools" python3 - "$MATRIX" <<'PY'
import sys
from pathlib import Path
from environment_topology_contract_scaffold import RepositoryInventory, detect_stack_evidence, default_stack_capability_registry

root = Path(sys.argv[1])
inventory = RepositoryInventory.build(root)
rows = {row.stack: row for row in detect_stack_evidence(root, default_stack_capability_registry(), inventory)}
assert inventory.inventory_builds == 1
assert inventory.manifest_parses == len(inventory.manifests())
assert rows["nestjs"].evidence_state == "candidate"
assert rows["nestjs"].evidence == "nest/package.json [dependencies:@nestjs/core], split-nest/package.json [dependencies:@nestjs/core]"
assert rows["react"].evidence_state == "candidate"
assert rows["react"].evidence == "react/package.json [optionalDependencies:react-dom], split-react/package.json [peerDependencies:react-dom]"
assert rows["vite"].evidence_state == "candidate"
assert rows["vite"].evidence == "vite/package.json [devDependencies:vite]"
assert rows["postgresql"].evidence_state == "unknown"
assert rows["prisma"].evidence_state == "candidate"
assert rows["prisma"].evidence == "prisma-client/package.json [dependencies:@prisma/client], prisma/schema/schema.prisma"
assert rows["railway"].evidence_state == "candidate"
assert rows["railway"].evidence == "railway/railway.toml"
assert "railway-near/railway.yaml" not in rows["railway"].evidence
assert all("generic/package.json" not in row.evidence for row in rows.values())
assert all("react-native/package.json" not in row.evidence for row in rows.values())
assert all("types-only/package.json" not in row.evidence for row in rows.values())
assert all("nest-cli/package.json" not in row.evidence for row in rows.values())
assert all("vite-plugin-only/package.json" not in row.evidence for row in rows.values())
assert "manifest ignored: malformed/package.json" in inventory.diagnostics
assert "manifest ignored: oversized/package.json" in inventory.diagnostics
assert "manifest ignored: root-array/package.json (root must be an object)" in inventory.diagnostics
assert "manifest ignored section: wrong-section/package.json:dependencies" in inventory.diagnostics
assert "manifest ignored: symlink/package.json" in inventory.diagnostics
assert all("invalid json" not in diagnostic for diagnostic in inventory.diagnostics)
assert all("not-an-object" not in diagnostic for diagnostic in inventory.diagnostics)
assert all("/etc/passwd" not in row.evidence for row in rows.values())
PY

printf 'environment_topology_contract_scaffold_test: OK\n'
