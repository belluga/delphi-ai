---
name: docker-update-skill-method
description: "Update skills with canonical/Cline consolidation and required sync validation."
---

# Workflow: Update Skill Across Agent Surfaces

## Purpose
Keep skill behavior aligned across Codex, Cline, and Antigravity while preventing cross-surface drift.

## Steps

1. Edit canonical skill file at `delphi-ai/skills/<skill-name>/SKILL.md`.
2. Mirror the same content to `delphi-ai/.cline/skills/<skill-name>/SKILL.md`.
3. If behavior changed, update the corresponding canonical rules/workflows and Cline `.clinerules/**` counterparts.
4. If the skill is `wf-*`, ensure:
- canonical workflow exists in `delphi-ai/workflows/**`
- Cline workflow counterpart exists in `delphi-ai/.clinerules/workflows/**`
5. Run validations:
- downstream environment path: `bash delphi-ai/verify_context.sh` and `bash delphi-ai/verify_adherence_sync.sh`
- Delphi self-maintenance path: manual agnosticism review plus applicable local checks such as `bash tools/audit_instruction_baselines.sh`
6. Report changed files and explicitly confirm no Codex/Cline/Antigravity drift remains.

## Validation

- No mismatch between canonical and `.cline/skills` versions of edited skills.
- Workflow-skill counterparts exist in canonical and Cline workflow surfaces.
- For downstream environment runs, adherence sync check passes.
- For Delphi self-maintenance runs, manual agnosticism review and applicable local checks are recorded.
