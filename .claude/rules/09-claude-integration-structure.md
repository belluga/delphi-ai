---
description: "Documents the correct Claude Code artifact structure for the Delphi AI project"
alwaysApply: true
---

# Claude Code Integration Structure

## Artifact Locations

| Artifact | Location | Format |
|---|---|---|
| Bootloader | `CLAUDE.md` (project root) | Markdown entry point |
| Rules | `.claude/rules/` | Markdown with YAML frontmatter |
| Skills | `.claude/skills/` | Directories with `SKILL.md` inside |
| Settings | `.claude/settings.json` | JSON permissions config |
| Deterministic Guards | `delphi-ai/deterministic/` | Python scripts |
| Workflows | `delphi-ai/workflows/` | Markdown step-by-step |

## Rules Format

Rules are Markdown files in `.claude/rules/` with YAML frontmatter:

```yaml
---
description: "When this rule should activate (max 1024 chars)"
globs: ["pattern/**"]    # Optional: file patterns that trigger this rule
alwaysApply: true/false  # Whether rule loads every session
---
```

- `alwaysApply: true` rules load in every session (core governance).
- `globs` rules activate when matching files are in context.
- Rules without `globs` and with `alwaysApply: false` are model-decision (contextual).

## Skills Format

Skills must be directories with a `SKILL.md` file:

```
.claude/skills/
└── my-skill/
    └── SKILL.md
```

`SKILL.md` requires YAML frontmatter:

```yaml
---
name: my-skill
description: When to use this skill (max 1024 characters)
---
```

The `name` field must exactly match the directory name.

## Settings Format

`.claude/settings.json` defines permissions:

```json
{
  "permissions": {
    "allow": ["Bash(*)", "Read(*)", "Write(*)"],
    "deny": []
  }
}
```

## Cross-Agent Compatibility

This repo supports multiple agents. Each has its own artifact surface:

| Agent | Bootloader | Rules | Skills |
|---|---|---|---|
| Claude Code | `CLAUDE.md` | `.claude/rules/` | `.claude/skills/` |
| Cline | `CLINE.md` | `.clinerules/` | `.cline/skills/` |
| Codex | `AGENTS.md` | `.codex/` | `.codex/skills/` |
| Gemini | `GEMINI.md` | `.agents/` | `.agents/skills/` |

All agents share the same canonical rules in `rules/` and deterministic guards in `delphi-ai/deterministic/`.
