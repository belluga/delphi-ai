---
name: docker-update-skill-method
description: "Update skills with canonical/Cline consolidation and required sync validation."
---

# Workflow: Update Skill Across Agent Surfaces

## Purpose
Keep skill behavior aligned across Codex, Cline, and Antigravity while preventing cross-surface drift.

## Preconditions

- If working in a downstream project environment, run `bash delphi-ai/verify_context.sh` as a read-only readiness check before edits. If it fails only on Delphi-managed links/artifacts, run `bash delphi-ai/verify_context.sh --repair`, then rerun plain verification. If it fails on a path conflict with project-owned files/directories, stop and report it for manual remediation.
- If working directly on `delphi-ai/` instruction surfaces, use manual agnosticism review plus applicable local checks instead of blocking on downstream-only readiness artifacts.

## Steps

1. Edit canonical skill file at `delphi-ai/skills/<skill-name>/SKILL.md`.
2. If the skill is already exposed to Cline, or the change requires a new Cline mirror, run `bash delphi-ai/tools/sync_cline_skill_mirrors.sh <skill-name>`.
3. If behavior changed, update the corresponding canonical rules/workflows and Cline `.clinerules/**` counterparts.
4. If the skill is `wf-*`, ensure:
- canonical workflow exists in `delphi-ai/workflows/**`
- Cline workflow counterpart exists in `delphi-ai/.clinerules/workflows/**`
5. Run validations:
- downstream environment path: `bash delphi-ai/verify_context.sh` (read-only; use `--repair` only for Delphi-managed links/artifacts, then rerun plain verification) and `bash delphi-ai/verify_adherence_sync.sh`
- Delphi self-maintenance path: manual agnosticism review plus applicable local checks such as `bash tools/audit_instruction_baselines.sh`
6. Report changed files and explicitly confirm no Codex/Cline/Antigravity drift remains.

## Validation

- No mismatch between canonical and `.cline/skills` versions of edited skills.
- Workflow-skill counterparts exist in canonical and Cline workflow surfaces.
- For downstream environment runs, read-only `verify_context.sh` and adherence sync check pass.
- For Delphi self-maintenance runs, manual agnosticism review and applicable local checks are recorded.
