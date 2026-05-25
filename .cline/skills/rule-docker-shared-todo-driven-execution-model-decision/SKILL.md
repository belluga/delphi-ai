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
- Deterministic close guard: `tools/todo_completion_guard.py`

When this skill triggers, load the canonical rule first and follow it as the source of truth. Use the workflow when execution, planning, approval, or delivery sequencing is in scope.

## Required Application
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
3. Do not modify project code, submodule code, tests, runtime files, or project docs before explicit `APROVADO`, unless the canonical rule's exemption/micro-fix lane applies.
4. After `APROVADO`, ingest the governing rules/workflows for the touched surfaces before execution.
5. Before delivery, require evidence for:
   - Completion Evidence Matrix;
   - Local CI-Equivalent Suite Matrix;
   - Decision Adherence and module consistency;
   - Pipeline/Copilot P1/P2 Preflight;
   - Rule-Spirit Anti-Pattern Hunt;
   - security, performance/concurrency, verification debt, test-quality audit, and final review according to the canonical rule and audit floor.

## Delivery Blockers
- Unresolved `P1` or `P2` findings in the Pipeline/Copilot preflight block delivery.
- Unresolved `P1` or `P2` findings in the Rule-Spirit Anti-Pattern Hunt block delivery.
- Missing, aggregate-only, placeholder, or non-criterion-specific evidence blocks delivery.
- `tools/todo_completion_guard.py <todo-path>` must return `Overall outcome: go` before any `Local-Implemented`, `promotion_lane/`, `completed/`, or `Production-Ready` claim.

## Drift Control
- If this skill and the canonical rule disagree, the canonical rule wins and this skill should be updated.
- Keep reusable PACED rules in `delphi-ai/`; keep project-specific exceptions and anti-pattern candidates in the downstream project's canonical docs or local rule/pattern catalog.
