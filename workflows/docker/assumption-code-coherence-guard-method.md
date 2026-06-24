---
description: Run a post-critique guard that checks whether still-live planning assumptions are actually coherent with the cited code/test reality before APROVADO.
---

# Method: Assumption-vs-Code Coherence Guard

## Purpose
Add a narrow post-critique verification layer that specifically hunts for wrong implementation assumptions relative to the current codebase.

This guard is intentionally narrower than architecture critique or final review:
- critique challenges the plan broadly;
- this guard checks whether the remaining live assumptions are truly supported by the cited code/test reality.

## When It Applies
- After the planning-side review rounds have converged.
- Before requesting `APROVADO`.
- Whenever the TODO still contains live assumptions under `Assumptions Preview`.

## Inputs
- Governing tactical TODO.
- The exact code/test files cited by the still-live assumptions.
- Any critique findings already integrated or challenged.

## Procedure
1. Identify the still-live assumptions.
   - Focus on assumptions whose handling remains `Keep as Assumption` or `Block`.
   - If no assumptions remain live, record `not_needed` with rationale.
2. Require concrete code/test evidence.
   - Each still-live assumption must cite exact file paths, not only broad prose or doc-only references.
   - Strengthen the TODO first if the evidence is vague.
3. Run the deterministic support check:
   - `python3 delphi-ai/tools/assumption_code_coherence_guard.py --todo <todo-path>`
4. Review the cited code/test surfaces directly.
   - Confirm the recommended direction is coherent with the current implementation reality.
   - Look specifically for stale mental models, renamed call sites, moved ownership layers, hidden shared value objects, old test assumptions, or false claims about what is already paged/filtered/materialized.
5. Record the result in `Gate: Assumption Code Coherence`.
   - `no_material_findings` when the assumptions remain code-coherent.
   - `findings_integrated` when the guard exposed wrong assumptions that were corrected in the TODO.
   - `blocked` or `waived` only with explicit rationale.
6. If the guard reveals approval-material or otherwise significant changes:
   - send the TODO back to the review loop;
   - refresh the TODO;
   - rerun the affected review/critique loop;
   - request renewed approval only after the updated direction reconverges.

## Outputs
- Deterministic guard result (`go|no-go`).
- TODO evidence under `Gate: Assumption Code Coherence`.
- Refreshed TODO/review package when wrong assumptions were found.

## Non-Negotiables
- Do not request `APROVADO` while the assumption-vs-code guard is unresolved.
- Do not accept doc-only or conversational evidence for still-live implementation assumptions when code/test evidence is expected to exist.
- Do not let this guard replace critique; it is additive and narrower.
- A significant guard finding returns the TODO to review; it never allows direct continuation into implementation or approval.
