---
name: rule-docker-shared-todo-driven-execution-model-decision
description: "Rule: MUST use whenever the scope matches this purpose: Before implementation work, enforce tactical TODO authority, APROVADO, rule ingestion, and delivery gates from the canonical TODO-driven execution rule."
---

# Rule: TODO-Driven Execution

This skill is the trigger surface for the canonical TODO-driven execution rule. Do not duplicate the full gate language here.

## Canonical Sources
- Rule: `rules/core/todo-driven-execution-model-decision.md`
- Workflow umbrella: `workflows/docker/todo-driven-execution-method.md`
- Phase workflows: `workflows/docker/todo-*-method.md`
- Deterministic diff-scope guard: `tools/todo_diff_expectation_guard.py`
- Deterministic authority/process guard: `tools/todo_authority_guard.py`
- Deterministic close guard: `tools/todo_completion_guard.py`

When this skill triggers, load the canonical rule first and follow it as the source of truth. Use the workflow when execution, planning, approval, or delivery sequencing is in scope.

## Required Application
0. Keep subagent/delegation authority independent from Git-isolation authority. Default to one writer at a time in the principal checkout. Worktrees, auxiliary checkouts/copies, `worker/*`, and `reconcile/*` require separate human authorization explicitly naming worktrees or auxiliary checkouts.
1. Classify the lane before implementation:
   - exemption;
   - Operational Micro-Fix;
   - Maintenance/Regression Fix with ephemeral TODO;
   - full tactical TODO lane.
2. For full tactical work, require the tactical TODO contract before implementation:
   - bounded story slice or feature brief/direct-to-TODO rationale;
   - scope, out-of-scope, DoD, validation steps;
   - canonical module anchors and decision-consolidation targets;
   - primary profile, technical scope, and handoff trace;
   - assumptions preview and execution plan;
   - complexity policy (`small|medium|big`);
   - Plan Review Gate when required;
   - Decision Baseline freeze and module-coherence check.
3. Do not modify project code, submodule code, runtime files, or project docs before explicit `APROVADO`, unless the canonical rule's exemption/micro-fix lane applies. Test/support edits before approval are allowed only through the canonical bounded pre-`APROVADO` RED evidence capture lane for bugfix/regression TODOs.
4. After `APROVADO`, record compact approval evidence in the TODO, ingest the governing rules/workflows for the touched surfaces, and run `tools/todo_authority_guard.py <todo-path>` before execution.
5. Before delivery, require evidence for:
   - the strict `Diff Expectation Contract` and a passing `tools/todo_diff_expectation_guard.py` result;
   - Completion Evidence Matrix;
   - Local CI-Equivalent Suite Matrix;
   - Decision Adherence and module consistency;
   - Pipeline/Copilot P1/P2 Preflight;
   - Rule-Spirit Anti-Pattern Hunt;
   - security, performance/concurrency, verification debt, test-quality audit, and final review according to the canonical rule and audit floor.
   - `tools/todo_diff_expectation_guard.py <todo-path> --repo-root <authoritative-checkout>`, `tools/todo_authority_guard.py <todo-path> --require-delivery-gates`, and `tools/todo_completion_guard.py <todo-path>` must all return `Overall outcome: go`.

## Delivery Blockers
- Unresolved `P1` or `P2` findings in the Pipeline/Copilot preflight block delivery.
- Unresolved `P1` or `P2` findings in the Rule-Spirit Anti-Pattern Hunt block delivery.
- Missing approval evidence or rule-ingestion evidence blocks implementation.
- Any unclassified, forbidden, or incompatible real diff path/type blocks delivery for `Diff Deviation Analysis`: classify it as scope deviation, necessary/justifiable need, or noise. A no-go is not an automatic rollback; defend necessary changes with evidence, clean noise, revert unnecessary deviations, and require user validation plus renewed approval for necessary scope expansion.
- Missing, aggregate-only, placeholder, or non-criterion-specific evidence blocks delivery.
- `tools/todo_authority_guard.py <todo-path> --require-delivery-gates` and `tools/todo_completion_guard.py <todo-path>` must return `Overall outcome: go` before any `Local-Implemented`, `promotion_lane/`, `completed/`, or `Production-Ready` claim.

## Drift Control
- If this skill and the canonical rule disagree, the canonical rule wins and this skill should be updated.
- Keep reusable PACED rules in `delphi-ai/`; keep project-specific exceptions and anti-pattern candidates in the downstream project's canonical docs or local rule/pattern catalog.
