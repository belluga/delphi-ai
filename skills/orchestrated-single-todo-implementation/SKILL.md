---
name: orchestrated-single-todo-implementation
description: Explicitly orchestrate implementation of one approved tactical TODO, including authorized Laravel, Flutter, or Docker changes, with canonical routing and deterministic intake checks.
---

# Orchestrated Single Todo Implementation

Invoke this skill by name only when exactly one canonical tactical TODO is approved. It may cover explicitly authorized Laravel, Flutter, or Docker work when the same TODO names those paths. Do not use it for broad or multiple-TODO initiatives, or for work without a canonical approved TODO.

Before editing, run the two deterministic helpers from the repository root:

1. `python3 tools/orchestrated_single_todo_routing.py --client <client> --surface <surface> --role <role> --json-output <ignored-temp-file>`
2. `python3 tools/orchestrated_single_todo_teach.py --todo <exact-todo> --baseline <frozen-ref@commit> --approval-gate approved --authority-gate canonical --primary-goal-state active --primary-goal-report <reported-state> --changed-path <path> ... --expected-path <contract-path-or-glob> ... --writer-role routine-executor --raw-artifact-root <ignored-temp-root> --token-total unavailable --execution-kind <llm-subagent|deterministic-only> --model-family <JSON-resolved-family-or-n/a> --goal-tokens-used <integer-or-n/a> --goal-token-budget <integer|unbudgeted|n/a> --goal-time-used-seconds <seconds-or-n/a> [--goal-created --goal-completed] [--metrics-opt-out-reference user-approved:<reference>]`

Stop on a TEACH block. A successful resolver is evidence of the existing `config/agent_role_routing.json` selection, not a replacement authority. The exact TODO must authorize every expected path, including any cross-stack path. The routine executor remains the sole normal material writer; provider fallback and automatic dispatch are prohibited.

Every dispatched LLM subagent must create a Goal before work, call `update_goal` with `status=complete` after work, and return Goal runtime telemetry: `tokensUsed`, `tokenBudget` (an integer or `unbudgeted`), and `timeUsedSeconds`. The orchestrator records one compact per-subagent record plus totals grouped by the JSON-resolved model family in the exact TODO. This is Goal runtime telemetry only: it is not a provider receipt, never an estimate, and never a session total. Deterministic-only work may report all Goal fields as explicit `n/a`; missing or invalid LLM metrics block.

Before any real TODO execution, the primary orchestrator must create and hold an active Goal and report its state to TEACH. If the user explicitly opts out of metrics, pass a `user-approved:<reference>` recorded under the exact TODO's opt-out section; never infer an opt-out. Missing primary Goal state/report or malformed opt-out blocks.

Keep raw command/review/usage payloads only under the ignored temporary execution root. Record compact command/result summaries and Goal runtime telemetry in the exact TODO; Goal values are never provider receipts, estimates, or session totals.
