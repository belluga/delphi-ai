---
name: "docker-independent-critique-method"
description: "Define the canonical no-context auxiliary critique gate for higher-complexity or higher-impact tactical TODOs, including trigger rules, package hygiene, retry discipline, and resolution handling."
---

<!-- Generated from `workflows/docker/independent-critique-method.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# Workflow: Independent No-Context Critique

## Purpose
Provide the canonical planning-side challenge lane for a tactical TODO once `wf-docker-audit-escalation-method` has derived the critique floor.

This method exists to expose weak assumptions, blind spots, and plan-review gaps before implementation starts. It is a challenge mechanism, not an authority transfer.
It must also challenge whether the planned path is sound for performance, elegant, and structurally sound rather than reliant on brittle workarounds or structural shortcuts.

## When It Applies
- Run this method whenever `wf-docker-audit-escalation-method` marks `critique` as `required|recommended`.
- The deterministic floor currently makes critique the baseline planning challenge lane for tactical TODOs.
- The audit-escalation guard decides whether the package depth stays `baseline` or becomes `expanded`.

## Inputs
- Tactical TODO under `foundation_documentation/todos/active/`.
- The pushed review baseline recorded in `Gate: Review Baseline Freeze`.
- Frozen decisions, assumptions preview, execution plan, and Plan Review Gate output.
- A bounded critique package:
  - either a curated file set,
  - or a concise structured summary of the relevant review package.

## Package Hygiene
- The critique package must be bounded. Do not hand the full session transcript or diffuse conversational history to the internal reviewer.
- Prefer one of these package shapes:
  - `bounded-file-set`: only the canonical files or diffs needed to critique the current decision package;
  - `bounded-summary`: a concise structured summary containing frozen decisions, assumptions, plan, issue cards, and residual risks.
- If using a `bounded-summary`, it must include at minimum:
  - frozen decisions / baseline;
  - approved scope boundary;
  - assumptions preview that still matters to planning;
  - execution plan summary;
  - material issue cards already raised;
  - residual risks / unknowns;
  - any existing waivers or blockers already affecting the TODO.
- Preserve the key constraints and open risks rather than paraphrasing them into soft language.

## Required-Gate Waiver Control
- If a `required` no-context critique cannot be completed after one retry, a `blocked` record alone does not permit `APROVADO`.
- Only the current human approval authority for the TODO may waive a required critique gate.
- The waiver record must include:
  - `waiver_reason`
  - `approver_id`
  - `approval_reference`
  - `mitigation_summary`
  - `follow_up_owner`
  - `follow_up_task_id`

## Procedure
1. Use the latest successful `wf-docker-audit-escalation-method` output as the minimum decision authority for this gate.
   - If implementation or planning changed any trigger materially, rerun the audit-escalation guard before trusting the old critique decision.
2. Confirm the review baseline freeze is already committed and pushed.
   - The TODO must record `Gate: Review Baseline Freeze` with a real branch/commit/push reference before the first critique run.
   - If that gate is missing or unresolved, block the critique lane instead of treating an unpushed worktree snapshot as canonical review input.
3. Build the bounded critique package.
   - If orchestration tooling is desired, derive a dispatch packet with `python3 delphi-ai/tools/subagent_review_dispatch.py --review-kind critique ...`.
4. Run one fresh internal critique with no inherited thread context.
   - This critique pass must use a fresh internal no-context reviewer/subagent with `fork_context=false`; it must not be the implementing agent.
   - Internal no-context reviewer availability inside the active client is treated as operationally mandatory. If no free reviewer slot is available, close/recycle another review lane and open a fresh reviewer instead of downgrading to self-review.
   - Do not invoke or treat an external provider as gate-satisfying review evidence.
   - In other environments, use the closest internal equivalent that guarantees no prior thread contamination.
5. Prompt the reviewer to return findings first, ordered by severity, and to avoid implementation.
   - Require explicit positions on:
     - performance acceptability;
     - elegance (simplicity/coherence/minimal incidental complexity);
     - structural soundness, meaning resistance to brittle workarounds or structural shortcuts such as ad hoc patches, layered patches over unresolved defects, contract bypasses, opportunistic duplication, hidden coupling, or other avoidable structural debt.
6. Treat the critique as challenge evidence only:
   - advisory, never authoritative by itself;
   - it may invalidate assumptions or planning quality, but it does not replace user approval.
7. If the first no-context critique attempt fails or times out, retry once with a tighter package.
8. If a `required` critique still cannot be obtained after one retry:
   - record the tooling limitation explicitly;
   - do not silently treat bounded self-review as equivalent to a true fresh no-context critique;
   - require either a blocker state or an explicit waiver before `APROVADO`;
   - treat `blocked` as non-satisfying until the gate is actually run or explicitly waived by the approval authority.
9. Resolve every material finding explicitly in the TODO as one of:
   - `Integrated`
   - `Challenged`
   - `Deferred with rationale`
   - If structured reviewer JSON was used, merge it with `python3 delphi-ai/tools/subagent_review_merge.py ...` before recording the authoritative resolution.
   - Prefer the machine-checkable resolution table from `templates/todo_template.md`, then derive `*-resolution.json` with `python3 delphi-ai/tools/gate_finding_resolution_extract.py --review-kind critique ...` when metrics are in scope.
10. After critique findings converge, run the narrower assumption-vs-code coherence guard before `APROVADO`.
   - Use the governing TODO plus the exact code/test files cited by the still-live assumptions.
   - Require concrete file-path evidence for those assumptions; if the TODO only cites docs or vague notes, strengthen it before approval.
   - Run `python3 delphi-ai/tools/assumption_code_coherence_guard.py --todo <todo-path>` and record the result in `Gate: Assumption Code Coherence`.
11. After the planning-side integrations settle, run `python3 delphi-ai/tools/review_scope_drift_guard.py --todo <todo-path>` to compare the current TODO against the pushed review baseline.
   - If the guard reports material scope-governing drift, return the TODO to the review loop, revalidate the evolved scope with the user, refresh the pushed baseline when needed, and rerun the affected critique/review lanes before approval.
12. If the critique, the assumption-vs-code guard, or the review-scope-drift guard reveals contract changes, module supersedes, or approval-material/significant plan changes, send the TODO back to the review loop, refresh it, revalidate the evolved scope with the user, and request renewed approval only after the updated direction reconverges.
13. Treat `audit-protocol-triple-review` as additive only.
   - It may coexist with this critique lane.
   - It remains the compatibility id for the dedicated delivery-side multi-lane audit.
   - It does not silently replace this planning challenge gate.

## Outputs
- A recorded critique decision (`required|recommended|not_needed`) with rationale.
- A bounded critique package reference.
- Findings summarized in the TODO with explicit resolution status.
- An assumption-vs-code coherence record showing whether the remaining assumptions still match the cited code reality.
- A blocker or waiver record if a required no-context critique could not be executed.

## Non-Authority Rule
- Fresh internal critiques are intentionally independent, but they do not own the decision.
- Implementation authority remains the tactical TODO, explicit `APROVADO`, and the normal decision-adherence gates.
