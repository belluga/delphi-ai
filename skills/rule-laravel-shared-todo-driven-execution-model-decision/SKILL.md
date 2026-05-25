---
name: rule-laravel-shared-todo-driven-execution-model-decision
description: "Rule: MUST use whenever Laravel-scoped implementation work needs tactical TODO authority, APROVADO, rule ingestion, and delivery gates from the canonical TODO-driven execution rule."
---

# Rule: Laravel TODO-Driven Execution

This skill is the Laravel trigger surface for TODO-driven execution. Do not duplicate the full gate language here.

## Canonical Sources
- Global rule: `rules/core/todo-driven-execution-model-decision.md`
- Workflow: `workflows/docker/todo-driven-execution-method.md`
- Laravel adjunct rule, when present in downstream stacks: `rules/stacks/laravel/shared/todo-driven-execution-model-decision.md`
- Deterministic close guard: `tools/todo_completion_guard.py`

When this skill triggers, load the global rule first. For Laravel implementation, also load the relevant Laravel workflow/rules for touched endpoints, domains, tenant access, domain resolution, package boundaries, and foundation-doc sync.

## Required Application
1. Classify the lane before implementation:
   - exemption;
   - Operational Micro-Fix;
   - Maintenance/Regression Fix with ephemeral TODO;
   - full tactical TODO lane.
2. For full tactical work, require the TODO contract before implementation:
   - bounded story slice or feature brief/direct-to-TODO rationale;
   - scope, out-of-scope, DoD, validation steps;
   - canonical module anchors and decision-consolidation targets;
   - primary profile, technical scope, and handoff trace;
   - assumptions preview and execution plan;
   - complexity policy (`small|medium|big`);
   - Plan Review Gate when required;
   - Decision Baseline freeze and module-coherence check.
3. Do not modify Laravel code, tests, routes, schemas, jobs, config, project docs, or cross-stack contracts before explicit `APROVADO`, unless the canonical rule's exemption/micro-fix lane applies.
4. After `APROVADO`, ingest the governing Laravel and shared rules/workflows for the touched surfaces before execution.
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
- Keep reusable PACED/Laravel method in `delphi-ai/`; keep project-specific Laravel exceptions and anti-pattern candidates in the downstream project's canonical docs or local rule/pattern catalog.
