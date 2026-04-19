# Claude Code Bootloader — Delphi AI Co-Engineer

This file serves as the entry point for Claude Code to load the Delphi AI Co-Engineer context.

## Quick Start

1. **Core Instructions** are loaded automatically from `.claude/rules/` directory
2. **Skills** are available in `.claude/skills/`
3. **Primary instruction source**: Read `./delphi-ai/main_instructions.md` before any work

## Directory Structure

```
.claude/
├── rules/                       # Rules loaded automatically every session
│   ├── 00-main-instructions.md  # Core identity and operational instructions
│   ├── 01-governance-protocol.md # PACED governance and T.E.A.C.H. framework
│   └── ...                      # Stack-specific and shared rules
├── skills/                      # Reusable skills for specific tasks
│   ├── <skill-name>/SKILL.md   # Each skill in its own directory
│   └── ...
└── settings.json                # Permissions and configuration
```

## Readiness Check

Before starting downstream project work, verify context availability:

```bash
bash delphi-ai/verify_context.sh
```

If it fails only on Delphi-managed links/artifacts:

```bash
bash delphi-ai/verify_context.sh --repair
bash delphi-ai/verify_context.sh
```

## Identity & Profile

- Maintain Delphi identity alignment (Senior Software Co-engineer) per `main_instructions.md`.
- Run `delphi-ai/workflows/docker/profile-selection-method.md` to declare the active profile and technical scope before task-specific work.

## Governance Surfaces

| Surface | Location |
|---------|----------|
| Rules | `.claude/rules/` (auto-loaded every session) |
| Skills | `.claude/skills/` (invocable via `/skill-name`) |
| Deterministic Guards | `.agents/deterministic/` |
| Foundation Docs | `foundation_documentation/` |
| Patterns Library | `delphi-ai/patterns/` and `foundation_documentation/patterns/local/` |

## Available Skills

Skills are invocable via `/skill-name` in Claude Code. Key skills include:

| Skill | Purpose |
|-------|---------|
| `flutter-architecture-adherence` | Enforces Flutter architecture rules |
| `test-creation-standard` | Test creation with baseline and gate controls |
| `test-quality-audit` | Test integrity audit with bypass detection |
| `audit-protocol-triple-review` | Triple-review audit protocol |
| `bug-fix-evidence-loop` | Evidence-based bug fix workflow |
| `github-main-promotion-orchestrator` | Main branch promotion workflow |
| `github-stage-promotion-orchestrator` | Stage branch promotion workflow |

Run `/skills` in Claude Code to see the full list of available skills.

## Delivery Authority

- Claude Code planning is advisory by default.
- Implementation authority requires Delphi TODO governance:
  - Active tactical TODO in `todos/active/`
  - Explicit `APROVADO` before project-modifying actions
  - Decision Adherence Gate evidence before delivery
- See `.claude/rules/` for TODO-driven execution rules.

## Source of Truth

- **Agnostic Core Context**: `delphi-ai/` directory
- **Project-Specific Context**: `foundation_documentation/`

## Compatibility

This repo also supports:

- **Codex**: See `AGENTS.md` and `.codex/skills/`
- **Gemini/Antigravity**: See `GEMINI.md` and `.agents/skills/`
- **Cline**: See `CLINE.md`, `.clinerules/`, and `.cline/skills/`
