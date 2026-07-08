---
name: prune-artifacts
description: "Safely prune Delphi artifact folders when `artifacts/**`, `tmp/**`, review packets, checkpoints, or generated evidence have grown noisy, especially after successful closeout or environment prune, by inventorying candidates, consolidating durable decisions, and deleting only non-active disposable artifacts."
---

# Prune Artifacts

## Purpose
Reduce context and repository noise from generated artifact folders without losing decisions, evidence, or active recovery paths.

This skill is a consolidation-first artifact cleanup flow. It is not a repository branch/worktree cleanup flow.
Its explicit goal is to remove disposable temporary noise while promoting any durable architectural, operational, or product truth out of raw artifacts and into the correct authoritative surface before deletion.

## Trigger
- Use this skill when the user asks to prune or clean `artifacts/**`, `artifacts/tmp/**`, generated evidence packets, checkpoint artifacts, execution-plan artifacts, review/audit artifacts, or artifact pollution after a successful execution.
- Use this skill after a broader environment prune only for the artifact portion of the work.
- If the request also includes repository branch, worktree, or rebaseline cleanup, run `prune-repository` for that part and keep artifact deletion governed here.

## Boundaries
- Default to dry-run inventory first. Do not delete until the candidate list, keep reasons, and consolidation blockers are explicit.
- Do not delete an artifact referenced by an active TODO, execution plan, delivery gate, checkpoint, promotion/reconcile plan, failure review, unresolved finding, or pending user validation.
- Do not delete canonical documentation, source code, project configuration, live TODO folders, promotion ledgers, or environment topology contracts as "artifact cleanup".
- Do not use symlink traversal casually. Report symlinked artifact roots before sizing or pruning them, because a local `delphi-ai/rules/*/local` link may point into another repository.
- Do not use this skill for Git branch deletion, worktree pruning, rebase/reset, remote cleanup, or gitlink correction. Route those through `prune-repository` and `branch-rebaseline-preflight`.
- Do not let an artifact remain the sole durable home of a relevant decision, invariant, environment contract, or routed finding once that truth is stable enough for canonical documentation.
- Do not promote artifact-derived content into canonical system documentation without explicit user validation that the proposed truth is ready to become canonical. When in doubt, stage the proposed consolidation as a recommendation or TODO-linked summary instead of silently canonizing it.

## Artifact Classes
- `artifacts/tmp/**`
  - Default prune candidate after successful closeout.
  - Keep only `.gitkeep`, active lock/state files, or files referenced by still-open work.
- `artifacts/execution-plans/**`
  - Keep while the plan, branch, TODO, or orchestration package is active.
  - After closeout, consolidate durable decisions into the governing TODO, closeout report, or canonical documentation before pruning.
- `artifacts/checkpoints/**`
  - Keep while branch replay, reconcile validation, promotion, or recovery depends on the checkpoint.
  - After dependency ends, reduce to a manifest or prune if the durable result is recorded elsewhere.
- Review, audit, Copilot-sim, no-context, and critique packets
  - Keep until findings are routed and dispositions are recorded in the active TODO or finding ledger.
  - After routing, prune raw packets unless they are named evidence for an unresolved blocker.
- Metrics and summaries
  - Prefer compact/rotate over blind deletion when trend evidence is useful.
  - Raw logs may be pruned after summaries are preserved and no active blocker cites them.
- Named persistent artifacts
  - Keep only when they have a live reference or ongoing recovery value.
  - Otherwise consolidate the decision/evidence into the correct durable document and prune the artifact copy.

## Workflow
1. **Locate roots**
   - Identify explicit roots from the user request first.
   - Common roots include `foundation_documentation/artifacts`, repository-local `artifacts`, and Delphi-managed local mirrors under `delphi-ai/rules/*/local/artifacts`.
   - Report symlinks with their targets before using `find -L`, `du -L`, or other symlink-following commands.
2. **Inventory size and shape**
   - Count files and bytes by root and major subdirectory.
   - For token-pressure analysis, also count text-like files and approximate words where useful.
   - Separate `tmp`, execution plans, checkpoints, review packets, metrics/logs, and named persistent artifacts.
3. **Build a dry-run prune table**
   - For each candidate, record: path, class, size/count, proposed action, keep/delete rationale, and required consolidation if any.
   - Mark candidates as `delete`, `compact`, `keep`, or `blocked`.
4. **Run reference guards**
   - Search active TODOs, execution plans, promotion/reconcile plans, closeout reports, and foundation documentation for candidate paths and salient filenames.
   - Any hit in active or unresolved work changes the candidate to `keep` or `blocked` until the reference is resolved.
5. **Consolidate before delete**
   - Move durable decisions to the correct authoritative surface before deleting the artifact copy.
   - If the destination is canonical system documentation, present the proposed canonicalization to the user for confirmation before applying it.
   - Preferred destination depends on the truth being preserved:
     - system-wide or cross-module rules/invariants -> `project_constitution.md`
     - enduring product intent/domain language -> `project_mandate.md` or `domain_entities.md`
     - staged follow-up, sequencing, or cross-stack future work -> `system_roadmap.md`
     - module-local contracts/APIs/flows -> relevant `foundation_documentation/modules/*.md`
     - execution-specific decisions, evidence routing, and bounded delivery context -> governing TODO / closeout report / finding ledger
     - environment/runtime/validation topology -> dependency-readiness record or environment topology contract
   - If the artifact contains both durable truth and disposable raw packet detail, preserve the truth in canonical documentation and prune the packet unless active evidence rules still protect it.
   - Do not preserve raw packet volume when a short authoritative summary is sufficient.
6. **Apply only safe cleanup**
   - Delete only candidates that remain `delete` after reference and consolidation checks.
   - Preserve `.gitkeep` when a directory is intentionally tracked.
   - If the user did not explicitly authorize deletion, stop after the dry-run report.
7. **Report outcome**
   - Report deleted bytes/files, retained blockers, consolidation performed, canonical destinations updated or still required, and any artifact roots that still require user decision.

## Suggested Commands
- Symlink/root inventory:
  - `find <root> -maxdepth 4 -type l -ls`
  - `find <root>/artifacts -mindepth 1 -maxdepth 2 -type d -print`
- Size/count inventory:
  - `du -sh <root>/artifacts/* 2>/dev/null`
  - `find <root>/artifacts/tmp -type f | wc -l`
- Text volume estimate:
  - `find <root>/artifacts -type f \( -name '*.md' -o -name '*.txt' -o -name '*.json' -o -name '*.log' \) -print0 | xargs -0 wc -w`
- Reference scan:
  - `rg -n --fixed-strings '<candidate-path-or-filename>' <active-todo-root> <documentation-root>`
- Safe tmp delete pattern after approval:
  - `find <root>/artifacts/tmp -mindepth 1 ! -name '.gitkeep' -exec rm -rf {} +`

## Required Output
- Artifact roots inspected and symlink status.
- Dry-run table with `delete|compact|keep|blocked` classification.
- Consolidation actions performed or required, including the intended authoritative destination for each durable decision/evidence item.
- Explicit note for any proposed canonical promotion that still requires user confirmation before the artifact can be safely deleted.
- Exact destructive commands run, if any.
- Remaining blockers and the document/TODO that owns each blocker.

## Done Criteria
- Disposable artifact volume is reduced without deleting active evidence.
- Durable decisions are represented in authoritative documents rather than only in raw artifacts, especially when the artifact previously held the only copy of system-relevant truth.
- Active TODOs, promotion/reconcile lanes, review findings, and pending validation are not orphaned.
- Repository branch/worktree cleanup remains separate and, when needed, is routed through `prune-repository`.
