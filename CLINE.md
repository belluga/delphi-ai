# Cline Bootloader — Delphi AI Co-Engineer

This file serves as the entry point for Cline to load the Delphi AI Co-Engineer context.

## Quick Start

1. **Core Instructions** are loaded automatically from `.clinerules/` directory
2. **Skills** are available in `.cline/skills/`
3. **Workflows** are available in `.clinerules/workflows/`

## Directory Structure

```
.clinerules/
├── 00-main-instructions.md      # Core identity and operational instructions
├── 01-flutter-architecture.md   # Flutter architecture rules (always-on)
└── ...                          # Additional rule files

.cline/
├── skills/                      # Reusable skills for specific tasks
└── ...

.clinerules/
├── workflows/                   # Step-by-step procedures
│   ├── create-controller.md
│   ├── create-domain.md
│   ├── create-screen.md
│   ├── create-repository.md
│   ├── docker-todo-driven-execution.md
│   ├── docker-update-skill-method.md
│   └── laravel-create-package-method.md
└── hooks/                       # Event-driven hooks (optional)
```

## Available Skills

| Skill | Description |
|-------|-------------|
| `flutter-architecture-adherence` | Architecture guardrail for Flutter - entrypoint for any Flutter change |
| `flutter-smell-async-navigation` | Detects navigation inside async gaps |
| `flutter-smell-mounted-checks` | Detects `mounted`/`context.mounted` checks as smell |
| `flutter-smell-build-side-effects` | Detects side effects in build methods |
| `flutter-widget-local-state-heuristics` | Defines boundary between ephemeral and controller-owned state |
| `wf-docker-update-skill-method` | Keeps Codex/Cline/Antigravity skills and workflow artifacts synchronized |
| `wf-docker-todo-driven-execution-method` | TODO-driven execution workflow with module-anchor and consolidation gates |
| `rule-docker-shared-todo-driven-execution-model-decision` | Enforces TODO/APROVADO/adherence/module-consolidation gates before delivery |
| `wf-laravel-create-api-endpoint-method` | Laravel endpoint workflow with domain matrix, ability-catalog sync, and PATCH contract gates |
| `rule-laravel-shared-tenant-access-guardrails-model-decision` | Enforces tenant route guardrails + route-matrix and domain-param checks |
| `rule-laravel-shared-todo-driven-execution-model-decision` | Enforces TODO/APROVADO/adherence with module coherence + consolidation gates |
| `rule-laravel-shared-ability-catalog-sync-model-decision` | Enforces ability string sync across routes/settings/policies and token catalogs |
| `rule-laravel-shared-settings-kernel-patch-contract-model-decision` | Enforces Settings Kernel PATCH payload contract (dot-path + field-presence semantics) |
| `rule-flutter-flutter-repository-workflow-glob` | Enforces repository workflow + DAO/DTO raw payload boundary on Flutter repository edits |
| `rule-flutter-flutter-contract-alignment-always-on` | Enforces Flutter contract alignment, including repository/DAO transport boundary discipline |
| `wf-flutter-create-repository-method` | Repository method workflow with explicit DAO/decoder boundary and typed transport contracts |
| `wf-laravel-create-package-method` | Laravel package decoupling workflow with mandatory assertions |
| `wf-laravel-create-domain-method` | Laravel domain workflow with tenant/landlord migration and index lifecycle guardrails |
| `test-quality-audit` | Test integrity audit with bypass detection and decision-adherence checks |
| `test-creation-standard` | Test creation standard with explicit baseline and gate controls |
| `test-orchestration-suite` | Cross-stack orchestration with staged gates and adherence validation |

## Available Workflows

| Workflow | Purpose |
|----------|---------|
| `create-controller` | Introduce a new Flutter controller with StreamValue |
| `create-domain` | Introduce a new Flutter domain aggregate |
| `create-screen` | Scaffold a new Flutter feature screen |
| `create-repository` | Establish domain-aligned data access |
| `create-repository-method` | Method-suffixed repository workflow counterpart with explicit DAO/decoder transport boundary gates |
| `docker-todo-driven-execution` | Enforce TODO, APROVADO, and Decision Adherence gates |
| `docker-todo-driven-execution-method` | Method-suffixed counterpart for TODO, APROVADO, and module-consolidation gates |
| `docker-update-skill-method` | Update skills with cross-surface sync controls |
| `laravel-create-package-method` | Create/refactor Laravel packages with explicit boundaries |

## Usage

### For Flutter Work

1. Start with `flutter-architecture-adherence` skill
2. Based on the task, invoke the appropriate workflow:
   - Creating controller → `create-controller` workflow
   - Creating domain → `create-domain` workflow
   - Creating screen → `create-screen` workflow
   - Creating repository → `create-repository` workflow

### For Code Review

Use the smell detection skills:
- `flutter-smell-async-navigation` for navigation issues
- `flutter-smell-mounted-checks` for lifecycle issues
- `flutter-smell-build-side-effects` for side effect issues

## Delivery Authority

- Cline planning is advisory by default.
- Implementation authority requires Delphi TODO governance:
  - active tactical TODO,
  - explicit `APROVADO` before project-modifying actions,
  - Decision Adherence Gate evidence before delivery.
- See `.clinerules/model-decision/shared-todo-driven-execution.md` and `.clinerules/workflows/docker-todo-driven-execution.md`.

## Verification

Before starting work, verify context availability:

```bash
bash delphi-ai/verify_context.sh
```

## Source of Truth

- **Agnostic Core Context**: `delphi-ai/` directory
- **Project-Specific Context**: `/foundation_documentation/`

## Compatibility

This repo also supports:
- **Codex/Antigravity**: See `GEMINI.md` and `skills/` directory
- **Cline**: See `.clinerules/` and `.cline/` directories
