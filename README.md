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
Optional preflight before making changes:
```bash
bash delphi-ai/init.sh --check
```

Run the setup helper from the project root:
```bash
bash delphi-ai/init.sh
```
- In non-interactive environments, the helper reuses the current `.gitmodules` URLs unless `DELPHI_*_URL` overrides are provided.
- Prompts for Laravel/Flutter/Web submodule URLs (defaults to current entries).
- Creates the documented bootloaders/symlinks for Cline, Codex, and Gemini, and syncs `.agent` rules/workflows when the downstream layout is available.
- If a required Delphi path is already occupied by a different file/symlink/directory, setup fails clearly and prints the blocking paths. Fix them manually, then rerun.
- Run `bash delphi-ai/verify_context.sh` afterward as a read-only validation pass.
- If the validation fails only because Delphi-managed links/artifacts are missing or misaligned, run `bash delphi-ai/verify_context.sh --repair`, then rerun plain `bash delphi-ai/verify_context.sh`.
- For full governance mirror validation after readiness passes, run `bash delphi-ai/verify_adherence_sync.sh`.

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
   bash delphi-ai/tools/sync_agent_rules.sh
   ```

4. **For Gemini**:
   ```bash
   ln -s delphi-ai/GEMINI.md GEMINI.md
   ln -s delphi-ai/skills skills
   ```

5. Check `git status` to ensure submodule URLs point to your project forks, not boilerplate.

## If Setup Fails

The installer now fails on path conflicts instead of trying to overwrite them silently.

Common blocking paths are:
- `AGENTS.md`
- `CLINE.md`
- `GEMINI.md`
- `skills/`
- `.clinerules/`
- `.cline/skills/`
- `.codex/skills/`
- `flutter-app/AGENTS.md`
- `laravel-app/AGENTS.md`
- `flutter-app/foundation_documentation`
- `laravel-app/foundation_documentation`
- `flutter-app/delphi-ai`
- `laravel-app/delphi-ai`
- `flutter-app/scripts`
- `laravel-app/scripts/delphi`

Manual resolution rules:
- If the path already belongs to your project, keep it and install Delphi manually only where it does not conflict.
- If the path is supposed to be Delphi-managed, rename or remove the conflicting file/directory, then rerun `bash delphi-ai/init.sh`.
- After any manual fix, run `bash delphi-ai/init.sh --check`, then `bash delphi-ai/init.sh`, then `bash delphi-ai/verify_context.sh`.

## AI Install Guide

If an AI agent is asked to install Delphi in a host repo, it should follow this exact behavior:

1. Inspect the required Delphi-owned paths before running setup.
2. If any required path already exists and is not the expected Delphi symlink, stop immediately and report the exact conflicting paths.
3. Do not overwrite project-owned files or directories.
4. After the user resolves conflicts, run:
   ```bash
   bash delphi-ai/init.sh --check
   bash delphi-ai/init.sh
   bash delphi-ai/verify_context.sh
   bash delphi-ai/verify_adherence_sync.sh
   ```
5. If `verify_context` fails only on repairable Delphi-managed links/artifacts, run:
   ```bash
   bash delphi-ai/verify_context.sh --repair
   bash delphi-ai/verify_context.sh
   ```
6. Report whether setup completed cleanly or whether manual remediation is still required.

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
