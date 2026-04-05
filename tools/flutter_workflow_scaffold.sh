#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: flutter_workflow_scaffold.sh --kind <controller|domain|repository|screen> --name <text> [--feature <text>] [--output <path>]

Generate a markdown checklist scaffold for Delphi Flutter workflow skills.
This helper is intentionally partial: it prepares the repeatable doc/file/test checklist but does not generate production code.
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

KIND=""
NAME=""
FEATURE=""
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
    --feature)
      [ $# -ge 2 ] || die "missing value for --feature"
      FEATURE="$2"
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
  controller|domain|repository|screen) ;;
  *) die "--kind must be one of controller|domain|repository|screen" ;;
esac

[ -n "$NAME" ] || die "--name is required"

render_kind_sections() {
  case "$KIND" in
    controller)
      cat <<EOF
## Planned File Surfaces
- \`lib/presentation/<module>/${FEATURE:-<feature>}/screens/<screen>/controllers/${NAME}_controller.dart\`
- \`lib/application/router/modular_app/module_settings.dart\` or feature DI scope
- Targeted controller test file when behavior is non-trivial

## Checklist
- Document controller responsibility in module docs and roadmap if shared behavior/contracts move.
- Inject repositories/services via constructor and register through GetIt.
- Keep UI controllers (`TextEditingController`, `ScrollController`) owned and disposed by the controller.
- Keep widgets `BuildContext`-free and dependent on controller APIs only.
- Run \`fvm flutter analyze\`.
EOF
      ;;
    domain)
      cat <<EOF
## Planned File Surfaces
- \`foundation_documentation/domain_entities.md\`
- \`lib/domain/${NAME}/\`
- \`lib/domain/repositories/${NAME}_repository_contract.dart\`
- \`lib/infrastructure/mappers/<feature>_dto_mapper.dart\`
- \`lib/infrastructure/repositories/${NAME}_repository.dart\`
- DI registration surface under \`lib/application/router/modular_app/\`

## Checklist
- Canonicalize the aggregate in docs before code.
- Create entity/value object/projection surfaces under \`lib/domain/${NAME}/\`.
- Keep DTO-to-domain translation in infrastructure mappers only.
- Register repository/service dependencies in GetIt.
- Update controllers/widgets to consume domain types instead of DTOs.
- Run \`fvm flutter analyze\` and targeted unit tests.
EOF
      ;;
    repository)
      cat <<EOF
## Planned File Surfaces
- \`lib/domain/repositories/${NAME}_repository_contract.dart\`
- \`lib/infrastructure/mappers/${NAME}_dto_mapper.dart\`
- \`lib/infrastructure/repositories/${NAME}_repository.dart\`
- DI registration surface under \`module_settings.dart\`
- Repository or consumer tests

## Checklist
- Freeze the contract in domain language, not screen language.
- Keep raw transport parsing/building out of repository methods.
- Place DTO decoding and formatting helpers in DAO/mapper boundaries.
- Update consuming controllers/services to depend on the contract only.
- Run \`fvm flutter analyze\` and targeted tests.
- If branch-delta enforcement is in use, run the relevant branch guard command.
EOF
      ;;
    screen)
      cat <<EOF
## Planned File Surfaces
- \`lib/presentation/<module>/${FEATURE:-<feature>}/${NAME}_screen.dart\`
- \`lib/presentation/<module>/${FEATURE:-<feature>}/${NAME}_controller.dart\`
- \`lib/presentation/<module>/${FEATURE:-<feature>}/widgets/*.dart\`
- Route registration in \`app_router.dart\`
- Generated router output after \`build_runner\`

## Checklist
- Freeze scope/subscope placement before creating files.
- Keep the screen pure UI and move state/business logic into the controller.
- Use one widget per file for feature widgets.
- Register dependencies in the appropriate module scope.
- Regenerate router/build artifacts when route annotations change.
- Run \`fvm flutter analyze\` and navigation verification.
EOF
      ;;
  esac
}

render() {
  local now_utc
  now_utc="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"

  cat <<EOF
# Flutter Workflow Scaffold

- Kind: $KIND
- Name: $NAME
- Feature: ${FEATURE:-not-recorded}
- Created At: $now_utc

## Documentation / Governance
- Relevant module docs:
- \`foundation_documentation/system_roadmap.md\` impact:
- \`foundation_documentation/policies/scope_subscope_governance.md\` impact:

EOF

  render_kind_sections

  cat <<'EOF'

## Validation
- Analyzer command:
- Targeted tests:
- Route/build generation command (if needed):
- Follow-up doc sync:
EOF
}

if [ -n "$OUTPUT_PATH" ]; then
  mkdir -p "$(dirname "$OUTPUT_PATH")"
  render >"$OUTPUT_PATH"
  printf 'Wrote Flutter workflow scaffold to %s\n' "$OUTPUT_PATH"
else
  render
fi
