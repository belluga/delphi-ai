---
name: "docker-effort-selection-method"
description: "Select the appropriate effort tier, model routing, executor state policy, and GOAL policy for sessions, orchestrators, executor subagents, monitors, and review subagents when the active client exposes those controls."
---

<!-- Generated from `workflows/docker/effort-selection-method.md` by `tools/sync_clinerules_mirrors.py`. Do not edit directly. -->

# Workflow: Effort Selection

## Purpose
Centralize how Delphi chooses effort tiers, model routing, executor state, and GOAL usage so token spend stays intentional, repeatable, and proportional to judgment risk.

## Triggers
- The active client exposes named effort controls.
- The active client exposes model selection or configurable agent files.
- The active client exposes persistent GOAL support.
- A session/operator needs to decide whether a surface should remain at the routine default or escalate to the highest review-focused tier.
- A subagent is about to be dispatched and its effort/GOAL policy is not already obvious from the active workflow.
- Code implementation, monitoring, or formal review is being routed between the chat/orchestrator and subagents.
- A governed action is about to begin and the selected lane must be recorded fail-closed before execution.

## Inputs
- The active profile and technical scope.
- The current execution surface:
  - ordinary chat/orchestrator turn
  - Delphi self-improvement / instruction change
  - strategic framing / recommendation
  - TODO approval / plan review
  - delivery / final review / promotion-readiness adjudication
  - executor subagent
  - process monitoring / log status pass
  - formal review subagent
  - exploratory second-opinion reviewer
- Whether the active client supports model selection.
- Whether the active client supports persistent GOAL state.
- Whether the active client supports a per-chat/TODO sticky executor state.
- Whether the current judgment includes **material strategic ambiguity**.
- Whether the selected lane will be proved by client artifact, declaration, or explicit waiver.

## Model Routing Defaults
- Model identifiers and review-kind routing live only in `config/agent_role_routing.json`; this workflow must not duplicate them. Resolve the selected client, surface, and review kind through `agent_role_routing_guard.py` before governed work begins.
- Keep ordinary chat/orchestrator turns at `medium` effort and on the active session/default model unless the turn itself becomes a governed review/adjudication surface.
- The chat/orchestrator plans, packages handoffs, reconciles evidence, and adjudicates gates. When executor subagents are available, it does not directly create implementation code for TODO slices except for workflow-authorized reconciliation, merge-conflict resolution, or minimal integration glue.
- For high-risk implementation whose `HOW` still requires deep reasoning after planning, keep the executor handoff but select the configured escalation model instead of changing authority boundaries.
- Monitoring is deterministic first. If an LLM is needed for process status, use an ephemeral low/medium mini pass over bounded output; do not create a standing watcher or let the main chat consume verbose logs continuously.
- Before governed implementation, implementation-side validation, monitoring, approval, delivery review, or formal review begins, resolve the selected lane through `config/agent_role_routing.json` and require `python3 delphi-ai/tools/agent_role_routing_guard.py ...` to return `Overall outcome: go`.

## Sticky Executor State Policy
- Sticky means per chat/TODO only, never global across unrelated work.
- The executor wakes only on explicit handoff from the orchestrator; it does not monitor background processes.
- Retained state must be compact: owned files/modules, implementation decisions, commands/tests already run, blockers, and the last accepted patch state.
- Do not retain raw logs, complete diffs, transcripts, full command output, generated artifacts, or large search/read dumps in sticky executor state.
- Reset or recompact the executor at TODO closeout, major scope/module change, large context ingestion, stale/confused state, or when the active branch/worktree authority changes materially.

## Material Strategic Ambiguity Test
Treat ambiguity as material when any of the following is still unresolved after first-pass planning:
- the approved `WHAT` could change, not just the implementation `HOW`;
- contract/API/schema/auth/payment/runtime-sensitive behavior may change;
- validation semantics or acceptance criteria may change;
- accepted risk, architectural direction, or module coherence may change;
- cross-module or promotion-lane consequences are still unclear.

If none of those are true, prefer the routine default instead of escalation.

