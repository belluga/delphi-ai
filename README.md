# Delphi-AI Setup Guide

## Purpose
Centralized instructions to attach Delphi-AI (bootloaders, methods, templates) to any project repo.

## Supported AI Tools

| Tool | Bootloader | Artifacts |
|------|------------|-----------|
| **Cline** | Auto-loads `.clinerules/` | `.clinerules/`, `.cline/skills/` |
| **Codex/Antigravity** | `AGENTS.md` | `.codex/skills/`, `.agent/` |
| **Gemini** | `GEMINI.md` | `skills/` directory |

## Quick Setup

### Option 1: Full Setup (Recommended)
Run the setup helper from the project root:
```bash
bash delphi-ai/init.sh
```
- Prompts for Laravel/Flutter/Web submodule URLs (defaults to current entries).
- Creates all required symlinks for Cline, Codex, and Gemini.

### Option 2: Manual Setup

1. Clone Delphi-AI (if not present):
   ```bash
   git clone https://github.com/belluga/delphi-ai.git delphi-ai
   ```

2. **For Cline** (auto-loads rules):
   ```bash
   ln -s delphi-ai/.clinerules .clinerules
   mkdir -p .cline
   ln -s ../delphi-ai/.cline/skills .cline/skills
   ```

3. **For Codex/Antigravity**:
   ```bash
   ln -s delphi-ai/templates/agents/root.md AGENTS.md
   mkdir -p .codex
   ln -s ../delphi-ai/skills .codex/skills
   ```

4. **For Gemini**:
   ```bash
   ln -s delphi-ai/GEMINI.md GEMINI.md
   ln -s delphi-ai/skills skills
   ```

3. Check `git status` to ensure submodule URLs point to your project forks, not boilerplate.

## Cline-Specific Details

Cline automatically discovers artifacts without a bootloader file:

| Artifact | Location | Auto-Loaded |
|----------|----------|-------------|
| Rules | `.clinerules/*.md` | ✅ Always |
| Conditional Rules | `.clinerules/glob/*.md` | ✅ On file match |
| Workflows | `.clinerules/workflows/*.md` | ✅ Via `/filename.md` |
| Hooks | `.clinerules/hooks/*` | ✅ If executable |
| Skills | `.cline/skills/*/SKILL.md` | ✅ On-demand |

### Available Workflows
- `/create-controller.md` - New Flutter controller
- `/create-screen.md` - New Flutter screen
- `/create-domain.md` - New Flutter domain
- `/create-repository.md` - New Flutter repository

## Notes
- Delphi instructions remain agnostic; project-specific stack details should live under `foundation_documentation/`.
- Always run the DevOps readiness workflow before builds (`delphi-ai/workflows/docker/environment-readiness-method.md`).
