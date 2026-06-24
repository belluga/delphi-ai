---
description: Select the appropriate effort tier and GOAL policy for sessions, orchestrators, executor subagents, and review subagents when the active client exposes those controls.
---

# Method: Effort Selection

## Purpose
Centralize how Delphi chooses effort tiers and GOAL usage so token spend stays intentional, repeatable, and proportional to judgment risk.

## Triggers
- The active client exposes named effort controls.
- The active client exposes persistent GOAL support.
- A session/operator needs to decide whether a surface should remain at the routine default or escalate to the highest review-focused tier.
- A subagent is about to be dispatched and its effort/GOAL policy is not already obvious from the active workflow.

## Inputs
- The active profile and technical scope.
- The current execution surface:
  - ordinary session / routine implementation turn
  - Delphi self-improvement / instruction change
  - strategic framing / recommendation
  - TODO approval / plan review
  - delivery / final review / promotion-readiness adjudication
  - executor subagent
  - formal review subagent
  - exploratory second-opinion reviewer
- Whether the active client supports persistent GOAL state.
- Whether the current judgment includes **material strategic ambiguity**.

## Material Strategic Ambiguity Test
Treat ambiguity as material when any of the following is still unresolved after first-pass planning:
- the approved `WHAT` could change, not just the implementation `HOW`;
- contract/API/schema/auth/payment/runtime-sensitive behavior may change;
- validation semantics or acceptance criteria may change;
- accepted risk, architectural direction, or module coherence may change;
- cross-module or promotion-lane consequences are still unclear.

If none of those are true, prefer the routine default instead of escalation.

## Matrix
| Surface | Recommended effort | GOAL policy | Notes |
| --- | --- | --- | --- |
| Ordinary session / routine implementation turn | `medium` | `not_needed` | Default for normal delivery turns. |
| Delphi self-improvement / instruction change | highest review-focused tier (`ExtraRight` or closest equivalent) | `not_needed` | Instruction mistakes have broad method impact. |
| Strategic framing with material strategic ambiguity | highest review-focused tier (`ExtraRight` or closest equivalent) | `not_needed` | Escalate only when first-pass planning did not resolve approval-material ambiguity. |
| Strategic framing without material strategic ambiguity | `medium` | `not_needed` | Routine recommendation work stays at default. |
| TODO approval / plan review | highest review-focused tier (`ExtraRight` or closest equivalent) | `not_needed` | Includes orchestrator-side approval reasoning. |
| Delivery / final review / promotion-readiness adjudication | highest review-focused tier (`ExtraRight` or closest equivalent) | `not_needed` | Includes P1/P2 interpretation, waiver/debt acceptance, and close-claim judgment. |
| Executor subagent | `medium` | `required when supported` | Use explicit bounded GOAL contracts. |
| Formal review subagent (`critique`, `final_review`, `test_quality_audit`, pre-promotion review) | highest review-focused tier (`ExtraRight` or closest equivalent) | `stateless by default` | Review agents are judgment-first surfaces; keep them stateless unless resumable state is required by the client/tool. |
| Exploratory second-opinion reviewer | `medium` | `stateless by default` | Escalate to the highest review-focused tier only when it becomes gate-satisfying or the ambiguity test is material. |

## Procedure
1. Confirm whether the active client actually exposes named effort controls and/or persistent GOAL support.
   - If not, record `n/a` and continue without inventing pseudo-settings.
2. Classify the current surface using the matrix above.
3. Run the Material Strategic Ambiguity Test when the surface is strategic framing or exploratory review and the correct tier is not obvious.
4. Assign the effort tier from the matrix.
5. Assign the GOAL policy from the matrix.
   - For executor subagents with GOAL support, the GOAL must name:
     - one bounded objective;
     - owned workstream/traceability rows or files/modules;
     - minimum validation required before `complete`;
     - the exact condition that returns `blocked`.
6. Record the decision where it will matter operationally:
   - session note for standalone strategic reasoning;
   - TODO review/delivery gate notes when approval or closure depends on it;
   - orchestration execution plan when subagents are dispatched.
7. If the effort decision is still disputed, use the advisory helper:
   - `python3 delphi-ai/tools/effort_selection_advisor.py --surface <surface> [--material-strategic-ambiguity] [--goals-supported]`
   - Treat its output as advisory only. It does not replace operator judgment.

## Outputs
- Recommended effort tier.
- Recommended GOAL policy.
- Short rationale tied to the current surface.
- Explicit note when the choice depended on material strategic ambiguity.

## Validation
- `medium` remains the default for routine execution and executor subagents.
- Formal review subagents default to the highest review-focused tier, not the routine default.
- GOAL contracts are used for executor subagents when the client supports them.
- Review subagents remain stateless by default unless resumable reviewer state is explicitly required by the client/tool.
- The highest review-focused tier is reserved for approval-material or review-material judgment surfaces rather than routine execution.
