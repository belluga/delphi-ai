---
description: Run planning review, audit-floor decisions, critique, and explicit approval gates before TODO implementation starts.
---

# Method: TODO Approval Gates

## Purpose
Validate the refined TODO before execution and obtain explicit approval. This phase protects against implementing under ambiguous scope, stale decisions, weak evidence planning, or insufficient audit floor.

## Inputs
- Refined tactical TODO.
- Complexity classification.
- Audit trigger matrix when required.
- Bounded review packages for critique/triple-review when triggered.

## Procedure
1. Freeze or refresh the `Decision Baseline (Frozen)` before execution.
2. Run the Module Coherence Gate:
   - check that active decisions align with module docs and project constitution;
   - raise approval-material drift before implementation.
3. Resolve COMMENT blocks and open material decisions.
4. Run Plan Review Gate:
   - `small`: abbreviated unless risk requires full review;
   - `medium|big`: full issue cards, failure modes, and residual unknowns.
5. Populate the TODO `Audit Trigger Matrix` and run:
   - `python3 delphi-ai/tools/audit_escalation_guard.py --todo <todo-path>`
   - require `Overall outcome: go` before trusting audit decisions.
6. Run the derived critique/triple-review lanes when required or recommended by the audit floor.
7. Ask the user to reply with **`APROVADO`** for tactical and ephemeral TODO lanes.

## Outputs
- Plan Review Gate evidence.
- Audit-floor evidence and required critique/triple-review evidence.
- Frozen decision baseline.
- Explicit approval record.

## Non-Negotiables
- No implementation before `APROVADO`.
- If approval-material scope, decision, validation, or architecture facts change, refresh the TODO and request renewed `APROVADO`.
- Do not substitute ad hoc reviewer sequencing for the dedicated triple-review workflow when the derived floor requires or recommends it.
