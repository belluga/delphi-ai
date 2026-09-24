#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: laravel_workflow_scaffold.sh --kind <api-endpoint|domain> --name <text> [--module <text>] [--output <path>]

Generate a markdown checklist scaffold for Delphi Laravel workflow skills.
This helper structures the repeatable checklist but does not replace contract/security/domain judgment.
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

KIND=""
NAME=""
MODULE_NAME=""
OUTPUT_PATH=""

while [ $# -gt 0 ]; do
  case "$1" in
    --kind)
      [ $# -ge 2 ] || die "missing value for --kind"
      KIND="$2"
      shift 2
      ;;
    --name)
      [ $# -ge 2 ] || die "missing value for --name"
      NAME="$2"
      shift 2
      ;;
    --module)
      [ $# -ge 2 ] || die "missing value for --module"
      MODULE_NAME="$2"
      shift 2
      ;;
    --output)
      [ $# -ge 2 ] || die "missing value for --output"
      OUTPUT_PATH="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

case "$KIND" in
  api-endpoint|domain) ;;
  *) die "--kind must be one of api-endpoint|domain" ;;
esac

[ -n "$NAME" ] || die "--name is required"

render_kind_sections() {
  case "$KIND" in
    api-endpoint)
      cat <<EOF
## Planned File Surfaces
- Relevant module docs${MODULE_NAME:+ for $MODULE_NAME}
- \`foundation_documentation/endpoints_mvp_contracts.md\`
- \`routes/api/*.php\`
- Controller / Request / Service / Policy files
- Ability catalog surface (\`config/abilities.php\` when applicable)
- Feature/security tests

## Checklist
- Freeze request/response contract and security level before coding.
- Choose the correct route file/group and middleware stack.
- Keep controllers thin and extract reusable logic into services/actions.
- Sync any new ability string into the ability catalog path when token expansion needs it.
- Add happy-path, validation, ability, and replay/idempotency coverage as applicable.
- Run \`php artisan route:list\`, architecture guardrails, lint/static analysis, and targeted tests.
EOF
      ;;
    domain)
      cat <<EOF
## Planned File Surfaces
- \`foundation_documentation/domain_entities.md\`
- Relevant module docs${MODULE_NAME:+ for $MODULE_NAME}
- DocumentModel under \`app/Models/\`
- Migration paths under \`database/migrations/landlord|tenant\`
- Factories / seeders when bootstrap coverage is needed
- Targeted tests

## Checklist
- Canonicalize fields, invariants, indexes, and collection scope in docs first.
- Plan schema/index changes through migrations, never in runtime request paths.
- Keep MongoDB-backed array/object fields uncast unless the driver requires otherwise.
- Update seeders/factories only when bootstrap or regression coverage needs them.
- Sync module docs and roadmap when the domain unlocks broader work.
- Run targeted Laravel tests after the model/migration change.
EOF
      ;;
  esac
}

render() {
  local now_utc
  now_utc="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"

  cat <<EOF
# Laravel Workflow Scaffold

- Kind: $KIND
- Name: $NAME
- Module: ${MODULE_NAME:-not-recorded}
- Created At: $now_utc

## Documentation / Governance
- \`foundation_documentation/project_constitution.md\` impact:
- \`foundation_documentation/system_roadmap.md\` impact:
- Active TODO / approval notes:

EOF

  render_kind_sections

  cat <<'EOF'

## Validation
- Targeted tests:
- Route / migration / model verification:
- Guardrail commands:
- Follow-up doc sync:
EOF
}

if [ -n "$OUTPUT_PATH" ]; then
  mkdir -p "$(dirname "$OUTPUT_PATH")"
  render >"$OUTPUT_PATH"
  printf 'Wrote Laravel workflow scaffold to %s\n' "$OUTPUT_PATH"
else
  render
fi
