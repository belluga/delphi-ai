---
name: wf-docker-update-skill-method
description: "Workflow: MUST use whenever the scope matches this purpose: Keep Delphi skills synchronized across canonical and Cline surfaces while updating any dependent rules/workflows and validating sync integrity."
---

# Workflow: Update Skill Across Agent Surfaces

## Purpose
Update or create skills with one canonical process that keeps Cline, Codex, and Antigravity aligned.

## Preconditions
- If working in a downstream project environment, run `bash delphi-ai/verify_context.sh` as a read-only readiness check before edits. If it fails only on Delphi-managed links/artifacts, run `bash delphi-ai/verify_context.sh --repair`, then rerun plain verification. If it fails on a path conflict with project-owned files/directories, stop and report it for manual remediation.
- If working directly on `delphi-ai/` instruction surfaces, use manual agnosticism review plus applicable local checks instead of blocking on downstream-only readiness artifacts.
- Identify the target skill name in kebab-case.
- Confirm if the change is skill-only or also affects rule/workflow behavior.
- Canonical project skills must live inside this repository under `delphi-ai/skills/` (never as the primary source in `~/.codex/skills/**`).
- Review `delphi-ai/skills/deterministic-tooling-register.md` when the skill already exists, or be prepared to classify the skill there when creating a new one.

## Steps
1. Edit the canonical skill in `delphi-ai/skills/<skill-name>/SKILL.md`.
2. Classify or refresh the skill entry in `delphi-ai/skills/deterministic-tooling-register.md`.
   - Use `skill-only` when the skill is mainly governance, judgment, or orchestration.
   - Use `lint/analyzer` when the right extraction path is static analysis rather than a shell/python helper.
   - Use `partial-tool` when only the mechanical subset should be scripted.
   - Use `full-tool-candidate` when the flow is objective enough to justify a deterministic helper end-to-end.
   - Use `already-backed` when a canonical tool/script already materially supports the skill.
   - Link any existing canonical support and record the preferred support shape when no tool exists yet.
3. Ensure frontmatter `name` exactly matches the folder name.
4. If the skill is already exposed to Cline, or the change requires a new Cline mirror, sync it with `bash delphi-ai/tools/sync_cline_skill_mirrors.sh <skill-name>`.
5. If the skill was created outside canonical surfaces (for example under `~/.codex/skills/**`), migrate it into `delphi-ai/skills/<skill-name>/SKILL.md`, sync any required Cline mirror with `bash delphi-ai/tools/sync_cline_skill_mirrors.sh <skill-name>`, and remove/deprecate the out-of-surface copy to avoid drift.
6. If the skill introduces or changes operational behavior, update compatible rule/workflow files too:
   - Canonical (Codex/Antigravity): `delphi-ai/rules/**`, `delphi-ai/workflows/**`, and affected `delphi-ai/skills/rule-*` or `delphi-ai/skills/wf-*`.
   - Cline-compatible: `delphi-ai/.clinerules/model-decision/**`, `delphi-ai/.clinerules/glob/**`, `delphi-ai/.clinerules/manual/**`, `delphi-ai/.clinerules/workflows/**`.
   - After changing any curated canonical rule/workflow that has a generated `.clinerules` counterpart, run `bash delphi-ai/tools/sync_clinerules_mirrors.sh`.
7. If changed behavior defines/changes an API contract pattern (for example PATCH semantics), consolidate all contract surfaces:
   - Update `foundation_documentation/endpoints_mvp_contracts.md` conventions.
   - Update active tactical TODO decisions/tasks/validation gates with explicit convergence work for legacy areas.
   - Update endpoint-related Laravel workflow/skills surfaces so the rule is enforceable for `Cline | Codex | Antigravity`.
8. If a new canonical pattern impacts existing code, add a mandatory side-job in the active TODO to align non-conforming areas (or record explicit exceptions with rationale/owner/next action).
9. If the changed skill is a workflow skill (`wf-*`), ensure a canonical workflow file exists under `delphi-ai/workflows/**` and a Cline workflow counterpart exists under `delphi-ai/.clinerules/workflows/**`.
10. Validate sync and compatibility:
   - Downstream environment path: `bash delphi-ai/verify_context.sh` (read-only; use `--repair` only for Delphi-managed links/artifacts, then rerun plain verification) and `bash delphi-ai/verify_adherence_sync.sh`
   - Delphi self-maintenance path: `bash self_check.sh` plus any explicit mirror/counterpart diff checks that matter for the touched surfaces
   - Optional explicit diff: `diff -u delphi-ai/skills/<skill-name>/SKILL.md delphi-ai/.cline/skills/<skill-name>/SKILL.md`
11. Report changed files and explicitly confirm consolidation for `Cline | Codex | Antigravity`.

## Outputs
- Updated skill in canonical and Cline-compatible locations.
- Updated skill-tooling register entry when the skill was created, reclassified, or materially changed in deterministic support expectations.
- Related rules/workflows synchronized when needed.
- Contract conventions and active TODO obligations synchronized when behavioral standards change.
- Validation evidence that adherence checks passed.

## Validation
- No mismatch between `delphi-ai/skills/<skill-name>/SKILL.md` and `delphi-ai/.cline/skills/<skill-name>/SKILL.md`.
- Materially changed skills are classified in `delphi-ai/skills/deterministic-tooling-register.md` with current support notes.
- Workflow-skill counterparts exist in both canonical and Cline workflow surfaces.
- For downstream environment runs, read-only `verify_context.sh` and `verify_adherence_sync.sh` exit successfully.
- For Delphi self-maintenance runs, manual agnosticism review and applicable local checks are recorded with explicit N/A rationale where needed.