## Matrix
| Surface | Recommended model | Recommended effort | GOAL policy | State policy | Notes |
| --- | --- | --- | --- | --- | --- |
| Ordinary chat/orchestrator turn | active session/default model | `medium` | `not_needed` | primary chat state | Default for normal delivery turns; plans and packages handoffs but does not create implementation code when executor subagents are available. |
| Routine code executor subagent | contract-selected `routine_executor` | `medium` | `required when supported` | sticky per chat/TODO, compact state | Use explicit bounded GOAL contracts and reset/recompact under the sticky executor policy. |
| High-risk code executor subagent | contract-selected escalation | `medium` or higher only when justified | `required when supported` | bounded executor state | Keep the code handoff rather than moving implementation into the chat. |
| Process monitoring / log status | deterministic first; contract-selected monitoring model if LLM needed | `low` or `medium` | `not_needed` | ephemeral | Summarize bounded output only; no standing watcher and no verbose-log monitoring in the main chat. |
| Delphi self-improvement / instruction change | contract-selected strongest review | highest review-focused tier (`ExtraRight` or closest equivalent) | `not_needed` | primary chat state | Instruction mistakes have broad method impact. |
| Strategic framing with material strategic ambiguity | contract-selected strongest review | highest review-focused tier (`ExtraRight` or closest equivalent) | `not_needed` | primary chat state | Escalate only when first-pass planning did not resolve approval-material ambiguity. |
| Strategic framing without material strategic ambiguity | active session/default model | `medium` | `not_needed` | primary chat state | Routine recommendation work stays at default. |
| TODO approval / plan review | contract-selected governance review | highest review-focused tier (`ExtraRight` or closest equivalent) | `not_needed` | primary chat state | Includes orchestrator-side approval reasoning. |
| Delivery / final review / promotion-readiness adjudication | contract-selected review kind | highest review-focused tier (`ExtraRight` or closest equivalent) | `not_needed` | primary chat state | Includes P1/P2 interpretation, waiver/debt acceptance, and close-claim judgment. |
| Formal review subagent | contract-selected review kind | highest review-focused tier (`ExtraRight` or closest equivalent) | `stateless by default` | no-context stateless review | Review agents are judgment-first surfaces; keep them stateless unless resumable state is required by the client/tool. |
| Exploratory second-opinion reviewer | active session/default or contract-selected review kind | `medium` | `stateless by default` | no-context stateless review | Escalate to the highest review-focused tier only when it becomes gate-satisfying or the ambiguity test is material. |

## Procedure
1. Confirm whether the active client actually exposes named effort controls, model selection, sticky/custom agent state, and/or persistent GOAL support.
   - If not, record `n/a` and continue without inventing pseudo-settings.
2. Classify the current surface using the matrix above.
3. Run the Material Strategic Ambiguity Test when the surface is strategic framing or exploratory review and the correct tier is not obvious.
4. Assign the recommended model from the matrix when model selection is available.
5. Assign the effort tier from the matrix.
6. Assign the GOAL policy from the matrix.
   - For executor subagents with GOAL support, the GOAL must name:
     - one bounded objective;
     - owned workstream/traceability rows or files/modules;
     - minimum validation required before `complete`;
     - the exact condition that returns `blocked`.
7. Assign the state policy from the matrix.
   - For routine executor subagents, prefer one sticky executor per chat/TODO when supported, but keep its retained state compact and reset it under the Sticky Executor State Policy.
   - For review subagents, keep no-context stateless behavior by default.
   - For monitoring, keep the pass ephemeral unless a workflow explicitly defines a bounded monitor artifact.
8. Record the decision where it will matter operationally:
   - session note for standalone strategic reasoning;
   - TODO review/delivery gate notes when approval or closure depends on it;
   - orchestration execution plan when subagents are dispatched.
9. For governed execution/review surfaces, run the deterministic routing guard before the action begins:
   - `python3 delphi-ai/tools/agent_role_routing_guard.py --client <client> --surface <surface> --role <role> --model <model> --effort <effort-or-n/a> --proof-mode <artifact|declared|waiver> [--exception-reason <reason>] [--waiver-reference <ref>]`
   - if the outcome is `delegate-required`, `review-required`, `waiver-required`, or `blocked`, stop and repair the routing instead of proceeding.
10. If the effort/model decision is still disputed, use the advisory helper:
   - `python3 delphi-ai/tools/effort_selection_advisor.py --surface <surface> [--material-strategic-ambiguity] [--goals-supported]`
   - Treat its output as advisory only. It does not replace operator judgment.

## Outputs
- Recommended effort tier.
- Recommended model when selectable.
- Recommended GOAL policy.
- Recommended state policy.
- Recommended proof mode and guard-ready routing declaration.
- Short rationale tied to the current surface.
- Explicit note when the choice depended on material strategic ambiguity.

## Validation
- `medium` remains the default for ordinary chat/orchestrator turns and routine executor subagents.
- Routine code executor subagents use the contract-selected `routine_executor` model when model selection is available.
- Chat/orchestrator turns do not create implementation code when executor subagents are available, except for workflow-authorized reconciliation/merge-conflict/integration glue.
- Formal review subagents use the contract-selected family for their explicit review kind, not the routine default.
- GOAL contracts are used for executor subagents when the client supports them.
- Sticky executor state is per chat/TODO, compact, non-monitoring, and reset at closeout or material scope/context changes.
- Monitoring is deterministic first or ephemeral mini summarization, not continuous main-chat log watching.
- Review subagents remain stateless by default unless resumable reviewer state is explicitly required by the client/tool.
- The highest review-focused tier is reserved for approval-material or review-material judgment surfaces rather than routine execution.
- Governed execution/review surfaces do not proceed unless `agent_role_routing_guard.py` resolves to `go` and the routing evidence is recorded in the governing TODO or orchestration plan.
