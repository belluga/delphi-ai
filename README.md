# Delphi-AI Setup Guide

## Purpose
Centralized instructions to attach Delphi-AI (bootloaders, methods, templates) to any project repo.

## Steps

1. Clone Delphi-AI (if not present):
   ```bash
   git clone https://github.com/belluga/delphi-ai.git delphi-ai
   ```
2. Run the setup helper from the project root:
   ```bash
   ./scripts/setup_delphi.sh
   ```
   - Prompts for Laravel/Flutter/Web submodule URLs (defaults to current entries).
   - Creates required symlinks for `AGENTS.md`, `foundation_documentation`, and `delphi-ai` inside submodules.
3. Check `git status` to ensure submodule URLs point to your project forks, not boilerplate.

## Notes
- Delphi instructions remain agnostic; project-specific stack details should live under `foundation_documentation/`.
- Always run the DevOps readiness workflow before builds (`delphi-ai/workflows/docker/environment-readiness-method.md`).
