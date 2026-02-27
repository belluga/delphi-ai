## Brief overview
Documents the correct Cline artifact structure for the Delphi AI project. This rule ensures Cline correctly loads rules, skills, workflows, and hooks according to Cline's native format requirements.

## Artifact locations
- **Rules**: `.clinerules/` directory - Markdown files with optional YAML frontmatter for conditional loading
- **Skills**: `.cline/skills/` directory - Each skill is a subdirectory containing `SKILL.md` with YAML frontmatter
- **Workflows**: `.clinerules/workflows/` directory - Markdown files with step-by-step instructions
- **Hooks**: `.clinerules/hooks/` directory - Executable scripts (bash, python) that receive JSON via stdin and output JSON via stdout

## Skills format
Skills must be directories with a `SKILL.md` file:
```
.cline/skills/
└── my-skill/
    └── SKILL.md
```

SKILL.md requires YAML frontmatter:
```yaml
---
name: my-skill
description: When to use this skill (max 1024 characters)
---
```
- `name` must exactly match the directory name
- `description` determines when Cline activates the skill

## Workflows format
Workflows are markdown files invoked with `/filename.md`:
```markdown
# Workflow Title

Brief description.

## Step 1: First step
Instructions for Cline.

## Step 2: Second step
More instructions.
```
- Can use natural language, Cline XML tool syntax, or CLI commands
- Filename becomes the command (e.g., `release.md` → `/release.md`)

## Hooks format
Hooks are executable scripts (NOT markdown):
- Must be executable (`chmod +x`)
- Receive JSON input via stdin
- Output JSON via stdout with structure: `{"cancel": false, "contextModification": "...", "errorMessage": "..."}`
- Hook types: TaskStart, TaskResume, TaskCancel, TaskComplete, PreToolUse, PostToolUse, UserPromptSubmit, PreCompact

## Common mistakes to avoid
- Do NOT put `.md` files in hooks directory - hooks must be executable scripts
- Do NOT put skills directly as `.md` files - skills must be directories with `SKILL.md` inside
- Skills `name` field must match directory name exactly
- Use kebab-case for skill names (e.g., `data-analysis`, not `data_analysis` or `DataAnalysis`)