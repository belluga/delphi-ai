---
name: "docker-independent-critique-method"
description: "Define the canonical no-context auxiliary critique gate for higher-complexity or higher-impact tactical TODOs, including trigger rules, package hygiene, retry discipline, and resolution handling."
---

<!-- Generated from `workflows/docker/independent-critique-method.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# Workflow: Independent No-Context Critique

## Purpose
Provide a repeatable challenge lane for tactical TODOs whose complexity or blast radius is high enough that a fresh reviewer with no inherited thread context materially improves the quality of planning and critique.

This method exists to expose weak assumptions, blind spots, and plan-review gaps before implementation starts. It is a challenge mechanism, not an authority transfer.
It must also challenge whether the planned path is sound for performance, elegant, and structurally sound rather than reliant on brittle workarounds or structural shortcuts.

## When It Applies
- Always `required` for tactical TODOs classified as `big`.
- `Required` for `medium` tactical TODOs when any of the following are true:
  - blast radius is `cross-module`;
  - the TODO changes public contract/API/schema/route/auth/payment behavior;
  - the TODO changes runtime/infra-sensitive paths such as queue/worker/realtime/ingress/runtime configuration;
  - the TODO intentionally supersedes canonical module decisions;
  - the Plan Review Gate contains any `high` severity issue card.
- `Recommended` for other `medium` tactical TODOs.
- `Not needed` only for low-risk `small` TODOs unless the user explicitly asks for an external challenge anyway.

## Inputs
- Tactical TODO under `foundation_documentation/todos/active/`.
- Frozen decisions, assumptions preview, execution plan, and Plan Review Gate output.
- A bounded critique package:
  - either a curated file set,
  - or a concise structured summary of the relevant review package.

## Package Hygiene
- The critique package must be bounded. Do not hand the full session transcript or diffuse conversational history to the external reviewer.
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
1. Record the critique decision in the TODO as `required|recommended|not_needed` with rationale.
2. Build the bounded critique package.
   - If orchestration tooling is desired, derive a dispatch packet with `python3 delphi-ai/tools/subagent_review_dispatch.py --review-kind critique ...`.
3. Run one fresh auxiliary critique with no inherited thread context.
   - If a subagent is available in the environment, use that subagent with `fork_context=false`.
   - If no subagent is available, document the constraint and run a bounded no-context self-review from the package only.
   - In other environments, use the closest equivalent that guarantees no prior thread contamination.
4. Prompt the reviewer to return findings first, ordered by severity, and to avoid implementation.
   - Require explicit positions on:
     - performance acceptability;
     - elegance (simplicity/coherence/minimal incidental complexity);
     - structural soundness, meaning resistance to brittle workarounds or structural shortcuts such as ad hoc patches, layered patches over unresolved defects, contract bypasses, opportunistic duplication, hidden coupling, or other avoidable structural debt.
5. Treat the critique as challenge evidence only:
   - advisory, never authoritative by itself;
   - it may invalidate assumptions or planning quality, but it does not replace user approval.
6. If the first no-context critique attempt fails or times out, retry once with a tighter package.
7. If a `required` critique still cannot be obtained after one retry:
   - record the tooling limitation explicitly;
   - do not silently treat bounded self-review as equivalent to a true fresh no-context critique;
   - require either a blocker state or an explicit waiver before `APROVADO`;
   - treat `blocked` as non-satisfying until the gate is actually run or explicitly waived by the approval authority.
8. Resolve every material finding explicitly in the TODO as one of:
   - `Integrated`
   - `Challenged`
   - `Deferred with rationale`
   - If structured reviewer JSON was used, merge it with `python3 delphi-ai/tools/subagent_review_merge.py ...` before recording the authoritative resolution.
   - Prefer the machine-checkable resolution table from `templates/todo_template.md`, then derive `*-resolution.json` with `python3 delphi-ai/tools/gate_finding_resolution_extract.py --review-kind critique ...` when metrics are in scope.
9. If the critique reveals contract changes, module supersedes, or approval-material plan changes, refresh the TODO and request renewed approval before implementation.

## Outputs
- A recorded critique decision (`required|recommended|not_needed`) with rationale.
- A bounded critique package reference.
- Findings summarized in the TODO with explicit resolution status.
- A blocker or waiver record if a required no-context critique could not be executed.

## Non-Authority Rule
- Fresh auxiliary critiques are intentionally independent, but they do not own the decision.
- Implementation authority remains the tactical TODO, explicit `APROVADO`, and the normal decision-adherence gates.
